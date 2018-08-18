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


// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/ast/alt_e100s10_wide_compact_words_4.v#1 $
// $Revision: #1 $
// $Date: 2013/02/27 $
// $Author: pscheidt $
//-----------------------------------------------------------------------------
// baeckler - 05-04-2009
// pull valid words, bit masked in any postion, together
// toward the more significant end with a count.

`timescale 1 ps / 1 ps

module alt_e100s10_wide_compact_words_4 #(
	parameter WORDS = 4,
	parameter WORD_LEN = 64	
)
(
	input clk, srst,

	input [WORDS-1:0] din_valid_mask, // MSbit = MS word is used
	input [WORDS*WORD_LEN-1:0] din_words,
	
	// packed toward more significant end
	output [WORDS*WORD_LEN-1:0] dout_words,
	output [3:0] num_dout_words_valid	
);

//wire srst;
//alt_e100s10_sync_arst sync_arst (clk, arst, srst); // S10TIM: sync rst


reg [WORDS*WORD_LEN-1:0] din_words_r;

// word numbering {0..3}, msb to lsb
wire [WORDS-1:0] din_word_valid;
genvar i;
generate
	for (i=0; i<WORDS; i=i+1) begin : vm
		assign din_word_valid[i] = din_valid_mask [WORDS-1-i];
	end	
endgenerate

reg [3:0] num_valid;
wire [2:0] valids_before4_w;
alt_e100s10_wide_six_three_comp sc1 (.data({2'b00,din_word_valid[3:0]}),.sum(valids_before4_w));

always @(posedge clk) begin
	if (srst) begin
		num_valid <= 0;
		din_words_r <= 0;
	end
	else begin
		num_valid <= valids_before4_w;
		din_words_r <= din_words;
	end	
end

// figure out which din word if any drives output page
reg valids_before1;		  // 0..1
reg [1:0] valids_before2; // 0..2
reg [1:0] valids_before3; // 0..3

always @(posedge clk) begin
	if (srst) begin
		valids_before1 <= 0;
		valids_before2 <= 0;
		valids_before3 <= 0;
	end
	else begin
		valids_before1 <= din_word_valid[0];
		valids_before2 <= {din_word_valid[1] & din_word_valid[0], din_word_valid[1] ^ din_word_valid[0]};
		valids_before3 <= valids_before4_w[1:0] - (din_word_valid[3] ? 1'b1 : 1'b0); // originally 3 -> 2 bits
	end	
end

///////////////////////////////////////
// layer 2 - mux valid words into an adjacent group
///////////////////////////////////////

wire [WORD_LEN-1:0] din_r_0, din_r_1, din_r_2, din_r_3;
			
assign {din_r_0, din_r_1, din_r_2, din_r_3} = din_words_r;
			
reg [WORD_LEN-1:0] outword0, outword1, outword2, outword3; 

reg [3:0] last_num_valid;

always @(posedge clk) begin
	if (srst) begin
		outword0 <= 0;
		outword1 <= 0;
		outword2 <= 0;
		outword3 <= 0;
		last_num_valid <= 0;
	end
	else begin
		last_num_valid <= num_valid;
		outword0 <= (valids_before3 == 2'b00) ? din_r_3 :
                            (valids_before2 == 2'b00) ? din_r_2 :
                            (valids_before1 == 1'b0)  ? din_r_1 : din_r_0;
		outword1 <= (valids_before3 == 2'b01) ? din_r_3 :
                            (valids_before2 == 2'b01) ? din_r_2 : din_r_1;
		outword2 <= (valids_before3 == 2'b10) ? din_r_3 : din_r_2;
		outword3 <= din_r_3;					
	end
end

assign dout_words = {outword0, outword1, outword2, outword3};

assign num_dout_words_valid = last_num_valid;

endmodule
