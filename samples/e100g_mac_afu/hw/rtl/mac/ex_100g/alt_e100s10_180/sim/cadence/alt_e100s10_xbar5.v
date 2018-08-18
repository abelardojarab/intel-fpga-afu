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

module alt_e100s10_xbar5 #(
	parameter WIDTH = 66
)(
	input clk,
	input [5*3-1:0] sel,
	input [5*WIDTH-1:0] din,
	output [5*WIDTH-1:0] dout	
);

genvar i;
generate
	for (i=0; i<5; i=i+1) begin : lp
		alt_e100s10_mx5r m (
			.clk(clk),
			.din(din),
			.dout(dout[(i+1)*WIDTH-1:i*WIDTH]),
			.sel(sel[(i+1)*3-1:i*3])
		);	
		defparam m .WIDTH = WIDTH; 	
	end
endgenerate

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 330
// BENCHMARK INFO :  Total pins : 676
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 331             ;       ;
// BENCHMARK INFO :  ALMs : 457 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
