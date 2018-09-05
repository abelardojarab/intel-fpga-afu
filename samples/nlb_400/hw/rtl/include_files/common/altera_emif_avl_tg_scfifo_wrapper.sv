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
// This module is a wrapper for the scfifo.  Some scfifo parameters are
// derived here.
//////////////////////////////////////////////////////////////////////////////

module altera_emif_avl_tg_scfifo_wrapper # (
   parameter DEVICE_FAMILY       = "",
   parameter FIFO_WIDTH          = "",
   parameter FIFO_SIZE           = "",
   parameter SHOW_AHEAD          = "",
   parameter USE_EAB             = "ON",
   parameter ENABLE_PIPELINE     = 1
) (
   // Clock and reset
   input  logic                       clk,
   input  logic                       reset_n,

   // Controls
   input  logic                       write_req,
   input  logic                       read_req,

   // Data
   input  logic [FIFO_WIDTH-1:0]      data_in,
   output logic [FIFO_WIDTH-1:0]      data_out,

   // Status
   output logic                       full,
   output logic                       empty
);
   timeunit 1ns;
   timeprecision 1ps;
   
   import avl_tg_defs::*;

   // FIFO address width
   localparam FIFO_WIDTHU = ceil_log2(FIFO_SIZE);

   // Actual FIFO size
   localparam FIFO_NUMWORDS = 2 ** FIFO_WIDTHU;

   logic [FIFO_WIDTH-1:0]    data_in_logic;
   logic                     write_req_logic;
   logic                     almost_full;
   logic                     total_full;

   generate
      if (ENABLE_PIPELINE == 1) begin
         logic [FIFO_WIDTH-1:0]   data_in_reg;
         logic                    write_req_reg;
         
         always_ff @ (posedge clk) begin
            if (~reset_n) begin
               write_req_reg <= 1'b0;
            end else begin
               write_req_reg <= write_req;
            end
         end
         
         always_ff @ (posedge clk) begin
            data_in_reg <= data_in;
         end         
         
         assign write_req_logic = write_req_reg;
         assign data_in_logic = data_in_reg;
         assign full = almost_full;
         
      end else begin
         assign write_req_logic = write_req;
         assign data_in_logic = data_in;
         assign full = total_full;
      end

      if (FIFO_SIZE > 0) begin
         scfifo # (
            .intended_device_family   (DEVICE_FAMILY),
            .lpm_width                (FIFO_WIDTH),
            .lpm_widthu               (FIFO_WIDTHU),
            .lpm_numwords             (FIFO_NUMWORDS),
            .lpm_showahead            (SHOW_AHEAD),
            .almost_full_value        (FIFO_NUMWORDS > 2 ? FIFO_NUMWORDS-2 : 1), 
            .use_eab                  (USE_EAB),
            .overflow_checking        ("OFF"),
            .underflow_checking       ("OFF")
         ) scfifo_inst (
            .rdreq                    (read_req),
            .aclr                     (1'b0),
            .clock                    (clk),
            .wrreq                    (write_req_logic),
            .data                     (data_in_logic),
            .full                     (total_full),
            .q                        (data_out),
            .sclr                     (!reset_n),
            .usedw                    (),
            .empty                    (empty),
            .almost_full              (almost_full),
            .almost_empty             ()
         );
           
      end else begin
         assign total_full  = 1'b0;
         assign data_out    = '0;
         assign empty       = 1'b1;
         assign almost_full = 1'b0;
      end
   endgenerate
endmodule
