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
// 2:1 MUX of 1 bit words.  Latency 0.
// Generated by one of Gregg's toys.   Share And Enjoy.

module alt_mux2w1t0s0 #(
    parameter SIM_EMULATE = 1'b0
) (
    input [1:0] din,
    input sel,
    output dout
);

generate
if (SIM_EMULATE) begin
    assign dout = sel ? din[1] : din[0];

end else begin
    alt_lut6 lt0 (.din({1'b0,sel,2'b0,din}),.dout(dout));
    defparam lt0 .SIM_EMULATE = SIM_EMULATE;
    defparam lt0 .MASK = 64'hff00f0f0ccccaaaa;

end
endgenerate
endmodule

