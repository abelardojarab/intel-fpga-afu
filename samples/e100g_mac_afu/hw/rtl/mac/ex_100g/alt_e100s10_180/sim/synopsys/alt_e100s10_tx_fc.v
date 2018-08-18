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

module alt_e100s10_tx_fc
#(
    parameter WORDS = 4,
    parameter EMPTYBITS = 6,
    parameter NUMPRIORITY = 2,
    parameter PREAMBLE_PASS = 1,
    parameter ALLOCATE_4B_CRC = 1
) (
    input clk_tx,
    input clk_rx,
    input reset_tx_n,
    input reset_rx_n,

    input [NUMPRIORITY-1:0] cfg_enable,
    input cfg_pfc_sel,
    input [NUMPRIORITY*16-1:0] cfg_pause_quanta,
    input [NUMPRIORITY*16-1:0] cfg_holdoff_quanta,
    input [NUMPRIORITY-1:0] cfg_2b_req_mode_csr_req_sel,
    input [NUMPRIORITY-1:0] cfg_2b_req_mode_sel,
    input [NUMPRIORITY-1:0] cfg_pause_req0,
    input [NUMPRIORITY-1:0] cfg_pause_req1,
    input [47:0] cfg_saddr,
    input [47:0] cfg_daddr,
    input cfg_tx_off_en,
    input [NUMPRIORITY-1:0] cfg_rx_pfc_en,

    output in_ready,
    //input [WORDS-1:0] in_idle,
    input in_sop,
    input in_eop,
    input in_error,
    input [511:0] in_data,
    input [EMPTYBITS-1:0] in_empty,
    //input [63:0] in_preamble,
    
    input out_ready,
    input rx_data_valid,
    input tx_data_valid,
    
    //output [WORDS-1:0] out_idle,
    output out_sop,
    output out_eop,
    output out_error,
    output [511:0] out_data,
    output [EMPTYBITS-1:0] out_empty,
    //output [63:0] out_preamble,
    output out_pfc_frame,
    output fc_sel,

    input [NUMPRIORITY-1:0] sig_pause_req0,
    input [NUMPRIORITY-1:0] sig_pause_req1,
    
    input rx_pfc_frame,
    input rx_pause_quanta_valid,
    input [15:0]rx_pause_quanta_en,
    input [NUMPRIORITY*16-1:0] rx_pause_quanta_data,
    output [NUMPRIORITY-1:0] pause_receive_rx,

    output tx_xoff,
    output tx_xon
);
    
    wire txoff_req;
    wire txoff_ack;
    wire traffic_stall_done;
    wire stall_req;
    wire stall_ack;
    wire pfc_sop;
    wire pfc_eop;
    wire pfc_valid;
    wire [511:0] pfc_data;
    wire [EMPTYBITS-1:0] pfc_empty;

    alt_e100s10_tx_fc_frame_muxer
    #(
        .WORDS(WORDS),
        .EMPTYBITS(EMPTYBITS)
    ) tx_fc_frame_muxer (
        .clk(clk_tx),
        .rst_n(reset_tx_n),
        .data_valid(tx_data_valid),
        .in_ready(in_ready),
        //.in_idle(in_idle),
        .in_sop(in_sop),
        .in_eop(in_eop),
        .in_error(in_error),
        .in_data(in_data),
        .in_empty(in_empty),
        //.in_preamble(in_preamble),
        .in_pfc_sop(pfc_sop),
        .in_pfc_eop(pfc_eop),
        .in_pfc_valid(pfc_valid),
        .in_pfc_data(pfc_data),
        .in_pfc_empty(pfc_empty),
        .out_ready(out_ready),
        //.out_idle(out_idle),
        .out_sop(out_sop),
        .out_eop(out_eop),
        .out_error(out_error),
        .out_data(out_data),
        .out_empty(out_empty),
        //.out_preamble(out_preamble),
        .out_pfc_frame(out_pfc_frame),
        .fc_sel(fc_sel),
        .txoff_ack(txoff_ack),
        .txoff_req(txoff_req)
     );
    
    alt_e100s10_tx_fc_ctrl
    #(
        .WORDS(WORDS),
        .EMPTYBITS(EMPTYBITS),
        .NUMPRIORITY(NUMPRIORITY),
        .PREAMBLE_PASS(PREAMBLE_PASS),
        .ALLOCATE_4B_CRC(ALLOCATE_4B_CRC)
    ) tx_fc_ctrl (
        .clk(clk_tx),
        .reset_n(reset_tx_n),
        .cfg_enable(cfg_enable),
        .cfg_pfc_sel(cfg_pfc_sel),
        .cfg_pause_quanta(cfg_pause_quanta),
        .cfg_holdoff_quanta(cfg_holdoff_quanta),
        .cfg_2b_req_mode_csr_req_sel(cfg_2b_req_mode_csr_req_sel),
        .cfg_2b_req_mode_sel(cfg_2b_req_mode_sel),
        .cfg_pause_req0(cfg_pause_req0),
        .cfg_pause_req1(cfg_pause_req1),
        .cfg_saddr(cfg_saddr),
        .cfg_daddr(cfg_daddr),
        .sig_pause_req0(sig_pause_req0),
        .sig_pause_req1(sig_pause_req1),
        .stall_req(stall_req),
        .stall_ack(stall_ack),
        .traffic_stall_done(traffic_stall_done),
        .out_ready(out_ready),
        .data_valid(tx_data_valid),
        .txoff_req(txoff_req),
        .txoff_ack(txoff_ack),
        .fc_sel(fc_sel),
        .out_pfc_sop(pfc_sop),
        .out_pfc_eop(pfc_eop),
        .out_pfc_valid(pfc_valid),
        .out_pfc_data(pfc_data),
        .out_pfc_empty(pfc_empty),
        .tx_xoff(tx_xoff),
        .tx_xon(tx_xon)
    );

    alt_e100s10_tx_fc_pb_conv
    #(
        .WORDS(WORDS),
        .NUMPRIORITY(NUMPRIORITY)
    ) pb_conv (
        .clk_tx(clk_tx),
        .clk_rx(clk_rx),
        .reset_tx_n(reset_tx_n),
        .reset_rx_n(reset_rx_n),
        .data_valid(rx_data_valid),
        .out_ready(out_ready),
        .cfg_enable(cfg_enable),
        .cfg_pfc_sel(cfg_pfc_sel),
        .cfg_tx_off_en(cfg_tx_off_en),
        .cfg_rx_pfc_en(cfg_rx_pfc_en),
        .rx_pfc_frame(rx_pfc_frame),
        .rx_pause_quanta_valid(rx_pause_quanta_valid),
        .rx_pause_quanta_en(rx_pause_quanta_en),
        .rx_pause_quanta_data(rx_pause_quanta_data),
        .stall_req(stall_req),
        .stall_ack(stall_ack),
        .traffic_stall_done(traffic_stall_done),
        .pause_receive_rx(pause_receive_rx)
    );
         
endmodule


