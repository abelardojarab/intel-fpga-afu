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
import ccip_avmm_pkg::*;

module afu #(
		parameter MMIO_BYPASS_ADDRESS = 0,
		parameter MMIO_BYPASS_SIZE = 0
	)
	(
	// ---------------------------global signals-------------------------------------------------
        input	Clk_400,	  //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
		input pClkDiv2,
		input pClkDiv4,
		input uClk_usr,
		input uClk_usrDiv2,
        input	reset,	  //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH
        
        
`ifdef INCLUDE_DDR4
     input                    DDR4a_USERCLK,
     input                    DDR4a_waitrequest,
     input  [511:0]           DDR4a_readdata,
     input                    DDR4a_readdatavalid,
     output  [6:0]            DDR4a_burstcount,
     output  [511:0]          DDR4a_writedata,
     output  [26:0]           DDR4a_address,
     output                   DDR4a_write,
     output                   DDR4a_read,
     output  [63:0]           DDR4a_byteenable,
     input                    DDR4b_USERCLK,
     input                    DDR4b_waitrequest,
     input  [511:0]           DDR4b_readdata,
     input                    DDR4b_readdatavalid,
     output  [6:0]            DDR4b_burstcount,
     output  [511:0]          DDR4b_writedata,
     output  [26:0]           DDR4b_address,
     output                   DDR4b_write,
     output                   DDR4b_read,
     output  [63:0]           DDR4b_byteenable,
`endif
        
	// ---------------------------IF signals between CCI and AFU  --------------------------------
	input	t_if_ccip_Rx    cp2af_sRxPort,
	output	t_if_ccip_Tx	af2cp_sTxPort
);

    wire [31:0]           DDR4a_byte_address;
    wire [31:0]           DDR4b_byte_address;
`ifndef INCLUDE_DDR4
	wire          DDR4a_waitrequest;
	wire [511:0]  DDR4a_readdata;
	wire          DDR4a_readdatavalid;
	wire [6:0]   DDR4a_burstcount;
	wire [511:0] DDR4a_writedata;
	wire [26:0]  DDR4a_address;
	wire         DDR4a_write;
	wire         DDR4a_read;
	wire [63:0]  DDR4a_byteenable;
	wire          DDR4b_waitrequest;
	wire [511:0]  DDR4b_readdata;
	wire          DDR4b_readdatavalid;
	wire [6:0]   DDR4b_burstcount;
	wire [511:0] DDR4b_writedata;
	wire [26:0]  DDR4b_address;
	wire [63:0]  DDR4b_byteenable;
	wire         DDR4b_write;
	wire         DDR4b_read;
	
	`timescale 1 ps / 1 ps
	reg          DDR4a_USERCLK = 0;  
	always begin
		#1875 DDR4a_USERCLK = ~DDR4a_USERCLK;
	end
	
	reg          DDR4b_USERCLK = 0;  
	always begin
		#1800 DDR4b_USERCLK = ~DDR4b_USERCLK;
	end
	
	mem_sim_model ddr4a_inst(
		.clk(DDR4a_USERCLK),
		.reset(reset),
		.avmm_waitrequest(DDR4a_waitrequest),
		.avmm_readdata(DDR4a_readdata),
		.avmm_readdatavalid(DDR4a_readdatavalid),
		.avmm_burstcount(DDR4a_burstcount),
		.avmm_writedata(DDR4a_writedata),
		.avmm_address(DDR4a_address),
		.avmm_write(DDR4a_write),
		.avmm_read(DDR4a_read),
		.avmm_byteenable(DDR4a_byteenable)
	);
	
	mem_sim_model ddr4b_inst(
		.clk(DDR4b_USERCLK),
		.reset(reset),
		.avmm_waitrequest(DDR4b_waitrequest),
		.avmm_readdata(DDR4b_readdata),
		.avmm_readdatavalid(DDR4b_readdatavalid),
		.avmm_burstcount(DDR4b_burstcount),
		.avmm_writedata(DDR4b_writedata),
		.avmm_address(DDR4b_address),
		.avmm_write(DDR4b_write),
		.avmm_read(DDR4b_read),
		.avmm_byteenable(DDR4b_byteenable)
	);
