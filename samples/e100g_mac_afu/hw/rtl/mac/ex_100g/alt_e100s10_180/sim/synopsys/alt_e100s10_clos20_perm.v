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

// baeckler - 08-26-2012

module alt_e100s10_clos20_perm #(
	parameter WIDTH = 320
)(
	input [WIDTH-1:0] din,
	output [WIDTH-1:0] dout	
);

localparam WORD_WIDTH = WIDTH / 20;

wire [WORD_WIDTH-1:0] w0,w1,w2,w3, w4,w5,w6,w7, w8,w9,wa,wb, wc,wd,we,wf, wg,wh,wi,wj;
assign {w0,w1,w2,w3, w4,w5,w6,w7, w8,w9,wa,wb, wc,wd,we,wf, wg,wh,wi,wj} = din;


assign dout =
	{w0,w4,w8,wc,wg, w1,w5,w9,wd,wh, w2,w6,wa,we,wi, w3,w7,wb,wf,wj};


endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  0.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 0
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 0
// BENCHMARK INFO :  Total block memory bits : 0
