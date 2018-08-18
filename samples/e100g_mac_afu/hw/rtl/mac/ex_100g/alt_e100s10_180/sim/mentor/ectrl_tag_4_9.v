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


// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/mac/ectrl_tag_4_9.v#2 $
// $Revision: #2 $
// $Date: 2013/06/06 $
// $Author: jilee $
//-----------------------------------------------------------------------------
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
// baeckler - 09-26-2012

module ectrl_tag_4_9 #(
	parameter EN_PREAMBLE_PASS_THROUGH = 1'b1,
	parameter WORDS = 4
)(
	input clk,
	input sclr,

        input  ena,	
	//output req,
	output [4:0] req, // S10TIM
	input [WORDS-1:0] i_sop, // lsbit first, sop marks the preamble word
	input [WORDS-1:0] i_eop,
	input [WORDS-1:0] i_idle,
	input [WORDS*3-1:0] i_eop_empty,
	output i_bus_error,
	
	output [WORDS*3-1:0] o_tags,
		// 111,110,101,100 data words
		// 000 idles
		// 001 padding
	output [WORDS-1:0] o_sop, // lsbit first
	output [WORDS-1:0] o_eop, // modified if necessary for padding
	output [WORDS*3-1:0] o_data_empty, // modified if necessary for padding	
	output [WORDS*3-1:0] o_eop_empty // modified if necessary for padding	
);

reg local_sclr;
always @(posedge clk) local_sclr <= sclr;

reg [WORDS-1:0] bus_error;
always @(posedge clk) begin 
    if (local_sclr) bus_error <= 0;
    else bus_error <= (i_sop & i_eop) | (i_sop & i_idle) | (i_eop & i_idle);
end
assign i_bus_error = |bus_error;

//////////////////////////////
// fracturing work horse

wire [WORDS*3-1:0] frac_tag;

generate
   if (EN_PREAMBLE_PASS_THROUGH) begin
      ectrl_frac_4_9 ef (
	.clk(clk),
	.sclr(local_sclr),
	.ena(ena),
	.req(req),
	.pat(i_sop),
	.otag(frac_tag) // 111,110,101,100 data   000 hole
      );
    end
    else begin
      ectrl_frac_4_8 ef (
	.clk(clk),
	.sclr(local_sclr),
	.ena(ena),
	.req(req),
	.pat(i_sop),
	.otag(frac_tag) // 111,110,101,100 data   000 hole
      );
   end
endgenerate

reg [WORDS-1:0] prev_sop; // lsbit first
reg [WORDS-1:0] prev_eop; // lsbit first
reg [WORDS-1:0] prev_idle; // lsbit first
reg [WORDS*3-1:0] prev_eop_empty; // lsbit first

