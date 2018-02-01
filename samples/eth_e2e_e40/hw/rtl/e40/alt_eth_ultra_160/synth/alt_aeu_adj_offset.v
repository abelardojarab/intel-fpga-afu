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

module alt_aeu_adj_offset
   (
	input srst,

	input [4:0] offset_adj,

	input [15:0] ts_offset_in,
	input [15:0] corr_offset_in,
	input [15:0] chk_sum_zero_offset_in,
	input [15:0] chk_sum_upd_offset_in,

	output reg [15:0] ts_offset_out,
	output reg [15:0] corr_offset_out,
	output reg [15:0] chk_sum_zero_offset_out,
	output reg [15:0] chk_sum_upd_offset_out,

    input clk
   
	);

   always @(posedge clk)
	 begin
		ts_offset_out <= ts_offset_in + offset_adj;
		corr_offset_out <= corr_offset_in + offset_adj;
		chk_sum_zero_offset_out <= chk_sum_zero_offset_in + offset_adj;
		chk_sum_upd_offset_out <= chk_sum_upd_offset_in + offset_adj;
	 end
   
endmodule // alt_aeu_adj_offset







