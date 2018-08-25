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
// This module is a wrapper for the address generators.  The generators'
// outputs are multiplexed in this module using the select signals.
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_addr_gen # (

   // Avalon signal widths
   parameter ADDR_WIDTH                            = "",
   parameter AVL_WORD_ADDR_WIDTH                   = "",
   parameter DATA_WIDTH                            = "",
   parameter BURSTCOUNT_WIDTH                      = "",

   // If set to 1, the driver generates 'avl_size' which are powers of two
   parameter POWER_OF_TWO_BURSTS_ONLY              = "",
   
   // If set to 1, burst transfers begin at addresses which are multiples of 'avl_size'
   parameter BURST_ON_BURST_BOUNDARY               = "",
   
   // If set to 1, transfers do not cross 4k boundary as required for axi slaves
   parameter DO_NOT_CROSS_4KB_BOUNDARY             = "",
   
   // Specifies alignment criteria for Avalon-MM word addresses and burst count
   parameter AMM_WORD_ADDRESS_DIVISIBLE_BY         = 1,
   parameter AMM_BURST_COUNT_DIVISIBLE_BY          = 1,
   
   // If set to true, the address will be shifted to make it per byte address instead per word address
   parameter GEN_BYTE_ADDR                         = "",

   // Sequential address generator
   parameter SEQ_ADDR_GEN_MIN_BURSTCOUNT           = "",
   parameter SEQ_ADDR_GEN_MAX_BURSTCOUNT           = "",

   // Random address generator
   parameter RAND_ADDR_GEN_MIN_BURSTCOUNT          = "",
   parameter RAND_ADDR_GEN_MAX_BURSTCOUNT          = "",

   // Mixed sequential/random address generator
   parameter RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT      = "",
   parameter RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT      = "",
   parameter RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT   = "",

   // If set to true, the unix_id will be added to the MSB bit of the generated address.
   // This is usefull to avoid address overlapping when more than one traffic generator being connected to the same slave
   parameter ENABLE_UNIX_ID                        = 0,
   parameter USE_UNIX_ID                           = 3'b000
   
) (
   // Clock and reset
   input  logic                                    clk,
   input  logic                                    reset_n,

   // One-hot address generator selector
   input  avl_tg_defs::addr_gen_select_t           addr_gen_select,

   // Control and status
   input  logic                                    enable,
   output logic                                    ready,

   // Address generator outputs
   output logic [ADDR_WIDTH-1:0]                   addr,
   output logic [BURSTCOUNT_WIDTH-1:0]             burstcount
);
   timeunit 1ns;
   timeprecision 1ps;
   
   import avl_tg_defs::*;

   localparam ADDR_WOB_ADDR_WIDTH   = (GEN_BYTE_ADDR == 1)  ? AVL_WORD_ADDR_WIDTH : ADDR_WIDTH;
   localparam ADDR_WIDTH_NO_ID      = (ENABLE_UNIX_ID == 1) ? ADDR_WIDTH - 4 : ADDR_WIDTH;
   localparam ADDR_GEN_ADDR_WIDTH   = (ENABLE_UNIX_ID == 1) ? ADDR_WOB_ADDR_WIDTH - 4 : ADDR_WOB_ADDR_WIDTH;

   // Sequential address generator signals
   logic                                seq_addr_gen_enable;
   logic                                seq_addr_gen_ready;
   logic [ADDR_GEN_ADDR_WIDTH-1:0]      seq_addr_gen_addr;
   logic [BURSTCOUNT_WIDTH-1:0]         seq_addr_gen_burstcount;

   // Random address generator signals
   logic                                rand_addr_gen_enable;
   logic                                rand_addr_gen_ready;
   logic [ADDR_GEN_ADDR_WIDTH-1:0]      rand_addr_gen_addr;
   logic [BURSTCOUNT_WIDTH-1:0]         rand_addr_gen_burstcount;

   // Mixed sequential/random address generator signals
   logic                                rand_seq_addr_gen_enable;
   logic                                rand_seq_addr_gen_ready;
   logic [ADDR_GEN_ADDR_WIDTH-1:0]      rand_seq_addr_gen_addr;
   logic [BURSTCOUNT_WIDTH-1:0]         rand_seq_addr_gen_burstcount;

   // Sequential address generator signals
   logic                                template_addr_gen_enable;
   logic                                template_addr_gen_ready;
   logic [ADDR_GEN_ADDR_WIDTH-1:0]      template_addr_gen_addr;
   logic [BURSTCOUNT_WIDTH-1:0]         template_addr_gen_burstcount;

   // Address generator output mux
   logic [ADDR_WIDTH_NO_ID-1:0]         addr_no_id;
   logic [ADDR_GEN_ADDR_WIDTH-1:0]      word_addr;

   assign addr_no_id = (GEN_BYTE_ADDR == 1) ? {word_addr, {(ADDR_WIDTH-AVL_WORD_ADDR_WIDTH){1'b0}}} : word_addr;
   assign addr = (ENABLE_UNIX_ID == 1) ? {USE_UNIX_ID[2:0], 1'b0, addr_no_id[ADDR_WIDTH-5:0]} : addr_no_id;

   always_comb
   begin
      case (addr_gen_select)
         SEQ:
         begin
            ready      <= seq_addr_gen_ready;
            word_addr  <= seq_addr_gen_addr;
            burstcount <= seq_addr_gen_burstcount;
         end
         RAND:
         begin
            ready      <= rand_addr_gen_ready;
            word_addr  <= rand_addr_gen_addr;
            burstcount <= rand_addr_gen_burstcount;
         end
         RAND_SEQ:
         begin
            ready      <= rand_seq_addr_gen_ready;
            word_addr  <= rand_seq_addr_gen_addr;
            burstcount <= rand_seq_addr_gen_burstcount;
         end
         TEMPLATE_ADDR_GEN:
         begin
            ready      <= template_addr_gen_ready;
            word_addr  <= template_addr_gen_addr;
            burstcount <= template_addr_gen_burstcount;
         end
         default:
         begin
            ready      <= seq_addr_gen_ready;
            word_addr  <= seq_addr_gen_addr;
            burstcount <= seq_addr_gen_burstcount;
         end
      endcase
   end

   // Address generator inputs
   assign seq_addr_gen_enable      = (addr_gen_select == SEQ) & enable;
   assign rand_addr_gen_enable     = (addr_gen_select == RAND) & enable;
   assign rand_seq_addr_gen_enable = (addr_gen_select == RAND_SEQ) & enable;
   assign template_addr_gen_enable = (addr_gen_select == TEMPLATE_ADDR_GEN) & enable;

   // Sequential address generator
   altera_emif_avl_tg_seq_addr_gen # (
      .ADDR_WIDTH                   (ADDR_GEN_ADDR_WIDTH),
      .BURSTCOUNT_WIDTH             (BURSTCOUNT_WIDTH),
      .POWER_OF_TWO_BURSTS_ONLY     (POWER_OF_TWO_BURSTS_ONLY),
      .BURST_ON_BURST_BOUNDARY      (BURST_ON_BURST_BOUNDARY),
      .DO_NOT_CROSS_4KB_BOUNDARY    (DO_NOT_CROSS_4KB_BOUNDARY),
      .AMM_BURST_COUNT_DIVISIBLE_BY (AMM_BURST_COUNT_DIVISIBLE_BY),
      .AMM_WORD_ADDRESS_DIVISIBLE_BY(AMM_WORD_ADDRESS_DIVISIBLE_BY),
      .DATA_WIDTH                   (DATA_WIDTH),
      .MIN_BURSTCOUNT               (SEQ_ADDR_GEN_MIN_BURSTCOUNT),
      .MAX_BURSTCOUNT               (SEQ_ADDR_GEN_MAX_BURSTCOUNT)
   ) seq_addr_gen_inst (
      .clk                          (clk),
      .reset_n                      (reset_n),
      .enable                       (seq_addr_gen_enable),
      .ready                        (seq_addr_gen_ready),
      .addr                         (seq_addr_gen_addr),
      .burstcount                   (seq_addr_gen_burstcount)
   );

   // Random address generator
   altera_emif_avl_tg_rand_addr_gen # (
      .ADDR_WIDTH                   (ADDR_GEN_ADDR_WIDTH),
      .BURSTCOUNT_WIDTH             (BURSTCOUNT_WIDTH),
      .POWER_OF_TWO_BURSTS_ONLY     (POWER_OF_TWO_BURSTS_ONLY),
      .BURST_ON_BURST_BOUNDARY      (BURST_ON_BURST_BOUNDARY),
      .DO_NOT_CROSS_4KB_BOUNDARY    (DO_NOT_CROSS_4KB_BOUNDARY),
      .AMM_BURST_COUNT_DIVISIBLE_BY (AMM_BURST_COUNT_DIVISIBLE_BY),
      .AMM_WORD_ADDRESS_DIVISIBLE_BY(AMM_WORD_ADDRESS_DIVISIBLE_BY),
      .DATA_WIDTH                   (DATA_WIDTH),
      .MIN_BURSTCOUNT               (RAND_ADDR_GEN_MIN_BURSTCOUNT),
      .MAX_BURSTCOUNT               (RAND_ADDR_GEN_MAX_BURSTCOUNT)
   ) rand_addr_gen_inst (
      .clk                          (clk),
      .reset_n                      (reset_n),
      .enable                       (rand_addr_gen_enable),
      .ready                        (rand_addr_gen_ready),
      .addr                         (rand_addr_gen_addr),
      .burstcount                   (rand_addr_gen_burstcount)
   );

   // Mixed sequential/random address generator
   altera_emif_avl_tg_rand_seq_addr_gen # (
      .ADDR_WIDTH                   (ADDR_GEN_ADDR_WIDTH),
      .BURSTCOUNT_WIDTH             (BURSTCOUNT_WIDTH),
      .POWER_OF_TWO_BURSTS_ONLY     (POWER_OF_TWO_BURSTS_ONLY),
      .BURST_ON_BURST_BOUNDARY      (BURST_ON_BURST_BOUNDARY),
      .DO_NOT_CROSS_4KB_BOUNDARY    (DO_NOT_CROSS_4KB_BOUNDARY),
      .AMM_BURST_COUNT_DIVISIBLE_BY (AMM_BURST_COUNT_DIVISIBLE_BY),
      .AMM_WORD_ADDRESS_DIVISIBLE_BY(AMM_WORD_ADDRESS_DIVISIBLE_BY),
      .DATA_WIDTH                   (DATA_WIDTH),
      .RAND_ADDR_PERCENT            (RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT),
      .MIN_BURSTCOUNT               (RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT),
      .MAX_BURSTCOUNT               (RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT)
   ) rand_seq_addr_gen_inst (
      .clk                          (clk),
      .reset_n                      (reset_n),
      .enable                       (rand_seq_addr_gen_enable),
      .ready                        (rand_seq_addr_gen_ready),
      .addr                         (rand_seq_addr_gen_addr),
      .burstcount                   (rand_seq_addr_gen_burstcount)
   );

   // Address generator template
   altera_emif_avl_tg_template_addr_gen # (
      .ADDR_WIDTH                   (ADDR_GEN_ADDR_WIDTH),
      .BURSTCOUNT_WIDTH             (BURSTCOUNT_WIDTH),
      .AMM_BURST_COUNT_DIVISIBLE_BY (AMM_BURST_COUNT_DIVISIBLE_BY),
      .AMM_WORD_ADDRESS_DIVISIBLE_BY(AMM_WORD_ADDRESS_DIVISIBLE_BY)
   ) template_addr_gen_inst (
      .clk                          (clk),
      .reset_n                      (reset_n),
      .enable                       (template_addr_gen_enable),
      .ready                        (template_addr_gen_ready),
      .addr                         (template_addr_gen_addr),
      .burstcount                   (template_addr_gen_burstcount)
   );
endmodule

