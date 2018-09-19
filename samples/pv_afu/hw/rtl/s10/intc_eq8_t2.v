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
// Executable compiled Jan  4 2017 09:42:44
// This file was generated 01/25/2017 16:26:06

module intc_eq8_t2 #(
    parameter SIM_EMULATE = 1'b0
) (
    input clk,
    input [7:0] dina,
    input [7:0] dinb,
    output dout
);

wire [2:0] leaf;

intc_eq3_t1 eq0 (
    .clk(clk),
    .dina(dina[2:0]),
    .dinb(dinb[2:0]),
    .dout(leaf[0])
);

defparam eq0 .SIM_EMULATE = SIM_EMULATE;

intc_eq3_t1 eq1 (
    .clk(clk),
    .dina(dina[5:3]),
    .dinb(dinb[5:3]),
    .dout(leaf[1])
);

defparam eq1 .SIM_EMULATE = SIM_EMULATE;

intc_eq2_t1 eq2 (
    .clk(clk),
    .dina(dina[7:6]),
    .dinb(dinb[7:6]),
    .dout(leaf[2])
);

defparam eq2 .SIM_EMULATE = SIM_EMULATE;

intc_and3_t1 c3 (
    .clk(clk),
    .din(leaf),
    .dout(dout)
);
defparam c3 .SIM_EMULATE = SIM_EMULATE;

endmodule

