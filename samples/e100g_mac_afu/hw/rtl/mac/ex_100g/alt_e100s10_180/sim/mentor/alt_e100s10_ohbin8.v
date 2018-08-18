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
// Convert 8 onehot signals to a binary number for one location.
// Generated by one of Gregg's toys.   Share And Enjoy.

module alt_e100s10_ohbin8 #(
    parameter SIM_EMULATE = 1'b0
) (
	input clk, 
    input [7:0] din,
	output [2:0] dout
);

wire [3:0] din0 = {
    din[1],din[3],din[5],din[7]};

alt_e100s10_or4t1 c0 (
    .clk(clk),
    .din(din0),
    .dout(dout[0])
);
defparam c0 .SIM_EMULATE = SIM_EMULATE;

wire [3:0] din1 = {
    din[2],din[3],din[6],din[7]};

alt_e100s10_or4t1 c1 (
    .clk(clk),
    .din(din1),
    .dout(dout[1])
);
defparam c1 .SIM_EMULATE = SIM_EMULATE;

wire [3:0] din2 = {
    din[4],din[5],din[6],din[7]};

alt_e100s10_or4t1 c2 (
    .clk(clk),
    .din(din2),
    .dout(dout[2])
);
defparam c2 .SIM_EMULATE = SIM_EMULATE;

endmodule

