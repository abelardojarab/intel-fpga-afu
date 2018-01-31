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

module alt_aeu_dly_mlab
  #(
    parameter TARGET_CHIP = 2, // 2: stratix v, 5: arria 10
	parameter LATENCY = 10,
	parameter FRACTURE = 1,
    parameter WIDTH = 4 // 4 for 100G
    )    
   (

	input [WIDTH-1:0] din,
	output reg [WIDTH-1:0] dout,
    input clk
	);

   reg [WIDTH-1:0] 		   din_reg;
   wire [WIDTH-1:0] 	   dout_mlab0;

   localparam LATENCY_0 = (LATENCY-2) / 2;
   localparam LATENCY_1 = LATENCY -2 - ((LATENCY-2) / 2);
   
   defparam dm0. LATENCY = LATENCY_0;
   defparam dm0. TARGET_CHIP = TARGET_CHIP;
   defparam dm0. WIDTH = WIDTH;
   defparam dm0. FRACTURE = FRACTURE;
   
   delay_mlab dm0
	 (
	  .clk(clk),
	  .din(din_reg),
	  .dout(dout_mlab0)
	  );

   reg [WIDTH-1:0] 		   d_int;
   
   always @(posedge clk)
	 d_int <= dout_mlab0;
   
   defparam dm1. LATENCY = LATENCY_1-1;
   defparam dm1. TARGET_CHIP = TARGET_CHIP;
   defparam dm1. WIDTH = WIDTH;
   defparam dm1. FRACTURE = FRACTURE;

   wire [WIDTH-1:0] 	   dout_mlab1;
   delay_mlab dm1
	 (
	  .clk(clk),
	  .din(d_int),
	  .dout(dout_mlab1)
	  );

   always @(posedge clk)
	 begin
		din_reg <= din;
		dout <= dout_mlab1;
	 end

endmodule // alt_aeu_dly_mlab











