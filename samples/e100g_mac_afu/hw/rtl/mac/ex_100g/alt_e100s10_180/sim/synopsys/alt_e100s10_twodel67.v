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




`timescale 1ps/1ps

// DESCRIPTION
// Two way multiplexed delay. 67 bit wide.
// Modified from one of Gregg's toys.   Share And Enjoy.

module alt_e100s10_twodel67 #(
    parameter SIM_EMULATE = 1'b0
) (
    input clk,
    input din_phase,
    //input dout_phase,
    input din_valid,
    input din_sclr,
    input [1:0] din_fallback,
    input [66:0] din,
    output [66:0] dout
);

reg phase_w = 1'b0 /* synthesis preserve_syn_only */;
always @(posedge clk) phase_w <= din_phase;

reg sclr_r = 1'b0 /* synthesis preserve_syn_only */;
always @(posedge clk) sclr_r <= din_sclr;

/////////////////////////////////
// little write pointer counter
wire [3:0] wptr;
alt_e100s10_cnt4ic ct0 (
    .clk(clk),
    .sclr(sclr_r),
    .inc(phase_w),
    .dout(wptr)
);
defparam ct0 .SIM_EMULATE = SIM_EMULATE;

//wire [3:0] rptr;
//alt_e100s10_cnt4i ct3 (
//    .clk(clk),
//    .inc(phase_r),
//    .dout(rptr)
//);
//defparam ct3 .SIM_EMULATE = SIM_EMULATE;

/////////////////////////////////
// two read offsets
wire [3:0] rptr0;
alt_e100s10_cnt4cd ct1 (
    .clk(clk),
    .dec(din_fallback[0]),
    .sclr(sclr_r),
    .dout(rptr0)
);
defparam ct1 .SIM_EMULATE = SIM_EMULATE;

wire [3:0] rptr1;
alt_e100s10_cnt4cd ct2 (
    .clk(clk),
    .dec(din_fallback[1]),
    .sclr(sclr_r),
    .dout(rptr1)
);
defparam ct2 .SIM_EMULATE = SIM_EMULATE;

/////////////////////////////////
// make offsets relative to write
wire [3:0] rsum0;
wire [3:0] rsum1;
alt_e100s10_add4t1 ad0 (
    .clk(clk),
    .dina(wptr),
    .dinb(rptr0),
    .dout(rsum0)
);
defparam ad0 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_add4t1 ad1 (
    .clk(clk),
    .dina(wptr),
    .dinb(rptr1),
    .dout(rsum1)
);
defparam ad1 .SIM_EMULATE = SIM_EMULATE;

/////////////////////////////////
// combine the read pointer
wire [4:0] rptr_mix;
alt_e100s10_mux2w5t1s1 mx0 (
    .clk(clk),
    .din({1'b1,rsum1,1'b0,rsum0}),
    .sel(phase_w),
    .dout(rptr_mix)
);
defparam mx0 .SIM_EMULATE = SIM_EMULATE;

/////////////////////////////////
// storage
wire [66:0] dout_w;
alt_e100s10_mlab67a5r1w1 m0 (
    .rclk(clk),
    .wclk(clk),
    .wena(din_valid),           
    .waddr({din_phase,wptr}),
    .din(din),
    .raddr(rptr_mix),
    .dout(dout_w)
);
defparam m0 .SIM_EMULATE = SIM_EMULATE;


reg [66:0] dout_r ;
always @(posedge clk) dout_r <= dout_w;
assign dout = dout_r;
endmodule

