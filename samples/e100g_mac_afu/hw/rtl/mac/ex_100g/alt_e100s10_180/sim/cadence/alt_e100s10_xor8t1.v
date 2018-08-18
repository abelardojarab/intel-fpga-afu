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


// Copyright 2014 Altera Corporation. All rights reserved.
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////


`timescale 1ps/1ps

// DESCRIPTION
// 8 input XOR gate.  Latency 1.
// Generated by one of Gregg's toys.   Share And Enjoy.

module alt_e100s10_xor8t1 #(
    parameter SIM_EMULATE = 1'b0
) (
    input clk,
    input [7:0] din,
    output dout
);

wire [1:0] leaf;

alt_e100s10_xor4t1 c0 (
    .clk(clk),
    .din(din[3:0]),
    .dout(leaf[0])
);
defparam c0 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_xor4t1 c1 (
    .clk(clk),
    .din(din[7:4]),
    .dout(leaf[1])
);
defparam c1 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_xor2t0 c2 (
    .din(leaf),
    .dout(dout)
);
defparam c2 .SIM_EMULATE = SIM_EMULATE;

endmodule

