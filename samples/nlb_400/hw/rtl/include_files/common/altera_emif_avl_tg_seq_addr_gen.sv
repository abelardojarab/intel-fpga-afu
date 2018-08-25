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
// The sequential address generator generates sequential addresses starting
// with a parametrizable address.
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_seq_addr_gen # (

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

   // Address generator outputs
   output logic [ADDR_WIDTH-1:0]         addr,
   output logic [BURSTCOUNT_WIDTH-1:0]   burstcount
);
   timeunit 1ns;
   timeprecision 1ps;

   // Sequential address registers
   logic [ADDR_WIDTH-1:0] seq_addr;

   // Sequential address generation
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n)
         seq_addr <= '0;
      else if (enable)
         seq_addr <= addr + burstcount;
   end

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
      .enable                       (enable),
      .ready                        (ready),
      .burstcount                   (burstcount)
   );

   // Burst boundary address generator
   altera_emif_avl_tg_burst_boundary_addr_gen # (
      .ADDR_WIDTH                    (ADDR_WIDTH),
      .BURSTCOUNT_WIDTH              (BURSTCOUNT_WIDTH),
      .BURST_ON_BURST_BOUNDARY       (BURST_ON_BURST_BOUNDARY),
      .DO_NOT_CROSS_4KB_BOUNDARY     (DO_NOT_CROSS_4KB_BOUNDARY),
      .AMM_WORD_ADDRESS_DIVISIBLE_BY (AMM_WORD_ADDRESS_DIVISIBLE_BY),
      .DATA_WIDTH                    (DATA_WIDTH)
   ) burst_boundary_addr_gen_inst (
      .burstcount                    (burstcount),
      .addr_in                       (seq_addr),
      .addr_out                      (addr)
   );
endmodule


