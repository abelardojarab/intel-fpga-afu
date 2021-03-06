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
// The block write/read test stage performs a parametrizable number of write
// operations, followed by the same number of read operations to the same
// addresses.  The write/read cycle repeats for a parametrizable number of
// times.  The number of write/read cycles that various address generators
// are used are also parametrizable.
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_block_rw_stage # (

   // The number of write/read cycles that each address generator is used
   parameter SEQ_ADDR_COUNT                  = "",
   parameter RAND_ADDR_COUNT                 = "",
   parameter RAND_SEQ_ADDR_COUNT             = "",

   // The number of write operations in a write/read cycle
   parameter BLOCK_SIZE                      = "",

   // Should the stage wait for all read data to come back before switching
   // address generators? This is typically used for protocols such as QDR II.
   parameter USE_BLOCKING_ADDRESS_GENERATION = 0
   
) (
   // Clock and reset
   input  logic                                      clk,
   input  logic                                      reset_n,

   // can_write and can_read indicates whether a do_write or do_read can be issued
   input  logic                                      can_write,
   input  logic                                      can_read,

   // Read compare status
   input  logic                                      read_compare_fifo_empty,

   // Address generator selector
   output avl_tg_defs::addr_gen_select_t             addr_gen_select,

   // Command output logics
   output logic                                      do_write,
   output logic                                      do_read,

   // Control and status
   input  logic                                      stage_enable,
   output logic                                      stage_complete
);
   timeunit 1ns;
   timeprecision 1ps;
   
   import avl_tg_defs::*;

   // The total number of write/read cycles
   localparam NUM_BLOCK_WRITES            = SEQ_ADDR_COUNT + RAND_ADDR_COUNT + RAND_SEQ_ADDR_COUNT;

   // Counter widths
   localparam BLOCK_WRITE_COUNTER_WIDTH   = log2(NUM_BLOCK_WRITES) + 1;
   localparam BLOCK_SIZE_COUNTER_WIDTH    = log2(BLOCK_SIZE) + 1;

   // Counters
   logic [BLOCK_WRITE_COUNTER_WIDTH-1:0]   block_write_counter;
   logic [BLOCK_SIZE_COUNTER_WIDTH-1:0]    block_size_counter;

   // Block write/read state machine
   enum int unsigned {
      INIT,
      BLOCK_WRITE,
      BLOCK_READ,
      WAIT_ADDR_GEN,
      WAIT,
      DONE
   } state;
   
   // Depending on configuration, we might need to wait for all read
   // data to come back before switching address generators
   addr_gen_select_t	addr_gen_select_r;
   logic do_wait;

   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n) begin
         block_write_counter <= '0;
         block_size_counter <= '0;
         
         if (SEQ_ADDR_COUNT > 0)
            addr_gen_select <= SEQ;
         else if (SEQ_ADDR_COUNT + RAND_ADDR_COUNT > 0)
            addr_gen_select <= RAND;
         else
            addr_gen_select <= RAND_SEQ;
         addr_gen_select_r <= SEQ;
         do_wait <= 1'b0;
         state <= INIT;
      
      end else begin
         addr_gen_select_r <= addr_gen_select;
      
         case (state)
            INIT:
               // Standby until this stage is signaled to start
               if (NUM_BLOCK_WRITES <= 0)
                  state <= DONE;
               else if (stage_enable)
                  state <= BLOCK_WRITE;

            BLOCK_WRITE:
               // Issue 'BLOCK_SIZE' write commands in this state
               if (can_write) begin
                  if (block_size_counter == BLOCK_SIZE[BLOCK_SIZE_COUNTER_WIDTH-1:0] - 1'b1) begin
                     block_size_counter <= '0;
                     block_write_counter <= block_write_counter + 1'b1;
                     
                     if (block_write_counter + 1'b1 < SEQ_ADDR_COUNT)
                        addr_gen_select <= SEQ;
                     else if (block_write_counter + 1'b1 < SEQ_ADDR_COUNT + RAND_ADDR_COUNT)
                        addr_gen_select <= RAND;
                     else
                        addr_gen_select <= RAND_SEQ;
                     state <= BLOCK_READ;
                     
                  end else begin
                     block_size_counter <= block_size_counter + 1'b1;
                  end
               end

            BLOCK_READ:
            begin
               if (addr_gen_select_r != addr_gen_select)
                  do_wait <= 1'b1;
            
               // Issue 'BLOCK_SIZE' read commands in this state
               if (can_read) begin
                  if (block_size_counter == BLOCK_SIZE[BLOCK_SIZE_COUNTER_WIDTH-1:0] - 1'b1) begin
                     block_size_counter <= '0;
                     if (block_write_counter == NUM_BLOCK_WRITES)
                        // All commands have been issued
                        state <= WAIT;
                     else if (USE_BLOCKING_ADDRESS_GENERATION && (addr_gen_select_r != addr_gen_select || do_wait))
                        state <= WAIT_ADDR_GEN;
                     else
                        state <= BLOCK_WRITE;
                  end else begin
                     block_size_counter <= block_size_counter + 1'b1;
                  end
               end
            end
            
            WAIT_ADDR_GEN:
            begin
               do_wait <= 1'b0;
               if (read_compare_fifo_empty)
                  // All read data have returned
                  state <= BLOCK_WRITE;
            end            

            WAIT:
            begin
               do_wait <= 1'b0;
               if (read_compare_fifo_empty)
                  // All read data have returned and verified
                  state <= DONE;
            end

            DONE:
            begin
               block_write_counter <= '0;
               block_size_counter <= '0;
               if (SEQ_ADDR_COUNT > 0)
                  addr_gen_select <= SEQ;
               else if (SEQ_ADDR_COUNT + RAND_ADDR_COUNT > 0)
                  addr_gen_select <= RAND;
               else
                  addr_gen_select <= RAND_SEQ;
               state <= INIT;
            end
         endcase
      end
   end

   // Command outputs
   always_comb
   begin
      do_write <= 1'b0;
      do_read <= 1'b0;
      case (state)
         BLOCK_WRITE:   if (can_write) do_write <= 1'b1;
         BLOCK_READ:    if (can_read) do_read <= 1'b1;
         default:       ; 
      endcase
   end

   // Status outputs
   assign stage_complete = (state == DONE);
endmodule

