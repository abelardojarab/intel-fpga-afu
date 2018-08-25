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
// When enabled, the read compare module buffers the write data and compares
// it with the returned read data.  If the write and read data do not match,
// the corresponding bits of pnf_per_bit is deasserted.
//////////////////////////////////////////////////////////////////////////////

`define _get_pnf_id(_prefix, _i)  (  (((_i)==0) ? `"_prefix``0`" : \
                                     (((_i)==1) ? `"_prefix``1`" : \
                                     (((_i)==2) ? `"_prefix``2`" : \
                                     (((_i)==3) ? `"_prefix``3`" : \
                                     (((_i)==4) ? `"_prefix``4`" : \
                                     (((_i)==5) ? `"_prefix``5`" : \
                                     (((_i)==6) ? `"_prefix``6`" : \
                                     (((_i)==7) ? `"_prefix``7`" : `"_prefix``8`")))))))))

module altera_emif_avl_tg_read_compare # (
   parameter DEVICE_FAMILY             = "",
   parameter DATA_WIDTH                = "",
   parameter BE_WIDTH                  = "",
   parameter ADDR_WIDTH                = "",
   parameter SIZE_WIDTH                = "",
   parameter WORD_ADDR_WIDTH           = "",
   parameter ADDR_BURSTCOUNT_FIFO_SIZE = "",
   parameter WRITTEN_DATA_FIFO_SIZE    = "",
   parameter TG_LFSR_SEED              = 36'b000000111110000011110000111000110010,
   parameter TG_RANDOM_BYTE_ENABLE     = 1
) (
   // Clock and reset
   input                          clk,
   input                          reset_n,

   input                          reset_n_dup,

   // Control signals
   input                          enable,
   input                          queue_read_compare_req,

   // Avalon read data and read addresses
   input                          queue_read_addr_burstcount_req,
   input logic [ADDR_WIDTH-1:0]   read_addr_to_queue,
   input logic [SIZE_WIDTH-1:0]   read_burstcount_to_queue,

   input                          rdata_valid,
   input logic [DATA_WIDTH-1:0]   rdata,

   // Read compare status
   output logic                   read_compare_fifo_full,
   output logic                   read_compare_fifo_empty,
   output logic [DATA_WIDTH-1:0]  pnf_per_bit,
   output logic                   captured_first_fail,
   output logic [ADDR_WIDTH-1:0]  first_fail_exact_addr
);
   timeunit 1ns;
   timeprecision 1ps;
   
   import avl_tg_defs::*;
   
   // Test stages definition
   typedef enum logic [1:0] {
      WAIT_ADDR_FIFO = 2'd0,
      WAIT_READ_DATA = 2'd1
   } state_t;
   
   // Byte size derived from dividing data width by byte enable width
   // Round up so that compile fails if DATA_WIDTH is not a multiple of BE_WIDTH
   localparam BYTE_SIZE = (DATA_WIDTH + BE_WIDTH - 1) / BE_WIDTH;

   // the width of the local data counter
   localparam DATACOUNTER_WIDTH = 8;
   
   // width of counter to emulate a fifo of read comparison requests
   localparam WRITTEN_DATA_COUNTER_WIDTH = ceil_log2(WRITTEN_DATA_FIFO_SIZE) + 2;

   // Write data
   logic [DATA_WIDTH-1:0]        written_data;
   logic [DATA_WIDTH-1:0]        written_data_lfsr_out;
   logic [BE_WIDTH-1:0]          written_be_lfsr_out;
   logic [DATA_WIDTH-1:0]        written_data_r;
   logic [DATA_WIDTH-1:0]        written_data_r2;
   logic [DATA_WIDTH-1:0]        written_data_r3;
   logic [DATA_WIDTH-1:0]        written_data_r4;
   logic [DATA_WIDTH-1:0]        written_be_full;
   logic [DATA_WIDTH-1:0]        written_be_full_r;
   logic [DATA_WIDTH-1:0]        written_be_full_r2;
   logic [DATA_WIDTH-1:0]        written_be_full_r3;
   logic [DATA_WIDTH-1:0]        written_be_full_r4;

   // Read/write data registers
   logic                         rdata_valid_r;
   logic                         rdata_valid_r2;
   logic                         rdata_valid_r3;
   logic                         rdata_valid_r4;
   logic                         rdata_valid_r5;
   logic                         rdata_valid_r6;
   logic [DATA_WIDTH-1:0]        rdata_r;
   logic [DATA_WIDTH-1:0]        rdata_r2;
   logic [DATA_WIDTH-1:0]        rdata_r3;
   logic [DATA_WIDTH-1:0]        rdata_r4;
   logic [DATA_WIDTH-1:0]        rdata_r5;
   logic [DATA_WIDTH-1:0]        rdata_r6;
   
   // Errors related
   logic [DATA_WIDTH-1:0]        pnf_per_bit_r;
   logic [DATA_WIDTH-1:0]        pnf_per_bit_r2;
   logic                         pnf_r2_has_failure;
   logic                         pnf_is_active;
   logic                         pnf_is_active_r;
   logic                         pnf_is_active_r2;
   logic [31:0]                  ttl_fail_pnf;
   logic [31:0]                  ttl_pnf;

   logic                         captured_first_fail_internal /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
   
   logic [DATA_WIDTH-1:0]        first_fail_expected_data;
   logic [DATA_WIDTH-1:0]        first_fail_expected_data_prev;
   logic [DATA_WIDTH-1:0]        first_fail_expected_data_next;
   logic [DATA_WIDTH-1:0]        first_fail_written_be;   
   logic [DATA_WIDTH-1:0]        first_fail_actual_data;
   logic [DATA_WIDTH-1:0]        first_fail_actual_data_prev;
   logic [DATA_WIDTH-1:0]        first_fail_actual_data_next;
   logic                         first_fail_actual_data_valid_prev;
   logic                         first_fail_actual_data_valid_next;
   logic [DATA_WIDTH-1:0]        first_fail_pnf;
   logic [DATA_WIDTH-1:0]        last_rdata;

   // Data Counter
   logic [DATACOUNTER_WIDTH-1:0] data_counter;
   
   // Counter to emulate a fifo of read comparison requests
   logic [WRITTEN_DATA_COUNTER_WIDTH-1:0] written_data_counter;
   logic                         queue_read_compare_req_r;
   logic                         queue_read_compare_req_r2;

   // Should errors be forced?
   logic                         force_error;
   
   // Enable LFSR to re-generate next expected write data/data mask
   logic                         enable_lfsr;
   
   // Control logic to synchronize read data with the originating address
   state_t                       state;
   logic                         addr_fifo_read_req;
   logic [ADDR_WIDTH-1:0]        read_addr;
   logic [ADDR_WIDTH-1:0]        read_addr_r;
   logic [SIZE_WIDTH-1:0]        read_burstcount;
   logic [SIZE_WIDTH-1:0]        read_burstcount_r;
   logic [SIZE_WIDTH-1:0]        read_burstleft;
   logic [SIZE_WIDTH-1:0]        read_burstleft_r;
   logic [WORD_ADDR_WIDTH-1:0]   read_exact_word_addr_r;
   logic [ADDR_WIDTH-1:0]        read_exact_addr_r2;
   logic [ADDR_WIDTH-1:0]        read_exact_addr_r3;
   
   state_t                  nxt_state;
   logic                    nxt_addr_fifo_read_req;   
   logic [ADDR_WIDTH-1:0]   nxt_read_addr;
   logic [SIZE_WIDTH-1:0]   nxt_read_burstcount;
   logic [SIZE_WIDTH-1:0]   nxt_read_burstleft;
   
   // Generate bit-wise byte-enable signal which is easier to read
   generate
   genvar byte_num;
      for (byte_num = 0; byte_num < BE_WIDTH; ++byte_num) 
      begin : gen_written_be_full
         assign written_be_full [byte_num * BYTE_SIZE +: BYTE_SIZE] = {BYTE_SIZE{written_be_lfsr_out[byte_num]}};
      end
   endgenerate

   // Per bit comparison
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n) begin
         pnf_per_bit         <= {DATA_WIDTH{1'b1}};
         pnf_per_bit_r       <= {DATA_WIDTH{1'b1}};
         pnf_per_bit_r2      <= {DATA_WIDTH{1'b1}};
         pnf_is_active       <= 1'b0;
         pnf_is_active_r     <= 1'b0;
         pnf_is_active_r2    <= 1'b0;
         pnf_r2_has_failure  <= 1'b0;

      end else begin
         for (int byte_num = 0; byte_num < BE_WIDTH; byte_num++) begin
            for (int bit_num = 0; bit_num < BYTE_SIZE; bit_num++) begin
               int abs_bit_num;
               abs_bit_num = byte_num * BYTE_SIZE + bit_num;
               if (enable && rdata_valid_r2 && written_be_lfsr_out[byte_num])
                  /*if (rdata[11:0] == 48'h4a3a40fa0052) begin
                    pnf_per_bit[abs_bit_num] <= 1'b1;
                  end else begin*/
                    pnf_per_bit[abs_bit_num] <= (rdata_r2[abs_bit_num] === written_data[abs_bit_num]);
                  //end
               else
                  pnf_per_bit[abs_bit_num] <= 1'b1;
            end
         end

         pnf_per_bit_r      <= pnf_per_bit;
         pnf_per_bit_r2     <= pnf_per_bit_r;
         
         pnf_is_active      <= (enable && rdata_valid_r2);
         pnf_is_active_r    <= pnf_is_active;
         pnf_is_active_r2   <= pnf_is_active_r;
         
         pnf_r2_has_failure <= !(&pnf_per_bit_r);
      end
   end

   // Timing closure pipe stages
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n) begin
         rdata_valid_r             <= 1'b0;
         rdata_valid_r2            <= 1'b0;
         rdata_valid_r3            <= 1'b0;
         rdata_valid_r4            <= 1'b0;
         rdata_valid_r5            <= 1'b0;
         rdata_valid_r6            <= 1'b0;
         queue_read_compare_req_r  <= 1'b0;
         queue_read_compare_req_r2 <= 1'b0;
      end
      else
      begin
         rdata_valid_r             <= rdata_valid;
         rdata_valid_r2            <= rdata_valid_r;
         rdata_valid_r3            <= rdata_valid_r2;
         rdata_valid_r4            <= rdata_valid_r3;
         rdata_valid_r5            <= rdata_valid_r4;
         rdata_valid_r6            <= rdata_valid_r5;
         queue_read_compare_req_r  <= queue_read_compare_req;
         queue_read_compare_req_r2 <= queue_read_compare_req_r;
      end
   end
   
   // Timing closure pipe stages
   always_ff @(posedge clk)
   begin
      rdata_r            <= rdata;
      rdata_r2           <= rdata_r;
      rdata_r3           <= rdata_r2;
      rdata_r4           <= rdata_r3;
      rdata_r5           <= rdata_r4;
      rdata_r6           <= rdata_r5;
      written_data_r     <= written_data;
      written_data_r2    <= written_data_r;
      written_data_r3    <= written_data_r2;
      written_data_r4    <= written_data_r3;
      written_be_full_r  <= written_be_full;
      written_be_full_r2 <= written_be_full_r;
      written_be_full_r3 <= written_be_full_r2;
      written_be_full_r4 <= written_be_full_r3;
      read_addr_r        <= read_addr;
      read_burstcount_r  <= read_burstcount;
      read_burstleft_r   <= read_burstleft;
      read_exact_addr_r2 <= {read_exact_word_addr_r, {(ADDR_WIDTH - WORD_ADDR_WIDTH){1'b0}}};
      read_exact_addr_r3 <= read_exact_addr_r2;
   end
   
   // Must convert read_addr_r to word address before calculation 
   assign read_exact_word_addr_r = read_addr_r[ADDR_WIDTH-1:(ADDR_WIDTH - WORD_ADDR_WIDTH)] + read_burstcount_r - read_burstleft_r - 1'b1;
   
   // Error information
   always_ff @(posedge clk or negedge reset_n_dup)
   begin
      if (!reset_n_dup) begin
         captured_first_fail               <= 1'b0;
         captured_first_fail_internal      <= 1'b0;
         ttl_fail_pnf                      <= '0;
         ttl_pnf                           <= '0;
         first_fail_pnf                    <= '0;
         first_fail_expected_data          <= '0;
         first_fail_expected_data_prev     <= '0;
         first_fail_expected_data_next     <= '0;
         first_fail_written_be             <= '0;
         first_fail_actual_data            <= '0;
         first_fail_actual_data_prev       <= '0;
         first_fail_actual_data_next       <= '0;
         first_fail_actual_data_valid_prev <= '0;
         first_fail_actual_data_valid_next <= '0;
         first_fail_exact_addr             <= '0;
         last_rdata                        <= '0;
      end else begin
         // Collect statistics about total failures and comparisons
         if (pnf_r2_has_failure) begin
       	   ttl_fail_pnf <= ttl_fail_pnf + 1'b1;
         end
         if (pnf_is_active_r2) begin
            ttl_pnf <= ttl_pnf + 1'b1;
         end
         
         // Collect information about the first data mismatch
         if (pnf_r2_has_failure && !captured_first_fail_internal) begin
            captured_first_fail_internal <= 1'b1;
         end
         
         if (pnf_r2_has_failure && !captured_first_fail) begin
            captured_first_fail <= 1'b1;
         end
         
         if (pnf_r2_has_failure && !captured_first_fail_internal) begin
            first_fail_pnf                    <= pnf_per_bit_r2;
            first_fail_expected_data_prev     <= written_data_r4 & written_be_full_r4;
            first_fail_expected_data          <= written_data_r3 & written_be_full_r3;
            first_fail_expected_data_next     <= written_data_r2 & written_be_full_r2;
            first_fail_actual_data_valid_prev <= rdata_valid_r6;
            first_fail_actual_data_valid_next <= rdata_valid_r4;
            first_fail_actual_data_prev       <= rdata_r6 & written_be_full_r4;
            first_fail_actual_data            <= rdata_r5 & written_be_full_r3;
            first_fail_actual_data_next       <= rdata_r4 & written_be_full_r2;
            first_fail_written_be             <= written_be_full_r3;
            first_fail_exact_addr             <= read_exact_addr_r3;
         end
         
         // Collect the last read data, which in WORM mode is
         // the data of the repeated read
         if (rdata_valid_r3) begin
            last_rdata <= rdata_r3 & first_fail_written_be;
         end         
      end
   end
   
`ifdef ALTERA_EMIF_ENABLE_ISSP
   altsource_probe #(
      .sld_auto_instance_index ("YES"),
      .sld_instance_index      (0),
      .instance_id             ("RCNT"),
      .probe_width             (32),
      .source_width            (0),
      .source_initial_value    ("0"),
      .enable_metastability    ("NO")
   ) issp_pnf_count (
      .probe  (ttl_pnf)
   );

   altsource_probe #(
      .sld_auto_instance_index ("YES"),
      .sld_instance_index      (0),
      .instance_id             ("FCNT"),
      .probe_width             (32),
      .source_width            (0),
      .source_initial_value    ("0"),
      .enable_metastability    ("NO")
   ) issp_ttl_fail_pnf (
      .probe  (ttl_fail_pnf)
   );

   altsource_probe #(
      .sld_auto_instance_index ("YES"),
      .sld_instance_index      (0),
      .instance_id             ("FADR"),
      .probe_width             (ADDR_WIDTH),
      .source_width            (0),
      .source_initial_value    ("0"),
      .enable_metastability    ("NO")
   ) issp_first_fail_exact_addr (
      .probe  (first_fail_exact_addr)
   );
   
   altsource_probe #(
      .sld_auto_instance_index ("YES"),
      .sld_instance_index      (0),
      .instance_id             ("RAVP"),
      .probe_width             (1),
      .source_width            (0),
      .source_initial_value    ("0"),
      .enable_metastability    ("NO")
   ) tg_rd_valid_prev (
      .probe  (first_fail_actual_data_valid_prev)
   );

   altsource_probe #(
      .sld_auto_instance_index ("YES"),
      .sld_instance_index      (0),
      .instance_id             ("RAVN"),
      .probe_width             (1),
      .source_width            (0),
      .source_initial_value    ("0"),
      .enable_metastability    ("NO")
   ) tg_rd_valid_next (
      .probe  (first_fail_actual_data_valid_next)
   );
   
   localparam MAX_PROBE_WIDTH = 511;
   generate
      genvar i;
      for (i = 0; i < (DATA_WIDTH + MAX_PROBE_WIDTH - 1) / MAX_PROBE_WIDTH; i = i + 1)
      begin : gen_wd_rd
         altsource_probe #(
            .sld_auto_instance_index ("YES"),
            .sld_instance_index      (0),
            .instance_id             (`_get_pnf_id(FPN, i)),
            .probe_width             ((MAX_PROBE_WIDTH * (i+1)) > DATA_WIDTH ? DATA_WIDTH - (MAX_PROBE_WIDTH * i) : MAX_PROBE_WIDTH),
            .source_width            (0),
            .source_initial_value    ("0"),
            .enable_metastability    ("NO")
         ) tg_pnf (
            .probe  (first_fail_pnf[((MAX_PROBE_WIDTH * (i+1) - 1) < DATA_WIDTH-1 ? (MAX_PROBE_WIDTH * (i+1) - 1) : DATA_WIDTH-1) : (MAX_PROBE_WIDTH * i)])
         );      
         altsource_probe #(
            .sld_auto_instance_index ("YES"),
            .sld_instance_index      (0),
            .instance_id             (`_get_pnf_id(FEX, i)),
            .probe_width             ((MAX_PROBE_WIDTH * (i+1)) > DATA_WIDTH ? DATA_WIDTH - (MAX_PROBE_WIDTH * i) : MAX_PROBE_WIDTH),
            .source_width            (0),
            .source_initial_value    ("0"),
            .enable_metastability    ("NO")
         ) tg_wd (
            .probe  (first_fail_expected_data[((MAX_PROBE_WIDTH * (i+1) - 1) < DATA_WIDTH-1 ? (MAX_PROBE_WIDTH * (i+1) - 1) : DATA_WIDTH-1) : (MAX_PROBE_WIDTH * i)])
         );
         altsource_probe #(
            .sld_auto_instance_index ("YES"),
            .sld_instance_index      (0),
            .instance_id             (`_get_pnf_id(FEP, i)),
            .probe_width             ((MAX_PROBE_WIDTH * (i+1)) > DATA_WIDTH ? DATA_WIDTH - (MAX_PROBE_WIDTH * i) : MAX_PROBE_WIDTH),
            .source_width            (0),
            .source_initial_value    ("0"),
            .enable_metastability    ("NO")
         ) tg_wd_prev (
            .probe  (first_fail_expected_data_prev[((MAX_PROBE_WIDTH * (i+1) - 1) < DATA_WIDTH-1 ? (MAX_PROBE_WIDTH * (i+1) - 1) : DATA_WIDTH-1) : (MAX_PROBE_WIDTH * i)])
         );
         altsource_probe #(
            .sld_auto_instance_index ("YES"),
            .sld_instance_index      (0),
            .instance_id             (`_get_pnf_id(FEN, i)),
            .probe_width             ((MAX_PROBE_WIDTH * (i+1)) > DATA_WIDTH ? DATA_WIDTH - (MAX_PROBE_WIDTH * i) : MAX_PROBE_WIDTH),
            .source_width            (0),
            .source_initial_value    ("0"),
            .enable_metastability    ("NO")
         ) tg_wd_next (
            .probe  (first_fail_expected_data_next[((MAX_PROBE_WIDTH * (i+1) - 1) < DATA_WIDTH-1 ? (MAX_PROBE_WIDTH * (i+1) - 1) : DATA_WIDTH-1) : (MAX_PROBE_WIDTH * i)])
         );
         altsource_probe #(
            .sld_auto_instance_index ("YES"),
            .sld_instance_index      (0),
            .instance_id             (`_get_pnf_id(ACT, i)),
            .probe_width             ((MAX_PROBE_WIDTH * (i+1)) > DATA_WIDTH ? DATA_WIDTH - (MAX_PROBE_WIDTH * i) : MAX_PROBE_WIDTH),
            .source_width            (0),
            .source_initial_value    ("0"),
            .enable_metastability    ("NO")
         ) tg_rd (
            .probe  (first_fail_actual_data[((MAX_PROBE_WIDTH * (i+1) - 1) < DATA_WIDTH-1 ? (MAX_PROBE_WIDTH * (i+1) - 1) : DATA_WIDTH-1) : (MAX_PROBE_WIDTH * i)])
         );
         altsource_probe #(
            .sld_auto_instance_index ("YES"),
            .sld_instance_index      (0),
            .instance_id             (`_get_pnf_id(ACP, i)),
            .probe_width             ((MAX_PROBE_WIDTH * (i+1)) > DATA_WIDTH ? DATA_WIDTH - (MAX_PROBE_WIDTH * i) : MAX_PROBE_WIDTH),
            .source_width            (0),
            .source_initial_value    ("0"),
            .enable_metastability    ("NO")
         ) tg_rd_prev (
            .probe  (first_fail_actual_data_prev[((MAX_PROBE_WIDTH * (i+1) - 1) < DATA_WIDTH-1 ? (MAX_PROBE_WIDTH * (i+1) - 1) : DATA_WIDTH-1) : (MAX_PROBE_WIDTH * i)])
         );
         altsource_probe #(
            .sld_auto_instance_index ("YES"),
            .sld_instance_index      (0),
            .instance_id             (`_get_pnf_id(ACN, i)),
            .probe_width             ((MAX_PROBE_WIDTH * (i+1)) > DATA_WIDTH ? DATA_WIDTH - (MAX_PROBE_WIDTH * i) : MAX_PROBE_WIDTH),
            .source_width            (0),
            .source_initial_value    ("0"),
            .enable_metastability    ("NO")
         ) tg_rd_next (
            .probe  (first_fail_actual_data_next[((MAX_PROBE_WIDTH * (i+1) - 1) < DATA_WIDTH-1 ? (MAX_PROBE_WIDTH * (i+1) - 1) : DATA_WIDTH-1) : (MAX_PROBE_WIDTH * i)])
         );
         altsource_probe #(
            .sld_auto_instance_index ("YES"),
            .sld_instance_index      (0),
            .instance_id             (`_get_pnf_id(LRD, i)),
            .probe_width             ((MAX_PROBE_WIDTH * (i+1)) > DATA_WIDTH ? DATA_WIDTH - (MAX_PROBE_WIDTH * i) : MAX_PROBE_WIDTH),
            .source_width            (0),
            .source_initial_value    ("0"),
            .enable_metastability    ("NO")
         ) tg_last_rdata (
            .probe  (last_rdata[((MAX_PROBE_WIDTH * (i+1) - 1) < DATA_WIDTH-1 ? (MAX_PROBE_WIDTH * (i+1) - 1) : DATA_WIDTH-1) : (MAX_PROBE_WIDTH * i)])
         );         
      end
   endgenerate
