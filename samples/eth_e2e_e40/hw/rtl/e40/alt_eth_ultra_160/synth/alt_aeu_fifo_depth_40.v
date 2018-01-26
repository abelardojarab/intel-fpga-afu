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
// $Author: pscheidt $
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

//
// Calculates average fifo depth of 20 fifos
// 16 fifos are chosen at random
// well, not quite.
// 16 fifos are chosen statically
// 

module alt_aeu_fifo_depth_40#
  (	parameter SYNOPT_FULL_SKEW = 1
)
  (
   input clk,

   input [35:0] wpos, // 20 bits, 4 vlanes,
   input [3:0] en, // all ones

   output [8:0] av_depth

   );

   reg [9:0] tot_1;
   reg [9:0] tot_2;
   reg [10:0] tot;
   reg [10:0] tot_adj;
   
   always @(posedge clk)
     begin
	if (SYNOPT_FULL_SKEW)
	  begin
	     tot_1  <= wpos[35:27] + wpos[26:18];
	     tot_2  <= wpos[17:9] + wpos[8:0];
	  end
	else
	  begin
	     tot_1  <= wpos[19:15] + wpos[14:10];
	     tot_2  <= wpos[9:5] + wpos[4:0];
	  end
	
	tot  <= tot_1 + tot_2;
     end

   always @(posedge clk)
     begin
		tot_adj <= tot + 11'd1; // per empirical data
		
//	if (tot <= 7'd2)
//	  tot_adj <= 7'd0;
//	else
//	  tot_adj <= tot - 7'd2;
     end

   assign av_depth = tot_adj[10:2];

endmodule // alt_aeu_fifo_depth_40

	



