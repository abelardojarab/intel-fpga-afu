// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: $
// $Revision: $
// $Date: $
// $Author: $
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps
// Copyright 2012 Altera Corporation. All rights reserved.  
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

// baeckler - 01-09-2012
// move a pulse from one domain to another

module cross_strobe (
	input din_clk,
	input din_pulse,
	
	input dout_clk,
	output dout_pulse
);

reg din_togl = 1'b0;
always @(posedge din_clk) begin
	din_togl <= din_togl ^ din_pulse;	
end

wire togl_s;
sync_regs_m2 sr (
	.clk(dout_clk),
	.din(din_togl),
	.dout(togl_s)
);
defparam sr .WIDTH = 1;

reg last_togl_s = 1'b0;
always @(posedge dout_clk) begin
	last_togl_s <= togl_s;
end

assign dout_pulse = togl_s ^ last_togl_s;

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 4
// BENCHMARK INFO :  Total pins : 4
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 3               ;       ;
// BENCHMARK INFO :  ALMs : 2 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.425 ns, From din_togl, To din_togl}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.425 ns, From din_togl, To din_togl}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.508 ns, From sync_regs_m2:sr|sync_sr[0], To last_togl_s}
