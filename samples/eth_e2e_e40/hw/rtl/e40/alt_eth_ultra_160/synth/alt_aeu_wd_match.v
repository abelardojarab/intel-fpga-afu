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

module alt_aeu_wd_match
  #(
    parameter WORDS = 2 
    )    
   (
	input srst,

    input din_valid,
	input [79:0] din,
	input [15:0] din_offset,
	input din_spl_hndl,
    input din_ipg,

    output reg dout_valid,
	output reg [79:0] dout,
	output reg [15:0] dout_offset,
	output reg dout_spl_hndl,
	output reg dout_ipg,

    input clk
   
	);

   reg [15:0]  wd_cnt;
   reg [15:0]  wd_cnt_n1;

   reg 		   din_valid_d1;
   reg [79:0]  din_d1;
   reg [15:0]  din_offset_d1;
   reg 		   din_spl_hndl_d1;
   reg 		   din_ipg_d1;

   reg 		   dout_valid_tmp;
   reg [79:0]  dout_tmp;
   reg [15:0]  dout_offset_tmp;
   reg 		   dout_spl_hndl_tmp;
   reg 		   dout_ipg_tmp;

   generate
	  if (WORDS == 4)

		begin:w4
		   always @(posedge clk)
			 begin
				if (din_valid)
				  begin
					 din_offset_d1 <= din_offset;
					 din_spl_hndl_d1 <= din_spl_hndl;
					 din_ipg_d1 <= din_ipg;
					 din_d1 <= din;
				  end
				
				if (din_valid)
				  begin
					 din_valid_d1 <= 1'b1;
					 wd_cnt <= 16'd0;
					 wd_cnt_n1 <= 16'd32;
				  end
				else
				  begin
					 if (din_valid_d1)
					   begin
						  if (wd_cnt[15:5] == din_offset_d1[15:5])
							din_valid_d1 <= 1'b0;
					   end
					 wd_cnt <= wd_cnt + 16'd32;
					 wd_cnt_n1 <= wd_cnt_n1 + 16'd32;
				  end // else: !if(din_valid)

				if (din_valid_d1)
				  begin
					 if (wd_cnt_n1[15:5] == din_offset_d1[15:5])
					   dout_valid_tmp <= 1'b1;
					 else
					   dout_valid_tmp <= 1'b0;
					 if (dout_valid_tmp & (dout_valid == 1'b0))
					   begin
						  dout_valid <= 1'b1;
						  dout_offset <= dout_offset_tmp;
						  dout_spl_hndl <= dout_spl_hndl_tmp;
						  dout_ipg <= dout_ipg_tmp;
						  dout <= dout_tmp;
					   end
					 else
					   begin
						  if (wd_cnt[15:5] == din_offset_d1[15:5])
							begin
							   dout_valid <= 1'b1;
							   dout_offset <= din_offset_d1;
							   dout_spl_hndl <= din_spl_hndl_d1;
							   dout_ipg <= din_ipg_d1;
							   dout <= din_d1;
							end
						  else
							dout_valid <= 1'b0;
					   end // else: !if(wd_cnt_n1[15:4] == dout_offset_tmp[15:5])
				  end // if (din_valid_d1)
				else
				  begin
					 dout_valid <= 1'b0;
				  end // if (din_valid_d1)
			 end // always @ (posedge clk)
		   always @(posedge clk)
			 begin
				dout_offset_tmp <= din_offset_d1;
				dout_spl_hndl_tmp <= din_spl_hndl_d1;
				dout_ipg_tmp <= din_ipg_d1;
				dout_tmp <= din_d1;
			 end
		end // block: w4
	  else
		begin: w2
		   always @(posedge clk)
			 begin
				if (din_valid)
				  begin
					 din_offset_d1 <= din_offset;
					 din_spl_hndl_d1 <= din_spl_hndl;
					 din_ipg_d1 <= din_ipg;
					 din_d1 <= din;
				  end
				
				if (din_valid)
				  begin
					 din_valid_d1 <= 1'b1;
					 wd_cnt <= 16'd0;
				  end
				else
				  begin
					 if (din_valid_d1)
					   begin
						  if (wd_cnt[15:4] == din_offset_d1[15:4])
							din_valid_d1 <= 1'b0;
					   end
					 wd_cnt <= wd_cnt + 16'd16;
				  end

				if (din_valid_d1)
				  begin
					 if (wd_cnt[15:4] == din_offset_d1[15:4])
					   begin
						  dout_valid <= 1'b1;
						  dout_offset <= din_offset_d1;
						  dout_spl_hndl <= din_spl_hndl_d1;
						  dout_ipg <= din_ipg_d1;
						  dout <= din_d1;
					   end
					 else
					   begin
						  dout_valid <= 1'b0;
					   end // else: !if(wd_cnt[15:4] == din_offset_d1[15:4])
				  end // if (din_valid_d1)
				else
				  dout_valid <= 1'b0;
			 end // always @ (posedge clk)
		end // else: !if(WORDS == 4)
	  endgenerate
endmodule // alt_aeu_wd_match

