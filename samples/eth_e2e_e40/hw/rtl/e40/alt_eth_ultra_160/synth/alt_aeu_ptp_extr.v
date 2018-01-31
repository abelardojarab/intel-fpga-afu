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




// $Id: //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/pcs/e100_rx_pcs_4.v#1 $
// $Revision: #1 $
// $Date: 2013/02/27 $
// $Author: rkane $
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

module alt_aeu_ptp_extr
  #(
    parameter TARGET_CHIP = 2, // 2: stratix v, 5: arria 10
	parameter W2_WIDTH = 9,
    parameter WORDS = 4
    )    
   (
	input srst,

    input din_valid,
	input din_sop,
	input din_extr,
	input din_spl_hndl,
	input din_wr_off,
	input [1:0] din_ptp_asm,
    input [WORDS*64-1:0] din,
    input [15:0] din_offset,
	input [4:0] din_offset_adj,

	output pre_dout_valid,
	output pre_dout_spl_hndl,
    output reg dout_valid,
	output reg dout_ipg, // wether two words were separated by ipg
	output reg dout_spl_hndl,
	output reg dout_wr_off,
	output reg [1:0] dout_ptp_asm,
    output reg [(2*8+W2_WIDTH)*8-1:0] dout,
	output reg [15:0] dout_offset /* synthesis preserve */,
	output reg [1:0] dout_offset_cp1 /* synthesis preserve */,

    input clk
   
	);

   reg [15:0] 				   cur_offset;
   reg [15:0] 				   reqd_offset;
   reg 						   spl_hndl;
   reg 						   wr_off;
   
   reg 						   extr_en;
   reg [1:0] 						   ptp_asm;

   reg [15:0] 				   cur_offset_n;

   reg [15:0] 				   reqd_offset_alt;
   reg 						   spl_hndl_alt;
   reg 						   wr_off_alt;
   reg [1:0] 						   ptp_asm_alt;
   reg 						   word_match_alt;
   reg [2*64-1:0] 			   wd1_alt;
   reg 						   word_match_alt_d1;
   

   always @(posedge clk)
	 begin
		if (din_valid)
		  begin
			 if (din_sop)
			   begin
				  cur_offset <= 16'd0;
				  cur_offset_n <= WORDS*8;
				  if (din_extr)
					begin
					   reqd_offset <= din_offset + din_offset_adj;
					   spl_hndl <= din_spl_hndl;
					   wr_off <= din_wr_off;
					   extr_en <= 1'b1;
					   ptp_asm <= din_ptp_asm;
					end
				  else
					begin
					   reqd_offset <= 16'd0;
					   spl_hndl <= 1'b0;
					   wr_off <= 1'b0;
					   extr_en <= 1'b0;
					   ptp_asm <= 2'b00;
					end
			   end // if (din_sop)
			 else
			   begin
				  cur_offset <= cur_offset + WORDS*8;
				  cur_offset_n <= cur_offset_n + WORDS*8;
			   end // else: !if(din_sop)
		  end // if (din_valid)
		else
		  begin 
			 // din_valid is 0, alignment marker cycle. Add to both the offsets. 
			 // reqd offset used later to find insertion point for this field after sop
			 // din_valid is not available at that point in wd_match
			 cur_offset <= cur_offset + WORDS*8;
			 reqd_offset <= reqd_offset + WORDS*8;
			 cur_offset_n <= cur_offset_n + WORDS*8;
			 spl_hndl <= spl_hndl;
			 wr_off <= wr_off;
		  end // else: !if(din_valid)
	 end // always @ (posedge clk)

   reg [WORDS*64-1:0] din_d1;
   reg 			  din_valid_d1;
   reg [2*64-1:0] din_d2;
   
   always @(posedge clk)
	 begin
		reqd_offset_alt <= reqd_offset;
		spl_hndl_alt <= spl_hndl;
		wr_off_alt <= wr_off;
		ptp_asm_alt <= ptp_asm;
		word_match_alt_d1 <= word_match_alt;
		wd1_alt <= din[(WORDS*64)-1:(WORDS-2)*64];
	 end

   always @(posedge clk)
	 begin
		din_d1 <= din;
		din_valid_d1 <= din_valid;
	 end

   
   reg [2*64-1:0] wd1_din;
   reg [2*64-1:0] wd1;
   
   reg 				  wd1_valid;
   

   reg 				  word_match;

   generate 
	  if (WORDS == 4)
		begin: w4
		   always @(*)
			 begin
				if (reqd_offset[4] == 1'b1)
				  wd1_din = din_d1[(WORDS-2)*64-1:0];
				else
				  wd1_din = din_d1[(WORDS*64)-1:(WORDS-2)*64];
				if ((cur_offset[15:5] == reqd_offset[15:5]) & extr_en)
				  word_match = 1'b1;
				else
				  word_match = 1'b0;

				if (cur_offset_n[15:5] == reqd_offset[15:5] & extr_en & din_sop)
				  word_match_alt = 1'b1;
				else
				  word_match_alt = 1'b0;
			 end
		end
	  else
		begin: w2
		   always @(*)
			 begin
				word_match = 1'b0;
				wd1_din = din_d1[(WORDS*64)-1:(WORDS-2)*64];
				if ((cur_offset[15:4] == reqd_offset[15:4]) & extr_en)
				  word_match = 1'b1;
				else
				  word_match = 1'b0;
			 end
		end
   endgenerate
   
   reg [15:0] 				   reqd_offset_d1;
   reg 						   spl_hndl_d1;
   reg 						   wr_off_d1;
   reg [1:0]  						   ptp_asm_d1;
   reg 						   wd2_in_next_cycle;
   
   always @(posedge clk)
	 begin
		if (din_valid_d1)
		  begin
			 if (word_match_alt_d1)
			   begin
				  wd1_valid <= 1'b1;
				  reqd_offset_d1 <= reqd_offset_alt;
				  spl_hndl_d1 <= spl_hndl_alt;
				  wr_off_d1 <= wr_off_alt;
				  ptp_asm_d1 <= ptp_asm_alt;
				  if (din_valid)
					wd2_in_next_cycle <= 1'b1;
				  else
					wd2_in_next_cycle <= 1'b0;
			   end // if (word_match_alt_d1)
			 else
			   begin
				  if (word_match)
					begin
					   wd1_valid <= 1'b1;
					   reqd_offset_d1 <= reqd_offset;
					   spl_hndl_d1 <= spl_hndl;
					   wr_off_d1 <= wr_off;
					   ptp_asm_d1 <= ptp_asm;
					   if (din_valid)
						 wd2_in_next_cycle <= 1'b1;
					   else
						 wd2_in_next_cycle <= 1'b0;
					end
				  else
					begin
					   wd1_valid <= 1'b0;
					   spl_hndl_d1 <= 1'b0;
					   wr_off_d1 <= 1'b0;
					   ptp_asm_d1 <= 2'b00;
					   wd2_in_next_cycle <= 1'b0;
					end // else: !if(word_match)
			   end // else: !if(word_match_alt_d1)
		  end // if (din_valid)
		else
		  begin
			 wd1_valid <= 1'b0;
			 spl_hndl_d1 <= 1'b0;
			 wr_off_d1 <= 1'b0;
			 ptp_asm_d1 <= 2'b00;
			 wd2_in_next_cycle <= 1'b0;
		  end // else: !if(din_valid_d1)
		if (word_match_alt_d1)
		  wd1 <= wd1_alt;
		else
		  wd1 <= wd1_din;
	 end // always @ (posedge clk)
   

   reg [W2_WIDTH*8-1:0] wd2_din; // max W2_WIDTH bytes needed
   reg [W2_WIDTH*8-1:0] wd2; // max W2_WIDTH bytes needed

   always @(*)
	 begin
		if ((WORDS == 4) && (reqd_offset_d1[4] == 1'b0))
		  wd2_din = din_d2[127:(16-W2_WIDTH)*8];
		else
		  wd2_din = din_d1[WORDS*8*8-1:(WORDS*8-W2_WIDTH)*8];
	 end

   always @(posedge clk)
	 begin
		din_d2 <= din_d1[127:0];
		wd2 <= wd2_din;
//		if ((WORDS == 4) && (reqd_offset_d1[4] == 1'b0))
//		  wd2 <= din_d2[127:(16-W2_WIDTH)*8];
//		else
//		  wd2 <= din_d1[WORDS*8*8-1:(WORDS*8-W2_WIDTH)*8];
	 end
   

   wire [2*64-1:0] wd1_dl1;
   wire 		   wd1_valid_dl1;
   wire 		   spl_hndl_dl1;
   wire 		   wr_off_dl1;
   wire [1:0] 		   ptp_asm_dl1;
   wire [15:0] 	   reqd_offset_dl1;

   wire [W2_WIDTH*8-1:0] wd2_dl2;
   wire 				 wd2_valid_dl2;

   generate
	  if (WORDS == 4)
		begin: w4_1
		   delay_mlab #
			 (
			  .LATENCY(5),
			  .WIDTH(160),
			  .FRACTURE(4),
			  .TARGET_CHIP(TARGET_CHIP)
			  )
		   dl1
			 (
			  .din({wd1,(wd1_valid&(~wd2_in_next_cycle)),reqd_offset_d1,spl_hndl_d1,wr_off_d1,ptp_asm_d1}),
			  .dout({wd1_dl1,wd1_valid_dl1,reqd_offset_dl1,spl_hndl_dl1,wr_off_dl1,ptp_asm_dl1}),
			  .clk(clk)
			  );
		   delay_mlab #
			 (
			  .LATENCY(4),
			  .WIDTH(100),
			  .FRACTURE(2),
			  .TARGET_CHIP(TARGET_CHIP)
			  )
		   dl2
			 (
			  .din({din_valid_d1,wd2}),
			  .dout({wd2_valid_dl2,wd2_dl2}),
			  .clk(clk)
			  );
		end // block: w4
	  else
		begin:w2_1 // 2 words 40g AMs for 2 cycles only
   reg [2*64-1:0]  wd1_dl1_reg;
   reg 			   wd1_valid_dl1_reg;
   reg [15:0] 	   reqd_offset_dl1_reg;
   reg 			   spl_hndl_dl1_reg;
   reg 			   wr_off_dl1_reg;
   reg [1:0]			   ptp_asm_dl1_reg;
   
   reg [2*64-1:0]  wd1_dl1_reg1;
   reg 			   wd1_valid_dl1_reg1;
   reg [15:0] 	   reqd_offset_dl1_reg1;
   reg 			   spl_hndl_dl1_reg1;
   reg 			   wr_off_dl1_reg1;
   reg [1:0]			   ptp_asm_dl1_reg1;
   
   reg [W2_WIDTH*8-1:0] wd2_dl2_reg;
   reg 				 wd2_valid_dl2_reg;
//		   delay_mlab #
//			 (
//			  .LATENCY(2),
//			  .WIDTH(160),
//			  .FRACTURE(4),
//			  .TARGET_CHIP(TARGET_CHIP)
//			  )
//		   dl1
//			 (
//			  .din({wd1,(wd1_valid&(~wd2_in_next_cycle)),reqd_offset_d1,ptp_asm_d1}),
//			  .dout({wd1_dl1,wd1_valid_dl1,reqd_offset_dl1,ptp_asm_dl1}),
//			  .clk(clk)
//			  );
		   always @(posedge clk)
			 begin
				{wd1_dl1_reg1,wd1_valid_dl1_reg1,reqd_offset_dl1_reg1,spl_hndl_dl1_reg1,wr_off_dl1_reg1,ptp_asm_dl1_reg1} <= 
                        {wd1,(wd1_valid&(~wd2_in_next_cycle)),reqd_offset_d1,spl_hndl_d1,wr_off_d1,ptp_asm_d1};
				{wd1_dl1_reg,wd1_valid_dl1_reg,reqd_offset_dl1_reg,spl_hndl_dl1_reg,wr_off_dl1_reg,ptp_asm_dl1_reg} <= 
						{wd1_dl1_reg1,wd1_valid_dl1_reg1,reqd_offset_dl1_reg1,spl_hndl_dl1_reg1,wr_off_dl1_reg1,ptp_asm_dl1_reg1};
			 end
		   assign {wd1_dl1,wd1_valid_dl1,reqd_offset_dl1,spl_hndl_dl1,wr_off_dl1,ptp_asm_dl1} = {wd1_dl1_reg,wd1_valid_dl1_reg,reqd_offset_dl1_reg,spl_hndl_dl1_reg,wr_off_dl1_reg,ptp_asm_dl1_reg};
		   always @(posedge clk)
			 begin
				wd2_dl2_reg <= wd2;
				wd2_valid_dl2_reg <= din_valid_d1;
			 end
				
		   assign {wd2_valid_dl2,wd2_dl2} = {wd2_valid_dl2_reg,wd2_dl2_reg};
		end // block: w2_1
	  endgenerate
   
   
   
   reg [2*64-1:0] 	   wd1_del;
   reg 				   wd1_valid_del;
   reg [15:0] 		   reqd_offset_del;
   reg 				   spl_hndl_del;
   reg 				   wr_off_del;
   reg [1:0]				   ptp_asm_del;

   always @(posedge clk)
	 begin
		wd1_del <= wd1_dl1;
		wd1_valid_del <= wd1_valid_dl1;
		reqd_offset_del <= reqd_offset_dl1;
		spl_hndl_del <= spl_hndl_dl1;
		wr_off_del <= wr_off_dl1;
		ptp_asm_del <= ptp_asm_dl1;
	 end
   
   reg [W2_WIDTH*8-1:0] 		  wd2_del;
   reg 							  wd2_valid_del;
   

   always @(posedge clk)
	 begin
		wd2_del <= wd2_dl2;
		wd2_valid_del <= wd2_valid_dl2;
	 end

   reg [(2*8+W2_WIDTH)*8-1:0] dout_vec;
   
   always @(*)
	 begin
		if (wd2_valid_del)
		  dout_vec = {wd1_del,wd2_del};
		else
		  dout_vec = {wd1_del,wd2};
	 end

//   always @(posedge clk)
//	 begin
//		dout <= dout_vec;
//		dout_valid <= wd1_valid_del;
//		dout_ipg <= ~wd2_valid_del; // if wd2 is valid then there is no ipg between
//		dout_offset <= reqd_offset_del;
//		dout_ptp_asm <= ptp_asm_del;
//		dout_offset_cp1 <= reqd_offset_del[3:2]; // needed only for mux selects
//	 end

   always @(posedge clk)
	 begin
		if (wd1_valid_del)
		  begin
			 dout <= dout_vec;
			 dout_valid <= wd1_valid_del;
			 dout_ipg <= ~wd2_valid_del; // if wd2 is valid then there is no ipg between
			 dout_offset <= reqd_offset_del;
			 dout_spl_hndl <= spl_hndl_del;
			 dout_wr_off <= wr_off_del;
			 dout_ptp_asm <= ptp_asm_del;
			 dout_offset_cp1 <= reqd_offset_del[3:2]; // needed only for mux selects
		  end
		else
		  begin
			 dout <= {wd1,wd2_din};
			 dout_valid <= wd2_in_next_cycle;
			 dout_ipg <= 1'b0; // if wd2 is valid then there is no ipg between
			 dout_offset <= reqd_offset_d1;
			 dout_spl_hndl <= spl_hndl_d1;
			 dout_wr_off <= wr_off_d1;
			 dout_ptp_asm <= ptp_asm_d1;
			 dout_offset_cp1 <= reqd_offset_d1[3:2]; // needed only for mux selects
		  end // else: !if(wd2_valid_del)
	 end // always @ (posedge clk)
   assign pre_dout_valid = wd1_valid;
   assign pre_dout_spl_hndl = spl_hndl_d1;
		
endmodule // alt_aeu_ptp_extr

