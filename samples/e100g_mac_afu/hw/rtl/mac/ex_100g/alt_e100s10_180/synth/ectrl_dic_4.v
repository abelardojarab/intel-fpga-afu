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


// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/mac/ectrl_dic_4.v#7 $
// $Revision: #7 $
// $Date: 2013/10/20 $
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

// set_instance_assignment -name VIRTUAL_PIN ON -to num_idle_rm
// set_instance_assignment -name VIRTUAL_PIN ON -to i_eop_empty
// set_instance_assignment -name VIRTUAL_PIN ON -to i_data_empty
// set_instance_assignment -name VIRTUAL_PIN ON -to i_tags
// set_instance_assignment -name VIRTUAL_PIN ON -to o_eop_empty
// set_instance_assignment -name VIRTUAL_PIN ON -to o_data_empty
// set_instance_assignment -name VIRTUAL_PIN ON -to o_tags
// set_global_assignment -name SEARCH_PATH ../../hsl12
// set_global_assignment -name SEARCH_PATH ../../rtl/lib
// set_global_assignment -name SEARCH_PATH ../../rtl/mac
// set_global_assignment -name SEARCH_PATH ../../rtl/clones

module ectrl_dic_4 #(
        parameter WORDS = 4,
	parameter SYNOPT_AVG_IPG = 12,
	parameter EN_TX_CRC_INS = 1 // S10TIM
)(
        input clk,
        input sclr,

        input [7:0] num_idle_rm,
        //input tx_crc_ins_en,
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

reg         dic_req0;
reg         dic_req1;
reg         dic_req2;
reg         dic_req3;

reg [2:0] partial;
reg [4:0] gap_cnt;
reg [4:0] short;
reg [4:0] short_no_crc;
reg [2:0] dic;
reg [2:0] next_dic;
reg       next_dic_req;
reg       dic_req;
reg am;
reg [7:0] num_idle_rm_r;
reg [5:0] short_plus_dic;
reg [3:0] eop,eop_r,eop_rr, eop_rrr;
reg [3:0] sop,sop_r,sop_rr, sop_rrr;
reg [11:0] tags,tags_r,tags_rr, tags_rrr;
reg [11:0] eop_empty,eop_empty_r,eop_empty_rr,eop_empty_rrr;
reg [11:0] data_empty,data_empty_r,data_empty_rr, data_empty_rrr;
reg [2:0] local_sclr;

always @(posedge clk) am <= i_am;

always @(posedge clk) begin
   if (local_sclr[2]) begin
       num_idle_rm_r <= 0;
       sop <= 0;
       eop <= 0;
       eop_empty <= 0;
       data_empty <= 0;
       tags <= 0;

       sop_r <= 0;
       eop_r <= 0;
       eop_empty_r <= 0;
       data_empty_r <= 0;
       tags_r <= 0;

       sop_rr <= 0;
       eop_rr <= 0;
       eop_empty_rr <= 0;
       data_empty_rr <= 0;
       tags_rr <= 0;

       sop_rrr <= 0;
       eop_rrr <= 0;
       eop_empty_rrr <= 0;
       data_empty_rrr <= 0;
       tags_rrr <= 0;
   end
   else if (i_ena && !o_wait_req) begin
       num_idle_rm_r <= num_idle_rm;
       sop <= i_sop;
       eop <= i_eop;
       eop_empty <= i_eop_empty;
       data_empty <= i_data_empty;
       tags <= i_tags;

       sop_r <= sop;
       eop_r <= eop;
       eop_empty_r <= eop_empty;
       data_empty_r <= data_empty;
       tags_r <= tags;

       sop_rr <= sop_r;
       eop_rr <= eop_r;
       eop_empty_rr <= eop_empty_r;
       data_empty_rr <= data_empty_r;
       tags_rr <= tags_r;

       sop_rrr <= sop_rr;
       eop_rrr <= eop_rr;
       eop_empty_rrr <= eop_empty_rr;
       data_empty_rrr <= data_empty_rr;
       tags_rrr <= tags_rr;
   end
end

// this is after padding. So no (sop,eop,sop,eop) type of case
always @(posedge clk) begin
   if (local_sclr[2]) partial <= 0;
   else if (|i_sop) begin 
      partial <= ({3{eop[3]}} & eop_empty[11:9]) | 
                 ({3{eop[2]}} & eop_empty[ 8:6]) | 
                 ({3{eop[1]}} & eop_empty[ 5:3]) | 
                 ({3{i_eop[0]}} & i_eop_empty[ 2:0]) | 
                 ({3{i_eop[1]}} & i_eop_empty[ 5:3]) | 
                 ({3{i_eop[2]}} & i_eop_empty[ 8:6]);
   end
end

/*
// For AVG_IPG 12 case
// synthesis translate_off
always @(*) begin
       gap_cnt = 23;
       if (sop[0]) begin
          if (eop_r[2]) gap_cnt = {2'b01, partial[2:0]};
          if (eop_r[1]) gap_cnt = {2'b10, partial[2:0]};
       end
       if (sop[1]) begin
          if (eop_r[3]) gap_cnt = {2'b01, partial[2:0]};
          if (eop_r[2]) gap_cnt = {2'b10, partial[2:0]};
       end
       if (sop[2]) begin
          if (eop[0]) gap_cnt = {2'b01, partial[2:0]};
          if (eop_r[3]) gap_cnt = {2'b10, partial[2:0]};
       end
       if (sop[3]) begin
          if (eop[1]) gap_cnt = {2'b01, partial[2:0]};
          if (eop[0]) gap_cnt = {2'b10, partial[2:0]};
       end
end

always @(*)
begin
   case(gap_cnt)
   5'd8  : short = 5'h08;
   5'd9  : short = 5'h07;
   5'd10 : short = 5'h06;
   5'd11 : short = 5'h05;
   5'd12 : short = 5'h04;
   5'd13 : short = 5'h03;
   5'd14 : short = 5'h02;
   5'd15 : short = 5'h01;
   5'd16 : short = 5'h00;
   5'd17 : short = 5'h1f;
   5'd18 : short = 5'h1e;
   5'd19 : short = 5'h1d;
   5'd20 : short = 5'h1c;
   5'd21 : short = 5'h1b;
   5'd22 : short = 5'h1a;
   5'd23 : short = 5'h19;
   default: short = 0;
   endcase
end
// synthesis translate_on
*/

generate
   if (SYNOPT_AVG_IPG == 8) begin
      always @(posedge clk) begin
         if (i_ena && !o_wait_req) begin
             if ((sop[0] && eop_r[3]) || (sop[1] && eop[0]) || (sop[2] && eop[1]) || (sop[3] && eop[2]))          short <= 5'h0c - partial[2:0];
             else if ((sop[0] && eop_r[2]) || (sop[1] && eop_r[3]) || (sop[2] && eop[0]) || (sop[3] && eop[1]))   short <= 5'h04 - partial[2:0];
             else if ((sop[0] && eop_r[1]) || (sop[1] && eop_r[2]) || (sop[2] && eop_r[3]) || (sop[3] && eop[0])) short <= 5'h00 - partial[2:0];
             else                                                                                                 short <= 5'h19;
         end
      end

      always @(posedge clk) begin
         if (i_ena && !o_wait_req) begin
             if ((sop[0] && eop_r[3]) || (sop[1] && eop[0]) || (sop[2] && eop[1]) || (sop[3] && eop[2]))          short_no_crc <= 5'h08 - partial[2:0];
             else if ((sop[0] && eop_r[2]) || (sop[1] && eop_r[3]) || (sop[2] && eop[0]) || (sop[3] && eop[1]))   short_no_crc <= 5'h00 - partial[2:0];
             else if ((sop[0] && eop_r[1]) || (sop[1] && eop_r[2]) || (sop[2] && eop_r[3]) || (sop[3] && eop[0])) short_no_crc <= 5'h08 - {2'b10, partial[2:0]};
             else                                                                                                 short_no_crc <= 5'h19;
         end 
      end
   end
   else begin // SYNOPT_AVG_IPG == 12
      always @(posedge clk) begin
         if (i_ena && !o_wait_req) begin
             if ((sop[0] && eop_r[2]) || (sop[1] && eop_r[3]) || (sop[2] && eop[0]) || (sop[3] && eop[1]))        short <= 5'h08 - partial[2:0];
             else if ((sop[0] && eop_r[1]) || (sop[1] && eop_r[2]) || (sop[2] && eop_r[3]) || (sop[3] && eop[0])) short <= 5'h00 - partial[2:0];
             else                                                                                                 short <= 5'h19;
         end
      end

      always @(posedge clk) begin
         if (i_ena && !o_wait_req) begin
             if ((sop[0] && eop_r[3]) || (sop[1] && eop[0]) || (sop[2] && eop[1]) || (sop[3] && eop[2]))          short_no_crc <= 5'h0c - partial[2:0];
             else if ((sop[0] && eop_r[2]) || (sop[1] && eop_r[3]) || (sop[2] && eop[0]) || (sop[3] && eop[1]))   short_no_crc <= 5'h04 - partial[2:0];
             else if ((sop[0] && eop_r[1]) || (sop[1] && eop_r[2]) || (sop[2] && eop_r[3]) || (sop[3] && eop[0])) short_no_crc <= 5'h0c - {2'b10, partial[2:0]};
             else                                                                                                 short_no_crc <= 5'h19;
         end
      end
   end
