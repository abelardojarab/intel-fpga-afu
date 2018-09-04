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

// ===== Status Signals ===== //
logic rx_pcs_ready, rx_pcs_ready_rx_clk, cdr_lock;
logic tx_clk_stable;
logic [1:0] tx_pll_locked, tx_pll_locked_tx_clk;
logic [3:0] tx_dll_lock;
logic rx_block_lock, rx_am_lock, hi_ber;
logic ehip_ready;
logic remote_fault_status, local_fault_status;

// ===== MAC Clocks ===== //
logic rx_clk, tx_clk;
logic tx_clk_locked, rx_clk_locked;
logic clk_rx_rs, clk_tx_rs, clk_ref;

// ===== MAC resets ===== //
logic sys_rst;
logic csr_rst_in, csr_rst_afu_clk;
logic rx_rst_in, tx_rst_in;
logic rx_rst_afu_clk, tx_rst_afu_clk;
logic rx_rst_rx_clk, tx_rst_tx_clk;
logic [3:0] tx_digitalreset, tx_digitalreset_stat;
logic soft_rx_rst, soft_tx_rst;

// ===== MAC ===== //
logic l8_tx_startofpacket, l8_tx_endofpacket, l8_tx_valid, l8_tx_ready, l8_tx_error, l8_txstatus_valid;
logic l8_rx_startofpacket, l8_rx_endofpacket, l8_rx_valid, l8_rxstatus_valid;
logic [5:0] l8_rx_empty, l8_tx_empty;
logic [511:0] l8_rx_data, l8_tx_data;
logic [39:0] l8_rxstatus_data, l8_txstatus_data;
logic [6:0] l8_txstatus_error;
logic [5:0] l8_rx_error;
logic pcs_dout_am;
logic [255:0] rx_data_out, pcs_din_d, pcs_dout_d;
logic [31:0] pcs_din_c, pcs_dout_c, rx_ctl_out, rx_last_data;
logic rx_data_out_valid, rx_fcs_error, rx_fcs_valid;
logic [3:0] rx_first_data, rx_mii_start;
logic pause_insert_tx0, pause_insert_tx1, pause_receive_rx;
logic [31:0] avmm_din;
logic [7:0] avmm_addr;
logic avmm_mac_tx_write, avmm_mac_rx_write, avmm_fc_tx_write, avmm_fc_rx_write, avmm_mac_tx_stats_write, avmm_mac_rx_stats_write;
logic avmm_mac_tx_read, avmm_mac_rx_read, avmm_fc_tx_read, avmm_fc_rx_read, avmm_mac_tx_stats_read, avmm_mac_rx_stats_read;
logic avmm_mac_tx_dval, avmm_mac_rx_dval, avmm_fc_tx_dval, avmm_fc_rx_dval, avmm_mac_tx_stats_dval, avmm_mac_rx_stats_dval;
logic [31:0] avmm_mac_tx_dout, avmm_mac_rx_dout, avmm_fc_tx_dout, avmm_fc_rx_dout, avmm_mac_tx_stats_dout, avmm_mac_rx_stats_dout;

