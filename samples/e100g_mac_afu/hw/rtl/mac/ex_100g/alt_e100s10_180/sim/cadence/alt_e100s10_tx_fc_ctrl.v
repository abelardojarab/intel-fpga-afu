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

module alt_e100s10_tx_fc_ctrl
#(
    parameter WORDS = 4, //25G = 1, 50G = 2, 100G = 4
    parameter EMPTYBITS = 6,
    parameter NUMPRIORITY = 2,
    parameter PREAMBLE_PASS = 1,
    parameter ALLOCATE_4B_CRC = 1 //1=allocate crc for pause/pfc frame ==>64B of packet not including preamble
                                     //0=do not allocate crc for pause/pfc frame ==> 60B of packet not including preamble       
) (
    input clk,
    input reset_n,
    
    input [NUMPRIORITY-1:0] cfg_enable,
    input cfg_pfc_sel, //0=pause,1=pfc,
    input [NUMPRIORITY*16-1:0] cfg_pause_quanta,
    input [NUMPRIORITY*16-1:0] cfg_holdoff_quanta,
    input [NUMPRIORITY-1:0] cfg_2b_req_mode_csr_req_sel, //0=use signal, 1=use csr
    input [NUMPRIORITY-1:0] cfg_2b_req_mode_sel, //0=use 1 bit, 1=use 2 bit
    input [NUMPRIORITY-1:0] cfg_pause_req0,
    input [NUMPRIORITY-1:0] cfg_pause_req1,
    input [47:0] cfg_saddr,
    input [47:0] cfg_daddr,

    input [NUMPRIORITY-1:0] sig_pause_req0,
    input [NUMPRIORITY-1:0] sig_pause_req1,
    
    input stall_req,
    output stall_ack,
    input traffic_stall_done,
    
    input out_ready,
    input data_valid,
    output txoff_req,
    input txoff_ack,
    output fc_sel,
    
    output out_pfc_sop,
    output out_pfc_eop,
    output out_pfc_valid,
    output [511:0] out_pfc_data,
    output [EMPTYBITS-1:0] out_pfc_empty,

    output tx_xoff,
    output tx_xon
);
 
    wire [NUMPRIORITY-1:0] queue_pause_req;
    wire [NUMPRIORITY*16-1:0] queue_pause_quanta;
    wire [NUMPRIORITY-1:0] pause_txin_done;

    wire [NUMPRIORITY-1:0] pause_req;
    reg [NUMPRIORITY-1:0] in_pause_req_dly_0;
    reg [NUMPRIORITY-1:0] in_pause_req_dly_1;
    wire [NUMPRIORITY-1:0] xoff_req_1b;
    wire [NUMPRIORITY-1:0] xon_req_1b;
    wire [NUMPRIORITY-1:0] pause_req0;
    wire [NUMPRIORITY-1:0] pause_req1;
    wire [NUMPRIORITY-1:0] xoff_req_2b;
    wire [NUMPRIORITY-1:0] xon_req_2b;
    reg [NUMPRIORITY-1:0] final_xoff_req;
    reg [NUMPRIORITY-1:0] final_xon_req;
    wire [NUMPRIORITY-1:0] tx_xoff_wire;
    wire [NUMPRIORITY-1:0] tx_xon_wire;
    
    assign tx_xoff = |tx_xoff_wire;
    assign tx_xon = |tx_xon_wire;
 
    genvar i;
    generate
    for (i =0; i < NUMPRIORITY; i=i+1) begin: XOFF_XON_REQ
        //1 bit on/off control    
        assign pause_req[i] = sig_pause_req0[i] | cfg_pause_req0[i];
        assign xoff_req_1b[i]=  in_pause_req_dly_1[i] |( in_pause_req_dly_0[i] & ~in_pause_req_dly_1[i]);
        assign xon_req_1b[i] = ~in_pause_req_dly_1[i] |(~in_pause_req_dly_0[i] &  in_pause_req_dly_1[i]);
        always @(posedge clk) begin
            if (~reset_n) begin
                in_pause_req_dly_0[i] <= 1'b0;
                in_pause_req_dly_1[i] <= 1'b0;
            end else begin
                in_pause_req_dly_0[i] <= pause_req[i];
                in_pause_req_dly_1[i] <= in_pause_req_dly_0[i];
            end
        end
    
        //2 bit on/off control
        assign pause_req0[i] = cfg_2b_req_mode_csr_req_sel[i] ? cfg_pause_req0[i] : sig_pause_req0[i];
        assign pause_req1[i] = cfg_2b_req_mode_csr_req_sel[i] ? cfg_pause_req1[i] : sig_pause_req1[i];
        assign xoff_req_2b[i] = pause_req1[i] & ~pause_req0[i];
        assign xon_req_2b[i] = ~pause_req1[i] & pause_req0[i];
        
        //mux between 1 bit operation and 2 bit operation
        always @(posedge clk) begin
            final_xoff_req[i] <= cfg_2b_req_mode_sel[i] ? xoff_req_2b[i] : xoff_req_1b[i];
            final_xon_req[i] <= cfg_2b_req_mode_sel[i] ? xon_req_2b[i] : xon_req_1b[i];
        end
    end
    endgenerate
    
    wire [NUMPRIORITY-1:0] onoff_ctrl_en;
    generate
    for (i =0; i < NUMPRIORITY; i=i+1) begin: ONOFF_CTRL
        if (i == 0) begin
            assign onoff_ctrl_en[i] = cfg_enable[i];
        end else begin
            assign onoff_ctrl_en[i] = cfg_enable[i] & cfg_pfc_sel; //sm of q1-7 should not do anything if pfc_sel choose pause mode.
        end
        
        alt_e100s10_tx_fc_onoff_ctrl
        #(
            .WORDS(WORDS)
        ) fc_onoff_ctrl (
            .clk(clk),
            .reset_n(reset_n),
            .out_ready(out_ready),
            .data_valid(data_valid),
            .pause_txin_done(pause_txin_done[i]),
            .cfg_holdoff_quanta(cfg_holdoff_quanta[16*(i+1)-1:16*i]),
            .cfg_enable(onoff_ctrl_en[i]),
            .cfg_pause_quanta(cfg_pause_quanta[16*(i+1)-1:16*i]),
            .xoff_req(final_xoff_req[i]),
            .xon_req(final_xon_req[i]),
            .tx_xoff(tx_xoff_wire[i]),
            .tx_xon(tx_xon_wire[i]),
            .queue_pause_req(queue_pause_req[i]),
            .queue_pause_quanta(queue_pause_quanta[16*(i+1)-1:16*i])
        );
    end
    endgenerate
    
    alt_e100s10_tx_fc_arbiter_ctrl
    #(
        .WORDS(WORDS),
        .EMPTYBITS(EMPTYBITS),
        .NUMPRIORITY(NUMPRIORITY),
        .PREAMBLE_PASS(PREAMBLE_PASS),
        .ALLOCATE_4B_CRC(ALLOCATE_4B_CRC)
    ) arbiter_ctrl (
        .clk(clk),
        .reset_n(reset_n),
        .out_ready(out_ready),
        .data_valid(data_valid),
        .txoff_req(txoff_req),
        .txoff_ack(txoff_ack),
        .cfg_enable(cfg_enable),
        .queue_pause_req(queue_pause_req),
        .queue_pause_quanta(queue_pause_quanta),
        .cfg_pfc_sel(cfg_pfc_sel),
        .cfg_saddr(cfg_saddr),
        .cfg_daddr(cfg_daddr),
        .stall_req(stall_req),
        .stall_ack(stall_ack),
        .traffic_stall_done(traffic_stall_done),
        .pause_txin_done(pause_txin_done),
        .fc_sel(fc_sel),
        .out_pfc_sop(out_pfc_sop),
        .out_pfc_eop(out_pfc_eop),
        .out_pfc_valid(out_pfc_valid),
        .out_pfc_data(out_pfc_data),
        .out_pfc_empty(out_pfc_empty)
    );

endmodule


