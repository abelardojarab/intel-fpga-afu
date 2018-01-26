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
// Module Name: eth_pkt_gen.v
// Project:     Ethernet
//
// Description: 
// This module generates Ethernet packets with the following format:
// Field       Bytes
// dst_addr    6    
// src_addr    6
// Length      2
// Payload     46-1500
//
// The output interface follows the Avalon-ST signaling for packets:
// - ready  (i - sink is able to accept transactions)
// - data   (o - data bus)
// - valid  (o - valid signals qualifier)
// - sop    (o - start of packet flag)
// - eop    (o - end of packet flag)
//
// The configuration interface allows to setup the following parameters:
// - start (self-clearing) / stop (self-clearing)
// - source address
// - destination address
// - random / fixed packet length
// - random / fixed interpacket gap

// ***************************************************************************

module eth_pkt_gen
(
// Global signals
input               clk             ,// Clock signal (e40 @ 312.5MHz - 3.2ns)
input               reset           ,// Reset signal (active low)
// Configuration interface
input               cfg_start_gen   ,// start generation of packets
input               cfg_stop_gen    ,// stop generation of packets
input   	[47:0]  cfg_dst_addr    ,// MAC destination address
input   	[47:0]  cfg_src_addr    ,// MAC source address
input   	[31:0]  cfg_pkt_number  ,// number of packets to be generated
input   	[10:0]  cfg_pkt_length  ,// payload length (min=46 / max=1500 bytes)
input   	[ 9:0]  cfg_pkt_delay   ,// inter-packet delay    
input               cfg_continuous  ,// continuous generation
input               cfg_rnd_number  ,// packet number 0=fixed, 1=random
input               cfg_rnd_length  ,// payload length: 0=fixed, 1=random
input               cfg_rnd_delay   ,// interpacket delay: 0=fixed, 1=random
output reg          stat_gen_compl  ,// packet generation completed
// Avalon-ST interface
input               tx_ready        ,// Avalon-ST Sink Ready
output reg 	[255:0] tx_data         ,// Avalon-ST TX Data
output reg          tx_valid        ,// Avalon-ST TX Valid
output reg          tx_sop          ,// Avalon-ST TX StartOfPacket
output reg         	tx_eop          ,// Avalon-ST TX EndOfPacket
output reg  [ 4:0]  tx_empty        ,// Avalon-ST TX Empty
output reg          tx_error         // Avalon-ST TX Error
);

// -----------------------------------------------------------------------------
// internal signals
// -----------------------------------------------------------------------------

wire [10:0] pkt_length_tmp;
reg  [10:0] pkt_length;
reg  [10:0] byte_remain;

reg  [31:0] pkt_count;

reg   [9:0] pkt_delay; 
reg   [9:0] pkt_delay_count;

reg  [14:0] prbs15_data;

reg [255:0] tx_data_nxt;

reg         cfg_stop_gen_r;

integer i;

// -----------------------------------------------------------------------------
// FSM for Payload generation
// -----------------------------------------------------------------------------

// FSM parameters
localparam [2:0] ST_IDLE  = 3'b000,
                 ST_SOP   = 3'b001,
                 ST_DATA  = 3'b010,
                 ST_EOP   = 3'b011,
                 ST_DLY   = 3'b100;

reg [2:0] st_cur;
reg [2:0] st_nxt;

// FSM control outputs
reg fsm_idle;
reg fsm_sop;
reg fsm_data;
reg fsm_eop;

reg byte_remain_dec;
reg delay_count_inc;
reg tx_empty_load;

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
    byte_remain_dec = 'b0;
    delay_count_inc = 'b0;
    tx_empty_load   = 'b0;
    
    case (st_cur)
        ST_IDLE: begin
            if (!stat_gen_compl)
            begin
                byte_remain_dec = 'b1;
                st_nxt = ST_SOP;
            end
        end
         
        ST_SOP: begin
            if (tx_ready)
            begin
                byte_remain_dec = 'b1;
                // More than 63 bytes remain
                if (|byte_remain[10:6])
                    st_nxt = ST_DATA;
                else
                    // More than 32 bytes remain
                    if (byte_remain[5] && |byte_remain[4:0])
                        st_nxt = ST_DATA;
                    else
                    begin
                        tx_empty_load = 'b1;
                        st_nxt = ST_EOP;
                    end
            end
        end
         
        ST_DATA: begin
            if (tx_ready) 
            begin
                byte_remain_dec = 'b1;
                // More than 63 bytes remain
                if (|byte_remain[10:6])
                    st_nxt = ST_DATA;
                else
                    // More than 32 bytes remain
                    if (byte_remain[5] && |byte_remain[4:0])
                        st_nxt = ST_DATA;
                    else
                    begin
                        tx_empty_load = 'b1;
                        st_nxt = ST_EOP;
                    end
            end
        end
        
        ST_EOP: begin
            if (tx_ready)
                st_nxt = ST_DLY;
        end
                
        ST_DLY: begin
            delay_count_inc = 'b1;
            if (pkt_delay_count == pkt_delay)
                st_nxt = ST_IDLE;
        end
        default: begin
            st_nxt = ST_IDLE;
        end
    endcase
end


