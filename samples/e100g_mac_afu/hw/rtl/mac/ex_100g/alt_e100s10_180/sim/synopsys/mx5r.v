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

// baeckler - 08-20-2012
// registered 5:1 MUX

// DESCRIPTION
// 
// This is a registered 5:1 bus MUX. The fifth channel is using the synchronous load, so the LUT depth is
// still arguably one.
// 

// CONFIDENCE
// This muxing component has very little state.  Problems should be clearly visible in simulation.
// 

module mx5r #(
	parameter WIDTH = 16
)(
	input clk,
	input [5*WIDTH-1:0] din,
	input [2:0] sel,
	output [WIDTH-1:0] dout
);

genvar k;
generate 
wire   [WIDTH-1:0] do_0;
for  (k=0; k<WIDTH; k=k+1) begin : lp
       alt_sel5t m (
        .d4(din[(4*WIDTH)+k]),
        .d3(din[(3*WIDTH)+k]),
        .d2(din[(2*WIDTH)+k]),
        .d1(din[(1*WIDTH)+k]),
        .d0(din[(0*WIDTH)+k]),
        .sel(sel[2:0]),
        .dout(dout[k]),
        .clk(clk)
       );
end
endgenerate

endmodule

module  alt_sel5t (
        input        clk,
	    input [2:0]  sel,
        input        d4, d3, d2, d1, d0, 
        output dout
);

wire [4:0]  do_0 = {d4,d3,d2,d1,d0};

alt_e100s10_mx5t1 i (
    .clk(clk),
    .din(do_0),
    .sel(sel),
    .dout(dout)
);

endmodule


// BENCHMARK INFO :  Uses helper file :  alt_mx5r1.v
