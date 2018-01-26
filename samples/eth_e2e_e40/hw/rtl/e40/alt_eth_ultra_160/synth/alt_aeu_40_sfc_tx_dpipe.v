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


// ____________________________________________________________________
// $Id: //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/mac/e100_mac_tx_4.v#15 $
// $Revision: #15 $
// $Date: 2013/07/29 $
// $Author: adubey $
// Copyright(C) 2013: Altera Corporation
// Altera corporation Confidential 
// ____________________________________________________________________

 module alt_aeu_40_sfc_tx_dpipe 
     #(parameter WIDTH = 524 //+5+6+1 
      )(
       input wire clk 
      ,input wire out_ready 
      ,output reg in_ready 
      ,input wire [WIDTH-1:0] in_data      
      ,output reg [WIDTH-1:0] out_data 
     );

   // ___________________________________________________

    initial out_data = 0;

    always@(posedge clk)
       begin
	  if (out_ready) out_data <= in_data;
	  in_ready <= out_ready;
       end

 endmodule

 

