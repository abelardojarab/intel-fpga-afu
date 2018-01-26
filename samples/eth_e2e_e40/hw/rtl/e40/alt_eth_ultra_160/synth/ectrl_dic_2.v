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
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/mac/ectrl_dic_2.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
// ______________________________________________________________________________


`timescale 1 ps / 1 ps

module ectrl_dic_2 #(
        parameter WORDS = 2,
	parameter SYNOPT_AVG_IPG = 12
)(
        input clk,
        input sclr,

        input [7:0] num_idle_rm,
        input tx_crc_ins_en,
        input i_am,
        input i_ena,
        input [WORDS-1:0] i_sop, // lsbit first, sop marks the preamble word
        input [WORDS-1:0] i_eop,
        input [WORDS*3-1:0] i_eop_empty,
        input [WORDS*3-1:0] i_data_empty,
        input [WORDS*3-1:0] i_tags,

        output o_wait_req,
        output [WORDS*3-1:0] o_tags,
                // 111,110,101,100 data words
                // 000 idles
                // 001 padding
        output [WORDS-1:0] o_sop, // lsbit first
        output [WORDS-1:0] o_eop, 
        output [WORDS*3-1:0] o_eop_empty, 
        output [WORDS*3-1:0] o_data_empty
);

reg         dic_req0, dic_req1;

wire [2:0] partial;
reg [4:0] gap_cnt;
reg [4:0] short;
reg [4:0] short_no_crc;
reg [2:0] dic;
reg [2:0] next_dic;
reg       next_dic_req;
reg       dic_req;
reg       dic_req_unblocked;
reg [5:0] short_plus_dic;
reg [WORDS-1:0] eop_r;
reg [WORDS-1:0] eop_r2;
reg [WORDS-1:0] sop_r;
reg [3*WORDS-1:0] tags_r;
reg [3*WORDS-1:0] eop_empty_r;
reg [3*WORDS-1:0] eop_empty_r2;
reg [3*WORDS-1:0] data_empty_r;

always @(posedge clk) begin
   if (i_ena && !o_wait_req) begin
       sop_r <= i_sop;
       eop_r <= i_eop;
       eop_empty_r <= i_eop_empty;
       data_empty_r <= i_data_empty;
       tags_r <= i_tags;
       eop_r2 <= eop_r;
       eop_empty_r2 <= eop_empty_r;
   end
end

// this is after padding. So no (sop,eop,sop,eop) type of case
assign partial = ({3{eop_r2[1]}} & eop_empty_r2[5:3]) | 
                 ({3{eop_r[0]}} & eop_empty_r[ 2:0]) | 
                 ({3{eop_r[1]}} & eop_empty_r[ 5:3]) | 
                 ({3{i_eop[0]}} & i_eop_empty[ 2:0]) | 
                 ({3{i_eop[1]}} & i_eop_empty[ 5:3]);

/*
// This is for AVG_IPG 12 case
// synthesis translate_off
always @(*) begin
       gap_cnt = 23;
       if (i_sop[0]) begin
          if (eop_r[0]) gap_cnt = {2'b01, partial[2:0]};
          if (eop_r2[1]) gap_cnt = {2'b10, partial[2:0]};
       end
       if (i_sop[1]) begin
          if (eop_r[1]) gap_cnt = {2'b01, partial[2:0]};
          if (eop_r[0]) gap_cnt = {2'b10, partial[2:0]};
       end
end

always @(*)
begin
   case(gap_cnt)
   5'd8  : short = 5'h08; +8
   5'd9  : short = 5'h07; +7
   5'd10 : short = 5'h06; +6
   5'd11 : short = 5'h05; +5
   5'd12 : short = 5'h04; +4
   5'd13 : short = 5'h03; +3
   5'd14 : short = 5'h02; +2
   5'd15 : short = 5'h01; +1
   5'd16 : short = 5'h00; +0
   5'd17 : short = 5'h1f; -1
   5'd18 : short = 5'h1e; -2
   5'd19 : short = 5'h1d; -3
   5'd20 : short = 5'h1c; -4
   5'd21 : short = 5'h1b; -5
   5'd22 : short = 5'h1a; -6
   5'd23 : short = 5'h19; -7
   default: short = 0;
   endcase
end

// synthesis translate_on
*/

generate
   if (SYNOPT_AVG_IPG == 8) begin
      always @(*) begin
         short = 5'h19;
         //if ((i_sop[0] && eop_r[1])  || (i_sop[1] && i_eop[0])) short = 5'h0c - {2'b00, partial[2:0]};
         //if ((i_sop[0] && eop_r[0])  || (i_sop[1] && eop_r[1])) short = 5'h0c - {2'b01, partial[2:0]};
         //if ((i_sop[0] && eop_r2[1]) || (i_sop[1] && eop_r[0])) short = 5'h0c - {2'b10, partial[2:0]};
         if ((i_sop[0] && eop_r[1])  || (i_sop[1] && i_eop[0])) short = 5'h0c - partial[2:0];
         if ((i_sop[0] && eop_r[0])  || (i_sop[1] && eop_r[1])) short = 5'h04 - partial[2:0];
         if ((i_sop[0] && eop_r2[1]) || (i_sop[1] && eop_r[0])) short = 5'h0c - {2'b10, partial[2:0]};
      end
      
      always @(*) begin
         short_no_crc = 5'h19;
         //if ((i_sop[1] && i_eop[0]) || (i_sop[0] && eop_r[1]))  short_no_crc = 5'h08 - {2'b00, partial[2:0]};
         //if ((i_sop[0] && eop_r[0]) || (i_sop[1] && eop_r[1]))  short_no_crc = 5'h08 - {2'b01, partial[2:0]};
         //if ((i_sop[0] && eop_r2[1]) || (i_sop[1] && eop_r[0])) short_no_crc = 5'h08 - {2'b10, partial[2:0]};
         if ((i_sop[1] && i_eop[0]) || (i_sop[0] && eop_r[1]))  short_no_crc = 5'h08 - partial[2:0];
         if ((i_sop[0] && eop_r[0]) || (i_sop[1] && eop_r[1]))  short_no_crc = 5'h00 - partial[2:0];
         if ((i_sop[0] && eop_r2[1]) || (i_sop[1] && eop_r[0])) short_no_crc = 5'h08 - {2'b10, partial[2:0]};
      end
   end
   else begin // SYNOPT_AVG_IPG == 12
      always @(*) begin
         short = 5'h19;
         if ((i_sop[0] && eop_r[0])  || (i_sop[1] && eop_r[1])) short = 5'h10 - {2'b01, partial[2:0]};
         if ((i_sop[0] && eop_r2[1]) || (i_sop[1] && eop_r[0])) short = 5'h10 - {2'b10, partial[2:0]};
      end


      always @(*) begin
         short_no_crc = 5'h19;
	 if ((i_sop[1] && i_eop[0]) || (i_sop[0] && eop_r[1])) short_no_crc = 5'h0C - {2'b00, partial[2:0]};
	 if ((i_sop[0] && eop_r[0]) || (i_sop[1] && eop_r[1])) short_no_crc = 5'h0C - {2'b01, partial[2:0]};
      end
   end
endgenerate


always @(*) begin
	short_plus_dic = (tx_crc_ins_en ? short : short_no_crc) + dic;
        if (short_plus_dic[4]) {next_dic_req, next_dic} = 4'b0000;
        else {next_dic_req, next_dic} = short_plus_dic[3:0];
end

reg local_sclr = 1'b0;
always @(posedge clk) local_sclr <= sclr;

localparam AM_NUM=4;

reg [7:0] am_cnt;

always @(posedge clk) begin
   if (local_sclr) am_cnt <= 8'd0;
   else if (i_am) am_cnt <= num_idle_rm;
   else if (dic_req_unblocked && !dic_req) am_cnt <= am_cnt - 1'b1;
end

always @(posedge clk)
   if (local_sclr)                            dic <= 0;
   else if (i_ena && !o_wait_req && |(i_sop)) dic <= next_dic;

always @(posedge clk)
   if (local_sclr)                                     dic_req <= 0;
   else if (i_ena && !o_wait_req && |(i_sop)) begin
           if (!i_am && am_cnt!=0)                     dic_req <= 0;
           else                                        dic_req <= next_dic_req;
   end
   else                                                dic_req <= 0;

always @(posedge clk)
   if (local_sclr)                                     dic_req_unblocked <= 0;
   else if (i_ena && !o_wait_req && |(i_sop))          dic_req_unblocked <= next_dic_req;
   else                                                dic_req_unblocked <= 0;


always @(*) begin
       dic_req0 = (sop_r[0] && dic_req); 
       dic_req1 = (sop_r[1] && dic_req); 
end

ectrl_ins_2 edic_ins(
        .clk(clk),
        .sclr(local_sclr),

        .i_gap_req0(dic_req0),
        .i_gap_req1(dic_req1),
        .i_ena(i_ena),
        .i_sop(sop_r), // lsbit first, sop marks the preamble word
        .i_eop(eop_r),
        .i_eop_empty(eop_empty_r),
        .i_data_empty(data_empty_r),
        .i_tags(tags_r),

        .o_wait_req(o_wait_req),
        .o_tags(o_tags),
                // 111,110,101,100 data words
                // 000 idles
                // 001 padding
        .o_sop(o_sop), // lsbit first
        .o_eop(o_eop),
        .o_eop_empty(o_eop_empty),
        .o_data_empty(o_data_empty)
);

endmodule

 
