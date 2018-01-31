// ***************************************************************************  
//
//          Copyright (C) 2017 Intel Corporation All Rights Reserved.
//
// The source code contained or described herein and all  documents related to
// the  source  code  ("Material")  are  owned  by  Intel  Corporation  or its
// suppliers  or  licensors.    Title  to  the  Material  remains  with  Intel
// Corporation or  its suppliers  and licensors.  The Material  contains trade
// secrets  and  proprietary  and  confidential  information  of  Intel or its
// suppliers and licensors.  The Material is protected  by worldwide copyright
// and trade secret laws and treaty provisions. No part of the Material may be
// used,   copied,   reproduced,   modified,   published,   uploaded,  posted,
// transmitted,  distributed,  or  disclosed  in any way without Intel's prior
// express written permission.
//
// No license under any patent,  copyright, trade secret or other intellectual
// property  right  is  granted  to  or  conferred  upon  you by disclosure or
// delivery  of  the  Materials, either expressly, by implication, inducement,
// estoppel or otherwise.  Any license under such intellectual property rights
// must be express and approved by Intel in writing.
//
// Engineer:    mariano.aguirre@intel.com
// Create Date: Feb/2017
// Module Name: eth_pkt_csr.v
// Project:     Ethernet
//
// Description: 
// This module defines the Control and Status Registers for the Ethernet Packet
// Generator and Checker modules.

// ***************************************************************************

module eth_pkt_csr
#(
    parameter INST_ID = 0
)
(
// Global signals
input             clk               ,// Clock signal (skxp @ 100MHz - 10ns)
input             reset             ,// Reset signal (active high)
// Configuration interface
input             cfg_read          ,// Avalon-MM read
input             cfg_write         ,// Avalon-MM write
input      [15:0] cfg_address       ,// Avalon-MM address
input      [31:0] cfg_wrdata        ,// Avalon-MM write data
output reg [31:0] cfg_rddata        ,// Avalon-MM read data

// Registers inputs/outputs
output reg [47:0] gen_dst_addr      ,//
output reg [47:0] gen_src_addr      ,//
output reg [31:0] gen_pkt_number    ,//
output reg [10:0] gen_pkt_length    ,//
output reg [ 9:0] gen_pkt_delay     ,//
output reg [31:0] gen_pkt_ctrl      ,//
input      [31:0] gen_pkt_stat      ,//
output reg [47:0] mon_dst_addr      ,//
output reg [47:0] mon_src_addr      ,//
output reg [31:0] mon_pkt_number    ,//
output reg [31:0] mon_pkt_ctrl      ,//
input      [31:0] mon_pkt_stat       //
);

// -----------------------------------------------------------------------------
// internal parameters/signals
// -----------------------------------------------------------------------------

// Registers addresses
localparam [3:0] GEN_DST_ADDR_L = 'h0,
                 GEN_DST_ADDR_H = 'h1,
                 GEN_SRC_ADDR_L = 'h2,
                 GEN_SRC_ADDR_H = 'h3,
                 GEN_PKT_NUMBER = 'h4,
                 GEN_PKT_LENGTH = 'h5,
                 GEN_PKT_DELAY  = 'h6,
                 GEN_PKT_CTRL   = 'h7,
                 GEN_PKT_STAT   = 'h8,
                 MON_DST_ADDR_L = 'h9,
                 MON_DST_ADDR_H = 'ha,
                 MON_SRC_ADDR_L = 'hb,
                 MON_SRC_ADDR_H = 'hc,
                 MON_PKT_NUMBER = 'hd,
                 MON_PKT_CTRL   = 'he,
                 MON_PKT_STAT   = 'hf;

