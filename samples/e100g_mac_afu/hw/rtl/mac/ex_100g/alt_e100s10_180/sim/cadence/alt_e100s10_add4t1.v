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




`timescale 1ps/1ps

// DESCRIPTION
// 4 bit adder.  Latency 1.
// Generated by one of Gregg's toys.   Share And Enjoy.

module alt_e100s10_add4t1 #(
    parameter SIM_EMULATE = 1'b0
) (
    input clk,
    input [3:0] dina,
    input [3:0] dinb,
    output [3:0] dout
);

reg [3:0] dout_r = 4'b0;
always @(posedge clk) dout_r <= dina + dinb;
assign dout = dout_r;

endmodule

