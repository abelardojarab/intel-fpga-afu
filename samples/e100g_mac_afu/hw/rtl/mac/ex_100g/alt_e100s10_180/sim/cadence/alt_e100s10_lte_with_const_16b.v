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


`timescale 1ns / 1ns
module alt_e100s10_lte_with_const_16b #(
    parameter CONST_VAL = 1000
) (
    input           clk,
    input  [15:0]   din,
    output          lte
);

    localparam NEG_VAL = -(CONST_VAL + 1);

    wire gt;
    alt_e100s10_pipeline_adder_16b pla (
        .clk    (clk),
        .a      (NEG_VAL[15:0]),
        .b      (din),
        .cin    (1'b0),
        .sum    (),
        .cout   (gt)
    );

    assign lte = ~gt;
endmodule
