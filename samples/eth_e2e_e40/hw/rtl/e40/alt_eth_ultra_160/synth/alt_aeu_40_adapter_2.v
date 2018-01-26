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


// $Id: //acds/rel/16.0/ip/ethernet/alt_eth_ultra/40g/rtl/ast/alt_aeu_40_adapter_2.v#1 $
// $Revision: #1 $
// $Date: 2016/02/08 $
// $Author: swbranch $
//-----------------------------------------------------------------------------
`timescale 1ps / 1ps

// set_instance_assignment -name VIRTUAL_PIN ON -to l4_tx_data
// set_instance_assignment -name VIRTUAL_PIN ON -to l4_tx_empty
// set_instance_assignment -name VIRTUAL_PIN ON -to tx4l_d
// set_instance_assignment -name VIRTUAL_PIN ON -to tx4l_eop_empty
// set_instance_assignment -name VIRTUAL_PIN ON -to l4_rx_data
// set_instance_assignment -name VIRTUAL_PIN ON -to l4_rx_empty
// set_instance_assignment -name VIRTUAL_PIN ON -to rx2l_d
// set_instance_assignment -name VIRTUAL_PIN ON -to rx2l_eop_empty
// set_global_assignment -name SEARCH_PATH ../../hsl12
// set_global_assignment -name SEARCH_PATH ../../rtl/lib
// set_global_assignment -name SEARCH_PATH ../../rtl/clones
// set_global_assignment -name SEARCH_PATH ../../rtl/ast

module alt_aeu_40_adapter_2 #(
    parameter SYNOPT_ALIGN_FCSEOP = 0,
    parameter WIDTH = 64,
    parameter WORDS = 4,
    parameter CWORDS = 2,
    parameter RXERRWIDTH = 6,
    parameter RXSTATUSWIDTH  = 3,                             
    parameter TARGET_CHIP = 2
 )(
    input wire  tx_arst,
    input wire  clk_txmac,      

    input wire  [WIDTH*WORDS-1:0] l4_tx_data,
    input wire  [4:0] l4_tx_empty,
    input wire  l4_tx_startofpacket,
    input wire  l4_tx_endofpacket,
    output wire l4_tx_ready,
    input wire  l4_tx_valid,
    input wire  l4_tx_error,
    
    input  wire  tx2l_ack,                 
    output wire [CWORDS*WIDTH-1:0] tx2l_d,        
    output wire [CWORDS-1:0] tx2l_sop,      
    output wire [CWORDS-1:0] tx2l_eop,      
    output wire [CWORDS*3-1:0] tx2l_eop_empty,
    output wire [CWORDS-1:0] tx2l_idle,
    output wire [CWORDS-1:0] tx2l_error,      
    
    input wire   rx_arst,
    input wire   clk_rxmac,
    
    output wire  [WIDTH*WORDS-1:0] l4_rx_data,
    output wire  [4:0] l4_rx_empty,
    output wire  l4_rx_startofpacket,
    output wire  l4_rx_endofpacket,
    output wire  [RXERRWIDTH-1:0]    l4_rx_error,
    output wire  [RXSTATUSWIDTH-1:0] l4_rx_status,   
    output wire  l4_rx_valid,
    output wire  l4_rx_fcs_valid,

    input wire   [CWORDS*64-1:0] rx2l_d,         
    input wire   [CWORDS-1:0] rx2l_sop,       
    input wire   [CWORDS-1:0] rx2l_idle,
    input wire   [CWORDS-1:0] rx2l_eop,       
    input wire   [CWORDS*3-1:0] rx2l_eop_empty,
    input wire   [RXERRWIDTH-1:0]    rx2l_error,
    input wire   [RXSTATUSWIDTH-1:0] rx2l_status,
    input wire   rx2l_fcs_valid,
    input wire   rx2l_valid      

  );
  
defparam tx_path.DEVICE_FAMILY = (TARGET_CHIP == 2) ? "Stratix V" : ((TARGET_CHIP == 1) ? "Stratix IV" : "UNDEFINED CHIP ID");
defparam tx_path.TARGET_CHIP = TARGET_CHIP;
defparam rx_path.DEVICE_FAMILY = (TARGET_CHIP == 2) ? "Stratix V" : ((TARGET_CHIP == 1) ? "Stratix IV" : "UNDEFINED CHIP ID");

alt_aeu_40_adapter_tx tx_path (
    .mac_tx_arst_sync_core(tx_arst),
    .clk_txmac(clk_txmac),

    .l4_tx_data(l4_tx_data),
    .l4_tx_empty(l4_tx_empty),
    .l4_tx_startofpacket(l4_tx_startofpacket), 
    .l4_tx_endofpacket(l4_tx_endofpacket),
    .l4_tx_error (l4_tx_error),
    .l4_tx_ready(l4_tx_ready), 
    .l4_tx_valid(l4_tx_valid), 
    
    .tx2l_d(tx2l_d),
    .tx2l_sop(tx2l_sop),
    .tx2l_eop(tx2l_eop),
    .tx2l_error(tx2l_error),
        .tx2l_eop_empty(tx2l_eop_empty),
        .tx2l_idle(tx2l_idle),
    .tx2l_ack(tx2l_ack)
    
    );

        
alt_aeu_40_adapter_rx rx_path (
    .mac_rx_arst_sync_core(rx_arst), 
    .clk_rxmac(clk_rxmac), 
    
    .l4_rx_data(l4_rx_data),
    .l4_rx_empty(l4_rx_empty),
    .l4_rx_startofpacket(l4_rx_startofpacket), 
    .l4_rx_endofpacket(l4_rx_endofpacket), 
    .l4_rx_error (l4_rx_error), 
    .l4_rx_status(l4_rx_status), //o                             
    .l4_rx_valid(l4_rx_valid), 
    .l4_rx_fcs_valid(l4_rx_fcs_valid), 
    
    .rx2l_d(rx2l_d),
    .rx2l_sop(rx2l_sop),
    .rx2l_eop(rx2l_eop),
    .rx2l_eop_empty(rx2l_eop_empty),
    .rx2l_idle(rx2l_idle),
    .rx2l_valid(rx2l_valid),            
        
    .rx2l_runt_last_data(2'b00),     // Not used
    .rx2l_fcs_valid(rx2l_fcs_valid),              
    .rx2l_error (rx2l_error ), 
    .rx2l_status(rx2l_status)   //i                             
);

endmodule
