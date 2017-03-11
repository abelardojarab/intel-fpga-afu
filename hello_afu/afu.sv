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
// Module Name:         afu.sv
// Project:             Hello AFU
// Modified:            PSG - ADAPT
// Description:         Hello AFU supports MMIO Writes and Reads for the DCP 0.5 Release.
//
// Hello_AFU is provided as as starting point for developing AFUs with the dcp_0.5 release for MMIO
// Writes and Reads.
//
// It is strongly recommended:
// - register all AFU inputs and outputs
// - output registers should be initialized with a reset
// - Host Writes and Reads must be sent on Virtual Channel (VC): VH0 - PCIe0 link
// - MMIO addressing must be QuardWord Aligned (Quadword = 8 bytes)
// - AFU_ID must be re-generated for new AFUs.
//
// Please see the CCI-P specification for more information about the CCI-P interfaces.
// AFU template provides 4 AFU CSR registers required by the CCI-P protocol(see
// specification for more information) and a scratch register to issue MMIO Writes and Reads.
//
// Scratch_Reg[63:0] @ Byte Address 0x0080 is provided to test MMIO Reads and Writes to the AFU.
//
// Please see the Avalon MM specification with respect to the Quartus 16.0 Release for more information.
// Avalon MM Interface for dcp_0.5:
// - operates with respect to 400 MHz clock
// - only single bursts are currently supported
// - No response status is supported
// - No support for posted writes
// - Recommended to use lower [63:0] of data bus
import ccip_if_pkg::*;

module afu (
	// ---------------------------global signals-------------------------------------------------
        input	Clk_400,	  //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
        input	SoftReset,	  //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH
	// ---------------------------IF signals between CCI and AFU  --------------------------------
	input	t_if_ccip_Rx    cp2af_sRxPort,
	output	t_if_ccip_Tx	af2cp_sTxPort,

        // --------------------------- AMM signals
	output	logic [63:0]    avs_writedata,     	//          .writedata
	input	logic [63:0]    avs_readdata,     	//          .readdata
	output	logic [31:0]    avs_address,       	//          .address
	input	logic	        avs_waitrequest,   	//          .waitrequest
	output	logic           avs_write,        	//          .write
	output	logic           avs_read,         	//          .read
	output	logic [7:0]     avs_byteenable,   	//          .byteenable
	input	wire		avs_readdatavalid     	//          .readdatavalid
);

        //Hello_AFU ID
        localparam HELLO_AFU_ID_H = 64'h850A_DCC2_6CEB_4B22;
        localparam HELLO_AFU_ID_L = 64'h9722_D433_75B6_1C66;

        logic  [63:0] scratch_reg = 0;

        // cast c0 header into ReqMmioHdr
        t_ccip_c0_ReqMmioHdr mmioHdr;
        assign mmioHdr = t_ccip_c0_ReqMmioHdr'(cp2af_sRxPort.c0.hdr);

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
                avs_writedata  <= 64'b0;
                avs_address    <= 32'b0;
                avs_write      <= 1'b0;
                avs_read       <= 1'b0;
                avs_byteenable <= 8'b0;
                scratch_reg    <= '0;
            end
            else begin
                af2cp_sTxPort.c2.mmioRdValid <= 0;
                // set the registers on MMIO write request
                // these are user-defined AFU registers at offset 0x40 and 0x41
                if(cp2af_sRxPort.c0.mmioWrValid == 1)
                    case(mmioHdr.address)
                        16'h0020: scratch_reg <= cp2af_sRxPort.c0.data[63:0];
                    endcase
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
                      16'h0002: af2cp_sTxPort.c2.data <= HELLO_AFU_ID_L; // afu id low
                      16'h0004: af2cp_sTxPort.c2.data <= HELLO_AFU_ID_H; // afu id hi
                      16'h0006: af2cp_sTxPort.c2.data <= 64'h0; // next AFU
                      16'h0008: af2cp_sTxPort.c2.data <= 64'h0; // reserved
                      16'h0020: af2cp_sTxPort.c2.data <= scratch_reg; // Scratch Register
                      default:  af2cp_sTxPort.c2.data <= 64'h0;
                  endcase
                  af2cp_sTxPort.c2.mmioRdValid <= 1; // post response
              end
          end
      end
endmodule