endgenerate
   
always @(*) begin
	//short_plus_dic = (tx_crc_ins_en ? short : short_no_crc) + dic;
	short_plus_dic = (EN_TX_CRC_INS ? short : short_no_crc) + dic; // S10TIM

        if (short_plus_dic[4]) {next_dic_req, next_dic} = 4'b0000;
        else                   {next_dic_req, next_dic} = short_plus_dic[3:0];
end

   
always @(posedge clk) local_sclr <= {3{sclr}};

reg [7:0] am_cnt;
reg dic_req_unblocked;

always @(posedge clk) begin
   if (local_sclr[0])                         am_cnt <= num_idle_rm_r;
   else if (am)                            am_cnt <= num_idle_rm_r;
   //else if (i_ena && !o_wait_req && dic_req_unblocked && !dic_req) am_cnt <= am_cnt - 1'b1; // ideal, correct
   else if (dic_req_unblocked && !dic_req) am_cnt <= am_cnt - 1'b1;
end

always @(posedge clk) 
   if (local_sclr[0])  dic <= 0;
   else if (i_ena && !o_wait_req && |(sop_r))        dic <= next_dic;

always @(posedge clk) 
   if (local_sclr[0])                                   dic_req <= 0;
   else if (i_ena && !o_wait_req && |(sop_r)) begin
           if (!am && am_cnt!=0)                     dic_req <= 0;
           else                                      dic_req <= next_dic_req;
   end
   else                                              dic_req <= 0;

