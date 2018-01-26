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
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/ast/alt_aeu_40_adapter_rx.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
// ___________________________________________________________________________
//
// lanny - 12-05-2011 Adapter seperation

`timescale 1ps / 1ps

module alt_aeu_40_adapter_rx #(

    parameter DEVICE_FAMILY = "Stratix IV",
    parameter RXERRWIDTH    = 6,
    parameter RXSTATUSWIDTH = 3                       
)(
    input   mac_rx_arst_sync_core,
    input   clk_rxmac,    // MAC + PCS clock - at least 312.5Mhz
    
    output  [255:0] l4_rx_data,
    output  [4  :0] l4_rx_empty,
    output  l4_rx_startofpacket,
    output  l4_rx_endofpacket,
    output  [RXERRWIDTH-1:0]    l4_rx_error,
    output  [RXSTATUSWIDTH-1:0] l4_rx_status,   
    output  l4_rx_valid,
    output  l4_rx_fcs_valid,
    
    input   [2*64-1:0] rx2l_d,        // 5 lane payload to send
    input   [2   -1:0] rx2l_sop,      // 5 lane start position
        input   [2   -1:0] rx2l_eop,      // 5 lane end position
    input   [2*3 -1:0] rx2l_eop_empty,   // 5 lane end position, any byte
    input              rx2l_valid,    // payload is accepted
    input   [2   -1:0] rx2l_runt_last_data,
    input   [2   -1:0] rx2l_idle,
    input              rx2l_fcs_valid,
    input   [RXERRWIDTH-1:0]    rx2l_error,
    input   [RXSTATUSWIDTH-1:0] rx2l_status
);


//----------------------------------------------------------------------------
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
wire     [4*64-1:0] rx4l_d;        // 8 lane payload data
wire                rx4l_sop;
wire                rx4l_eop;
wire          [4:0] rx4l_empty;
wire                rx4l_fcs_valid;
wire     [RXERRWIDTH-1:0]    rx4l_error ;
wire     [RXSTATUSWIDTH-1:0] rx4l_status;
wire                rx4l_wrfull;
wire                rx4l_wrreq;

// little/big endian conversion
wire [255:0] l4_rx_data_local;

assign l4_rx_data       = alt_aeu_40_wide_little_endian2avalon_256(l4_rx_data_local);

// 2 lanes to 4 conversion ---------------------------------------------------
alt_aeu_40_wide_l4if_rx2to4 alt_aeu_40_wide_l4if_rx2to4(
    .arst              (mac_rx_arst_sync_core),  // i
    .clk_rxmac         (clk_rxmac),         // i
    .rx4l_d            (rx4l_d),            // o
    .rx4l_sop          (rx4l_sop),          // o
    .rx4l_eop          (rx4l_eop),          // o
    .rx4l_empty        (rx4l_empty),        // o
    .rx4l_sideband     ({rx4l_status, rx4l_error}),        // o
    .rx4l_fcs_valid    (rx4l_fcs_valid),    // o
    .rx4l_wrfull       (1'b0),              // i
    .rx4l_wrreq        (rx4l_wrreq),        // o
    .rx2l_d            (rx2l_d),            // i
    .rx2l_sop          (rx2l_sop),          // i
    .rx2l_eop          (rx2l_eop),          // i
    .rx2l_eop_empty    (rx2l_eop_empty),       // i
    .rx2l_valid        (rx2l_valid & (~&rx2l_idle)),        // i
    //.rx2l_error        ((|rx2l_runt_last_data) | (rx2l_fcs_valid & rx2l_fcs_error )),        // i
    .rx2l_fcs_valid    (rx2l_fcs_valid),    // i
    .rx2l_sideband     ({rx2l_status, rx2l_error}),    // i
    .rx2l_ready        ()                   // o    
);

assign l4_rx_fcs_valid     = rx4l_fcs_valid;
assign l4_rx_error         = rx4l_error;
assign l4_rx_status        = rx4l_status;
assign l4_rx_startofpacket = rx4l_sop;
assign l4_rx_endofpacket   = rx4l_eop;
assign l4_rx_empty         = rx4l_empty & {5{rx4l_eop}};
assign l4_rx_data_local    = rx4l_d;

// WAS rx fifo -------------------------------------------------------------------
assign l4_rx_valid = rx4l_wrreq;


endmodule

