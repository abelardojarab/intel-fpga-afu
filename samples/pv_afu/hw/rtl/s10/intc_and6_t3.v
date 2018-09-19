// Copyright 2010-2017 Altera Corporation. All rights reserved.
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

// Generated by one of Gregg's toys.   Share And Enjoy.
// Executable compiled Jun  1 2017 09:50:07
// This file was generated 06/02/2017 15:53:50

// Pipelined AND gate
// 6 inputs,  latency 3 ticks

module intc_and6_t3 #(
    parameter SIM_EMULATE = 1'b0
) (
    input clk,
    input [5:0] din,
    output dout
);

// this is a basic cell with surplus registers
// OK a lot of surplus registers, put one on the input side
reg [1:0] dout_r = 2'b0;
wire dout_w;
reg [5:0] din_r = 6'b0;
always @(posedge clk) din_r <= din;

generate
    if (SIM_EMULATE) begin
        wire [63:0] local_mask = 64'h8000000000000000;
        wire [5:0] local_din = {din_r[5],din_r[4],din_r[3],din_r[2],din_r[1],din_r[0]};
        assign dout_w = local_mask [local_din];
    end else begin
        //Note: the S5 cell is 99% the same, and compatible
        //stratixv_lcell_comb s5c (
 
        twentynm_lcell_comb  #(
            .lut_mask(64'h8000000000000000),
            .shared_arith("off"),
            .extended_lut("off")
        ) s10c_0 (
            .dataa (din_r[0]),
            .datab (din_r[1]),
            .datac (din_r[2]),
            .datad (din_r[3]),
            .datae (din_r[4]),
            .dataf (din_r[5]),
            .datag(1'b1),
            
            .cin(1'b1),
            
            
            // synthesis translate_off
            // this is for stratix 10 (fourteen) but not the others
            //.datah(1'b1),
                        
            // this does not exist in S10, but is partially there in the models right this second
            .sharein(1'b0),
            // synthesis translate_on
            
            .sumout(),.cout(),.shareout(),
            .combout(dout_w)
        );
    end
endgenerate

always @(posedge clk) dout_r <= {dout_r[0:0],dout_w};

assign dout = dout_r[1];

endmodule

