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
// The single write/read test stage performs a parametrizable number of
// interleaving write and read operation.  The number of write/read cycles
// that various address generators are used are parametrizable.
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_single_rw_stage # (

   // The number of write/read cycles that each address generator is used
   parameter SEQ_ADDR_COUNT                  = "",
   parameter RAND_ADDR_COUNT                 = "",
   parameter RAND_SEQ_ADDR_COUNT             = "",

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

   // Address generator selector
   output avl_tg_defs::addr_gen_select_t           addr_gen_select,

   // Command outputs
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
   localparam NUM_SINGLE_WRITES = SEQ_ADDR_COUNT + RAND_ADDR_COUNT + RAND_SEQ_ADDR_COUNT;

   // Counter width
   localparam SINGLE_WRITE_COUNTER_WIDTH = log2(NUM_SINGLE_WRITES) + 1;

   // Counters
   logic [SINGLE_WRITE_COUNTER_WIDTH-1:0] single_write_counter;

   // Block write/read state machine
   enum int unsigned {
      INIT,
      SINGLE_WRITE,
      SINGLE_READ,
      WAIT_ADDR_GEN,
      WAIT,
      DONE
   } state;
   
   // Depending on configuration, we might need to wait for all read
   // data to come back before switching address generators
   addr_gen_select_t	addr_gen_select_r;
   logic do_wait;

   always_ff @(posedge clk)
   begin
      if (!reset_n) begin
         single_write_counter <= '0;
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
               if (NUM_SINGLE_WRITES <= 0)
                  state <= DONE;
               else if (stage_enable)
                  state <= SINGLE_WRITE;

            SINGLE_WRITE:
               // Issue a single write command in this state
               if (can_write) begin
                  single_write_counter <= single_write_counter + 1'b1;
                  if (single_write_counter + 1'b1 < SEQ_ADDR_COUNT)
                     addr_gen_select <= SEQ;
                  else if (single_write_counter + 1'b1 < SEQ_ADDR_COUNT + RAND_ADDR_COUNT)
                     addr_gen_select <= RAND;
                  else
                     addr_gen_select <= RAND_SEQ;
                  state <= SINGLE_READ;
               end

            SINGLE_READ:
            begin
               if (addr_gen_select_r != addr_gen_select)
                  do_wait <= 1'b1;
            
               // Issue a single read command in this state
               if (can_read) begin
                  if (single_write_counter == NUM_SINGLE_WRITES)
                     // All commands have been issued
                     state <= WAIT;
                  else if (USE_BLOCKING_ADDRESS_GENERATION && (addr_gen_select_r != addr_gen_select || do_wait))
                     state <= WAIT_ADDR_GEN;
                  else
                     state <= SINGLE_WRITE;
               end
            end
            
            WAIT_ADDR_GEN:
            begin
               do_wait <= 1'b0;
               if (read_compare_fifo_empty)
                  // All read data have returned
                  state <= SINGLE_WRITE;
            end            

            WAIT:
            begin
               do_wait <= 1'b0;
               if (read_compare_fifo_empty)
                  // All read data have returned
                  state <= DONE;
            end

            DONE:
            begin
               single_write_counter <= '0;
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
         SINGLE_WRITE:   if (can_write) do_write <= 1'b1;
         SINGLE_READ:    if (can_read) do_read <= 1'b1;
         default:        ; 
      endcase
   end

   // Status outputs
   assign stage_complete = (state == DONE);
endmodule

