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
// Module Name: eth_pkt_mon.v
// Project:     Ethernet
//
// Description: 
// This module receives Ethernet packets with the following format:
// Field       Bytes
// dst_addr    6    
// src_addr    6
// Length      2
// Payload     46-1500
//
// The output interface follows the Avalon-ST signaling for packets:
// - ready  (o - sink is able to accept transactions)
// - data   (i - data bus)
// - valid  (i - valid signals qualifier)
// - sop    (i - start of packet flag)
// - eop    (i - end of packet flag)
//
// The configuration interface allows to setup the following parameters:
// - start (self-clearing) / stop (self-clearing)

// ***************************************************************************

module eth_pkt_mon
(
// Global signals
input               clk             ,// Clock signal (e40 @ 312.5MHz - 3.2ns)
input               reset           ,// Reset signal (active high)
// Configuration interface
input               cfg_start_mon   ,// start monitoring packets
input               cfg_stop_mon    ,// stop monitoring packets
input   	[47:0]  cfg_dst_addr    ,// MAC destination address
input   	[47:0]  cfg_src_addr    ,// MAC source address
input   	[31:0]  cfg_pkt_number  ,// number of packets to be checked
input               cfg_continuous  ,// continuous monitoring
output reg          stat_mon_compl  ,// packet monitoring completed
output reg          stat_dst_err    ,// error in DST ADDR
output reg          stat_src_err    ,// error in SRC ADDR
output reg          stat_len_err    ,// error in packet length
// Avalon-ST interface
input      [255:0]  rx_data         ,// Avalon-ST RX Data
input               rx_valid        ,// Avalon-ST RX Valid
input               rx_sop          ,// Avalon-ST RX StartOfPacket
input             	rx_eop          ,// Avalon-ST RX EndOfPacket
input        [4:0]  rx_empty        ,// Avalon-ST RX Empty
input        [5:0]  rx_error        ,// Avalon-ST RX Error
output reg          rx_ready         // Avalon-ST Sink Ready
);

// -----------------------------------------------------------------------------
// internal parameters/signals
// -----------------------------------------------------------------------------

localparam DST_ADDR_MSB = 255;
localparam DST_ADDR_LSB = 208;
localparam SRC_ADDR_MSB = 207;
localparam SRC_ADDR_LSB = 160;
localparam PKT_LENG_MSB = 154; //159; Max Length 1500 fits in 11 bits
localparam PKT_LENG_LSB = 144;

reg	[47:0] dst_addr_reg;
reg	[47:0] src_addr_reg;

reg  [5:0] val_bytes_eop;

reg [10:0] byte_remain;
reg [31:0] pkt_remain;

wire       stop_monitor;
reg        cfg_stop_mon_r;

// -----------------------------------------------------------------------------
// FSM for packet monitoring
// -----------------------------------------------------------------------------

// FSM parameters
localparam [1:0] ST_IDLE  = 2'b00,
                 ST_SOP   = 2'b01,
                 ST_DATA  = 2'b10,
                 ST_EOP   = 2'b11;

reg [1:0] st_cur;
reg [1:0] st_nxt;

// FSM control outputs
reg fsm_idle;
reg fsm_sop;
reg fsm_data;
reg fsm_eop;

reg capt_sop;
reg capt_eop;
reg byte_remain_dec;
reg check_err;

// FSM current state logic
always @(posedge clk or posedge reset)
begin
    if (reset) 
    begin
        st_cur   <= ST_IDLE;
        fsm_idle <= 'b1;
        fsm_sop  <= 'b0;
        fsm_data <= 'b0;
        fsm_eop  <= 'b0;
    end
    else
    begin
        st_cur   <= st_nxt;
        fsm_idle <= (st_nxt == ST_IDLE);
        fsm_sop  <= (st_nxt == ST_SOP);
        fsm_data <= (st_nxt == ST_DATA);
        fsm_eop  <= (st_nxt == ST_EOP);
    end
end

