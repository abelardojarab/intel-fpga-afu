// Copyright 2010-2017 Altera Corporation. All rights reserved.
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

// Generated by one of Gregg's toys.   Share And Enjoy.
// Executable compiled Jun  1 2017 09:50:04
// This file was generated 06/02/2017 16:40:11

// spread out a single input through a register tree to 32 destinations
// 6 ticks available to get there

module intc_spread32_t6 #(
    parameter SIM_EMULATE = 1'b0
) (
    input clk,
    input din,
    output [31:0] dout
);

// targeting roughly 6 ticks of splitting by 2

// this has a lot of latency available, just register the outputs and pass along

wire [31:0] helpers;
reg [31:0] dout_r = 32'b0 /* synthesis preserve_syn_only */;
always @(posedge clk) begin
    dout_r[0:0] <= {1{helpers[0]}};
    dout_r[1:1] <= {1{helpers[1]}};
    dout_r[2:2] <= {1{helpers[2]}};
    dout_r[3:3] <= {1{helpers[3]}};
    dout_r[4:4] <= {1{helpers[4]}};
    dout_r[5:5] <= {1{helpers[5]}};
    dout_r[6:6] <= {1{helpers[6]}};
    dout_r[7:7] <= {1{helpers[7]}};
    dout_r[8:8] <= {1{helpers[8]}};
    dout_r[9:9] <= {1{helpers[9]}};
    dout_r[10:10] <= {1{helpers[10]}};
    dout_r[11:11] <= {1{helpers[11]}};
    dout_r[12:12] <= {1{helpers[12]}};
    dout_r[13:13] <= {1{helpers[13]}};
    dout_r[14:14] <= {1{helpers[14]}};
    dout_r[15:15] <= {1{helpers[15]}};
    dout_r[16:16] <= {1{helpers[16]}};
    dout_r[17:17] <= {1{helpers[17]}};
    dout_r[18:18] <= {1{helpers[18]}};
    dout_r[19:19] <= {1{helpers[19]}};
    dout_r[20:20] <= {1{helpers[20]}};
    dout_r[21:21] <= {1{helpers[21]}};
    dout_r[22:22] <= {1{helpers[22]}};
    dout_r[23:23] <= {1{helpers[23]}};
    dout_r[24:24] <= {1{helpers[24]}};
    dout_r[25:25] <= {1{helpers[25]}};
    dout_r[26:26] <= {1{helpers[26]}};
    dout_r[27:27] <= {1{helpers[27]}};
    dout_r[28:28] <= {1{helpers[28]}};
    dout_r[29:29] <= {1{helpers[29]}};
    dout_r[30:30] <= {1{helpers[30]}};
    dout_r[31:31] <= {1{helpers[31]}};
end

intc_spread32_t5 sp0 (
    .clk(clk),
    .din(din),
    .dout(helpers)
);
defparam sp0 .SIM_EMULATE = SIM_EMULATE;

assign dout = dout_r;

endmodule

