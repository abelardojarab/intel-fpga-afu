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



///////////////////////////////////////////////////////////////////////////////
// Top-level of the Avalon-MM 1x bridge.
//
// The purpose is to decouple an Avalon-MM master and an Avalon-MM slave in the
// same clock domain using a shallow FIFO. The requirements are:
//
// 1) No effiency loss (i.e. at steady state, the only reason the bridge
//    needs to stall the external Avalon-MM master is backpressure from
//    the external Avalon-MM slave)
// 2) Minimal latency penalty through the bridge.
// 3) No direct path between external slave and external master
// 4) Minimal area footprint.
// 5) Avalon-MM compliant.
//
// The 1x bridge is implemented as a 2-deep FIFO, the input of which is
// connected to an external AMM master. An Avalon command (read or write)
// results in one item in the FIFO. When the external AMM slave is ready to
// accept command, one item is read out of the FIFO. The output of the FIFO
// goes to a pipeline register stage before reaching the external AMM slave.
// The pipeline register stage is what decouples master and slave.
//
// A 2-deep FIFO is the minimum FIFO depth to ensure no efficiency loss
// without needing to send backpressure signal from the slave into
// the master.
//
///////////////////////////////////////////////////////////////////////////////

// Use FFs to implement FIFO. Turn off RAM inference.
(* altera_attribute = "-name AUTO_RAM_RECOGNITION OFF" *)

