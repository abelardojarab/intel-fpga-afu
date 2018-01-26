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

module alt_aeu_ptp_rx_40 #
  (
   parameter TARGET_CHIP = 2,
   parameter SYNOPT_PTP = 1,
   parameter SYNOPT_TOD_FMT = 0,
   parameter WORDS = 4,
   parameter DBG_WIDTH = 4,
   parameter EMPTYBITS = 5,
   parameter RXERRWIDTH = 6,
   parameter RXSTATUSWIDTH = 3
   )
   (
    input rst_rxmac,
    input [19:0] rxmclk_period,
	input [31:0] rx_pma_delay,
    input [95:0] tod_rxmclk,

    input [95:0] tod_96b_rxmac_in,
    input [63:0] tod_64b_rxmac_in,
    input rxmac_sop_in,
    input [8:0] dsk_av_depth,

    input din_valid,
    input [WORDS*64-1:0] din,
    input din_sop,
    input din_eop,
    input [EMPTYBITS-1:0] din_empty,
    input din_pkt_del,
    input [RXERRWIDTH-1:0] din_fcs_error,
    input [RXSTATUSWIDTH-1:0] din_rx_status,    
    input din_fcs_valid,
    input [DBG_WIDTH-1:0] dbg_in,

    output reg dout_valid,
    output reg [WORDS*64-1:0] dout,
    output reg                dout_sop,
    output reg                dout_eop,
    output reg [EMPTYBITS-1:0] dout_empty,
    output reg [RXERRWIDTH-1:0] dout_fcs_error,
    output reg [RXSTATUSWIDTH-1:0] dout_rx_status,    
    output reg                 dout_fcs_valid,
    output reg [DBG_WIDTH-1:0] dbg_out,
    output reg [159:0]          rx_tod,

    input clk_rxmac
    );
   
   wire [31:0]                 tot_rx_dly;
   wire [95:0]                 tod_rx_clk_sub;
   wire [159:0]                 rx_tod_ff;
   

   generate
      if (SYNOPT_PTP == 1)
        begin: p1
           
           alt_aeu_dsk_dly add // adds delay from serdes to mac, tot he average fifo depth delay
             (
              .period(rxmclk_period),
              .depth(dsk_av_depth),
              .clk(clk_rxmac),
              .tot_dly(tot_rx_dly)
              );
           defparam add.TARGET_CHIP = TARGET_CHIP;
           
           reg [95:0] tod_rxmclk_d1;
           always @(posedge clk_rxmac)
             tod_rxmclk_d1 <= tod_96b_rxmac_in;

           alt_aeu_sub_ts_96 sub 
             (
              .arst(rst_rxmac),
              .enable(1'b1),
              .inp_valid(1'b1),
              .inp1(tod_rxmclk_d1),
              .inp2({64'd0,tot_rx_dly}),
              .out_valid(),
              .res(tod_rx_clk_sub),
              .clk(clk_rxmac)
              );

           // match delay in the alt_aeu_sub_ts

		   wire nvl_valid_clc;
		   wire [95:0] nvl_96_fd1_clc;
		   wire [63:0] nvl_64_fd1_clc;

		   wire [15:0] mac_delay;
		   
		   assign mac_delay = (WORDS == 4) ? 16'h04_00 : 16'h04_00;
           if (TARGET_CHIP == 2)
             begin
                defparam s5.WIDTH = 160;
                defparam s5.ADDR_WIDTH = 7;
                wire        s5_full;
                wire        s5_empty;
                
                scfifo_s5m20k s5 
                  (
                   .clk(clk_rxmac),
                   .sclr(rst_rxmac),
//                   .data(tod_rx_clk_sub),
                   .wrreq(nvl_valid_clc),
                   .data({nvl_96_fd1_clc,nvl_64_fd1_clc}),
                   .full(s5_full),
                   .rdreq((din_sop & din_valid) | din_pkt_del),
                   .q(rx_tod_ff),
                   .empty(s5_empty)
                   );
             end // if (TARGET_CHIP == 2)
           else
             begin
                defparam a10.WIDTH = 160;
                defparam a10.ADDR_WIDTH = 7;
                wire        a10_full;
                wire        a10_empty;
                
                scfifo_a10m20k a10 
                  (
                   .clk(clk_rxmac),
                   .sclr(rst_rxmac),
//                   .data(tod_rx_clk_sub),
                   .wrreq(nvl_valid_clc),
                   .data({nvl_96_fd1_clc,nvl_64_fd1_clc}),
                   .full(a10_full),
                   .rdreq((din_valid & din_sop)|din_pkt_del),
                   .q(rx_tod_ff),
                   .empty(a10_empty)
                   );
             end // else: !if(TARGET_CHIP == 2)

   alt_eth_1588_cal # 
	 (
	  .TIME_OF_DAY_FORMAT(SYNOPT_TOD_FMT),     //0 = 96b timestamp, 1 = 64b timestamp, 2= both 96b+64b timestamp
	  .DELAY_SIGN(1)      // Sign of the delay adjustment
      // TX: set this parameter to 0 (unsigned) to add delays to Tod
      // RX: set this parameter to 1 (signed) to subtract the delays from ToD                   
	  ) clc 
	   (
		// Common clock and Reset
		.clk(clk_rxmac),
		.rst_n(~rst_rxmac),
		//ctrl fifo to/from tod_calc block
		.ctrl_extractor_to_calc(6'h10),
		.non_empty_ctrl_fifo_extractor_to_calc(1'b1),
		.pop_ctrl_fifo_calc_to_extractor(),
		//todi fifo to/from cf_calc block
		.todi_extractor_to_calc(96'd0),
		.non_empty_todi_fifo_extractor_to_calc(1'b0),
		.pop_todi_fifo_calc_to_extractor(), // assign to _64 also
		// todp is fd1
		//todp fifo to/from cf_calc block
		.todp_extractor_to_calc(96'd0),
		.non_empty_todp_fifo_extractor_to_calc(1'b0),
		.pop_todp_fifo_calc_to_extractor(),
		// cf correctin field fd2
		//cf fifo to/from cf_calc block 
		.cf_extractor_to_calc(64'd0),
		.non_empty_cf_fifo_extractor_to_calc(1'b0),
		.pop_cf_fifo_calc_to_extractor(),
		// chka checksum field fd3
		//chka fifo to/from chka_calc block
		.chka_extractor_to_calc(16'd0),
		.non_empty_chka_fifo_extractor_to_calc(1'b0),
		.pop_chka_fifo_calc_to_extractor(),
		// inpput to fd1
		//tod_calc to inserter
		.push_tod_fifo_calc_to_inserter(nvl_valid_clc),
		.tod_calc_to_inserter_96(nvl_96_fd1_clc),
		.tod_calc_to_inserter_64(nvl_64_fd1_clc),
		// input to fd2
		//cf_calc to inserter
		.push_cf_fifo_calc_to_inserter(),
		.cf_calc_to_inserter(),
		// input to fd3
		//chka_calc to inserter
		.push_chka_fifo_calc_to_inserter(),
		.chka_calc_to_inserter(),

		// CSR Configuration Input
		.asymmetry_reg(19'd0),
		.pma_delay_reg(rx_pma_delay),
		.period(rxmclk_period),
		//SOP from deterministic latency point in MAC
		.sop_mac_to_calc(rxmac_sop_in),
		.path_delay_data(tot_rx_dly[21:0]),
		.mac_delay(mac_delay),
		.time_of_day_96b_data(tod_96b_rxmac_in),
		.time_of_day_64b_data(tod_64b_rxmac_in)
		);


           always @(posedge clk_rxmac)
             begin
                dout_valid <= din_valid;
                dout <= din;
                dout_empty <= din_empty;
                dout_sop <= din_sop;
                dout_eop <= din_eop;
                dout_fcs_error <= din_fcs_error;
                dout_rx_status <= din_rx_status;                
                dout_fcs_valid <= din_fcs_valid;
                dbg_out <= dbg_in;
             end
           always @(*)
             begin
                rx_tod = rx_tod_ff;
             end
        end // block: p1
      else

        begin
           always @(*)
             begin
                dout_valid = din_valid;
                dout = din;
                dout_empty = din_empty;
                dout_sop = din_sop;
                dout_eop = din_eop;
                dout_fcs_error = din_fcs_error;
                dout_rx_status = din_rx_status;         
                dout_fcs_valid = din_fcs_valid;
                dbg_out = dbg_in;
                rx_tod = 160'd0;
             end
        end // else: !if(SYNOPT_PTP == 1)
   endgenerate
   

endmodule // alt_aeu_ptp_rx_40




