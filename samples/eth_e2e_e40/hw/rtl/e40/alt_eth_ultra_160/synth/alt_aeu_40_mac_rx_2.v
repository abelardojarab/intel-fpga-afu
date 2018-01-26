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
// ______________________________________________________________________________
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/mac/alt_aeu_40_mac_rx_2.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
// ______________________________________________________________________________


`timescale 1 ps / 1 ps
// baeckler - 10-12-2012
// read CGMII stream, check for errors, annotate


// set_instance_assignment -name VIRTUAL_PIN ON -to mii_data_in
// set_instance_assignment -name VIRTUAL_PIN ON -to data_out
// set_instance_assignment -name VIRTUAL_PIN ON -to dout_d
// set_instance_assignment -name VIRTUAL_PIN ON -to dout_sop
// set_instance_assignment -name VIRTUAL_PIN ON -to dout_eop
// set_instance_assignment -name VIRTUAL_PIN ON -to dout_idle
// set_instance_assignment -name VIRTUAL_PIN ON -to dout_eop_empty
// set_global_assignment -name SEARCH_PATH ../../hsl18
// set_global_assignment -name SEARCH_PATH ../../rtl/lib
// set_global_assignment -name SEARCH_PATH ../../rtl/mac
// set_global_assignment -name SEARCH_PATH ../../rtl/clones
// set_global_assignment -name SEARCH_PATH ../../rtl/csr

module alt_aeu_40_mac_rx_2 #(
    parameter TARGET_CHIP = 2, 
    parameter SYNOPT_ALIGN_FCSEOP = 0, 
                // 0: no alignment
                // 1: align at custom & avalon interface. additional 11 cycle latency in packet to align
                // 2: align at avalon interface, no extra latency
    parameter REVID = 32'h04142014,
    parameter BASE_RXMAC = 5,
    parameter BASE_RXSTAT = 7,
    parameter SYNOPT_RXSTATS = 1, 
    parameter SYNOPT_RXHPROC = 1, 
    parameter ERRORBITWIDTH  = 11,  
    parameter RXERRWIDTH  = 6,
    parameter RXSTATUSWIDTH  = 3, 
    parameter STATSBITWIDTH  = 32,  
    parameter EN_LINK_FAULT = 1, 
    parameter SYNOPT_PREAMBLE_PASS = 1, 
    parameter WORDS = 2, // no override   
    parameter REDUCE_CRC_LAT = 1'b1  // lower CRC latency (at expense of timing)
)(
    input clk,
    input wire reset_rx, //from ~rx_online,//this input has not logic connect to it
 
    // raw CGMII stream in
    input wire rx_pcs_fully_aligned,
    input mii_in_valid,
    input [WORDS*64-1:0] mii_data_in,  // read bytes left to right
    input [WORDS*8-1:0] mii_ctl_in,    // read bits left to right

    // annotated output
    output out_valid,
    output [WORDS*64-1:0] data_out,  // read bytes left to right
    output [WORDS*8-1:0] ctl_out,    // read bits left to right
    output [WORDS-1:0] first_data,  // word contains the first non-preamble data of a frame
    output [WORDS*8-1:0] last_data, // byte contains the last data before FCS
    
    // lagged (N) cycles from the non-zero last_data output
    output wire [RXERRWIDTH-1:0] rx_error,
    output wire [RXSTATUSWIDTH-1:0] rx_status, 
    output wire rx_fcs_error,               // referring to the non-zero last_data
    output wire rx_fcs_valid,
    output wire remote_fault_status,
    output wire local_fault_status,
    
    output reg                dout_valid,
    output reg [WORDS*64-1:0] dout_d,
    output reg [WORDS*8-1:0]  dout_c,
    output reg [WORDS-1:0]    dout_sop,
    output reg [WORDS-1:0]    dout_eop,
    output reg [WORDS*3-1:0]  dout_eop_empty,
    output reg [WORDS-1:0]    dout_idle,

    input  wire reset_csr,// global reset, async, no domain
    input  wire clk_csr,  // 100 MHz
    output wire serif_slave_dout,
    input  wire serif_slave_din,
    output reg [WORDS-1:0] rx_mii_start,
    output wire[STATSBITWIDTH-1:0] out_rx_stats,
    output wire[15:0] rx_inc_octetsOK,
    output wire rx_inc_octetsOK_valid
 );
 
wire                rx_mii_err_chk;
wire                rx_fcs_error_chk;
wire                rx_fcs_valid_chk;
wire                dout_valid_chk;
wire [WORDS*64-1:0] dout_d_chk;
wire [WORDS*8-1:0]  dout_c_chk;
wire [WORDS-1:0]    dout_sop_chk;
wire [WORDS-1:0]    dout_eop_chk;
wire [WORDS*3-1:0]  dout_eop_empty_chk;
wire [WORDS-1:0]    dout_idle_chk;

reg                dout_valid_int;
reg [WORDS*64-1:0] dout_d_int;
reg [WORDS*8-1:0]  dout_c_int;
reg [WORDS-1:0]    dout_sop_int;
reg [WORDS-1:0]    dout_eop_int;
reg [WORDS*3-1:0]  dout_eop_empty_int;
reg [WORDS-1:0]    dout_idle_int;
reg                dout_rxi_in_packet_int;
reg   rx_mii_err;
 wire  cfg_keep_rx_crc;
 wire  keep_rx_crc = cfg_keep_rx_crc;
reg fcs_error; initial fcs_error = 0;
reg fcs_error_a; initial fcs_error_a = 0;
reg fcs_valid; initial fcs_valid = 0;
reg fcs_valid_a; initial fcs_valid_a = 0;
 reg [WORDS-1:0] words_valid;

wire out_rxfcs_valid, out_err_rx_fcs;
wire out_rx_ctrl_other;      //  From alt_aeu_40_hproc_2 
wire out_rx_ctrl_pfc;        //  From alt_aeu_40_hproc_2 
wire out_rx_ctrl_sfc;        //  From alt_aeu_40_hproc_2 
localparam BYTES = WORDS * 8;

// reset syncer
wire gbl_rst_sync_rxd;
   
aclr_filter gbl_rst_syncer_rx_domain(
        .aclr     (reset_csr),         // global reset, no domain
        .clk      (clk),     
        .aclr_sync(gbl_rst_sync_rxd)   // sync to rx clock domain
);

reg gbl_rst_sync_rxd_1d = 1'b0;
reg reset_rx_1d = 1'b0;           
wire gbl_rst_sync_rxd_posedge;
wire reset_rx_negedge;

always @(posedge clk) begin
  gbl_rst_sync_rxd_1d <= gbl_rst_sync_rxd;
  reset_rx_1d         <= reset_rx    ;       
end


assign gbl_rst_sync_rxd_posedge = (gbl_rst_sync_rxd) & (~gbl_rst_sync_rxd_1d); 
assign reset_rx_negedge         = (~reset_rx       ) & ( reset_rx_1d    );

reg rst_stats = 1'b0;
always @(posedge clk) begin
  if (gbl_rst_sync_rxd_posedge) rst_stats <= 1'b1; // asserted when gloabl reset asserted       
  else if (reset_rx_negedge)    rst_stats <= 1'b0; // deasserted when rx digital reset is done 
   
end   

/////////////////////////////////////
// work out the frame boundaries
/////////////////////////////////////

reg [WORDS*64-1:0]  next2_din = 0, next_din = 0, din = 0;
reg [WORDS*8-1:0] next2_ctl = 0, next_ctl = 0, ctl = 0;
wire ena = mii_in_valid;
reg din_valid = 1'b0;

always @(posedge clk) begin
    din_valid <= 1'b0;
    if (ena) begin
        next2_din <= mii_data_in;
        next2_ctl <= mii_ctl_in;
        next_din <= next2_din;
        next_ctl <= next2_ctl;
        din <= next_din;
        ctl <= next_ctl;
        din_valid <= 1'b1;
    end
end

// you are first data when the previous block was a frame start
reg  [WORDS-1:0] din_first_data;
//assign din_first_data[0] = ctl[2*8-1] & (din[2*64-1:2*64-8] == 8'hfb);

// you are last data when plus 5 bytes is a frame term
reg [BYTES-1:0] din_last_data = 0;
reg [BYTES-1:0] din_last_data_b4crc = 0;
wire [BYTES-1:0] next_din_last_data;
wire [BYTES-1:0] next_din_last_data_b4crc;

genvar i;
generate
    for (i=BYTES-1; i>=5; i=i-1) begin : c0
                assign next_din_last_data_b4crc[i] = next_ctl[i-5] & (next_din[(i+1-5)*8-1:(i-5)*8] == 8'hfd);
        assign next_din_last_data[i] = keep_rx_crc ? next_ctl[i-1] & (next_din[i*8-1:(i-1)*8] == 8'hfd) :
                                                                                                         next_ctl[i-5] & (next_din[(i+1-5)*8-1:(i-5)*8] == 8'hfd);
    end
endgenerate

// wrap around to the next word
wire [4:0] next2_ctl_top = next2_ctl[WORDS*8-1:WORDS*8-5];
wire [39:0] next2_din_top = next2_din[WORDS*64-1:WORDS*64-40];
generate
    for (i=4; i>=1; i=i-1) begin : c1
                assign next_din_last_data_b4crc[i] = next2_ctl_top[i] & (next2_din_top[8*(i+1)-1:8*i] == 8'hfd);
        assign next_din_last_data[i] = keep_rx_crc ? next_ctl[i-1] & (next_din[i*8-1:(i-1)*8] == 8'hfd) :
                                                             next2_ctl_top[i] & (next2_din_top[8*(i+1)-1:8*i] == 8'hfd);
    end
endgenerate

assign next_din_last_data_b4crc[0] = next2_ctl_top[0] & (next2_din_top[7:0] == 8'hfd);
assign next_din_last_data[0] = keep_rx_crc ? next2_ctl_top[4] & (next2_din_top[39:32] == 8'hfd) :
                                             next2_ctl_top[0] & (next2_din_top[7:0] == 8'hfd);

reg [BYTES-1:0] prev_din_last_data_b4crc = 0;
always @(posedge clk) begin
    if (ena) begin
        din_last_data <= next_din_last_data;
                din_last_data_b4crc <= next_din_last_data_b4crc;
        prev_din_last_data_b4crc <= din_last_data_b4crc;
    end
end

// black out at least 7 bytes starting on the 1st byte of the FCS
wire [BYTES-1:0] din_blank_byte;
wire [7 + BYTES-1:0] tmp_last_flags = {prev_din_last_data_b4crc [6:0], din_last_data_b4crc};
wire [WORDS*64-1:0] din_blank_mask;

generate
    for (i=0; i<BYTES; i=i+1) begin : blk
        assign din_blank_byte [i] = |tmp_last_flags[i+7:i+1];
        assign din_blank_mask [8*(i+1)-1:8*i] = {8{din_blank_byte[i]}};
    end
endgenerate

/////////////////////////////////////
// grab the received FCS for compare
/////////////////////////////////////

reg [3:0] fcs_idx = 0;
always @(posedge clk) begin
    fcs_idx[3] <= |(din_last_data_b4crc & 16'h00ff);
    fcs_idx[2] <= |(din_last_data_b4crc & 16'h0f0f);
    fcs_idx[1] <= |(din_last_data_b4crc & 16'h3333);
    fcs_idx[0] <= |(din_last_data_b4crc & 16'h5555);
end

reg [WORDS*64+32-1:0] tmp_fcs_r = 0;
always @(posedge clk) begin
        tmp_fcs_r <= {din,next_din[WORDS*64-1:WORDS*64-32]};
end

wire [WORDS*64+32+24-1:0] tmp_fcs = {8'h00,8'h00,8'h00,tmp_fcs_r};

// want to compute the top 32 bits of tmp_fcs << (8*(fcs_idx));
// doing it in stages for Fmax

reg [WORDS*64+32+24-1:0] tmp_fcs2 = 0;
reg [2:0] fcs_idx2 = 0;

always @(posedge clk) begin
    case (fcs_idx[3])
        1'b0 : tmp_fcs2 <= tmp_fcs;
        1'b1 : tmp_fcs2 <= tmp_fcs << 8*8;
    endcase
    fcs_idx2 <= fcs_idx[2:0];
end

reg [WORDS*64+32+24-1:0] tmp_fcs3 = 0;
always @(posedge clk) begin
    case (fcs_idx2)
        3'b000 : tmp_fcs3 <= tmp_fcs2;
        3'b001 : tmp_fcs3 <= tmp_fcs2 << 1*8;
        3'b010 : tmp_fcs3 <= tmp_fcs2 << 2*8;
        3'b011 : tmp_fcs3 <= tmp_fcs2 << 3*8;
        3'b100 : tmp_fcs3 <= tmp_fcs2 << 4*8;
        3'b101 : tmp_fcs3 <= tmp_fcs2 << 5*8;
        3'b110 : tmp_fcs3 <= tmp_fcs2 << 6*8;
        3'b111 : tmp_fcs3 <= tmp_fcs2 << 7*8;            
    endcase
end

reg [31:0] expect_fcs = 0;
always @(posedge clk) begin
    expect_fcs <=  tmp_fcs3[WORDS*64+24-1:WORDS*64+24-32];
end

wire [31:0] fcs_lag;
delay_mlab dr5 (
        .clk(clk),
        .din(expect_fcs),
        .dout(fcs_lag)
);
defparam dr5 .TARGET_CHIP = TARGET_CHIP;
defparam dr5 .WIDTH = 32;
defparam dr5 .LATENCY = REDUCE_CRC_LAT ? 6 : 10;


wire [7:0] tmp_a,tmp_b,tmp_c,tmp_d;
assign {tmp_a,tmp_b,tmp_c,tmp_d} = fcs_lag;

// byte reverse the packet's expected CRC
wire [31:0] expect_crc;
assign expect_crc = {tmp_d,tmp_c,tmp_b,tmp_a};

/////////////////////////////////////
// CRC heavy lifting
/////////////////////////////////////

wire [31:0] crc_out;
wire crc_out_valid;
ecrc_2 fcs (
    .clk(clk),
    
    .din_valid(din_valid),
    .din (din & ~din_blank_mask),
    .din_first_data(din_first_data),
    .din_last_data(din_last_data_b4crc & {{8{words_valid[1]}}, {8{words_valid[0]}}}),

    .crc_valid(crc_out_valid),
    .crc_out(crc_out)   
);
defparam fcs .REDUCE_LATENCY = REDUCE_CRC_LAT;
defparam fcs .TARGET_CHIP = TARGET_CHIP; 

wire pipe_crc;
delay_regs dr6 (
        .clk(clk),
        .din(keep_rx_crc && din_valid && ((|din_last_data_b4crc[3:0]) && words_valid[0])),
        .dout(pipe_crc)
);
defparam dr6 .LATENCY = REDUCE_CRC_LAT ? 11 : 15;
defparam dr6 .WIDTH = 1;

reg last_is_data_eop=0;
always @(posedge clk) last_is_data_eop <= keep_rx_crc && din_valid & (|din_last_data_b4crc[3:0]) && words_valid[0];

wire pipe4enable;
delay_regs dr7 (
        .clk(clk),
        .din(!din_valid && last_is_data_eop),
        .dout(pipe4enable)
);
defparam dr7 .LATENCY = REDUCE_CRC_LAT ? 10 : 14;
defparam dr7 .WIDTH = 1;

/////////////////////////////////////
// CRC comparator
/////////////////////////////////////

reg [7:0] crc_chk = 0;
reg crc_chk_valid;
generate
    for (i=0; i<8; i=i+1) begin : chk
        always @(posedge clk) begin
            crc_chk [i] <= |(crc_out[(i+1)*4-1:i*4] ^ expect_crc[(i+1)*4-1:i*4]);
        end
    end
endgenerate

reg pipe_crc_r=0;
reg pipe4enable_r=0;
reg [1:0] fcs_valid_buf=0;
reg [1:0] fcs_error_buf=0;
reg [1:0] pipe4enable_buf=0;

always @(posedge clk) begin
       pipe_crc_r <= pipe_crc;
       crc_chk_valid <= crc_out_valid;
       fcs_error_a <= |crc_chk;
       fcs_valid_a <= crc_chk_valid;
       pipe4enable_r <= pipe4enable;
       // adubey. to fix quartus warning
       //fcs_valid_buf <= {fcs_valid_buf[3:0], fcs_valid_a};
       //fcs_error_buf <= {fcs_error_buf[3:0], fcs_error_a};
       //pipe4enable_buf <= {pipe4enable_buf[3:0], pipe4enable_r};
       fcs_valid_buf <= {fcs_valid_buf[0], fcs_valid_a};
       fcs_error_buf <= {fcs_error_buf[0], fcs_error_a};
       pipe4enable_buf <= {pipe4enable_buf[0], pipe4enable_r};

       fcs_error   <= pipe_crc ? 1'b0 : pipe_crc_r ? (pipe4enable_r ? 1'b0: fcs_error_a) : pipe4enable_buf[1] ? fcs_error_buf[1] : |crc_chk;
       fcs_valid   <= pipe_crc ? 1'b0 : pipe_crc_r ? (pipe4enable_r ? 1'b0: fcs_valid_a) : pipe4enable_buf[1] ? fcs_valid_buf[1] : crc_chk_valid;
end

/////////////////////////////////////
// outputs 
/////////////////////////////////////

assign out_valid = din_valid;
assign data_out = din;
assign ctl_out = ctl;
assign first_data = din_first_data;
assign last_data = din_last_data;




/////////////////////////////////////
// output interface conversion
/////////////////////////////////////
reg [WORDS-1:0] preamble_pos = 0;
reg [WORDS-1:0] pre_dout_eop;


wire[WORDS-1:0] sop_pos;
assign sop_pos = SYNOPT_PREAMBLE_PASS ? preamble_pos : first_data;


//--- functions
//----------------------------------------------------------------------------
function [2:0] encode8to3;
input [7:0] in;

reg   [2:0] out;
integer     i;

begin
    out = 0;
    for (i = 0; i < 8; i = i + 1) begin
        if (in[i])   out = out | i[2:0];
    end
    encode8to3 = out;
end
endfunction

//assign pre_dout_eop = { |last_data[31:24], |last_data[23:16], |last_data[15:8], |last_data[7:0]};
always @(posedge clk)
    if (ena) begin
       pre_dout_eop <= { |next_din_last_data[15:8], |next_din_last_data[7:0]};
    end

always @(posedge clk) begin
    if (ena) begin
       preamble_pos[1] <= next_ctl[2*8-1] & (next_din[2*64-1:2*64-8] == 8'hfb);
       preamble_pos[0] <= next_ctl[1*8-1] & (next_din[1*64-1:1*64-8] == 8'hfb);
       din_first_data[1] <= ctl[8-1] & (din[63:56] == 8'hfb);
       din_first_data[0] <= next_ctl[2*8-1] & (next_din[2*64-1:2*64-8] == 8'hfb);
    end
end

reg rxi_in_packet = 1'b0;

always @(posedge clk)
begin
       //if      ( (|preamble_pos) & (~(|last_data))) rxi_in_packet <= 1;
       //else if ((~(|preamble_pos)) &  (|last_data)) rxi_in_packet <= 0;

       //if      ( !rxi_in_packet && (|preamble_pos)) rxi_in_packet <= 1;
       //else if      ( (|preamble_pos) & (~(|last_data))) rxi_in_packet <= 1;
       //else if ((~(|preamble_pos)) &  (|last_data)) rxi_in_packet <= 0;

    // ______________________________________________________________________
    //  the rxi_in_packet is simply a 1-bit state that indicates whether
    //  a packet is in progress (and has not ended). whenever there is start
    //  on MSWORD and no eop in that cycle - or - there is a start on LS word
    //  (that can not be followed by an eop with min 64B packet), this signal
    //  is set. Similarly, whenever a packet ends on LS WORD or ends on MS Words
    //  without a new start, this is set indicating no packet is in progress
    // _________________________________ adubey 11.21.2013 ___________________
       if ((sop_pos[1] && (~(|last_data[ 7:0]))) ||
            sop_pos[0]) rxi_in_packet <= 1;
       else if (((|last_data[15: 8]) && !sop_pos[0])      || 
                 (|last_data[ 7: 0])) rxi_in_packet <= 0;

end

always @ (*)
begin
if (out_valid == 1'b0)
        words_valid = 2'b00;
else
        case ({sop_pos, pre_dout_eop})
        // no sop or eop
        {2'b00, 2'b00}:     words_valid = rxi_in_packet ? 2'b11 : 2'b00 ;
        // sop only
        {2'b10, 2'b00}:     words_valid = rxi_in_packet ? 2'b11 : 2'b11 ;
        {2'b01, 2'b00}:     words_valid = rxi_in_packet ? 2'b01 : 2'b01 ;
        // eop only
        {2'b00, 2'b10}:     words_valid = rxi_in_packet ? 2'b10 : 2'b00 ;
        {2'b00, 2'b01}:     words_valid = rxi_in_packet ? 2'b11 : 2'b00 ;
        // sop in front of eop
        {2'b10, 2'b01}:     words_valid = rxi_in_packet ? 2'b11 : 2'b11 ;
        // eop in front of sop
        {2'b01, 2'b10}:     words_valid = rxi_in_packet ? 2'b11 : 2'b01 ;
        // the case sop == eop
        default:            words_valid = rxi_in_packet ? 2'b00 : 2'b00 ;
        endcase
end


//    assign rx_mii_start = preamble_pos;
   reg temp = 1'b0;
   
   always @(posedge clk)
     begin
        if (temp == 1'b1)
          begin
             temp <= 1'd0;
          end
        else
          begin
             if (mii_in_valid)
               begin
                  if (preamble_pos == 2'b01)
                    begin
                       temp <= 1'b1;
                    end
                  else
                    begin
                       temp <= 1'b0;
                    end
               end // if (mii_in_valid)
             else
               begin
                  temp <= 1'b0;
               end // else: !if(mii_in_valid)
          end // else: !if(temp == 1'b1)
     end // always @ (posedge clk)

   always @(posedge clk)
         begin
        if (temp == 1'b1)
          begin
             rx_mii_start <= 2'b10;
          end
        else
          begin
             if (mii_in_valid)
               begin
                  if (preamble_pos == 2'b01)
                    begin
                       rx_mii_start <= 2'b00;
                    end
                  else
                    begin
                       rx_mii_start <= {1'b0,preamble_pos[1]};
                    end
               end // if (mii_in_valid)
             else
               begin
                  rx_mii_start <= 2'd0;
               end // else: !if(mii_in_valid)
          end // else: !if(temp == 1'b1)
         end // always @ (posedge clk)
   
   
                
   
 // ________________________________________________
 //    create a pre-aligned data-bus
 // ________________________________________________
    reg unaligned_dout_valid;
    reg [WORDS*64-1:0] unaligned_dout_d;
    reg [WORDS*8-1:0]  unaligned_dout_c;
    reg [WORDS-1:0]    unaligned_dout_sop;
    reg [WORDS-1:0]    unaligned_dout_eop;
    reg [WORDS*3-1:0]  unaligned_dout_eop_empty;
    reg [WORDS-1:0]    unaligned_dout_idle;
    reg                unaligned_rxi_in_packet;
  
    wire aligned_dout_valid;
    wire [WORDS*64-1:0] aligned_dout_d;
    wire [WORDS*8-1:0]  aligned_dout_c;
    wire [WORDS-1:0]    aligned_dout_sop;
    wire [WORDS-1:0]    aligned_dout_eop;
    wire [WORDS*3-1:0]  aligned_dout_eop_empty;
    wire [WORDS-1:0]    aligned_dout_idle;
    
    always @(posedge clk) begin
       unaligned_dout_valid             <= out_valid;
       unaligned_dout_d                 <= data_out;
       unaligned_dout_c                 <= ctl_out;
       unaligned_dout_sop               <= sop_pos & {WORDS{out_valid}} & words_valid; 
       unaligned_dout_eop               <= pre_dout_eop & {WORDS{out_valid}} & words_valid; 
       unaligned_dout_eop_empty[2:0]  <= {3{|last_data[7:0]}} & encode8to3(last_data[7:0]) & {3{words_valid[0]}}; 
       unaligned_dout_eop_empty[5:3]  <= {3{|last_data[15:8]}} & encode8to3(last_data[15:8]) & {3{words_valid[1]}}; 
       unaligned_dout_idle              <= ~words_valid | {WORDS{~out_valid}};
         unaligned_rxi_in_packet        <= rxi_in_packet;
    end

 generate 
   if (SYNOPT_ALIGN_FCSEOP==1) begin
      localparam STALL_WIDTH = 1+WORDS*64+WORDS*8+WORDS+WORDS+WORDS*3+WORDS+1;
      wire [STALL_WIDTH-1:0] stall_out;
      wire [STALL_WIDTH-1:0] stall_data; 
      wire aligned_rxi_in_packet;
      assign stall_data = {unaligned_dout_valid,unaligned_dout_d,unaligned_dout_c,unaligned_dout_sop,unaligned_dout_eop,unaligned_dout_eop_empty,unaligned_dout_idle, unaligned_rxi_in_packet};
      assign              {aligned_dout_valid, aligned_dout_d, aligned_dout_c, aligned_dout_sop, aligned_dout_eop, aligned_dout_eop_empty, aligned_dout_idle, aligned_rxi_in_packet} = stall_out;

      delay_mlab #(
        .WIDTH(STALL_WIDTH),
        .LATENCY(10), // minimum of 2, maximum of 33 for s5, 32 for s4
        .TARGET_CHIP(TARGET_CHIP), // 1 S4, 2 S5
        .FRACTURE(1)   // duplicate the addressing

       )datalag(
        .clk(clk),
        .din(stall_data),
        .dout(stall_out)
      );

      always @(posedge clk) begin
         dout_valid_int     <= aligned_dout_valid;
         dout_d_int         <= aligned_dout_d;
         dout_c_int         <= aligned_dout_c;
         dout_sop_int       <= aligned_dout_sop;
         dout_eop_int       <= aligned_dout_eop;
         dout_eop_empty_int <= aligned_dout_eop_empty; 
         dout_idle_int      <= aligned_dout_idle;
         dout_rxi_in_packet_int <= aligned_rxi_in_packet;
      end

      // synthesis translate_off
      always @(posedge clk) begin
         if (rx_pcs_fully_aligned && dout_valid && dout_eop && !rx_fcs_valid) $display("%t: ERROR : dout_eop=1 && rx_fcs_valid=0", $time);
         if (rx_pcs_fully_aligned && dout_valid && !dout_eop && rx_fcs_valid) $display("%t: ERROR : dout_eop=0 && rx_fcs_valid=1", $time);
      end
      // synthesis translate_on

   alt_aeu_40_mac_chk_pkt #(
      .SYNOPT_PREAMBLE_PASS(SYNOPT_PREAMBLE_PASS),
      .WORDS(WORDS)
   )cp(
      .clk(clk),
      .in_fcs_error(fcs_error),
      .in_fcs_valid(fcs_valid),
      .in_rxi_in_packet(dout_rxi_in_packet_int), 
      .in_ctl(dout_c_int),
      .in_data(dout_d_int),
      .in_valid(dout_valid_int),
      .in_sop(dout_sop_int),
      .in_eop(dout_eop_int),
      .in_eop_empty(dout_eop_empty_int),
      .in_idle(dout_idle_int),
      .out_fcs_error(rx_fcs_error_chk),
      .out_fcs_valid(rx_fcs_valid_chk),
      .out_ctl(dout_c_chk),
      .out_data(dout_d_chk),
      .out_valid(dout_valid_chk),
      .out_sop(dout_sop_chk),
      .out_eop(dout_eop_chk),
      .out_eop_empty(dout_eop_empty_chk),
      .out_idle(dout_idle_chk),
      .out_rx_mii_err(rx_mii_err_chk)
   );

      localparam STALL_WIDTH_CHK = 1+128+16+2+2+6+2+1+2;
      wire [STALL_WIDTH_CHK-1:0] chk_stall_out;
      wire [STALL_WIDTH_CHK-1:0] chk_stall_data = {2'b0,dout_valid_chk, dout_d_chk, dout_c_chk, dout_sop_chk,
                                           dout_eop_chk, dout_eop_empty_chk, dout_idle_chk, rx_mii_err_chk};

      wire         chk_aligned_dout_valid;
      wire [127:0] chk_aligned_dout_d;
      wire [15:0]  chk_aligned_dout_c;
      wire [1:0]   chk_aligned_dout_sop;
      wire [1:0]   chk_aligned_dout_eop;
      wire [5:0]  chk_aligned_dout_eop_empty;
      wire [1:0]   chk_aligned_dout_idle;
      wire         chk_aligned_rx_mii_err;

      delay_mlab #(
        .WIDTH(STALL_WIDTH_CHK),
        .LATENCY(12), // minimum of 2, maximum of 33 for s5, 32 for s4
        .TARGET_CHIP(TARGET_CHIP), // 1 S4, 2 S5
        .FRACTURE(1)   // duplicate the addressing

       )datalag_chk(
        .clk(clk),
        .din(chk_stall_data),
        .dout(chk_stall_out)
      );
      assign {chk_aligned_dout_valid, chk_aligned_dout_d, chk_aligned_dout_c, chk_aligned_dout_sop, chk_aligned_dout_eop, chk_aligned_dout_eop_empty, chk_aligned_dout_idle, chk_aligned_rx_mii_err} = chk_stall_out[157:0];

      always @(posedge clk) begin
         dout_valid     <= chk_aligned_dout_valid;
         dout_d         <= chk_aligned_dout_d;
         dout_c         <= chk_aligned_dout_c;
         dout_sop       <= chk_aligned_dout_sop;
         dout_eop       <= chk_aligned_dout_eop;
         dout_eop_empty <= chk_aligned_dout_eop_empty; 
         dout_idle      <= chk_aligned_dout_idle;
         rx_mii_err     <= chk_aligned_rx_mii_err;
      end

   end
   else begin
      always @(*) begin
         dout_valid             =  unaligned_dout_valid;
         dout_d                 =  unaligned_dout_d;
         dout_c                 =  unaligned_dout_c;
         dout_sop               =  unaligned_dout_sop;
         dout_eop               =  unaligned_dout_eop;
         dout_eop_empty         =  unaligned_dout_eop_empty;
         dout_idle              =  unaligned_dout_idle;
      end
      assign rx_fcs_error_chk   = fcs_error; 
      assign rx_fcs_valid_chk   = fcs_valid; 
      assign dout_c_chk         = dout_c_int; 
      assign dout_d_chk         = dout_d_int; 
      assign dout_valid_chk     = dout_valid_int; 
      assign dout_sop_chk       = dout_sop_int; 
      assign dout_eop_chk       = dout_eop_int; 
      assign dout_eop_empty_chk = dout_eop_empty_int; 
      assign dout_idle_chk      = dout_idle_int; 
      assign rx_mii_err_chk     = 1'b0; 
   end
endgenerate

 // _________________________________________________________________
 //     rx csr register module
 // _________________________________________________________________
   localparam CSRADDRSIZE = 8;

   wire cfg_enable_txoff;
   wire cfg_fwd_pframes;
   wire[47:0] cfg_dst_address;
   wire[15:0] cfg_max_fsize;
   wire cfg_pld_length_chk         ;
   wire cfg_pld_length_include_vlan;
   wire cfg_cntena_fcs_error       ;
   wire cfg_cntena_oversize_error  ;
   wire cfg_cntena_undersize_error ;
   wire cfg_cntena_pldlength_error ;
   wire cfg_cntena_phylink_error   ;
   wire out_fcs_error;
   wire out_fcs_valid;
   wire [ERRORBITWIDTH-1:0] out_rx_error;

   wire serif_mac_dout , serif_stats_dout;
   assign serif_slave_dout = serif_mac_dout & serif_stats_dout;
   alt_aeu_40_mac_rx_csr #(
         .BASE                  (BASE_RXMAC)
        ,.REVID                 (REVID)
        ,.ADDRSIZE              (CSRADDRSIZE) 
        ,.TARGET_CHIP (TARGET_CHIP)
   ) macrx_csr(
         .reset_csr             (reset_csr) //this input has not logic connect to it
        ,.clk_csr               (clk_csr)
        ,.clk_rx                (clk)
        ,.reset_rx              (reset_rx)  //this input has not logic connect to it
        ,.serif_master_din      (serif_slave_din)
        ,.serif_slave_dout      (serif_mac_dout)

        ,.remote_fault_status   (remote_fault_status)
        ,.local_fault_status    (local_fault_status)
        ,.cfg_fwd_pframes       (cfg_fwd_pframes)
        ,.cfg_pld_length_chk    (cfg_pld_length_chk)
        ,.cfg_pld_length_include_vlan   (cfg_pld_length_include_vlan)         
        ,.cfg_cntena_phylink_error      (cfg_cntena_phylink_error)
        ,.cfg_cntena_oversize_error     (cfg_cntena_oversize_error)
        ,.cfg_cntena_undersize_error    (cfg_cntena_undersize_error)
        ,.cfg_cntena_pldlength_error    (cfg_cntena_pldlength_error)
        ,.cfg_cntena_fcs_error          (cfg_cntena_fcs_error)
        ,.cfg_dst_address       (cfg_dst_address)
        ,.cfg_max_fsize         (cfg_max_fsize)
        ,.cfg_enable_txoff      (cfg_enable_txoff)
        ,.cfg_keep_rx_crc       (cfg_keep_rx_crc)
        );


 // _________________________________________________________________
 //     rx statistics 
 // _________________________________________________________________

reg [11:0] fcs_error_pipe;
reg [11:0] fcs_valid_pipe;

always @(posedge clk) fcs_error_pipe <= {fcs_error_pipe[10:0], rx_fcs_error_chk}; 
always @(posedge clk) fcs_valid_pipe <= {fcs_valid_pipe[10:0], rx_fcs_valid_chk}; 

 generate if ((SYNOPT_RXSTATS == 1) || (SYNOPT_RXHPROC == 1))
    begin: rxhproc
        // _________________________________________________________________
        //      header processor
        // _________________________________________________________________
          alt_aeu_40_hproc_2  #(
                .WORDS                          (WORDS) 
               ,.SYNOPT_PREAMBLE_PASS           (SYNOPT_PREAMBLE_PASS)
               ,.ERRORBITWIDTH                  (ERRORBITWIDTH)
               ,.STATSBITWIDTH                  (STATSBITWIDTH)
          )hdr_proc     (
                 .clk                           (clk)
                ,.reset                         (reset_rx) //connect to alt_aeu_dform internal logic
                                             
                ,.cfg_crc_included              (cfg_keep_rx_crc)
                ,.cfg_max_frm_length            (cfg_max_fsize)
                ,.cfg_pld_length_chk            (cfg_pld_length_chk)
                ,.cfg_pld_length_include_vlan   (cfg_pld_length_include_vlan)    
                ,.cfg_cntena_phylink_error      (cfg_cntena_phylink_error)
                ,.cfg_cntena_oversize_error     (cfg_cntena_oversize_error)
                ,.cfg_cntena_undersize_error    (cfg_cntena_undersize_error)
                ,.cfg_cntena_pldlength_error    (cfg_cntena_pldlength_error)
                ,.cfg_cntena_fcs_error          (cfg_cntena_fcs_error)
        
                ,.in_dp_phyready                (rx_pcs_fully_aligned)
                ,.in_dp_valid                   (dout_valid_chk)
                ,.in_dp_ctrl                    (dout_c_chk)
                ,.in_dp_idle                    (dout_idle_chk)
                ,.in_dp_sop                     (dout_sop_chk)
                ,.in_dp_eop                     (dout_eop_chk)
                ,.in_dp_data                    (dout_d_chk)
                ,.in_dp_eop_empty               (dout_eop_empty_chk)
                                                
                ,.in_dpfcs_error                (SYNOPT_ALIGN_FCSEOP ? fcs_error_pipe[10] : rx_fcs_error_chk)
                ,.in_dpfcs_valid                (SYNOPT_ALIGN_FCSEOP ? fcs_valid_pipe[10] : rx_fcs_valid_chk)
                ,.in_dp_phyerror                (1'b0) //placeholder
                ,.out_dpfcs_error               (out_fcs_error)
                ,.out_dpfcs_valid               (out_fcs_valid)
        
                ,.out_counts_valid              (rx_inc_octetsOK_valid)
                ,.out_counts                    (rx_inc_octetsOK)
                ,.out_dp_stats                  (out_rx_stats)
                ,.out_dp_error                  (out_rx_error)
                ,.out_rx_ctrl_sfc               (out_rx_ctrl_sfc)   
                ,.out_rx_ctrl_pfc               (out_rx_ctrl_pfc)  
                ,.out_rx_ctrl_other             (out_rx_ctrl_other) 
                );

    end
    else begin:nostats_hp
        assign out_rx_stats = 0;
        assign out_rx_error = 0;
        assign rx_inc_octetsOK= 0;
        assign rx_inc_octetsOK_valid = 1'b0;
        assign out_fcs_error= fcs_error;
        assign out_fcs_valid= fcs_valid;
    end
 endgenerate
  
 generate if (SYNOPT_RXSTATS == 1)
    begin: rxstats
         // _________________________________________________________________
         //     the stats collection module
         // _________________________________________________________________
          alt_aeu_40_stats_reg #(
                .BASE                           (BASE_RXSTAT)  
               ,.REVID                          (REVID)
               ,.NUMSTATS                       (STATSBITWIDTH) 
               ,.TARGET_CHIP                    (TARGET_CHIP)  
          ) statsreg    (
                .clk                            (clk)
               ,.reset                          (rst_stats)   //use global reset instead of ~rx_online, internal it has syncer 
               ,.clk_csr                        (clk_csr)
               ,.reset_csr                      (reset_csr)   //this input has not logic connect to it
               ,.in_counts                      (rx_inc_octetsOK)
               ,.in_stats                       (out_rx_stats)
               ,.serif_master_dout              (serif_slave_din)
               ,.serif_slave_dout               (serif_stats_dout)
        );
 
 end else 
    begin:nostats
        assign serif_stats_dout = 1'b1;
    end
 endgenerate

 assign rx_fcs_error = out_fcs_error; 
 assign rx_fcs_valid = out_fcs_valid;

 // _______________________________________________________
 //     Link Fault SIgnalling Module
 // _______________________________________________________
 // 
   generate if (EN_LINK_FAULT) 
      begin
           alt_aeu_40_mac_link_fault_det link_fault 
           (
                .clk                    (clk),
                .rstn                   (~gbl_rst_sync_rxd),  //use global reset instead of ~rx_online
                .ena                    (mii_in_valid),
                .mii_data_in            (mii_data_in),
                .mii_ctl_in             (mii_ctl_in),
                .remote_fault_status    (remote_fault_status),
                .local_fault_status     (local_fault_status)
            ); 
        end
   else begin
            assign remote_fault_status = 1'b0;
            assign local_fault_status = 1'b0;
        end
   endgenerate

 localparam BIT_OVERSIZE               = 18;
 localparam BIT_RNT                    = 26;
 localparam BIT_PLERR                  = 30;

 assign rx_error[0] = rx_mii_err;                 // PHY error
 assign rx_error[1] = rx_fcs_error;               // FCS error
 assign rx_error[2] = out_rx_stats[BIT_RNT];      // Undersize
 assign rx_error[3] = out_rx_stats[BIT_OVERSIZE]; // Oversize
 assign rx_error[4] = out_rx_stats[BIT_PLERR];    // Length error
 assign rx_error[5] = 1'b0;                       // Overflow
   
 assign rx_status[0] = out_rx_ctrl_sfc;      
 assign rx_status[1] = out_rx_ctrl_pfc;      
 assign rx_status[2] = out_rx_ctrl_other;    

endmodule // alt_aeu_40_mac_rx_2


