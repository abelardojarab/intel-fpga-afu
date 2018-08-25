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
// The mixed random/sequential address generator generates addresses within a
// parametrizable range that are random or sequential with a parametrizable
// probability.  It also generates random burstcounts within a parametrizable
// range.
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_rand_seq_addr_gen # (

   // Avalon signal widths
   parameter ADDR_WIDTH                     = "",
   parameter BURSTCOUNT_WIDTH               = "",

   // Address generator configuration
   parameter POWER_OF_TWO_BURSTS_ONLY       = "",
   parameter BURST_ON_BURST_BOUNDARY        = "",
   parameter DO_NOT_CROSS_4KB_BOUNDARY      = "",
   parameter AMM_WORD_ADDRESS_DIVISIBLE_BY  = 1,
   parameter AMM_BURST_COUNT_DIVISIBLE_BY   = 1,
   parameter DATA_WIDTH                     = "",

   // The percentage of the generated addresses that are random
   parameter RAND_ADDR_PERCENT              = "",

   // Burstcount ranges
   parameter MIN_BURSTCOUNT                 = "",
   parameter MAX_BURSTCOUNT                 = ""

) (
   // Clock and reset
   input  logic                         clk,
   input  logic                         reset_n,

   // Control and status
   input  logic                         enable,
   output logic                         ready,

   // Address generator outputs
   output logic [ADDR_WIDTH-1:0]        addr,
   output logic [BURSTCOUNT_WIDTH-1:0]  burstcount
);
   timeunit 1ns;
   timeprecision 1ps;

   import avl_tg_defs::*;

   // Two LFSRs are used to generate random addresses to prevent address overlap
   // in block writes.  The following parameter is the width of the lower bits.
   localparam ADDR_WIDTH_LOW = (ADDR_WIDTH - 1) / 2 + 1;

   // Use random numbers between 0 and 999 to determine random or sequential generation
   localparam RAND_SEQ_PROB_GEN_MIN   = 0;
   localparam RAND_SEQ_PROB_GEN_MAX   = 999;
   localparam RAND_SEQ_PROB_GEN_WIDTH = ceil_log2(RAND_SEQ_PROB_GEN_MAX);
   localparam RAND_ADDR_PROB          = RAND_ADDR_PERCENT * 10;

   // Addresses and burstcount
   logic [ADDR_WIDTH-1:0]                rand_addr_out;
   logic [ADDR_WIDTH-1:0]                seq_addr;
   logic [ADDR_WIDTH-1:0]                addr_out;
   logic [BURSTCOUNT_WIDTH-1:0]          burstcount_out;

   // Random/sequential selector and output
   logic [RAND_SEQ_PROB_GEN_WIDTH-1:0]   rand_seq_prob_out;
   logic                                 use_rand_addr;
   logic [ADDR_WIDTH-1:0]                rand_seq_addr;

   // Submodule status
   logic                                 rand_seq_prob_ready;
   logic                                 rand_burstcount_ready;
   logic                                 sub_gens_ready;
   logic                                 get_next_addr;

   // Random/sequential address generator status
   assign sub_gens_ready = rand_burstcount_ready & rand_seq_prob_ready;
   assign get_next_addr = (~ready & sub_gens_ready) | enable;

   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n) begin
         ready      <= 1'b0;
         addr       <= '0;
         burstcount <= '0;
         
      end else if (get_next_addr) begin
         ready      <= sub_gens_ready;
         addr       <= addr_out;
         burstcount <= burstcount_out;
      end
   end

   // Sequential address generator
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n)
         seq_addr <= '0;
      else if (get_next_addr)
         seq_addr <= addr_out + burstcount_out;
   end

   // Random address generator
   altera_emif_avl_tg_lfsr # (
      .WIDTH      (ADDR_WIDTH_LOW)
   ) rand_addr_low (
      .clk        (clk),
      .reset_n    (reset_n),
      .enable     (get_next_addr & use_rand_addr),
      .data       (rand_addr_out[ADDR_WIDTH_LOW-1:0])
   );

   altera_emif_avl_tg_lfsr # (
      .WIDTH      (ADDR_WIDTH - ADDR_WIDTH_LOW - 1)
   ) rand_addr_high (
      .clk        (clk),
      .reset_n    (reset_n),
      .enable     (get_next_addr & use_rand_addr),
      .data       (rand_addr_out[ADDR_WIDTH-1:ADDR_WIDTH_LOW+1])
   );

   assign rand_addr_out[ADDR_WIDTH_LOW] = 1'b0;

   // Random burstcount generator
   altera_emif_avl_tg_rand_burstcount_gen # (
      .BURSTCOUNT_WIDTH             (BURSTCOUNT_WIDTH),
      .POWER_OF_TWO_BURSTS_ONLY     (POWER_OF_TWO_BURSTS_ONLY),
      .AMM_BURST_COUNT_DIVISIBLE_BY (AMM_BURST_COUNT_DIVISIBLE_BY),
      .MIN_BURSTCOUNT               (MIN_BURSTCOUNT),
      .MAX_BURSTCOUNT               (MAX_BURSTCOUNT)
   ) rand_burstcount (
      .clk                          (clk),
      .reset_n                      (reset_n),
      .enable                       (get_next_addr),
      .ready                        (rand_burstcount_ready),
      .burstcount                   (burstcount_out)
   );

   // Random/sequential address selector
   altera_emif_avl_tg_rand_num_gen # (
      .RAND_NUM_WIDTH                  (RAND_SEQ_PROB_GEN_WIDTH),
      .RAND_NUM_MIN                    (RAND_SEQ_PROB_GEN_MIN),
      .RAND_NUM_MAX                    (RAND_SEQ_PROB_GEN_MAX),
      .RAND_NUM_IS_LESS_THAN_THRESHOLD (RAND_ADDR_PROB)
   ) rand_seq_prob (
      .clk                             (clk),
      .reset_n                         (reset_n),
      .enable                          (get_next_addr),
      .ready                           (rand_seq_prob_ready),
      .rand_num                        (rand_seq_prob_out),
      .is_less_than                    (use_rand_addr)
   );

   // Random/sequential address mux
   assign rand_seq_addr = (use_rand_addr) ? rand_addr_out : seq_addr;

   // Burst boundary address generator
   altera_emif_avl_tg_burst_boundary_addr_gen # (
      .ADDR_WIDTH                      (ADDR_WIDTH),
      .BURSTCOUNT_WIDTH                (BURSTCOUNT_WIDTH),
      .BURST_ON_BURST_BOUNDARY         (BURST_ON_BURST_BOUNDARY),
      .DO_NOT_CROSS_4KB_BOUNDARY       (DO_NOT_CROSS_4KB_BOUNDARY),
      .AMM_WORD_ADDRESS_DIVISIBLE_BY   (AMM_WORD_ADDRESS_DIVISIBLE_BY),
      .DATA_WIDTH                      (DATA_WIDTH)
   ) burst_boundary_addr_gen_inst (
      .burstcount                      (burstcount_out),
      .addr_in                         (rand_seq_addr),
      .addr_out                        (addr_out)
   );

   // Simulation assertions
   initial
   begin
      assert (RAND_ADDR_PERCENT >= 0 && RAND_ADDR_PERCENT <= 100)
         else $error ("Invalid random/sequential address probability");
   end
endmodule

