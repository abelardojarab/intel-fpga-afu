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
// Module Name: eth_traff_ctrl.v
// Project:     Ethernet
//
// Description: 
// This module integrates the ETH Packet generator, monitor and CSR modules.

// ***************************************************************************

module eth_traff_ctrl
#(
    parameter INST_ID
)
(
// Configuration interface
input           cfg_clk     ,// Avalon-MM clk
input           cfg_reset   ,// Avalon-MM reset
input           cfg_read    ,// Avalon-MM read
input           cfg_write   ,// Avalon-MM write
input   [15:0]  cfg_address ,// Avalon-MM address
input   [31:0]  cfg_wrdata  ,// Avalon-MM write data
output  [31:0]  cfg_rddata  ,// Avalon-MM read data
// TX Avalon-ST interface
input           tx_clk      ,// Avalon-ST TX clk
input           tx_reset    ,// Avalon-ST TX reset
input           tx_ready    ,// Avalon-ST TX ready
output  [255:0] tx_data     ,// Avalon-ST TX data
output          tx_valid    ,// Avalon-ST TX data valid
output          tx_sop      ,// Avalon-ST TX start-of-packet
output          tx_eop      ,// Avalon-ST TX end-of-packet
output    [4:0] tx_empty    ,// Avalon-ST TX empty
output          tx_error    ,// Avalon-ST TX error
// RX Avalon-ST interface
input           rx_clk      ,// Avalon-ST RX clk
input           rx_reset    ,// Avalon-ST RX reset
input   [255:0] rx_data     ,// Avalon-ST RX data
input           rx_valid    ,// Avalon-ST RX data valid
input           rx_sop      ,// Avalon-ST RX start-of-packet
input           rx_eop      ,// Avalon-ST RX end-of-packet
input     [4:0] rx_empty    ,// Avalon-ST RX empty
input     [5:0] rx_error    ,// Avalon-ST RX error
output          rx_ready     // Avalon-ST RX ready
);

// -----------------------------------------------------------------------------
// Internal signals
// -----------------------------------------------------------------------------

wire [47:0] gen_dst_addr    ; // Gen destination address
wire [47:0] gen_src_addr    ; // Gen source address
wire [31:0] gen_pkt_number  ; // Gen number of packets
wire [10:0] gen_pkt_length  ; // Gen packet length
wire [ 9:0] gen_pkt_delay   ; // Gen inter-packet delay
wire [31:0] gen_pkt_ctrl    ; // Gen control vector
wire [31:0] gen_pkt_stat    ; // Gen status vector

wire [47:0] mon_dst_addr    ; // Mon destination address
wire [47:0] mon_src_addr    ; // Mon source address
wire [31:0] mon_pkt_number  ; // Mon number of packets
wire [31:0] mon_pkt_ctrl    ; // Mon control vector
wire [31:0] mon_pkt_stat    ; // Mon status vector

// -----------------------------------------------------------------------------
// CDC and pulse signals generation
// -----------------------------------------------------------------------------

reg   [2:0] gen_ctrl_0    = 'b0;
reg         gen_start_pls = 'b0;
reg   [2:0] gen_ctrl_1    = 'b0;
reg         gen_stop_pls  = 'b0;

always @(posedge tx_clk)
begin
    gen_ctrl_0[0] <= gen_pkt_ctrl[0];
    gen_ctrl_0[1] <= gen_ctrl_0[0];
    gen_ctrl_0[2] <= gen_ctrl_0[1];
    gen_start_pls <= (gen_ctrl_0[1] & ~gen_ctrl_0[2]);

    gen_ctrl_1[0] <= gen_pkt_ctrl[1];
    gen_ctrl_1[1] <= gen_ctrl_1[0];
    gen_ctrl_1[2] <= gen_ctrl_1[1];
    gen_stop_pls  <= (gen_ctrl_1[1] & ~gen_ctrl_1[2]);
end

reg   [2:0] mon_ctrl_0    = 'b0;
reg         mon_start_pls = 'b0;
reg   [2:0] mon_ctrl_1    = 'b0;
reg         mon_stop_pls  = 'b0;

always @(posedge rx_clk)
begin
    mon_ctrl_0[0] <= mon_pkt_ctrl[0];
    mon_ctrl_0[1] <= mon_ctrl_0[0];
    mon_ctrl_0[2] <= mon_ctrl_0[1];
    mon_start_pls <= (mon_ctrl_0[1] & ~mon_ctrl_0[2]);

    mon_ctrl_1[0] <= mon_pkt_ctrl[1];
    mon_ctrl_1[1] <= mon_ctrl_1[0];
    mon_ctrl_1[2] <= mon_ctrl_1[1];
    mon_stop_pls  <= (mon_ctrl_1[1] & ~mon_ctrl_1[2]);
end

// -----------------------------------------------------------------------------
// Sub-modules instances
// -----------------------------------------------------------------------------

