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

// altera message_off 10230

//`timescale 1 ps / 1 ps
module alt_aeu_40_pfc_tx_odp #(
   parameter WORDS = 4,
   parameter DWIDTH = 64*WORDS,
   parameter EXTRAWIDTH = DWIDTH - 64*WORDS,
   parameter EMPTYBITS = 5
)(
   input clk,

   //    link control interface signals
   input sel_in_pkt,
   input sel_pfc_pkt,
   input sel_store_pkt,

   //   input data-path interface
   output in_ready,
   input in_valid,
   input in_sop,
   input in_eop,
   input in_error,
   input [DWIDTH-1:0] in_data,
   input [EMPTYBITS-1:0] in_empty,
   input in_pfc_valid,
   input [8*64-1:0] in_pfc_data, // Full PFC packet here
   input [EMPTYBITS-1:0] in_pfc_empty,

   //     output data-path interface
   input out_ready,			// stall input pipe
   output reg out_valid,
   output reg out_sop,
   output reg out_eop,
   output reg out_error,
   output reg [DWIDTH-1:0] out_data,
   output reg [EMPTYBITS-1:0] out_empty,
   output reg out_debug
);

   reg pfc_first_cycle;
   assign in_ready = out_ready;
   always@ (posedge clk) begin
      if (out_ready) begin
         out_debug <= sel_pfc_pkt;
         if (sel_pfc_pkt) begin
            out_valid <= in_pfc_valid;
            out_sop <= pfc_first_cycle? 1 : 0;
            out_eop <= pfc_first_cycle? 0 : 1;
            out_error <= 1'b0;
            // Pad out data with zeroes for PTP data
            out_data <= {{EXTRAWIDTH{1'b0}}, pfc_first_cycle? in_pfc_data[511:256] : in_pfc_data[255:0]};
            out_empty <= pfc_first_cycle? 'b0 : in_pfc_empty;
            pfc_first_cycle <= 1'b0;
         end else if (sel_store_pkt) begin
         // the link fsm provides for the store state
         // for a future need (if we decide to add a
         // buffer at the input and drain it later 
            out_valid <=1'b0;
            out_sop  <= 1'b0;
            out_eop  <= 1'b0;
            out_error <= 1'b0;
            out_data <= 'b0;
            out_empty <= 'b0;
            pfc_first_cycle <= 1'b1;
         end else if (sel_in_pkt) begin
            out_valid <=in_valid;
            out_sop  <= in_sop;
            out_eop  <= in_eop;
            out_error <= in_error;
            out_data <= in_data;
            out_empty <= in_empty;
            pfc_first_cycle <= 1'b1;
         end else begin
            out_valid<= 1'b0;
            out_sop  <= 1'b0;
            out_eop  <= 1'b0;
            out_error <= 1'b0;
         end
      end // out_ready
   end

endmodule
