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



`timescale 1 ps / 1 ps

// DESCRIPTION
// 
// This is a 3 cell two tick WYSIWYG implementation of comparing a 10 bit number to a constant.
// 



// CONFIDENCE
// This is a small equality circuit.  Any problems should be easily spotted in simulation.
// 

module alt_e100s10_eq_10_const #(
        parameter TARGET_CHIP = 5,
        parameter VAL = 10'h1fe
)(
        input clk,
        input [9:0] din,
        output match
);

wire match0, match1;

alt_e100s10_lut6 w0 (
    .din        ({din[4:0],1'b0}),
    .dout       (match0)
);
defparam w0 .SIM_EMULATE = 1'b0;
defparam w0 .MASK = 64'h0 | (64'b1 << {VAL[4:0],1'b0});


alt_e100s10_lut6 w1 (
    .din        ({din[9:5],1'b0}),
    .dout       (match1)
);
defparam w1 .SIM_EMULATE = 1'b0;
defparam w1 .MASK = 64'h0 | (64'b1 << {VAL[9:5],1'b0});

/*alt_e100s10_wys_lut w0 (
        .a(1'b0),
        .b(din[0]),
        .c(din[1]),
        .d(din[2]),
        .e(din[3]),
        .f(din[4]),
        .out (match0)
);
defparam w0 .TARGET_CHIP = TARGET_CHIP;
defparam w0 .MASK = 64'h0 | (64'b1 << {VAL[4:0],1'b0});

alt_e100s10_wys_lut w1 (
        .a(1'b0),
        .b(din[5]),
        .c(din[6]),
        .d(din[7]),
        .e(din[8]),
        .f(din[9]),
        .out (match1)
);
defparam w1 .TARGET_CHIP = TARGET_CHIP;
defparam w1 .MASK = 64'h0 | (64'b1 << {VAL[9:5],1'b0});
*/


reg match0_r = 1'b0;
reg match1_r = 1'b0;
reg match_r = 1'b0;
always @(posedge clk) begin
        match0_r <= match0;
        match1_r <= match1;
        match_r <= match0_r & match1_r;
end
assign match = match_r;

endmodule



// BENCHMARK INFO :  10AX115U2F45I2SGE2
// BENCHMARK INFO :  Quartus II 64-Bit Version 15.1.0 Internal Build 58 04/28/2015 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  alt_eq_10_const.v
// BENCHMARK INFO :  Uses helper file :  alt_wys_lut.v
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 3
// BENCHMARK INFO :  Total pins : 12
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  3                  
// BENCHMARK INFO :  ALMs : 2 / 427,200 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.469 ns, From match_r, To match}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.461 ns, From match_r, To match}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.431 ns, From match_r, To match}