always @(posedge clk) 
   if (local_sclr[0])                                   dic_req_unblocked <= 0;
   else if (i_ena && !o_wait_req && |(sop_r))        dic_req_unblocked <= next_dic_req;
   else                                              dic_req_unblocked <= 0;

/*
//////////////////////////////////////////////////////////////////////////////////////////
// ideal, correct
//////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk) 
   if (local_sclr)                                   dic_req <= 0;
   else if (i_ena && !o_wait_req) begin
      if (|(sop_r)) begin
           if (am_cnt!=0)                            dic_req <= 0;
           else                                      dic_req <= next_dic_req;
      end
      else                                           dic_req <= 0;
   end

always @(posedge clk) 
   if (local_sclr)                                   dic_req_unblocked <= 0;
   else if (i_ena && !o_wait_req) begin
      if (|(sop_r))                                  dic_req_unblocked <= next_dic_req;
      else                                           dic_req_unblocked <= 0;
   end
//////////////////////////////////////////////////////////////////////////////////////////
*/
always @(posedge clk) begin
   if (local_sclr[0]) begin
       dic_req0 <= 0;
       dic_req1 <= 0;
       dic_req2 <= 0;
       dic_req3 <= 0;
   end
   else if (i_ena && !o_wait_req) begin
       dic_req0 <= (sop_rr[0] && dic_req); 
       dic_req1 <= (sop_rr[1] && dic_req); 
       dic_req2 <= (sop_rr[2] && dic_req); 
       dic_req3 <= (sop_rr[3] && dic_req);
   end
end

ectrl_ins_4 edic_ins(
        .clk(clk),
        .sclr(local_sclr[1]),

        .i_gap_req0(dic_req0),
        .i_gap_req1(dic_req1),
        .i_gap_req2(dic_req2),
        .i_gap_req3(dic_req3),
        .i_ena(i_ena),
        .i_sop(sop_rrr), // lsbit first, sop marks the preamble word
        .i_eop(eop_rrr),
        .i_eop_empty(eop_empty_rrr),
        .i_data_empty(data_empty_rrr),
        .i_tags(tags_rrr),

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

 
