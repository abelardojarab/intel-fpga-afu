// ***************************************************************************
// Copyright (c) 2017, Intel Corporation
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// * Neither the name of Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// ***************************************************************************

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

    // MMIO parameters and ports
	localparam AVMM_ADDR_WIDTH = 18;
	localparam AVMM_DATA_WIDTH = 64;
	localparam AVMM_BYTE_ENABLE_WIDTH=(AVMM_DATA_WIDTH/8);

	wire [AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+2-1:0] in_data;
    wire in_valid;
    wire in_ready;
             
    wire [AVMM_DATA_WIDTH-1:0] out_data;
    wire out_valid;
    wire out_ready;
	
    wire [31:0]           DDR4a_byte_address;
    wire [31:0]           DDR4b_byte_address;
`ifndef INCLUDE_DDR4
	wire          DDR4a_waitrequest;
	wire [511:0]  DDR4a_readdata;
	wire          DDR4a_readdatavalid;
	wire [6:0]   DDR4a_burstcount;
	wire [511:0] DDR4a_writedata;
	wire [25:0]  DDR4a_address;
	wire         DDR4a_write;
	wire         DDR4a_read;
	wire [63:0]  DDR4a_byteenable;
	wire          DDR4b_waitrequest;
	wire [511:0]  DDR4b_readdata;
	wire          DDR4b_readdatavalid;
	wire [6:0]   DDR4b_burstcount;
	wire [511:0] DDR4b_writedata;
	wire [25:0]  DDR4b_address;
	wire [63:0]  DDR4b_byteenable;
	wire         DDR4b_write;
	wire         DDR4b_read;
`endif

	assign DDR4a_address = DDR4a_byte_address[31:6];
	assign DDR4b_address = DDR4b_byte_address[31:6];

	wire		ccip_host_bridge_m0_waitrequest;
	wire	[511:0]	ccip_host_bridge_m0_readdata;
	wire		ccip_host_bridge_m0_readdatavalid;
	wire	[0:0]	ccip_host_bridge_m0_burstcount;
	wire	[511:0]	ccip_host_bridge_m0_writedata;
	wire	[47:0]	ccip_host_bridge_m0_address;
	wire		ccip_host_bridge_m0_write;
	wire		ccip_host_bridge_m0_read;
	wire	[63:0]	ccip_host_bridge_m0_byteenable;
	
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
		.ddr4a_master_burstcount    (DDR4a_burstcount[2:0]),    //           .burstcount
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
		.ddr4b_master_burstcount    (DDR4b_burstcount[2:0]),    //           .burstcount
		.ddr4b_master_writedata     (DDR4b_writedata),     //           .writedata
		.ddr4b_master_address       (DDR4b_byte_address),       //           .address
		.ddr4b_master_write         (DDR4b_write),         //           .write
		.ddr4b_master_read          (DDR4b_read),          //           .read
		.ddr4b_master_byteenable    (DDR4b_byteenable),    //           .byteenable
		.ddr4b_master_debugaccess   (),   //           .debugaccess
        `endif
        
        .avst_rd_rsp_data,
		.avst_rd_rsp_valid,
		.avst_rd_rsp_ready,
		
		.avst_avcmd_data,
		.avst_avcmd_valid,
		.avst_avcmd_ready,
		
		.clk_clk            (pClkDiv4),            //   clk.clk
		.ddr_clk_clk(DDR4_USERCLK),
		//.clk_clk            (Clk_400),            //   clk.clk
		.pclk400_clk(Clk_400),
		.reset_reset        (SoftReset)         // reset.reset
	);
	
    // DMA will send out bursts of 4 (max) to the memory controllers
    assign DDR4a_burstcount[6:3] = 4'b0000;
    assign DDR4b_burstcount[6:3] = 4'b0000;

	 wire [512-1:0] avst_rd_rsp_data;
    wire avst_rd_rsp_valid;
    wire avst_rd_rsp_ready;
    
    wire [512+48+3+1-1:0] avst_avcmd_data;
    wire avst_avcmd_valid;
    wire avst_avcmd_ready;
	
	avmm_ccip_host #(
		.AVMM_ADDR_WIDTH(48), 
		.AVMM_DATA_WIDTH(512),
        .AVMM_BURST_WIDTH(3))
	avmm_ccip_host_inst (
		.clk            (Clk_400),            //   clk.clk
		.reset        (SoftReset),         // reset.reset
		
		.avst_rd_rsp_data,
		.avst_rd_rsp_valid,
		.avst_rd_rsp_ready,
		
		.avst_avcmd_data,
		.avst_avcmd_valid,
		.avst_avcmd_ready,
		
		.c0TxAlmFull(cp2af_sRxPort.c0TxAlmFull),
		.c1TxAlmFull(cp2af_sRxPort.c1TxAlmFull),
		.c0rx(cp2af_sRxPort.c0),
		//.c1rx(cp2af_sRxPort.c1),
		.c0tx(af2cp_sTxPort.c0),
		.c1tx(af2cp_sTxPort.c1)
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
	
endmodule

