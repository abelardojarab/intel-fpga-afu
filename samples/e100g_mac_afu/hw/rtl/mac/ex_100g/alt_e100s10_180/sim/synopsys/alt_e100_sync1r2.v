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
// Register based synchronizer of width 1.
// Generated by one of Gregg's toys.   Share And Enjoy.
// Copy from alt_e2550/hsx/ directory. It is for fec's csr use.

module alt_e100_sync1r2 #(
    parameter SIM_EMULATE = 1'b0
) (
    input din_clk,
    input [0:0] din,
    input dout_clk,
    output [0:0] dout
);

// set of handy SDC constraints
localparam MULTI_2 = "-name SDC_STATEMENT \"set_multicycle_path -to [get_keepers *alt_e100_sync1r2*ff_meta\[*\]] 2\" ";
localparam MULTI_3 = "-name SDC_STATEMENT \"set_multicycle_path -to [get_keepers *alt_e100_sync1r2*ff_meta\[*\]] 3\" ";
localparam FPATH = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *alt_e100_sync1r2*ff_meta\[*\]]\" ";
localparam FHOLD = "-name SDC_STATEMENT \"set_false_path -hold -to [get_keepers *alt_e100_sync1r2*ff_meta\[*\]]\" ";

reg [0:0] ff_launch = 1'b0 /* synthesis preserve_syn_only dont_replicate */;
always @(posedge din_clk) begin
	ff_launch <= din;
end

localparam SDC = {MULTI_2,";",FHOLD};
(* altera_attribute = SDC *)
reg [0:0] ff_meta = 1'b0 /* synthesis preserve_syn_only dont_replicate */;
always @(posedge dout_clk) begin
	ff_meta <= ff_launch;
end

reg [0:0] ff_sync = 1'b0 /* synthesis preserve_syn_only dont_replicate */;
always @(posedge dout_clk) begin
	ff_sync <= ff_meta;
end

assign dout = ff_sync;
endmodule