// -----------------------------------------------------------------------------
// cfg_stop_gen_r captures the cfg_stop_gen input pulse and stays asserted until 
// the packet generation has stopped
// -----------------------------------------------------------------------------

always @(posedge clk)
begin
    if (cfg_stop_gen)   cfg_stop_gen_r <= 1'b1;
    if (stat_gen_compl) cfg_stop_gen_r <= 1'b0;
end 

// -----------------------------------------------------------------------------
// pkt_length stores the payload length size; allowed values are 46 -> 1500.
// It will get a random value if cfg_rnd_length is set, otherwise it will get
// the value provided by the user in the cfg_pkt_length input. It should be
// captured by the SOP.
//
// byte_remain stores the number of bytes that remain to be generated
// The packet generation stops when this value reaches 0
// -----------------------------------------------------------------------------

assign pkt_length_tmp = (cfg_rnd_length) ? 
                        prbs15_data[10:0] :
                        cfg_pkt_length;

always @(posedge clk)
begin
    if (byte_remain_dec)
    begin
        if (fsm_idle)
        begin
            if (pkt_length_tmp < 11'd46)
            begin
                pkt_length  <= 11'd46;
                byte_remain <= 11'd28;
            end
            else
            begin
                if (pkt_length_tmp > 11'd1500)
                begin
                    pkt_length  <= 11'd1500;
                    byte_remain <= 11'd1482;
                end
                else
                begin
                    pkt_length  <= pkt_length_tmp;
                    byte_remain <= pkt_length_tmp - 11'd18;
                end
            end
        end
        else
            byte_remain <= byte_remain - 11'd32;
    end
end

// -----------------------------------------------------------------------------
// pkt_count stores the number of packets that have been generated.
// stat_gen_compl indicates if the generation process has completed
// The generation of packets stops when the user asserts the stop input
// or when the pkt_count reaches the cfg_pkt_number
// -----------------------------------------------------------------------------

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        stat_gen_compl <= 'b1;
        pkt_count <= 'b0;
    end
    else
        if (cfg_start_gen)
        begin
            stat_gen_compl <= 'b0;        
            pkt_count <= 'b0;
        end
        else
        begin
            if (tx_empty_load) // this signal is set once before EOP
                pkt_count <= pkt_count + 32'h1;
            if (fsm_eop)
                stat_gen_compl <= (~cfg_continuous & (pkt_count == cfg_pkt_number))
                                | cfg_stop_gen_r;
        end
end

// -----------------------------------------------------------------------------
// pkt_delay stores the inter-packet delay as a number of clock cycles
// It will get a random value if cfg_rnd_delay is set, otherwise it will get
// the value provided by the user in the cfg_pkt_delay input.
// -----------------------------------------------------------------------------

always @(posedge clk)
begin
    if (fsm_sop)
        pkt_delay <= (cfg_rnd_delay) ? 
                        prbs15_data[9:0] :
                        cfg_pkt_delay;
end
// -----------------------------------------------------------------------------
// pkt_delay_count stores the number of clock cycles elapsed after EOP
// -----------------------------------------------------------------------------

always @(posedge clk)
begin
    if (fsm_eop)
        pkt_delay_count <= 'b0;
    else
        if (delay_count_inc)
            pkt_delay_count <= pkt_delay_count + 10'h1;
end

// -----------------------------------------------------------------------------
// Payload generation
// -----------------------------------------------------------------------------

always @(*) 
begin
    for(i=0; i<16; i=i+1)
    begin
        if (i==15)
            tx_data_nxt[(i*16)+:16] = {prbs15_data[0], prbs15_data};
        else
            tx_data_nxt[(i*16)+:16] = {prbs15_data[i], prbs15_data};
    end
    if (fsm_sop)
        tx_data_nxt[255:112] = {cfg_dst_addr,          // 6 bytes
                                cfg_src_addr,          // 6 bytes
                                {5'b0, pkt_length},    // 2 bytes
                                pkt_count              // 4 bytes
                               };
end

// -----------------------------------------------------------------------------
// Avalon-ST output signals assignments
// -----------------------------------------------------------------------------

always @(posedge clk or posedge reset)
begin
    if (reset) 
    begin
        tx_data  <= 'b0;
        tx_valid <= 'b0;
        tx_sop   <= 'b0;
        tx_eop   <= 'b0;
        tx_empty <= 'b0;
        tx_error <= 'b0;
    end
    else
    begin
        if (tx_empty_load)
            tx_empty <= 6'd32 - byte_remain[4:0];
    
        if (tx_ready)
        begin
            tx_data  <= tx_data_nxt;
            tx_valid <= fsm_sop | fsm_data | fsm_eop;
            tx_sop   <= fsm_sop;
            tx_eop   <= fsm_eop;
            tx_error <= 'b0;        
        end
    end
end
   
// -----------------------------------------------------------------------------
// PRBS15 generator
// f(x) = x^15 + x^14 + x^0
// -----------------------------------------------------------------------------

always @(posedge clk or posedge reset)
begin
    if (reset) 
        prbs15_data <= 'h5eed;
    else
        if (tx_ready)
            prbs15_data <= {prbs15_data[0] ^ prbs15_data[1], prbs15_data[14:1]};
end        

endmodule
