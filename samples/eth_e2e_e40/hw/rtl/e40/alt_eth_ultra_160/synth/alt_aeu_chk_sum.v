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

module alt_aeu_chk_sum
  (
   input [79:0] in1,
   input [63:0] in2,
   input over1_10,
   input over1_8,
   input over2_2,
   input over2_8,

   output reg [15:0] chk_sum,
   input clk
   );

   reg [95:0] in_vec;
   
   always @(posedge clk)
	 begin
		case ({over1_10,over1_8,over2_2,over2_8}) // synthesis parallel_case
		  4'b1010: in_vec <= {in1,in2[63:48]};
		  4'b0100: in_vec <= {in1[79:16],32'd0};
		  4'b0001: in_vec <= {in2,32'd0};
		  default: in_vec <= 96'd0;
		endcase // case ({over1_10,over1_8,over2_2,over2_8})
	 end

   reg [15:0] res54; // results of sum 5, 6
   reg [15:0] res32;
   reg [15:0] res10;
   reg 		  c54; // carry from sum of 5 and 6
   reg 		  c32;
   reg 		  c10;
   
   
   always @(posedge clk)
	 begin
		{c54,res54} <= in_vec [95:80] + in_vec[79:64];
		{c32,res32} <= in_vec[63:48] + in_vec[47:32];
		{c10,res10} <= in_vec[31:16] + in_vec [15:0];
	 end

   reg [15:0] res5432;
   reg [15:0] res1000;
   reg 		  c5432;
   reg [1:0]  c543210;

   always @(posedge clk)
	 begin
		{c5432,res5432} <= res54 + res32;
		res1000 <= res10;
		c543210 <= c54 + c32 + c10;
	 end

   reg cr;
   reg [1:0] c543210_d1;
   reg [15:0] res543210;
   
   always @(posedge clk)
	 begin
		{cr,res543210} <= res5432 + res1000 + c5432;
		c543210_d1 <= c543210;
	 end
   
	always @(posedge clk)
	  begin
		 chk_sum <= res543210 + cr + c543210_d1;
	  end
endmodule // alt_aeu_chk_sum

	
		
		
   
		  

