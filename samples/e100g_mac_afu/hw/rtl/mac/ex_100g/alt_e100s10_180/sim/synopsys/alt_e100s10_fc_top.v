// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



`timescale 1 ps / 1 ps

module alt_e100s10_fc_top #(
    parameter PREAMBLE_PASS        = 0,
    parameter NUMPRIORITY          = 1,
    parameter ALLOCATE_4B_CRC      = 1,
    parameter WORDS                = 4,
    parameter WIDTH                = 64,
    parameter TXEMPTYBITS          = 6,
    parameter RXEMPTYBITS          = 6,
    parameter RXERRWIDTH           = 6
  )(
    // Clock & Reset
    input                         clk_tx,
    input                         clk_rx,
    input                         reset_tx_n,
    input                         reset_rx_n,
    
    // Input from CSR
    input [NUMPRIORITY-1:0]        cfg_enable,
    input                          cfg_pfc_sel,
    input [NUMPRIORITY*16-1:0]     cfg_pause_quanta,
    input [NUMPRIORITY*16-1:0]     cfg_holdoff_quanta,
    input [NUMPRIORITY-1:0]        cfg_2b_req_mode_sel,
    input [NUMPRIORITY-1:0]        cfg_2b_req_mode_csr_req_sel,
    input [NUMPRIORITY-1:0]        cfg_pause_req0,
    input [NUMPRIORITY-1:0]        cfg_pause_req1,
    input [47:0]                   cfg_tx_saddr,
    input [47:0]                   cfg_tx_daddr,
    input [47:0]                   cfg_rx_daddr,
    input                          cfg_tx_off_en,
    input [NUMPRIORITY-1:0]        cfg_rx_pfc_en,
    input                          cfg_rx_crc_pt,

    // AV-ST input from user
    output                         tx_in_ready,
    input                          tx_in_sop,
    input                          tx_in_eop,
    input                          tx_in_error,
    input [511:0]                  tx_in_data,
    input [TXEMPTYBITS-1:0]        tx_in_empty,
    
    // AV-ST output to MAC
    input                          tx_out_ready,
    output                         tx_out_sop,
    output                         tx_out_eop,
    output                         tx_out_error,
    output [511:0]                 tx_out_data,
    output [TXEMPTYBITS-1:0]       tx_out_empty,
    output                         tx_out_pfc_frame,
    output                         fc_sel,

    input                          rx_data_valid,
    input                          tx_data_valid,
    
    input [NUMPRIORITY-1:0]        pause_insert_tx0,
    input [NUMPRIORITY-1:0]        pause_insert_tx1,
    output [NUMPRIORITY-1:0]       pause_receive_rx,

    output                         tx_xoff,
    output                         tx_xon,

    // AV-ST input from MAC
    input [511:0]                  rx_in_data,
    input                         rx_in_sop,
    input                         rx_in_eop,
    input                         rx_in_valid,
    input [RXEMPTYBITS-1:0]       rx_in_empty,
    input [RXERRWIDTH-1:0]        rx_in_error
);

wire                      rx_pfc_frame;
wire                      rx_pause_quanta_valid;
wire [7:0]                rx_pause_quanta_en;
wire [NUMPRIORITY*16-1:0] rx_pause_quanta_data;

alt_e100s10_tx_fc #(
    .WORDS(WORDS),
    .EMPTYBITS(TXEMPTYBITS),
    .NUMPRIORITY(NUMPRIORITY),
    .PREAMBLE_PASS(PREAMBLE_PASS),
    .ALLOCATE_4B_CRC(ALLOCATE_4B_CRC)
  ) tx_fc (
    .clk_tx(clk_tx),
    .clk_rx(clk_rx),
    .reset_tx_n(reset_tx_n),
    .reset_rx_n(reset_rx_n),

    .cfg_enable(cfg_enable),
    .cfg_pfc_sel(cfg_pfc_sel),
    .cfg_pause_quanta(cfg_pause_quanta),
    .cfg_holdoff_quanta(cfg_holdoff_quanta),
    .cfg_2b_req_mode_csr_req_sel(cfg_2b_req_mode_csr_req_sel),
    .cfg_2b_req_mode_sel(cfg_2b_req_mode_sel),
    .cfg_pause_req0(cfg_pause_req0),
    .cfg_pause_req1(cfg_pause_req1),
    .cfg_saddr(cfg_tx_saddr),
    .cfg_daddr(cfg_tx_daddr),
    .cfg_tx_off_en(cfg_tx_off_en),
    .cfg_rx_pfc_en(cfg_rx_pfc_en),

    .in_ready(tx_in_ready),
    .in_sop(tx_in_sop),
    .in_eop(tx_in_eop),
    .in_error(tx_in_error),
    .in_data(tx_in_data),
    .in_empty(tx_in_empty),
    
    .out_ready(tx_out_ready),
    .out_sop(tx_out_sop),
    .out_eop(tx_out_eop),
    .out_error(tx_out_error),
    .out_data(tx_out_data),
    .out_empty(tx_out_empty),
    .out_pfc_frame(tx_out_pfc_frame),
    .fc_sel(fc_sel),

    .rx_data_valid(rx_data_valid),
    .tx_data_valid(tx_data_valid),
    
    .sig_pause_req0(pause_insert_tx0),
    .sig_pause_req1(pause_insert_tx1),
    .pause_receive_rx(pause_receive_rx),
    
    .rx_pfc_frame(rx_pfc_frame),
    .rx_pause_quanta_valid(rx_pause_quanta_valid),
    .rx_pause_quanta_en({8'd0,rx_pause_quanta_en}),
    .rx_pause_quanta_data(rx_pause_quanta_data),

    .tx_xoff(tx_xoff),
    .tx_xon(tx_xon)
);

alt_e100s10_rx_fc #(
    .WORDS(WORDS),
    .WIDTH(WIDTH),
    .EMPTYBITS(RXEMPTYBITS),
    .RXERRWIDTH(RXERRWIDTH),
    .NUMPRIORITY(NUMPRIORITY),
    .PREAMBLE_PASS(PREAMBLE_PASS),
    .PIPE_INPUTS(1)
) rx_fc (
    .clk(clk_rx),
    .reset_n(reset_rx_n),
    
    // Input from CSR
    .cfg_rx_mac_da(cfg_rx_daddr),
    .cfg_rx_crc_pt(cfg_rx_crc_pt),
    .cfg_rx_pfc_en(8'hFF), // Will be handled by TX FC. Tie to 1.
    
    // AV-ST input from MAC
    .in_data(rx_in_data),
    .in_sop(rx_in_sop),
    .in_eop(rx_in_eop),
    .in_valid(rx_in_valid),
    .in_empty(rx_in_empty),
    .in_error(rx_in_error),

    // Output to TX Flow Control
    .out_pfc_ena(rx_pause_quanta_en),
    .out_pq_data(rx_pause_quanta_data),
    .out_pfc_frame(rx_pfc_frame),
    .out_pq_valid(rx_pause_quanta_valid)
);
    
endmodule
