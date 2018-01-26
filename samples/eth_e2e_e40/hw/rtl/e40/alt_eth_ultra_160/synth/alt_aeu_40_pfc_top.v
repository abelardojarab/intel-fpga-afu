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


// (C) 2001-2014 Altera Corporation. All rights reserved.
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

`timescale 1 ps / 1 ps
 module alt_aeu_40_pfc_top #(
         parameter SYNOPT_PREAMBLE_PASS = 1,
         parameter SYNOPT_ALIGN_FCSEOP = 1,
         parameter REVID = 32'h04252014,
         parameter BASE_TXFC = 0,
         parameter BASE_RXFC = 1,
         parameter TARGET_CHIP = 2,
         parameter SYNOPT_NUMPRIORITY = 2,
         parameter RXERRWIDTH = 6,
         parameter RXSTATUSWIDTH = 3, //RxCtrl
         parameter TXDBGWIDTH = 1,
         parameter RXDBGWIDTH = 3,
         parameter WORDS = 4,
         parameter DWIDTH = WORDS * 64,
         parameter EMPTYBITS = 5
        )(
	 input clk_mm,
	input reset_mm,
	input smm_master_dout,
	output smm_slave_dout,

 //	source to pfc avalon st interface in tx dir 
	input clk_tx,
	input reset_tx_n,
	output tx_in_ready,
	input tx_in_eop,
	input tx_in_error,
	input tx_in_sop,
	input tx_in_valid,
	input [DWIDTH-1:0] tx_in_data,
	input [EMPTYBITS-1:0] tx_in_empty,
	input [TXDBGWIDTH-1:0] tx_in_debug, // dummy
    
 //	pfc to sink avalon st interface in tx dir 
	input clk_rx,
	input reset_rx_n,
	input tx_out_ready,
	output tx_out_eop,
	output tx_out_error,
	output tx_out_sop,
	output tx_out_valid,
	output [DWIDTH-1:0] tx_out_data,
	output [EMPTYBITS-1:0] tx_out_empty,
	output [TXDBGWIDTH-1:0] tx_out_debug, // dummy
	input [SYNOPT_NUMPRIORITY-1:0] tx_in_pause, // ingress buffer congestion indication
    output [SYNOPT_NUMPRIORITY-1:0] tx_inc_xon,
    output [SYNOPT_NUMPRIORITY-1:0] tx_inc_xoff,

 //	source to pfc avalon st interface in Rx dir 
	output rx_in_ready,
	input rx_in_eop,
	input [RXERRWIDTH-1:0]    rx_in_error,
	input rx_in_error_valid,
	input [RXSTATUSWIDTH-1:0] rx_in_status,
	input rx_in_sop,
	input rx_in_valid,
	input [WORDS*64-1:0] rx_in_data,
	input [EMPTYBITS-1:0] rx_in_empty,
	input [RXDBGWIDTH-1:0] rx_in_debug, // dummy

	input rx_out_ready,
	output rx_out_eop,
	output [RXERRWIDTH-1:0]    rx_out_error,
	output rx_out_error_valid,
	output [RXSTATUSWIDTH-1:0] rx_out_status,
	output rx_out_sop,
	output rx_out_valid,
	output [WORDS*64-1:0] rx_out_data,
	output [EMPTYBITS-1:0] rx_out_empty,
	output [RXDBGWIDTH-1:0] rx_out_debug, // dummy

	output [SYNOPT_NUMPRIORITY-1:0] rx_out_pause,	// pause signal to egress buffer
        output [SYNOPT_NUMPRIORITY-1:0] rx_inc_xon,	// pulses to count frames
        output [SYNOPT_NUMPRIORITY-1:0] rx_inc_xoff	// pulses to count frames
      );

    wire smm_tx_dout, smm_rx_dout; assign smm_slave_dout = smm_tx_dout & smm_rx_dout;

 	alt_aeu_40_pfc_tx 	       #(
        .TARGET_CHIP(TARGET_CHIP),
        .REVID(REVID),
        .BASE_TXFC(BASE_TXFC),
        .NUMPRIORITY(SYNOPT_NUMPRIORITY),
        .PREAMBLE_PASS(SYNOPT_PREAMBLE_PASS),
        .WORDS(WORDS),
        .DWIDTH(DWIDTH),
        .EMPTYBITS(EMPTYBITS)
	) tx (
	 .clk_mm(clk_mm),
	.reset_mm(reset_mm),
	.smm_master_dout(smm_master_dout),
	.smm_slave_dout(smm_tx_dout),

	.clk(clk_tx),
	.reset_n(reset_tx_n),
	.in_eop(tx_in_eop),
	.in_error(tx_in_error),
	.in_sop(tx_in_sop),
	.in_valid(tx_in_valid),
	.in_data(tx_in_data),
	.in_empty(tx_in_empty),
	.in_ready(tx_in_ready),
	.in_pause_req(tx_in_pause),
	                           
	.out_eop(tx_out_eop),
	.out_error(tx_out_error),
	.out_sop(tx_out_sop),
	.out_valid(tx_out_valid),
	.out_data(tx_out_data),
	.out_empty(tx_out_empty),
	.out_ready(tx_out_ready),
	.out_debug(tx_out_debug),
     	.txon_frame(tx_inc_xon),
     	.txoff_frame(tx_inc_xoff)
      );

	alt_aeu_40_pfc_rx #(
        .TARGET_CHIP(TARGET_CHIP),
        .REVID(REVID),
        .BASE_RXFC(BASE_RXFC),
        .NUMPRIORITY(SYNOPT_NUMPRIORITY),
        .WORDS(WORDS),
        .EMPTYBITS(EMPTYBITS),
        .RXERRWIDTH(RXERRWIDTH),
        .RXSTATUSWIDTH(RXSTATUSWIDTH),
        .SYNOPT_PREAMBLE_PASS(SYNOPT_PREAMBLE_PASS),
        .SYNOPT_ALIGN_FCSEOP(SYNOPT_ALIGN_FCSEOP)
	) rx (
	 .clk(clk_rx),
	.reset_n(reset_rx_n),

	.clk_mm(clk_mm),
	.reset_mm(reset_mm),
	.smm_master_dout(smm_master_dout),
	.smm_slave_dout(smm_rx_dout),
	  
//	mac to pfc rx avalon st interface
	.in_eop(rx_in_eop),
	.in_error(rx_in_error),
	.in_error_valid(rx_in_error_valid),
	.in_status(rx_in_status), // RxCtrl
	.in_sop(rx_in_sop),
	.in_valid(rx_in_valid),
	.in_data(rx_in_data),
	.in_empty(rx_in_empty),
	.in_ready(rx_in_ready),

//	pfc to scheduler rx avalon st interface
	.out_sband(rx_out_debug),
	.out_eop(rx_out_eop),
	.out_error_valid(rx_out_error_valid),
	.out_error(rx_out_error),
	.out_status(rx_out_status), // RxCtrl
	.out_sop(rx_out_sop),
	.out_valid(rx_out_valid),
	.out_data(rx_out_data),
	.out_empty(rx_out_empty),
	.out_ready(rx_out_ready),

 	.out_pause(rx_out_pause),
	.rxon_frame(rx_inc_xon),
	.rxoff_frame(rx_inc_xoff)
	);

 endmodule
