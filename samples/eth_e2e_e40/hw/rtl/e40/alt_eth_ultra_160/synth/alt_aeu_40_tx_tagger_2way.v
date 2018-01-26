// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// Copyright 2012 Altera Corporation. All rights reserved.  
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
// baeckler - 06-07-2012

module alt_aeu_40_tx_tagger_2way #(
	parameter VLANE_SET = 1, // 0..1
	parameter TARGET_CHIP = 2
)(
	input clk,
	input sclr,
	input [65:0] din,
	input am_insert,  // discard the din, insert alignment
	output [65:0] dout
);

// this is cut and paste from the spec table, lanes 0..19
//  for obvious compatability
wire [64*4-1:0] marker_table_raw = {
    8'h90,8'h76,8'h47,8'h00,8'h6f,8'h89,8'hb8,8'h00,    // lane 0
    8'hf0,8'hc4,8'he6,8'h00,8'h0f,8'h3b,8'h19,8'h00,
    8'hc5,8'h65,8'h9b,8'h00,8'h3a,8'h9a,8'h64,8'h00,
    8'ha2,8'h79,8'h3d,8'h00,8'h5d,8'h86,8'hc2,8'h00
};

// Fix it up so lane 0, LSB, 1st to send is in
// position 0.
wire [64*4-1:0] marker_table;
genvar i;
generate
    for (i=0; i<8*4; i=i+1)
    begin : fix
        assign marker_table[(8*4-i)*8-1-:8] = marker_table_raw[(i*8)+7:i*8];
    end
endgenerate

// assemble the desired tags
wire [7:0] bip;
reg [7:0] last_bip = 8'h0;
wire [65:0] vlane_tag;
		
always @(posedge clk) last_bip <= bip;

wire [65:0] vlane_tag_const0 = {marker_table[(VLANE_SET+1)*64-1:VLANE_SET*64],2'b01};
wire [65:0] vlane_tag_const1 = {marker_table[(VLANE_SET+3)*64-1:(VLANE_SET+2)*64],2'b01};

reg cntr = 1'b0;
always @(posedge clk) begin
	if (sclr) cntr <= 1'b0;
	else cntr <= ~cntr;
end

// mux up all the constants, hopefully maps right  CHECK ME
reg [65:0] vlane_tag_const;
always @(*) begin
        vlane_tag_const = cntr ? vlane_tag_const1 : vlane_tag_const0;
end

assign vlane_tag = vlane_tag_const | {~last_bip,24'b0,last_bip,24'b0,2'b0};

////////////////////////////////

wire bx_restart;

alt_aeu_40_bip_xor_2way bx (
	.clk(clk),
	.restart(bx_restart),
	.phase(cntr),
	.din(din),
	.dout(bip)
);
defparam bx .TARGET_CHIP = TARGET_CHIP;

reg [65:0] din_r = 66'b0 /* synthesis preserve */;
reg [65:0] din_rr = 66'b0 /* synthesis preserve */;
reg [65:0] dout_r = 66'b0 /* synthesis preserve */;
reg am_insert_r = 1'b0 /* synthesis preserve */;
reg am_insert_rr = 1'b0 /* synthesis preserve */;

assign bx_restart = am_insert_r;

always @(posedge clk) begin
	din_r <= din;
	din_rr <= din_r;
	am_insert_r <= am_insert | sclr;
	am_insert_rr <= am_insert_r;
	dout_r <= am_insert_rr ? vlane_tag : din_rr; 
end
assign dout = dout_r;

endmodule
