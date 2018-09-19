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
// Executable compiled Jun  1 2017 09:50:07
// This file was generated 06/02/2017 15:53:50

// Pipelined AND gate
// 32 inputs,  latency 5 ticks

module intc_and32_t5 #(
    parameter SIM_EMULATE = 1'b0
) (
    input clk,
    input [31:0] din,
    output dout
);

///////////////////////////////////////
// biting off 6 leaves of size 6

// leaf latency is 2
wire [5:0] leaf;

intc_and6_t2 #(
    .SIM_EMULATE(SIM_EMULATE)
) lf0 (
    .clk(clk),
    .din(din[5:0]),
    .dout(leaf[0])
);

intc_and6_t2 #(
    .SIM_EMULATE(SIM_EMULATE)
) lf1 (
    .clk(clk),
    .din(din[11:6]),
    .dout(leaf[1])
);

intc_and6_t2 #(
    .SIM_EMULATE(SIM_EMULATE)
) lf2 (
    .clk(clk),
    .din(din[17:12]),
    .dout(leaf[2])
);

intc_and6_t2 #(
    .SIM_EMULATE(SIM_EMULATE)
) lf3 (
    .clk(clk),
    .din(din[23:18]),
    .dout(leaf[3])
);

intc_and6_t2 #(
    .SIM_EMULATE(SIM_EMULATE)
) lf4 (
    .clk(clk),
    .din(din[29:24]),
    .dout(leaf[4])
);

intc_and2_t2 #(
    .SIM_EMULATE(SIM_EMULATE)
) lf5 (
    .clk(clk),
    .din(din[31:30]),
    .dout(leaf[5])
);

////////////////////////////////////////
// Combine the 6 leaves in 3 ticks

intc_and6_t3 #(
    .SIM_EMULATE(SIM_EMULATE)
) hd0 (
    .clk(clk),
    .din(leaf),
    .dout(dout)
);


endmodule

