
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
`include "platform_if.vh"

module dma_test_system_wrapper 
  #(
    parameter NUM_LOCAL_MEM_BANKS=2
    )
   (
	// ---------------------------global signals-------------------------------------------------
        input	host_clk_clk,	  //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
        input	reset_reset,	  //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH

        output	dma_irq_irq,

`ifdef PLATFORM_PROVIDES_LOCAL_MEMORY
    // Local memory interface
    avalon_mem_if.to_fiu local_mem[NUM_LOCAL_MEM_BANKS],
`endif
        output                                     ccip_avmm_mmio_waitrequest,         //       ccip_avmm_mmio.waitrequest
        output [CCIP_AVMM_MMIO_DATA_WIDTH-1:0]     ccip_avmm_mmio_readdata,            //                    .readdata
        output                                     ccip_avmm_mmio_readdatavalid,       //                    .readdatavalid
        input                                      ccip_avmm_mmio_burstcount,          //                    .burstcount
        input  [CCIP_AVMM_MMIO_DATA_WIDTH-1:0]     ccip_avmm_mmio_writedata,           //                    .writedata
        input  [CCIP_AVMM_MMIO_ADDR_WIDTH-1:0]     ccip_avmm_mmio_address,             //                    .address
        input                                      ccip_avmm_mmio_write,               //                    .write
        input                                      ccip_avmm_mmio_read,                //                    .read
        input  [(CCIP_AVMM_MMIO_DATA_WIDTH/8)-1:0] ccip_avmm_mmio_byteenable,          //                    .byteenable
        input                                      ccip_avmm_mmio_debugaccess,         //                    .debugaccess

        input                                           ccip_avmm_requestor_wr_waitrequest,   // ccip_avmm_requestor.waitrequest
        input  [CCIP_AVMM_REQUESTOR_DATA_WIDTH-1:0]     ccip_avmm_requestor_wr_readdata,      //                    .readdata
        input                                           ccip_avmm_requestor_wr_readdatavalid, //                    .readdatavalid
        output [CCIP_AVMM_REQUESTOR_BURST_WIDTH-1:0]    ccip_avmm_requestor_wr_burstcount,    //                    .burstcount
        output [CCIP_AVMM_REQUESTOR_DATA_WIDTH-1:0]     ccip_avmm_requestor_wr_writedata,     //                    .writedata
        output [CCIP_AVMM_REQUESTOR_WR_ADDR_WIDTH-1:0]  ccip_avmm_requestor_wr_address,       //                    .address
        output                                          ccip_avmm_requestor_wr_write,         //                    .write
        output                                          ccip_avmm_requestor_wr_read,          //                    .read
        output [(CCIP_AVMM_REQUESTOR_DATA_WIDTH/8)-1:0] ccip_avmm_requestor_wr_byteenable,    //                    .byteenable
        output                                          ccip_avmm_requestor_wr_debugaccess,   //                    .debugaccess
        
        input                                           ccip_avmm_requestor_rd_waitrequest,   // ccip_avmm_requestor.waitrequest
        input  [CCIP_AVMM_REQUESTOR_DATA_WIDTH-1:0]     ccip_avmm_requestor_rd_readdata,      //                    .readdata
        input                                           ccip_avmm_requestor_rd_readdatavalid, //                    .readdatavalid
        output [CCIP_AVMM_REQUESTOR_BURST_WIDTH-1:0]    ccip_avmm_requestor_rd_burstcount,    //                    .burstcount
        output [CCIP_AVMM_REQUESTOR_DATA_WIDTH-1:0]     ccip_avmm_requestor_rd_writedata,     //                    .writedata
        output [CCIP_AVMM_REQUESTOR_RD_ADDR_WIDTH-1:0]  ccip_avmm_requestor_rd_address,       //                    .address
        output                                          ccip_avmm_requestor_rd_write,         //                    .write
        output                                          ccip_avmm_requestor_rd_read,          //                    .read
        output [(CCIP_AVMM_REQUESTOR_DATA_WIDTH/8)-1:0] ccip_avmm_requestor_rd_byteenable,    //                    .byteenable
        output                                          ccip_avmm_requestor_rd_debugaccess    //                    .debugaccess
);

`ifdef PLATFORM_PROVIDES_LOCAL_MEMORY

   // avalon_mem_if pipe_local_mem[NUM_LOCAL_MEM_BANKS]();

   logic         pl_waitrequest   [NUM_LOCAL_MEM_BANKS];
   logic         pl_readdatavalid [NUM_LOCAL_MEM_BANKS];
   logic [575:0] pl_readdata      [NUM_LOCAL_MEM_BANKS];
   logic [6:0]   pl_burstcount [NUM_LOCAL_MEM_BANKS];
   logic [575:0] pl_writedata  [NUM_LOCAL_MEM_BANKS];
   logic [71:0]  pl_byteenable [NUM_LOCAL_MEM_BANKS];
   logic [26:0]  pl_address    [NUM_LOCAL_MEM_BANKS];
   logic         pl_write      [NUM_LOCAL_MEM_BANKS];
   logic         pl_read       [NUM_LOCAL_MEM_BANKS];
   
   
	 
    // memory map offset for byte address, used to align port concatination
    logic [5:0] 	   mm_byte_offset[NUM_LOCAL_MEM_BANKS];

    logic  		   local_mem_reset[NUM_LOCAL_MEM_BANKS];

    // DMA will send out bursts of 4 (max) to the memory controllers
    genvar n;
    generate
       for (n = 0; n < NUM_LOCAL_MEM_BANKS; n = n + 1)
 	begin : mem_burstcount
 	   // assign local_mem[n].burstcount[6:3] = '0;
 	   assign pl_burstcount[n][6:3] = '0;
 	end
    endgenerate
   
   genvar b;
   generate
      for (b = 0; b < NUM_LOCAL_MEM_BANKS; b = b + 1)
        begin : ddr_pl
           green_bs_resync
             #(
               .SYNC_CHAIN_LENGTH(2),
               .WIDTH(1),
               .INIT_VALUE(1)
               )
           local_mem_reset_sync
             (
              .clk(local_mem[b].clk),
              .reset(reset_reset),
              .d(1'b0),
              .q(local_mem_reset[b])
              );
           ddr_avmm_bridge
             #(
               .DATA_WIDTH(576),
               .SYMBOL_WIDTH(8),
               .ADDR_WIDTH(27),
               .BURSTCOUNT_WIDTH(7),
               .READDATA_PIPE_DEPTH(2)
               )
	   local_mem_avmm_bridge
             (
              .clk              (local_mem[b].clk),
              .reset            (local_mem_reset[b]),
	      
              .s0_waitrequest   (pl_waitrequest[b]),
              .s0_readdata      (pl_readdata[b]),
              .s0_readdatavalid (pl_readdatavalid[b]),
              .s0_burstcount    (pl_burstcount[b]),
              .s0_writedata     (pl_writedata[b]),
              .s0_address       (pl_address[b]),
              .s0_write         (pl_write[b]),
              .s0_read          (pl_read[b]),
              .s0_byteenable    (pl_byteenable[b]),
              .m0_waitrequest   (local_mem[b].waitrequest),
              .m0_readdata      (local_mem[b].readdata),
              .m0_readdatavalid (local_mem[b].readdatavalid),
              .m0_burstcount    (local_mem[b].burstcount),
              .m0_writedata     (local_mem[b].writedata),
              .m0_address       (local_mem[b].address),
              .m0_write         (local_mem[b].write),
              .m0_read          (local_mem[b].read),
              .m0_byteenable    (local_mem[b].byteenable)
              );
        end // block: ddr_pl
   endgenerate
