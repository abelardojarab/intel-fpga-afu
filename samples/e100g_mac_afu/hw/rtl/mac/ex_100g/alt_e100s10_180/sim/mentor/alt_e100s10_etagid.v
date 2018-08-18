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
// Ethernet VLANE tag identifier.
// Faisal Khan

module alt_e100s10_etagid #(
    parameter SIM_EMULATE = 1'b0,
    parameter TAGID = 5'd0
) (
	input clk, 
        input [65:0] din,
	output dout_opp,  // latency 3
        output reg am,           // latency 4
        output  reg am_dsk,
	output [4:0] dout_tnum // latency 1
);

///////////////////////////////////
// proper tags are of the form A,~A 

alt_e100s10_opp33t3 op0 (
    .clk(clk),
    .dina({din[33:2],din[1]}),
    .dinb({din[65:34],din[0]}),
    .dout(dout_opp)
);

defparam op0 .SIM_EMULATE = SIM_EMULATE;


// 5-bit comparator
// tag number == AM_TAG?
reg [4:0] tnum;
alt_e100s10_eqc5hxxt1 eq (
    .clk    (clk),
    .din    (tnum),
    .dout   (am_i)
);
defparam    eq .SIM_EMULATE = SIM_EMULATE;
defparam    eq .MASK = 64'h0 | (1 << TAGID);

// classify the progreammed AM ping
reg am_c3;
reg [6:0] am_d;
always @(posedge clk) begin
    am_c3   <=  am_i;
    am      <=  am_c3 & dout_opp;
    am_d    <=  {am_d[5:0], am};
end

//wire am_st;
//alt_e100s10_pulse4 apulse ( 
//    .clk        (clk),
//    .din        (am_d[2]),
//    .dout       (am_st)
//);
//defparam    apulse .SIM_EMULATE = SIM_EMULATE;
always @(posedge clk) am_dsk <= |am_d[4:0] ;

reg [4:0] tnum_c2, tnum_c3;
always @(posedge clk ) begin
    tnum_c2 <=  tnum;
    tnum_c3 <=  tnum_c2;
end
assign  dout_tnum = tnum_c3;

///////////////////////////////////////////////////////
// assuming something is a tag, figure out which one

// using din[33:2] & 00c50500
wire [5:0] din_sel = {din[25],din[24],din[20],din[18],din[12],din[10]};

// tag  0 : 04
// tag  1 : 29
// tag  2 : 31
// tag  3 : 17
// tag  4 : 07
// tag  5 : 32
// tag  6 : 08
// tag  7 : 1b
// tag  8 : 1a
// tag  9 : 35
// tag 10 : 26
// tag 11 : 1d
// tag 12 : 21
// tag 13 : 2c
// tag 14 : 33
// tag 15 : 3e
// tag 16 : 19
// tag 17 : 2e
// tag 18 : 02
// tag 19 : 3c
// tag 20 : 1e  // vlane-0 for 40G
// tag 21 : 3a
// tag 22 : 27
// tag 23 : 0d

wire [4:0] tnum_w;
alt_e100s10_lut6 t0 (
    .din({6'h0 | din_sel}),
    .dout(tnum_w[0])
);
defparam t0 .MASK = 64'hfff5ff3db9fffe6b;
defparam t0 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_lut6 t1 (
    .din({6'h0 | din_sel}),
    .dout(tnum_w[1])
);
defparam t1 .MASK = 64'hfbdbadfdb9ffff6f;
defparam t1 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_lut6 t2 (
    .din({6'h0 | din_sel}),
    .dout(tnum_w[2])
);
defparam t2 .MASK = 64'hefddbdbfd97fffeb;
defparam t2 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_lut6 t3 (
    .din({6'h0 | din_sel}),
    .dout(tnum_w[3])
);
defparam t3 .MASK = 64'hebf9bd7fb57fde6b;
defparam t3 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_lut6 t4 (
    .din({6'h0 | din_sel}),
    .dout(tnum_w[4])
);
defparam t4 .MASK = 64'hbfd1edbdd37ffe6f;
defparam t4 .SIM_EMULATE = SIM_EMULATE;

always @(posedge clk) begin
    tnum <= tnum_w;
end

//assign dout_tnum = tnum;

endmodule

