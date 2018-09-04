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

module afu 
#(
    parameter NUM_LOCAL_MEM_BANKS=2
)
(
    // ---------------------------global signals-------------------------------------------------
    input	afu_clk,	  //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
    input   avmm_clk,
    input	reset,	      //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH
    
    `ifdef PLATFORM_PROVIDES_LOCAL_MEMORY
    // Local memory interface
    avalon_mem_if.to_fiu local_mem[NUM_LOCAL_MEM_BANKS],
    `endif
        
    // ---------------------------IF signals between CCI and AFU  --------------------------------
    input	t_if_ccip_c0_Rx cp2af_mmio_c0rx,
    output	t_if_ccip_Tx	af2cp_sTxPort
);

//ccip avmm signals
logic mmio_avmm_waitrequest;
logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0]	mmio_avmm_readdata;
logic mmio_avmm_readdatavalid;
logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0]	mmio_avmm_writedata; // 64-bit
logic [CCIP_AVMM_MMIO_ADDR_WIDTH-1:0]	mmio_avmm_address; // 18-bit
logic mmio_avmm_write;
logic mmio_avmm_read;
logic [(CCIP_AVMM_MMIO_DATA_WIDTH/8)-1:0]	mmio_avmm_byteenable;
logic [31:0] mac_csr_writedata;
logic [15:0] mac_csr_address;
logic mac_csr_write;
logic mac_csr_read;
logic mac_csr_waitrequest;
logic [31:0] mac_csr_readdata;
logic mac_csr_readdatavalid;
logic [511:0] client_csr_writedata;
logic [15:0] client_csr_address;
logic client_csr_write;
logic client_csr_read;
logic client_csr_waitrequest;
logic [511:0] client_csr_readdata;
logic client_csr_readdatavalid;

ccip_avmm_mmio ccip_avmm_mmio_inst (
    .avmm_waitrequest(mmio_avmm_waitrequest),
    .avmm_readdata(mmio_avmm_readdata),
    .avmm_readdatavalid(mmio_avmm_readdatavalid),
    .avmm_writedata(mmio_avmm_writedata),
    .avmm_address(mmio_avmm_address),
    .avmm_write(mmio_avmm_write),
    .avmm_read(mmio_avmm_read),
    .avmm_byteenable(mmio_avmm_byteenable),

    .clk            (afu_clk),            //   clk.clk
    .reset        (reset),                // reset.reset

    .c0rx(cp2af_mmio_c0rx),
    .c2tx(af2cp_sTxPort.c2)
);

csr_top afu_csr (
    .clk          (afu_clk),                      // input
    .reset        (reset),                        // input
    .avmm_waitrequest(mmio_avmm_waitrequest),       // output
    .avmm_readdata(mmio_avmm_readdata),             // output
    .avmm_readdatavalid(mmio_avmm_readdatavalid),   // output
    .avmm_writedata(mmio_avmm_writedata),           // input
    .avmm_address(mmio_avmm_address),               // input
    .avmm_write(mmio_avmm_write),                   // input
    .avmm_read(mmio_avmm_read),                     // input
    .avmm_byteenable(mmio_avmm_byteenable),         // input

    .mac_csr_writedata(mac_csr_writedata),
    .mac_csr_address(mac_csr_address),
    .mac_csr_write(mac_csr_write),
    .mac_csr_read(mac_csr_read),
    .mac_csr_readdata(mac_csr_readdata),
    .mac_csr_readdatavalid(mac_csr_readdatavalid),
    .mac_csr_waitrequest(mac_csr_waitrequest),

    .client_csr_writedata(client_csr_writedata),
    .client_csr_address(client_csr_address),
    .client_csr_write(client_csr_write),
    .client_csr_read(client_csr_read),
    .client_csr_readdata(client_csr_readdata),
    .client_csr_readdatavalid(client_csr_readdatavalid),
    .client_csr_waitrequest(client_csr_waitrequest)
);

// ===== MAC Clocks ===== //
logic rx_clk, tx_clk;

// ===== MAC ===== //
logic l8_tx_startofpacket, l8_tx_endofpacket, l8_tx_valid, l8_tx_ready;
logic l8_rx_startofpacket, l8_rx_endofpacket, l8_rx_valid;
logic [5:0] l8_rx_empty, l8_tx_empty;
logic [511:0] l8_rx_data, l8_tx_data;

/*
// ------------------------------------//
// ========== Client Logic =========== //
// ------------------------------------//
alt_e100s10_packet_client client (
    .i_arst                     (reset),

    .i_clk_tx                   (tx_clk),
    .i_tx_ready                 (l8_tx_ready),
    .o_tx_valid                 (l8_tx_valid),
    .o_tx_data                  (l8_tx_data),
    .o_tx_sop                   (l8_tx_startofpacket),
    .o_tx_eop                   (l8_tx_endofpacket),
    .o_tx_empty                 (l8_tx_empty),

    .i_clk_rx                   (rx_clk),
    .i_rx_sop                   (l8_rx_startofpacket),
    .i_rx_eop                   (l8_rx_endofpacket),
    .i_rx_empty                 (l8_rx_empty),
    .i_rx_data                  (l8_rx_data),
    .i_rx_valid                 (l8_rx_valid),

    .i_clk_status               (avmm_clk),
    .i_status_addr              (client_csr_address),
    .i_status_read              (client_csr_read),
    .i_status_write             (client_csr_write),
    .i_status_writedata         (client_csr_writedata),
    .o_status_readdata          (client_csr_readdata),
    .o_status_readdata_valid    (client_csr_readdatavalid)
);*/

endmodule


