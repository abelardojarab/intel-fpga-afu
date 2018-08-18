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
// 2:1 MUX of 1 bit words.  Latency 0.
// Generated by one of Gregg's toys.   Share And Enjoy.

module alt_e100s10_mux2w1t0s0 #(
    parameter SIM_EMULATE = 1'b0
) (
    input [1:0] din,
    input sel,
    output dout
);

generate
if (SIM_EMULATE) begin
    assign dout = sel ? din[1] : din[0];

end else begin
    alt_e100s10_lut6 lt0 (.din({1'b0,sel,2'b0,din}),.dout(dout));
    defparam lt0 .SIM_EMULATE = SIM_EMULATE;
    defparam lt0 .MASK = 64'hff00f0f0ccccaaaa;

end
endgenerate
endmodule

