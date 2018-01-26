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


// $Id: //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/pcs/eth_sane_block_encode.v#3 $
// $Revision: #3 $
// $Date: 2013/07/11 $
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
// baeckler - 06-21-2012

// 64->66 encoder operating on the assumption that the provided
// MII traffic is LEGAL.   No promises when that isn't the case.

module alt_aeu_40_sane_block_encode #(
	parameter TARGET_CHIP = 2,
	parameter MLAB_DELAY = 1'b0
)(
	input clk, 
	input [7:0] mii_txc,
	input [63:0] mii_txd, // bit 0 first
	output [65:0] encoded,
        output        tx_mii_start
);

localparam MII_IDLE = 8'h7,            // I
        MII_START = 8'hfb,            // S
        MII_TERMINATE = 8'hfd,        // T
        MII_ERROR = 8'hfe,            // E
        MII_SEQ_ORDERED = 8'h9c,    // Q aka O
        MII_SIG_ORDERED = 8'h5c;    // Fsig aka O
        
localparam BLK_CTRL = 8'h1e,
            BLK_START = 8'h78,
            BLK_OS_A = 8'h4b,    // for Q
            BLK_OS_B = 8'h55,    // for Fsig
            BLK_TERM0 = 8'h87,
            BLK_TERM1 = 8'h99,
            BLK_TERM2 = 8'haa,
            BLK_TERM3 = 8'hb4,
            BLK_TERM4 = 8'hcc,
            BLK_TERM5 = 8'hd2,
            BLK_TERM6 = 8'he1,
            BLK_TERM7 = 8'hff;
            
localparam EBLOCK_T = {{8{7'h1e}},BLK_CTRL,2'b01};
localparam IBLOCK_T = {{8{7'h00}},BLK_CTRL,2'b01};

///////////////////////////////////////////////////
// comparators on the MII input bytes

wire m_start;
eq_10_const eq0 (
	.clk(clk),
	.din({1'b0,mii_txc[0],mii_txd[7:0]}),
	.match(m_start)
);
defparam eq0 .VAL = {1'b0,1'b1,MII_START};
defparam eq0 .TARGET_CHIP = TARGET_CHIP;

wire [7:0] m_term;
genvar i;
generate 
	for (i=0; i<8; i=i+1) begin : t
		eq_10_const eqt (
			.clk(clk),
			.din({1'b0,mii_txc[i],mii_txd[8*(i+1)-1:8*i]}),
			.match(m_term[i]));
		defparam eqt .VAL = {1'b0,1'b1,MII_TERMINATE};
		defparam eqt .TARGET_CHIP = TARGET_CHIP;
	end
endgenerate

wire m_err;
eq_10_const eqe (
	.clk(clk),
	.din({1'b0,mii_txc[7],mii_txd[63:56]}),
	.match(m_err));
defparam eqe .VAL = {1'b0,1'b1,MII_ERROR};
defparam eqe .TARGET_CHIP = TARGET_CHIP;


wire m_any_control;
or_r o (
	.clk(clk),
	.din(mii_txc),
	.dout(m_any_control)
);
defparam o .WIDTH = 8;

wire m_all_control;
and_r a (
	.clk(clk),
	.din(mii_txc),
	.dout(m_all_control)
);
defparam a .WIDTH = 8;

wire m_seq;
eq_10_const eqs (
	.clk(clk),
	.din({1'b0,mii_txc[0],mii_txd[7:0]}),
	.match(m_seq)
);
defparam eqs .VAL = {1'b0,1'b1,MII_SEQ_ORDERED};
defparam eqs .TARGET_CHIP = TARGET_CHIP;

///////////////////////////////////////////////////
// figure out what you want to show

reg [3:0] block_sel = 4'b0;
always @(posedge clk) begin
	block_sel[0] <= (m_term[1] || m_term[3] || m_term[5] || m_term[7] || !m_any_control || m_err);
	block_sel[1] <= (m_term[2] || m_term[3] || m_term[6] || m_term[7] || m_start || m_err);
	block_sel[2] <= (m_term[4] || m_term[5] || m_term[6] || m_term[7] || m_seq || m_err);
	block_sel[3] <=	!m_term[0] && (!m_any_control || m_start || m_all_control || m_seq || m_err);
end

///////////////////////////////////////////////////
// match up latency

wire [63:0] raw_data;

generate 
	if (MLAB_DELAY) begin
		delay_mlab dm0 (
			.clk(clk),
			.din(mii_txd),
			.dout(raw_data)
		);
		defparam dm0 .WIDTH = 64;
		defparam dm0 .LATENCY = 3;
		defparam dm0 .TARGET_CHIP = TARGET_CHIP;
	end
	else begin
		delay_regs dr0 (
			.clk(clk),
			.din(mii_txd),
			.dout(raw_data)
		);
		defparam dr0 .WIDTH = 64;
		defparam dr0 .LATENCY = 3;
	end
endgenerate
	
///////////////////////////////////////////////////
// output MUX

wire [55:0] packed_control = 56'h0; // idle is 0

reg [65:0] encoded_block = 66'b0 /* synthesis preserve */;
always @(posedge clk) begin
	case (block_sel)
		4'h0 : encoded_block <= {packed_control[55:7],7'b0,BLK_TERM0,2'b01};
		4'h1 : encoded_block <= {packed_control[55:14],6'b0,raw_data[7:0],BLK_TERM1,2'b01};
		4'h2 : encoded_block <= {packed_control[55:21],5'b0,raw_data[15:0],BLK_TERM2,2'b01};
		4'h3 : encoded_block <= {packed_control[55:28],4'b0,raw_data[23:0],BLK_TERM3,2'b01};
		4'h4 : encoded_block <= {packed_control[55:35],3'b0,raw_data[31:0],BLK_TERM4,2'b01};
		4'h5 : encoded_block <= {packed_control[55:42],2'b0,raw_data[39:0],BLK_TERM5,2'b01};
		4'h6 : encoded_block <= {packed_control[55:49],1'b0,raw_data[47:0],BLK_TERM6,2'b01};
		4'h7 : encoded_block <= {raw_data[55:0],BLK_TERM7,2'b01};
		4'h8 : encoded_block <= IBLOCK_T;
		4'h9 : encoded_block <= {raw_data,2'b10};
		4'ha : encoded_block <= {raw_data[63:8],BLK_START,2'b01};
		4'hb : encoded_block <= EBLOCK_T;
		4'hc : encoded_block <= {raw_data[63:8],(raw_data[7]?BLK_OS_A:BLK_OS_B),2'b01};
		4'hd : encoded_block <= EBLOCK_T;
		4'he : encoded_block <= EBLOCK_T;
		4'hf : encoded_block <= EBLOCK_T;								
	endcase		
end
assign encoded = encoded_block;

assign tx_mii_start = m_start;

endmodule 
// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  2.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 113
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 295
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.990 ns, From block_sel[1]~DUPLICATE, To encoded_block[52]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.830 ns, From delay_regs:dr0|storage[26], To delay_regs:dr0|storage[90]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.897 ns, From block_sel[3]~DUPLICATE, To encoded_block[39]}