module altera_emif_avl_tg_amm_1x_bridge # (

   parameter AMM_WDATA_WIDTH                   = 1,
   parameter AMM_SYMBOL_ADDRESS_WIDTH          = 1,
   parameter AMM_BCOUNT_WIDTH                  = 1,
   parameter AMM_BYTEEN_WIDTH                  = 1

) (
   // User reset
   input  logic                                               reset_n,

   // User clock
   input  logic                                               clk,

   // Ports for slave Avalon port
   output logic                                               amm_slave_write,
   output logic                                               amm_slave_read,
   input  logic                                               amm_slave_ready,
   output logic [AMM_SYMBOL_ADDRESS_WIDTH-1:0]                amm_slave_address,
   output logic [AMM_WDATA_WIDTH-1:0]                         amm_slave_writedata,
   output logic [AMM_BCOUNT_WIDTH-1:0]                        amm_slave_burstcount,
   output logic [AMM_BYTEEN_WIDTH-1:0]                        amm_slave_byteenable,

   // Ports for master Avalon port
   input  logic                                               amm_master_write,
   input  logic                                               amm_master_read,
   output logic                                               amm_master_ready,
   input  logic [AMM_SYMBOL_ADDRESS_WIDTH-1:0]                amm_master_address,
   input  logic [AMM_WDATA_WIDTH-1:0]                         amm_master_writedata,
   input  logic [AMM_BCOUNT_WIDTH-1:0]                        amm_master_burstcount,
   input  logic [AMM_BYTEEN_WIDTH-1:0]                        amm_master_byteenable
);
   timeunit 1ns;
   timeprecision 1ps;

   localparam FIFO_DEPTH     = 2;
   localparam FIFO_PTR_WIDTH = 2;

   (* altera_attribute = {"-name MAX_FANOUT 5"}*) logic [FIFO_PTR_WIDTH-1:0] fifo_wptr;
   (* altera_attribute = {"-name MAX_FANOUT 5"}*) logic [FIFO_PTR_WIDTH-1:0] fifo_rptr;

   logic [FIFO_PTR_WIDTH-2:0] fifo_wptr_real;
   logic [FIFO_PTR_WIDTH-2:0] fifo_rptr_real;

   logic                      fifo_empty;
   logic                      fifo_full;

   logic                      can_accept_cmd;
   logic                      accepting_cmd;

   // FIFO is empty when write pointer is same as read pointer.
   // FIFO is full when the MSB's of the write pointer is different from that
   // of the read pointer, and the remaining bits are the same between read
   // and write pointer - a condition which signals the write pointer has wrapped
   // around the entire address space exactly once more than the read pointer.
   assign fifo_empty = fifo_wptr == fifo_rptr;
   assign fifo_full  = fifo_wptr[FIFO_PTR_WIDTH-1] != fifo_rptr[FIFO_PTR_WIDTH-1] && fifo_wptr[FIFO_PTR_WIDTH-2:0] == fifo_rptr[FIFO_PTR_WIDTH-2:0];

   // The actual pointers that can be used to index into the FIFO, without
   // the extra bits for detecting full/empty condition.
   assign fifo_wptr_real = fifo_wptr[FIFO_PTR_WIDTH-2:0];
   assign fifo_rptr_real = fifo_rptr[FIFO_PTR_WIDTH-2:0];

   // Pipeline the reset_n signal for amm_master_ready generation.
   // Don't use reset_n directly because if reset_n is promoted to global,
   // the insertion delay is big enough to cause downstream logic to fail setup timing.
   logic fifo_out_of_reset;
   always_ff @(posedge clk, negedge reset_n)
   begin
      if (!reset_n) begin
         fifo_out_of_reset <= 1'b0;
      end else begin
         fifo_out_of_reset <= 1'b1;
      end
   end

   // Bridge is ready to accept new item from the AMM master whenever FIFO
   // isn't full and we're not under reset
   assign amm_master_ready = !fifo_full && fifo_out_of_reset;

   // When can_accept_cmd is 1, that means we can accept a command from the master.
   assign can_accept_cmd = !fifo_full;

   // The following signals whether or not on the upcoming rising clock edge,
   // we're accepting an incoming Avalon command from the AMM master
   assign accepting_cmd = (amm_master_read || amm_master_write) && can_accept_cmd;

   // Advance FIFO write pointer whenever we're accepting an Avalon command from master
   always_ff @(posedge clk, negedge reset_n)
   begin
      if (!reset_n) begin
         fifo_wptr <= 1'b0;
      end else begin
         if (accepting_cmd)
            fifo_wptr <= fifo_wptr + 1'b1;
      end
   end

   // 2-deep FIFO
   //
   // An Avalon command results in one item in the FIFO.
   //
   // We overwrite the FIFO whenever it is ready to accept data.
   // There's no need to check whether the written data is garbage
   // or not since FIFO's readiness guarantees that what we're
   // overwriting must not be valulable. Also, as long as we don't
   // change fifo_wptr we're not really writing anyway. This approach
   // avoids unnecessarily coupling amm_master_write and amm_master_read
   // to every data bit of the FIFO.
   // Another optimization is that there's no need to reset FIFO contents.
   logic                                 fifo_write      [0:FIFO_DEPTH-1];
   logic                                 fifo_read       [0:FIFO_DEPTH-1];
   logic [AMM_SYMBOL_ADDRESS_WIDTH-1:0]  fifo_address    [0:FIFO_DEPTH-1];
   logic [AMM_WDATA_WIDTH-1:0]           fifo_writedata  [0:FIFO_DEPTH-1];
   logic [AMM_BCOUNT_WIDTH-1:0]          fifo_burstcount [0:FIFO_DEPTH-1];
   logic [AMM_BYTEEN_WIDTH-1:0]          fifo_byteenable [0:FIFO_DEPTH-1];

   always_ff @(posedge clk)
   begin
      if (can_accept_cmd) begin
         fifo_write      [fifo_wptr_real] <= amm_master_write;
         fifo_read       [fifo_wptr_real] <= amm_master_read;
         fifo_address    [fifo_wptr_real] <= amm_master_address;
         fifo_writedata  [fifo_wptr_real] <= amm_master_writedata;
         fifo_burstcount [fifo_wptr_real] <= amm_master_burstcount;
         fifo_byteenable [fifo_wptr_real] <= amm_master_byteenable;
      end
   end

   // Send FIFO output (in 2x clock domain) into register stage
   // whenever the external AMM slave is ready to accept new command
   // or when we don't already have a command posted.
   (* altera_attribute = {"-name MAX_FANOUT 1"}*) logic amm_slave_active_cmd;
   logic can_output_new_cmd;

   assign can_output_new_cmd = amm_slave_ready || !amm_slave_active_cmd;

   // Since we don't clear the FIFO during a read, nor do we reset FIFO
   // content during startup, when FIFO is empty we must ensure we don't
   // issue an old read/write requests.
   always_ff @(posedge clk, negedge reset_n)
   begin
      if (!reset_n) begin
         amm_slave_write      <= 1'b0;
         amm_slave_read       <= 1'b0;
         amm_slave_active_cmd <= 1'b0;
      end else begin
         if (can_output_new_cmd) begin
            if (fifo_empty) begin
               // No more command to push out
               amm_slave_write      <= 1'b0;
               amm_slave_read       <= 1'b0;
               amm_slave_active_cmd <= 1'b0;
            end else begin
               // Push out next command
               amm_slave_write      <= fifo_write[fifo_rptr_real];
               amm_slave_read       <= fifo_read [fifo_rptr_real];
               amm_slave_active_cmd <= fifo_write[fifo_rptr_real] || fifo_read [fifo_rptr_real];
            end
         end
      end
   end

   // The following are not control signals, so even garbage is ok.
   // The only requirement is that they must be kept unchanged when
   // the register stage isn't writable.
   always_ff @(posedge clk)
   begin
      if (can_output_new_cmd) begin
         amm_slave_address    <= fifo_address    [fifo_rptr_real];
         amm_slave_burstcount <= fifo_burstcount [fifo_rptr_real];
         amm_slave_writedata  <= fifo_writedata  [fifo_rptr_real];
         amm_slave_byteenable <= fifo_byteenable [fifo_rptr_real];
      end
   end

   // Advance FIFO read pointer whenever FIFO isn't empty and
   // an item has been read into the register stage
   always_ff @(posedge clk, negedge reset_n)
   begin
      if (!reset_n) begin
         fifo_rptr <= 1'b0;
      end else begin
         if (!fifo_empty && can_output_new_cmd)
            fifo_rptr <= fifo_rptr + 1'b1;
      end
   end

endmodule
