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


// cnt 00 : in 40 to make 40  no
// cnt 01 : in 40 to make 80  out 66 os 24
// cnt 02 : in 40 to make 54  no
// cnt 03 : in 40 to make 94  out 66 os 10
// cnt 04 : to make 28  no
// cnt 05 : in 40 to make 68  out 66 os 36
// cnt 06 : in 40 to make 42  no
// cnt 07 : in 40 to make 82  out 66 os 22
// cnt 08 : in 40 to make 56  no
// cnt 09 : in 40 to make 96  out 66 os 8
// cnt 0a : to make 30  no
// cnt 0b : in 40 to make 70  out 66 os 34
// cnt 0c : in 40 to make 44  no
// cnt 0d : in 40 to make 84  out 66 os 20
// cnt 0e : in 40 to make 58  no
// cnt 0f : in 40 to make 98  out 66 os 6
// cnt 10 : to make 32  no
// cnt 11 : in 40 to make 72  out 66 os 32
// cnt 12 : in 40 to make 46  no
// cnt 13 : in 40 to make 86  out 66 os 18
// cnt 14 : in 40 to make 60  no
// cnt 15 : in 40 to make 100  out 66 os 4
// cnt 16 : to make 34  no
// cnt 17 : in 40 to make 74  out 66 os 30
// cnt 18 : in 40 to make 48  no
// cnt 19 : in 40 to make 88  out 66 os 16
// cnt 1a : in 40 to make 62  no
// cnt 1b : in 40 to make 102  out 66 os 2
// cnt 1c : to make 36  no
// cnt 1d : in 40 to make 76  out 66 os 28
// cnt 1e : in 40 to make 50  no
// cnt 1f : in 40 to make 90  out 66 os 14
// cnt 20 : in 40 to make 64  no
// cnt 21 : in 40 to make 104  out 66 os 0
// cnt 22 : to make 38  no
// cnt 23 : in 40 to make 78  out 66 os 26
// cnt 24 : in 40 to make 52  no
// cnt 25 : in 40 to make 92  out 66 os 12
// cnt 26 : to make 26  no
// cnt 27 : in 40 to make 66  out 66 os 38


// shft mask 000000bbefbefbef
// bump mask 0000008000020820
// out  mask 0000005555555555
// out0 mask 0000001111111111
// out1 mask 0000004141414141
// out2 mask 0000005141000414
// out3 mask 0000001045104104
// out4 mask 0000000000041041


module alt_aeu_40_gb_40_66_x2 #(
    parameter TARGET_CHIP = 2,
    parameter PRE_TICKS = 6
)(
    input clk,
    input [5:0] cnt,
    input [40*2-1:0] din,
    output din_req,
    output pre_din_req,
    output reg [65:0] dout = 66'b0,
    output dout_zero
);
reg shft_req = 1'b0, bump = 1'b0, shft = 1'b0, out = 1'b0, pre_shft_req = 1'b0;
reg [4:0] os = 5'b0;

///////////////////////////////////
// control schedule 

wire bump_w;
wys_lut w0 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(bump_w));
defparam w0 .MASK = 64'h0000008000020820;
defparam w0 .TARGET_CHIP = TARGET_CHIP;

wire shft_w;
wys_lut w1 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(shft_w));
defparam w1 .MASK = 64'h000000bbefbefbef;
defparam w1 .TARGET_CHIP = TARGET_CHIP;

wire shft_req_w;
wys_lut w2 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(shft_req_w));
defparam w2 .MASK = 64'h000000ddf7df7df7;
defparam w2 .TARGET_CHIP = TARGET_CHIP;

wire os0_w;
wys_lut w3 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(os0_w));
defparam w3 .MASK = 64'h0000001111111111;
defparam w3 .TARGET_CHIP = TARGET_CHIP;

wire os1_w;
wys_lut w4 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(os1_w));
defparam w4 .MASK = 64'h0000004141414141;
defparam w4 .TARGET_CHIP = TARGET_CHIP;

wire os2_w;
wys_lut w5 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(os2_w));
defparam w5 .MASK = 64'h0000005141000414;
defparam w5 .TARGET_CHIP = TARGET_CHIP;

wire os3_w;
wys_lut w6 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(os3_w));
defparam w6 .MASK = 64'h0000001045104104;
defparam w6 .TARGET_CHIP = TARGET_CHIP;

wire os4_w;
wys_lut w7 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(os4_w));
defparam w7 .MASK = 64'h0000000000041041;
defparam w7 .TARGET_CHIP = TARGET_CHIP;

wire out_w;
wys_lut w8 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(out_w));
defparam w8 .MASK = 64'h0000005555555555;
defparam w8 .TARGET_CHIP = TARGET_CHIP;

