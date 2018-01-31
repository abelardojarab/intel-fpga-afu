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


// (C) 2001-2014 Altera Corporation. All rights reserved.
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

`timescale 1 ps / 1 ps
// baeckler - 08-20-2012

// set_instance_assignment -name VIRTUAL_PIN ON -to din_d
// set_instance_assignment -name VIRTUAL_PIN ON -to din_c
// set_instance_assignment -name VIRTUAL_PIN ON -to dout


module alt_aeu_40_tx_pcs_2 #(
    parameter TARGET_CHIP = 2,
    parameter SYNOPT_PTP = 0,
    parameter PTP_LATENCY = 52, // even number only. For odd number, some logic need to be implemented
    parameter EN_LINK_FAULT = 0,
    parameter WORDS = 2, // no override
    parameter AM_CNT_BITS = 14,
    parameter REDUCE_CRC_LAT = 1'b1,  // assume faster TX CRC
    parameter CREATE_TX_SKEW = 1'b0
)(
    input clk,
    input sclr,
    
    input [WORDS*64-1:0] din_d, 
    input [WORDS*8-1:0] din_c, 
    output din_am,  // this din_d/c will be replaced with align markers
    output pre_din_am, // advance warning
    input tx_crc_ins_en,
        
    output [40*4-1:0] dout, // lsbit first serial streams
    output dout_valid,
    output [WORDS-1:0] tx_mii_start,
    
    output [66*4-1:0] dout_66, // for fec
    output reg [3:0] dout_66_valid = 4'b0101
);

genvar i;

////////////////////////////////////////////////////
// keep track of where we are in the cycle

reg [5:0] cnt = 0;
always @(posedge clk) begin
    if (sclr) cnt <= 6'h0;
    else begin
        if (cnt == 6'd39) cnt <= 6'h0;
        else cnt <= cnt + 1'b1;
    end
end

wire shft_w;
wys_lut w0 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(shft_w));
defparam w0 .MASK = 64'h000000efbdf7defb;
defparam w0 .TARGET_CHIP = TARGET_CHIP;

reg shft = 1'b0;
always @(posedge clk) shft <= shft_w;

// which vlane of the 2 way set will din_d/din_c launch on?
reg din_d_vlane=1'b0;
always @(posedge clk) begin
    if (sclr) din_d_vlane <= 1'b0;
    else din_d_vlane <= ~din_d_vlane;
end

// how many words are out per vlane?
reg [AM_CNT_BITS-1:0] words_out = 0;
always @(posedge clk) begin
    if (din_d_vlane == 1'b1) words_out <= words_out + 1'b1;
end

// when to put in vlane tags, as viewed on din
reg last_am_msb = 1'b0;
reg prepare_am_ins = 1'b0;

reg [12:0] prepare_am_ins_plus = 13'b0;

      reg [PTP_LATENCY/2-1:0] ptp_pipe=0;
      always @(posedge clk) begin
         if (din_d_vlane == 1'h1) begin
                {ptp_pipe[PTP_LATENCY/2-1:0], prepare_am_ins_plus[12:0]} <= {ptp_pipe[(PTP_LATENCY/2)-2:0], prepare_am_ins_plus[12:0], prepare_am_ins};    
         end
      end

//
// NOTE : this ought to match the logic in e100_mac_tx_4_tb.sv
// 

always @(posedge clk) begin
    if (din_d_vlane == 1'b1) last_am_msb <= words_out[AM_CNT_BITS-1];
    if (din_d_vlane == 1'b1) prepare_am_ins <= words_out[AM_CNT_BITS-1] && !last_am_msb;
end

assign din_am = SYNOPT_PTP ? ptp_pipe[PTP_LATENCY/2-1] : prepare_am_ins_plus[12] ;
//assign din_am = prepare_am_ins_plus[12];

generate
   if (EN_LINK_FAULT) assign pre_din_am = prepare_am_ins_plus [!tx_crc_ins_en?  9: REDUCE_CRC_LAT ? 4 : 0]; // !REDUCE_CRC_LAT case not tested
   else               assign pre_din_am = prepare_am_ins_plus [!tx_crc_ins_en? 10: REDUCE_CRC_LAT ? 5 : 0]; // right for !REDUCE_CRC_LAT case
endgenerate

////////////////////////////////////////////////////
// mii->66 block encode

wire [2*66-1:0] din_e;

generate 
    for (i=0; i<WORDS; i=i+1) begin : e
        alt_aeu_40_sane_block_encode enc (
            .clk(clk), 
            .mii_txc(din_c[(i+1)*8-1:i*8]),
            .mii_txd(din_d[(i+1)*64-1:i*64]), // bit 0 first
            .encoded(din_e[(i+1)*66-1:i*66]),
	    .tx_mii_start(tx_mii_start[i])
        );
        defparam enc .TARGET_CHIP = TARGET_CHIP;
        defparam enc .MLAB_DELAY = 1'b1;
    end
endgenerate


wire din_e_am;
delay_regs dr1 (
    .clk(clk),
    .din(din_am),
    .dout(din_e_am)
);
defparam dr1 .WIDTH = 1;
defparam dr1 .LATENCY = 4;




////////////////////////////////////////////////////
// BEGIN simulation sanity check
// synthesis translate_off

wire [WORDS*64-1:0] rebuilt_d; 
wire [WORDS*8-1:0] rebuilt_c; 

sim_mii_decode_multiple chk (
    .clk(clk),
    .arst(1'b0),
    .ena(!din_e_am),
    .rx_fault_en(1'b0),
    .rx_test_en(1'b0),
    .hi_ber(1'b0),
    .align_status(1'b1),
    .rx_blocks(din_e), // bit 0 first
    .mii_rxc(rebuilt_c),
    .mii_rxd(rebuilt_d)        // bit 0 first    
);
defparam chk .NUM_BLOCKS = 2;

integer n = 0;
always @(posedge clk) begin
    for (n=0; n<WORDS*8; n=n+1) begin
        if (rebuilt_c[n] && (((rebuilt_d >> (8*n)) & 8'hff) == 8'hfe)) begin
            $display ("TX PCS is sending a MII error byte at time %d",$time);
        end
    end
end

// synthesis translate_on
// END simulation sanity check
////////////////////////////////////////////////////




////////////////////////////////////////////////////
// scrambler - framing bypass

wire [2*WORDS-1:0] enc_frame_lag;
wire [64*WORDS-1:0] enc_data;    
    
eth_unframe uf (
    .clk(clk),
    .din(din_e),
    .dout_frame_lag(enc_frame_lag),
    .dout_data(enc_data)    
);
defparam uf .WORDS = WORDS;
defparam uf .LATENCY = 1;

wire [WORDS*64-1:0] scram_data;
scrambler sc (
    .clk(clk),
    .srst(sclr),
    .ena(!din_e_am),
    .din(enc_data),        // bit 0 is to be sent first
    .dout(scram_data)
);
defparam sc .WIDTH = 2*64;
defparam sc .DEBUG_DONT_SCRAMBLE = 1'b0;

wire [WORDS*66-1:0] din_es;
eth_reframe rf (
    .din_data(scram_data),
    .din_frame(enc_frame_lag),
    .dout(din_es)    
);
defparam rf .WORDS = WORDS;

reg din_es_am = 1'b0;
always @(posedge clk) din_es_am <= din_e_am;

////////////////////////////////////////////////////
// vlane tag + bip

wire sclr_d;
delay_regs dr6 (
    .clk(clk),
    .din(sclr),
    .dout(sclr_d)
);
defparam dr6 .WIDTH = 1;
defparam dr6 .LATENCY = 1;

wire [WORDS*66-1:0] din_est;
generate 
    for (i=0; i<WORDS; i=i+1) begin : tl
        alt_aeu_40_tx_tagger_2way et (
            .clk(clk),
            .sclr(sclr_d),  // this will regulate the order the tags are used in the TX round robin
            .din(din_es[(i+1)*66-1:i*66]),
            .am_insert(din_es_am),  // discard the din, insert alignment
            .dout(din_est[(i+1)*66-1:i*66])
        );
        defparam et .VLANE_SET = i;
        defparam et .TARGET_CHIP = TARGET_CHIP;
    end
endgenerate

// for 100g 
// the launch order of TX tags, in the low byte of din_est, needs to look like
// 05 d5 81 71 11
// for vlanes 0,4,8,12,16
// not a rotation of that.

// for 40g
// the launch order of TX tags, in the low byte of din_est, needs to look like
// 41 15    (0x90 = 1001_0000____01 = 10___0100_0001) 
// for vlanes 0,2
// c1 89 
// for vlanes 1,3

////////////////////////////////////////////////////
// stripe for transmission

// synthesis translate_off
// debug monitor for framing-ish words (A,~A)leaving
wire [31:0] op_cmp = din_est[33:2] ^ din_est[65:34];
wire opposite = &op_cmp;
// synthesis translate_on

generate 
    for (i=0; i<WORDS; i=i+1) begin : st
        alt_aeu_40_stripe_2way s2 (
            .clk(clk),
            .shft(shft),
            .din(din_est[(i+1)*66-1:i*66]), // lsbit first, words 0..1 cyclic
            .cnt(cnt),
            .dout(dout[(i+1)*2*40-1:i*2*40]) // lsbit first, words 1..0 parallel
        );
        defparam s2 .TARGET_CHIP = TARGET_CHIP;
        defparam s2 .CREATE_TX_SKEW = CREATE_TX_SKEW;
        defparam s2 .GB_NUMBER = i;
        
        assign dout_66[(i+1)*2*66-1:i*2*66] = {2{din_est[(i+1)*66-1:i*66]}};
    end
endgenerate

assign dout_valid = shft;

always @(posedge clk) begin
    if (sclr) dout_66_valid <= 4'b0101;
    else dout_66_valid <= ~dout_66_valid;
end


// synthesis translate_off

// for easy debugging
wire [64-1:0] din_d0;
wire [64-1:0] din_d1;
assign din_d0 = din_d[63:0];
assign din_d1 = din_d[127:64];
wire [66-1:0] din_e0;
wire [66-1:0] din_e1;
assign din_e0 = din_e[65:0];
assign din_e1 = din_e[131:66];
wire [66-1:0] din_est0;
wire [66-1:0] din_est1;
assign din_est1 = din_est[131:66];
assign din_est0 = din_est[65:0];
wire [40-1:0] dout0;
wire [40-1:0] dout1;
wire [40-1:0] dout2;
wire [40-1:0] dout3;
assign dout0 = dout[39:0];
assign dout1 = dout[79:40];
assign dout2 = dout[119:80];
assign dout3 = dout[159:120];
// synthesis translate_on

endmodule
