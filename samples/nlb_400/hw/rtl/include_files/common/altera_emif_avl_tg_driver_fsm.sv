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
// The driver state machine controls the test stages modules, and multiplexes
// the signals into and out of the active stage module.
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_driver_fsm # (
   // Single write/read stage
   parameter SINGLE_RW_SEQ_ADDR_COUNT         = "",
   parameter SINGLE_RW_RAND_ADDR_COUNT        = "",
   parameter SINGLE_RW_RAND_SEQ_ADDR_COUNT    = "",

   // Block write/read stage
   parameter BLOCK_RW_SEQ_ADDR_COUNT          = "",
   parameter BLOCK_RW_RAND_ADDR_COUNT         = "",
   parameter BLOCK_RW_RAND_SEQ_ADDR_COUNT     = "",
   parameter BLOCK_RW_BLOCK_SIZE              = "",

   // Byte-enable stage
   parameter BYTEENABLE_STAGE_RAND_ADDR_COUNT = "",
   
   // Template stage
   parameter TEMPLATE_STAGE_COUNT             = "",

   // Timeout counter width
   // If the test stages are modified, this parameter
   // may need adjustment to avoid premature timeouts.
   parameter TIMEOUT_COUNTER_WIDTH            = "",

   // NUM_DRIVER_LOOP
   // Specifies the maximum number of loops through the driver patterns
   // before asserting test complete. A setting of 0 will cause the driver to
   // loop infinitely.
   parameter NUM_DRIVER_LOOP                  = "",

   // Should the stage wait for all read data to come back before switching
   // address generators? This is typically used for protocols such as QDR II.
   parameter USE_BLOCKING_ADDRESS_GENERATION   = 0
   
) (
   // Clock and reset
   input  logic                                   clk,
   input  logic                                   reset_n,

   // WORM mode: If a data mismatch is encountered, stop as much of the traffic as possible
   // and issue a read to the same address. In this mode, the persistent PNF
   // is no longer meaningful as we basically stop at the first data mismatch.
   input  logic                                   worm_en,
   
   // can_write and can_read indicates whether a do_write or do_read can be issued
   input  logic                                   can_write,
   input  logic                                   can_read,

   // Read compare status
   input  logic                                   read_compare_fifo_full,
   input  logic                                   read_compare_fifo_empty,
   input  logic                                   captured_first_fail,
   
   // Status of the write command fifo. These signals are only used
   // by protocols such as QDRII, to guard against race conditions 
   // whereby reads can start before writes have finished.
   input  logic                                   fifo_w_full,
   input  logic                                   fifo_w_empty,

   // Address generator selector
   output avl_tg_defs::addr_gen_select_t          addr_gen_select,
   
   // Are we testing byte-enable? If so we must be able to regenerate same write data
   output logic                                   byteenable_stage,

   // Command outputs
   output logic                                   do_inv_be_write,
   output logic                                   do_write,
   output logic                                   do_read,
  
   output [3:0]                                   fsm_state,

   // Driver status
   output logic                                   test_complete,
   output logic                                   timeout,
   output logic [31:0]                            loop_counter
);
   timeunit 1ns;
   timeprecision 1ps;
   
   import avl_tg_defs::*;

   // Test stages definition
   typedef enum int unsigned {
      INIT,
      SINGLE_RW,
      BLOCK_RW,
      BYTEENABLE_STAGE,
      TEMPLATE_STAGE,
      REREAD_STAGE,
      DONE,
      TEST_COMPLETE,
      TIMEOUT
   } test_stage_t;

   // Single write/read stage signals
   addr_gen_select_t                 single_rw_addr_gen_select;
   logic                             single_rw_do_write;
   logic                             single_rw_do_read;
   logic                             single_rw_complete;

   // Block write/read stage signals
   addr_gen_select_t                 block_rw_addr_gen_select;
   logic                             block_rw_do_write;
   logic                             block_rw_do_read;
   logic                             block_rw_complete;
   
   // Byteenable stage signals
   addr_gen_select_t                 byteenable_stage_addr_gen_select;
   logic                             byteenable_stage_do_write;
   logic                             byteenable_stage_do_read;
   logic                             byteenable_stage_complete;   

   // Template stage signals
   addr_gen_select_t                 template_stage_addr_gen_select;
   logic                             template_stage_do_write;
   logic                             template_stage_do_read;
   logic                             template_stage_complete;

   // Timeout counter
   logic [TIMEOUT_COUNTER_WIDTH:0]   timeout_counter;

   // Test stages
   test_stage_t                      stage;

   assign fsm_state = stage[3:0];

   // Generate status signals
   assign test_complete    = (stage == TEST_COMPLETE);
   assign timeout          = (stage == TIMEOUT);
   assign byteenable_stage = (stage == BYTEENABLE_STAGE);

   // Test stages signals mux
   always_comb
   begin
      case (stage)
         SINGLE_RW:
         begin
            addr_gen_select <= single_rw_addr_gen_select;
            do_write        <= single_rw_do_write && (!worm_en || !captured_first_fail);
            do_read         <= single_rw_do_read && (!worm_en || !captured_first_fail);
         end

         BLOCK_RW:
         begin
            addr_gen_select <= block_rw_addr_gen_select;
            do_write        <= block_rw_do_write && (!worm_en || !captured_first_fail);
            do_read         <= block_rw_do_read && (!worm_en || !captured_first_fail);
         end

         BYTEENABLE_STAGE:
         begin
            addr_gen_select <= byteenable_stage_addr_gen_select;
            do_write        <= byteenable_stage_do_write && (!worm_en || !captured_first_fail);
            do_read         <= byteenable_stage_do_read && (!worm_en || !captured_first_fail);
         end
         
         TEMPLATE_STAGE:
         begin
            addr_gen_select <= template_stage_addr_gen_select;
            do_write        <= template_stage_do_write && (!worm_en || !captured_first_fail);
            do_read         <= template_stage_do_read && (!worm_en || !captured_first_fail);
         end
         
         REREAD_STAGE:
         begin
            addr_gen_select <= addr_gen_select.first();  
            do_write        <= 1'b0;
            do_read         <= can_read;
         end

         default:
         begin
            addr_gen_select <= addr_gen_select.first();
            do_write        <= 1'b0;
            do_read         <= 1'b0;
         end
      endcase
   end

   // Test stages state machine
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n) begin
         timeout_counter  <= '0;
         stage            <= (NUM_DRIVER_LOOP == -1) ? TEST_COMPLETE : INIT;
         loop_counter     <= '0;
      end
      else
      begin
         // Always increment timeout counter
         timeout_counter <= timeout_counter + 1'b1;
         
         if (NUM_DRIVER_LOOP > 0 && TIMEOUT_COUNTER_WIDTH > 0 && timeout_counter[TIMEOUT_COUNTER_WIDTH]) begin
            // All test stages fail to complete within 2**TIMEOUT_COUNTER_WIDTH+1 cycles
            stage <= TIMEOUT;
            
         end else if (read_compare_fifo_full) begin
            // The read compare FIFO should not fill up
            // Try increasing the FIFO size and test again
            stage <= TIMEOUT;
            
         end else begin
            case (stage)
               INIT:
               begin
                  // Start test immediately after reset_n is deasserted
                  timeout_counter <= '0;
                  stage <= SINGLE_RW;

                  // Increment the loop counter
                  loop_counter <= loop_counter + 1'b1;
               end

               SINGLE_RW:
                  // Perform single write/read test
                  if (single_rw_complete || (worm_en && captured_first_fail))
                     stage <= BLOCK_RW;

               BLOCK_RW:
                  // Perform block write/read test
                  if (block_rw_complete || (worm_en && captured_first_fail))
                     stage <= BYTEENABLE_STAGE;
                     
               BYTEENABLE_STAGE:
                  // Perform byteenable test
                  if (byteenable_stage_complete || (worm_en && captured_first_fail))
                     stage <= TEMPLATE_STAGE;                     

               TEMPLATE_STAGE:
               begin
                  // Template stage
                  if (worm_en && captured_first_fail) begin
                     stage <= REREAD_STAGE;
                  end else if (template_stage_complete) begin
                     stage <= DONE;
                  end
               end
               
               REREAD_STAGE:
                  // Re-read from data mismatch address
                  // This must be done at the very end.
                  if (can_read)
                     stage <= TEST_COMPLETE;
                  
               DONE:
               begin
                  if (NUM_DRIVER_LOOP == 0) begin
                     // A setting of 0 means loop forever
                     stage <= INIT;
                  end else if (loop_counter < NUM_DRIVER_LOOP) begin
                     // The loop limit has not yet been reached
                     stage <= INIT;
                  end else begin
                     // The loop limit has been reached. 
                     stage <= TEST_COMPLETE;
                  end
               end

               TEST_COMPLETE:
               begin
                  timeout_counter <= '0;
                  stage <= TEST_COMPLETE;
               end

               TIMEOUT:
               begin
                  timeout_counter <= '0;
                  stage <= TIMEOUT;
               end
            endcase
         end
      end
   end

   // TEST STAGE MODULE INSTANTIATIONS
   // These modules should comply with the following protocol:
   // - when 'reset_n' is deasserted, it should idle and listen to 'stage_enable'
   // - it should proceed with the test operations when 'stage_enable' is asserted
   // - when the test completes, it should assert either 'stage_complete' or 'stage_timeout'

   // Single write/read test stage
   altera_emif_avl_tg_single_rw_stage # (
      .SEQ_ADDR_COUNT                  (SINGLE_RW_SEQ_ADDR_COUNT),
      .RAND_ADDR_COUNT                 (SINGLE_RW_RAND_ADDR_COUNT),
      .RAND_SEQ_ADDR_COUNT             (SINGLE_RW_RAND_SEQ_ADDR_COUNT),
      .USE_BLOCKING_ADDRESS_GENERATION (USE_BLOCKING_ADDRESS_GENERATION)
   ) single_rw_stage_inst (
      .clk                             (clk),
      .reset_n                         (reset_n),
      .can_write                       (can_write),
      .can_read                        (can_read),
      .read_compare_fifo_empty         (read_compare_fifo_empty),
      .addr_gen_select                 (single_rw_addr_gen_select),
      .do_write                        (single_rw_do_write),
      .do_read                         (single_rw_do_read),
      .stage_enable                    ((stage == SINGLE_RW)),
      .stage_complete                  (single_rw_complete)
   );

   // Block write/read test stage
   altera_emif_avl_tg_block_rw_stage # (
      .SEQ_ADDR_COUNT                  (BLOCK_RW_SEQ_ADDR_COUNT),
      .RAND_ADDR_COUNT                 (BLOCK_RW_RAND_ADDR_COUNT),
      .RAND_SEQ_ADDR_COUNT             (BLOCK_RW_RAND_SEQ_ADDR_COUNT),
      .BLOCK_SIZE                      (BLOCK_RW_BLOCK_SIZE),
      .USE_BLOCKING_ADDRESS_GENERATION (USE_BLOCKING_ADDRESS_GENERATION)
   ) block_rw_stage_inst (
      .clk                             (clk),
      .reset_n                         (reset_n),
      .can_write                       (can_write),
      .can_read                        (can_read),
      .read_compare_fifo_empty         (read_compare_fifo_empty),
      .addr_gen_select                 (block_rw_addr_gen_select),
      .do_write                        (block_rw_do_write),
      .do_read                         (block_rw_do_read),
      .stage_enable                    ((stage == BLOCK_RW)),
      .stage_complete                  (block_rw_complete)
   );
   
   // Byteenable test stage
   altera_emif_avl_tg_byteenable_stage # (
      .RAND_ADDR_COUNT                 (BYTEENABLE_STAGE_RAND_ADDR_COUNT),
      .USE_BLOCKING_ADDRESS_GENERATION (USE_BLOCKING_ADDRESS_GENERATION)
   ) byteenable_stage_inst (
      .clk                             (clk),
      .reset_n                         (reset_n),
      .can_write                       (can_write),
      .can_read                        (can_read),
      .read_compare_fifo_empty         (read_compare_fifo_empty),
      .fifo_w_empty                    (fifo_w_empty),
      .addr_gen_select                 (byteenable_stage_addr_gen_select),
      .do_inv_be_write                 (do_inv_be_write),
      .do_write                        (byteenable_stage_do_write),
      .do_read                         (byteenable_stage_do_read),
      .stage_enable                    ((stage == BYTEENABLE_STAGE)),
      .stage_complete                  (byteenable_stage_complete)
   );   

   // Test stage template
   altera_emif_avl_tg_template_stage # (
      .NUM_TESTS                       (TEMPLATE_STAGE_COUNT)
   ) template_stage_inst (
      .clk                             (clk),
      .reset_n                         (reset_n),
      .can_write                       (can_write),
      .can_read                        (can_read),
      .read_compare_fifo_empty         (read_compare_fifo_empty),
      .addr_gen_select                 (template_stage_addr_gen_select),
      .do_write                        (template_stage_do_write),
      .do_read                         (template_stage_do_read),
      .stage_enable                    ((stage == TEMPLATE_STAGE)),
      .stage_complete                  (template_stage_complete)
   );

   // Simulation assertions
   always_ff @(posedge clk)
   begin
      if (reset_n) begin
         if (!can_write)
            assert (!do_write) else $error ("Write command cannot be issued");
         if (!can_read)
            assert (!do_read) else $error ("Read command cannot be issued");
      end
   end
endmodule

