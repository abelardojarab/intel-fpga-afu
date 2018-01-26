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


// $Id: //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/pcs/eth_sane_block_decode.v#5 $
// $Revision: #5 $
// $Date: 2013/07/19 $
// $Author: jilee $
//-----------------------------------------------------------------------------
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
// baeckler - 07-13-2012
module alt_aeu_40_sane_block_decode #(
	parameter TARGET_CHIP = 2
)(
	input clk,
        input insert_lblock, 
	input [65:0] block, // bit 0 first
	output [7:0] mii_txc,
	output [63:0] mii_txd // bit 0 first	
);

localparam MII_IDLE = 8'h7,            // I
        MII_START = 8'hfb,            // S
        MII_TERMINATE = 8'hfd,        // T
        MII_ERROR = 8'hfe,            // E
        MII_SEQ_ORDERED = 8'h9c,    // Q aka O
        MII_SIG_ORDERED = 8'h5c;    // Fsig aka O

////////////////////////////////////////////////////

reg [7:0] mc = 8'h0;
reg [63:0] md = 64'h0;
reg [2:0] term_fix = 3'b0;
reg bad_block = 1'b0;

localparam LBLOCK_R =  {8'h1, 8'h0, 8'h0, 8'h0, 8'h0, 8'h1, 8'h0, 8'h0, 8'h9c},
           BLK_OS_A = 8'h4b,       // for Q
           BLK_OS_B = 8'h55;       // for Fsig
 
always @(posedge clk) begin
	term_fix <= 3'b111;
	if (!block[0]) begin
		// data block
		{mc,md} <= {8'h0,block[65:2]};
	end
	else if (!block[9]) begin
		if (block[7]) begin
			// start of packet
			{mc,md} <= {8'h1,block[65:10],MII_START};
		end
                //=========================================================
                // added for link fault feature
                //=========================================================
                else if ({block[9:2], block[1:0]}=={BLK_OS_A, 2'b01}) begin
                        // ordered set word
                        {mc,md} <= {8'h1, block[65:10], MII_SEQ_ORDERED};
                end
                else if ({block[9:2], block[1:0]}=={BLK_OS_B, 2'b01}) begin
                        // ordered set word
                        {mc,md} <= {8'h1, block[65:10], MII_SIG_ORDERED};
                end
                //=========================================================
                // added for rx_error feature
                //=========================================================
                else if ({block[16:10], block[9:2], block[1:0]}=={7'h1e, 8'h1e, 2'b01}) begin
                        // Error control word
                        {mc,md} <= {8'hff,{8{8'hFE}}};
                end
                //=========================================================
		else begin
			// control word or set - decode as idles
			{mc,md} <= {8'hff,{8{8'h07}}};		
		end
	end
	else begin
		// presumption of terminating in the last byte, may need to ammend
		{mc,md} <= {8'h80,MII_TERMINATE,block[65:10]};
		term_fix <= block[8:6];
	end
end

always @(posedge clk) begin
	bad_block <= ~^block[1:0];
end

////////////////////////////////////////////////////

reg [7:0] mc1 = 8'h0;
reg [63:0] md1 = 64'h0;

always @(posedge clk) begin
	{mc1,md1} <= {mc,md};
	
	if (term_fix == 3'h6) {mc1,md1} <= {8'hc0,MII_IDLE,MII_TERMINATE,md[47:0]};				
	else if (term_fix == 3'h5) {mc1,md1} <= {8'he0,{2{MII_IDLE}},MII_TERMINATE,md[39:0]};				
	else if (term_fix == 3'h4) {mc1,md1} <= {8'hf0,{3{MII_IDLE}},MII_TERMINATE,md[31:0]};				
	else if (term_fix == 3'h3) {mc1,md1} <= {8'hf8,{4{MII_IDLE}},MII_TERMINATE,md[23:0]};				
	else if (term_fix == 3'h2) {mc1,md1} <= {8'hfc,{5{MII_IDLE}},MII_TERMINATE,md[15:0]};				
	else if (term_fix == 3'h1) {mc1,md1} <= {8'hfe,{6{MII_IDLE}},MII_TERMINATE,md[7:0]};				
	else if (term_fix == 3'h0) {mc1,md1} <= {8'hff,{7{MII_IDLE}},MII_TERMINATE};				
	
	if (bad_block) {mc1,md1} <= {8'hff,{8{MII_ERROR}}};				
        if (insert_lblock) {mc1,md1} <= LBLOCK_R; // fault sequence block
end

assign mii_txc = mc1;
assign mii_txd = md1;

endmodule 


// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  2.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 137
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 143
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.193 ns, From term_fix[2], To md1[32]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.985 ns, From term_fix[1], To md1[35]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.044 ns, From term_fix[1], To md1[44]}
