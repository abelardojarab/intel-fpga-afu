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


`timescale 1 ps / 1 ps
// outputs 33 times 40 bits times 2 lanes = 40 words every 40 cycles

// shift enable mask is 000000efbdf7defb

/////////////////////////////////  overall schedule
// cntr 00 phase 0 52 52  : load pipe 0 shl 52
// (hiccup)
// cntr 01 phase 1 118 52  : load pipe 1 shl 52
// cntr 02 phase 0 78 78  : load pipe 0 shl 78
// cntr 03 phase 1 104 38  : load pipe 1 shl 38
// cntr 04 phase 0 64 64  : load pipe 0 shl 64
// cntr 05 phase 1 90 24  : load pipe 1 shl 24
// cntr 06 phase 0 50 50  : load pipe 0 shl 50
// (hiccup)
// cntr 07 phase 1 116 50  : load pipe 1 shl 50
// cntr 08 phase 0 76 76  : load pipe 0 shl 76
// cntr 09 phase 1 102 36  : load pipe 1 shl 36
// cntr 0a phase 0 62 62  : load pipe 0 shl 62
// cntr 0b phase 1 88 22  : load pipe 1 shl 22
// (hiccup)
// cntr 0c phase 0 88 88  : load pipe 0 shl 88
// cntr 0d phase 1 114 48  : load pipe 1 shl 48
// cntr 0e phase 0 74 74  : load pipe 0 shl 74
// cntr 0f phase 1 100 34  : load pipe 1 shl 34
// cntr 10 phase 0 60 60  : load pipe 0 shl 60
// cntr 11 phase 1 86 20  : load pipe 1 shl 20
// (hiccup)
// cntr 12 phase 0 86 86  : load pipe 0 shl 86
// cntr 13 phase 1 112 46  : load pipe 1 shl 46
// cntr 14 phase 0 72 72  : load pipe 0 shl 72
// cntr 15 phase 1 98 32  : load pipe 1 shl 32
// cntr 16 phase 0 58 58  : load pipe 0 shl 58
// cntr 17 phase 1 84 18  : load pipe 1 shl 18
// (hiccup)
// cntr 18 phase 0 84 84  : load pipe 0 shl 84
// cntr 19 phase 1 110 44  : load pipe 1 shl 44
// cntr 1a phase 0 70 70  : load pipe 0 shl 70
// cntr 1b phase 1 96 30  : load pipe 1 shl 30
// cntr 1c phase 0 56 56  : load pipe 0 shl 56
// (hiccup)
// cntr 1d phase 1 122 56  : load pipe 1 shl 56
// cntr 1e phase 0 82 82  : load pipe 0 shl 82
// cntr 1f phase 1 108 42  : load pipe 1 shl 42
// cntr 20 phase 0 68 68  : load pipe 0 shl 68
// cntr 21 phase 1 94 28  : load pipe 1 shl 28
// cntr 22 phase 0 54 54  : load pipe 0 shl 54
// (hiccup)
// cntr 23 phase 1 120 54  : load pipe 1 shl 54
// cntr 24 phase 0 80 80  : load pipe 0 shl 80
// cntr 25 phase 1 106 40  : load pipe 1 shl 40
// cntr 26 phase 0 66 66  : load pipe 0 shl 66
// cntr 27 phase 1 92 26  : load pipe 1 shl 26

module alt_aeu_40_stripe_2way #(
    parameter TARGET_CHIP = 2,
    parameter CREATE_TX_SKEW = 1'b0,
    parameter GB_NUMBER = 0
)(
    input clk,
    input shft,
    input [65:0] din, // lsbit first, words 0..4 cyclic
    input [5:0] cnt,
    output [40*2-1:0] dout // lsbit first, words 0..4 parallel
);

reg [4:0] ld_pos = 5'b0;

reg [66+14-1:0] din_shl = 0;
wire [66+46-1:0] din_sh32 = {din_shl,32'b0};
wire [66+46-1:0] din_sh16 = {16'b0,din_shl,16'b0};
wire [66+46-1:0] din_ns = {32'b0,din_shl};

always @(posedge clk) begin
  case (ld_pos[2:0])
    3'b000 : din_shl <= {14'b0,din};
    3'b001 : din_shl <= {12'b0,din,2'b0};
    3'b010 : din_shl <= {10'b0,din,4'b0};
    3'b011 : din_shl <= {8'b0,din,6'b0};
    3'b100 : din_shl <= {6'b0,din,8'b0};
    3'b101 : din_shl <= {4'b0,din,10'b0};
    3'b110 : din_shl <= {2'b0,din,12'b0};
    3'b111 : din_shl <= {din,14'b0};
  endcase
end


///////////////////////////////////
// phase 0

shifter_40ge_gbx s0 (
    .clk(clk),
    .din_sh32(din_sh32),
    .din_sh16(din_sh16),
    .din_ns(din_ns),
    .shft(shft),
    .ld_pos2(ld_pos[4:3]),
    .cnt(cnt),
    .dout(dout[1*40-1:0*40])
);
defparam s0 .TARGET_CHIP = TARGET_CHIP;
defparam s0 .MAX_SHL = 88;
defparam s0 .LD_MASK = 64'h0000005555555555;
defparam s0 .ADD_SKEW = CREATE_TX_SKEW ? GB_NUMBER*3+1 : 0;
// defparam s0 .MIN_SHL = 50;
// defparam s0 .S0_MASK = 64'h0000008888888888;
// defparam s0 .S1_MASK = 64'h0000000a0a0a0a0a;
// defparam s0 .S2_MASK = 64'h000000080020a28a;
// defparam s0 .S3_MASK = 64'h0000005104104104;
// defparam s0 .S4_MASK = 64'h0000000041041000;

///////////////////////////////////
// phase 1

shifter_40ge_gbx s1 (
    .clk(clk),
    .din_sh32(din_sh32),
    .din_sh16(din_sh16),
    .din_ns(din_ns),
    .shft(shft),
    .ld_pos2(ld_pos[4:3]),
    .cnt(cnt),
    .dout(dout[2*40-1:1*40])
);
defparam s1 .TARGET_CHIP = TARGET_CHIP;
defparam s1 .MAX_SHL = 56;
defparam s1 .LD_MASK = 64'h000000aaaaaaaaaa;
defparam s1 .ADD_SKEW = CREATE_TX_SKEW ? GB_NUMBER*3+2 : 0;
// defparam s1 .MIN_SHL = 18;
// defparam s1 .S0_MASK = 64'h0000001111111111;
// defparam s1 .S1_MASK = 64'h0000001414141414;
// defparam s1 .S2_MASK = 64'h0000004145141000;
// defparam s1 .S3_MASK = 64'h000000208208a208;
// defparam s1 .S4_MASK = 64'h0000000820000082;



///////////////////////////////////
// din shifter schedule 

wire [4:0] ld_pos_w;
wys_lut w4 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(ld_pos_w[4]));
defparam w4 .MASK = 64'h0000000861041082;
defparam w4 .TARGET_CHIP = TARGET_CHIP;

wys_lut w3 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(ld_pos_w[3]));
defparam w3 .MASK = 64'h000000718618e30c;
defparam w3 .TARGET_CHIP = TARGET_CHIP;

wys_lut w2 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(ld_pos_w[2]));
defparam w2 .MASK = 64'h000000494534b28a;
defparam w2 .TARGET_CHIP = TARGET_CHIP;

wys_lut w1 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(ld_pos_w[1]));
defparam w1 .MASK = 64'h0000001e1e1e1e1e;
defparam w1 .TARGET_CHIP = TARGET_CHIP;

wys_lut w0 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(ld_pos_w[0]));
defparam w0 .MASK = 64'h0000009999999999;
defparam w0 .TARGET_CHIP = TARGET_CHIP;

always @(posedge clk) ld_pos <= ld_pos_w;

endmodule

// max_distance= 38