// Tie these signals to EHIP output
/*
assign tx_clk_stable = 1'b0; // mii_to_afu.f2a_tx_lanes_stable
assign cdr_lock = 1'b0;      // mii_to_afu.f2a_cdr_lock;
assign rx_pcs_ready = 1'b0;  // mii_to_afu.f2a_rx_pcs_ready;
assign tx_pll_locked = 2'b0; // o_tx_pll_locked
assign tx_dll_lock = {tx_pll_locked,tx_pll_locked};
assign rx_block_lock = 1'b0; // mii_to_afu.f2a_rx_block_lock;
assign rx_am_lock = 1'b0; //mii_to_afu.f2a_rx_am_lock;
assign hi_ber = 1'b0; // mii_to_afu.f2a_rx_hi_ber;
assign ehip_ready = 1'b0; // mii_to_afu.f2a_ehip_ready;
assign remote_fault_status = 1'b0; // f2a_remote_fault_status
assign local_fault_status = 1'b0; // f2a_local_fault_status

// TODO: need to CDC
// tx_pll_locked_tx_clk

// TODO: tie these signals to EHIP output
assign rx_clk = 1'b0;      // o_clk_rec_div66 
assign tx_clk = 1'b0;      // o_clk_pll_div66
always @ (posedge rx_clk)	rx_clk_locked <= cdr_lock;
always @ (posedge tx_clk)	tx_clk_locked <= tx_clk_stable;

assign csr_rst_in   = reset;
assign rx_rst_in    = reset;
assign tx_rst_in    = reset;
assign tx_digitalreset = {tx_rst_in,tx_rst_in,tx_rst_in,tx_rst_in};
assign tx_digitalreset_stat = {tx_rst_in,tx_rst_in,tx_rst_in,tx_rst_in};
*/
/*
// -------------------------------------------//
// ========== IP Reset Controller =========== //
// -------------------------------------------//
alt_e100s10_reset_controller reset_controller (
    .rst_clk                (afu_clk),                            // input
    .rx_clk                 (rx_clk),                             // input
    .tx_clk                 (tx_clk),                             // input
    .csr_rst_in             (csr_rst_in),                         // input, CSR reset
    .xcvr_rx_dig_rst_in     (rx_rst_in),                          // input, triggers RX digital reset
    .tx_fabric_pll_locked   (tx_clk_stable),                      // input, PLL locked signal from TX MAC fPLL
    .tx_clk_stable          (tx_clk_stable),                      // input
    .sys_rst                (sys_rst),                            // input, reset everything
    .rx_rst                 (rx_rst_in),                          // input, reset RX MAC
    .tx_rst                 (tx_rst_in),                          // input, reset TX MAC
    .rx_pcs_ready_in        (rx_pcs_ready),                       // input, from RX PCS
    .rx_ready               (cdr_lock),                           // input, from Native PHY
    .soft_rx_rst            (soft_rx_rst),                        // input, synchronous to rst_clk
    .soft_tx_rst            (soft_tx_rst),                        // input, synchronous to rst_clk
    .csr_rst_out            (csr_rst_afu_clk),                    // output, synchronous to rst_clk
    .xcvr_rx_dig_rst_out    (rx_rst_afu_clk),                     // output, synchronous to rst_clk
    .native_phy_reset       (),                                   // output, synchronous to rst_clk, unused
    .xcvr_rx_sclr           (),                                   // output, synchronous to rst_clk, unused
    .rx_pcs_pll_locked      (cdr_lock),                           // input, from RX PCS PLL
    .rx_pcs_sclr            (),                                   // output, synchronous to rx_clk, unused
    .rx_mac_sclr            (rx_rst_rx_clk),                      // output, synchronous to rx_clk
    .rx_pcs_ready_out       (rx_pcs_ready_rx_clk),                // output, synchronous to rx_clk
    .tx_lanes_stable        (tx_lanes_stable),                    // output, synchronous to rx_clk, based on tx_clk_stable
    .tx_pcs_sclr            (),                                   // output, synchronous to tx_clk, unused
    .tx_mac_sclr            (tx_rst_tx_clk),                      // output, synchronous to tx_clk
    .tx_digitalreset        (tx_digitalreset),                    // TODO: input, from Native PHY
    .tx_digitalreset_stat   (tx_digitalreset_stat),               // input   
    .tx_dll_lock            (tx_dll_lock),                        // input
    .tx_data_valid_core     (1'b0),                               // input, unused
    .tx_data_valid_pma      ()                                    // output, unused
); 

// -------------------------------------------//
// =================  MAC  ================== //
// -------------------------------------------//
assign pause_insert_tx0 = 1'b0;
assign pause_insert_tx1 = 1'b0;

alt_e100s10_mac mac(
    // clocks 
    .rx_clk                 (rx_clk),                               // input 
    .tx_clk                 (tx_clk),                               // input
    .rx_clk_locked		(rx_clk_locked),                            // input 
    .tx_clk_locked		(tx_clk_locked),                            // input

    // Resets 
    .tx_mac_sclr            (tx_rst_tx_clk),                           // input
    .rx_mac_sclr            (rx_rst_rx_clk),                           // input
    .reset_csr              (csr_rst_afu_clk),                         // input

    // Avalon TX Interface
    .l8_tx_startofpacket    (l8_tx_startofpacket),                   // input
    .l8_tx_endofpacket      (l8_tx_endofpacket),                     // input
    .l8_tx_valid            (l8_tx_valid),                           // input
    .l8_tx_ready            (l8_tx_ready),                           // output
    .l8_tx_empty            (l8_tx_empty),                           // input
    .l8_tx_data             (l8_tx_data),                            // input
    .l8_tx_error            (l8_tx_error),                           // input
    .l8_txstatus_valid      (l8_txstatus_valid),                     // output
    .l8_txstatus_data       (l8_txstatus_data),                      // output
    .l8_txstatus_error      (l8_txstatus_error),                     // output

    // Avalon RX Interface
    .l8_rx_startofpacket    (l8_rx_startofpacket),                      // output
    .l8_rx_endofpacket      (l8_rx_endofpacket),                        // output
    .l8_rx_valid            (l8_rx_valid),                              // output
    .l8_rx_empty            (l8_rx_empty),                              // output
    .l8_rx_data             (l8_rx_data),                               // output
    .l8_rxstatus_valid      (l8_rxstatus_valid),                        // output
    .l8_rxstatus_data       (l8_rxstatus_data),                         // output
    .l8_rx_error            (l8_rx_error),                              // output

    // AVMM Interface
    .avmm_clk               (avmm_clk),                             // input, 100MHz

    // PCS input/output
    //.pre_pcs_din_am         (1'b0),                                 // input, backpressure MAC
    //.pcs_din_d              (pcs_din_d),                            // output
    //.pcs_din_c              (pcs_din_c),                            // output
    //.pcs_dout_am            (pcs_dout_am),                          // input
    //.pcs_dout_d             (pcs_dout_d),                           // input
    //.pcs_dout_c             (pcs_dout_c),                           // input
    //.tx_crc_ins_en          (),                                     // output

    .pre_pcs_din_am         (1'b0),                                 // input, backpressure MAC
    .pcs_din_d              (pcs_dout_d),                           // output
    .pcs_din_c              (pcs_dout_c),                           // output
    .pcs_dout_am            (pcs_dout_am),                          // input
    .pcs_dout_d             (pcs_dout_d),                           // input
    .pcs_dout_c             (pcs_dout_c),                           // input
    .tx_crc_ins_en          (),                                     // output

    // MAC RX
    .rx_data_out_valid      (),                                     // output
    .rx_data_out            (),                                     // output
    .rx_ctl_out             (),                                     // output
    .rx_first_data          (),                                     // output
    .rx_last_data           (),                                     // output
    .rx_fcs_error           (),                                     // output
    .rx_fcs_valid           (),                                     // output
    .rx_pcs_fully_aligned   (rx_pcs_ready_rx_clk),                  // input
    .unidirectional_en      (),                                     // output
    .link_fault_gen_en      (),                                     // output
    .remote_fault_status    (),                                     // output
    .local_fault_status     (),                                     // output
    .rx_mii_start           (),                                     // output

    // Flow Control
    .pause_insert_tx0      (pause_insert_tx0),                       // input
    .pause_insert_tx1      (pause_insert_tx1),                       // input
    .pause_receive_rx      (pause_receive_rx),                       // output

    //AVMM Signals
    .avmm_address               (avmm_addr),                          // input, 8-bit 
    .avmm_din                   (avmm_din[31:0]),                     // input, 32-bit
    .avmm_mac_tx_write          (avmm_mac_tx_write),                  // input
    .avmm_mac_rx_write          (avmm_mac_rx_write),                  // input
    .avmm_mac_tx_read           (avmm_mac_tx_read),                   // input
    .avmm_mac_rx_read           (avmm_mac_rx_read),                   // input
    .avmm_mac_tx_dout           (avmm_mac_tx_dout),                   // output
    .avmm_mac_rx_dout           (avmm_mac_rx_dout),                   // output
    .avmm_mac_tx_dval           (avmm_mac_tx_dval),                   // output
    .avmm_mac_rx_dval           (avmm_mac_rx_dval),                   // output

    .avmm_fc_tx_write          (avmm_fc_tx_write),                    // input
    .avmm_fc_tx_read           (avmm_fc_tx_read),                     // input
    .avmm_fc_tx_dout           (avmm_fc_tx_dout),                     // output
    .avmm_fc_tx_dval           (avmm_fc_tx_dval),                     // output
    .avmm_fc_rx_write          (avmm_fc_rx_write),                    // input
    .avmm_fc_rx_read           (avmm_fc_rx_read),                     // input
    .avmm_fc_rx_dout           (avmm_fc_rx_dout),                     // output
    .avmm_fc_rx_dval           (avmm_fc_rx_dval),                     // output

    .avmm_mac_tx_stats_write          (avmm_mac_tx_stats_write),      // input
    .avmm_mac_rx_stats_write          (avmm_mac_rx_stats_write),      // input
    .avmm_mac_tx_stats_read           (avmm_mac_tx_stats_read),       // input
    .avmm_mac_rx_stats_read           (avmm_mac_rx_stats_read),       // input
    .avmm_mac_tx_stats_dout           (avmm_mac_tx_stats_dout),       // output
    .avmm_mac_rx_stats_dout           (avmm_mac_rx_stats_dout),       // output
    .avmm_mac_tx_stats_dval           (avmm_mac_tx_stats_dval),       // output
    .avmm_mac_rx_stats_dval           (avmm_mac_rx_stats_dval)        // output
 );

alt_e100s10_csr csr   (
 // Clocks
    .csr_clk                (afu_clk),                    // input
    .tx_clk                 (tx_clk),                     // input
    .rx_clk                 (rx_clk),                     // input
    .clk_rx_rs              (1'b0),                       // input, 0 if no FEC, 312.5mhz if FEC
    .clk_tx_rs              (1'b0),                       // input, 0 if no FEC, 312.5mhz if FEC
    .cdr_ref_clk            (1'b0),                       // TODO: input, 644/322 mhz
    
    // AVMMM Interface
    .reset                  (csr_rst_afu_clk),              // input

    .write                  (mac_csr_write),                // input
    .read                   (mac_csr_read),                 // input
    .address                (mac_csr_address),              // input, 16-bit
    .data_in                (mac_csr_writedata),            // input, 32-bit

    .data_out               (mac_csr_readdata),
    .data_valid             (mac_csr_readdatavalid),
    .waitrequest            (mac_csr_waitrequest),

    .avmm_din               (avmm_din),
    .avmm_addr              (avmm_addr),

    // MAC AVMM Signals 
    .write_rxmac            (avmm_mac_rx_write),
    .read_rxmac             (avmm_mac_rx_read),
    .data_out_rxmac         (avmm_mac_rx_dout),                // input
    .data_valid_rxmac       (avmm_mac_rx_dval),                // input
    .write_txmac            (avmm_mac_tx_write),
    .read_txmac             (avmm_mac_tx_read),
    .data_out_txmac         (avmm_mac_tx_dout),                // input
    .data_valid_txmac       (avmm_mac_tx_dval),                // input
    .write_fc_tx            (avmm_fc_tx_write),
    .read_fc_tx             (avmm_fc_tx_read),
    .data_out_fc_tx         (avmm_fc_tx_dout),                 // input
    .data_valid_fc_tx       (avmm_fc_tx_dval),                 // input
    .write_fc_rx            (avmm_fc_rx_write),
    .read_fc_rx             (avmm_fc_rx_read),
    .data_out_fc_rx         (avmm_fc_rx_dout),                 // input
    .data_valid_fc_rx       (avmm_fc_rx_dval),                 // input
    
    // MAC Stats AVMM Signals 
    .write_rx_stats            (avmm_mac_rx_stats_write),
    .read_rx_stats             (avmm_mac_rx_stats_read),
    .data_out_rx_stats         (avmm_mac_rx_stats_dout),       // input
    .data_valid_rx_stats       (avmm_mac_rx_stats_dval),       // input
    .write_tx_stats            (avmm_mac_tx_stats_write),
    .read_tx_stats             (avmm_mac_tx_stats_read),
    .data_out_tx_stats         (avmm_mac_tx_stats_dout),       // input
    .data_valid_tx_stats       (avmm_mac_tx_stats_dval),       // input
    
    //RSFEC AVMM Signals 
    .write_tx_rsfec         (),
    .read_tx_rsfec          (),
    .data_out_tx_rsfec      (32'b0),                           // input
    .data_valid_tx_rsfec    (1'b0),                            // input
    .write_rx_rsfec         (),
    .read_rx_rsfec          (),
    .data_out_rx_rsfec      (32'b0),                 // input
    .data_valid_rx_rsfec    (1'b0),                  // input

    // Reset outputs
    .soft_txp_rst           (soft_tx_rst),
    .soft_rxp_rst           (soft_rx_rst),
    .eio_sys_rst            (sys_rst),
   
    // RX status in
    .rx_pempty              (4'b0),                                 // input
    .rx_pfull               (4'b0),                                 // input
    .rx_empty               (4'b0),                                 // input
    .rx_full                (4'b0),                                 // input
    .rxpcs_frm_err          (20'b0),                                // input
    .rx_is_lockedtodata     ({cdr_lock,cdr_lock,cdr_lock,cdr_lock}), // input
    .rx_word_locked         (rx_block_lock),                        // TODO: 20-bit input
    .rx_am_lock             (rx_am_lock),                           // input
    .rx_deskew_locked       (rx_block_lock),                        // input
    .rx_align_locked        (rx_pcs_ready_rx_clk),                  // input
    .rx_hi_ber              (hi_ber),                               // input
    .rxpcs_dout_tags        (100'b0),                               // input
    .rx_am_lock_fec         (1'b0),                                 // input
    .rx_align_status_fec    (1'b0),                                 // input

     //RX strict preamble check 
    .cfg_sfd_det_on         (),
    .cfg_preamble_det_on    (),  

    // RX Status and Control Out
    .rxpcs_frm_err_sclr     (),
    .rx_fifo_soft_purge     (),
    .rx_seriallpbken        (),
    .rx_set_locktoref       (),
    .rx_set_locktodata      (),
    .rx_word_locked_s       (),
    .rx_crc_pt              (),
    .rx_delay               (),

    // TX status in
    .tx_pempty              (4'b0),                           // input
    .tx_pfull               (4'b0),                           // input
    .tx_empty               (4'b0),                           // input
    .tx_full                (4'b0),                           // input
    .tx_pll_locked          (tx_pll_locked_tx_clk),           // input
    .tx_fec_pll_locked      (1'b1),                           // input
    .rx_fec_pll_locked      (1'b1),                           // input
    .tx_digitalreset        ({~tx_lanes_stable,~tx_lanes_stable,~tx_lanes_stable,~tx_lanes_stable}), // input

    // TX Status and Control Out
    .tx_clk_stable          (),
    .tx_crc_pt              (),
    .num_idle_rm            (),

    // Statistics Vector
    .tx_vlandet_disable     (),
    .rx_vlandet_disable     (),
    .tx_max_frm_length      (),
    .rx_max_frm_length      ()
);

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


