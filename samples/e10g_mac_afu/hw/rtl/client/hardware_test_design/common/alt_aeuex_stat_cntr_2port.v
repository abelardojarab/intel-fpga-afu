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


// Copyright 2010 Altera Corporation. All rights reserved.  
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
// baeckler - 07-27-2010
// counter with 2 increment ports

module alt_aeuex_stat_cntr_2port # (
	parameter WIDTH = 32
)(
	input clk, 
	input ena,
	input sclr,
	input [1:0] inc,
	output [WIDTH-1:0] cntr
);

reg [WIDTH/2:0] cume_lower = {(WIDTH/2+1){1'b0}} /* synthesis preserve_syn_only */;
reg [WIDTH/2-1:0] cume_upper = {(WIDTH/2){1'b0}} /* synthesis preserve_syn_only */;
reg [WIDTH/2-1:0] cume_lower_d = {(WIDTH/2){1'b0}} /* synthesis preserve_syn_only */;

always @(posedge clk) begin
   if (ena) begin
        if (sclr) begin
                cume_lower <= {(WIDTH/2+1){1'b0}};
                cume_lower_d <= {(WIDTH/2){1'b0}};
                cume_upper <= {(WIDTH/2){1'b0}};
        end
        else begin
                cume_lower <= {1'b0,cume_lower[WIDTH/2-1:0]} + {inc[1]&inc[0],inc[1]^inc[0]};
                cume_lower_d <= cume_lower[WIDTH/2-1:0];
                cume_upper <= cume_upper + cume_lower[WIDTH/2];
        end
   end
end

assign cntr = {cume_upper, cume_lower_d};

/*
initial cntr = 0;

//always @(posedge clk) begin
always @(posedge clk) begin
	if (ena) begin
		if (sclr) begin
			cntr <= 0;
		end
		else begin
			cntr <= cntr + {inc[1]&inc[0],inc[1]^inc[0]};
		end 
	end
end
*/
endmodule
