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

// S10 100G Word Aligner
// Faisal Khan
// 11/02/2016

module alt_e100s10_walign #(
    parameter   SIM_EMULATE = 1'b0
)(
    input                   clk,
    input                   reset,
    input   [2:0]           schd,
    input   [14*5-1:0]      din,
    input   [4:0]           din_hv,
    input                   din_valid,

    input                   sticky_err_clr,
    output                  lock,
    output  [4:0]           locked_lanes,
    output  [4:0]           sticky_err,
    output  [14*5-1:0]      dout,
    output  [4:0]           dout_hv,
    output                  dout_valid,
    output                  ready,
    output                  purge_align
);


// mlabs for word delay
genvar i;
wire    [14*5-1:0]  dout_wd;
wire    [4:0]       dout_hv_wd;
wire    [4:0]       dout_valid_wd;  // clean the valid
wire    [5*3-1:0]   blk_delay;
generate
    for (i=0; i<5; i=i+1) begin: dlb
        alt_e100s10_wdelay  wdly (
            .clk        (clk),
            .delta      (blk_delay[i*3+:3]),
            .din        ({din[14*i+:14], din_hv[i]}),
            .din_valid  (din_valid),
            .dout       ({dout_wd[14*i+:14], dout_hv_wd[i]}),
            .dout_valid (dout_valid_wd[i])

        );
        defparam wdly .SIM_EMULATE = SIM_EMULATE;
    end
endgenerate


// 13/14-bit hybrid barrel shifter
wire    [14*5-1:0]  dout_bt;
wire    [4:0]       dout_hv_bt;
wire    [5*4-1:0]   bshift;
wire    [5*2-1:0]   din_mon;
wire    [4:0]       dout_valid_bt;
wire                any_valid;
generate
    for (i=0; i<5; i=i+1) begin: bsh
        alt_e100s10_bshft  bshft (
            .clk        (clk),
            .shft       (bshift[4*i+:4]),
            .din        (dout_wd[14*i+:14]),
            .din_hv     (dout_hv_wd[i]),
            .din_valid  (dout_valid_wd[i]),
            .dout       (dout_bt[14*i+:14]),
            .dout_hv    (dout_hv_bt[i]),
            .dout_valid (dout_valid_bt[i])
        );

        assign din_mon[i*2+:2] = dout_bt[14*i+:2];
    end
endgenerate

reg [2:0] schd_d1;
always @(posedge clk) schd_d1 <= schd;

reg         reset_i;
generate
if (SIM_EMULATE == 1'b1) begin : RI
    initial begin   reset_i = 1'b0; end
end
endgenerate

always @(posedge clk)   reset_i <=  reset;

// monitor and control logic
wire    [7*5-1:0] delay;
alt_e100s10_wamon  mon (
    .clk            (clk),
    .reset          (reset_i),
    .din            (din_mon),
    .any_valid      (dout_valid_bt[0]),
    .schd           (schd_d1),         // implicitly aligned
    .delay          (delay),
    .walock         (lock),
    .locked_lanes   (locked_lanes),
    .sticky_err     (sticky_err),
    .sticky_err_clr (sticky_err_clr),
    .ready          (ready),
    .purge_align    (purge_align)
);
defparam    mon .SIM_EMULATE = SIM_EMULATE;

generate
    for (i=0; i<5; i=i+1) begin: asgn
        assign bshift[i*4+:4]      = delay[i*7+:4];
        assign blk_delay[i*3+:3]  = delay[(i*7+4)+:3]; 
    end
endgenerate

assign  dout = dout_bt;
assign  dout_hv = dout_hv_bt;
assign  dout_valid = dout_valid_bt[0];

endmodule
// BENCHMARK INFO : Date : Thu Mar  2 14:42:48 2017
// BENCHMARK INFO : Quartus version : /tools/acdskit/17.0/241/linux64/quartus/bin
// BENCHMARK INFO : benchmark P4 version: 18 
// BENCHMARK INFO : benchmark path: /data/fkhan/work/s100/walign
// BENCHMARK INFO : Number of LUT levels: Max 2.0 LUTs   Average 0.70
// BENCHMARK INFO : Number of Fitter seeds : 1
// BENCHMARK INFO : Device: 1SG280LU3F50I3VG
// BENCHMARK INFO : ALM usage: 372 (excluding ALMs used by virtual I/O pins)
// BENCHMARK INFO : Combinational ALUT usage: 395
// BENCHMARK INFO : Fitter seed 1000: Worst setup slack @ 450 MHz : 0.501 ns, From mon|rdata[12], To mon|wd_delay[2]~RTM_5_LAB_RE_X80_Y98_N0_I31_dff 
// BENCHMARK INFO : Elapsed benchmark time: 611.6 seconds