`endif

    // DMA will send out bursts of 4 (max) to the memory controllers
    assign DDR4a_burstcount[6:3] = 4'b0000;
    assign DDR4b_burstcount[6:3] = 4'b0000;

	assign DDR4a_address = DDR4a_byte_address[31:6];
	assign DDR4b_address = DDR4b_byte_address[31:6];
	
	//ccip avmm signals
	wire requestor_avmm_waitrequest;
	wire [CCIP_AVMM_REQUESTOR_DATA_WIDTH-1:0]	requestor_avmm_readdata;
	wire requestor_avmm_readdatavalid;
	wire [CCIP_AVMM_REQUESTOR_DATA_WIDTH-1:0]	requestor_avmm_writedata;
	wire [CCIP_AVMM_REQUESTOR_ADDR_WIDTH-1:0]	requestor_avmm_address;
	wire requestor_avmm_write;
	wire requestor_avmm_read;
	wire [CCIP_AVMM_REQUESTOR_BURST_WIDTH-1:0]	requestor_avmm_burstcount;
	
	wire mmio_avmm_waitrequest;
	wire [CCIP_AVMM_MMIO_DATA_WIDTH-1:0]	mmio_avmm_readdata;
	wire mmio_avmm_readdatavalid;
	wire [CCIP_AVMM_MMIO_DATA_WIDTH-1:0]	mmio_avmm_writedata;
	wire [CCIP_AVMM_MMIO_ADDR_WIDTH-1:0]	mmio_avmm_address;
	wire mmio_avmm_write;
	wire mmio_avmm_read;
	wire [(CCIP_AVMM_MMIO_DATA_WIDTH/8)-1:0]	mmio_avmm_byteenable;

	dma_test_system u0 (
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
        
        .ccip_avmm_mmio_waitrequest         (mmio_avmm_waitrequest),         //       ccip_avmm_mmio.waitrequest
        .ccip_avmm_mmio_readdata            (mmio_avmm_readdata),            //                    .readdata
        .ccip_avmm_mmio_readdatavalid       (mmio_avmm_readdatavalid),       //                    .readdatavalid
        .ccip_avmm_mmio_burstcount          (1'b1),          //                    .burstcount
        .ccip_avmm_mmio_writedata           (mmio_avmm_writedata),           //                    .writedata
        .ccip_avmm_mmio_address             (mmio_avmm_address),             //                    .address
        .ccip_avmm_mmio_write               (mmio_avmm_write),               //                    .write
        .ccip_avmm_mmio_read                (mmio_avmm_read),                //                    .read
        .ccip_avmm_mmio_byteenable          (mmio_avmm_byteenable),          //                    .byteenable
        .ccip_avmm_mmio_debugaccess         (),         //                    .debugaccess
        .ccip_avmm_requestor_waitrequest   (requestor_avmm_waitrequest),   // ccip_avmm_requestor.waitrequest
        .ccip_avmm_requestor_readdata      (requestor_avmm_readdata),      //                    .readdata
        .ccip_avmm_requestor_readdatavalid (requestor_avmm_readdatavalid), //                    .readdatavalid
        .ccip_avmm_requestor_burstcount    (requestor_avmm_burstcount),    //                    .burstcount
        .ccip_avmm_requestor_writedata     (requestor_avmm_writedata),     //                    .writedata
        .ccip_avmm_requestor_address       (requestor_avmm_address),       //                    .address
        .ccip_avmm_requestor_write         (requestor_avmm_write),         //                    .write
        .ccip_avmm_requestor_read          (requestor_avmm_read),          //                    .read
        .ccip_avmm_requestor_byteenable    (),    //                    .byteenable
        .ccip_avmm_requestor_debugaccess   (),   //                    .debugaccess
        
		.ddr4a_clk_clk(DDR4a_USERCLK),
		.ddr4b_clk_clk(DDR4b_USERCLK),
		.host_clk_clk(pClkDiv2),
		.reset_reset(reset)         // reset.reset
	);
	
	avmm_ccip_host avmm_ccip_host_inst (
		.clk            (pClkDiv2),            //   clk.clk
		.reset        (reset),         // reset.reset
		
		.avmm_waitrequest(requestor_avmm_waitrequest),
		.avmm_readdata(requestor_avmm_readdata),
		.avmm_readdatavalid(requestor_avmm_readdatavalid),
		.avmm_writedata(requestor_avmm_writedata),
		.avmm_address(requestor_avmm_address),
		.avmm_write(requestor_avmm_write),
		.avmm_read(requestor_avmm_read),
		.avmm_burstcount(requestor_avmm_burstcount),
		
		.c0TxAlmFull(cp2af_sRxPort.c0TxAlmFull),
		.c1TxAlmFull(cp2af_sRxPort.c1TxAlmFull),
		.c0rx(cp2af_sRxPort.c0),
		//.c1rx(cp2af_sRxPort.c1),	//write response
		.c0tx(af2cp_sTxPort.c0),
		.c1tx(af2cp_sTxPort.c1)
	);
	
	ccip_avmm_mmio #(
		.MMIO_BYPASS_ADDRESS(MMIO_BYPASS_ADDRESS),
		.MMIO_BYPASS_SIZE(MMIO_BYPASS_SIZE)
	)
	ccip_avmm_mmio_inst (
		.avmm_waitrequest(mmio_avmm_waitrequest),
		.avmm_readdata(mmio_avmm_readdata),
		.avmm_readdatavalid(mmio_avmm_readdatavalid),
		.avmm_writedata(mmio_avmm_writedata),
		.avmm_address(mmio_avmm_address),
		.avmm_write(mmio_avmm_write),
		.avmm_read(mmio_avmm_read),
		.avmm_byteenable(mmio_avmm_byteenable),
	
		.clk            (pClkDiv2),            //   clk.clk
		.reset        (reset),         // reset.reset
		
		.c0rx(cp2af_sRxPort.c0),
		.c2tx(af2cp_sTxPort.c2)
	);
	
endmodule