wire pre_shft_req_w;
localparam PRE_SHIFT_MASK = 40'hddf7df7df7; // 40bit for further right rotation-early
wys_lut w9 (.a(cnt[0]),.b(cnt[1]),.c(cnt[2]),.d(cnt[3]),.e(cnt[4]),.f(cnt[5]),.out(pre_shft_req_w));
defparam w9 .MASK = 64'h0 | {PRE_SHIFT_MASK[PRE_TICKS-1:0],PRE_SHIFT_MASK[39:PRE_TICKS]};
defparam w9 .TARGET_CHIP = TARGET_CHIP;

always @(posedge clk) begin
    bump <= bump_w;
    shft <= shft_w;
    shft_req <= shft_req_w;
    pre_shft_req <= pre_shft_req_w;
    os[0] <= os0_w;
    os[1] <= os1_w;
    os[2] <= os2_w;
    os[3] <= os3_w;
    os[4] <= os4_w;
    out <= out_w;
end

assign din_req = shft_req;
assign pre_din_req = pre_shft_req;
reg [66*2-1:0] dout_i = 0;

/////////////////////////////////////////////////////

reg [103:0] storage0 = 104'h0;
always @(posedge clk) begin
    case ({shft,bump})
       2'b00: storage0 <= storage0;
       2'b01: storage0 <= {storage0[103:72],storage0[103:32]};
       2'b10: storage0 <= {din[1*40-1:0*40],storage0[103:40]};
       2'b11: storage0 <= {din[1*40-1:0*40+8],din[1*40-1:0*40],storage0[103:72]};
    endcase
end

always @(posedge clk) begin
  if (out) begin
    case (os[3:0])
        4'd0 : dout_i[1*66-1:0*66] <= storage0[65:0];
        4'd1 : dout_i[1*66-1:0*66] <= storage0[67:2];
        4'd2 : dout_i[1*66-1:0*66] <= storage0[69:4];
        4'd3 : dout_i[1*66-1:0*66] <= storage0[71:6];
        4'd4 : dout_i[1*66-1:0*66] <= storage0[73:8];
        4'd5 : dout_i[1*66-1:0*66] <= storage0[75:10];
        4'd6 : dout_i[1*66-1:0*66] <= storage0[77:12];
        4'd7 : dout_i[1*66-1:0*66] <= storage0[79:14];
        4'd8 : dout_i[1*66-1:0*66] <= storage0[81:16];
        4'd9 : dout_i[1*66-1:0*66] <= storage0[83:18];
        4'd10 : dout_i[1*66-1:0*66] <= storage0[85:20];
        4'd11 : dout_i[1*66-1:0*66] <= storage0[87:22];
        4'd12 : dout_i[1*66-1:0*66] <= storage0[89:24];
        4'd13 : dout_i[1*66-1:0*66] <= storage0[91:26];
        4'd14 : dout_i[1*66-1:0*66] <= storage0[93:28];
        4'd15 : dout_i[1*66-1:0*66] <= storage0[95:30];
    endcase
  end
end

/////////////////////////////////////////////////////

reg [103:0] storage1 = 104'h0;
always @(posedge clk) begin
    case ({shft,bump})
       2'b00: storage1 <= storage1;
       2'b01: storage1 <= {storage1[103:72],storage1[103:32]};
       2'b10: storage1 <= {din[2*40-1:1*40],storage1[103:40]};
       2'b11: storage1 <= {din[2*40-1:1*40+8],din[2*40-1:1*40],storage1[103:72]};
    endcase
end

always @(posedge clk) begin
  if (out) begin
    case (os[3:0])
        4'd0 : dout_i[2*66-1:1*66] <= storage1[65:0];
        4'd1 : dout_i[2*66-1:1*66] <= storage1[67:2];
        4'd2 : dout_i[2*66-1:1*66] <= storage1[69:4];
        4'd3 : dout_i[2*66-1:1*66] <= storage1[71:6];
        4'd4 : dout_i[2*66-1:1*66] <= storage1[73:8];
        4'd5 : dout_i[2*66-1:1*66] <= storage1[75:10];
        4'd6 : dout_i[2*66-1:1*66] <= storage1[77:12];
        4'd7 : dout_i[2*66-1:1*66] <= storage1[79:14];
        4'd8 : dout_i[2*66-1:1*66] <= storage1[81:16];
        4'd9 : dout_i[2*66-1:1*66] <= storage1[83:18];
        4'd10 : dout_i[2*66-1:1*66] <= storage1[85:20];
        4'd11 : dout_i[2*66-1:1*66] <= storage1[87:22];
        4'd12 : dout_i[2*66-1:1*66] <= storage1[89:24];
        4'd13 : dout_i[2*66-1:1*66] <= storage1[91:26];
        4'd14 : dout_i[2*66-1:1*66] <= storage1[93:28];
        4'd15 : dout_i[2*66-1:1*66] <= storage1[95:30];
    endcase
  end
end

reg osel = 0;
always @(posedge clk) begin
    if (out) osel <= 1'b0;
    else osel <= ~osel;
end

always @(posedge clk) dout <= osel ? dout_i[131:66] : dout_i[65:0];

reg dz = 1'b0;
always @(posedge clk) dz <= (osel == 1'b0);
assign dout_zero = dz;

endmodule

