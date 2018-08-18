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
// 5 bit val == const(log(MASK)) equality comparator.  Latency 1.

module alt_e100s10_eqc5hxxt1 #(
    parameter SIM_EMULATE = 1'b0,
    parameter MASK = 64'h0000000000000001
) (
    input clk,
    input [4:0] din,
    output dout
);

wire dout_w;

alt_e100s10_lut6 t0 (.din(6'h0 | din),.dout(dout_w));
defparam t0 .MASK = MASK;
defparam t0 .SIM_EMULATE = SIM_EMULATE;

reg dout_r0 = 1'b0;
always @(posedge clk) dout_r0 <= dout_w;

assign dout = dout_r0;
endmodule

