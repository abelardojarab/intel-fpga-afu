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


//////////////////////////////////////////////////////////////////////////////////
// This module implements a simple Avalon-MM traffic generator intending
// to answer the basic question of: "is the memory subsystem functionally capable
// of performing the simplest reads and writes after a successful calibration?"
// This simple traffic generator can be a useful tool during initial bring-up
// for basic sanity checking.
//
// Performance and efficiency are not important consideration for this simple
// traffic generator.  In fact, highly efficient traffic patterns (e.g. long bursts
// of data on the DRAM data bus with aggressive data pattern) are not desired as
// they may expose timing marginality and/or signal and power integrity issues on
// hardware, clouding the answer to the basic question we pose above.
//
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_driver_simple # (

   parameter DEVICE_FAMILY                          = "",
   parameter PROTOCOL_ENUM                          = "",

   // The driver supports the following pre-defined modes:
   //
   // SHORT: perform one write-read operation to a constant address and with constant data.
   //        Test is passed if read data is same as expected data. (default)
   //
   // MEDIUM: perform writes to 128 addresses where the write data is the same
   //         as the target address. After that we read back all data and pass
   //         the test if all data are correct.
   //
   // LONG:   Address-aliasiing test. Perform writes to all the addresses where 
   //         the write data is the same as the target address. After that we read
   //         back all data and pass the test if all data are correct.
   parameter TG_TEST_DURATION                       = "SHORT",

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

   // Specifies alignment criteria for Avalon-MM word addresses and burst count
   parameter AMM_WORD_ADDRESS_DIVISIBLE_BY          = 1,
   parameter AMM_BURST_COUNT_DIVISIBLE_BY           = 1,

   // Indicates whether a separate interface exists for reads and writes.
   // Typically set to 1 for QDR-style interfaces where concurrent reads and
   // writes are possible
   parameter TG_SEPARATE_READ_WRITE_IFS             = 0

) (
   // Clock and reset
   input  logic                                     clk,
   input  logic                                     reset_n,

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
   output logic [TG_AVL_DATA_WIDTH-1:0]             pnf_per_bit_persist
) /* synthesis dont_merge syn_preserve = 1 */;
   timeunit 1ns;
   timeprecision 1ps;

   // Indicates whether to use a constant address. If 0, word address is incremented for every burst.
   localparam USE_CONSTANT_ADDR = (TG_TEST_DURATION == "SHORT" ? 1 : 0);

   // Indicates whether to use constant data. If 0, data is incremented for every burst.
   localparam USE_CONSTANT_DATA = (TG_TEST_DURATION == "SHORT" ? 1 : 0);

   // Number of unique word addresses to use.
   localparam NUM_OF_UNIQUE_WORD_ADDRS = (USE_CONSTANT_ADDR == 1)      ? 1 :
                                         (TG_TEST_DURATION == "MEDIUM" ? 128 :
                                                                         2 ** TG_AVL_WORD_ADDR_WIDTH);

   localparam LAST_WORD_ADDR           = AMM_WORD_ADDRESS_DIVISIBLE_BY * NUM_OF_UNIQUE_WORD_ADDRS - 1;

   // Determines how many loops to perform. Number of loops = 2^LOOP_COUNTER_WIDTH - 1.
   localparam LOOP_COUNT_WIDTH = 1;

   // Register read data signals to ease timing closure
   logic                                avl_rdata_valid_r;
   logic [TG_AVL_DATA_WIDTH-1:0]        avl_rdata_r;

   logic                                avl_ready_for_write;

   logic [TG_AVL_DATA_WIDTH-1:0]        nxt_golden_data;
   logic [TG_AVL_DATA_WIDTH-1:0]        nxt_pnf_per_bit;
   logic                                nxt_avl_write_req;
   logic                                nxt_avl_read_req;
   logic [TG_AVL_SIZE_WIDTH-1:0]        nxt_burst_count;
   logic [TG_AVL_WORD_ADDR_WIDTH-1:0]   nxt_word_addr;
   logic [LOOP_COUNT_WIDTH-1:0]         nxt_loop_count;
   logic [TG_AVL_WORD_ADDR_WIDTH-1:0]   nxt_ttl_words_read;

   logic [TG_AVL_DATA_WIDTH-1:0]        golden_data;
   logic [TG_AVL_WORD_ADDR_WIDTH-1:0]   word_addr;
   logic [TG_AVL_SIZE_WIDTH-1:0]        burst_count;
   logic [LOOP_COUNT_WIDTH-1:0]         loop_count;

   logic [TG_AVL_WORD_ADDR_WIDTH-1:0]   ttl_words_read;

   enum int unsigned {
      INIT,
      ISSUE_WRITE,
      WAIT_WRITE_DONE,
      ISSUE_READ,
      WAIT_READ_ACCEPTED,
      WAIT_READ_DONE,
      NEXT_LOOP,
      DONE_PASS,
      DONE_FAIL
   } state, nxt_state;

   ////////////////////////////////////////////////////////////////////////////
   // The following control or externally visible signals must be reset
   ////////////////////////////////////////////////////////////////////////////
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n) begin
         state             <= INIT;
         avl_write_req     <= 1'b0;
         avl_read_req      <= 1'b0;
         avl_rdata_valid_r <= 1'b0;
         loop_count        <= {'0, 1'b1};
         pnf_per_bit       <= '1;
         ttl_words_read    <= '0;
      end else begin
         state             <= nxt_state;
         avl_write_req     <= nxt_avl_write_req;
         avl_read_req      <= nxt_avl_read_req;
         avl_rdata_valid_r <= avl_rdata_valid;
         loop_count        <= nxt_loop_count;
         pnf_per_bit       <= nxt_pnf_per_bit;
         ttl_words_read    <= nxt_ttl_words_read;
      end
   end

   ////////////////////////////////////////////////////////////////////////////
   // The following data signals don't need to be reset
   ////////////////////////////////////////////////////////////////////////////
   always_ff @(posedge clk)
   begin
      avl_wdata    <= golden_data;
      avl_rdata_r  <= avl_rdata;
      burst_count  <= nxt_burst_count;
      word_addr    <= nxt_word_addr;
      golden_data  <= nxt_golden_data;
   end

   ////////////////////////////////////////////////////////////////////////////
   // The following are constant, to reduce the number of unnecessary C2P/P2C
   // connections.
   ////////////////////////////////////////////////////////////////////////////
   assign avl_be         = '1;
   assign avl_size       = AMM_BURST_COUNT_DIVISIBLE_BY[TG_AVL_SIZE_WIDTH-1:0];
   assign avl_addr       = (USE_CONSTANT_ADDR ? '0 : {word_addr, {(TG_AVL_ADDR_WIDTH-TG_AVL_WORD_ADDR_WIDTH){1'b0}}});
   assign avl_addr_w     = avl_addr;
   assign avl_size_w     = avl_size;

   assign avl_ready_for_write = (TG_SEPARATE_READ_WRITE_IFS ? avl_ready_w : avl_ready);

   ////////////////////////////////////////////////////////////////////////////
   // Status signal logic
   ////////////////////////////////////////////////////////////////////////////
   assign pass                = (state == DONE_PASS);
   assign fail                = (state == DONE_FAIL);
   assign timeout             = '0;
   assign pnf_per_bit_persist = pnf_per_bit;

   ////////////////////////////////////////////////////////////////////////////
   // Next-state logic
   ////////////////////////////////////////////////////////////////////////////
   always_comb
   begin
      // Default values

      nxt_state          <= INIT;
      nxt_avl_write_req  <= 1'b0;
      nxt_avl_read_req   <= 1'b0;
      nxt_golden_data    <= golden_data;
      nxt_burst_count    <= burst_count;
      nxt_word_addr      <= word_addr;
      nxt_loop_count     <= loop_count;
      nxt_pnf_per_bit    <= pnf_per_bit;
      nxt_ttl_words_read <= ttl_words_read;

      case (state)
         INIT:
            begin
               // update golden data, which is also the write data, and proceed to write
               nxt_state        <= ISSUE_WRITE;
               nxt_word_addr    <= '0;
               nxt_golden_data  <= (USE_CONSTANT_DATA ? '1 : '0);
            end

         ISSUE_WRITE:
            begin
               // issue write command and proceed to wait for completion
               nxt_state          <= WAIT_WRITE_DONE;
               nxt_avl_write_req  <= 1'b1;
               nxt_burst_count    <= avl_size - 1'b1;
            end

         WAIT_WRITE_DONE:
            begin
               if (!avl_ready_for_write) begin
                  // write data not accepted, wait while holding Avalon signals constants
                  nxt_state         <= WAIT_WRITE_DONE;
                  nxt_avl_write_req <= 1'b1;

               end else if (burst_count != '0) begin
                  // data accepted but burst isn't done, send out the next beat
                  nxt_state          <= WAIT_WRITE_DONE;
                  nxt_avl_write_req  <= 1'b1;
                  nxt_burst_count    <= burst_count - 1'b1;

               end else if (word_addr != LAST_WORD_ADDR) begin
                  // write burst done, but more writes to do
                  nxt_state          <= ISSUE_WRITE;
                  nxt_word_addr      <= word_addr + AMM_WORD_ADDRESS_DIVISIBLE_BY[TG_AVL_WORD_ADDR_WIDTH-1:0];
                  nxt_golden_data    <= (USE_CONSTANT_DATA ? '1 : (golden_data + 1'b1));

               end else begin
                  // done all writes, proceed to do reads
                  nxt_state          <= ISSUE_READ;
                  nxt_word_addr      <= '0;
                  nxt_golden_data    <= (USE_CONSTANT_DATA ? '1 : '0);
               end
            end

         ISSUE_READ:
            begin
               // issue read command and proceed to wait for command acceptance
               nxt_state          <= WAIT_READ_ACCEPTED;
               nxt_avl_read_req   <= 1'b1;
               nxt_burst_count    <= avl_size - 1'b1;
            end

         WAIT_READ_ACCEPTED:
            begin
               if (!avl_ready) begin
                  // command not yet accepted, wait while holding Avalon signals constants
                  nxt_state          <= WAIT_READ_ACCEPTED;
                  nxt_avl_read_req   <= 1'b1;
               end else begin
                  // command accepted, wait for read data return
                  nxt_state          <= WAIT_READ_DONE;
               end
            end

         WAIT_READ_DONE:
            begin
               if (avl_rdata_valid_r) begin
                  nxt_ttl_words_read <= ttl_words_read + 1'b1;

                  // data is available, compare against golden
                  if (avl_rdata_r == golden_data) begin
                     // correct data
                     if (burst_count != '0) begin
                        // not all beats has come back, keep waiting
                        nxt_state <= WAIT_READ_DONE;
                        nxt_burst_count <= burst_count - 1'b1;

                     end else if (word_addr != LAST_WORD_ADDR) begin
                        // read burst done, but more reads to do
                        nxt_state       <= ISSUE_READ;
                        nxt_word_addr   <= word_addr + AMM_WORD_ADDRESS_DIVISIBLE_BY[TG_AVL_WORD_ADDR_WIDTH-1:0];
                        nxt_golden_data <= (USE_CONSTANT_DATA ? '1 : (golden_data + 1'b1));

                     end else begin
                        // proceed to next loop
                        nxt_state <= NEXT_LOOP;
                     end
                  end else begin
                     // incorrect data, update pnf, and fail test
                     nxt_state <= DONE_FAIL;
                     nxt_pnf_per_bit <= ~(avl_rdata_r ^ golden_data);
                  end
               end else begin
                  // no valid data, keep waiting
                  nxt_state <= WAIT_READ_DONE;
               end
            end

         NEXT_LOOP:
            begin
               if (loop_count == '1) begin
                  // all iterations completed, pass test
                  nxt_state <= DONE_PASS;
               end else begin
                  // proceed to next iteration
                  nxt_state <= INIT;
                  nxt_loop_count <= loop_count + 1'b1;
               end
            end

         DONE_PASS:
            begin
               nxt_state <= DONE_PASS;
            end

         DONE_FAIL:
            begin
               nxt_state <= DONE_FAIL;
            end
      endcase
   end

`ifdef ALTERA_EMIF_ENABLE_ISSP
   altsource_probe #(
      .sld_auto_instance_index ("YES"),
      .sld_instance_index      (0),
      .instance_id             ("RCNT"),
      .probe_width             (TG_AVL_WORD_ADDR_WIDTH),
      .source_width            (0),
      .source_initial_value    ("0"),
      .enable_metastability    ("NO")
   ) issp_ttl_words_read (
      .probe  (ttl_words_read)
   );
`endif
endmodule
