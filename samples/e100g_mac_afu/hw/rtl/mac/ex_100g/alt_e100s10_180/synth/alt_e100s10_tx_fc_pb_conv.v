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

module alt_e100s10_tx_fc_pb_conv
#(
    parameter WORDS = 4, //25G = 1, 50G = 2, 100G = 4
    parameter NUMPRIORITY = 2
)(
    input clk_tx,
    input clk_rx,
    input reset_tx_n,
    input reset_rx_n,

    input data_valid,
    input out_ready,
    
    input [NUMPRIORITY-1:0] cfg_enable,
    input cfg_pfc_sel, //1=pfc, 0=pause
    input cfg_tx_off_en, //tx clock domain
    input [NUMPRIORITY-1:0] cfg_rx_pfc_en,
    
    input rx_pfc_frame, //1=pfc, 0=pause
    input rx_pause_quanta_valid,
    input [15:0]rx_pause_quanta_en,
    input [NUMPRIORITY*16-1:0] rx_pause_quanta_data,

    output stall_req,
    input stall_ack,
    output traffic_stall_done,
    
    output [NUMPRIORITY-1:0] pause_receive_rx
);

	localparam TIMER_WIDTH = (WORDS == 1) ? 19 : (WORDS == 2) ? 18 : 17; //25G=19b, 50G=18b, 100g=17b???
    
    assign traffic_stall_done = ~stall_req;
    
    wire cfg_pfc_sel_rx_clk;
    alt_e100s10_sync1r2 cfg_fc_sel_sync (
        .din_clk(clk_tx),
        .din(cfg_pfc_sel),
        .dout_clk(clk_rx),
        .dout(cfg_pfc_sel_rx_clk)
    );
    
    reg stall_ack_tx_clk;
    wire stall_ack_rx_clk;
    //Synchronous reset
    always @ (posedge clk_tx) begin
        if (~reset_tx_n) begin
            stall_ack_tx_clk <=1'b0;
        end else begin
            //tx ready down will stop the counter as well
            //There are 2 case where tx ready down
            //1. padding, crc insert, preamble insert --> counter should stop for this case
            //2. IPG insertion --> counter should not stop for this case
            //Only 1 ready signal, thus we try to be pesimistic in the counting where counter stop for both case
            //stall_ack_tx_clk <= cfg_tx_off_en ? stall_ack & out_ready : 1'b1;
            stall_ack_tx_clk <= cfg_tx_off_en ? stall_ack : 1'b1;
        end
    end
    alt_e100s10_sync1r2 txoff_ack_sync (
        .din_clk(clk_tx),
        .din(stall_ack_tx_clk),
        .dout_clk(clk_rx),
        .dout(stall_ack_rx_clk)
    );
 
    wire [NUMPRIORITY*TIMER_WIDTH-1:0] pq_cycle;
    genvar i;
    generate
    for (i = 0;i < NUMPRIORITY; i=i+1) begin: PQ_CYCLE
        if (WORDS == 1) begin
            assign pq_cycle[(i+1)*TIMER_WIDTH-1:i*TIMER_WIDTH] = {rx_pause_quanta_data[(i+1)*16-1:i*16],3'b000};
        end else if (WORDS == 2) begin
            assign pq_cycle[(i+1)*TIMER_WIDTH-1:i*TIMER_WIDTH] = {rx_pause_quanta_data[(i+1)*16-1:i*16],2'b00};
        end else if (WORDS == 4) begin // ???
            assign pq_cycle[(i+1)*TIMER_WIDTH-1:i*TIMER_WIDTH] = {rx_pause_quanta_data[(i+1)*16-1:i*16],1'b0};
        end
    end
    endgenerate
  

    wire pause;
    alt_e100s10_tx_fc_pb_timer
    #(
        .WIDTH(TIMER_WIDTH)
    ) pause_timer (
        .clk(clk_rx),
        .reset_n(reset_rx_n),
        .load(rx_pause_quanta_valid & ~rx_pfc_frame),
        .enable(stall_ack_rx_clk & data_valid), //if rx clock running faster, then rx data valid is needed to have a correct counting
        .pq_cycle(pq_cycle[TIMER_WIDTH-1:0]),
        .pause(pause),
        .done() //not used
    );
    
    reg stall_req_rx_clk;
    //Synchronous reset
    always @ (posedge clk_rx) begin
        if (~reset_rx_n) begin
            stall_req_rx_clk <=1'b0;
        end else begin
            stall_req_rx_clk <= pause & ~cfg_pfc_sel_rx_clk;
        end
    end

    wire stall_req_tx_clk;
    assign stall_req = stall_req_tx_clk & cfg_tx_off_en;
    alt_e100s10_sync1r2 txoff_req_sync (
        .din_clk(clk_rx),
        .din(stall_req_rx_clk),
        .dout_clk(clk_tx),
        .dout(stall_req_tx_clk)
    );
    
    wire [NUMPRIORITY-1:0] pfc_pause;
    generate
    for (i = 0; i < NUMPRIORITY; i=i+1) begin: PFC_TIMER
        alt_e100s10_tx_fc_pb_timer
        #(
            .WIDTH(TIMER_WIDTH)
        ) pfc_timer (
            .clk(clk_rx),
            .reset_n(reset_rx_n),
            .load(rx_pause_quanta_valid & rx_pfc_frame & rx_pause_quanta_en[i]),
            .enable(data_valid), //if rx clock running faster, then rx data valid is needed to have a correct counting
            .pq_cycle(pq_cycle[(i+1)*TIMER_WIDTH-1:i*TIMER_WIDTH]),
            .pause(pfc_pause[i]),
            .done() //not used
        );
		if (i == 0) begin
		    assign pause_receive_rx[0] = cfg_pfc_sel_rx_clk ? pfc_pause[0] & cfg_rx_pfc_en[0] : pause;
		end else begin
            assign pause_receive_rx[i] = pfc_pause[i] & cfg_rx_pfc_en[i] & cfg_pfc_sel_rx_clk;
        end
    end
    endgenerate
endmodule


