// ***************************************************************************
// Copyright (c) 2013-2017, Intel Corporation All Rights Reserved.
// The source code contained or described herein and all  documents related to
// the  source  code  ("Material")  are  owned by  Intel  Corporation  or  its
// suppliers  or  licensors.    Title  to  the  Material  remains  with  Intel
// Corporation or  its suppliers  and licensors.  The Material  contains trade
// secrets and  proprietary  and  confidential  information  of  Intel or  its
// suppliers and licensors.  The Material is protected  by worldwide copyright
// and trade secret laws and treaty provisions. No part of the Material may be
// copied,    reproduced,    modified,    published,     uploaded,     posted,
// transmitted,  distributed,  or  disclosed  in any way without Intel's prior
// express written permission.
// ***************************************************************************
//

import ccip_if_pkg::*;

module mem_csr #(
   parameter DDR_ADDR_WIDTH=26
) (
	// ---------------------------global signals-------------------------------------------------
  input	Clk_400,	  // Core clock. CCI interface is synchronous to this clock.
  input	SoftReset,	// CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH

	// ---------------------------IF signals between CCI and AFU  --------------------------------
	input	 t_if_ccip_Rx    cp2af_sRxPort,
	output t_if_ccip_Tx	   af2cp_sTxPort,

  // avm
  output reg [31:0]      avm_address,
  output reg [11:0]      avm_burstcount,
  output reg             avm_read,
  input [63:0]           avm_readdata,
  input [1:0]            avm_response,
  output reg             avm_write,
  output reg [63:0]      avm_writedata,

  // control and status
  output reg             mem_testmode,
  input [4:0]            addr_test_status,
  input                  addr_test_done, 
  input [1:0]            rdwr_done,  
  input [4:0]            rdwr_status, 
  output reg             rdwr_reset,
  output reg             mem_bank_select,
  input wire             ready_for_sw_cmd
);

localparam HELLO_AFU_ID_H        = 64'h35F9_452B_25C2_434C; // HELLO_AFU_ID Upper 
localparam HELLO_AFU_ID_L        = 64'h93D5_6F8C_60DB_361C; // HELLO_AFU_ID Lower
localparam AFU_ID_L              = 16'h0002;                // AFU ID Lower
localparam AFU_ID_H              = 16'h0004;                // AFU ID Higher 
localparam SCRATCH_REG           = 16'h0020;                // Scratch Register
localparam MEM_ADDRESS           = 16'h0040;                // AVMM Master Address
localparam MEM_BURSTCOUNT        = 16'h0042;                // AVMM Master Burst Count
localparam MEM_RDWR              = 16'h0044;                // AVMM Master Read/Write
localparam MEM_WRDATA            = 16'h0046;                // AVMM Master Write Data
localparam MEM_RDDATA            = 16'h0048;                // AVMM Master Read Data
localparam MEM_ADDR_TESTMODE     = 16'h004A;                // Test Control Register        
localparam MEM_ADDR_TEST_STATUS  = 16'h0060;                // Test Status Register
localparam MEM_RDWR_STATUS       = 16'h0062;
localparam MEM_BANK_SELECT       = 16'h0064;                // Memory bank selection register
localparam READY_FOR_SW_CMD      = 16'h0066;                // "Ready for sw cmd" register. S/w must poll this register before issuing a read/write command to fsm

// cast c0 header into ReqMmioHdr
t_ccip_c0_ReqMmioHdr mmioHdr;
assign mmioHdr = t_ccip_c0_ReqMmioHdr'(cp2af_sRxPort.c0.hdr);

logic [63:0] scratch_reg = '0;
logic [2:0]  mem_RDWR = '0;

