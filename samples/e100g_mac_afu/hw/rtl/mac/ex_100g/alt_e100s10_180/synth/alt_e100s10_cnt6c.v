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
// 6 bit counter.
// Generated by one of Gregg's toys.   Share And Enjoy.

module alt_e100s10_cnt6c #(
    parameter SIM_EMULATE = 1'b0
) (
    input clk,
    input sclr,
    output [5:0] dout
);

wire [5:0] dout_w;

alt_e100s10_lut6 t0 (
    .din({6'h0 | dout }),
    .dout(dout_w[0])
);
defparam t0 .MASK = 64'h5555555555555555;
defparam t0 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_lut6 t1 (
    .din({6'h0 | dout }),
    .dout(dout_w[1])
);
defparam t1 .MASK = 64'h6666666666666666;
defparam t1 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_lut6 t2 (
    .din({6'h0 | dout }),
    .dout(dout_w[2])
);
defparam t2 .MASK = 64'h7878787878787878;
defparam t2 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_lut6 t3 (
    .din({6'h0 | dout }),
    .dout(dout_w[3])
);
defparam t3 .MASK = 64'h7f807f807f807f80;
defparam t3 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_lut6 t4 (
    .din({6'h0 | dout }),
    .dout(dout_w[4])
);
defparam t4 .MASK = 64'h7fff80007fff8000;
defparam t4 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_lut6 t5 (
    .din({6'h0 | dout }),
    .dout(dout_w[5])
);
defparam t5 .MASK = 64'h7fffffff80000000;
defparam t5 .SIM_EMULATE = SIM_EMULATE;

// hypothetical problem - this is state info and should really be don't replicate
alt_e100s10_hw_reg r0 (
	.clk(clk),
	.arst(1'b0),
	.d(dout_w),
	.ena(1'b1),
	.sclr(sclr),
	.sload(1'b0),
	.sdata({6{1'b1}}),
	.q(dout)
);
defparam r0 .WIDTH = 6;
defparam r0 .SIM_EMULATE = SIM_EMULATE;

endmodule

