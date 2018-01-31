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
// $Author: pscheidt $
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

module alt_aeu_clks_40 # 
  (
    parameter TARGET_CHIP = 2,
    parameter SYNOPT_PTP = 1,
    parameter REVID = 32'h04172014,
    parameter CSRADDRSIZE = 8,
    parameter BASE_TXPTP = 8,
    parameter BASE_RXPTP = 9
   )
   (
    // csr interface
    input reset_csr,
    input clk_csr,
    input serif_master_din,
    output serif_slave_out_ptp,

    input rst_txmac,
    input rst_rxmac,

    output ptp_v2,
    output ptp_s2,
    output [31:0] ext_lat,
    output [18:0] tx_asym_delay,
    output [31:0] tx_pma_delay,
    output cust_mode,
    output [19:0] txmclk_period,
    output [19:0] rxmclk_period,
    output [31:0] rx_pma_delay,

    input clk_txmac, // mac tx clk
    input clk_rxmac  // mac rx clk
);

    localparam RST_RXMCLK_PERIOD = 20'h3_3333; // mac clk period 3.2 ns
    localparam RST_TXMCLK_PERIOD = 20'h3_3333; // mac clk period 3.2 ns
    generate
        if (SYNOPT_PTP == 0) begin
            assign ptp_v2 = 1'b1;
            assign ptp_s2 = 1'b1;
            assign ext_lat = 32'd0;
            assign txmclk_period = 20'd0;
            assign rxmclk_period = 20'd0;
            assign serif_slave_out_ptp = 1'b1;
            assign tx_asym_delay = 19'd0;
            assign tx_pma_delay = 32'd0;
            assign rx_pma_delay = 32'd0;
            assign cust_mode = 1'b0;
        end
        else begin
            wire        serif_slave_dout_txm;
            wire        serif_slave_dout_rxm;

            assign serif_slave_out_ptp = serif_slave_dout_txm & serif_slave_dout_rxm;

            alt_aeu_txmclk_csr #(
                .BASE(BASE_TXPTP),
                .TARGET_CHIP(TARGET_CHIP)
            ) txmcsr (
                .reset_csr(reset_csr),
                .clk_csr(clk_csr), 
                .clk_slv    (clk_txmac),
                .reset_slv(rst_txmac),
                .serif_master_din(serif_master_din),
                .serif_slave_dout(serif_slave_dout_txm), 
                .rst_txmclk_period(RST_TXMCLK_PERIOD), // for now

                .ptp_s2(ptp_s2),
                .ptp_v2(ptp_v2),
                .ext_lat(ext_lat),
                .asym_delay(tx_asym_delay),
                .pma_delay(tx_pma_delay),
                .cust_mode(cust_mode),
                .txmclk_period(txmclk_period)
            );

            defparam txmcsr.REVID = REVID;

            alt_aeu_rxmclk_csr # (
                .BASE(BASE_RXPTP),
                .TARGET_CHIP(TARGET_CHIP)
            ) rxmcsr (
                .reset_csr(reset_csr),
                .clk_csr(clk_csr), 
                .clk_slv(clk_rxmac),
                .reset_slv(rst_rxmac),
                .serif_master_din(serif_master_din),
                .serif_slave_dout(serif_slave_dout_rxm), 
                .rst_rxmclk_period(RST_RXMCLK_PERIOD), // for now
                .pma_delay(rx_pma_delay),
                .rxmclk_period(rxmclk_period)
            );

            defparam rxmcsr.REVID = REVID;
        end // else: !if(SYNOPT_BYPASS_PTP)
    endgenerate
endmodule // alt_aeu_clks