// -----------------------------------------------------------------------------
// Write data decoding
// -----------------------------------------------------------------------------

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        gen_dst_addr    <= 'b0;
        gen_src_addr    <= 'b0;
        gen_pkt_number  <= 'b1;   
        gen_pkt_length  <= 'b0;   
        gen_pkt_delay   <= 'b1;   
        gen_pkt_ctrl    <= 'b0;   
        mon_dst_addr    <= 'b0;
        mon_src_addr    <= 'b0;
        mon_pkt_number  <= 'b1;   
        mon_pkt_ctrl    <= 'b0;   
    end
    else
    begin
        if (cfg_write && (cfg_address[15:12] == INST_ID[3:0]))
            case(cfg_address[3:0]) 
                GEN_DST_ADDR_L : gen_dst_addr[31:0]   <= cfg_wrdata;
                GEN_DST_ADDR_H : gen_dst_addr[47:32]  <= cfg_wrdata[15:0];
                GEN_SRC_ADDR_L : gen_src_addr[31:0]   <= cfg_wrdata;
                GEN_SRC_ADDR_H : gen_src_addr[47:32]  <= cfg_wrdata[15:0];
                GEN_PKT_NUMBER : gen_pkt_number       <= cfg_wrdata;
                GEN_PKT_LENGTH : gen_pkt_length       <= cfg_wrdata[10:0];
                GEN_PKT_DELAY  : gen_pkt_delay        <= cfg_wrdata[9:0];
                GEN_PKT_CTRL   : gen_pkt_ctrl         <= cfg_wrdata;
                MON_DST_ADDR_L : mon_dst_addr[31:0]   <= cfg_wrdata;
                MON_DST_ADDR_H : mon_dst_addr[47:32]  <= cfg_wrdata[15:0];
                MON_SRC_ADDR_L : mon_src_addr[31:0]   <= cfg_wrdata;
                MON_SRC_ADDR_H : mon_src_addr[47:32]  <= cfg_wrdata[15:0];
                MON_PKT_NUMBER : mon_pkt_number       <= cfg_wrdata;
                MON_PKT_CTRL   : mon_pkt_ctrl         <= cfg_wrdata;
                default        : ;
            endcase

        // Self-clearing control triggers
        if (gen_pkt_ctrl[0]) gen_pkt_ctrl[0] <= 1'b0;
        if (gen_pkt_ctrl[1]) gen_pkt_ctrl[1] <= 1'b0;
        if (mon_pkt_ctrl[0]) mon_pkt_ctrl[0] <= 1'b0;
        if (mon_pkt_ctrl[1]) mon_pkt_ctrl[1] <= 1'b0;
    end
end
                 
// -----------------------------------------------------------------------------
// Read data decoding
// -----------------------------------------------------------------------------

always @(posedge clk) 
begin
    if (cfg_read)
        case(cfg_address[3:0]) 
            GEN_DST_ADDR_L : cfg_rddata <= 32'b0 | gen_dst_addr[31:0];
            GEN_DST_ADDR_H : cfg_rddata <= 32'b0 | gen_dst_addr[47:32];
            GEN_SRC_ADDR_L : cfg_rddata <= 32'b0 | gen_src_addr[31:0];
            GEN_SRC_ADDR_H : cfg_rddata <= 32'b0 | gen_src_addr[47:32];
            GEN_PKT_NUMBER : cfg_rddata <= 32'b0 | gen_pkt_number;
            GEN_PKT_LENGTH : cfg_rddata <= 32'b0 | gen_pkt_length;
            GEN_PKT_DELAY  : cfg_rddata <= 32'b0 | gen_pkt_delay;
            GEN_PKT_CTRL   : cfg_rddata <= 32'b0 | gen_pkt_ctrl;
            GEN_PKT_STAT   : cfg_rddata <= 32'b0 | gen_pkt_stat;
            MON_DST_ADDR_L : cfg_rddata <= 32'b0 | mon_dst_addr[31:0];
            MON_DST_ADDR_H : cfg_rddata <= 32'b0 | mon_dst_addr[47:32];
            MON_SRC_ADDR_L : cfg_rddata <= 32'b0 | mon_src_addr[31:0];
            MON_SRC_ADDR_H : cfg_rddata <= 32'b0 | mon_src_addr[47:32];
            MON_PKT_NUMBER : cfg_rddata <= 32'b0 | mon_pkt_number;
            MON_PKT_CTRL   : cfg_rddata <= 32'b0 | mon_pkt_ctrl;
            MON_PKT_STAT   : cfg_rddata <= 32'b0 | mon_pkt_stat;
            default        : cfg_rddata <= 32'b0;
        endcase
end

endmodule
