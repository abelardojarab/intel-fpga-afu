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

module alt_e100s10_tx_fc_frame_muxer
#(
    parameter WORDS = 4,
    parameter EMPTYBITS = 6
)(
    input clk,
    input rst_n,

    //input data-path interface
    output in_ready,
    //input [WORDS-1:0] in_idle,
    input in_sop,
    input in_eop,
    input in_error,
    input [511:0] in_data,
    input [EMPTYBITS-1:0] in_empty,
    //input [63:0] in_preamble,
    
    //pfc data frame
    input in_pfc_sop,
    input in_pfc_eop,
    input in_pfc_valid,
    input [511:0] in_pfc_data,
    input [EMPTYBITS-1:0] in_pfc_empty,

    //output data-path interface
    input out_ready,
    input data_valid,
    //output [WORDS-1:0] out_idle,
    output out_sop,
    output out_eop,
    output out_error,
    output [511:0] out_data,
    output [EMPTYBITS-1:0] out_empty,
    //output [63:0] out_preamble,
    output out_pfc_frame, //tagging of pfc/pause frame

    input fc_sel,

    input txoff_req,
    output reg txoff_ack
);


    //reg [WORDS-1:0] idle_reg0;
    reg sop_reg0;
    reg eop_reg0;
    reg error_reg0;
    reg [511:0] data_reg0 = 0;
    reg [EMPTYBITS-1:0] empty_reg0;
    //reg [63:0] preamble_reg0;
    
    //reg [WORDS-1:0] idle_reg1;
    reg sop_reg1;
    reg eop_reg1;
    reg error_reg1;
    reg [511:0] data_reg1=0;
    reg [EMPTYBITS-1:0] empty_reg1;
    //reg [63:0] preamble_reg1;

    reg txoff=1'b0;
    reg pkt_end;
 
    //input 2 stage pipeline
    always @ (posedge clk) begin
        //synchronous reset
        if (~rst_n) begin
            sop_reg0 <= 1'b0;
            eop_reg0 <= 1'b0;
            error_reg0 <= 1'b0;
    
            sop_reg1 <= 1'b0;
            eop_reg1 <= 1'b0;
            error_reg1 <= 1'b0;
        end else begin
            if (~txoff & out_ready & data_valid) begin
                sop_reg0 <= in_sop;
                eop_reg0 <= in_eop;
                error_reg0 <= in_error;
                
                sop_reg1 <= sop_reg0;
                eop_reg1 <= eop_reg0;
                error_reg1 <= error_reg0;
            end
        end
        
        //not resettable
        if (~txoff & out_ready & data_valid) begin
            data_reg0 <= in_data;
            empty_reg0 <= in_empty;
            //preamble_reg0 <= in_preamble;
            
            data_reg1 <= data_reg0;
            empty_reg1 <= empty_reg0;
            //preamble_reg1 <= preamble_reg0;
        end
        
    end

    always @ (posedge clk) begin
        if (~rst_n) begin
            pkt_end <= 1'b1;
        end else begin
            if (out_ready & data_valid) begin
                if (in_eop) begin
                    pkt_end <= 1'b1;
                end else if (in_sop) begin
                    pkt_end <= 1'b0;
                end else begin
                    pkt_end <= pkt_end;
                end
            end
        end
    end
    
    //detect txoff_ack 1 cycle earlier before txoff
    always @ (posedge clk) begin
        if (~rst_n) begin
            txoff_ack <= 1'b0;
            txoff <= 1'b0;
        end else begin
            if (out_ready & data_valid) begin
                if (pkt_end & txoff_req) begin
                    txoff_ack <= 1'b1;
                end else if (~txoff_req) begin
                    txoff_ack <= 1'b0;
                end else begin
                    txoff_ack <= txoff_ack;
                end
                
                if (txoff_ack & txoff_req) begin
                    txoff <= 1'b1;
                end else if (~txoff_req) begin
                    txoff <= 1'b0;
                end else begin
                    txoff <= txoff;
                end
            end
        end
    end
    
    assign in_ready = ~txoff & out_ready;
    
    //reg [WORDS-1:0] idle_reg2;
    reg sop_reg2;
    reg eop_reg2;
    reg error_reg2;
    reg [511:0] data_reg2=0;
    reg [EMPTYBITS-1:0] empty_reg2;
    //reg [63:0] preamble_reg2;
    reg out_pfc_frame_reg;

    //output 1 stage pipeline
    always @ (posedge clk) begin
        //synchronous reset
        if (~rst_n) begin
            sop_reg2 <= 1'b0;
            eop_reg2 <= 1'b0;
            error_reg2 <= 1'b0;
            out_pfc_frame_reg <= 1'b0;
        end else begin
            if (out_ready & data_valid) begin
                if (~fc_sel & ~txoff) begin
                    sop_reg2 <= sop_reg1;
                    eop_reg2 <= eop_reg1;
                    error_reg2 <= error_reg1;
                    out_pfc_frame_reg <= 1'b0;
                end else if (fc_sel) begin
                    sop_reg2 <= in_pfc_sop;
                    eop_reg2 <= in_pfc_eop;
                    error_reg2 <= 1'b0;
                    out_pfc_frame_reg <= 1'b1;
                end else begin
                    sop_reg2 <= 1'b0;
                    eop_reg2 <= 1'b0;
                    error_reg2 <= 1'b0;
                    out_pfc_frame_reg <= 1'b0;
                end
            end
        end
        
        //not resettable
        if (out_ready & data_valid) begin
            if (~fc_sel & ~txoff) begin
                data_reg2 <= data_reg1;
                empty_reg2 <= empty_reg1;
                //preamble_reg2 <= preamble_reg1;
            end else if (fc_sel) begin
                data_reg2 <= in_pfc_data;
                //empty_reg2 <= {3'b0,in_pfc_empty[2:0]};
                empty_reg2 <= in_pfc_empty;
                //preamble_reg2 <= 64'hFB555555555555D5;
            end else begin
                data_reg2 <= 512'b0;
                empty_reg2 <= {EMPTYBITS{1'b0}};
                //preamble_reg2 <= 64'hFB555555555555D5;
            end
        end    
 
    end

    assign out_sop = sop_reg2;
    assign out_eop = eop_reg2;
    assign out_error = error_reg2;
    assign out_data = data_reg2;
    assign out_empty = empty_reg2;
    assign out_pfc_frame = out_pfc_frame_reg;
    
endmodule


