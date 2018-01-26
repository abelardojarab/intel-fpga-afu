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
// ______________________________________________________________________________
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/mac/ectrl_frac_2.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
// ______________________________________________________________________________


`timescale 1ps / 1ps

// insert holes into the data stream as necessary to separate SOPs
// by at least 9 words, to make room for 8 word packet, 1 gap, 1 preamble 

// data tags only appear in their corresponding position, and should cycle
// 32103210... with holes when working properly

module ectrl_frac_2 (
	input clk,
	input sclr,
        input ena,
	output req,
	input [1:0] pat,
	output reg [2*3-1:0] otag // 101,100 data   000 hole
);

localparam s_base       = 4'h0,
           s_g_g_g_g_01 = 4'h1,     
           s_g_g_g_01   = 4'h2,
           s_g_g_01     = 4'h3,
           s_g_01       = 4'h4,
           s_01         = 4'h5,
           s_g_g_g_g_g1 = 4'h6,
           s_g_g_g_g1   = 4'h7,
           s_g_g_g1     = 4'h8,
           s_g_g1       = 4'h9,
           s_g1         = 4'ha;

localparam 
	o_01 = 6'b101_100,
	o_g  = 6'b000_000,
	o_0g = 6'b000_100,
	o_g1 = 6'b101_000;
	
initial otag = o_g;
	
reg [3:0] hist = 0;
reg [3:0] st = s_base;

always @(posedge clk) begin
	if (sclr) begin
		hist <= 4'h0; 
		st <= s_base;
		otag <= o_g;
	end
	else begin
           if (ena) begin
		case (st)
			s_base : begin

				if (pat == 4'h0) begin
					if (hist == 4'h0) begin otag <= o_01; st <= s_base; hist <= 4'h2; end
					if (hist == 4'h1) begin otag <= o_01; st <= s_base; hist <= 4'h3; end
					if (hist == 4'h2) begin otag <= o_01; st <= s_base; hist <= 4'h4; end
					if (hist == 4'h3) begin otag <= o_01; st <= s_base; hist <= 4'h5; end
					if (hist == 4'h4) begin otag <= o_01; st <= s_base; hist <= 4'h6; end
					if (hist == 4'h5) begin otag <= o_01; st <= s_base; hist <= 4'h7; end
					if (hist == 4'h6) begin otag <= o_01; st <= s_base; hist <= 4'h8; end
					if (hist == 4'h7) begin otag <= o_01; st <= s_base; hist <= 4'h9; end
					if (hist == 4'h8) begin otag <= o_01; st <= s_base; hist <= 4'h9; end
					if (hist == 4'h9) begin otag <= o_01; st <= s_base; hist <= 4'h9; end
				end

				if (pat == 4'h1) begin
					if (hist == 4'h0) begin otag <= o_01; st <= s_base;       hist <= 4'h2; end
					if (hist == 4'h1) begin otag <= o_g;  st <= s_g_g_g_g_01; hist <= 4'h2; end
					if (hist == 4'h2) begin otag <= o_g;  st <= s_g_g_g_g_01; hist <= 4'h2; end
					if (hist == 4'h3) begin otag <= o_g;  st <= s_g_g_g_01;   hist <= 4'h2; end
					if (hist == 4'h4) begin otag <= o_g;  st <= s_g_g_g_01;   hist <= 4'h2; end
					if (hist == 4'h5) begin otag <= o_g;  st <= s_g_g_01;     hist <= 4'h2; end
					if (hist == 4'h6) begin otag <= o_g;  st <= s_g_g_01;     hist <= 4'h2; end
					if (hist == 4'h7) begin otag <= o_g;  st <= s_g_01;       hist <= 4'h2; end
					if (hist == 4'h8) begin otag <= o_g;  st <= s_g_01;       hist <= 4'h2; end
					if (hist == 4'h9) begin otag <= o_01; st <= s_base;       hist <= 4'h2; end
				end

				if (pat == 4'h2) begin
					if (hist == 4'h0) begin otag <= o_01; st <= s_base;       hist <= 4'h1; end
					if (hist == 4'h1) begin otag <= o_0g; st <= s_g_g_g_g_g1; hist <= 4'h1; end
					if (hist == 4'h2) begin otag <= o_0g; st <= s_g_g_g_g1;   hist <= 4'h1; end
					if (hist == 4'h3) begin otag <= o_0g; st <= s_g_g_g1;     hist <= 4'h1; end
					if (hist == 4'h4) begin otag <= o_0g; st <= s_g_g_g1;     hist <= 4'h1; end
					if (hist == 4'h5) begin otag <= o_0g; st <= s_g_g_g1;     hist <= 4'h1; end
					if (hist == 4'h6) begin otag <= o_0g; st <= s_g_g1;       hist <= 4'h1; end
					if (hist == 4'h7) begin otag <= o_0g; st <= s_g1;         hist <= 4'h1; end
					if (hist == 4'h8) begin otag <= o_01; st <= s_base;       hist <= 4'h1; end
					if (hist == 4'h9) begin otag <= o_01; st <= s_base;       hist <= 4'h1; end
				end
			end
			s_g_g_g_g_01 :      begin  otag <= o_g;  st <= s_g_g_g_01; end
			s_g_g_g_01 :        begin  otag <= o_g;  st <= s_g_g_01; end
			s_g_g_01 :          begin  otag <= o_g;  st <= s_g_01; end
			s_g_01 :            begin  otag <= o_g;  st <= s_01; end
			s_01 :              begin  otag <= o_01; st <= s_base; end
			s_g_g_g_g_g1 :      begin  otag <= o_g;  st <= s_g_g_g_g1; end
			s_g_g_g_g1 :        begin  otag <= o_g;  st <= s_g_g_g1; end
			s_g_g_g1 :          begin  otag <= o_g;  st <= s_g_g1; end
			s_g_g1 :            begin  otag <= o_g;  st <= s_g1; end
			s_g1 :              begin  otag <= o_g1; st <= s_base; end
		endcase
		end
           end
end

assign req = (st == s_base) && ena;

endmodule
