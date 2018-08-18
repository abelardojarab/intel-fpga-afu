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

// baeckler - 01-14-2012
// five registered 4:1 MUX stacked to build 16:1

// DESCRIPTION
// 
// This is a registered 16:1 bus MUX composed from four copies of mx4r. It has a latency of 2 cycles and a
// LUT depth of one.
// 



// CONFIDENCE
// This muxing component has very little state.  Problems should be clearly visible in simulation.
// 

module alt_e100s10_mx16r #(
	parameter WIDTH = 16
)(
	input clk,
	input [16*WIDTH-1:0] din,
	input [3:0] sel,
	output [WIDTH-1:0] dout
);

wire [4*WIDTH-1:0] mid_dout;

genvar i;
generate
for (i=0; i<4; i=i+1) begin : lp
	alt_e100s10_mx4r m (
		.clk(clk),
		.din(din[(i+1)*4*WIDTH-1:i*4*WIDTH]),
		.sel(sel[1:0]),
		.dout(mid_dout[(i+1)*WIDTH-1:i*WIDTH])
	);
	defparam m .WIDTH = WIDTH;
end
endgenerate

reg [1:0] mid_sel = 2'b0 /* synthesis preserve_syn_only */;
always @(posedge clk) mid_sel <= sel[3:2];

alt_e100s10_mx4r m (
	.clk(clk),
	.din(mid_dout),
	.sel(mid_sel),
	.dout(dout)
);
defparam m .WIDTH = WIDTH;

endmodule

// BENCHMARK INFO :  10AX115R3F40I2SGES
// BENCHMARK INFO :  Quartus II 64-Bit Version 14.0.0 Internal Build 145 02/20/2014 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  alt_mx16r.v
// BENCHMARK INFO :  Uses helper file :  alt_mx4r.v
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 82
// BENCHMARK INFO :  Total pins : 277
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  81                 
// BENCHMARK INFO :  ALMs : 81 / 427,200 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.020 ns, From mid_sel[1], To alt_mx4r:m|dout_r[4]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.994 ns, From mid_sel[1], To alt_mx4r:m|dout_r[4]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.655 ns, From mid_sel[1], To alt_mx4r:m|dout_r[10]}
