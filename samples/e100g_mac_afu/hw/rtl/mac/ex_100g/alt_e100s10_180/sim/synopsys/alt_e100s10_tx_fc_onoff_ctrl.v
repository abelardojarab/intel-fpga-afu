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

module alt_e100s10_tx_fc_onoff_ctrl
#(
    parameter WORDS = 4
)(
    input       clk,
    input       reset_n,
    
    input       out_ready,
    input       data_valid,

    input       pause_txin_done,
    input [15:0] cfg_holdoff_quanta,
    input       cfg_enable,
    input [15:0] cfg_pause_quanta,
    input       xoff_req,
    input       xon_req,
    output reg        tx_xoff,
    output reg        tx_xon,
    output       queue_pause_req,
    output [15:0] queue_pause_quanta
);

    // _____________________________________________________________________
    //
    localparam IDL = 2'd0, XOF = 2'd1, XON = 2'd2, HLD = 2'd3;
    // _____________________________________________________________________

    // both the pause and hold off quanta values are in multiples of 512-bits 
    // 25G is 1 word wide which is 64-bits
    // the clock count needed = quanta value*8
    // 50G is 2 word wide which is 128-bits
    // the clock count needed = quanta value*4     
     
    reg [19:0] holdoff_cycles;

    //non-resettable
    always @ (posedge clk) begin
        holdoff_cycles <= WORDS == 1 ? {cfg_holdoff_quanta,3'b000} //25G, left shift 3bit the quanta value = *8
                                     : WORDS == 2 ? {cfg_holdoff_quanta,2'b00} : //50G, left shift 2bit the quanta value = *4
                                     {cfg_holdoff_quanta,1'b0}; //100G, left shift 1bit the quanta value = *2
    end
 

    wire holdoff_en;
    //2 cycle of latency
    alt_e100s10_or16t2 holdoff_quanta_or (
        .clk(clk),
        .din(cfg_holdoff_quanta),
        .dout(holdoff_en)
    );

    wire count_done;
    reg [19:0] count;
    reg [10:0] count_1cycle_more;
    //3 cycle of latency
    alt_e100s10_eq20t3 count_eq (
        .clk(clk),
        .dina(holdoff_cycles),
        .dinb(count),
        .dout(count_done)
    );
    
    reg [1:0] state;
    assign queue_pause_req = (state == XOF)||(state == XON);
    assign queue_pause_quanta = (state == XON)? 16'd0:cfg_pause_quanta;

    wire holdoff_done = (state == HLD) && count_done;

    //frame pulses generated at the end of frame pulse transmission
    wire xoff_frame = (state == XOF) && pause_txin_done;
    wire xon_frame  = (state == XON) && pause_txin_done;
    
    // _____________________________________________________________________
    //    indication for transmitted xon and xoff frames
    always @ (posedge clk) begin
        tx_xoff <= xoff_frame;
        tx_xon <= xon_frame;
    end
    
    //to make sure there is a xoff first before move to xon
    reg xoff_prior;
    always @ (posedge clk) begin
        if (~reset_n) begin
            xoff_prior <= 1'b0;
        end else begin
            xoff_prior <= state == XOF ? 1'b1:
                         (state == XON || ~cfg_enable) ? 1'b0:xoff_prior;
        end
    end
    
    // _____________________________________________________________________
    always @ (posedge clk) begin
        if (~reset_n) begin
                 state <= IDL;
                 count <= 20'd0;
        //end else if (out_ready & data_valid) begin
        end else begin
            case (state)
            IDL:begin
                count <= 20'd0;
                count_1cycle_more[10:0] <=  11'd0;
                if (cfg_enable & xoff_req) begin
                    state <= XOF;
                end else if (cfg_enable & xoff_prior & xon_req) begin
                    state <= XON;
                end else begin
                    state <= state;
                end
            end
            XOF:begin
                // once entered this state, the fsm will remain
                // in xoff, until the xoff pause frame has been sent
                // by the link fsm - indicated by the pause_txin_done
                
                // if congestion is removed by the time xoff frame
                // is sent, fsm will take immediate action to send
                // an xon frame - even if holdoff is enabled
            
                // otherwise - if priority hold off is enabled,fsm
                // will move to holdoff state and hence delay
                // the next opportunity to resend the pause frame
                // at the end of the hold off period
                count_1cycle_more[10:0] <=  11'd0;
                if (cfg_enable & pause_txin_done & xon_req) begin
                    state <= XON;
                    count <= 20'd0;
                end else if (cfg_enable & pause_txin_done & holdoff_en) begin
                    state <= HLD;
                    count <= 20'd4; //start counter from 4 because comparator need 3 cyles of latency
                end else if (cfg_enable & pause_txin_done & xoff_req) begin
                    state <= XOF;
                    count <= 20'd0;
                end else if (pause_txin_done) begin
                    state <= IDL;
                    count <= 20'd0;
                end else begin
                    state <= state;
                    count <= count;
                end
            end
            XON: begin
                 // the buffer congestion does not exist anymore
                 // send last pause frame with null pause quanta
                 // though the ingress buffer is practically never
                 // expected to be filled again just between xoff
                 // and xonn states - however - this design does
                 // respond to a buffer full signal and moves to the
                 // xoff state. If no buffer full it moves to idle
                count <= 20'd0;
                count_1cycle_more[10:0] <=  11'd0;
                if (cfg_enable & pause_txin_done & xoff_req) begin
                    state <= XOF;
                end else if (pause_txin_done) begin
                    state <= IDL;
                end else begin
                    state <= state;
                end
            end
            HLD:begin
                 // during a HOLDOFF state, if buffer_full flag is cleared
                 // exit the state to send an xon frame
                 // ehen hold period is done and the fsm should be ready
                 // assert request xoff to lfsm if buffer still filled
                if (cfg_enable & xon_req) begin
                    state <= XON;
                    count <= 20'd0;
                end else if (cfg_enable & holdoff_done & xoff_req) begin
                    state <= XOF;
                    count <= 20'd0;
                end else if (holdoff_done) begin
                    state <= IDL;
                    count <= 20'd0;
                end else begin
                    state <= state;
                    count[9:0] <= count[9:0]  + 10'd1;
                    count_1cycle_more[10:0] <= count[9:0]  + 10'd2;
                    count[19:10] <= count[19:10] + (count_1cycle_more[10]&~count_1cycle_more[0]);
                end
            end
            default:begin
                state <= state;
                count <= count;
                count_1cycle_more[10:0] <=  11'd0;
            end
            endcase
        end
    end


 endmodule


