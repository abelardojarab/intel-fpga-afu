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


// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/ast/alt_e100s10_adapter_4.v#5 $
// $Revision: #5 $
// $Date: 2013/08/30 $
// $Author: adubey $
//-----------------------------------------------------------------------------
`timescale 1ps / 1ps

// set_instance_assignment -name VIRTUAL_PIN ON -to l8_tx_data
// set_instance_assignment -name VIRTUAL_PIN ON -to l8_tx_empty
// set_instance_assignment -name VIRTUAL_PIN ON -to tx4l_d
// set_instance_assignment -name VIRTUAL_PIN ON -to tx4l_eop_empty
// set_instance_assignment -name VIRTUAL_PIN ON -to l8_rx_data
// set_instance_assignment -name VIRTUAL_PIN ON -to l8_rx_empty
// set_instance_assignment -name VIRTUAL_PIN ON -to rx4l_d
// set_instance_assignment -name VIRTUAL_PIN ON -to rx4l_eop_empty
// set_global_assignment -name SEARCH_PATH ../../hsl12
// set_global_assignment -name SEARCH_PATH ../../rtl/lib
// set_global_assignment -name SEARCH_PATH ../../rtl/clones
// set_global_assignment -name SEARCH_PATH ../../rtl/ast

module alt_e100s10_adapter_4 #(
    parameter SYNOPT_ALIGN_FCSEOP = 0,
    parameter WIDTH = 64,
    parameter WORDS = 4,
    parameter TARGET_CHIP = 2,
    parameter RXERRWIDTH = 6,
    parameter RXSTATUSWIDTH  = 3                        
)(
    // TX
    input  tx_srst,
    input  clk_txmac,    // MAC + PCS clock - at least 312.5Mhz

    input  [511:0] l8_tx_data,
    input  [5  :0] l8_tx_empty,
    input  l8_tx_startofpacket,
    input  l8_tx_endofpacket,
    output l8_tx_ready,
    input  l8_tx_valid,
    input  l8_tx_error,
    
    output [4*64-1:0] tx4l_d,        // 4 lane payload to send
    output [4   -1:0] tx4l_sop,      // 4 lane start position
    output [4   -1:0] tx4l_eop,      // 4 lane end of packet
    output [4*3 -1:0] tx4l_eop_empty,// 4 lane eop empty bytes
    output [4   -1:0] tx4l_idle,     // 4 lane idle 
    output [4   -1:0] tx4l_error,
    input  tx4l_ack,                 // payload is accepted
    
    // RX 
    input   rx_srst,
    input   clk_rxmac,    // MAC + PCS clock - at least 312.5Mhz
    
    output  [511:0] l8_rx_data,
    output  [5  :0] l8_rx_empty,
    output  l8_rx_startofpacket,
    output  l8_rx_endofpacket,
    output  l8_rx_fcs_error,
    output  l8_rx_valid,
    output  [RXERRWIDTH-1:0] l8_rx_error,
    output  [RXSTATUSWIDTH-1:0] l8_rx_status,
    output  l8_rx_fcs_valid,

    input   [4*64-1:0] rx4l_d,         // 4 lane payload to send
    input   [4   -1:0] rx4l_sop,       // 4 lane start position
    input   [4   -1:0] rx4l_idle,      // 4 lane idle position
    input   [4   -1:0] rx4l_eop,       // 4 lane end position, any byte
    input   [4*3 -1:0] rx4l_eop_empty, // 4 lane # of empty bytes
    input   [RXERRWIDTH-1:0] rx4l_error,
    input   [RXSTATUSWIDTH-1:0] rx4l_status,
    input              rx4l_fcs_valid,
    input              rx4l_valid      // payload is accepted

);


// local ---------------------------------------------------------------------
wire          [5:0] l8_tx_eop_pos;

wire     [8*64-1:0] tx8l_d;        // 8 lane payload data
wire                tx8l_sop;
wire                tx8l_eop;
wire          [5:0] tx8l_eop_pos;  // end of packet position <= 63-avalon_empty
wire                tx8l_rdempty;
wire                tx8l_rdreq;

// little/big endian conversion
wire [511:0] l8_tx_data_local;
assign l8_tx_data_local = l8_tx_data;

// WAS tx fifo -------------------------------------------------------------------
//assign l8_tx_eop_pos = 63 - l8_tx_empty;
assign l8_tx_eop_pos = l8_tx_empty;

assign tx8l_sop      = l8_tx_startofpacket;
assign tx8l_eop      = l8_tx_endofpacket;
assign tx8l_eop_pos  = l8_tx_eop_pos;
assign tx8l_d        = l8_tx_data_local;

assign l8_tx_ready   = tx8l_rdreq;
assign tx8l_rdempty  = ~l8_tx_valid;

// 8 lanes to 4 lans conversion ----------------------------------------------
alt_e100s10_wide_l8if_tx824 alt_e100s10_wide_l8if_tx824(
    .srst               (tx_srst),            // i
    .clk_txmac          (clk_txmac),          // i
    .tx8l_d             (tx8l_d),             // i
    .tx8l_sop           (tx8l_sop),           // i
    .tx8l_eop           (tx8l_eop),           // i
    .tx8l_eop_pos       (tx8l_eop_pos),       // i
    .tx8l_rdempty       (tx8l_rdempty),       // i
    .tx8l_error         (l8_tx_error),
    .tx8l_rdreq         (tx8l_rdreq),         // o
    .tx4l_d             (tx4l_d),             // o
    .tx4l_sop           (tx4l_sop),           // o
    .tx4l_eop           (tx4l_eop),           // o
    .tx4l_eop_empty     (tx4l_eop_empty),     // o
    .tx4l_error         (tx4l_error),
    .tx4l_idle          (tx4l_idle),          // o
    .tx4l_ack           (tx4l_ack)            // i
); // module alt_e100s10_wide_l8if_tx824
    defparam alt_e100s10_wide_l8if_tx824 .TARGET_CHIP = TARGET_CHIP;

// local ---------------------------------------------------------------------
wire     [8*64-1:0] rx8l_d;        // 8 lane payload data
wire                rx8l_sop;
wire                rx8l_eop;
wire          [5:0] rx8l_empty;
wire                rx8l_fcs_error;
wire                rx8l_wrfull;
wire                rx8l_wrreq;
wire [RXERRWIDTH-1:0]          rx8l_error;
wire [RXSTATUSWIDTH-1:0]       rx8l_status;
wire                rx8l_fcs_valid;

// 4 lanes to 8 conversion ---------------------------------------------------
alt_e100s10_wide_l8if_rx428 alt_e100s10_wide_l8if_rx428(
    .srst           (rx_srst),        //i
    .clk_rxmac      (clk_rxmac),      // i
    .rx8l_d         (rx8l_d),         // o
    .rx8l_sop       (rx8l_sop),       // o
    .rx8l_eop       (rx8l_eop),       // o
    .rx8l_empty     (rx8l_empty),     // o
    .rx8l_sideband  ({rx8l_status, rx8l_error}),     // o 
    .rx8l_fcs_error (rx8l_fcs_error), // o
    .rx8l_fcs_valid (rx8l_fcs_valid), // o
    .rx8l_wrfull    (1'b0),           // i
    .rx8l_wrreq     (rx8l_wrreq),     // o
    .rx4l_d         (rx4l_d),         // i
    .rx4l_sop       (rx4l_sop),       // i
    .rx4l_idle      (rx4l_idle),      // i
    .rx4l_eop       (rx4l_eop),       // i
    .rx4l_eop_empty (rx4l_eop_empty), // i
    .rx4l_sideband  ({rx4l_status,rx4l_error}),     // i 
    .rx4l_fcs_valid (rx4l_fcs_valid), // i
    .rx4l_valid     (rx4l_valid)      // i
);
    defparam alt_e100s10_wide_l8if_rx428 .TARGET_CHIP = TARGET_CHIP;
    defparam alt_e100s10_wide_l8if_rx428 .SYNOPT_ALIGN_FCSEOP = SYNOPT_ALIGN_FCSEOP;
    defparam alt_e100s10_wide_l8if_rx428 .RXSIDEBANDWIDTH = RXSTATUSWIDTH + RXERRWIDTH;


assign l8_rx_fcs_error     = rx8l_fcs_error;
assign l8_rx_fcs_valid     = rx8l_fcs_valid;
assign l8_rx_error         = rx8l_error;
assign l8_rx_status        = rx8l_status;   
assign l8_rx_startofpacket = rx8l_sop;
assign l8_rx_endofpacket   = rx8l_eop;
assign l8_rx_empty         = rx8l_empty & {6{rx8l_eop}};
assign l8_rx_data          = rx8l_d;

wire [255:0] l8_rx_data_hi, l8_rx_data_lo;
wire [255:0] l8_tx_data_hi, l8_tx_data_lo;

assign l8_rx_data_hi       = rx8l_d[511:256];
assign l8_rx_data_lo       = rx8l_d[255:0];
assign l8_tx_data_hi       = l8_tx_data[511:256];
assign l8_tx_data_lo       = l8_tx_data[255:0];

// WAS rx fifo -------------------------------------------------------------------
assign l8_rx_valid = rx8l_wrreq;

endmodule
