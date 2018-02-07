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


//////////////////////////////////////////////////////////////////////////////
// This is an example address generator, which simply alternate between 0x0
// and AMM_WORD_ADDRESS_DIVISIBLE_BY
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_template_addr_gen # (
   // Avalon signal widths
   parameter ADDR_WIDTH                  = "",
   parameter BURSTCOUNT_WIDTH            = "",
   
   // The word address must be divisible by the following value
   parameter AMM_WORD_ADDRESS_DIVISIBLE_BY  = 1,

   // The burst count value must be divisible by the following value
   parameter AMM_BURST_COUNT_DIVISIBLE_BY   = 1
   
) (
   // Clock and reset
   input  logic                          clk,
   input  logic                          reset_n,

   // Control and status
   input  logic                          enable,
   output logic                          ready,

   // Address generator outputs
   output logic [ADDR_WIDTH-1:0]         addr,
   output logic [BURSTCOUNT_WIDTH-1:0]   burstcount
);
   timeunit 1ns;
   timeprecision 1ps;
   
   import avl_tg_defs::*;

   // Use non-zero address?
   logic addr_non_zero;

   // Always ready
   assign ready = 1'b1;

   // Always issue single burst commands
   assign burstcount = AMM_BURST_COUNT_DIVISIBLE_BY[BURSTCOUNT_WIDTH-1:0];

   // Alternate address 0x0 and 0x1
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n)
         addr_non_zero <= 1'b0;
      else if (enable)
         addr_non_zero <= ~addr_non_zero;
   end

   assign addr = addr_non_zero ? AMM_WORD_ADDRESS_DIVISIBLE_BY[ADDR_WIDTH-1:0] : '0;
endmodule