// FSM next state logic
always @(*)
begin
    // default values for state and control signals
    st_nxt = st_cur;
    capt_sop = 'b0;
    capt_eop = 'b0;    
    byte_remain_dec = 'b0;
    check_err = 'b0;
    
    case (st_cur)
        ST_IDLE: begin
            if (rx_sop && rx_valid && !stat_mon_compl)
            begin
                capt_sop = 'b1;
                st_nxt = ST_SOP;
            end
        end
         
        ST_SOP: begin
            if (rx_valid)
            begin
                if (rx_eop)
                begin
                    capt_eop = 'b1;
                    st_nxt = ST_EOP;
                end
                else
                begin
                    byte_remain_dec = 'b1;
                    st_nxt = ST_DATA;
                end
            end
        end
         
        ST_DATA: begin
            if (rx_valid)
            begin
                if (rx_eop)
                begin
                    capt_eop = 'b1;
                    st_nxt = ST_EOP;
                end
                else
                    byte_remain_dec = 'b1;
            end
        end
        
        ST_EOP: begin
            check_err = 'b1;
            if (rx_sop && rx_valid && !stop_monitor)
            begin
                capt_sop = 'b1;
                st_nxt = ST_SOP;
            end
            else
                st_nxt = ST_IDLE;
        end
        
        default: begin
            st_nxt = ST_IDLE;
        end
    endcase
end

// -----------------------------------------------------------------------------
// cfg_stop_mon_r captures the cfg_stop_mon input pulse and stays asserted until 
// the packet monitoring has stopped
// -----------------------------------------------------------------------------

always @(posedge clk)
begin
    if (cfg_stop_mon)   cfg_stop_mon_r <= 1'b1;
    if (stat_mon_compl) cfg_stop_mon_r <= 1'b0;
end 

// -----------------------------------------------------------------------------
// dst_addr_reg stores the destination address received in the packet
// src_addr_reg stores the source address received in the packet
// An error will be flaged if they do not match the configured values
// -----------------------------------------------------------------------------

always @(posedge clk)
begin
    if (capt_sop)
    begin
        dst_addr_reg <= rx_data[DST_ADDR_MSB:DST_ADDR_LSB];
        src_addr_reg <= rx_data[SRC_ADDR_MSB:SRC_ADDR_LSB];
    end
end

always @(posedge clk)
begin
    if (cfg_start_mon)
    begin
        stat_dst_err <= 'b0;
        stat_src_err <= 'b0;
    end
    else
        if (check_err)
        begin
            stat_dst_err <= (dst_addr_reg != cfg_dst_addr);
            stat_src_err <= (src_addr_reg != cfg_src_addr);
        end
end

// -----------------------------------------------------------------------------
// byte_remain stores the number of bytes that remain to be received
// An error will be added if it does not reach 0 by EOP signaling
// -----------------------------------------------------------------------------

always @(posedge clk)
begin
    if (capt_sop)
        byte_remain <= rx_data[PKT_LENG_MSB:PKT_LENG_LSB] - 11'd18;
    else
        if (byte_remain_dec)
            byte_remain <= byte_remain -  11'd32;
end

always @(posedge clk)
begin
    if (cfg_start_mon)
        stat_len_err <= 'b0;
    else
        if (check_err)
            stat_len_err <= (byte_remain[5:0] != val_bytes_eop);
end

// -----------------------------------------------------------------------------
// pkt_remain stores the number of packets that remain to be received.
// stat_mon_compl indicates if the monitoring has stopped due:
// - no more packets remain
// - stop pulse has been received
// -----------------------------------------------------------------------------

assign stop_monitor = (~cfg_continuous & ~|pkt_remain) | cfg_stop_mon_r;

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        stat_mon_compl <= 'b1;
        pkt_remain <= 'b0;
    end
    else
        if (cfg_start_mon)
        begin
            stat_mon_compl <= 'b0;        
            pkt_remain <= cfg_pkt_number;
        end
        else
        begin
            if (capt_eop)
                pkt_remain <= pkt_remain - 32'h1;

            if (fsm_idle && cfg_stop_mon_r)
                stat_mon_compl <= 1'b1;
            if (fsm_eop)
                stat_mon_compl <= stop_monitor;
        end
end

// -----------------------------------------------------------------------------
// val_bytes_eop stores the number of valid bytes in the EOP cycle
// -----------------------------------------------------------------------------

always @(posedge clk)
begin
    if (capt_eop)
        val_bytes_eop <= 6'd32 - {1'b0, rx_empty};
end

// -----------------------------------------------------------------------------
// Avalon-ST output signals assignments
// -----------------------------------------------------------------------------

always @(posedge clk)
begin
    rx_ready <= 'b1;
end

endmodule
