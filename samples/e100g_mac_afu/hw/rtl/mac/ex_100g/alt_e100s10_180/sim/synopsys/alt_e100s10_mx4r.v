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
// registered 4:1 MUX

module alt_e100s10_mx4r #(
	parameter WIDTH = 32
)(
	input clk,
	input [4*WIDTH-1:0] din,
	input [1:0] sel,
	output [WIDTH-1:0] dout
);

reg [WIDTH-1:0] dout_r = {WIDTH{1'b0}} /* synthesis preserve_syn_only */;
reg [WIDTH-1:0] dout_w /* synthesis keep */;

assign dout = dout_r;

always @(*) begin
	case (sel) 
		2'b00 : dout_w = din[WIDTH-1:0];
		2'b01 : dout_w = din[(WIDTH*2)-1:WIDTH];
		2'b10 : dout_w = din[(WIDTH*3)-1:(WIDTH*2)];
		2'b11 : dout_w = din[(WIDTH*4)-1:(WIDTH*3)];		
	endcase
end

always @(posedge clk) dout_r <= dout_w;

endmodule

// BENCHMARK INFO :  5SGXMBBR2SH40I3
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 32
// BENCHMARK INFO :  Total pins : 163
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                           ; 33              ;       ;
// BENCHMARK INFO :  ALMs : 36 / 359,200 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From clk~inputCLKENA0FMAX_CAP_FF0, To clk~inputCLKENA0FMAX_CAP_FF1}