always @(posedge clk) begin
	if (local_sclr) begin
		prev_sop <= {WORDS{1'b0}};
		prev_eop <= {WORDS{1'b0}};	
		prev_idle <= {WORDS{1'b0}};			
        prev_eop_empty <= {3*WORDS{1'b0}}; // lsbit first
	end
	else begin
		//if (req) prev_sop <= i_sop;	
		if (req[0]) prev_sop <= i_sop;	
		if (req[0]) prev_eop <= i_eop;	
		if (req[0]) prev_eop_empty <= i_eop_empty;	
		if (req[0]) prev_idle <= i_idle;	
	end
end

reg [WORDS-1:0] frac_tag_sop; // lsbit first
reg [WORDS-1:0] frac_tag_eop; // lsbit first
reg [3*WORDS-1:0] frac_tag_eop_empty; // lsbit first
reg [WORDS-1:0] frac_tag_hole; // lsbit first
reg [WORDS-1:0] frac_tag_hole_d; // lsbit first
reg [WORDS-1:0] frac_tag_eop_d; // lsbit first
reg [3*WORDS-1:0] frac_tag_eop_empty_d; // lsbit first
reg [WORDS-1:0] frac_tag_sop_d; // lsbit first
reg [WORDS-1:0] frac_tag_sop_d2; // lsbit first
reg [WORDS*3-1:0] frac_tag_r;
reg [WORDS*3-1:0] frac_tag_d;

always @(posedge clk) begin
    if (sclr) begin
	frac_tag_sop <= 0;
	frac_tag_eop <= 0;
	frac_tag_eop_empty[11:9] <= 0;
	frac_tag_eop_empty[ 8:6] <= 0;
	frac_tag_eop_empty[ 5:3] <= 0;
	frac_tag_eop_empty[ 2:0] <= 0;
	frac_tag_hole <= 0;
	frac_tag_r <= 0;
		
	frac_tag_hole_d <= 0;
	frac_tag_sop_d <= 0;
	frac_tag_eop_d <= 0;
	frac_tag_eop_empty_d <= 0;
	frac_tag_d <= 0;
	
	frac_tag_sop_d2 <= 0;
   end
    else if (ena) begin
	frac_tag_sop <= prev_sop & {frac_tag[11],frac_tag[8],frac_tag[5],frac_tag[2]};	
	frac_tag_eop <= prev_eop & {frac_tag[11],frac_tag[8],frac_tag[5],frac_tag[2]};		
	frac_tag_eop_empty[11:9] <= prev_eop_empty[11:9] & {3{frac_tag[11]}};		
	frac_tag_eop_empty[ 8:6] <= prev_eop_empty[ 8:6] & {3{frac_tag[8]}};		
	frac_tag_eop_empty[ 5:3] <= prev_eop_empty[ 5:3] & {3{frac_tag[5]}};		
	frac_tag_eop_empty[ 2:0] <= prev_eop_empty[ 2:0] & {3{frac_tag[2]}};		
	frac_tag_hole <= prev_idle | ~{frac_tag[11],frac_tag[8],frac_tag[5],frac_tag[2]};		
	frac_tag_r <= frac_tag;
		
	frac_tag_hole_d <= frac_tag_hole;
	frac_tag_sop_d <= frac_tag_sop;
	frac_tag_eop_d <= frac_tag_eop;
	frac_tag_eop_empty_d <= frac_tag_eop_empty;
	frac_tag_d <= frac_tag_r;
	
	frac_tag_sop_d2 <= frac_tag_sop_d;
   end
end

///////////////////////////////////////
// 8 words from start, eop forbidden

wire [3*WORDS-1:0] sop_hist = {frac_tag_sop,frac_tag_sop_d,frac_tag_sop_d2};

wire [WORDS-1:0] no_eop;
assign no_eop[3] = EN_PREAMBLE_PASS_THROUGH ? |sop_hist[10:4] : |sop_hist[10:5];
assign no_eop[2] = EN_PREAMBLE_PASS_THROUGH ? |sop_hist[9:3]  : |sop_hist[9:4];
assign no_eop[1] = EN_PREAMBLE_PASS_THROUGH ? |sop_hist[8:2]  : |sop_hist[8:3];
assign no_eop[0] = EN_PREAMBLE_PASS_THROUGH ? |sop_hist[7:1]  : |sop_hist[7:2];

reg [WORDS-1:0] no_eop_d = {WORDS{1'b0}};
always @(posedge clk) 
    if (sclr) no_eop_d <= 0;
    else if (ena) no_eop_d <= no_eop;

///////////////////////////////////////
// 9th word, end of short packet

wire [WORDS-1:0] short_end;
assign short_end[3] = EN_PREAMBLE_PASS_THROUGH ? sop_hist[3] : sop_hist[4];
assign short_end[2] = EN_PREAMBLE_PASS_THROUGH ? sop_hist[2] : sop_hist[3];
assign short_end[1] = EN_PREAMBLE_PASS_THROUGH ? sop_hist[1] : sop_hist[2];
assign short_end[0] = EN_PREAMBLE_PASS_THROUGH ? sop_hist[0] : sop_hist[1];

reg [WORDS-1:0] short_end_d = {WORDS{1'b0}};
always @(posedge clk) 
    if (sclr) short_end_d <= 0;
    else if (ena) short_end_d <= short_end;

///////////////////////////////////////
// create missing EOPs for extended packets

reg [WORDS-1:0] padded_eop_d = {WORDS{1'b0}};
reg [WORDS-1:0] short_end_eop_d = {WORDS{1'b0}};
always @(posedge clk) begin
    if (sclr) begin
	    padded_eop_d <= 0;
        short_end_eop_d <= 0;
    end
    else if (ena) begin
	    padded_eop_d <= short_end & frac_tag_hole;
        short_end_eop_d <= short_end & frac_tag_eop;
    end
end

reg [3*WORDS-1:0] tags_d2;
always @(posedge clk) begin
    if (sclr) tags_d2 <= 0;
    else if (ena) begin
	tags_d2[11:9] <=((no_eop_d[3] | short_end_d[3]) & frac_tag_hole_d[3]) ? 3'b001 :
					frac_tag_hole_d[3] ? 3'b000 :
					frac_tag_d[11:9];
	tags_d2[8:6] <=((no_eop_d[2] | short_end_d[2]) & frac_tag_hole_d[2]) ? 3'b001 :
					frac_tag_hole_d[2] ? 3'b000 :
					frac_tag_d[8:6];
	tags_d2[5:3] <=((no_eop_d[1] | short_end_d[1]) & frac_tag_hole_d[1]) ? 3'b001 :
					frac_tag_hole_d[1] ? 3'b000 :
					frac_tag_d[5:3];
	tags_d2[2:0] <=((no_eop_d[0] | short_end_d[0]) & frac_tag_hole_d[0]) ? 3'b001 :
					frac_tag_hole_d[0] ? 3'b000 :
					frac_tag_d[2:0];	
    end
end

reg [WORDS-1:0] frac_tag_eop_d2; 
reg [3*WORDS-1:0] frac_tag_eop_empty_d2; 
reg [3*WORDS-1:0] frac_tag_data_empty_d2; 
always @(posedge clk) begin
    if (sclr) begin
	frac_tag_eop_d2 <= 0;
	frac_tag_eop_empty_d2[11:9]  <= 0;
	frac_tag_eop_empty_d2[ 8:6]  <= 0;
	frac_tag_eop_empty_d2[ 5:3]  <= 0;
	frac_tag_eop_empty_d2[ 2:0]  <= 0;

	frac_tag_data_empty_d2[11:9] <= 0;
	frac_tag_data_empty_d2[ 8:6] <= 0;
	frac_tag_data_empty_d2[ 5:3] <= 0;
	frac_tag_data_empty_d2[ 2:0] <= 0;
    end
    else if (ena) begin
	frac_tag_eop_d2 <= (frac_tag_eop_d & ~no_eop_d) | padded_eop_d;
	frac_tag_eop_empty_d2[11:9]  <= (padded_eop_d[3] || (short_end_eop_d[3] && frac_tag_eop_empty_d[11])) ? 3'h4 : frac_tag_eop_empty_d[11:9];
	frac_tag_eop_empty_d2[ 8:6]  <= (padded_eop_d[2] || (short_end_eop_d[2] && frac_tag_eop_empty_d[ 8])) ? 3'h4 : frac_tag_eop_empty_d[ 8:6];
	frac_tag_eop_empty_d2[ 5:3]  <= (padded_eop_d[1] || (short_end_eop_d[1] && frac_tag_eop_empty_d[ 5])) ? 3'h4 : frac_tag_eop_empty_d[ 5:3];
	frac_tag_eop_empty_d2[ 2:0]  <= (padded_eop_d[0] || (short_end_eop_d[0] && frac_tag_eop_empty_d[ 2])) ? 3'h4 : frac_tag_eop_empty_d[ 2:0];

	frac_tag_data_empty_d2[11:9] <= frac_tag_eop_empty_d[11:9];
	frac_tag_data_empty_d2[ 8:6] <= frac_tag_eop_empty_d[ 8:6];
	frac_tag_data_empty_d2[ 5:3] <= frac_tag_eop_empty_d[ 5:3];
	frac_tag_data_empty_d2[ 2:0] <= frac_tag_eop_empty_d[ 2:0];
    end
end

assign o_eop_empty = frac_tag_eop_empty_d2;
assign o_data_empty = frac_tag_data_empty_d2;
assign o_eop = frac_tag_eop_d2;
assign o_sop = frac_tag_sop_d2;
assign o_tags = tags_d2;


////////////////////////////
// Sanity check
////////////////////////////

//synthesis translate_off
reg [15:0] sop_history;

always @(posedge clk) begin
   if (ena) begin
      sop_history <= {sop_history << 4, o_sop};
   end
   if ((sop_history[3] && |(sop_history[11:4])) || 
       (sop_history[2] && |(sop_history[10:3])) || 
       (sop_history[1] && |(sop_history[ 9:2])) || 
       (sop_history[0] && |(sop_history[ 8:1]))) begin
            $display("%t: SOPs are less than 9 words apart", $time);
            $stop;
   end
end
// synthesis translate_on

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  4.0 LUTs
// BENCHMARK INFO :  Total registers : 110
// BENCHMARK INFO :  Total pins : 61
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.761 ns, From local_sclr, To ectrl_frac_4:ef|hist.0110}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.712 ns, From ectrl_frac_4:ef|hist.0111, To ectrl_frac_4:ef|otag[7]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.803 ns, From ectrl_frac_4:ef|hist.0010, To ectrl_frac_4:ef|otag[3]}
