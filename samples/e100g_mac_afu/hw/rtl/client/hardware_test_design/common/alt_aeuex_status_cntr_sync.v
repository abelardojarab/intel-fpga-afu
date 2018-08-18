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


// Copyright 2010 Altera Corporation. All rights reserved.  
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

`timescale 1 ps / 1 ps
// baeckler - 01-20-2010
// gray code crossing to improve usability of status counters 
// not intended for serious hardening

module alt_aeuex_status_cntr_sync #(
	parameter WIDTH = 32
)(
	input clk_in,
	input [WIDTH-1:0] din,
	input clk_out,
	input pause,
	output reg [WIDTH-1:0] dout
);

// Convert to Gray

reg [WIDTH-1:0] din_gray = 0 /* synthesis preserve_syn_only */;
always @(posedge clk_in) begin
	din_gray <= din ^ (din >> 1);
end

// Cross

(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name SDC_STATEMENT \"set_false_path -to [get_keepers *alt_aeuex_status_cntr_sync*sync_0\[*\]]\" "}*) 
reg [WIDTH-1:0] sync_0 = 0 /* synthesis preserve_syn_only */;
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS"}*) 
reg [WIDTH-1:0] sync_1 = 0 /* synthesis preserve_syn_only */;

always @(posedge clk_out) begin
	sync_0 <= din_gray;
	sync_1 <= sync_0;
end

// Convert back
wire [WIDTH-1:0] dout_gray = sync_1;
wire [WIDTH-1:0] dout_w;
assign dout_w[WIDTH-1] = dout_gray[WIDTH-1];

genvar i;
generate
for (i=WIDTH-2; i>=0; i=i-1)
  begin: gry_to_bin
    assign dout_w[i] = dout_w[i+1] ^ dout_gray[i];
  end
endgenerate

// register
initial dout = 0;
always @(posedge clk_out) if (!pause) dout <= dout_w;

endmodule
