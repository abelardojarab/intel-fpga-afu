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


// ____________________________________________________________________
// Copyright(C) 2013: Altera Corporation
// $Id: //acds/main/ip/ethernet/alt_eth_ultra/40g/rtl/efc/top/alt_aeu_40_pipe_line.v#1 $
// $Revision: #1 $
// $Date: 2013/10/22 $
// $Author: adubey $
// ____________________________________________________________________

 module alt_aeu_40_sfc_pipe_line 
     #( 
       parameter WORDS = 8  
      ,parameter EMPTYBITS = 6 
      ,parameter PDEPTH = 2 
      ,parameter ODEPTH = 2  // stages made available as output < PDEPTH
      ,parameter WIDTH = 1+1+1+EMPTYBITS+64*WORDS // valid+sop+eop+empty+data
      )(
       input wire clk 
      ,input wire rst_n 

 //   input interface signals
      ,output wire in_ready
      ,input wire [WIDTH-1:0] in_data

 //   output interface signals
      ,input wire out_ready
      ,output wire [WIDTH-1:0] out_data

 //   first two-three stage signals are mostly
 //   needed to run datapath state machines 
      ,output wire [ODEPTH*WIDTH-1:0] pipe_data
     );

 // ____________________________________________________________________
 //	[ pdata[i-1]]=>[ pdata[i]]=>[ pdata[i+1]]
 // ____________________________________________________________________
 //

  reg[PDEPTH-1:0] pready;
  wire[WIDTH-1:0] pdata_0, pdata_1, pdata_2;

  always@(posedge clk) begin pready <= {pready[PDEPTH-2:0], out_ready}; end // warning fix
  assign pdata_0 = in_data;
  assign out_data = pdata_2; //[2*WIDTH-1:WIDTH];
  assign pipe_data = {pdata_2,pdata_1}; // pdata[ODEPTH*WIDTH-1:WIDTH]; 

  alt_aeu_40_sfc_tx_dpipe #(.WIDTH(WIDTH)) dpipe_0 (.clk(clk), .in_ready(), .in_data(pdata_0),.out_ready(out_ready), .out_data(pdata_1));
  alt_aeu_40_sfc_tx_dpipe #(.WIDTH(WIDTH)) dpipe_1 (.clk(clk), .in_ready(), .in_data(pdata_1),.out_ready(out_ready), .out_data(pdata_2));

  assign in_ready = out_ready; 

 endmodule


