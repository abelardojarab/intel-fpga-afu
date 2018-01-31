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

module alt_aeu_fld_mod
  #(
    parameter TARGET_CHIP = 2, // 2: stratix v, 5: arria 10
    parameter WORDS = 4
    )    
   (
	input srst,

    input [WORDS*8*8-1:0] din,
	input din_valid,
    input [WORDS*8*8-1:0] din_crc,
    input [WORDS*8*8-1:0] din_mlab,
	input [WORDS*8-1:0] din_mask,
	input [WORDS-1:0] din_sops,
	input [WORDS*8-1:0] din_eop_pos,

    output reg [WORDS*8*8-1:0] dout_crc,
	output reg 				   dout_valid,
    output reg [WORDS*8*8-1:0] dout_mlab,
	output reg [WORDS-1:0] 	   dout_sops,
	output reg [WORDS*8-1:0]   dout_eop_pos,

    input clk
   
	);

   genvar 					   i;
   generate
	  for (i=0; i<WORDS*8; i=i+1)
		begin: fr
		   always @(posedge clk)
			 begin
				if (din_valid)
				  begin
					 if (din_mask[i] == 1'b1)
					   begin
						  dout_crc[(i+1)*8-1:i*8] <= din[(i+1)*8-1:i*8];
						  dout_mlab[(i+1)*8-1:i*8] <= din[(i+1)*8-1:i*8];
					   end
					 else
					   begin
						  dout_crc[(i+1)*8-1:i*8] <= din_crc[(i+1)*8-1:i*8];
						  dout_mlab[(i+1)*8-1:i*8] <= din_mlab[(i+1)*8-1:i*8];
					   end
				  end // if (din_valid)
				else
				  begin
					 dout_crc[(i+1)*8-1:i*8] <= dout_crc[(i+1)*8-1:i*8];
					 dout_mlab[(i+1)*8-1:i*8] <= din_mlab[(i+1)*8-1:i*8];
				  end // else: !if(din_valid)
			 end // always @ (posedge clk)
		end // block: fr
   endgenerate

   always @(posedge clk)
	 begin
		dout_valid <= din_valid;
		dout_sops <= din_sops;
		dout_eop_pos <= din_eop_pos;
	 end
   
endmodule // alt_aeu_fld_mod



