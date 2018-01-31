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

module alt_aeu_ptp_2calc
  #(
    parameter TARGET_CHIP = 2 // 2: stratix v, 5: arria 10
    )    
   (
	input srst,

    input ing_ts_96_valid,
	input [95:0] ing_ts_96,

	input rd_ing_ts_96,
	output [95:0] ing_ts_96_2calc,
	output ing_ts_96_2calc_valid,

    input clk
   
	);


    sc_fifo_ptp #(
        .DEVICE_FAMILY       ((TARGET_CHIP == 2) ? "Stratic V" : "Arria 10"),
        .ENABLE_MEM_ECC      (0),
        .REGISTER_ENC_INPUT  (0),
        
        .SYMBOLS_PER_BEAT    (1),
        .BITS_PER_SYMBOL     (96),   //Data width, eg: 96 for TODp FIFO
        .FIFO_DEPTH          (8),            //FIFO Depth
        .CHANNEL_WIDTH       (0),
        .ERROR_WIDTH         (0),
        .USE_PACKETS         (0)
    ) fpf (
        .clk               (clk),                      // clock signal                         
        .reset             (srst),          //active high reset                  
        .in_data           (ing_ts_96),
        .in_valid          (ing_ts_96_valid),                    //push sc fifo signal
        .in_ready          (),                                     
        .out_data          (ing_ts_96_2calc),
        .out_valid         (ing_ts_96_2calc_valid),    //sc fifo not empty signal, 1 indicate not empty   
        .out_ready         (rd_ing_ts_96),                 //pop sc fifo signal
        .in_startofpacket  (1'b0),                                 
        .in_endofpacket    (1'b0),                                 
        .out_startofpacket (),                                     
        .out_endofpacket   (),                                     
        .in_empty          (1'b0),                                 
        .out_empty         (),                                     
        .in_error          (1'b0),                                 
        .out_error         (),                                     
        .in_channel        (1'b0),                                 
        .out_channel       (),
        .ecc_err_corrected (),
        .ecc_err_fatal     ()
    );

endmodule // alt_aeu_ptp_2calc

