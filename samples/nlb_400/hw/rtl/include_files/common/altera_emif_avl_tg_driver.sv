// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


//////////////////////////////////////////////////////////////////////////////
// The Example Driver is a parametrizable Avalon Memory-Mapped Master used to
// test various memory interfaces.  The driver generates pseudo-random traffic
// using a number of different patterns and compare the received data against
// what is expected.
// The Example Driver execute tests in various stages.  There are two test
// stages predefined in this driver, and it can be easily extended to include
// custom stages.
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_driver # (

   parameter DEVICE_FAMILY                          = "",
   parameter PROTOCOL_ENUM                          = "",

   ////////////////////////////////////////////////////////////
   // AVALON SIGNAL WIDTHS
   ////////////////////////////////////////////////////////////
   parameter TG_AVL_ADDR_WIDTH                      = 33,
   parameter TG_AVL_WORD_ADDR_WIDTH                 = 27,
   parameter TG_AVL_SIZE_WIDTH                      = 7,
   parameter TG_AVL_DATA_WIDTH                      = 288,
   parameter TG_AVL_BE_WIDTH                        = 36,

   ////////////////////////////////////////////////////////////
   // DRIVER CONFIGURATION
   ////////////////////////////////////////////////////////////

   // Specifies how many tests to run. Only applicable when USE_SIMPLE_TG is 0.
   // SHORT -> Suitable for simulation only.
   // MEDIUM -> Generates more traffic for simple hardware testing in seconds.
   // INFINITE -> Generates traffic continuously and indefinitely.
   parameter TG_TEST_DURATION                       = "SHORT",

   // Specifies the maximum number of loops through the driver
   // patterns before asserting test complete. A setting of 0
   // will cause the driver to loop infinitely.
   parameter TG_NUM_DRIVER_LOOP                     = (TG_TEST_DURATION == "SKIP")     ? -1 : (
                                                      (TG_TEST_DURATION == "INFINITE") ?  0 : (
                                                      (TG_TEST_DURATION == "MEDIUM")   ?  1000 : (
                                                      (TG_TEST_DURATION == "SHORT")    ?  1 : (
                                                                                          1 )))),

   // Random seed for data generator
   parameter TG_LFSR_SEED                           = 36'b000000111110000011110000111000110010,

   // If set to true, the unix_id will be added to the MSB bit of
   // the generated address. This is usefull to avoid address
   // overlapping when more than one traffic generator being
   // connected to the same slave.
   parameter TG_ENABLE_UNIX_ID                      = 0,
   parameter TG_USE_UNIX_ID                         = 3'b000,

   // If set to "1", the driver generates pseudo-random byte enables
   parameter TG_RANDOM_BYTE_ENABLE                  = 1,

   // If set to "1", the driver generates 'avl_size' which are powers of two
   parameter TG_POWER_OF_TWO_BURSTS_ONLY            = 0,

   // If set to "1", burst transfers begin at addresses which are multiples of 'avl_size'
   parameter TG_BURST_ON_BURST_BOUNDARY             = 0,

   // If set to 1, transfers do not cross 4kb boundary as required for axi slaves
   parameter TG_DO_NOT_CROSS_4KB_BOUNDARY           = 0,

   // Specifies alignment criteria for Avalon-MM word addresses and burst count
   parameter AMM_WORD_ADDRESS_DIVISIBLE_BY          = 1,
   parameter AMM_BURST_COUNT_DIVISIBLE_BY           = 1,

   // If set to "1", per byte address will be generated instead of per word address
   parameter TG_GEN_BYTE_ADDR                       = 1,

   // Timeout counter width
   // If the test stages are modified, this parameter
   // may need adjustment to avoid premature timeouts.
   // A value of 0 means that the timeout mechanism is disabled.
   parameter TG_TIMEOUT_COUNTER_WIDTH               = 0,

   ////////////////////////////////////////////////////////////
   // TEST STAGES PARAMETERS
   ////////////////////////////////////////////////////////////

   // Single write/read stage
   parameter TG_SINGLE_RW_SEQ_ADDR_COUNT            = (TG_TEST_DURATION == "SHORT") ? 8 : 64,
   parameter TG_SINGLE_RW_RAND_ADDR_COUNT           = (TG_TEST_DURATION == "SHORT") ? 8 : 64,
   parameter TG_SINGLE_RW_RAND_SEQ_ADDR_COUNT       = (TG_TEST_DURATION == "SHORT") ? 8 : 64,

   // Block write/read stage
   parameter TG_BLOCK_RW_SEQ_ADDR_COUNT             = (TG_TEST_DURATION == "SHORT") ? 8 : 64,
   parameter TG_BLOCK_RW_RAND_ADDR_COUNT            = (TG_TEST_DURATION == "SHORT") ? 8 : 64,
   parameter TG_BLOCK_RW_RAND_SEQ_ADDR_COUNT        = (TG_TEST_DURATION == "SHORT") ? 8 : 64,
   parameter TG_BLOCK_RW_BLOCK_SIZE                 = (TG_TEST_DURATION == "SHORT") ? 8 : 16,

   // Byte-enable test stage
   parameter TG_BYTEENABLE_STAGE_RAND_ADDR_COUNT    = (TG_TEST_DURATION == "SHORT") ? 8 : 64,

   // Template stage
   parameter TG_TEMPLATE_STAGE_COUNT                = (TG_TEST_DURATION == "SHORT") ? 8 : 64,

   ////////////////////////////////////////////////////////////
   // ADDRESS GENERATORS PARAMETERS
   ////////////////////////////////////////////////////////////

   // Sequential address generator
   // The burstcount is limited to a maximum of 64 to keep the value reasonable for simulation purposes.
   parameter TG_SEQ_ADDR_GEN_MIN_BURSTCOUNT         = 1,
   parameter TG_SEQ_ADDR_GEN_MAX_BURSTCOUNT         = 2 ** TG_AVL_SIZE_WIDTH - 1 > 64 ? 64 : 2 ** TG_AVL_SIZE_WIDTH - 1,

   // Random address generator
   // The burstcount is limited to a maximum of 64 to keep the value reasonable for simulation purposes.
   parameter TG_RAND_ADDR_GEN_MIN_BURSTCOUNT        = 1,
   parameter TG_RAND_ADDR_GEN_MAX_BURSTCOUNT        = 2 ** TG_AVL_SIZE_WIDTH - 1 > 64 ? 64 : 2 ** TG_AVL_SIZE_WIDTH - 1,

   // Mixed sequential/random address generator
   // The burstcount is limited to a maximum of 64 to keep the value reasonable for simulation purposes.
   parameter TG_RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT    = 1,
   parameter TG_RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT    = 2 ** TG_AVL_SIZE_WIDTH - 1 > 64 ? 64 : 2 ** TG_AVL_SIZE_WIDTH - 1,
   parameter TG_RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT = 50,

   ////////////////////////////////////////////////////////////
   // MEMORY INTERFACE PROPERTY
   ////////////////////////////////////////////////////////////

   // The maximum read latency seen by the driver
   // This parameter is used to determine buffer sizes, test stages may fail
   // if the actual read latency is larger than specified by this parameter.
   parameter TG_MAX_READ_LATENCY                    = 20,

   // Indicates whether a separate interface exists for reads and writes.
   // Typically set to 1 for QDR-style interfaces where concurrent reads and
   // writes are possible
   parameter TG_SEPARATE_READ_WRITE_IFS             = 0
) (
   // Clock and reset
   input  logic                                     clk,
   input  logic                                     reset_n,
   
   // WORM mode: If a data mismatch is encountered, stop as much of the traffic as possible
   // and issue a read to the same address. In this mode, the persistent PNF
   // is no longer meaningful as we basically stop at the first data mismatch.
   input  logic                                     worm_en,

   // Avalon master signals
   input  logic                                     avl_ready,
   output logic                                     avl_write_req,
   output logic                                     avl_read_req,
   output logic [TG_AVL_ADDR_WIDTH-1:0]             avl_addr,
   output logic [TG_AVL_SIZE_WIDTH-1:0]             avl_size,
   output logic [TG_AVL_BE_WIDTH-1:0]               avl_be,
   output logic [TG_AVL_DATA_WIDTH-1:0]             avl_wdata,
   input  logic                                     avl_rdata_valid,
   input  logic [TG_AVL_DATA_WIDTH-1:0]             avl_rdata,

   // Avalon master signals (Dedicated write interface for QDR-style where concurrent reads and writes are possible)
   input  logic                                     avl_ready_w,
   output logic [TG_AVL_ADDR_WIDTH-1:0]             avl_addr_w,
   output logic [TG_AVL_SIZE_WIDTH-1:0]             avl_size_w,

   // Driver status signals
   output logic                                     pass,
   output logic                                     fail,
   output logic                                     timeout,
   output logic [TG_AVL_DATA_WIDTH-1:0]             pnf_per_bit,
   output logic [TG_AVL_DATA_WIDTH-1:0]             pnf_per_bit_persist,
   output logic [3:0]                               fsm_state
);
   timeunit 1ns;
   timeprecision 1ps;

   import avl_tg_defs::*;

   // Determine the size of various FIFOs
   localparam AVALON_TRAFFIC_BUFFER_SIZE   = 8;
   localparam ADDR_BURSTCOUNT_FIFO_SIZE    = TG_BLOCK_RW_BLOCK_SIZE;
   localparam WRITTEN_DATA_FIFO_SIZE       = max(TG_BLOCK_RW_BLOCK_SIZE * (1 <<< (TG_AVL_SIZE_WIDTH - 1)), TG_MAX_READ_LATENCY) + AVALON_TRAFFIC_BUFFER_SIZE;

   // State machine signals
   logic                                   test_complete;
   logic                                   do_inv_be_write;
   logic                                   do_write;
   logic                                   do_read;
   logic                                   can_write;
   logic                                   can_read;
   logic [31:0]                            loop_counter;
   logic [31:0]                            loop_counter_persist;

   // Address generator signals
   addr_gen_select_t                       addr_gen_select;
   logic                                   addr_gen_enable;
   logic                                   addr_gen_ready;
   logic [TG_AVL_ADDR_WIDTH-1:0]           addr_gen_addr;
   logic [TG_AVL_SIZE_WIDTH-1:0]           addr_gen_burstcount;

   // Address/burstcount FIFO signals
   logic                                   addr_fifo_write_req;
   logic                                   addr_fifo_read_req;
   logic [TG_AVL_ADDR_WIDTH-1:0]           addr_fifo_addr;
   logic [TG_AVL_SIZE_WIDTH-1:0]           addr_fifo_burstcount;
   logic                                   addr_burstcount_fifo_empty;

   // Avalon traffic generator signals
   logic                                   traffic_gen_ready;
   logic                                   traffic_gen_ready_w;

   // Read compare signals
   logic                                   queue_read_compare_req;
   logic                                   read_compare_fifo_full;
   logic                                   read_compare_fifo_empty;
   logic                                   captured_first_fail;
   logic [TG_AVL_ADDR_WIDTH-1:0]           first_fail_exact_addr;

   // Address/data signals
   logic [TG_AVL_ADDR_WIDTH-1:0]           read_addr;
   logic [TG_AVL_SIZE_WIDTH-1:0]           read_burstcount;

   // Random write data and data mask generation
   logic                                   byteenable_stage;
   logic                                   wdata_gen_enable;
   logic                                   inv_be_gen_enable;
   logic [TG_AVL_DATA_WIDTH-1:0]           wdata;
   logic [TG_AVL_BE_WIDTH-1:0]             be;
   logic [TG_AVL_BE_WIDTH-1:0]             inv_be;
   logic [TG_AVL_BE_WIDTH-1:0]             pre_inv_be;

   // Delayed versions of avl_rdata and avl_rdata_valid to resolve issue
   // with VHDL simgen model
   logic                                   avl_rdata_valid_delay;
   logic [TG_AVL_DATA_WIDTH-1:0]           avl_rdata_delay;

   // Status of the write command fifo. These signals are only used
   // by protocols such as QDRII, to guard against race conditions
   // whereby reads can start before writes have finished.
   logic                                   fifo_w_full;
   logic                                   fifo_w_empty;

   // Delay the signals to ensure they are always after the clock
   //SPR:367726 details this issue
   always @(avl_rdata_valid)
      avl_rdata_valid_delay <= avl_rdata_valid;

   always @(avl_rdata)
      avl_rdata_delay <= avl_rdata;

   // Sticky per bit pnf
   always_ff @(posedge clk)
   begin
      if (!reset_n)
         pnf_per_bit_persist <= '1;
      else
         pnf_per_bit_persist <= pnf_per_bit_persist & pnf_per_bit;
   end

   // Generate status signals
   assign pass =  (&pnf_per_bit_persist) & test_complete;
   // If TG_NUM_DRIVER_LOOP == 0 (infinite loops) then the fail signal
   // will be asserted immediately upon any bit failure.  Otherwise,
   // the fail signal will only be asserted after all traffic has completed.
   assign fail = ~(&pnf_per_bit_persist) & (TG_NUM_DRIVER_LOOP == 0 ? 1'b1 : test_complete);

   // Read address/burstcount select
   // can_write and can_read indicates to the state machine whether
   // other components are ready for issuing a write or read command
   always_comb
   begin
      // When testing byteenable, make sure the normal and the inverted writes both use the same address and burst size
      addr_gen_enable <= byteenable_stage ? do_inv_be_write : do_write;

      addr_fifo_write_req <= do_write;

      // Override read address generation when in WORM re-read mode
      addr_fifo_read_req  <= do_read & !(worm_en && captured_first_fail);
      read_addr           <= (worm_en && captured_first_fail) ? first_fail_exact_addr : addr_fifo_addr;
      read_burstcount     <= (worm_en && captured_first_fail) ? {{(TG_AVL_SIZE_WIDTH-1){1'b0}}, 1'b1} : addr_fifo_burstcount;

      // read_compare_fifo_full is omitted in generating can_write because
      // we consider it a timeout if the read compare fifo is full
      can_read <= traffic_gen_ready & (~addr_burstcount_fifo_empty | (worm_en && captured_first_fail));

      if (TG_SEPARATE_READ_WRITE_IFS)
         can_write <= traffic_gen_ready_w & addr_gen_ready;
      else
         can_write <= traffic_gen_ready & addr_gen_ready;
   end

   // Address generators
   altera_emif_avl_tg_addr_gen # (
      .ADDR_WIDTH                            (TG_AVL_ADDR_WIDTH),
      .AVL_WORD_ADDR_WIDTH                   (TG_AVL_WORD_ADDR_WIDTH),
      .DATA_WIDTH                            (TG_AVL_DATA_WIDTH),
      .BURSTCOUNT_WIDTH                      (TG_AVL_SIZE_WIDTH),
      .AMM_BURST_COUNT_DIVISIBLE_BY          (AMM_BURST_COUNT_DIVISIBLE_BY),
      .AMM_WORD_ADDRESS_DIVISIBLE_BY         (AMM_WORD_ADDRESS_DIVISIBLE_BY),
      .POWER_OF_TWO_BURSTS_ONLY              (TG_POWER_OF_TWO_BURSTS_ONLY),
      .BURST_ON_BURST_BOUNDARY               (TG_BURST_ON_BURST_BOUNDARY),
      .DO_NOT_CROSS_4KB_BOUNDARY             (TG_DO_NOT_CROSS_4KB_BOUNDARY),
      .GEN_BYTE_ADDR                         (TG_GEN_BYTE_ADDR),
      .SEQ_ADDR_GEN_MIN_BURSTCOUNT           (TG_SEQ_ADDR_GEN_MIN_BURSTCOUNT),
      .SEQ_ADDR_GEN_MAX_BURSTCOUNT           (TG_SEQ_ADDR_GEN_MAX_BURSTCOUNT),
      .RAND_ADDR_GEN_MIN_BURSTCOUNT          (TG_RAND_ADDR_GEN_MIN_BURSTCOUNT),
      .RAND_ADDR_GEN_MAX_BURSTCOUNT          (TG_RAND_ADDR_GEN_MAX_BURSTCOUNT),
      .RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT      (TG_RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT),
      .RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT      (TG_RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT),
      .RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT   (TG_RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT),
      .ENABLE_UNIX_ID                        (TG_ENABLE_UNIX_ID),
      .USE_UNIX_ID                           (TG_USE_UNIX_ID)
   ) addr_gen_inst (
      .clk             (clk),
      .reset_n         (reset_n),
      .addr_gen_select (addr_gen_select),
      .enable          (addr_gen_enable),
      .ready           (addr_gen_ready),
      .addr            (addr_gen_addr),
      .burstcount      (addr_gen_burstcount)
   );

   // Pseudo-random data generator
   // Note that during the inverted-be writes of the byte-enable stage,
   // we keep the output data constant - this is ok, because the focus
   // is on testing byte-enable.
   altera_emif_avl_tg_lfsr_wrapper # (
      .DATA_WIDTH   (TG_AVL_DATA_WIDTH),
      .SEED         (TG_LFSR_SEED)
   ) data_gen_inst (
      .clk          (clk),
      .reset_n      (reset_n),
      .enable       (wdata_gen_enable),
      .data         (wdata)
   );

   // Byte enable generator
   generate
   if (TG_RANDOM_BYTE_ENABLE == 1)
   begin : be_gen
      altera_emif_avl_tg_lfsr_wrapper # (
         .DATA_WIDTH   (TG_AVL_BE_WIDTH)
      ) be_gen_inst (
         .clk          (clk),
         .reset_n      (reset_n),
         .enable       (wdata_gen_enable),
         .data         (be)
      );

      // This LFSR is to generate the byte-enable signal
      // during the 2nd write of the byte-enable stage
      // such that it is the bit-wise inverted version of
      // the byte-enable signal during the 1st write.
      // When not in the byte-enable stage we simply keep
      // it in-sync with the regular LFSR above.
      altera_emif_avl_tg_lfsr_wrapper # (
         .DATA_WIDTH   (TG_AVL_BE_WIDTH)
      ) inv_be_gen_inst (
         .clk          (clk),
         .reset_n      (reset_n),
         .enable       (inv_be_gen_enable),
         .data         (pre_inv_be)
      );
      assign inv_be = ~pre_inv_be;
   end
   else
   begin : be_const
      assign be = '1;
      assign inv_be = '1;   
   end
   endgenerate

   // The address/burstcount FIFO buffers the write addresses
   // and burstcounts which are later used in read operations
   altera_emif_avl_tg_scfifo_wrapper # (
      .DEVICE_FAMILY   (DEVICE_FAMILY),
      .FIFO_WIDTH      (TG_AVL_ADDR_WIDTH + TG_AVL_SIZE_WIDTH),
      .FIFO_SIZE       (ADDR_BURSTCOUNT_FIFO_SIZE),
      .SHOW_AHEAD      ("ON")
   ) addr_burstcount_fifo (
      .clk             (clk),
      .reset_n         (reset_n),
      .write_req       (addr_fifo_write_req),
      .read_req        (addr_fifo_read_req),
      .data_in         ({addr_gen_addr,addr_gen_burstcount}),
      .data_out        ({addr_fifo_addr,addr_fifo_burstcount}),
      .full            (),
      .empty           (addr_burstcount_fifo_empty)
   );

   // The main state machine of the example driver,
   // which contains sub-modules for various test stages
   altera_emif_avl_tg_driver_fsm # (
      .SINGLE_RW_SEQ_ADDR_COUNT               (TG_SINGLE_RW_SEQ_ADDR_COUNT),
      .SINGLE_RW_RAND_ADDR_COUNT              (TG_SINGLE_RW_RAND_ADDR_COUNT),
      .SINGLE_RW_RAND_SEQ_ADDR_COUNT          (TG_SINGLE_RW_RAND_SEQ_ADDR_COUNT),
      .BLOCK_RW_SEQ_ADDR_COUNT                (TG_BLOCK_RW_SEQ_ADDR_COUNT),
      .BLOCK_RW_RAND_ADDR_COUNT               (TG_BLOCK_RW_RAND_ADDR_COUNT),
      .BLOCK_RW_RAND_SEQ_ADDR_COUNT           (TG_BLOCK_RW_RAND_SEQ_ADDR_COUNT),
      .BLOCK_RW_BLOCK_SIZE                    (TG_BLOCK_RW_BLOCK_SIZE),
      .BYTEENABLE_STAGE_RAND_ADDR_COUNT       (TG_RANDOM_BYTE_ENABLE == 1 ? TG_BYTEENABLE_STAGE_RAND_ADDR_COUNT : 0),
      .TEMPLATE_STAGE_COUNT                   (TG_TEMPLATE_STAGE_COUNT),
      .TIMEOUT_COUNTER_WIDTH                  (TG_TIMEOUT_COUNTER_WIDTH),
      .NUM_DRIVER_LOOP                        (TG_NUM_DRIVER_LOOP),
      .USE_BLOCKING_ADDRESS_GENERATION        (TG_SEPARATE_READ_WRITE_IFS)
   ) driver_fsm_inst (
      .clk                             (clk),
      .reset_n                         (reset_n),
      .worm_en                         (worm_en),
      .can_write                       (can_write),
      .can_read                        (can_read),
      .read_compare_fifo_full          (read_compare_fifo_full),
      .read_compare_fifo_empty         (read_compare_fifo_empty),
      .captured_first_fail             (captured_first_fail),
      .fifo_w_full                     (fifo_w_full),
      .fifo_w_empty                    (fifo_w_empty),
      .addr_gen_select                 (addr_gen_select),
      .byteenable_stage                (byteenable_stage),
      .do_inv_be_write                 (do_inv_be_write),
      .do_write                        (do_write),
      .do_read                         (do_read),
      .fsm_state                       (fsm_state),
      .test_complete                   (test_complete),
      .loop_counter                    (loop_counter),
      .timeout                         (timeout)
   );

   // The Avalon traffic generator translates the commands
   // issued by the state machine into Avalon signals
   generate
      if (TG_SEPARATE_READ_WRITE_IFS) begin : srw
         altera_emif_avl_tg_avl_mm_srw_if # (
            .DEVICE_FAMILY       (DEVICE_FAMILY),
            .ADDR_WIDTH          (TG_AVL_ADDR_WIDTH),
            .BURSTCOUNT_WIDTH    (TG_AVL_SIZE_WIDTH),
            .DATA_WIDTH          (TG_AVL_DATA_WIDTH),
            .BE_WIDTH            (TG_AVL_BE_WIDTH),
            .BUFFER_SIZE         (AVALON_TRAFFIC_BUFFER_SIZE),
            .RANDOM_BYTE_ENABLE  (TG_RANDOM_BYTE_ENABLE)
         ) avl_tg_avl_mm_if_inst (
            .clk                    (clk),
            .reset_n                (reset_n),
            .avl_ready              (avl_ready),
            .avl_write_req          (avl_write_req),
            .avl_read_req           (avl_read_req),
            .avl_addr               (avl_addr),
            .avl_size               (avl_size),
            .avl_wdata              (avl_wdata),
            .avl_be                 (avl_be),
            .avl_ready_w            (avl_ready_w),
            .avl_addr_w             (avl_addr_w),
            .avl_size_w             (avl_size_w),
            .do_inv_be_write        (do_inv_be_write),
            .do_write               (do_write),
            .do_read                (do_read),
            .write_addr             (addr_gen_addr),
            .write_burstcount       (addr_gen_burstcount),
            .wdata                  (wdata),
            .be                     (be),
            .inv_be                 (inv_be),
            .read_addr              (read_addr),
            .read_burstcount        (read_burstcount),
            .ready_r                (traffic_gen_ready),
            .ready_w                (traffic_gen_ready_w),
            .fifo_w_full            (fifo_w_full),
            .fifo_w_empty           (fifo_w_empty),
            .queue_read_compare_req (queue_read_compare_req),
            .byteenable_stage       (byteenable_stage),
            .wdata_gen_enable       (wdata_gen_enable),
            .inv_be_gen_enable      (inv_be_gen_enable)
         );
      end else begin : not_srw

         logic                         avl_master_ready;
         logic                         avl_master_write_req;
         logic                         avl_master_read_req;
         logic [TG_AVL_ADDR_WIDTH-1:0] avl_master_addr;
         logic [TG_AVL_SIZE_WIDTH-1:0] avl_master_size;
         logic [TG_AVL_BE_WIDTH-1:0]   avl_master_be;
         logic [TG_AVL_DATA_WIDTH-1:0] avl_master_wdata;

         // For timing closure we instantiate a bridge to decouple
         // master and slave. The bridge is essentially a 2-deep FIFO.
         altera_emif_avl_tg_amm_1x_bridge # (
            .AMM_WDATA_WIDTH          (TG_AVL_DATA_WIDTH),
            .AMM_SYMBOL_ADDRESS_WIDTH (TG_AVL_ADDR_WIDTH),
            .AMM_BCOUNT_WIDTH         (TG_AVL_SIZE_WIDTH),
            .AMM_BYTEEN_WIDTH         (TG_AVL_BE_WIDTH)
         ) amm_1x_bridge (
            .reset_n                    (reset_n),
            .clk                        (clk),
            .amm_slave_write            (avl_write_req),
            .amm_slave_read             (avl_read_req),
            .amm_slave_ready            (avl_ready),
            .amm_slave_address          (avl_addr),
            .amm_slave_writedata        (avl_wdata),
            .amm_slave_burstcount       (avl_size),
            .amm_slave_byteenable       (avl_be),
            .amm_master_write           (avl_master_write_req),
            .amm_master_read            (avl_master_read_req),
            .amm_master_ready           (avl_master_ready),
            .amm_master_address         (avl_master_addr),
            .amm_master_writedata       (avl_master_wdata),
            .amm_master_burstcount      (avl_master_size),
            .amm_master_byteenable      (avl_master_be)
         );

         altera_emif_avl_tg_avl_mm_if # (
            .DEVICE_FAMILY       (DEVICE_FAMILY),
            .ADDR_WIDTH          (TG_AVL_ADDR_WIDTH),
            .BURSTCOUNT_WIDTH    (TG_AVL_SIZE_WIDTH),
            .DATA_WIDTH          (TG_AVL_DATA_WIDTH),
            .BE_WIDTH            (TG_AVL_BE_WIDTH),
            .BUFFER_SIZE         (AVALON_TRAFFIC_BUFFER_SIZE),
            .RANDOM_BYTE_ENABLE  (TG_RANDOM_BYTE_ENABLE)
         ) avl_tg_avl_mm_if_inst (
            .clk                    (clk),
            .reset_n                (reset_n),
            .avl_ready              (avl_master_ready),
            .avl_write_req          (avl_master_write_req),
            .avl_read_req           (avl_master_read_req),
            .avl_addr               (avl_master_addr),
            .avl_size               (avl_master_size),
            .avl_wdata              (avl_master_wdata),
            .avl_be                 (avl_master_be),
            .do_inv_be_write        (do_inv_be_write),
            .do_write               (do_write),
            .do_read                (do_read),
            .write_addr             (addr_gen_addr),
            .write_burstcount       (addr_gen_burstcount),
            .wdata                  (wdata),
            .be                     (be),
            .inv_be                 (inv_be),
            .read_addr              (read_addr),
            .read_burstcount        (read_burstcount),
            .ready                  (traffic_gen_ready),
            .queue_read_compare_req (queue_read_compare_req),
            .byteenable_stage       (byteenable_stage),
            .wdata_gen_enable       (wdata_gen_enable),
            .inv_be_gen_enable      (inv_be_gen_enable)
         );

         // Tie off unused signals to avoid warnings
			assign traffic_gen_ready_w = '0;
			assign avl_addr_w = '0;
			assign avl_size_w = '0;

         // Signals not supported and must not be used
         assign fifo_w_full = 1'b0;
         assign fifo_w_empty = 1'b1;
      end
   endgenerate

   // Read compare module
   altera_emif_avl_tg_read_compare # (
      .DATA_WIDTH                 (TG_AVL_DATA_WIDTH),
      .BE_WIDTH                   (TG_AVL_BE_WIDTH),
      .ADDR_WIDTH                 (TG_AVL_ADDR_WIDTH),
      .SIZE_WIDTH                 (TG_AVL_SIZE_WIDTH),
      .WORD_ADDR_WIDTH            (TG_AVL_WORD_ADDR_WIDTH),
      .ADDR_BURSTCOUNT_FIFO_SIZE  (ADDR_BURSTCOUNT_FIFO_SIZE),
      .WRITTEN_DATA_FIFO_SIZE     (WRITTEN_DATA_FIFO_SIZE),
      .DEVICE_FAMILY              (DEVICE_FAMILY),
      .TG_LFSR_SEED               (TG_LFSR_SEED),
      .TG_RANDOM_BYTE_ENABLE      (TG_RANDOM_BYTE_ENABLE)
   ) read_compare_inst (
      .clk                            (clk),
      .reset_n                        (reset_n),
      .enable                         (1'b1),
      .queue_read_compare_req         (queue_read_compare_req),
      .queue_read_addr_burstcount_req (addr_fifo_read_req),
      .read_addr_to_queue             (addr_fifo_addr),
      .read_burstcount_to_queue       (addr_fifo_burstcount),
      .rdata_valid                    (avl_rdata_valid_delay),
      .rdata                          (avl_rdata_delay),
      .read_compare_fifo_full         (read_compare_fifo_full),
      .read_compare_fifo_empty        (read_compare_fifo_empty),
      .pnf_per_bit                    (pnf_per_bit),
      .captured_first_fail            (captured_first_fail),
      .first_fail_exact_addr          (first_fail_exact_addr)
   );

   // Simulation assertions
   initial
   begin
      assert (TG_POWER_OF_TWO_BURSTS_ONLY == 1 || TG_POWER_OF_TWO_BURSTS_ONLY == 0)
         else $error ("TG_POWER_OF_TWO_BURSTS_ONLY must be 1 or 0");
      assert (TG_BURST_ON_BURST_BOUNDARY == 1 || TG_BURST_ON_BURST_BOUNDARY == 0)
         else $error ("TG_BURST_ON_BURST_BOUNDARY must be 1 or 0");
      assert (TG_DO_NOT_CROSS_4KB_BOUNDARY == 1 || TG_DO_NOT_CROSS_4KB_BOUNDARY == 0)
         else $error ("TG_DO_NOT_CROSS_4KB_BOUNDARY must be 1 or 0");
      assert (AMM_WORD_ADDRESS_DIVISIBLE_BY == 1 || TG_BURST_ON_BURST_BOUNDARY == 0)
         else $error ("TG_BURST_ON_BURST_BOUNDARY and AMM_WORD_ADDRESS_DIVISIBLE_BY cannot be set at the same time");
      assert (AMM_BURST_COUNT_DIVISIBLE_BY == 1 || TG_POWER_OF_TWO_BURSTS_ONLY == 0)
         else $error ("TG_POWER_OF_TWO_BURSTS_ONLY and AMM_BURST_COUNT_DIVISIBLE_BY cannot be set at the same time");
      assert (AMM_WORD_ADDRESS_DIVISIBLE_BY != 0 && (AMM_WORD_ADDRESS_DIVISIBLE_BY & (AMM_WORD_ADDRESS_DIVISIBLE_BY - 1)) == 0)
         else $error ("AMM_WORD_ADDRESS_DIVISIBLE_BY must be a power of 2");
      assert (AMM_BURST_COUNT_DIVISIBLE_BY != 0 && (AMM_BURST_COUNT_DIVISIBLE_BY & (AMM_BURST_COUNT_DIVISIBLE_BY - 1)) == 0)
         else $error ("AMM_BURST_COUNT_DIVISIBLE_BY must be a power of 2");
      assert (TG_RANDOM_BYTE_ENABLE == 1 || TG_RANDOM_BYTE_ENABLE == 0)
         else $error ("TG_RANDOM_BYTE_ENABLE must be 1 or 0");
   end
endmodule
