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

// 01-15-2012
// compare two 18 bit values - 2 ticks

// DESCRIPTION
// 
// This is a pipelined equality comparator of two 18 bit busses. It has a latency of two and a LUT depth of
// one. The decomposition is six copies of eq_3 combined.
// 
// Figure : eq_18 structure
// <image alt_eq_18.v.img0.png>
// 
//  
// 



// CONFIDENCE
// This is a small equality circuit.  Any problems should be easily spotted in simulation.
// 

module alt_e100s10_eq18t2 (
	input clk,
	input [17:0] din_a,
	input [17:0] din_b,
	output reg match
);

reg [5:0] cmp3 = 6'b0;

genvar i;
generate 
for (i=0; i<6; i=i+1) begin :lp
	wire eq_w;
	alt_e100s10_eq3t0 eq (
		.dina(din_a[(i+1)*3-1:i*3]),
		.dinb(din_b[(i+1)*3-1:i*3]),
		.dout(eq_w)
	);
	
	always @(posedge clk) begin
		cmp3[i] <= eq_w;
	end
end
endgenerate

initial match = 1'b0;
always @(posedge clk) begin
	match <= &cmp3;
end

endmodule


// BENCHMARK INFO :  10AX115U2F45I2SGE2
// BENCHMARK INFO :  Quartus II 64-Bit Version 15.1.0 Internal Build 58 04/28/2015 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  alt_eq_18.v
// BENCHMARK INFO :  Uses helper file :  alt_eq_3.v
// BENCHMARK INFO :  Uses helper file :  alt_wys_lut.v
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 7
// BENCHMARK INFO :  Total pins : 38
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  7                  
// BENCHMARK INFO :  ALMs : 7 / 427,200 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.360 ns, From match~reg0, To match}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.373 ns, From match~reg0, To match}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.237 ns, From match~reg0, To match}
