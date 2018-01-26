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
module alt_aeu_40_align_40 (
	input clk,
	input [5:0] pos,
	input din_valid,
	input [39:0] din,	// lsbit first
	output reg [39:0] dout  // lsbit first
);

initial dout = 0;
reg [40+39-1:0] mid = 0;

always @(posedge clk) begin
	if (din_valid) begin
		case (pos[5:3]) 
			3'b000 : mid <= {din,mid[78:40]};
			3'b001 : mid <= {8'b0,din,mid[70:40]};
			3'b010 : mid <= {16'h0,din,mid[62:40]};
			3'b011 : mid <= {24'h0,din,mid[54:40]};
			3'b100 : mid <= {32'h0,din,mid[46:40]};
			default: mid <= {32'h0,din,mid[46:40]};
		endcase		
	end
end

always @(posedge clk) begin
	case (pos[2:0]) 
		3'b000 : dout <= mid[39:0];
		3'b001 : dout <= mid[40:1];
		3'b010 : dout <= mid[41:2];
		3'b011 : dout <= mid[42:3];
		3'b100 : dout <= mid[43:4];
		3'b101 : dout <= mid[44:5];
		3'b110 : dout <= mid[45:6];
		3'b111 : dout <= mid[46:7];
	endcase		
end

endmodule
