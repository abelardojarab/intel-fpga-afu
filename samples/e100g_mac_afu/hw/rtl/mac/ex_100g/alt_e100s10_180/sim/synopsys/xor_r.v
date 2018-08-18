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


// $Id: $
// $Revision: $
// $Date: $
// $Author: $
//-----------------------------------------------------------------------------

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

`timescale 1 ps / 1 ps
// baeckler - 06-07-2012
// pipelined XOR together bits

module xor_r #(
	parameter WIDTH = 8,
	parameter TARGET_CHIP = 2
)(
	input clk,
	input [WIDTH-1:0] din,
	output dout
);

genvar i;
generate
	if (WIDTH <= 6) begin
		reg dout_r = 1'b0;
		wire xlw;
		xor_lut xl (
			.din(din),
			.dout(xlw)
		);
		defparam xl .TARGET_CHIP = TARGET_CHIP;
		defparam xl .WIDTH = WIDTH;
		always @(posedge clk) dout_r <= xlw;
		assign dout = dout_r;
	end
	else if ((WIDTH % 6) == 0) begin
		localparam NUM_HEXES = WIDTH / 6;
		wire [NUM_HEXES-1:0] tmp;
		for (i=0; i<NUM_HEXES; i=i+1) begin : lp
			xor_r a (.clk(clk),.din(din[(i+1)*6-1:i*6]),.dout(tmp[i]));
			defparam a .WIDTH = 6;	
			defparam a .TARGET_CHIP = TARGET_CHIP;		
		end					
		xor_r h (.clk(clk),.din(tmp),.dout(dout));			
		defparam h .WIDTH = NUM_HEXES;
		defparam h .TARGET_CHIP = TARGET_CHIP;
	end
	else if ((WIDTH % 5) == 0) begin
		localparam NUM_QUINTS = WIDTH / 5;
		wire [NUM_QUINTS-1:0] tmp;
		for (i=0; i<NUM_QUINTS; i=i+1) begin : lp
			xor_r a (.clk(clk),.din(din[(i+1)*5-1:i*5]),.dout(tmp[i]));
			defparam a .WIDTH = 5;			
			defparam a .TARGET_CHIP = TARGET_CHIP;		
		end					
		xor_r h (.clk(clk),.din(tmp),.dout(dout));			
		defparam h .WIDTH = NUM_QUINTS;
		defparam h .TARGET_CHIP = TARGET_CHIP;		
	end	
	else if ((WIDTH % 4) == 0) begin
		localparam NUM_QUADS = WIDTH / 4;
		wire [NUM_QUADS-1:0] tmp;
		for (i=0; i<NUM_QUADS; i=i+1) begin : lp
			xor_r a (.clk(clk),.din(din[(i+1)*4-1:i*4]),.dout(tmp[i]));
			defparam a .WIDTH = 4;			
			defparam a .TARGET_CHIP = TARGET_CHIP;		
		end					
		xor_r h (.clk(clk),.din(tmp),.dout(dout));			
		defparam h .WIDTH = NUM_QUADS;
		defparam h .TARGET_CHIP = TARGET_CHIP;		
	end	
	else if (WIDTH < 12) begin
		wire [1:0] tmp;
		
		xor_r a (.clk(clk),.din(din[(WIDTH/2)-1:0]),.dout(tmp[0]));
		defparam a .WIDTH = WIDTH/2;			
		defparam a .TARGET_CHIP = TARGET_CHIP;		
	
		xor_r b (.clk(clk),.din(din[WIDTH-1:WIDTH/2]),.dout(tmp[1]));
		defparam b .WIDTH = WIDTH-(WIDTH/2);			
		defparam b .TARGET_CHIP = TARGET_CHIP;		
	
		xor_r h (.clk(clk),.din(tmp),.dout(dout));			
		defparam h .WIDTH = 2;
		defparam h .TARGET_CHIP = TARGET_CHIP;		
	end
	else begin
		initial begin
			$display ("Oops - no pipelined gate pattern available for width %d",WIDTH);
			$display ("Please add");
			$stop();
		end
	end		
endgenerate

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 3
// BENCHMARK INFO :  Total pins : 10
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 4               ;       ;
// BENCHMARK INFO :  ALMs : 2 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.724 ns, From xor_r:lp[1].a|dout_r, To xor_r:h|dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.711 ns, From xor_r:lp[0].a|dout_r, To xor_r:h|dout_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.722 ns, From xor_r:lp[0].a|dout_r, To xor_r:h|dout_r}
