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
// Copyright(C) 2013: Altera Corporation
// $Id: alt_aeu_40_sfc_top.v,v 1.2 2015/01/23 22:38:14 marmstro Exp marmstro $
// $Revision: 1.2 $
// $Date: 2015/01/23 22:38:14 $
// $Author: marmstro $
// ____________________________________________________________________
// altera message_off 10036 10236
// adubey 06.2013

 module alt_aeu_40_sfc_top #( 
          parameter SYNOPT_ALIGN_FCSEOP = 0
         ,parameter TARGET_CHIP = 2 
         ,parameter CSRADDRSIZE = 8 
         ,parameter TXDBGWIDTH = 1 
         ,parameter RXDBGWIDTH = 3 
         ,parameter RXERRWIDTH = 6 
         ,parameter FCBITS = 1 
         ,parameter SYNOPT_PREAMBLE_PASS = 1 
         ,parameter BASE_TXFC = 0 
         ,parameter BASE_RXFC = 1 
         ,parameter REVID = 32'h04142014 
         ,parameter WORDS = 4 
         ,parameter DWIDTH = 512 
         ,parameter EMPTYBITS = 6
         ,parameter RXSTATUSWIDTH = 3 //RxCtrl
        )(
         input  wire clk_rx
        ,input  wire clk_tx
        ,input  wire reset_rx_n
        ,input  wire reset_tx_n
        ,input  wire clk_mm 
        ,input  wire reset_mm 
        ,input  wire smm_master_dout 
        ,output wire smm_slave_dout 

        ,output wire tx_in_ready
        ,input  wire tx_in_valid
        ,input  wire tx_in_sop
        ,input  wire tx_in_eop
        ,input  wire [DWIDTH-1:0] tx_in_data
        ,input  wire [EMPTYBITS-1:0]tx_in_empty 
        ,input  wire tx_in_error
        ,input  wire [TXDBGWIDTH-1:0] tx_in_debug
    
        ,input  wire tx_out_ready
        ,output wire tx_out_valid
        ,output wire tx_out_sop
        ,output wire tx_out_eop
        ,output wire [DWIDTH-1:0]tx_out_data
        ,output wire [EMPTYBITS-1:0] tx_out_empty 
        ,output wire tx_out_error
        ,output wire [TXDBGWIDTH-1:0] tx_out_debug

        ,output wire rx_in_ready
        ,input  wire rx_in_valid
        ,input  wire rx_in_sop
        ,input  wire rx_in_eop
        ,input  wire [WORDS*64-1:0]rx_in_data
        ,input  wire [EMPTYBITS-1:0] rx_in_empty 
        ,input  wire [RXERRWIDTH-1:0]    rx_in_error
        ,input  wire [RXSTATUSWIDTH-1:0] rx_in_status  
          
        ,input  wire rx_in_error_valid
        ,input  wire [RXDBGWIDTH-1:0] rx_in_debug

        ,input  wire rx_out_ready
        ,output wire rx_out_valid
        ,output wire rx_out_sop
        ,output wire rx_out_eop
        ,output wire [WORDS*64-1:0] rx_out_data
        ,output wire [EMPTYBITS-1:0] rx_out_empty 
        ,output wire [RXERRWIDTH-1:0]    rx_out_error 
        ,output wire [RXSTATUSWIDTH-1:0] rx_out_status  
        ,output wire rx_out_error_valid
        ,output wire [RXDBGWIDTH-1:0] rx_out_debug

        ,input  wire[FCBITS-1:0] tx_in_pause    // ingress buffer congestion indication 
        ,output wire[FCBITS-1:0] rx_out_pause   // pause signal to egress buffer 
      );

 // _________________________________________________________________
     localparam LATENCY_SRC_BKP = 3'd6;
 //


    wire rx_txoff_req;assign rx_out_pause = rx_txoff_req;
    wire smm_tx_dout, smm_rx_dout; assign smm_slave_dout = smm_tx_dout & smm_rx_dout;
 // _________________________________________________________________
        alt_aeu_40_sfc_tx       #(
         .FCBITS                ( FCBITS)
        ,.TARGET_CHIP           ( TARGET_CHIP)
        ,.SYNOPT_PREAMBLE_PASS  ( SYNOPT_PREAMBLE_PASS)
        ,.BASE_TXFC             ( BASE_TXFC)
        ,.REVID                 ( REVID)
        ,.WORDS                 ( WORDS)        // primarily to format pause frame
        ,.DWIDTH                ( DWIDTH)
        ,.EMPTYBITS             ( EMPTYBITS)
        )
 //     _________________________________________________________________
        tx                      (
         .clk_mm                (clk_mm)
        ,.reset_mm              (reset_mm)
        ,.smm_master_dout       (smm_master_dout)
        ,.smm_slave_dout        (smm_tx_dout)
        ,.clk                   (clk_tx) 
        ,.reset_n               (reset_tx_n)
        ,.in_eop                (tx_in_eop)
        ,.in_error              (tx_in_error)
        ,.in_sop                (tx_in_sop)
        ,.in_valid              (tx_in_valid)
        ,.in_data               (tx_in_data)
        ,.in_empty              (tx_in_empty) 
        ,.in_ready              (tx_in_ready)
        ,.in_debug              (tx_in_debug)
                                   
        ,.out_eop               (tx_out_eop)
        ,.out_error             (tx_out_error)
        ,.out_sop               (tx_out_sop)
        ,.out_valid             (tx_out_valid)
        ,.out_data              (tx_out_data)
        ,.out_empty             (tx_out_empty) 
        ,.out_ready             (tx_out_ready)
        ,.out_debug             (tx_out_debug)

        ,.in_pause_req          (tx_in_pause)
        ,.rx_txoff_req          (rx_txoff_req)
       );

 //     _________________________________________________________________
        alt_aeu_40_sfc_rx      #(
         .SYNOPT_ALIGN_FCSEOP   ( SYNOPT_ALIGN_FCSEOP)
        ,.FCBITS                ( FCBITS)
        ,.RXERRWIDTH            ( RXERRWIDTH)
        ,.TARGET_CHIP           ( TARGET_CHIP)
        ,.SYNOPT_PREAMBLE_PASS  ( SYNOPT_PREAMBLE_PASS)
        ,.REVID                 ( REVID)
        ,.BASE_RXFC             ( BASE_RXFC)
        ,.EMPTYBITS             ( EMPTYBITS)
        ,.RXSTATUSWIDTH         ( RXSTATUSWIDTH)                         
        )
 //     _________________________________________________________________
        rx                      (
         .clk                   (clk_rx)
        ,.reset_n               (reset_rx_n)
        ,.clk_mm                (clk_mm)
        ,.reset_mm              (reset_mm)
        ,.smm_master_dout       (smm_master_dout)
        ,.smm_slave_dout        (smm_rx_dout)

        ,.in_eop                (rx_in_eop)
        ,.in_error              (rx_in_error )
        ,.in_status             (rx_in_status) //RxCtrl                          
        ,.in_error_valid        (rx_in_error_valid)
        ,.in_sop                (rx_in_sop)
        ,.in_valid              (rx_in_valid)
        ,.in_data               (rx_in_data)
        ,.in_empty              (rx_in_empty)
        ,.in_ready              (rx_in_ready)

        ,.out_sband             (rx_out_debug)
        ,.out_eop               (rx_out_eop)
        ,.out_error             (rx_out_error )
        ,.out_status            (rx_out_status) //RxCtrl                                 
        ,.out_error_valid       (rx_out_error_valid)
        ,.out_sop               (rx_out_sop)
        ,.out_valid             (rx_out_valid)
        ,.out_data              (rx_out_data)
        ,.out_empty             (rx_out_empty) 
        ,.out_ready             (rx_out_ready)

        ,.out_pause             (rx_txoff_req)
       );

 // ____________________________________________________________________
 //

 endmodule
