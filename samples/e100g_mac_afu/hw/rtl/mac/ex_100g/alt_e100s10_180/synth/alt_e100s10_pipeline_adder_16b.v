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
module alt_e100s10_pipeline_adder_16b (
    input               clk,
    input  [15:0]       a,
    input  [15:0]       b,
    input               cin,
    output reg [15:0]   sum,
    output reg          cout
);

    wire [5:0] sum_s0;
    wire       cout_s0;
    alt_e100s10_adder #(
        .width(6)
    ) adder0 (
        .cin     (cin),
        .a       (a[5:0]),
        .b       (b[5:0]),
        .sum     (sum_s0),
        .cout    (cout_s0)
    );

    reg [5:0]  partial_sum_s1;
    reg        cin_s1;
    reg [15:6] remainder_a_s1;
    reg [15:6] remainder_b_s1;
    always @(posedge clk) begin
        partial_sum_s1 <= sum_s0;
        cin_s1         <= cout_s0;
        remainder_a_s1 <= a[15:6];
        remainder_b_s1 <= b[15:6];
    end

    // -------- Next stage ------------
    wire [10:0] sum_s1;
    wire        cout_s1;

    assign sum_s1[5:0] = partial_sum_s1;
    alt_e100s10_adder #(
        .width(5)
    ) adder1 (
        .cin     (cin_s1),
        .a       (remainder_a_s1[10:6]),
        .b       (remainder_b_s1[10:6]),
        .sum     (sum_s1[10:6]),
        .cout    (cout_s1)
    );

    reg [10:0]  partial_sum_s2;
    reg         cin_s2;
    reg [15:11] remainder_a_s2;
    reg [15:11] remainder_b_s2;
    always @(posedge clk) begin
        partial_sum_s2 <= sum_s1;
        cin_s2         <= cout_s1;
        remainder_a_s2 <= remainder_a_s1[15:11];
        remainder_b_s2 <= remainder_b_s1[15:11];
    end

    // -------- Next stage ------------
    wire [15:0] sum_s2;
    wire        cout_s2;

    assign sum_s2[10:0] = partial_sum_s2;
    alt_e100s10_adder #(
        .width(5)
    ) adder2 (
        .cin     (cin_s2),
        .a       (remainder_a_s2[15:11]),
        .b       (remainder_b_s2[15:11]),
        .sum     (sum_s2[15:11]),
        .cout    (cout_s2)
    );

    always @(posedge clk) begin
        sum <= sum_s2;
        cout <= cout_s2;
    end
endmodule
