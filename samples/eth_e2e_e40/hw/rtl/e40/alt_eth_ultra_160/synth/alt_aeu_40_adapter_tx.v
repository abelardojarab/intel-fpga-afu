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



// ___________________________________________________________________________
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/ast/alt_aeu_40_adapter_tx.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
// ___________________________________________________________________________
//
// lanny - 12-05-2011 Adapter seperation

`timescale 1ps / 1ps

module alt_aeu_40_adapter_tx #(
    parameter DEVICE_FAMILY = "Stratix V" ,
    parameter TARGET_CHIP = 2
)(
    input  mac_tx_arst_sync_core,
    input  clk_txmac,    // MAC + PCS clock - at least 312.5Mhz

    input  [255:0] l4_tx_data,
    input  [4  :0] l4_tx_empty,
    input  l4_tx_startofpacket,
    input  l4_tx_endofpacket,
    input  l4_tx_error,
    output l4_tx_ready,
    input  l4_tx_valid,
    
    output [2*64-1:0] tx2l_d,        // 5 lane payload to send
    output [2   -1:0] tx2l_sop,      // 5 lane start position
    output [2   -1:0] tx2l_eop,      // 5 lane end position
    output [2-1:0] tx2l_error,
    output [2*3 -1:0] tx2l_eop_empty,   // 5 lane end position, any byte
	output reg [2 -1:0]   tx2l_idle,    
    input  tx2l_ack                 // payload is accepted
     
    
    );

//--- functions
function [255:0] alt_aeu_40_wide_little_endian2avalon_256;
input [255:0] a;

begin
    alt_aeu_40_wide_little_endian2avalon_256 
                         = {a[  7: 0],  a[ 15:  8], a[ 23: 16], a[ 31: 24],
                            a[ 39: 32], a[ 47: 40], a[ 55: 48], a[ 63: 56],
                            a[ 71: 64], a[ 79: 72], a[ 87: 80], a[ 95: 88],
                            a[103: 96], a[111:104], a[119:112], a[127:120],
                            a[135:128], a[143:136], a[151:144], a[159:152],
                            a[167:160], a[175:168], a[183:176], a[191:184],
                            a[199:192], a[207:200], a[215:208], a[223:216],
                            a[231:224], a[239:232], a[247:240], a[255:248]};
end
endfunction

// local ---------------------------------------------------------------------
wire          [4:0] l4_tx_eop_pos;

wire     [4*64-1:0] tx4l_d;        // 8 lane payload data
wire                tx4l_sop;
wire                tx4l_eop;
wire                tx4l_error;
wire          [4:0] tx4l_eop_pos;  // end of packet position <= 31-avalon_empty
wire                tx4l_rdempty;
wire                tx4l_rdreq;

// little/big endian conversion
wire [255:0] l4_tx_data_local;
assign l4_tx_data_local = alt_aeu_40_wide_little_endian2avalon_256(l4_tx_data);

// WAS tx fifo -------------------------------------------------------------------
wire [5:0] l4_tx_eop_pos_tmp = 6'd31 - l4_tx_empty;
assign l4_tx_eop_pos = l4_tx_eop_pos_tmp[4:0];

assign tx4l_sop      = l4_tx_startofpacket && l4_tx_valid;
assign tx4l_eop      = l4_tx_endofpacket && l4_tx_valid;
assign tx4l_error    = l4_tx_error;
assign tx4l_eop_pos  = l4_tx_eop_pos;
assign tx4l_d        = l4_tx_data_local;

assign l4_tx_ready   = tx4l_rdreq;
assign tx4l_rdempty  = ~l4_tx_valid;

// 8 lanes to 5 lans conversion ----------------------------------------------
alt_aeu_40_wide_l4if_tx4to2 alt_aeu_40_wide_l4if_tx4to2(
    .arst               (mac_tx_arst_sync_core), // i
    .clk_txmac          (clk_txmac),          // i
    .tx4l_d             (tx4l_d),             // i
    .tx4l_sop           (tx4l_sop),           // i
    .tx4l_eop           (tx4l_eop),           // i
    .tx4l_error         (tx4l_error),
    .tx4l_eop_pos       (tx4l_eop_pos),       // i
    .tx4l_rdempty       (tx4l_rdempty),       // i
    .tx4l_rdreq         (tx4l_rdreq),         // o
    .tx2l_d             (tx2l_d),             // o
    .tx2l_sop           (tx2l_sop),           // o
	.tx2l_eop           (tx2l_eop),           // o
    .tx2l_error         (tx2l_error),
    .tx2l_eop_empty     (tx2l_eop_empty),        // o
    .tx2l_ack           (tx2l_ack)            // i
); // module l4if_4to2
defparam alt_aeu_40_wide_l4if_tx4to2.TARGET_CHIP = TARGET_CHIP;

reg inpacket = 1'b0;
always @(posedge clk_txmac or posedge mac_tx_arst_sync_core) begin
   if (mac_tx_arst_sync_core) inpacket 	    <= 1'b0;
	else begin
	   if(tx2l_sop[1] == 1'b1 && tx2l_eop[0] == 1'b1) inpacket <= 1'b0;	   
	   else if (tx2l_sop) inpacket 	    <= 1'b1;
	   else if (tx2l_eop) inpacket <= 1'b0;
	   
	end
end

always @(*) begin
	case ({tx2l_sop,tx2l_eop})
		4'b0001: tx2l_idle = 2'b00;
		4'b0010: tx2l_idle = 2'b01;
		4'b0100: tx2l_idle = 2'b10;
		4'b1000: tx2l_idle = 2'b00;
		4'b0110: tx2l_idle = 2'b00;
		4'b1001: tx2l_idle = 2'b00;
		default: tx2l_idle = {2{~inpacket}};
	endcase
end

endmodule

