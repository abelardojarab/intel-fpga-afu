// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module altera_emif_avl_tg_reset_sync # (
   parameter RESET_SYNC_STAGES          = 4,
   parameter NUM_RESET_OUTPUT           = 1
) (
   input  logic                         reset_n,
   input  logic                         clk,
   output logic [NUM_RESET_OUTPUT-1:0]  reset_n_sync
);
   timeunit 1ns;
   timeprecision 1ps;

   (* altera_attribute = {"-name GLOBAL_SIGNAL OFF"}*) reg [RESET_SYNC_STAGES+NUM_RESET_OUTPUT-2:0] reset_reg /* synthesis dont_merge syn_noprune syn_preserve = 1 */;

   generate
   genvar i;
      for (i=0; i<RESET_SYNC_STAGES+NUM_RESET_OUTPUT-1; i=i+1)
      begin: reset_stage
         always @(posedge clk or negedge reset_n) begin
            if (~reset_n) begin
               reset_reg[i] <= 1'b0;
               
            end else begin
               if (i==0)
                  reset_reg[i] <= 1'b1;
               else if (i < RESET_SYNC_STAGES)
                  reset_reg[i] <= reset_reg[i-1];
               else
                  reset_reg[i] <= reset_reg[RESET_SYNC_STAGES-2];
               
            end
         end
      end
   endgenerate

   assign reset_n_sync = reset_reg[RESET_SYNC_STAGES+NUM_RESET_OUTPUT-2:RESET_SYNC_STAGES-1];
endmodule