`endif

   // The data is used as a small counter to count data coming back. It is
   // used by the force_error mode to introduce errors.
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n)
         data_counter <= '0;
      else
         if (rdata_valid_r2)
            data_counter <= data_counter + 1'b1;
   end

   // synthesis translate_off   
   // Display a message to the user if there is an error
   logic [511:0] bitwise_xor = 'b0;
   logic pnfperbit_logic;
   logic [511:0] bitwise_xor_d;
   logic bitwise_or;
   assign bitwise_xor_d = ~bitwise_xor ^ pnf_per_bit;
   assign bitwise_or = |bitwise_xor_d;
   assign pnfperbit_logic = ~(&pnf_per_bit);
   always_ff @(posedge clk)
   begin
      //if (~(&pnf_per_bit))
      if (pnfperbit_logic)
      begin
        // if ((written_data_r != rdata_r3) && (written_data_r != rdata_r4)) begin
           //$display("[%0t] ERROR: Expected %h/%h but read %h", $time, written_data_r, written_be_full_r, rdata_r3);
           $display("[%0t] ERROR: Expected %h/%h but read %h", $time, written_data, written_be_full_r, rdata_r3);
           $display("            wrote bits: %h", written_data_r & written_be_full_r);
           $display("             read bits: %h", rdata_r3 & written_be_full_r);
           //$display("             read bits: %h", rdata_r4 & written_be_full_r);
      //   end 
      end
      //end else if (bitwise_or) begin
      if (~pnfperbit_logic && (written_data_r == rdata_r3)) begin
         $display("[%0t] SUCCESS: Expected %h/%h and read %h", $time, written_data_r, written_be_full_r, rdata_r3);
         $display("               wrote bits: %h", written_data_r & written_be_full_r);
         $display("               read bits: %h", rdata_r3 & written_be_full_r);
      end
   end
   // synthesis translate_on

   assign force_error = 1'b0;

   assign written_data = (force_error) ?
      ((data_counter > 10) ? {written_data_lfsr_out[DATA_WIDTH-1:1],~written_data_lfsr_out[0]} : written_data_lfsr_out) :
      written_data_lfsr_out;
   
   // We use LFSRs to re-generate the random write data/mask for 
   // read comparison. By using the same seed we're guaranteed
   // to regenerate the same sequence. This saves us from the 
   // need of instantiating a FIFO to record the write data (and
   // the timing closure challenge associated with it), at
   // the expense of flexibility (that we currently don't need).
   // For example if one of the stages need to use special data
   // instead of LFSR, we can't handle it.
   
   // Enable LFSR to generate the next item
   assign enable_lfsr = enable & rdata_valid_r2;
   
   // Write data generator
   altera_emif_avl_tg_lfsr_wrapper # (
      .DATA_WIDTH   (DATA_WIDTH),
      .SEED         (TG_LFSR_SEED)
   ) data_gen_inst (
      .clk          (clk),
      .reset_n      (reset_n),
      .enable       (enable_lfsr),
      .data         (written_data_lfsr_out)
   );
   
   // Byte enable generator
   generate
      if (TG_RANDOM_BYTE_ENABLE == 1)
      begin : be_gen
         altera_emif_avl_tg_lfsr_wrapper # (
            .DATA_WIDTH   (BE_WIDTH)
         ) be_gen_inst (
            .clk          (clk),
            .reset_n      (reset_n),
            .enable       (enable_lfsr),
            .data         (written_be_lfsr_out)
         );
      end 
      else 
      begin : be_const
         assign written_be_lfsr_out = '1;
      end
   endgenerate      

   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n)
         written_data_counter <= '1;
      else if (enable & queue_read_compare_req_r2 & rdata_valid_r)
         written_data_counter <= written_data_counter;
      else if (enable & queue_read_compare_req_r2)
         written_data_counter <= written_data_counter + 1'b1;
      else if (enable & rdata_valid_r)
         written_data_counter <= written_data_counter - 1'b1;
      else 
         written_data_counter <= written_data_counter;
   end
   
   assign read_compare_fifo_full  = (written_data_counter[WRITTEN_DATA_COUNTER_WIDTH-1:WRITTEN_DATA_COUNTER_WIDTH-2] == 2'b01);
   assign read_compare_fifo_empty = written_data_counter[WRITTEN_DATA_COUNTER_WIDTH-1] || (written_data_counter == 'b0);
   //assign read_compare_fifo_empty = written_data_counter[WRITTEN_DATA_COUNTER_WIDTH-1];
   
   // Register stage to ease timing closure. The assumption is that read data
   // must come back after this additional latency, or else we will underflow fifo.
   logic                    addr_fifo_write_req;
   logic [ADDR_WIDTH-1:0]   addr_fifo_in_addr;
   logic [SIZE_WIDTH-1:0]   addr_fifo_in_burstcount;
   
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n) begin
         addr_fifo_write_req     <= 1'b0;
         addr_fifo_in_addr       <= '0;
         addr_fifo_in_burstcount <= '0;
      end else begin
         addr_fifo_write_req     <= queue_read_addr_burstcount_req;
         addr_fifo_in_addr       <= read_addr_to_queue;
         addr_fifo_in_burstcount <= read_burstcount_to_queue;
      end
   end
   
   // FIFO to store read address/burstcount so that when read data comes
   // back we can map it back to the originating address
   logic                    addr_fifo_empty;
   logic [ADDR_WIDTH-1:0]   addr_fifo_out_addr;
   logic [SIZE_WIDTH-1:0]   addr_fifo_out_burstcount;
   
   altera_emif_avl_tg_scfifo_wrapper # (
      .DEVICE_FAMILY   (DEVICE_FAMILY),
      .FIFO_WIDTH      (ADDR_WIDTH + SIZE_WIDTH),
      .FIFO_SIZE       (ADDR_BURSTCOUNT_FIFO_SIZE),
      .SHOW_AHEAD      ("ON")
   ) addr_burstcount_fifo (
      .clk             (clk),
      .reset_n         (reset_n),
      .write_req       (addr_fifo_write_req),
      .read_req        (addr_fifo_read_req),
      .data_in         ({addr_fifo_in_addr, addr_fifo_in_burstcount}),
      .data_out        ({addr_fifo_out_addr,addr_fifo_out_burstcount}),
      .full            (),
      .empty           (addr_fifo_empty)
   );   
   
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n) begin
         state              <= WAIT_ADDR_FIFO;
         read_addr          <= '0;
         read_burstcount    <= '0;
         read_burstleft     <= '0;
         addr_fifo_read_req <= '0;
      end else begin
         state              <= nxt_state;
         read_addr          <= nxt_read_addr;
         read_burstcount    <= nxt_read_burstcount;
         read_burstleft     <= nxt_read_burstleft;
         addr_fifo_read_req <= nxt_addr_fifo_read_req;
      end
   end
   
   always_comb
   begin
      nxt_state              <= state;
      nxt_read_addr          <= read_addr;
      nxt_read_burstcount    <= read_burstcount;
      nxt_read_burstleft     <= read_burstleft;
      nxt_addr_fifo_read_req <= 1'b0;
      
      case (state)
         WAIT_ADDR_FIFO:
            begin
               if (!addr_fifo_empty) begin
                  nxt_state              <= WAIT_READ_DATA;
                  nxt_read_addr          <= addr_fifo_out_addr;
                  nxt_read_burstcount    <= addr_fifo_out_burstcount;
                  nxt_read_burstleft     <= addr_fifo_out_burstcount - 1'b1;
                  nxt_addr_fifo_read_req <= 1'b1;
               end
            end
         WAIT_READ_DATA:
            begin
               if (rdata_valid_r2) begin
                  if (read_burstleft != 0) begin
                     nxt_read_burstleft  <= read_burstleft - 1'b1;
                  end else begin
                     if (!addr_fifo_empty) begin
                        nxt_read_addr          <= addr_fifo_out_addr;
                        nxt_read_burstcount    <= addr_fifo_out_burstcount;
                        nxt_read_burstleft     <= addr_fifo_out_burstcount - 1'b1;
                        nxt_addr_fifo_read_req <= 1'b1;
                     end else begin
                        nxt_state <= WAIT_ADDR_FIFO;
                     end
                  end
               end
            end
      endcase
   end

endmodule

