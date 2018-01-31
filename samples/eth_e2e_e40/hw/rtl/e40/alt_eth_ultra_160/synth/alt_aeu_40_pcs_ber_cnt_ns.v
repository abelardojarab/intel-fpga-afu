// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: $
// $Revision: $
// $Date: $
// $Author: $
//-----------------------------------------------------------------------------

module alt_aeu_40_pcs_ber_cnt_ns
 #(
        parameter BLOCK_LEN = 66,
        parameter NUM_BLOCKS = 4
  )
  (
    input wire         clk,
    input wire [6:0]   ber_cnt_cs,
    input [BLOCK_LEN*NUM_BLOCKS-1:0] rx_blocks, // bit 0 first
    input wire [6:0]   rbit_error_total_cnt, 
    output reg [6:0]   ber_cnt_ns
   );

   //********************************************************************
   // Define variables 
   //********************************************************************
   genvar                                i;
   
   // Wires
   wire [NUM_BLOCKS-1:0] sh_err;

   //********************************************************************
   // check IDLE pattern for each block
   //********************************************************************

   generate

      for (i=0; i < NUM_BLOCKS; i=i+1) begin : BER_PERLANE
          assign sh_err[i] = !(rx_blocks[BLOCK_LEN*i] ^ rx_blocks[BLOCK_LEN*i+1]);
      end

   endgenerate

wire [2:0] cmp_w;
reg        sh_err_r;

//alt_e100_six_three_comp sc (.data({1'b0,~sh_valid[NUM_BLOCKS-1:0]}),.sum(cmp_w));
compressor_4to3 c43(.clk(clk), .din(sh_err[NUM_BLOCKS-1:0]), .sum(cmp_w));

always @(posedge clk) sh_err_r <= |sh_err;
   //********************************************************************
   // ber_cnt NS logic
   // 
   //********************************************************************
   always @(*) begin
      ber_cnt_ns = ber_cnt_cs;

      // Hault at error total
      //if  (!(&sh_valid) && (ber_cnt_cs < rbit_error_total_cnt)) begin
      //if  (!(&sh_valid) && (ber_cnt_cs[6:4] != 3'b111)) begin // for timing
      if  (sh_err_r && (ber_cnt_cs[6:4] != 3'b111)) begin // for timing
         ber_cnt_ns = ber_cnt_cs + cmp_w;
      end
   end

endmodule // alt_e40_pcs_ber_cnt_ns

