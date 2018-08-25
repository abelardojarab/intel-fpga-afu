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

// baeckler - 05-13-2005
//
//   Six input three output compressor (non-carry adder)
//
//	 Maps to 3 Stratix II six luts.  Use optimize = speed
//

module alt_aeuex_six_three_comp (data,sum);

input [5:0] data;
output [2:0] sum;

reg [2:0] sum /* synthesis keep */;

always @(data) begin
    case (data)
      0: sum=0;
      1: sum=1;
      2: sum=1;
      3: sum=2;
      4: sum=1;
      5: sum=2;
      6: sum=2;
      7: sum=3;
      8: sum=1;
      9: sum=2;
      10: sum=2;
      11: sum=3;
      12: sum=2;
      13: sum=3;
      14: sum=3;
      15: sum=4;
      16: sum=1;
      17: sum=2;
      18: sum=2;
      19: sum=3;
      20: sum=2;
      21: sum=3;
      22: sum=3;
      23: sum=4;
      24: sum=2;
      25: sum=3;
      26: sum=3;
      27: sum=4;
      28: sum=3;
      29: sum=4;
      30: sum=4;
      31: sum=5;
      32: sum=1;
      33: sum=2;
      34: sum=2;
      35: sum=3;
      36: sum=2;
      37: sum=3;
      38: sum=3;
      39: sum=4;
      40: sum=2;
      41: sum=3;
      42: sum=3;
      43: sum=4;
      44: sum=3;
      45: sum=4;
      46: sum=4;
      47: sum=5;
      48: sum=2;
      49: sum=3;
      50: sum=3;
      51: sum=4;
      52: sum=3;
      53: sum=4;
      54: sum=4;
      55: sum=5;
      56: sum=3;
      57: sum=4;
      58: sum=4;
      59: sum=5;
      60: sum=4;
      61: sum=5;
      62: sum=5;
      63: sum=6;
      default: sum=0;
    endcase
end

endmodule
