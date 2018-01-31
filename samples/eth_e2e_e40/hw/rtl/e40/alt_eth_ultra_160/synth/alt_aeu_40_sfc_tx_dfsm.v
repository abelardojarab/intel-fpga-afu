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

 module alt_aeu_40_sfc_tx_dfsm 
     #(parameter WORDS = 8, EMPTYBITS = 6)
      (
       input wire clk 
      ,input wire rst_n 
      ,input wire sel_store			// stored when high

 //    data-path source port 
      ,input wire in_valid	      		// daa val
      ,input wire in_sop   	
      ,input wire in_eop   	
      ,input wire [WORDS*64-1:0] in_data   	// sop word
      ,input wire [EMPTYBITS-1:0] in_empty 	// eop byte(one hot)

      ,output wire out_valid      		// daa val
      ,output wire out_sop  	// sop word
      ,output wire out_eop  	// sop word
      ,output wire [WORDS*64-1:0] out_data 	// sop word
      ,output wire [EMPTYBITS-1:0] out_empty 	// eop byte(one hot)

 //    fsm control port
      ,output wire pkt_end
     );

 // ____________________________________________________________________
    assign pkt_end = in_valid & in_eop;
 
 endmodule


