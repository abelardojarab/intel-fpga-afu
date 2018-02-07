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
// The random burstcount generator generates random burstcounts within
// parametrizable ranges.  In addition, an option can be enabled to only
// generate burstcounts that are powers of two.
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_rand_burstcount_gen # (

   // Avalon signal widths
   parameter BURSTCOUNT_WIDTH               = "",

   // Burstcount generator configuration
   parameter POWER_OF_TWO_BURSTS_ONLY       = "",
   
   // The burst count value must be divisible by the following value
   parameter AMM_BURST_COUNT_DIVISIBLE_BY   = 1,
   
   // Burstcount range
   parameter MIN_BURSTCOUNT                 = "",
   parameter MAX_BURSTCOUNT                 = ""
) (
   // Clock and reset
   input  logic                          clk,
   input  logic                          reset_n,

   // Control and status
   input  logic                          enable,
   output logic                          ready,

   // Burstcount generator output
   output logic [BURSTCOUNT_WIDTH-1:0]   burstcount
);
   timeunit 1ns;
   timeprecision 1ps;
   
   import avl_tg_defs::*;

   localparam ACTUAL_MIN_BURST_COUNT = (MIN_BURSTCOUNT < AMM_BURST_COUNT_DIVISIBLE_BY) ? AMM_BURST_COUNT_DIVISIBLE_BY : MIN_BURSTCOUNT;
   localparam MIN_EXPONENT           = ceil_log2(ACTUAL_MIN_BURST_COUNT);
   localparam MAX_EXPONENT           = log2(MAX_BURSTCOUNT);
   localparam EXPONENT_WIDTH         = ceil_log2(MAX_EXPONENT + 1);
   
   logic [BURSTCOUNT_WIDTH-1:0]   burstcount_1;
   
   generate
   if (POWER_OF_TWO_BURSTS_ONLY == 1)
   begin : power_of_two_true

      logic [EXPONENT_WIDTH-1:0] rand_exponent_out;
      assign burstcount_1 = 1 << rand_exponent_out;

      altera_emif_avl_tg_rand_num_gen # (
         .RAND_NUM_WIDTH    (EXPONENT_WIDTH),
         .RAND_NUM_MIN      (MIN_EXPONENT),
         .RAND_NUM_MAX      (MAX_EXPONENT)
      ) rand_exponent (
         .clk               (clk),
         .reset_n           (reset_n),
         .enable            (enable),
         .ready             (ready),
         .rand_num          (rand_exponent_out),
         .is_less_than      ()
      );
   end else 
   begin : power_of_two_false

      altera_emif_avl_tg_rand_num_gen # (
         .RAND_NUM_WIDTH    (BURSTCOUNT_WIDTH),
         .RAND_NUM_MIN      (ACTUAL_MIN_BURST_COUNT),
         .RAND_NUM_MAX      (MAX_BURSTCOUNT)
      ) rand_burstcount (
         .clk               (clk),
         .reset_n           (reset_n),
         .enable            (enable),
         .ready             (ready),
         .rand_num          (burstcount_1),
         .is_less_than      ()
      );
   end
   endgenerate
   
   // Make address divisible by AMM_BURST_COUNT_DIVISIBLE_BY (which must be a power of 2)
   // Round down instead of round up, since it's simpler, but make sure we don't
   // round down to zero!
   logic [BURSTCOUNT_WIDTH-1:0] burst_count_divisible_by;
   assign burst_count_divisible_by = AMM_BURST_COUNT_DIVISIBLE_BY[BURSTCOUNT_WIDTH-1:0];
   assign burstcount = ~(burst_count_divisible_by - 1'b1) & burstcount_1;
   
   // Simulation assertions
   initial
   begin
      assert (ACTUAL_MIN_BURST_COUNT <= MAX_BURSTCOUNT)
         else $error ("ACTUAL_MIN_BURST_COUNT must be <= MAX_BURSTCOUNT");
   
      assert (ACTUAL_MIN_BURST_COUNT >= AMM_BURST_COUNT_DIVISIBLE_BY)
         else $error ("ACTUAL_MIN_BURST_COUNT must be >= AMM_BURST_COUNT_DIVISIBLE_BY");
         
      assert (MAX_BURSTCOUNT >= AMM_BURST_COUNT_DIVISIBLE_BY)
         else $error ("MAX_BURSTCOUNT must be >= AMM_BURST_COUNT_DIVISIBLE_BY");
   end
endmodule

