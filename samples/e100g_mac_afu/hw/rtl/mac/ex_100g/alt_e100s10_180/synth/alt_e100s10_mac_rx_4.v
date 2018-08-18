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


// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.

// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/mac/alt_e100s10_mac_rx_4.v#29 $
// $Revision: #29 $
// $Date: 2013/10/31 $
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


module alt_e100s10_mac_rx_4 #(
    parameter SIM_EMULATE = 0,
    parameter TARGET_CHIP = 2, 
    parameter SYNOPT_ALIGN_FCSEOP = 1, 
                // 0: no alignment
                // 1: align at custom & avalon interface. additional 11 cycle latency in packet to align
                // 2: align at avalon interface, no extra latency
    parameter REVID = 32'h08092017,
    parameter BASE_RXMAC = 5,
    parameter EN_LINK_FAULT = 1, 
    parameter SYNOPT_PREAMBLE_PASS = 1, 
    parameter WORDS = 4, // no override   
    parameter REDUCE_CRC_LAT = 1'b1,   // lower CRC latency (at expense of timing)
    parameter SYNOPT_STRICT_SOP = 0,    // UNH SFD compliance feature                       
    parameter CSRADDRSIZE = 8
)(
    input wire clk,
    input wire reset_rx, //from ~rx_online, //this input has not logic connect to it
 
    // raw CGMII stream in
    input wire rx_pcs_fully_aligned,
    input [9:0] mii_in_valid,
    input [WORDS*64-1:0] mii_data_in,  // read bytes left to right
    input [WORDS*8-1:0] mii_ctl_in,    // read bits left to right

    // annotated output
    output out_valid,
    output [WORDS*64-1:0] data_out,  // read bytes left to right
    output [WORDS*8-1:0] ctl_out,    // read bits left to right
    output [WORDS-1:0] first_data,  // word contains the first non-preamble data of a frame
    output [WORDS*8-1:0] last_data, // byte contains the last data before FCS
    
    // lagged (N) cycles from the non-zero last_data output
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
  
    input  wire reset_csr,  // global reset, async, no domain
    input  wire clk_csr,    // 100 MHz

    //output wire serif_slave_dout,
    //input  wire serif_slave_din,
    input  wire               write,
    input  wire               read,
    input  wire [CSRADDRSIZE-1:0]address,
    input  wire [31:0]        writedata,
    output wire [31:0]        readdata,
    output wire               readdatavalid,

    output          rx_crc_pt,
    output [41:0]	rx_stats,
    output		rx_stats_valid,
    output [5:0]	rx_error,
//  output [2:0]  rx_stats_error,

    output reg [WORDS-1:0] rx_mii_start
);

localparam BYTES = WORDS * 8;

//wire                drop_sfderr_pkt;     // UNH
   
reg [WORDS-1:0]     dout_eeop;

reg   rx_mii_err;
wire  cfg_keep_rx_crc;

reg  keep_rx_crc_0 = 0;
reg  keep_rx_crc   = 0;
always @(posedge clk) keep_rx_crc_0 <= cfg_keep_rx_crc;
always @(posedge clk) keep_rx_crc   <= keep_rx_crc_0;
reg fcs_error; initial fcs_error = 0;
reg fcs_error_a; initial fcs_error_a = 0;
reg fcs_valid; initial fcs_valid = 0;
reg fcs_valid_a; initial fcs_valid_a = 0;
reg [3:0] words_valid;

wire out_rxfcs_valid, out_err_rx_fcs;
wire out_rx_ctrl_other;      //  From alt_e100s10_hproc_4
wire out_rx_ctrl_pfc;        //  From alt_e100s10_hproc_4
wire out_rx_ctrl_sfc;        //  From alt_e100s10_hproc_4
   
generate
   if (EN_LINK_FAULT) begin
      alt_e100s10_mac_link_fault_det link_fault
         (.clk(clk),
          .rstn(~reset_rx),  // global reset 
          .ena(mii_in_valid[0]),
          .mii_data_in(mii_data_in),
          .mii_ctl_in(mii_ctl_in),
          .remote_fault_status(remote_fault_status),
          .local_fault_status(local_fault_status)
         ); 
   end
   else begin
        assign remote_fault_status = 1'b0;
        assign local_fault_status = 1'b0;
   end
endgenerate

