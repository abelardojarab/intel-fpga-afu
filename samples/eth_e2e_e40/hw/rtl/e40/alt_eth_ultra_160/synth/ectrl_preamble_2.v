// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: $
// $Revision: $
// $Date: $
// $Author: $
//-----------------------------------------------------------------------------
// Copyright 2012 Altera Corporation. All rights reserved.
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

`timescale 1 ps / 1 ps

module ectrl_preamble_2 #(
        parameter WORDS = 2
)(
        input clk,
        input sclr,

        input i_ena,
        input [WORDS-1:0] i_sop, // lsbit first, sop marks the preamble word
        input [WORDS-1:0] i_eop,
        input [WORDS*3-1:0] i_eop_empty,
        input [WORDS*3-1:0] i_data_empty,
        input [WORDS*3-1:0] i_tags,

        output o_wait_req,
        output [WORDS*3-1:0] o_tags,
                // 111,110,101,100 data words
                // 000 idles
                // 001 padding
        output [WORDS-1:0] o_sop, // lsbit first
        output [WORDS-1:0] o_eop, 
        output [WORDS*3-1:0] o_eop_empty, 
        output [WORDS*3-1:0] o_data_empty
);

reg         gap_req0=0, gap_req1=0;

reg local_sclr = 1'b0;
always @(posedge clk) local_sclr <= sclr;

always @(*) begin
       gap_req0 = i_sop[0];
       gap_req1 = i_sop[1];
end

ectrl_ins4preamble_2 eins4preamble(
        .clk(clk),
        .sclr(local_sclr),

        .i_gap_req0(gap_req0),
        .i_gap_req1(gap_req1),
        .i_ena(i_ena),
        .i_sop(i_sop), // lsbit first, sop marks the preamble word
        .i_eop(i_eop),
        .i_eop_empty(i_eop_empty),
        .i_data_empty(i_data_empty),
        .i_tags(i_tags),

        .o_wait_req(o_wait_req),
        .o_tags(o_tags),
                // 111,110,101,100 data words
                // 000 idles
                // 001 padding
        .o_sop(o_sop), // lsbit first
        .o_eop(o_eop),
        .o_eop_empty(o_eop_empty),
        .o_data_empty(o_data_empty)
);

endmodule

 
