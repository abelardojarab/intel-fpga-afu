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

module alt_aeu_fld_shl
  #(
    parameter TARGET_CHIP = 2, // 2: stratix v, 5: arria 10
	parameter W2_WIDTH = 9,
	parameter MAX_WIDTH = 16 + W2_WIDTH, 
    parameter WORDS = 2 // this module gets oly two words + w2_width worth bytes
    )    
   (
	input srst,

    input din_valid,
	input din_ipg,
    input [MAX_WIDTH*8-1:0] din,
	input [1:0] din_ptp_asm,
    input [15:0] din_offset,
    input din_spl_hndl,
	input din_wr_off,
    input [1:0] din_offset_cp1,

    output reg dout_valid,
	output reg dout_ipg,
    output reg [(W2_WIDTH+1)*8-1:0] dout,
	output reg [1:0] dout_ptp_asm,
	output reg [15:0] dout_offset,
	output reg dout_spl_hndl,
	output reg dout_wr_off,

    input clk
   
	);

   reg [(4+W2_WIDTH)*8-1:0] 			 vec00, vec01, vec10, vec11;

   always @(*)
	 begin
		vec00 = din[MAX_WIDTH*8-1:(MAX_WIDTH-4-W2_WIDTH)*8];
		vec01 = din[(MAX_WIDTH-4)*8-1:(MAX_WIDTH-8-W2_WIDTH)*8];
		vec10 = din[(MAX_WIDTH-8)*8-1:(MAX_WIDTH-12-W2_WIDTH)*8];
		vec11 = din[(MAX_WIDTH-12)*8-1:(MAX_WIDTH-16-W2_WIDTH)*8];
	 end

   reg [(4+W2_WIDTH)*8-1:0] din_d1;

   generate
	  if (W2_WIDTH == 1)
		begin: w2_wd_1
		   always @(posedge clk)
			 begin
				case (din_offset[3:2]) // synthesis parallel_case
				  2'b00: din_d1 <= vec00;
				  2'b01: din_d1 <= vec01;
				  2'b10: din_d1 <= vec10;
				  2'b11: din_d1 <= vec11;
				endcase // case (din_offset[3:2])
			 end

		end
	  else
		begin: W2_wd_ne_1
		   
		   always @(posedge clk)
			 begin
				case (din_offset[3:2]) // synthesis parallel_case
				  2'b00: din_d1[(4+W2_WIDTH)*8-1:(4+W2_WIDTH-6)*8] <= vec00[(4+W2_WIDTH)*8-1:(4+W2_WIDTH-6)*8];
				  2'b01: din_d1[(4+W2_WIDTH)*8-1:(4+W2_WIDTH-6)*8] <= vec01[(4+W2_WIDTH)*8-1:(4+W2_WIDTH-6)*8];
				  2'b10: din_d1[(4+W2_WIDTH)*8-1:(4+W2_WIDTH-6)*8] <= vec10[(4+W2_WIDTH)*8-1:(4+W2_WIDTH-6)*8];
				  2'b11: din_d1[(4+W2_WIDTH)*8-1:(4+W2_WIDTH-6)*8] <= vec11[(4+W2_WIDTH)*8-1:(4+W2_WIDTH-6)*8];
				endcase // case (din_offset[3:2])
			 end

		   always @(posedge clk)
			 begin
				case (din_offset_cp1) // synthesis parallel_case
				  2'b00: din_d1[(4+W2_WIDTH-6)*8-1:0] <= vec00[(4+W2_WIDTH-6)*8-1:0];
				  2'b01: din_d1[(4+W2_WIDTH-6)*8-1:0] <= vec01[(4+W2_WIDTH-6)*8-1:0];
				  2'b10: din_d1[(4+W2_WIDTH-6)*8-1:0] <= vec10[(4+W2_WIDTH-6)*8-1:0];
				  2'b11: din_d1[(4+W2_WIDTH-6)*8-1:0] <= vec11[(4+W2_WIDTH-6)*8-1:0];
				endcase // case (din_offset[3:2])
			 end
		end // block: W2_wd_ne_1
   endgenerate
   
	  

   reg [15:0] din_offset_d1;
   reg 		  din_spl_hndl_d1;
   reg 		  din_wr_off_d1;
   reg 		 din_valid_d1;
   reg 		 din_ipg_d1;
   reg [1:0]  		 din_ptp_asm_d1;
   
   
   always @(posedge clk)
	 begin
		din_offset_d1 <= din_offset;
		din_spl_hndl_d1 <= din_spl_hndl;
		din_wr_off_d1 <= din_wr_off;
		din_valid_d1 <= din_valid;
		din_ipg_d1 <= din_ipg;
		din_ptp_asm_d1 <= din_ptp_asm;
	 end

   reg [(W2_WIDTH+1)*8-1:0] dout_reg;
   
   always @(posedge clk)
	 begin
		case (din_offset_d1[1:0])
		  2'b00: dout_reg[(W2_WIDTH+1)*8-1:0] <= din_d1[(4+W2_WIDTH-0)*8-1:(3-0)*8];
		  2'b01: dout_reg[(W2_WIDTH+1)*8-1:0] <= din_d1[(4+W2_WIDTH-1)*8-1:(3-1)*8];
		  2'b10: dout_reg[(W2_WIDTH+1)*8-1:0] <= din_d1[(4+W2_WIDTH-2)*8-1:(3-2)*8];
		  2'b11: dout_reg[(W2_WIDTH+1)*8-1:0] <= din_d1[(4+W2_WIDTH-3)*8-1:(3-3)*8];
		endcase // case (din_offset_d1[1:0])
		dout_offset <= din_offset_d1;
		dout_spl_hndl <= din_spl_hndl_d1;
		dout_wr_off <= din_wr_off_d1;
		dout_valid <= din_valid_d1;
		dout_ipg <= din_ipg_d1;
		dout_ptp_asm <= din_ptp_asm_d1;
	 end // always @ (posedge clk)

   always @(*)
	 begin
		if (dout_spl_hndl)
		  dout = (dout_reg >> 16);
		else
		  dout = dout_reg;
	 end
endmodule // alt_aeu_fld_shl