wire annot_valid;
wire [255:0] annot;
wire [31:0] annot_ctl;
wire [255:0] next_annot;
wire [3:0]   annot_sop; // preamble word
wire [31:0]   annot_last_byte; // last CRC byte location
wire [31:0]   annot_last_dbyte; // last data byte location
wire [3:0]   annot_eop;  // last FCS data
wire [3:0]   annot_deop;  // last data byte before FCS
wire [3:0]   annot_eeop;  // error indication
wire [11:0]   annot_mty; // number of empty bytes in eop word 0..7
wire [11:0]   annot_dmty; // number of empty bytes in eop word 0..7
wire [3:0]   annot_prb;

alt_e100s10_readmii4 rdm0 (
        .clk(clk),
        .sclr(reset_rx),
        .keep_rx_crc(keep_rx_crc),
        .din_valid(mii_in_valid[9:1]),
        .din_d(mii_data_in),
        .din_c(mii_ctl_in),
        .dout_valid(annot_valid),
        .dout(annot),
        .next_dout(next_annot),
        .dout_ctl(annot_ctl),
        .dout_prb(annot_prb),
        .dout_sop(annot_sop),
        .dout_last_byte(annot_last_byte),
        .dout_last_dbyte(annot_last_dbyte),
        .dout_eop(annot_eop),
        .dout_eeop(annot_eeop),
        .cfg_sfd_det_on(cfg_sfd_det_on),
        .cfg_preamble_det_on(cfg_premable_det_on),
        .dout_mty(annot_mty)
);
defparam rdm0 .SIM_EMULATE = SIM_EMULATE;
defparam rdm0 .SYNOPT_STRICT_SOP = SYNOPT_STRICT_SOP;

genvar i;
wire [255:0] din;
wire [255:0] next_din;
wire [WORDS-1:0] din_first_data;
wire [BYTES-1:0] din_last_data;
wire [BYTES-1:0] din_last_data_b4crc;
reg [BYTES-1:0] prev_din_last_data_b4crc;
wire [3:0] preamble_pos;
wire [3:0] pre_dout_eop;
wire [11:0] pre_dout_eop_empty;
wire [3:0] pre_dout_eeop;
wire [31:0] ctl;
wire        din_valid;

assign din = annot;
assign next_din = next_annot;
assign din_first_data = annot_sop;
assign din_last_data = keep_rx_crc ? annot_last_byte : annot_last_dbyte;
assign din_last_data_b4crc = annot_last_dbyte;
assign preamble_pos = annot_prb;
assign pre_dout_eop = annot_eop;
assign pre_dout_eop_empty = annot_mty;
assign pre_dout_eeop = annot_eeop;
assign ctl = annot_ctl;
assign din_valid = annot_valid;

always @(posedge clk) begin
    if (din_valid) begin
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