`endif
   
    dma_test_system u0 (
`ifdef PLATFORM_PROVIDES_LOCAL_MEMORY
    	.ddr4a_clk_clk              ( local_mem[0].clk),
        .ddr4a_master_waitrequest   ( pl_waitrequest[0]),        // dma_master.waitrequest
    	.ddr4a_master_readdata      ( pl_readdata[0]),           //           .readdata
    	.ddr4a_master_readdatavalid ( pl_readdatavalid[0]),      //           .readdatavalid
    	.ddr4a_master_burstcount    ( pl_burstcount[0][2:0]),    //           .burstcount
    	.ddr4a_master_writedata     ( pl_writedata[0]),          //           .writedata
    	.ddr4a_master_address       ({pl_address[0],mm_byte_offset[0]}),       //           .address
    	.ddr4a_master_write         ( pl_write[0]),              //           .write
    	.ddr4a_master_read          ( pl_read[0]),               //           .read
    	.ddr4a_master_byteenable    ( pl_byteenable[0]),         //           .byteenable
    	.ddr4a_master_debugaccess   (),                                //           .debugaccess

    	.ddr4b_clk_clk              ( local_mem[1].clk),
        .ddr4b_master_waitrequest   ( pl_waitrequest[1]),        // dma_master.waitrequest
    	.ddr4b_master_readdata      ( pl_readdata[1]),           //           .readdata
    	.ddr4b_master_readdatavalid ( pl_readdatavalid[1]),      //           .readdatavalid
    	.ddr4b_master_burstcount    ( pl_burstcount[1][2:0]),    //           .burstcount
    	.ddr4b_master_writedata     ( pl_writedata[1]),          //           .writedata
    	.ddr4b_master_address       ({pl_address[1],mm_byte_offset[1]}),       //           .address
    	.ddr4b_master_write         ( pl_write[1]),              //           .write
    	.ddr4b_master_read          ( pl_read[1]),               //           .read
    	.ddr4b_master_byteenable    ( pl_byteenable[1]),         //           .byteenable
    	.ddr4b_master_debugaccess   (),                                //           .debugaccess

    	.ddr4c_clk_clk              ( local_mem[2].clk),
        .ddr4c_master_waitrequest   ( pl_waitrequest[2]),        // dma_master.waitrequest
    	.ddr4c_master_readdata      ( pl_readdata[2]),           //           .readdata
    	.ddr4c_master_readdatavalid ( pl_readdatavalid[2]),      //           .readdatavalid
    	.ddr4c_master_burstcount    ( pl_burstcount[2][2:0]),    //           .burstcount
    	.ddr4c_master_writedata     ( pl_writedata[2]),          //           .writedata
    	.ddr4c_master_address       ({pl_address[2],mm_byte_offset[2]}),       //           .address
    	.ddr4c_master_write         ( pl_write[2]),              //           .write
    	.ddr4c_master_read          ( pl_read[2]),               //           .read
    	.ddr4c_master_byteenable    ( pl_byteenable[2]),         //           .byteenable
    	.ddr4c_master_debugaccess   (),                                //           .debugaccess
			
    	.ddr4d_clk_clk              ( local_mem[3].clk),
        .ddr4d_master_waitrequest   ( pl_waitrequest[3]),        // dma_master.waitrequest
    	.ddr4d_master_readdata      ( pl_readdata[3]),           //           .readdata
    	.ddr4d_master_readdatavalid ( pl_readdatavalid[3]),      //           .readdatavalid
    	.ddr4d_master_burstcount    ( pl_burstcount[3][2:0]),    //           .burstcount
    	.ddr4d_master_writedata     ( pl_writedata[3]),          //           .writedata
    	.ddr4d_master_address       ({pl_address[3],mm_byte_offset[3]}),       //           .address
    	.ddr4d_master_write         ( pl_write[3]),              //           .write
    	.ddr4d_master_read          ( pl_read[3]),               //           .read
    	.ddr4d_master_byteenable    ( pl_byteenable[3]),         //           .byteenable
    	.ddr4d_master_debugaccess   (),                                //           .debugaccess
    	
`endif
	.*
     );

	
endmodule

