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
// Equality compare of two 20 bit words.  Latency 3.
// Modified from Gregg's toys.   Share And Enjoy.

module alt_e100s10_eq20t3 #(
    parameter SIM_EMULATE = 1'b0
) (
    input clk,
    input [19:0] dina,
    input [19:0] dinb,
    output dout
);

wire [8:0] leaf;

alt_e100s10_eq3t1 eq0 (
    .clk(clk),
    .dina(dina[2:0]),
    .dinb(dinb[2:0]),
    .dout(leaf[0])
);

defparam eq0 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_eq3t1 eq1 (
    .clk(clk),
    .dina(dina[5:3]),
    .dinb(dinb[5:3]),
    .dout(leaf[1])
);

defparam eq1 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_eq3t1 eq2 (
    .clk(clk),
    .dina(dina[8:6]),
    .dinb(dinb[8:6]),
    .dout(leaf[2])
);

defparam eq2 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_eq3t1 eq3 (
    .clk(clk),
    .dina(dina[11:9]),
    .dinb(dinb[11:9]),
    .dout(leaf[3])
);

defparam eq3 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_eq3t1 eq4 (
    .clk(clk),
    .dina(dina[14:12]),
    .dinb(dinb[14:12]),
    .dout(leaf[4])
);

defparam eq4 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_eq3t1 eq5 (
    .clk(clk),
    .dina(dina[17:15]),
    .dinb(dinb[17:15]),
    .dout(leaf[5])
);

defparam eq5 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_eq2t1 eq6 (
    .clk(clk),
    .dina(dina[19:18]),
    .dinb(dinb[19:18]),
    .dout(leaf[6])
);

defparam eq6 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_and4t1 and0 (
    .clk(clk),
    .din(leaf[3:0]),
    .dout(leaf[7])
);
defparam and0 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_and3t1 and1 (
    .clk(clk),
    .din(leaf[6:4]),
    .dout(leaf[8])
);
defparam and1 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_and2t1 and2 (
    .clk(clk),
    .din(leaf[8:7]),
    .dout(dout)
);
defparam and2 .SIM_EMULATE = SIM_EMULATE;

endmodule

