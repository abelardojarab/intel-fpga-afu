// Copyright 2016 Altera Corporation. All rights reserved.
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

// DESCRIPTION
// One hot decoder with 8 outputs.  Latency 1.
// Generated by one of Gregg's toys.   Share And Enjoy.

module alt_dec8t1 #(
    parameter SIM_EMULATE = 1'b0
) (
    input clk,
    input [2:0] din,
    output [7:0] dout
);

wire [7:0] dout_w;
alt_lut6 t0 (.din(6'h0 | din),.dout(dout_w[0]));
defparam t0 .SIM_EMULATE = SIM_EMULATE;
defparam t0 .MASK = 64'h0000000000000001;

alt_lut6 t1 (.din(6'h0 | din),.dout(dout_w[1]));
defparam t1 .SIM_EMULATE = SIM_EMULATE;
defparam t1 .MASK = 64'h0000000000000002;

alt_lut6 t2 (.din(6'h0 | din),.dout(dout_w[2]));
defparam t2 .SIM_EMULATE = SIM_EMULATE;
defparam t2 .MASK = 64'h0000000000000004;

alt_lut6 t3 (.din(6'h0 | din),.dout(dout_w[3]));
defparam t3 .SIM_EMULATE = SIM_EMULATE;
defparam t3 .MASK = 64'h0000000000000008;

alt_lut6 t4 (.din(6'h0 | din),.dout(dout_w[4]));
defparam t4 .SIM_EMULATE = SIM_EMULATE;
defparam t4 .MASK = 64'h0000000000000010;

alt_lut6 t5 (.din(6'h0 | din),.dout(dout_w[5]));
defparam t5 .SIM_EMULATE = SIM_EMULATE;
defparam t5 .MASK = 64'h0000000000000020;

alt_lut6 t6 (.din(6'h0 | din),.dout(dout_w[6]));
defparam t6 .SIM_EMULATE = SIM_EMULATE;
defparam t6 .MASK = 64'h0000000000000040;

alt_lut6 t7 (.din(6'h0 | din),.dout(dout_w[7]));
defparam t7 .SIM_EMULATE = SIM_EMULATE;
defparam t7 .MASK = 64'h0000000000000080;

reg [7:0] dout_r = 8'b0;
always @(posedge clk) dout_r <= dout_w;
assign dout = dout_r;
endmodule

