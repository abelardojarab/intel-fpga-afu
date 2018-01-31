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


`timescale 1ps / 1ps

// insert holes into the data stream as necessary to separate SOPs
// by at least 8 words

// data tags only appear in their corresponding position, and should cycle
// 32103210... with holes when working properly

module ectrl_frac_2_8 (
	input clk,
	input sclr,
    input ena,
	output req,
	input [1:0] pat,
	output reg [2*3-1:0] otag // 101,100 data   000 hole
);

localparam s_0         = 4'h0,
           s_1         = 4'h1,     
           s_2         = 4'h2,
           s_3         = 4'h3,
           s_4         = 4'h4,
           s_5         = 4'h5,
           s_6         = 4'h6,
           s_7         = 4'h7,
           s_8         = 4'h8,
           s_9         = 4'h9,
           s_a         = 4'ha;

localparam 
	o_da1_da0 = 6'b101_100,
	o_non_non = 6'b000_000,
	o_non_da0 = 6'b000_100,
	o_da1_non = 6'b101_000;
	
initial otag = o_non_non;
	
reg [3:0] hist = 0;
reg [3:0] st = s_0;

always @(posedge clk) begin
	if (sclr) begin
		hist <= 4'h0; 
		st   <= s_0;
		otag <= o_non_non;
	end
	else begin
        if (ena) begin
		case (st)
			s_0 : begin

				if (pat == 4'h0) begin
					if (hist == 4'h0) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h2; end
					if (hist == 4'h1) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h3; end
					if (hist == 4'h2) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h4; end
					if (hist == 4'h3) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h5; end
					if (hist == 4'h4) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h6; end
					if (hist == 4'h5) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h7; end
					if (hist == 4'h6) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h8; end
					if (hist == 4'h7) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h8; end
					if (hist == 4'h8) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h8; end
				end

				if (pat == 4'h1) begin
					if (hist == 4'h0) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h2; end
					if (hist == 4'h1) begin       otag <= o_non_non;       st <= s_2;       hist <= 4'h2; end
					if (hist == 4'h2) begin       otag <= o_non_non;       st <= s_2;       hist <= 4'h2; end
					if (hist == 4'h3) begin       otag <= o_non_non;       st <= s_2;       hist <= 4'h2; end
					if (hist == 4'h4) begin       otag <= o_non_non;       st <= s_2;       hist <= 4'h2; end
					if (hist == 4'h5) begin       otag <= o_non_non;       st <= s_3;       hist <= 4'h2; end
					if (hist == 4'h6) begin       otag <= o_non_non;       st <= s_3;       hist <= 4'h2; end
					if (hist == 4'h7) begin       otag <= o_non_non;       st <= s_4;       hist <= 4'h2; end
					if (hist == 4'h8) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h2; end
				end

				if (pat == 4'h2) begin
					if (hist == 4'h0) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h1; end
					if (hist == 4'h1) begin       otag <= o_non_da0;       st <= s_6;       hist <= 4'h1; end
					if (hist == 4'h2) begin       otag <= o_non_da0;       st <= s_8;       hist <= 4'h1; end
					if (hist == 4'h3) begin       otag <= o_non_da0;       st <= s_8;       hist <= 4'h1; end
					if (hist == 4'h4) begin       otag <= o_non_da0;       st <= s_8;       hist <= 4'h1; end
					if (hist == 4'h5) begin       otag <= o_non_da0;       st <= s_8;       hist <= 4'h1; end
					if (hist == 4'h6) begin       otag <= o_non_da0;       st <= s_9;       hist <= 4'h1; end
					if (hist == 4'h7) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h1; end
					if (hist == 4'h8) begin       otag <= o_da1_da0;       st <= s_0;       hist <= 4'h1; end
				end
			end
			s_1 :                     begin       otag <= o_non_non;       st <= s_2; end
			s_2 :                     begin       otag <= o_non_non;       st <= s_3; end
			s_3 :                     begin       otag <= o_non_non;       st <= s_4; end
			s_4 :                     begin       otag <= o_non_non;       st <= s_5; end
			s_5 :                     begin       otag <= o_da1_da0;       st <= s_0; end
			s_6 :                     begin       otag <= o_non_non;       st <= s_7; end
			s_7 :                     begin       otag <= o_non_non;       st <= s_8; end
			s_8 :                     begin       otag <= o_non_non;       st <= s_9; end
			s_9 :                     begin       otag <= o_non_non;       st <= s_a; end
			s_a :                     begin       otag <= o_da1_non;       st <= s_0; end
		endcase
		end
    end
end

assign req = (st == s_0) && ena;

endmodule