always@(posedge Clk_400) begin
  if(SoftReset) begin
    af2cp_sTxPort.c1.hdr        <= '0;
    af2cp_sTxPort.c1.valid      <= '0;
    af2cp_sTxPort.c1.data       <= '0;
    af2cp_sTxPort.c0.hdr        <= '0;
    af2cp_sTxPort.c0.valid      <= '0;
    af2cp_sTxPort.c2.hdr        <= '0;
    af2cp_sTxPort.c2.data       <= '0;
    af2cp_sTxPort.c2.mmioRdValid <= '0;
    scratch_reg    <= '0;
    avm_address    <= '0;
    //avm_burstcount <= '0;
    avm_read       <= '0;
    avm_write      <= '0;
    avm_burstcount <= 12'd1;
    avm_writedata  <= '0;
    mem_testmode   <= '0;
    mem_RDWR       <= '0;
    mem_testmode   <= '0;
    rdwr_reset     <= 1;
    mem_bank_select <= '0;
  end
  else begin
      rdwr_reset     <= 0;
      af2cp_sTxPort.c2.mmioRdValid <= 0;
      avm_read  <= mem_RDWR[0] &  mem_RDWR[1]; //[0] enable [1] 0-WR,1-RD
      avm_write <= mem_RDWR[0] & !mem_RDWR[1];

      // set the registers on MMIO write request
      // these are user-defined AFU registers at offset 0x40 and 0x41
      if(cp2af_sRxPort.c0.mmioWrValid == 1)
        case(mmioHdr.address)
          SCRATCH_REG: scratch_reg <= cp2af_sRxPort.c0.data[63:0];
          MEM_ADDRESS: avm_address <= cp2af_sRxPort.c0.data[31:0];
          MEM_BURSTCOUNT: avm_burstcount <= cp2af_sRxPort.c0.data[11:0];
          MEM_RDWR: mem_RDWR <= cp2af_sRxPort.c0.data[2:0];
          MEM_WRDATA: avm_writedata <= cp2af_sRxPort.c0.data[63:0];
          MEM_ADDR_TESTMODE : mem_testmode <= cp2af_sRxPort.c0.data[0];
          MEM_BANK_SELECT: mem_bank_select <=  cp2af_sRxPort.c0.data[0];          
      endcase

      if (addr_test_done == 1) 
        mem_testmode <= 0;

      // serve MMIO read requests
      if(cp2af_sRxPort.c0.mmioRdValid == 1) begin
        af2cp_sTxPort.c2.hdr.tid <= mmioHdr.tid; // copy TID
        case(mmioHdr.address)
          // AFU header
          16'h0000: af2cp_sTxPort.c2.data <= {
             4'b0001, // Feature type = AFU
             8'b0,    // reserved
             4'b0,    // afu minor revision = 0
             7'b0,    // reserved
             1'b1,    // end of DFH list = 1 
             24'b0,   // next DFH offset = 0
             4'b0,    // afu major revision = 0
             12'b0    // feature ID = 0
          };            
          AFU_ID_L:             af2cp_sTxPort.c2.data <= HELLO_AFU_ID_L; // afu id low
          AFU_ID_H:             af2cp_sTxPort.c2.data <= HELLO_AFU_ID_H; // afu id hi
          16'h0006:             af2cp_sTxPort.c2.data <= 64'h0; // next AFU
          16'h0008:             af2cp_sTxPort.c2.data <= 64'h0; // reserved
          SCRATCH_REG:          af2cp_sTxPort.c2.data <= scratch_reg; // Scratch Register
          MEM_ADDRESS:          af2cp_sTxPort.c2.data <= {32'h0, avm_address};
          MEM_BURSTCOUNT:       af2cp_sTxPort.c2.data <= {20'd0,avm_burstcount};
          MEM_RDWR:             af2cp_sTxPort.c2.data <= {62'd0, mem_RDWR};
          MEM_WRDATA:           af2cp_sTxPort.c2.data <= avm_writedata;
          MEM_RDDATA:           af2cp_sTxPort.c2.data <= avm_readdata; 
          MEM_ADDR_TESTMODE:    af2cp_sTxPort.c2.data <= {63'd0, mem_testmode};
          MEM_ADDR_TEST_STATUS: af2cp_sTxPort.c2.data <= {'d0, addr_test_done,3'd0, addr_test_status}; 
          READY_FOR_SW_CMD:     af2cp_sTxPort.c2.data <= ready_for_sw_cmd;
          MEM_RDWR_STATUS: begin 
            af2cp_sTxPort.c2.data <= {49'd0, rdwr_done[1],rdwr_status[3:2],1'b0, rdwr_done[0],rdwr_status[1:0]};
            rdwr_reset     <= 1;
          end 
		      MEM_BANK_SELECT:  af2cp_sTxPort.c2.data <= mem_bank_select;
            default:  af2cp_sTxPort.c2.data <= 64'h0;
        endcase
        af2cp_sTxPort.c2.mmioRdValid <= 1; // post response
      end else begin
          if (avm_read | avm_write) mem_RDWR[0] <= 0;
      end 
    end
end
endmodule