eth_pkt_csr #(.INST_ID(INST_ID))
inst_eth_pkt_csr
(
    .clk             (cfg_clk       )   ,//i    [0]
    .reset           (cfg_reset     )   ,//i    [0]
    .cfg_read        (cfg_read      )   ,//i    [0]
    .cfg_write       (cfg_write     )   ,//i    [0]
    .cfg_address     (cfg_address   )   ,//i [15:0]
    .cfg_wrdata      (cfg_wrdata    )   ,//i [31:0]
    .cfg_rddata      (cfg_rddata    )   ,//o [31:0]
    .gen_dst_addr    (gen_dst_addr  )   ,//o [47:0]
    .gen_src_addr    (gen_src_addr  )   ,//o [47:0]
    .gen_pkt_number  (gen_pkt_number)   ,//o [31:0]
    .gen_pkt_length  (gen_pkt_length)   ,//o [10:0]
    .gen_pkt_delay   (gen_pkt_delay )   ,//o [ 9:0]
    .gen_pkt_ctrl    (gen_pkt_ctrl  )   ,//o [31:0]
    .gen_pkt_stat    (gen_pkt_stat  )   ,//i [31:0]
    .mon_dst_addr    (mon_dst_addr  )   ,//o [47:0]
    .mon_src_addr    (mon_src_addr  )   ,//o [47:0]
    .mon_pkt_number  (mon_pkt_number)   ,//o [31:0]
    .mon_pkt_ctrl    (mon_pkt_ctrl  )   ,//o [31:0]
    .mon_pkt_stat    (mon_pkt_stat  )    //i [31:0]
);

// gen_pkt_ctrl
// [0] - Start packet generation (self-clearing)
// [1] - Stop  packet generation (self_clearing)
// [2] - Continuous mode
// [3] - Random packet number
// [4] - Random packet length
// [5] - Random packet delay

// gen_pkt_stat
// [0] - Generation completed

eth_pkt_gen inst_eth_pkt_gen
(
    .clk            (tx_clk         )   ,//i     [0]
    .reset          (tx_reset       )   ,//i     [0]
    .cfg_start_gen  (gen_start_pls  )   ,//i     [0]
    .cfg_stop_gen   (gen_stop_pls   )   ,//i     [0]
    .cfg_dst_addr   (gen_dst_addr   )   ,//i  [47:0]
    .cfg_src_addr   (gen_src_addr   )   ,//i  [47:0]
    .cfg_pkt_number (gen_pkt_number )   ,//i  [31:0]
    .cfg_pkt_length (gen_pkt_length )   ,//i  [10:0]
    .cfg_pkt_delay  (gen_pkt_delay  )   ,//i   [9:0]
    .cfg_continuous (gen_pkt_ctrl[2])   ,//i     [0]
    .cfg_rnd_number (gen_pkt_ctrl[3])   ,//i     [0]
    .cfg_rnd_length (gen_pkt_ctrl[4])   ,//i     [0]
    .cfg_rnd_delay  (gen_pkt_ctrl[5])   ,//i     [0]
    .stat_gen_compl (gen_pkt_stat[0])   ,//o     [0]
    .tx_ready       (tx_ready       )   ,//i     [0]
    .tx_data        (tx_data        )   ,//o [255:0]
    .tx_valid       (tx_valid       )   ,//o     [0]
    .tx_sop         (tx_sop         )   ,//o     [0]
    .tx_eop         (tx_eop         )   ,//o     [0]
    .tx_empty       (tx_empty       )   ,//o   [4:0]
    .tx_error       (tx_error       )    //o     [0]     
);

// mon_pkt_ctrl
// [0] - Start packet monitoring (self-clearing)
// [1] - Stop  packet monitoring (self-clearing)
// [2] - Continuous mode

// mon_pkt_stat
// [0] - Monitoring completed (Received number of packets)
// [1] - Destination Address error
// [2] - Source Address error
// [3] - Packet Length error
    
eth_pkt_mon inst_eth_pkt_mon
(
    .clk            (rx_clk         )   ,//i     [0]
    .reset          (rx_reset       )   ,//i     [0]
    .cfg_start_mon  (mon_start_pls  )   ,//i     [0]
    .cfg_stop_mon   (mon_stop_pls   )   ,//i     [0]
    .cfg_dst_addr   (mon_dst_addr   )   ,//i  [47:0]
    .cfg_src_addr   (mon_src_addr   )   ,//i  [47:0]
    .cfg_pkt_number (mon_pkt_number )   ,//i  [31:0]
    .cfg_continuous (mon_pkt_ctrl[2])   ,//i     [0]
    .stat_mon_compl (mon_pkt_stat[0])   ,//o     [0]
    .stat_dst_err   (mon_pkt_stat[1])   ,//o     [0]
    .stat_src_err   (mon_pkt_stat[2])   ,//o     [0]
    .stat_len_err   (mon_pkt_stat[3])   ,//o     [0]
    .rx_data        (rx_data        )   ,//i [255:0]
    .rx_valid       (rx_valid       )   ,//i     [0]
    .rx_sop         (rx_sop         )   ,//i     [0]
    .rx_eop         (rx_eop         )   ,//i     [0]
    .rx_empty       (rx_empty       )   ,//i   [4:0]
    .rx_error       (rx_error       )   ,//i     [0]
    .rx_ready       (rx_ready       )    //o     [0]
);

endmodule
