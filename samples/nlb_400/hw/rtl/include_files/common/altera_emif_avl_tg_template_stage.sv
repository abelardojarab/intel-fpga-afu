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
// This is an example test stage, which issues write and read commands with
// progressing number of cycles between commands.  This test is to target the
// burst adaptor of the memory controller.
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_template_stage # (
   // The total number of write tests
   parameter NUM_TESTS           = ""
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

   // The number of cycles to pause between writes
   localparam MAX_T_RC_CYCLES           = 10;
   localparam MAX_PAUSE_BETWEEN_WRITES  = 11;
   localparam MAX_NUM_PAUSE_CYCLES      = max(MAX_T_RC_CYCLES, MAX_PAUSE_BETWEEN_WRITES);

   // Counter widths
   localparam NUM_TEST_COUNTER_WIDTH   = log2(NUM_TESTS) + 1;
   localparam RW_PAUSE_COUNTER_WIDTH   = log2(MAX_NUM_PAUSE_CYCLES) + 1;

   // Write/read state machine
   enum int unsigned {
      INIT,
      DONE
   } state;

   always_ff @(posedge clk)
   begin
      if (!reset_n) begin
         state            <= INIT;
      end else begin
         case (state)
            INIT:
               // Standby until this stage is signaled to start
               if (stage_enable) begin
                  state <= DONE;
               end
               
            DONE:
            begin

            end
         endcase
      end
   end

   // Command outputs
   assign do_write = '0; 
   assign do_read = '0; 

   // Status outputs
   assign addr_gen_select = TEMPLATE_ADDR_GEN;
   assign stage_complete = (state == DONE);

endmodule

