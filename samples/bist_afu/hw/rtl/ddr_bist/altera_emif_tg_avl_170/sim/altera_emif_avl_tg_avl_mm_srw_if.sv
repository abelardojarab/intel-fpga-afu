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
// This module translates the commands issued by the state machine into
// Avalon-MM signals.  The module assumes separate Avalon-MM ports for
// read and write (srw). This module is responsible for transmitting
// the entire burst of write data once the state machine issues a write
// command.  The Avalon signals are generated as per the Avalon-MM protocol.
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_avl_mm_srw_if # (
   parameter DEVICE_FAMILY              = "",
   parameter ADDR_WIDTH                 = "",
   parameter BURSTCOUNT_WIDTH           = "",
   parameter DATA_WIDTH                 = "",
   parameter BE_WIDTH                   = "",
   parameter BUFFER_SIZE                = "",
   parameter RANDOM_BYTE_ENABLE         = ""
) (
   // Clock and reset
   input  logic                         clk,
   input  logic                         reset_n,

   // Avalon master signals
   input  logic                         avl_ready,
   output logic                         avl_write_req,
   output logic                         avl_read_req,
   output logic [ADDR_WIDTH-1:0]        avl_addr,
   output logic [BURSTCOUNT_WIDTH-1:0]  avl_size,
   output logic [DATA_WIDTH-1:0]        avl_wdata,
   output logic [BE_WIDTH-1:0]          avl_be,
      
   // Avalon master signals for the write-only Avalon port
   input  logic                         avl_ready_w,
   output logic [ADDR_WIDTH-1:0]        avl_addr_w,
   output logic [BURSTCOUNT_WIDTH-1:0]  avl_size_w,

   // State machine commands
   input  logic                         do_inv_be_write,
   input  logic                         do_write,
   input  logic                         do_read,

   // Write address from the address generator
   input  logic [ADDR_WIDTH-1:0]        write_addr,
   input  logic [BURSTCOUNT_WIDTH-1:0]  write_burstcount,

   // Write data
   input  logic                         byteenable_stage,
   output logic                         wdata_gen_enable,
   output logic                         inv_be_gen_enable,
   input  logic [DATA_WIDTH-1:0]        wdata,
   input  logic [BE_WIDTH-1:0]          be,
   input  logic [BE_WIDTH-1:0]          inv_be,

   // Read address from the address/burstcount FIFO
   input  logic [ADDR_WIDTH-1:0]        read_addr,
   input  logic [BURSTCOUNT_WIDTH-1:0]  read_burstcount,

   // Avalon traffic generator status signals
   output logic                         ready_r,
   output logic                         ready_w,

   // Queue read comparison request
   output logic                         queue_read_compare_req,
   
   // Write command fifo status
   output logic                         fifo_w_full,
   output logic                         fifo_w_empty
);
   timeunit 1ns;
   timeprecision 1ps;

   import avl_tg_defs::*;

   // Avalon traffic generator state machine
   enum int unsigned {
      IDLE,
      WRITE_BURST,
      INV_WRITE_BURST
   } state;

   // logicister inputs
   logic                          do_inv_be_write_r;
   logic                          do_write_r;
   logic                          do_read_r;
   logic [ADDR_WIDTH-1:0]         write_addr_r;
   logic [BURSTCOUNT_WIDTH-1:0]   write_burstcount_r;
   logic [ADDR_WIDTH-1:0]         read_addr_r;
   logic [BURSTCOUNT_WIDTH-1:0]   read_burstcount_r;
   logic [ADDR_WIDTH-1:0]         last_write_addr_r;
   logic [BURSTCOUNT_WIDTH-1:0]   last_write_burstcount_r;

   // Counter for transmitting burst write data
   logic [BURSTCOUNT_WIDTH-1:0]   burst_counter;

   // Avalon traffic FIFO signals
   logic                          can_issue_avl_w_cmd;
   logic                          fifo_r_full;
   logic                          fifo_r_empty;
   logic                          can_issue_avl_r_cmd;

   logic                          fifo_write_req_in;
   logic                          fifo_read_req_in;
   logic [ADDR_WIDTH-1:0]         fifo_addr_in;
   logic [BURSTCOUNT_WIDTH-1:0]   fifo_size_in;
   logic                          fifo_use_inv_be_in;
   
   logic [ADDR_WIDTH-1:0]         fifo_addr_w_in;
   logic [BURSTCOUNT_WIDTH-1:0]   fifo_size_w_in;

   logic                          fifo_write_req_out;
   logic                          fifo_read_req_out;
   logic [ADDR_WIDTH-1:0]         fifo_addr_out;
   logic [BURSTCOUNT_WIDTH-1:0]   fifo_size_out;
   logic                          fifo_use_inv_be_out;
   logic [ADDR_WIDTH-1:0]         fifo_addr_w_out;
   logic [BURSTCOUNT_WIDTH-1:0]   fifo_size_w_out;

   assign can_issue_avl_w_cmd = avl_ready_w | ~avl_write_req;
   assign can_issue_avl_r_cmd = avl_ready | ~avl_read_req;

   // Buffer for Avalon write interface
   altera_emif_avl_tg_scfifo_wrapper # (
      .DEVICE_FAMILY   (DEVICE_FAMILY),
      .FIFO_WIDTH      (1 + 1 + ADDR_WIDTH + BURSTCOUNT_WIDTH),
      .FIFO_SIZE       (BUFFER_SIZE),
      .SHOW_AHEAD      ("ON"),
      .ENABLE_PIPELINE (0)
   ) avalon_traffic_fifo_w (
      .clk             (clk),
      .reset_n         (reset_n),
      .write_req       (fifo_write_req_in),
      .read_req        (can_issue_avl_w_cmd & ~fifo_w_empty),
      .data_in         ({fifo_write_req_in,fifo_use_inv_be_in,fifo_addr_w_in,fifo_size_w_in}),
      .data_out        ({fifo_write_req_out,fifo_use_inv_be_out,fifo_addr_w_out,fifo_size_w_out}),
      .full            (fifo_w_full),
      .empty           (fifo_w_empty)
   );

   // Avalon traffic generator state machine
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n)
      begin
         burst_counter <= '0;
         state <= IDLE;
      end
      else if (!fifo_w_full)
      begin
         case (state)
            IDLE:
               // A write request can be issued only in the IDLE state
               if (do_write_r || do_inv_be_write_r)
               begin
                  // Set the number of remaining beats in the burst counter
                  burst_counter <= write_burstcount_r - 1'b1;

                  // Transition to the WRITE_BURST/INV_WRITE_BURST state if the write burst is greater than 1
                  if (write_burstcount_r > 1)
                     state <= do_write_r ? WRITE_BURST : INV_WRITE_BURST;
               end

            WRITE_BURST, INV_WRITE_BURST:
            begin
               burst_counter <= burst_counter - 1'b1;

               // Transition to the IDLE state when the write burst is complete
               if (burst_counter == 1) state <= IDLE;
            end
         endcase
      end
   end


   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n)
      begin
         do_inv_be_write_r       <= 1'b0;
         do_write_r              <= 1'b0;
         do_read_r               <= 1'b0;
         write_addr_r            <= '0;
         write_burstcount_r      <= '0;
         read_addr_r             <= '0;
         read_burstcount_r       <= '0;
         last_write_addr_r       <= '0;
         last_write_burstcount_r <= '0;
      end
      else
      begin
         if (ready_w)
         begin
            do_inv_be_write_r       <= do_inv_be_write;
            do_write_r              <= do_write;
            write_addr_r            <= write_addr;
            write_burstcount_r      <= write_burstcount;
         end
         if (ready_r)
         begin
            do_read_r               <= do_read;
            read_addr_r             <= read_addr;
            read_burstcount_r       <= read_burstcount;
         end
         if (!fifo_w_full && state == IDLE && (do_write_r || do_inv_be_write_r))
         begin
            last_write_addr_r       <= write_addr_r;
            last_write_burstcount_r <= write_burstcount_r;
         end
      end
   end


   // Avalon traffic generator status and FIFO inputs for write interface
   always_comb
   begin
      ready_w                <= 1'b0;
      queue_read_compare_req <= 1'b0;

      // Default FIFO inputs
      fifo_write_req_in     <= 1'b0;
      fifo_use_inv_be_in    <= 1'b0;      
      
      // Keep addr and burstcount constant in a write burst
      fifo_addr_w_in        <= last_write_addr_r;
      fifo_size_w_in        <= last_write_burstcount_r;

      if (!fifo_w_full)
      begin
         case (state)
            IDLE:
            begin
               ready_w <= 1'b1;

               // A write request can be issued only in the IDLE state
               if (do_write_r || do_inv_be_write_r)
               begin
                  // Issue a write request and forward the
                  // address, burstcount and data to Avalon
                  queue_read_compare_req <= do_write_r;
                  fifo_use_inv_be_in     <= do_inv_be_write_r;                  
                  fifo_write_req_in      <= 1'b1;
                  fifo_addr_w_in         <= write_addr_r;
                  fifo_size_w_in         <= write_burstcount_r;
               end
            end

            WRITE_BURST, INV_WRITE_BURST:
            begin
               if (!do_write_r && !do_inv_be_write_r)
                  ready_w <= 1'b1;

               // All remaining data of a write burst is transmitted in this state
               queue_read_compare_req <= (state == WRITE_BURST);
               fifo_use_inv_be_in     <= (state == INV_WRITE_BURST);               
               fifo_write_req_in      <= 1'b1;
            end
         endcase
      end
      else
      begin
         if (!do_write_r && !do_inv_be_write_r)
            ready_w <= 1'b1;
      end
   end

   // Avalon write interface signals generation
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n) begin
         avl_write_req <= 1'b0;
         
      end else if (can_issue_avl_w_cmd) begin
         // Avalon signals can be toggled only when the interface is ready
         // (avl_ready_w is high) or idle (avl_write_req deasserted).
         // Otherwise, all Avalon signals should be held constant.
         if (fifo_w_empty) begin
            avl_write_req <= 1'b0;
         end else begin
            avl_write_req <= fifo_write_req_out;
         end
      end
   end

   // Address, size, wdata, be can all be don't care as they are set when 
   // a write is going to occur
   always_ff @(posedge clk)
   begin
      if (can_issue_avl_w_cmd) begin
         // Avalon signals can be toggled only when the interface is ready
         // (avl_ready_w is high) or idle (avl_write_req deasserted).
         // Otherwise, all Avalon signals should be held constant.
         avl_addr_w <= fifo_addr_w_out;
         avl_size_w <= fifo_size_w_out;
         avl_wdata  <= fifo_use_inv_be_out ? '0     : wdata;
         avl_be     <= fifo_use_inv_be_out ? inv_be : be;
      end
   end
   
   // Signal to request random wdata/be/inv_be generation
   always_comb
   begin
      wdata_gen_enable <= can_issue_avl_w_cmd && ~fifo_w_empty && fifo_write_req_out && ~fifo_use_inv_be_out;
      if (byteenable_stage) begin
         inv_be_gen_enable <= can_issue_avl_w_cmd && ~fifo_w_empty && fifo_use_inv_be_out;
      end else begin
         inv_be_gen_enable <= can_issue_avl_w_cmd && ~fifo_w_empty && fifo_write_req_out;
      end
   end
   
   // Buffer for Avalon read interface
   altera_emif_avl_tg_scfifo_wrapper # (
      .DEVICE_FAMILY  (DEVICE_FAMILY),
      .FIFO_WIDTH     (1 + ADDR_WIDTH + BURSTCOUNT_WIDTH),
      .FIFO_SIZE      (BUFFER_SIZE),
      .SHOW_AHEAD     ("ON")
   ) avalon_traffic_fifo_r (
      .clk            (clk),
      .reset_n        (reset_n),
      .write_req      (fifo_read_req_in),
      .read_req       (can_issue_avl_r_cmd & ~fifo_r_empty),
      .data_in        ({fifo_read_req_in,fifo_addr_in,fifo_size_in}),
      .data_out       ({fifo_read_req_out,fifo_addr_out,fifo_size_out}),
      .full           (fifo_r_full),
      .empty          (fifo_r_empty)
   );

   // Avalon traffic generator status and FIFO inputs for read interface
   always_comb
   begin
      ready_r            <= 1'b0;

      // Default Avalon output values
      fifo_read_req_in   <= 1'b0;
      
      // Keep addr and burstcount constant in a read burst
      fifo_addr_in       <= read_addr_r;
      fifo_size_in       <= read_burstcount_r;

      if (!fifo_r_full)
      begin
         ready_r <= 1'b1;

         if (do_read_r)
         begin
            // Issue a read request and forward the address and burstcount to Avalon
            fifo_read_req_in <= 1'b1;
         end
      end
      else
      begin
         if (!do_read_r)
            ready_r <= 1'b1;
      end
   end


   // Avalon read interface signals generation
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (!reset_n)
      begin
         avl_read_req   <= 1'b0;
         avl_addr       <= '0;
         avl_size       <= '0;
      end
      else if (can_issue_avl_r_cmd)
      begin
         // Avalon signals can be toggled only when the interface is ready
         // (avl_ready_r is high) or idle (avl_read_req deasserted).
         // Otherwise, all Avalon signals should be held constant.
         if (fifo_r_empty)
         begin
            avl_read_req   <= 1'b0;
         end
         else
         begin
            avl_read_req   <= fifo_read_req_out;
            avl_addr       <= fifo_addr_out;
            avl_size       <= fifo_size_out;
         end
      end
   end
endmodule

