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

// altera message_off 10036 10236

`timescale 1 ps / 1 ps
module alt_aeu_40_pfc_tx_ctrl #(
      parameter cfg_typlen= 16'h8808,
      parameter cfg_opcode= 16'h0001,
      parameter WORDS = 4,
      parameter EMPTYBITS = 5,
      parameter NUMPRIORITY = 2,
      parameter PREAMBLE_PASS = 1,
      parameter READY_LATENCY = 3'd1 
) (
      input clk,
      input reset_n,

      output sel_in_pkt,
      output sel_pfc_pkt,
      output sel_store_pkt, 

      output in_ready,
      input out_ready,			// stall input pipe
      input pkt_end,
      output out_pfc_valid,
      output [EMPTYBITS-1:0] out_pfc_empty,
      output [8*64-1:0] out_pfc_data, // Always 8 words wide, even for 4-word Avalon interface

      input [NUMPRIORITY-1:0] cfg_enable_txins,
      input [16*NUMPRIORITY-1:0] cfg_pause_quanta,
      input cfg_lholdoff_en,
      input [16-1:0] cfg_lholdoff_quanta,
      input [NUMPRIORITY-1:0] cfg_qholdoff_en,
      input [16*NUMPRIORITY-1:0] cfg_qholdoff_quanta,
      output [NUMPRIORITY-1:0] txon_frame,
      output [NUMPRIORITY-1:0] txoff_frame,

      input [47:0] cfg_saddr,
      input [47:0] cfg_daddr,
      input [NUMPRIORITY-1:0] cfg_pause_req,
      input [NUMPRIORITY-1:0] in_pause_req
);

  wire [NUMPRIORITY-1:0]  queue_pause_req;
  wire [16*NUMPRIORITY-1:0] queue_pause_quanta;
  wire [NUMPRIORITY-1:0]  pause_txin_done;

  genvar q;
  generate for (q=0; q < NUMPRIORITY; q=q+1) begin: queues
  alt_aeu_40_pfc_tx_qctrl #(
     .WORDS(WORDS)
  ) pfc_tx_qctrl (
     .clk(clk),
     .reset_n(reset_n),
     .out_ready(out_ready),
     .cfg_pause_req(cfg_pause_req[q]),
     .in_pause_req(in_pause_req[q]),
     .pause_txin_done(pause_txin_done[q]),
     .tx_xon(txon_frame[q]),
     .tx_xoff(txoff_frame[q]),
   
     .queue_pause_req(queue_pause_req[q]),
     .queue_pause_quanta(queue_pause_quanta[16*(q+1)-1:16*q]),
     .cfg_enable(cfg_enable_txins[q]),
     .cfg_pause_quanta(cfg_pause_quanta[16*(q+1)-1:16*q]),
     .cfg_holdoff_en(cfg_qholdoff_en[q]),
     .cfg_holdoff_quanta(cfg_qholdoff_quanta[16*(q+1)-1:16*q]));
   end
 endgenerate

   alt_aeu_40_pfc_tx_lctrl	#(
      .WORDS(WORDS),
      .NUMPRIORITY(NUMPRIORITY),
      .PREAMBLE_PASS(PREAMBLE_PASS),
      .EMPTYBITS(EMPTYBITS),
      .READY_LATENCY(READY_LATENCY),
      .PFC_BUFF_READ_LATENCY(3'd1)
) pfc_tx_lctrl (
	 .clk(clk),
	.reset_n(reset_n),

	.cfg_saddr(cfg_saddr),
	.cfg_daddr(cfg_daddr),
	.cfg_opcode(cfg_opcode),
	.cfg_typlen(cfg_typlen),
	.cfg_enable(|cfg_enable_txins),
	.cfg_holdoff_en(cfg_lholdoff_en),
	.cfg_holdoff_quanta(cfg_lholdoff_quanta[15:0]),
	 
	.queue_pause_req(queue_pause_req[NUMPRIORITY-1:0]),
	.queue_pause_quanta(queue_pause_quanta[16*NUMPRIORITY-1:0]),
	 
	.out_ready(out_ready),
	.in_ready(in_ready),
	.pkt_end(pkt_end),

	.pause_txin_done(pause_txin_done),
	.sel_in_pkt(sel_in_pkt),
	.sel_pfc_pkt(sel_pfc_pkt),
	.sel_store_pkt(sel_store_pkt),
	.out_pfc_valid(out_pfc_valid),
	.out_pfc_empty(out_pfc_empty),
	.out_pfc_data(out_pfc_data));

 endmodule
