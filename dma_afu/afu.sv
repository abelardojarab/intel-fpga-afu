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

//`define DISABLE_DDR4B_BANK

module afu (
	// ---------------------------global signals-------------------------------------------------
        input	Clk_400,	  //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
		input pClkDiv2,
		input pClkDiv4,
		input uClk_usr,
		input uClk_usrDiv2,
        input	SoftReset,	  //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH
        
        
`ifdef INCLUDE_DDR4
     input                    DDR4_USERCLK,
     input                    DDR4a_waitrequest,
     input  [511:0]           DDR4a_readdata,
     input                    DDR4a_readdatavalid,
     output  [6:0]            DDR4a_burstcount,
     output  [511:0]          DDR4a_writedata,
     output  [25:0]           DDR4a_address,
     output                   DDR4a_write,
     output                   DDR4a_read,
     output  [63:0]           DDR4a_byteenable,
     input                    DDR4b_waitrequest,
     input  [511:0]           DDR4b_readdata,
     input                    DDR4b_readdatavalid,
     output  [6:0]            DDR4b_burstcount,
     output  [511:0]          DDR4b_writedata,
     output  [25:0]           DDR4b_address,
     output                   DDR4b_write,
     output                   DDR4b_read,
     output  [63:0]           DDR4b_byteenable,
`endif
        
	// ---------------------------IF signals between CCI and AFU  --------------------------------
	input	t_if_ccip_Rx    cp2af_sRxPort,
	output	t_if_ccip_Tx	af2cp_sTxPort
);
	localparam AVMM_ADDR_WIDTH = 18;
	localparam AVMM_DATA_WIDTH = 64;
	localparam AVMM_BYTE_ENABLE_WIDTH=(AVMM_DATA_WIDTH/8);

	wire [AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+1-1:0] in_data;
    wire in_valid;
    wire in_ready;
             
    wire [AVMM_DATA_WIDTH-1:0] out_data;
    wire out_valid;
    wire out_ready;
	
    wire [31:0]           DDR4a_byte_address;
    wire [31:0]           DDR4b_byte_address;
