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


// $Id: $
// $Revision: $
// $Date: $
// $Author: $
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

module ectrl_ins4preamble_2 #(
        parameter WORDS = 2
)(
        input clk,
        input sclr,

        input i_gap_req0,
        input i_gap_req1,
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

wire [2:0]  HOLE=3'h0;
reg  [5:0] tags=0;
reg  [1:0]  tag_sop=0;
reg  [1:0]  tag_eop=0;
reg  [5:0] tag_eop_empty=0;
reg  [5:0] tag_data_empty=0;
reg  [2:0]  extra_tags_0=0;
reg         extra_sop_0=0;
reg         extra_eop_0=0;
reg  [2:0]  extra_eop_empty_0=0;
reg  [2:0]  extra_data_empty_0=0;
reg  [2:0]  extra_tags_1=0;
reg         extra_sop_1=0;
reg         extra_eop_1=0;
reg  [2:0]  extra_eop_empty_1=0;
reg  [2:0]  extra_data_empty_1=0;
reg  [1:0]  st=0;
wire        gap_req;
reg         wait_req=0;

assign gap_req = i_gap_req0 || i_gap_req1;

always @(posedge clk) begin
   if (sclr) begin
      tags               <= {WORDS{3'b0}};
      tag_sop            <= {WORDS{1'b0}};
      tag_eop            <= {WORDS{1'b0}};
      tag_eop_empty      <= {WORDS{3'b0}};  
      tag_data_empty     <= {WORDS{3'b0}};  
      st <= 0;
      wait_req <= 0;
   end
   else if (i_ena) begin
     case(st)
        2'h0 : begin
                  if (gap_req) begin
                     if (i_gap_req0) begin 
                        tags           <= {i_tags[2:0],       HOLE};  
                        tag_sop        <= {1'b0,              1'b1};
                        tag_eop        <= {i_eop[0],          1'b0};
                        tag_eop_empty  <= {i_eop_empty[2:0],  3'h0};  
                        tag_data_empty <= {i_data_empty[2:0], 3'h0};  
                     end
                     if (i_gap_req1) begin
                        tags           <= {HOLE,              i_tags[2:0]}; 
                        tag_sop        <= {1'b1,              i_sop[0]};
                        tag_eop        <= {1'b0,              i_eop[0]};
                        tag_eop_empty  <= {3'h0,              i_eop_empty[2:0]};  
                        tag_data_empty <= {3'h0,              i_data_empty[2:0]};  
                     end

                     extra_tags_0       <= i_tags[5:3];
                     extra_sop_0        <= 1'b0;
                     extra_eop_0        <= i_eop[1];
                     extra_eop_empty_0  <= i_eop_empty[5:3];
                     extra_data_empty_0 <= i_data_empty[5:3];
                     st                 <= 1;
                     wait_req           <= 0;
                  end
                  else begin
                     tags               <= i_tags;
                     tag_sop            <= i_sop;
                     tag_eop            <= i_eop;
                     tag_eop_empty      <= i_eop_empty;  
                     tag_data_empty     <= i_data_empty;  
                     st                 <= 0;
                     wait_req           <= 0;
                  end
               end
        2'h1 : begin
                  if (gap_req) begin
                     if (i_gap_req0) begin
                        tags           <= {HOLE,              extra_tags_0}; 
                        tag_sop        <= {1'b1,              extra_sop_0};
                        tag_eop        <= {1'b0,              extra_eop_0};
                        tag_eop_empty  <= {3'h0,              extra_eop_empty_0};  
                        tag_data_empty <= {3'h0,              extra_data_empty_0};  

                        extra_tags_0       <= i_tags[2:0];
                        extra_sop_0        <= 1'b0;
                        extra_eop_0        <= i_eop[0];
                        extra_eop_empty_0  <= i_eop_empty[2:0];
                        extra_data_empty_0 <= i_data_empty[2:0];

                        extra_tags_1       <= i_tags[5:3];
                        extra_sop_1        <= i_sop[1];
                        extra_eop_1        <= i_eop[1];
                        extra_eop_empty_1  <= i_eop_empty[5:3];
                        extra_data_empty_1 <= i_data_empty[5:3];

                        wait_req           <= 1;
                        st                 <= 2;
                     end
                     if (i_gap_req1) begin
                        tags           <= {i_tags[2:0],       extra_tags_0}; 
                        tag_sop        <= {i_sop[0],          extra_sop_0};
                        tag_eop        <= {i_eop[0],          extra_eop_0};
                        tag_eop_empty  <= {i_eop_empty[2:0],  extra_eop_empty_0};  
                        tag_data_empty <= {i_data_empty[2:0], extra_data_empty_0};  

                        extra_tags_0       <= HOLE; 
                        extra_sop_0        <= 1'b1; 
                        extra_eop_0        <= 1'b0; 
                        extra_eop_empty_0  <= 3'h0; 
                        extra_data_empty_0 <= 3'h0; 

                        extra_tags_1       <= i_tags[5:3];
                        extra_sop_1        <= 1'b0;
                        extra_eop_1        <= i_eop[1];
                        extra_eop_empty_1  <= i_eop_empty[5:3];
                        extra_data_empty_1 <= i_data_empty[5:3];

                        wait_req           <= 1;
                        st                 <= 2;
                     end

                  end
                  else begin
                     tags           <= {i_tags[2:0],       extra_tags_0};
                     tag_sop        <= {i_sop[0],          extra_sop_0};
                     tag_eop        <= {i_eop[0],          extra_eop_0};
                     tag_eop_empty  <= {i_eop_empty[2:0],  extra_eop_empty_0};  
                     tag_data_empty <= {i_data_empty[2:0], extra_data_empty_0};  

                     extra_tags_0       <= i_tags[5:3];
                     extra_sop_0        <= i_sop[1];
                     extra_eop_0        <= i_eop[1];
                     extra_eop_empty_0  <= i_eop_empty[5:3];
                     extra_data_empty_0 <= i_data_empty[5:3];

                     wait_req       <= 0;
                     st             <= 1;
                  end
               end
 
        3'h2 : begin
                  tags           <= {extra_tags_1,       extra_tags_0};        
                  tag_sop        <= {extra_sop_1,        extra_sop_0};        
                  tag_eop        <= {extra_eop_1,        extra_eop_0};        
                  tag_eop_empty  <= {extra_eop_empty_1,  extra_eop_empty_0};        
                  tag_data_empty <= {extra_data_empty_1, extra_data_empty_0};        
                  wait_req <= 0;
                  st <= 0;
               end
      endcase
   end
end

assign o_tags       = tags;
assign o_sop        = tag_sop;
assign o_eop        = tag_eop;
assign o_eop_empty  = tag_eop_empty;
assign o_data_empty = tag_data_empty;

assign o_wait_req   = wait_req;   
//assign o_wait_req   = (st==3) && gap_req;

endmodule

 
