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

module alt_e100s10_clos20 #(
	parameter WIDTH = 16
)(
	input clk,
	input [4*2*5+5*3*4+4*2*5-1:0] sels,
	input [20*WIDTH-1:0] din,
	output [20*WIDTH-1:0] dout	
);

wire [WIDTH*20-1:0] x0,x0p,x1,x1p;
wire [4*2*5-1:0] sel0,sel2;
wire [5*3*4-1:0] sel1;
assign {sel2,sel1,sel0} = sels;

//////////////////////////////
// 4x4 layer - five copies

genvar i;
generate
	for (i=0;i<5;i=i+1) begin : lp0
		alt_e100s10_xbar4 xb0 (
			.clk(clk),
			.sel(sel0[(i+1)*2*4-1:i*2*4]),
			.din(din[(i+1)*4*WIDTH-1:i*4*WIDTH]),
			.dout(x0[(i+1)*4*WIDTH-1:i*4*WIDTH])
		);
		defparam xb0 .WIDTH = WIDTH;
	end
endgenerate

//////////////////////////////
// perm

alt_e100s10_clos20_perm cp (
	.din(x0),
	.dout(x0p)	
);
defparam cp .WIDTH = 20*WIDTH;

//////////////////////////////
// 5x5 layer - four copies

generate
	for (i=0;i<4;i=i+1) begin : lp1
		alt_e100s10_xbar5 xb1 (
			.clk(clk),
			.sel(sel1[(i+1)*3*5-1:i*3*5]),
			.din(x0p[(i+1)*5*WIDTH-1:i*5*WIDTH]),
			.dout(x1[(i+1)*5*WIDTH-1:i*5*WIDTH])
		);
		defparam xb1 .WIDTH = WIDTH;
	end
endgenerate

//////////////////////////////
// perm

alt_e100s10_clos20_unperm cup (
	.din(x1),
	.dout(x1p)	
);
defparam cup .WIDTH = 20*WIDTH;

//////////////////////////////
// 4x4 layer - five copies

generate
	for (i=0;i<5;i=i+1) begin : lp2
		alt_e100s10_xbar4 xb2 (
			.clk(clk),
			.sel(sel2[(i+1)*2*4-1:i*2*4]),
			.din(x1p[(i+1)*4*WIDTH-1:i*4*WIDTH]),
			.dout(dout[(i+1)*4*WIDTH-1:i*4*WIDTH])
		);
		defparam xb2 .WIDTH = WIDTH;
	end
endgenerate


endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 960
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 960
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.669 ns, From xbar_4:lp0[4].xb0|mx4r:lp[3].m|dout_r[1], To xbar_5:lp1[3].xb1|mx5r:lp[2].m|dout_r[1]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.586 ns, From xbar_4:lp0[4].xb0|mx4r:lp[1].m|dout_r[7], To xbar_5:lp1[1].xb1|mx5r:lp[1].m|dout_r[7]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.737 ns, From xbar_4:lp0[4].xb0|mx4r:lp[0].m|dout_r[2], To xbar_5:lp1[0].xb1|mx5r:lp[3].m|dout_r[2]}