reg [4:0] fcs_idx = 0;
always @(posedge clk) begin
    fcs_idx[4] <= |(din_last_data_b4crc & 32'h0000ffff);
    fcs_idx[3] <= |(din_last_data_b4crc & 32'h00ff00ff);
    fcs_idx[2] <= |(din_last_data_b4crc & 32'h0f0f0f0f);
    fcs_idx[1] <= |(din_last_data_b4crc & 32'h33333333);
    fcs_idx[0] <= |(din_last_data_b4crc & 32'h55555555);
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
    case (fcs_idx[4:3])
        2'b00 : tmp_fcs2 <= tmp_fcs;
        2'b01 : tmp_fcs2 <= tmp_fcs << 8*8;
        2'b10 : tmp_fcs2 <= tmp_fcs << 16*8;
        2'b11 : tmp_fcs2 <= tmp_fcs << 24*8;        
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
defparam dr5 .LATENCY = REDUCE_CRC_LAT ? 7 : 11;
defparam dr5 .FRACTURE = 4;


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

reg [255:0] ecrc_din = 0;
reg         ecrc_din_valid = 0;
reg [3:0]   ecrc_din_first_data = 0;
reg [31:0]  ecrc_din_last_data = 0;

always @(posedge clk) begin
        if (din_valid) begin
                ecrc_din <= din & ~din_blank_mask;
                ecrc_din_first_data <= din_first_data;
                ecrc_din_last_data <= din_last_data_b4crc & {{8{words_valid[3]}}, {8{words_valid[2]}}, {8{words_valid[1]}}, {8{words_valid[0]}}};
        end
        ecrc_din_valid <= din_valid;
end

ecrc_4 fcs (
    .clk(clk),
    
    .din_valid(ecrc_din_valid),
    .din (ecrc_din),
    .din_first_data(ecrc_din_first_data),
    .din_last_data(ecrc_din_last_data),

    .crc_valid(crc_out_valid),
    .crc_out(crc_out)   
);
defparam fcs .TARGET_CHIP = TARGET_CHIP;
defparam fcs .REDUCE_LATENCY = REDUCE_CRC_LAT;

wire pipe_crc;
delay_regs dr6 (
        .clk(clk),
        .din(keep_rx_crc && din_valid && (|din_last_data_b4crc[3:0]) && words_valid[0]),
        .dout(pipe_crc)
);
defparam dr6 .LATENCY = REDUCE_CRC_LAT ? 12 : 16;
defparam dr6 .WIDTH = 1;

reg last_is_data_eop=0;
always @(posedge clk) last_is_data_eop <= keep_rx_crc && din_valid & (|din_last_data_b4crc[3:0]) && words_valid[0];

wire pipe4enable;
delay_regs dr7 (
        .clk(clk),
        .din(!din_valid && last_is_data_eop),
        .dout(pipe4enable)
);
defparam dr7 .LATENCY = REDUCE_CRC_LAT ? 11 : 15;
defparam dr7 .WIDTH = 1;

/////////////////////////////////////
// CRC comparator
/////////////////////////////////////

reg [7:0] crc_chk = 0;
reg crc_chk_valid=0;
generate
    for (i=0; i<8; i=i+1) begin : chk
        always @(posedge clk) begin
            crc_chk [i] <= |(crc_out[(i+1)*4-1:i*4] ^ expect_crc[(i+1)*4-1:i*4]);
        end
    end
endgenerate

reg pipe_crc_r=0;
reg pipe4enable_r=0;
reg [4:0] fcs_valid_buf=0;
reg [4:0] fcs_error_buf=0;
reg [4:0] pipe4enable_buf=0;

always @(posedge clk) begin
       pipe_crc_r <= pipe_crc;
       crc_chk_valid <= crc_out_valid;
       fcs_error_a <= |crc_chk;
       fcs_valid_a <= crc_chk_valid;
       pipe4enable_r <= pipe4enable;
       fcs_valid_buf <= {fcs_valid_buf[3:0], fcs_valid_a};
       fcs_error_buf <= {fcs_error_buf[3:0], fcs_error_a};
       pipe4enable_buf <= {pipe4enable_buf[3:0], pipe4enable_r};

       fcs_error   <= pipe_crc ? 1'b0 : pipe_crc_r ? (pipe4enable_r ? 1'b0: fcs_error_a) : pipe4enable_buf[4] ? fcs_error_buf[4] : |crc_chk;
       fcs_valid   <= pipe_crc ? 1'b0 : pipe_crc_r ? (pipe4enable_r ? 1'b0: fcs_valid_a) : pipe4enable_buf[4] ? fcs_valid_buf[4] : crc_chk_valid;
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
wire [3:0] sop_pos;


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

reg rxi_in_packet = 1'b0;
assign sop_pos = SYNOPT_PREAMBLE_PASS ? preamble_pos : first_data ;    

always @(posedge clk)
begin
       if (reset_rx) rxi_in_packet <= 0;
       else begin
            if (din_valid) begin
                if ((sop_pos[3] && (~(|last_data[23:0]))) ||
                    (sop_pos[2] && (~(|last_data[15:0]))) ||
                    (sop_pos[1] && (~(|last_data[ 7:0]))) ||
                     sop_pos[0]) rxi_in_packet <= 1;
                else if (((|last_data[31:24]) && !(|sop_pos[2:0])) ||
                    ((|last_data[23:16]) && !(|sop_pos[1:0])) || 
                    ((|last_data[15: 8]) && !sop_pos[0])      || 
                    (|last_data[ 7: 0])) rxi_in_packet <= 0;
            end
       end
end

always @ (*)
begin
if (out_valid == 1'b0)
        words_valid = 4'b0000;
else
        case ({sop_pos, pre_dout_eop})
        // no sop or eop
        {4'b0000, 4'b0000}:     words_valid = rxi_in_packet ? 4'b1111 : 4'b0000 ;
        // sop only
        {4'b1000, 4'b0000}:     words_valid = rxi_in_packet ? 4'b1111 : 4'b1111 ;
        {4'b0100, 4'b0000}:     words_valid = rxi_in_packet ? 4'b0111 : 4'b0111 ;
        {4'b0010, 4'b0000}:     words_valid = rxi_in_packet ? 4'b0011 : 4'b0011 ;
        {4'b0001, 4'b0000}:     words_valid = rxi_in_packet ? 4'b0001 : 4'b0001 ;
        // eop only
        {4'b0000, 4'b1000}:     words_valid = rxi_in_packet ? 4'b1000 : 4'b0000 ;
        {4'b0000, 4'b0100}:     words_valid = rxi_in_packet ? 4'b1100 : 4'b0000 ;
        {4'b0000, 4'b0010}:     words_valid = rxi_in_packet ? 4'b1110 : 4'b0000 ;
        {4'b0000, 4'b0001}:     words_valid = rxi_in_packet ? 4'b1111 : 4'b0000 ;
        // sop in front of eop
        {4'b1000, 4'b0100}:     words_valid = rxi_in_packet ? 4'b1100 : 4'b1100 ;
        {4'b1000, 4'b0010}:     words_valid = rxi_in_packet ? 4'b1110 : 4'b1110 ;
        {4'b1000, 4'b0001}:     words_valid = rxi_in_packet ? 4'b1111 : 4'b1111 ;
        {4'b0100, 4'b0010}:     words_valid = rxi_in_packet ? 4'b0110 : 4'b0110 ;
        {4'b0100, 4'b0001}:     words_valid = rxi_in_packet ? 4'b0111 : 4'b0111 ;
        {4'b0010, 4'b0001}:     words_valid = rxi_in_packet ? 4'b0011 : 4'b0011 ;
        // eop in front of sop
        {4'b0100, 4'b1000}:     words_valid = rxi_in_packet ? 4'b1111 : 4'b0111 ;
        {4'b0010, 4'b1000}:     words_valid = rxi_in_packet ? 4'b1011 : 4'b0011 ;
        {4'b0001, 4'b1000}:     words_valid = rxi_in_packet ? 4'b1001 : 4'b0001 ;
        {4'b0010, 4'b0100}:     words_valid = rxi_in_packet ? 4'b1111 : 4'b0011 ;
        {4'b0001, 4'b0100}:     words_valid = rxi_in_packet ? 4'b1101 : 4'b0001 ;
        {4'b0001, 4'b0010}:     words_valid = rxi_in_packet ? 4'b1111 : 4'b0001 ;
        // the case sop == eop
        default:                words_valid = rxi_in_packet ? 4'b0000 : 4'b0000 ;
        endcase

end


//assign rx_mii_start = preamble_pos;

   reg temp = 1'b0;
   
   always @(posedge clk)
     begin
        if (temp == 1'b1)
          begin
             rx_mii_start <= 4'b1000;
             temp <= 1'd0;
          end
        else
          begin
             if (mii_in_valid[0])
               begin
                  if (preamble_pos == 4'b0001)
                    begin
                       rx_mii_start <= 4'b0000;
                       temp <= 1'b1;
                    end
                  else
                    begin
                       rx_mii_start <= {1'b0,preamble_pos[3:1]};
                       temp <= 1'b0;
                    end
               end // if (mii_in_valid)
             else
               begin
                  rx_mii_start <= 4'd0;
                  temp <= 1'b0;
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
    reg [WORDS-1:0]    unaligned_dout_eeop;
    reg [WORDS*3-1:0]  unaligned_dout_eop_empty;
    reg [WORDS-1:0]    unaligned_dout_idle;
    reg                unaligned_rxi_in_packet;
  
      always @(posedge clk) begin
         unaligned_dout_valid           <= out_valid;
         unaligned_dout_d               <= data_out;
         unaligned_dout_c               <= ctl_out;
         unaligned_dout_sop             <= sop_pos & {4{out_valid}} & words_valid;      //UNH
         unaligned_dout_eop             <= pre_dout_eop & {4{out_valid}} & words_valid; //UNH
         unaligned_dout_eeop            <= pre_dout_eeop & {4{out_valid}} & words_valid; //UNH
         
         unaligned_dout_eop_empty[2:0]  <= {3{|last_data[7:0]}} & encode8to3(last_data[7:0]) &
                                           {3{pre_dout_eop[0]}} & {3{out_valid}} & {3{words_valid[0]}}; 
         unaligned_dout_eop_empty[5:3]  <= {3{|last_data[15:8]}} & encode8to3(last_data[15:8]) &
                                           {3{pre_dout_eop[1]}} & {3{out_valid}} & {3{words_valid[1]}}; 
         unaligned_dout_eop_empty[8:6]  <= {3{|last_data[23:16]}} & encode8to3(last_data[23:16]) &
                                           {3{pre_dout_eop[2]}} & {3{out_valid}} & {3{words_valid[2]}}; 
         unaligned_dout_eop_empty[11:9] <= {3{|last_data[31:24]}} & encode8to3(last_data[31:24]) & 
                                           {3{pre_dout_eop[3]}} & {3{out_valid}} & {3{words_valid[3]}}; 
         unaligned_dout_idle            <= ~words_valid | {4{~out_valid}};
         unaligned_rxi_in_packet        <= rxi_in_packet;
      end


      localparam STALL_WIDTH = 1+256+32+4+4+12+4+7;
      wire [STALL_WIDTH-1:0] stall_out;
      wire [STALL_WIDTH-1:0] stall_data = {2'b0,unaligned_dout_eeop, unaligned_dout_valid, unaligned_dout_d, unaligned_dout_c, unaligned_dout_sop,
                                          unaligned_dout_eop, unaligned_dout_eop_empty, unaligned_dout_idle, unaligned_rxi_in_packet};

      wire aligned_dout_valid;
      wire [255:0] aligned_dout_d;
      wire [31:0]  aligned_dout_c;
      wire [3:0]   aligned_dout_sop;
      wire [3:0]   aligned_dout_eop;
      wire [3:0]   aligned_dout_eeop;
      wire [11:0]  aligned_dout_eop_empty;
      wire [3:0]   aligned_dout_idle;
      wire         aligned_rxi_in_packet;

      delay_mlab #(
        .WIDTH(STALL_WIDTH),
        .LATENCY(15), // minimum of 2, maximum of 33 for s5, 32 for s4
        .TARGET_CHIP(TARGET_CHIP), // 1 S4, 2 S5
        .FRACTURE(10)   // duplicate the addressing

       )datalag(
        .clk(clk),
        .din(stall_data),
        .dout(stall_out)
      );
      assign {aligned_dout_eeop, aligned_dout_valid, aligned_dout_d, aligned_dout_c, aligned_dout_sop, aligned_dout_eop, aligned_dout_eop_empty, aligned_dout_idle, aligned_rxi_in_packet} = stall_out[317:0];
      // synthesis translate_off
      always @(posedge clk) begin
         if (rx_pcs_fully_aligned && dout_valid && dout_eop && !rx_fcs_valid) $display("%t: ERROR : dout_eop=1 && rx_fcs_valid=0", $time);
         if (rx_pcs_fully_aligned && dout_valid && !dout_eop && rx_fcs_valid) $display("%t: ERROR : dout_eop=0 && rx_fcs_valid=1", $time);
      end
      // synthesis translate_on

      always @(posedge clk) begin
         dout_valid     <= aligned_dout_valid;
         dout_d         <= aligned_dout_d;
         dout_c         <= aligned_dout_c;
         dout_sop       <= aligned_dout_sop;
         dout_eop       <= aligned_dout_eop;
         dout_eop_empty <= aligned_dout_eop_empty; 
         dout_idle      <= aligned_dout_idle;
         rx_mii_err     <= |aligned_dout_eeop;
      end

 // _________________________________
 //     rx csr register module
 // _________________________________________________________________

   wire cfg_pld_length_include_vlan;
   wire[15:0] cfg_max_fsize;

   alt_e100s10_mac_rx_csr #(
         .BASE                  (BASE_RXMAC)
        ,.REVID                 (REVID)
        ,.ADDRSIZE              (CSRADDRSIZE) 
        ,.TARGET_CHIP           (TARGET_CHIP) 
   ) macrx_csr(
         .reset_csr             (reset_csr)   //this input has not logic connect to it
        ,.clk_csr               (clk_csr)  
        ,.clk_rx                (clk)
        ,.reset_rx              (reset_rx) //this input has not logic connect to it

        ,.write                 (write)
        ,.read                  (read)
        ,.address               (address)
        ,.writedata             (writedata)
        ,.readdata              (readdata)
        ,.readdatavalid         (readdatavalid)

        ,.remote_fault_status   (remote_fault_status)
        ,.local_fault_status    (local_fault_status)
        ,.cfg_pld_length_include_vlan   (cfg_pld_length_include_vlan)
        ,.cfg_max_fsize         (cfg_max_fsize)
        ,.cfg_keep_rx_crc       (cfg_keep_rx_crc)
        ,.cfg_pld_length_sfd_det_on        (cfg_sfd_det_on     )  
        ,.cfg_pld_length_premable_det_on   (cfg_premable_det_on)
        );



//----------------------------------------
//---rx stats vector
//----------------------------------------
wire	[41:0]	rx_stats_d0;
wire		rx_stats_valid_d0;
wire	[2:0]	rx_stats_error_d0;
reg	[41:0]	rx_stats_d1, rx_stats_d2, rx_stats_d3, rx_stats_d4, rx_stats_d5, rx_stats_d6;
reg		rx_stats_valid_d1, rx_stats_valid_d2, rx_stats_valid_d3, rx_stats_valid_d4, rx_stats_valid_d5, rx_stats_valid_d6;
reg	[2:0]	rx_stats_error_d1, rx_stats_error_d2, rx_stats_error_d3, rx_stats_error_d4, rx_stats_error_d5, rx_stats_error_d6;
wire [2:0]  rx_stats_error;


reg [13:0] fcs_error_pipe;
reg [13:0] fcs_valid_pipe;

always @(posedge clk) fcs_error_pipe <= {fcs_error_pipe[12:0], fcs_error}; 
always @(posedge clk) fcs_valid_pipe <= {fcs_valid_pipe[12:0], fcs_valid}; 

// u_rx_stats has 10 cycle delay;
alt_e100s10_sv #(	.SIM_EMULATE 		(SIM_EMULATE),
			.SYNOPT_PREAMBLE_PT	(SYNOPT_PREAMBLE_PASS),
			.WORDS			(WORDS) )
   u_rx_stats_vector (
	.clk			(clk),
	.reset			(reset_rx),
   
	.cfg_crc_included	(cfg_keep_rx_crc),
	.cfg_max_frm_length	(cfg_max_fsize),
	.cfg_vlandet_disable	(cfg_pld_length_include_vlan),	// TBD linhua; (cfg_vlandet_disable),
     
	.frm_data		(unaligned_dout_d),
	.frm_sop		(unaligned_dout_sop),
	.frm_eop		(unaligned_dout_eop),
	.frm_valid		(unaligned_dout_valid),
	.frm_eop_empty		(unaligned_dout_eop_empty),
    
	.stats			(rx_stats_d0),
	.stats_valid		(rx_stats_valid_d0),
	.frm_error		(rx_stats_error_d0)
);

// data path has extra 3 cycle delay;
always @(posedge clk) begin
	{rx_stats_d6, rx_stats_d5, rx_stats_d4, rx_stats_d3, rx_stats_d2, rx_stats_d1} <= 
                {rx_stats_d5, rx_stats_d4, rx_stats_d3, rx_stats_d2, rx_stats_d1, rx_stats_d0};
	{rx_stats_valid_d6, rx_stats_valid_d5, rx_stats_valid_d4, rx_stats_valid_d3, rx_stats_valid_d2, rx_stats_valid_d1} <= 
                {rx_stats_valid_d5, rx_stats_valid_d4, rx_stats_valid_d3, rx_stats_valid_d2, rx_stats_valid_d1, rx_stats_valid_d0};
	{rx_stats_error_d6, rx_stats_error_d5, rx_stats_error_d4, rx_stats_error_d3, rx_stats_error_d2, rx_stats_error_d1} <= 
                {rx_stats_error_d5, rx_stats_error_d4, rx_stats_error_d3, rx_stats_error_d2, rx_stats_error_d1, rx_stats_error_d0};
end

assign rx_stats = rx_stats_d6;
assign rx_stats_valid = rx_stats_valid_d6;
assign rx_stats_error = rx_stats_error_d6;

 // _________________________________________________________________
  assign rx_fcs_valid = fcs_valid_pipe[3];
  assign rx_fcs_error = fcs_error_pipe[3];
 
 assign rx_error[0] = rx_mii_err;                 // PHY error
 assign rx_error[1] = rx_mii_err || fcs_error_pipe[3];	// FCS error
 assign rx_error[2] = rx_stats_error[0];	// Undersize 
 assign rx_error[3] = rx_stats_error[1];	// Oversize
 assign rx_error[4] = rx_stats_error[2];	// Length error
 assign rx_error[5] = 1'b0;

 assign rx_crc_pt = keep_rx_crc;

endmodule
