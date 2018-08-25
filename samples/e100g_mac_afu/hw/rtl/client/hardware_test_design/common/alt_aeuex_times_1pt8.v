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


`timescale 1ps/1ps

// baeckler - 05-02-2014
// DESCRIPTION
// Multiply by 461 / 256 

module alt_aeuex_times_1pt8 #(
	parameter WIDTH = 8
)(
	input clk,
	input [WIDTH-1:0] din,
	output [WIDTH-1:0] dout
);

reg [WIDTH+8-1:0] scratch = {(WIDTH+8){1'b0}};

reg [WIDTH+1-1:0] p0 = {(WIDTH+1){1'b0}};
reg [WIDTH+3-1:0] p1 = {(WIDTH+3){1'b0}};
reg [WIDTH+2-1:0] p2 = {(WIDTH+2){1'b0}};

always @(posedge clk) begin
	p0 <= {din,1'b0} + din; // 256,128
	p1 <= {din,3'b0} + din; // 64 8
	p2 <= {din,2'b0} + din; // 4 1
	scratch <= {p0,7'b0} + {p1,3'b0} + p2;
end

assign dout = scratch[WIDTH+8-1:8];

endmodule
// BENCHMARK INFO :  10AX115R3F40I2SGES
// BENCHMARK INFO :  Quartus II 64-Bit Version 14.0a10.0 Build 323 04/29/2014 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  alt_aeuex_times_1pt8.v
// BENCHMARK INFO :  Max depth :  2.2 LUTs
// BENCHMARK INFO :  Total registers : 34
// BENCHMARK INFO :  Total pins : 17
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  37                 
// BENCHMARK INFO :  ALMs : 19 / 427,200 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.860 ns, From p1[6], To scratch[15]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.875 ns, From p2[3], To scratch[15]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.774 ns, From p2[3], To scratch[15]}
