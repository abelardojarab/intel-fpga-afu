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


// (C) 2001-2014 Altera Corporation. All rights reserved.
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

`timescale 1 ps / 1 ps
module alt_aeu_40_pfc_mspipe
     #(
      parameter WORDS = 4,
      parameter EMPTYBITS = 5,
      parameter PDEPTH = 2,
      parameter ODEPTH = 2,  // stages made available as output < PDEPTH
      parameter WIDTH = 1+1+1+EMPTYBITS+64*WORDS // valid+sop+eop+empty+data
      )(
      input clk,
      input rst_n,

 //   input interface signals
      output in_ready,
      input [WIDTH-1:0] in_data,

 //   output interface signals
      input out_ready,
      output [WIDTH-1:0] out_data,

 //   first two-three stage signals are mostly
 //   needed to run datapath state machines 
      output [ODEPTH*WIDTH-1:0] pipe_data
     );

 // ____________________________________________________________________
 //	[ pdata[i-1]]=>[ pdata[i]]=>[ pdata[i+1]]
 // ____________________________________________________________________
 //

  reg[PDEPTH-1:0] pready;
  wire[WIDTH-1:0] pdata_0, pdata_1, pdata_2;

  always@(posedge clk) begin 
    pready <= {pready[PDEPTH-2:0], out_ready}; 
  end // warning fix
  assign pdata_0 = in_data;
  assign out_data = pdata_2; //[2*WIDTH-1:WIDTH];
  assign pipe_data = {pdata_2,pdata_1}; // pdata[ODEPTH*WIDTH-1:WIDTH];

  alt_aeu_40_pfc_tx_dpipe #(
    .WIDTH(WIDTH)
  ) dpipe_0 (
    .clk(clk), 
    .in_ready(), 
    .in_data(pdata_0),
    .out_ready(out_ready), 
    .out_data(pdata_1));
  alt_aeu_40_pfc_tx_dpipe #(
    .WIDTH(WIDTH)
  ) dpipe_1 (
    .clk(clk), 
    .in_ready(), 
    .in_data(pdata_1),
    .out_ready(out_ready), 
    .out_data(pdata_2));

  assign in_ready = out_ready;

endmodule
