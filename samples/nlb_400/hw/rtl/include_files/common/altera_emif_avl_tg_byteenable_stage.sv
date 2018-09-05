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
// The byte-enable performs a parametrizable number of write-write-read
// sequences, where the second write uses the same address and burst size
// as the first write, but with bit-wise inverted byteenable. 
// If byteenable works properly, then the second write must not corrupt
// the unmasked data of the first write (because during the second write
// they are masked) - the read operation checks for this condition
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_byteenable_stage # (

   // The number of write/read cycles that each address generator is used
   parameter RAND_ADDR_COUNT                 = "",

   // Should the stage wait for all read data to come back before switching
   // address generators? This is typically used for protocols such as QDR II.
   parameter USE_BLOCKING_ADDRESS_GENERATION = 0
   
) (
   // Clock and reset
   input  logic                                    clk,
   input  logic                                    reset_n,

   // can_write and can_read indicates whether a do_write or do_read can be issued
   input  logic                                    can_write,
   input  logic                                    can_read,

   // Read compare status
   input  logic                                    read_compare_fifo_empty,
   
   // Status of the write command fifo. These signals are only used
   // by protocols such as QDRII, to guard against race conditions 
   // whereby reads can start before writes have finished.
   input  logic                                    fifo_w_empty, 

   // Address generator selector
   output avl_tg_defs::addr_gen_select_t           addr_gen_select,

   // Command outputs
   output logic                                    do_inv_be_write,
   output logic                                    do_write,
   output logic                                    do_read,

   // Control and status
   input  logic                                    stage_enable,
   output logic                                    stage_complete
);
   timeunit 1ns;
   timeprecision 1ps;
   
   import avl_tg_defs::*;

   // The total number of write/read cycles
   localparam NUM_SEQS = RAND_ADDR_COUNT;
   
   // Should we wait for all writes to finish before issuing reads?
   // This is typically used for protocols such as QDRII, to avoid
   // race condition
   localparam ENSURE_WRITES_DONE_BEFORE_READS = USE_BLOCKING_ADDRESS_GENERATION;

   // Counter width
   localparam SEQ_COUNTER_WIDTH = log2(NUM_SEQS) + 1;
   localparam PAUSE_COUNTER_WIDTH = 3;

   // Counters
   logic [SEQ_COUNTER_WIDTH-1:0] seq_counter;
   logic [PAUSE_COUNTER_WIDTH-1:0] pause_counter;
   
   // Register fifo_w_empty to ease timing
   logic fifo_w_empty_r;

   // Block write/read state machine
   enum int unsigned {
      INIT,
      NORMAL_WRITE,
      INVERT_WRITE,
      PAUSE,
      WAIT_ALL_WRITES_FLUSHED,
      SINGLE_READ,
      WAIT,
      DONE
   } state;
   
   // For simplicity, simply always use random addgress
   assign addr_gen_select = RAND;
   
   always_ff @(posedge clk)
   begin
      if (!reset_n) begin
         fifo_w_empty_r <= '0;
         pause_counter <= '0;
      end else begin
         fifo_w_empty_r <= fifo_w_empty;
         
         if (state == PAUSE)
            pause_counter <= pause_counter + 1'b1;
         else
            pause_counter <= '0;
      end
   end

   always_ff @(posedge clk)
   begin
      if (!reset_n) begin
         seq_counter <= '0;
         state <= INIT;
         
      end else begin
         case (state)
            INIT:
               // Standby until this stage is signaled to start
               if (NUM_SEQS <= 0)
                  state <= DONE;
               else if (stage_enable)
                  state <= NORMAL_WRITE;

            NORMAL_WRITE:
               // Issue a single write command in this state
               if (can_write) 
                  state <= INVERT_WRITE;
                  
            INVERT_WRITE:
               // Issue a single write command with the same address
               // and burst size as in the NORMAL_WRITE state, but
               // with inverted data and be.
               if (can_write) begin
                  seq_counter <= seq_counter + 1'b1;
                  state <= PAUSE;
               end
               
            PAUSE:
               // It can takes a few cycles for the avalon command generator
               // to accept the write command. 8 cycles are more than sufficient.
               if (pause_counter == {PAUSE_COUNTER_WIDTH{1'b1}})
                  state <= WAIT_ALL_WRITES_FLUSHED;
                  
            WAIT_ALL_WRITES_FLUSHED:
               if (ENSURE_WRITES_DONE_BEFORE_READS) begin
                  if (fifo_w_empty_r)
                     state <= SINGLE_READ;
               end else begin
                  state <= SINGLE_READ;
               end

            SINGLE_READ:
            begin
               // Issue a single read command in this state
               if (can_read) begin
                  if (seq_counter == NUM_SEQS)
                     // All commands have been issued
                     state <= WAIT;
                  else
                     state <= NORMAL_WRITE;
               end
            end

            WAIT:
            begin
               if (read_compare_fifo_empty)
                  // All read data have returned
                  state <= DONE;
            end

            DONE:
            begin
               seq_counter <= '0;
               state <= INIT;
            end
         endcase
      end
   end

   // Command outputs
   always_comb
   begin
      do_write        <= 1'b0;
      do_inv_be_write <= 1'b0;
      do_read         <= 1'b0;
      
      case (state)
         NORMAL_WRITE:   if (can_write) do_write <= 1'b1;
         INVERT_WRITE:   if (can_write) do_inv_be_write <= 1'b1;
         SINGLE_READ:    if (can_read)  do_read <= 1'b1;
         default:        ; 
      endcase
   end

   // Status outputs
   assign stage_complete = (state == DONE);
endmodule