`ifndef INCLUDE_DDR4
	 /*wire                   DDR4_USERCLK;
     wire                   DDR4a_waitrequest;
     wire [511:0]           DDR4a_readdata;
     wire                   DDR4a_readdatavalid;
     wire  [6:0]            DDR4a_burstcount;
     wire  [511:0]          DDR4a_writedata;
     wire  [25:0]           DDR4a_address;
     wire                   DDR4a_write;
     wire                   DDR4a_read;
     wire  [63:0]           DDR4a_byteenable;
     wire                   DDR4b_waitrequest;
     wire [511:0]           DDR4b_readdata;
     wire                   DDR4b_readdatavalid;
     wire  [6:0]            DDR4b_burstcount;
     wire  [511:0]          DDR4b_writedata;
     wire  [25:0]           DDR4b_address;
     wire                   DDR4b_write;
     wire                   DDR4b_read;
     wire  [63:0]           DDR4b_byteenable;
     
     assign DDR4_USERCLK = pClkDiv2;*/
     
		`timescale 1 ps / 1 ps
	reg          DDR4_USERCLK = 0;  
	reg          DDR4a_waitrequest = 0;
	reg [511:0]  DDR4a_readdata = 512'b0;
	reg          DDR4a_readdatavalid = 0;
	wire [6:0]   DDR4a_burstcount;
	wire [511:0] DDR4a_writedata;
	wire [25:0]  DDR4a_address;
	wire         DDR4a_write;
	wire         DDR4a_read;
	wire [63:0]  DDR4a_byteenable;
	reg          DDR4b_waitrequest = 0;
	reg [511:0]  DDR4b_readdata = 512'b0;
	reg          DDR4b_readdatavalid = 0;
	wire [6:0]   DDR4b_burstcount;
	wire [511:0] DDR4b_writedata;
	wire [25:0]  DDR4b_address;
	wire [63:0]  DDR4b_byteenable;
	wire         DDR4b_write;
	wire         DDR4b_read;
	reg  [511:0] local_mem_bankA[ reg [25:0] ]; // Fake emif sim model, we model 2 banks of memory using systemverilog associative arrays
	reg  [511:0] local_mem_bankB[ reg [25:0] ];
	always begin
		#1875 DDR4_USERCLK = ~DDR4_USERCLK;
	end
	
	wire [511:0] DDR4a_byteenable_mask;
	wire [511:0] DDR4b_byteenable_mask;
	reg [511:0] DDR4a_tmp_read;
	reg [511:0] DDR4b_tmp_read;
	reg [6:0] DDR4a_burst_state;
	reg [6:0] DDR4b_burst_state;
	reg [25:0]  DDR4a_burst_address;
	reg [25:0]  DDR4b_burst_address;
	reg [511:0] DDR4a_burst_byteenable_mask;
	reg [511:0] DDR4b_burst_byteenable_mask;
	genvar i;
	generate
	for (i = 0; i < 64 ; i = i + 1) 
	begin: gen_loop1 
		assign DDR4a_byteenable_mask[(i+1)*8-1:i*8] = {8{DDR4a_byteenable[i]}};
		assign DDR4b_byteenable_mask[(i+1)*8-1:i*8] = {8{DDR4b_byteenable[i]}};
	end
	endgenerate
	
	always @(posedge DDR4_USERCLK) begin
		if (DDR4a_read | (DDR4a_burst_state != 6'b000000)) begin
			if (DDR4a_burst_state == 6'b000000) begin
				DDR4a_burst_state = DDR4a_burstcount;
				DDR4a_burst_address = DDR4a_address;
				DDR4a_burst_byteenable_mask = DDR4a_byteenable_mask;
			end
			else begin
				DDR4a_burst_address = DDR4a_burst_address+1;
			end
			DDR4a_burst_state = DDR4a_burst_state-1;
			
			if (local_mem_bankA.exists(DDR4a_burst_address)) DDR4a_readdata = local_mem_bankA[DDR4a_burst_address];
			else DDR4a_readdata = 512'b0;
			DDR4a_readdatavalid <= 1'b1;
		end
		else DDR4a_readdatavalid <= 1'b0;
		if (DDR4b_read | (DDR4b_burst_state != 6'b000000)) begin
			if (DDR4b_burst_state == 6'b000000) begin
				DDR4b_burst_state = DDR4b_burstcount;
				DDR4b_burst_address = DDR4b_address;
				DDR4b_burst_byteenable_mask = DDR4b_byteenable_mask;
			end
			else begin
				DDR4b_burst_address = DDR4b_burst_address+1;
			end
			DDR4b_burst_state = DDR4b_burst_state-1;
			
			if (local_mem_bankB.exists(DDR4b_burst_address)) DDR4b_readdata = local_mem_bankB[DDR4b_burst_address];
			else DDR4b_readdata = 512'b0;
			DDR4b_readdatavalid <= 1'b1;
		end
		else DDR4b_readdatavalid <= 1'b0;
		if (DDR4a_write) begin
			if (DDR4a_burst_state == 6'b000000) begin
				DDR4a_burst_state = DDR4a_burstcount;
				DDR4a_burst_address = DDR4a_address;
				DDR4a_burst_byteenable_mask = DDR4a_byteenable_mask;
			end
			else begin
				DDR4a_burst_address = DDR4a_burst_address+1;
			end
			DDR4a_burst_state = DDR4a_burst_state-1;
			
			if (local_mem_bankA.exists(DDR4a_burst_address)) DDR4a_tmp_read = local_mem_bankA[DDR4a_burst_address];
			else DDR4a_tmp_read = 512'b0;
			local_mem_bankA[DDR4a_burst_address] = (DDR4a_tmp_read & ~DDR4a_byteenable_mask) | (DDR4a_writedata & DDR4a_byteenable_mask);
		end
		if (DDR4b_write)  begin
			if (DDR4b_burst_state == 6'b000000) begin
				DDR4b_burst_state = DDR4b_burstcount;
				DDR4b_burst_address = DDR4b_address;
				DDR4b_burst_byteenable_mask = DDR4b_byteenable_mask;
			end
			else begin
				DDR4b_burst_address = DDR4b_burst_address+1;
			end
			DDR4b_burst_state = DDR4b_burst_state-1;
			
			if (local_mem_bankB.exists(DDR4b_burst_address)) DDR4b_tmp_read = local_mem_bankB[DDR4b_burst_address];
			else DDR4b_tmp_read = 512'b0;
			local_mem_bankB[DDR4b_burst_address] = (DDR4b_tmp_read & ~DDR4b_byteenable_mask) | (DDR4b_writedata & DDR4b_byteenable_mask);
		end
		if (SoftReset) begin // global reset
			DDR4a_readdata      = 512'b0;
			DDR4a_readdatavalid <= 1'b0;
			DDR4b_readdata      = 512'b0;
			DDR4b_readdatavalid <= 1'b0;
			DDR4a_burst_state = 6'b0;
			DDR4b_burst_state = 6'b0;
			DDR4a_burst_address = 6'b0;
			DDR4b_burst_address = 6'b0;
			DDR4a_burst_byteenable_mask = 512'b0;
			DDR4b_burst_byteenable_mask = 512'b0;
		end
	end
`endif

	assign DDR4a_address = DDR4a_byte_address[31:6];
	assign DDR4b_address = DDR4b_byte_address[31:6];

	dma_test_system u0 (
		.in_data,
        .in_ready,
        .in_valid,
        .out_data,
        .out_ready,
        .out_valid,
        
        .ddr4a_master_waitrequest   (DDR4a_waitrequest),   // dma_master.waitrequest
		.ddr4a_master_readdata      (DDR4a_readdata),      //           .readdata
		.ddr4a_master_readdatavalid (DDR4a_readdatavalid), //           .readdatavalid
		.ddr4a_master_burstcount    (DDR4a_burstcount),    //           .burstcount
		.ddr4a_master_writedata     (DDR4a_writedata),     //           .writedata
		.ddr4a_master_address       (DDR4a_byte_address),       //           .address
		.ddr4a_master_write         (DDR4a_write),         //           .write
		.ddr4a_master_read          (DDR4a_read),          //           .read
		.ddr4a_master_byteenable    (DDR4a_byteenable),    //           .byteenable
		.ddr4a_master_debugaccess   (),   //           .debugaccess
		`ifndef DISABLE_DDR4B_BANK
		.ddr4b_master_waitrequest   (DDR4b_waitrequest),   // dma_master.waitrequest
		.ddr4b_master_readdata      (DDR4b_readdata),      //           .readdata
		.ddr4b_master_readdatavalid (DDR4b_readdatavalid), //           .readdatavalid
		.ddr4b_master_burstcount    (DDR4b_burstcount),    //           .burstcount
		.ddr4b_master_writedata     (DDR4b_writedata),     //           .writedata
		.ddr4b_master_address       (DDR4b_byte_address),       //           .address
		.ddr4b_master_write         (DDR4b_write),         //           .write
		.ddr4b_master_read          (DDR4b_read),          //           .read
		.ddr4b_master_byteenable    (DDR4b_byteenable),    //           .byteenable
		.ddr4b_master_debugaccess   (),   //           .debugaccess
        `endif
		
		.clk_clk            (pClkDiv4),            //   clk.clk
		.ddr_clk_clk(DDR4_USERCLK),
		//.clk_clk            (Clk_400),            //   clk.clk
		.pclk400_clk(Clk_400),
		.reset_reset        (SoftReset)         // reset.reset
	);
	
	ccip_avmm_mmio #(AVMM_ADDR_WIDTH, AVMM_DATA_WIDTH)
	ccip_avmm_mmio_inst (
		.in_data,
		.in_valid,
		.in_ready,
				 
		.out_data,
		.out_valid,
		.out_ready,
	
		.clk            (Clk_400),            //   clk.clk
		.SoftReset        (SoftReset),         // reset.reset
		
		.ccip_c0_Rx_port(cp2af_sRxPort.c0),
		.ccip_c2_Tx_port(af2cp_sTxPort.c2)
	);
	
	//set c0 and c1 tx port to zero because they are not used in this AFU
	always@(posedge Clk_400) begin
		af2cp_sTxPort.c1.hdr        <= '0;
		af2cp_sTxPort.c1.valid      <= '0;
		af2cp_sTxPort.c1.data       <= '0;
		af2cp_sTxPort.c0.hdr        <= '0;
		af2cp_sTxPort.c0.valid      <= '0;
	end
endmodule

