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
// baeckler - 08-21-2012

module alt_e100s10_refram #(
	parameter WORDS = 4	
)(
	input [64*WORDS-1:0] din_data,
	input [2*WORDS-1:0] din_frame,
	output [66*WORDS-1:0] dout	
);

genvar i;
generate
	for (i=0; i<WORDS; i=i+1) begin : lp
		// merge the framing and data bits
		assign 
             dout[(i+1)*66-1:i*66] = {din_data[(i+1)*64-1:i*64],
									din_frame[(i+1)*2-1:i*2]};
    end
endgenerate	

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  0.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 0
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 0
// BENCHMARK INFO :  Total block memory bits : 0
