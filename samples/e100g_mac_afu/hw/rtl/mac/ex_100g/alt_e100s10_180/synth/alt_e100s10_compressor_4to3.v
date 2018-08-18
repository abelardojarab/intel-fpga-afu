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
// baeckler - 02-21-2012

// DESCRIPTION
// 
// LUT based computation of the sum of four single bit inputs.
// 



// CONFIDENCE
// This is a shallow arithmetic circuit.  Any bugs should be easy to see in simulation.
// 

module alt_e100s10_compressor_4to3 #(
        parameter TARGET_CHIP = 5
)(
        input clk,
        input [3:0] din,
        output [2:0] sum
);

reg [2:0] sum_r = 3'b0 /* synthesis preserve */;

always @(posedge clk) begin
    case (din)
      4'd0: sum_r <= 3'd0;
      4'd1: sum_r <= 3'd1;
      4'd2: sum_r <= 3'd1;
      4'd3: sum_r <= 3'd2;
      4'd4: sum_r <= 3'd1;
      4'd5: sum_r <= 3'd2;
      4'd6: sum_r <= 3'd2;
      4'd7: sum_r <= 3'd3;
      4'd8: sum_r <= 3'd1;
      4'd9: sum_r <= 3'd2;
      4'd10: sum_r <= 3'd2;
      4'd11: sum_r <= 3'd3;
      4'd12: sum_r <= 3'd2;
      4'd13: sum_r <= 3'd3;
      4'd14: sum_r <= 3'd3;
      4'd15: sum_r <= 3'd4;
      default: sum_r <= 3'd0;
    endcase
end

assign sum = sum_r;

endmodule

// BENCHMARK INFO :  10AX115U2F45I2SGE2
// BENCHMARK INFO :  Quartus II 64-Bit Version 15.1.0 Internal Build 52 04/20/2015 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  alt_compressor_4to3.v
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 3
// BENCHMARK INFO :  Total pins : 8
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  3                  
// BENCHMARK INFO :  ALMs : 2 / 427,200 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.171 ns, From din[1], To sum_r[1]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.774 ns, From din[1], To sum_r[0]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.424 ns, From din[2], To sum_r[1]}
