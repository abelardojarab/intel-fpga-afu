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


// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/mac/ectrl_gap_4.v#4 $
// $Revision: #4 $
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

module ectrl_gap_4 #(
        parameter WORDS = 4,
        parameter SYNOPT_AVG_IPG = 12,
        parameter EN_TX_CRC_INS = 1 // S10TIM
)(
        input clk,
        input sclr,

        //input tx_crc_ins_en,
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

reg         eop3_r; 
reg  [3:0]  eop3_empty_r; 
reg         gap_req0, gap_req1, gap_req2, gap_req3;

reg [3:0] eop_r;
reg [3:0] sop_r;
reg [11:0] tags_r;
reg [11:0] eop_empty_r;
reg [11:0] data_empty_r;

reg local_sclr = 1'b0;
always @(posedge clk) local_sclr <= sclr;

always @(posedge clk) begin
    if (sclr) begin
      eop3_r <= 0;
      eop3_empty_r[2:0] <= 0;
      sop_r <= 0;
      eop_r <= 0;
      eop_empty_r <= 0;
      data_empty_r <= 0;
      tags_r <= 0;
   end
   else if (i_ena && !o_wait_req) begin
      eop3_r <= i_eop[3];
      eop3_empty_r[2:0] <= i_eop_empty[11:9];
      sop_r <= i_sop;
      eop_r <= i_eop;
      eop_empty_r <= i_eop_empty;
      data_empty_r <= i_data_empty;
      tags_r <= i_tags;
   end
end
/*
always @(*) begin
       //gap_req0 = (i_sop[0] && eop3_r   && (eop3_empty_r[2:0]!=6 && eop3_empty_r[2:0]!=7));
       //gap_req1 = (i_sop[1] && i_eop[0] && (i_eop_empty[2:0]!=6  && i_eop_empty[2:0]!=7));
       //gap_req2 = (i_sop[2] && i_eop[1] && (i_eop_empty[5:3]!=6  && i_eop_empty[5:3]!=7));
       //gap_req3 = (i_sop[3] && i_eop[2] && (i_eop_empty[8:6]!=6  && i_eop_empty[8:6]!=7));

       //gap_req0 = i_sop[0] && eop3_r   && (tx_crc_ins_en || eop3_empty_r[2:0]==0);
       //gap_req1 = i_sop[1] && i_eop[0] && (tx_crc_ins_en || i_eop_empty[2:0]==0);
       //gap_req2 = i_sop[2] && i_eop[1] && (tx_crc_ins_en || i_eop_empty[5:3]==0);
       //gap_req3 = i_sop[3] && i_eop[2] && (tx_crc_ins_en || i_eop_empty[8:6]==0);

       gap_req0 = i_sop[0] && eop3_r   && (tx_crc_ins_en || eop3_empty_r[2]==0);
       gap_req1 = i_sop[1] && i_eop[0] && (tx_crc_ins_en || i_eop_empty[2]==0);
       gap_req2 = i_sop[2] && i_eop[1] && (tx_crc_ins_en || i_eop_empty[5]==0);
       gap_req3 = i_sop[3] && i_eop[2] && (tx_crc_ins_en || i_eop_empty[8]==0);
*/
/*
   if (tx_crc_ins_en) begin
       gap_req0 = (i_sop[0] && eop3_r);
       gap_req1 = (i_sop[1] && i_eop[0]);
       gap_req2 = (i_sop[2] && i_eop[1]);
       gap_req3 = (i_sop[3] && i_eop[2]);
   end
   else begin
       gap_req0 = (i_sop[0] && eop3_r   && eop3_empty_r[2:0]==0);
       gap_req1 = (i_sop[1] && i_eop[0] && i_eop_empty[2:0]==0);
       gap_req2 = (i_sop[2] && i_eop[1] && i_eop_empty[5:3]==0);
       gap_req3 = (i_sop[3] && i_eop[2] && i_eop_empty[8:6]==0);
   end
*/
//end

generate 
   if (SYNOPT_AVG_IPG == 8) begin
      always @(posedge clk) begin
         if (sclr) begin
            gap_req0 <= 0;
            gap_req1 <= 0;
            gap_req2 <= 0;
            gap_req3 <= 0;
         end
         else if (i_ena && !o_wait_req) begin
            //gap_req0 <= i_sop[0] && eop3_r   && (tx_crc_ins_en ? eop3_empty_r[2:0]<5 : eop3_empty_r[2:0]==0);
            //gap_req1 <= i_sop[1] && i_eop[0] && (tx_crc_ins_en ? i_eop_empty[2:0]<5  : i_eop_empty[2:0]==0);
            //gap_req2 <= i_sop[2] && i_eop[1] && (tx_crc_ins_en ? i_eop_empty[5:3]<5  : i_eop_empty[5:3]==0);
            //gap_req3 <= i_sop[3] && i_eop[2] && (tx_crc_ins_en ? i_eop_empty[8:6]<5  : i_eop_empty[8:6]==0);
            gap_req0 <= i_sop[0] && eop3_r   && (EN_TX_CRC_INS ? eop3_empty_r[2:0]<5 : eop3_empty_r[2:0]==0); // S10TIM
            gap_req1 <= i_sop[1] && i_eop[0] && (EN_TX_CRC_INS ? i_eop_empty[2:0]<5  : i_eop_empty[2:0]==0);  // S10TIM
            gap_req2 <= i_sop[2] && i_eop[1] && (EN_TX_CRC_INS ? i_eop_empty[5:3]<5  : i_eop_empty[5:3]==0);  // S10TIM
            gap_req3 <= i_sop[3] && i_eop[2] && (EN_TX_CRC_INS ? i_eop_empty[8:6]<5  : i_eop_empty[8:6]==0);  // S10TIM
         end
      end
   end
   else begin // AVG_IPG = 12
      always @(posedge clk) begin
          if (sclr) begin
            gap_req0 <= 0;
            gap_req1 <= 0;
            gap_req2 <= 0;
            gap_req3 <= 0;
         end
         else if (i_ena && !o_wait_req) begin
            //gap_req0 <= i_sop[0] && eop3_r   && (tx_crc_ins_en || eop3_empty_r[2]==0);
            //gap_req1 <= i_sop[1] && i_eop[0] && (tx_crc_ins_en || i_eop_empty[2]==0);
            //gap_req2 <= i_sop[2] && i_eop[1] && (tx_crc_ins_en || i_eop_empty[5]==0);
            //gap_req3 <= i_sop[3] && i_eop[2] && (tx_crc_ins_en || i_eop_empty[8]==0);
            gap_req0 <= i_sop[0] && eop3_r   && (EN_TX_CRC_INS ? 1'b1 : 1'b0 || eop3_empty_r[2]==0); // S10TIM
            gap_req1 <= i_sop[1] && i_eop[0] && (EN_TX_CRC_INS ? 1'b1 : 1'b0|| i_eop_empty[2]==0);   // S10TIM
            gap_req2 <= i_sop[2] && i_eop[1] && (EN_TX_CRC_INS ? 1'b1 : 1'b0 || i_eop_empty[5]==0);  // S10TIM
            gap_req3 <= i_sop[3] && i_eop[2] && (EN_TX_CRC_INS ? 1'b1 : 1'b0 || i_eop_empty[8]==0);  // S10TIM
         end
      end
   end
endgenerate

ectrl_ins_4 egap_ins(
        .clk(clk),
        .sclr(local_sclr),

        .i_gap_req0(gap_req0),
        .i_gap_req1(gap_req1),
        .i_gap_req2(gap_req2),
        .i_gap_req3(gap_req3),
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

 
