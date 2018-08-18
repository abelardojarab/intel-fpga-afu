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
// parameterized delay module
// Modified from Greg's library by Faisal

module alt_e100s10_delay #(
    parameter SIM_EMULATE = 1'b0,
    parameter WIDTH = 1,
    parameter LATENCY = 2   // minimum
) (
    input clk,
    input [WIDTH-1:0] din,
    output [WIDTH-1:0] dout
);


reg [WIDTH*LATENCY-1:0] storage = {(WIDTH*LATENCY){1'b0}} /* synthesis preserve_syn_only */;
always @(posedge clk) begin
	storage <= {storage [WIDTH*(LATENCY-1)-1:0],din};
end
assign dout = storage [WIDTH*LATENCY-1:WIDTH*(LATENCY-1)];
endmodule

