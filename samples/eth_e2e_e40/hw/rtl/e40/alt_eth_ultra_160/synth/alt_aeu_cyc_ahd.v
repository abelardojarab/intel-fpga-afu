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

module alt_aeu_cyc_ahd
  #(
    parameter WORDS = 2
    )    
   (
    input din_valid,
	output [15:0] cyc_ahd,

    input clk
   
	);

   reg [2:0] 		  cnt;
   
   generate
	  if (WORDS == 4)

		begin:w4
		   always @(posedge clk)
			 begin
				if (!din_valid)
				  begin
					 cnt <= 3'd0;
				  end
				else
				  begin
					 if (cnt == 3'd4)
					   cnt <= 3'd0;
					 else
					   cnt <= cnt + 3'd1;
				  end // else: !if(din_valid)
			 end // always @ (posedge clk)

//		   always @(posedge clk)
//			 begin
//				case (cnt) // synthesis parallel_case
//				  3'd0: cyc_ahd <= 16'h45_80;
//				  3'd1: cyc_ahd <= 16'h44_80;
//				  3'd2: cyc_ahd <= 16'h43_80;
//				  3'd3: cyc_ahd <= 16'h42_80;
//				  3'd4: cyc_ahd <= 16'h41_80;
//				endcase // case (cnt)
//			 end
		end // block: w4
	  else
		begin: w2
		   always @(posedge clk)
			 begin
				if (!din_valid)
				  begin
					 cnt <= 1'd0;
				  end
				else
				  begin
					 cnt <= ~cnt;
				  end // else: !if(din_valid)
			 end // always @ (posedge clk)

//		   always @(posedge clk)
//			 begin
//				case (cnt) // synthesis parallel_case
//				  3'd0: cyc_ahd <= 16'h45_80;
//				  3'd1: cyc_ahd <= 16'h44_80;
//				endcase // case (cnt)
//			 end
		end // block: w2
	  endgenerate

   assign cyc_ahd = cnt;
endmodule // alt_aeu_cyc_ahead

