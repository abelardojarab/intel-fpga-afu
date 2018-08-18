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
module alt_e100s10_pulse_stretcher #(
    parameter CYCLES = 8
) (
    input  clk,
    input  pulse_in,
    output pulse_out
);

    reg [CYCLES-1:0] mem = 'd0;

    always @(posedge clk) begin
        if (pulse_in) begin
            mem <= {CYCLES{1'b1}};
        end else begin
            mem <= {mem[CYCLES-2:0], 1'b0};
        end
    end

    assign pulse_out = mem[CYCLES-1];
endmodule
