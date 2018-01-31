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


// $Id: $
// $Revision: $
// $Date: $
// $Author: $
//-----------------------------------------------------------------------------

module alt_aeu_40_pcs_ber
  #(
    parameter                            BLOCK_LEN     = 66,
    parameter                            NUM_BLOCKS    = 2
    )
    (
    input wire                           rstn,           // Active low Reset
    input wire                           clk,            // Clock
    input wire                           bypass_ber,     // Bypass BER Monitoring 
    input wire                           align_status_in,
    input wire                           data_in_valid,
    input wire [NUM_BLOCKS*BLOCK_LEN-1:0] rx_blocks,
    //input wire                         rx_test_en,     // Indicates receiver is in test pattern mode
    input wire [20:0]                    rxus_timer_window,  //MDIO for xus timer counter.  40G is 390625. 100G is 156250.
    input wire [6:0]                     rbit_error_total_cnt, // MDIO for BER count. 10G is 16-1. 40G/100G is 97-1.
    output wire                          hi_ber          // Indicates High BER detected
    //output wire                          pcs_status
   );


   //********************************************************************
   // Define variables 
   //********************************************************************
   genvar                                i;
   
   // Regs
   reg                                   align_status_q;
   //reg                                   rx_test_en_q;
   //reg                                   bypass_ber_q;
   
   
   // Wires
   wire [6:0]                 ber_cnt_ns;
   wire [6:0]                 ber_cnt_cs;

   //********************************************************************
   // Instantiate the BER SM
   //********************************************************************
   alt_aeu_40_pcs_ber_sm e40_pcs_ber_sm
     (
      .rstn                 (rstn),           // Active low Reset
      .clk                  (clk),            // Clock
      .bypass_ber           (bypass_ber),     // Bypass BER Monitoring 
      .align_status_in      (align_status_in),
      .data_in_valid        (data_in_valid),
      //.rx_test_en           (rx_test_en_q),   // Indicates receiver is in test pattern mode
      .rxus_timer_window    (rxus_timer_window),  //MDIO for 125us timer counter
      .rbit_error_total_cnt (rbit_error_total_cnt), //MDIO for BER count   
      .ber_cnt_ns           (ber_cnt_ns),         // Indicates BER Count
      .hi_ber               (hi_ber),          // Indicates High BER detected
      .ber_cnt_cs           (ber_cnt_cs)
      );
      
   //********************************************************************
   // Instantiate ber_cnt
   //********************************************************************
   alt_aeu_40_pcs_ber_cnt_ns e40_pcs_ber_cnt_ns
     (
      .clk                  (clk),
      .ber_cnt_cs           (ber_cnt_cs),
      .rx_blocks            (rx_blocks),
      .rbit_error_total_cnt (rbit_error_total_cnt),
      .ber_cnt_ns           (ber_cnt_ns)
      );
   defparam e40_pcs_ber_cnt_ns.NUM_BLOCKS  = NUM_BLOCKS;
   
endmodule // ber

         
   
   
