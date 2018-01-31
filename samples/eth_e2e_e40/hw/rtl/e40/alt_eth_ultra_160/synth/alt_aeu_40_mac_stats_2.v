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


//_______________________________________________________________________________________________
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/mac/alt_aeu_40_mac_stats_2.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
//_______________________________________________________________________________________________
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
//_______________________________________________________________________________________________
// dubey 07.2013

`timescale 1 ps / 1 ps
 module alt_aeu_40_mac_stats_2 #(
     parameter BASE = 0 
    ,parameter REVID = 32'h04142014
    ,parameter TARGET_CHIP = 2  
    ,parameter ERRORBITWIDTH  = 16   
    ,parameter STATSBITWIDTH  = 32   
    ,parameter SYNOPT_PREAMBLE_PASS = 1  
    ,parameter WORDS = 2 
 )(
     input wire clk 
    ,input wire reset 
 
    ,input wire cfg_crc_in_pkt 
    ,input wire[15:0] cfg_max_fsize 
    ,input wire in_phyready 
    ,input wire in_fcs_error                // referring to the non-zero last_data
    ,input wire in_fcs_valid 
    ,output wire out_fcs_error                // referring to the non-zero last_data
    ,output wire out_fcs_valid 
     
    ,input wire in_valid 
    ,input wire [WORDS*64-1:0] in_data 
    ,input wire [WORDS*8-1:0]  in_ctrl 
    ,input wire [WORDS-1:0]    in_sop 
    ,input wire [WORDS-1:0]    in_eop 
    ,input wire [WORDS*3-1:0]  in_eop_empty 
    ,input wire [WORDS-1:0]    in_idle 
  
    ,input  wire reset_csr   	
    ,input  wire clk_csr   	
    ,output wire serif_slave_dout 
    ,input  wire serif_slave_din 

    ,output wire[ERRORBITWIDTH-1:0] out_error 
    ,output wire[STATSBITWIDTH-1:0] out_stats
 );


 // _________________________________________________________________
 //	header processor
 // _________________________________________________________________

   alt_aeu_40_hproc_2  #(
	 .WORDS  		(WORDS) 
	,.SYNOPT_PREAMBLE_PASS  (SYNOPT_PREAMBLE_PASS)
	,.ERRORBITWIDTH 	(ERRORBITWIDTH)
	,.STATSBITWIDTH 	(STATSBITWIDTH)
   )hdr_proc(
	 .clk			(clk)
	,.reset	        	(reset)
                        	             
   	,.cfg_crc_included  	(cfg_crc_in_pkt)
        ,.cfg_max_frm_length	(cfg_max_fsize)

   	,.in_dp_phyready	(in_phyready)
   	,.in_dp_valid   	(in_valid)
   	,.in_dp_ctrl    	(in_ctrl)
    	,.in_dp_idle    	(in_idle)
    	,.in_dp_sop     	(in_sop)
    	,.in_dp_eop     	(in_eop)
   	,.in_dp_data    	(in_data)
    	,.in_dp_eop_empty       (in_eop_empty)

	,.in_dpfcs_error      	(in_fcs_error)
	,.in_dpfcs_valid      	(in_fcs_valid)
	,.out_dpfcs_error     	(out_fcs_error)
	,.out_dpfcs_valid     	(out_fcs_valid)

	,.out_dp_stats	    	(out_stats)
	,.out_dp_error         	(out_error)
   	);

 // _________________________________________________________________
 //	the stats collection module
 // _________________________________________________________________
   alt_aeu_40_stats_reg #(
	 .BASE		(BASE)  
        ,.REVID   	(REVID)
	,.NUMSTATS  	(STATSBITWIDTH) 
	,.TARGET_CHIP  	(TARGET_CHIP)  
   ) statsreg (
	 .clk		(clk)
	,.reset	  	(reset)
	,.in_stats	(out_stats)
	,.clk_csr 	(clk_csr)
	,.reset_csr 	(reset_csr)
	,.serif_master_dout(serif_slave_din)
	,.serif_slave_dout (serif_slave_dout)
        );

endmodule

