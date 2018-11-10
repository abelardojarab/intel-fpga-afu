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
// 
// Bit Endian Converter
//	Convert the input data bit to big or little endian
//	if input is big endian, the output will be little endian
//	if input is little endian, the output will be big endian
//
// Author:
// Cher Jier Yap 	- 06-09-2012 
//   
// Revision:
// 06-09-2012 - intial version
// 07-09-2012 - fix: Assign name to every for loop block in bit_endian_converter.v to prevent Quartus report Error

module bit_endian_converter (
	ENABLE,
	DATA_IN,
	DATA_OUT
);

parameter	DATA_WIDTH = 32;				//8, 16, 32, 64

input						ENABLE;
input	[DATA_WIDTH-1:0]	DATA_IN;
output	[DATA_WIDTH-1:0]	DATA_OUT;

genvar i;
generate
	if (DATA_WIDTH == 8) begin 				
		for (i=0; i<8; i=i+1) begin : bit_endian_conv_loop
			assign	DATA_OUT[i] = ENABLE? DATA_IN[DATA_WIDTH-1-i] : DATA_IN[i];	
		end
	end			
	else if (DATA_WIDTH == 16) begin
		for (i=0; i<8; i=i+1) begin : bit_endian_conv_loop
			assign	DATA_OUT[i] = ENABLE? DATA_IN[DATA_WIDTH-1-8-i] : DATA_IN[i]; 
			assign	DATA_OUT[i+8] = ENABLE? DATA_IN[DATA_WIDTH-1-i] : DATA_IN[i+8]; 
		end	
	end
	else if (DATA_WIDTH == 32) begin
		for (i=0; i<8; i=i+1) begin : bit_endian_conv_loop
			assign	DATA_OUT[i] = ENABLE? DATA_IN[DATA_WIDTH-1-24-i] : DATA_IN[i];
			assign	DATA_OUT[i+8] = ENABLE? DATA_IN[DATA_WIDTH-1-16-i] : DATA_IN[i+8];
			assign	DATA_OUT[i+16] = ENABLE? DATA_IN[DATA_WIDTH-1-8-i] : DATA_IN[i+16];
			assign	DATA_OUT[i+24] = ENABLE? DATA_IN[DATA_WIDTH-1-i] : DATA_IN[i+24];
		end
	end
	else if (DATA_WIDTH == 64) begin
		for (i=0; i<8; i=i+1) begin : bit_endian_conv_loop
			assign	DATA_OUT[i] = ENABLE? DATA_IN[DATA_WIDTH-1-56-i] : DATA_IN[i];
			assign	DATA_OUT[i+8] = ENABLE? DATA_IN[DATA_WIDTH-1-48-i] : DATA_IN[i+8];
			assign	DATA_OUT[i+16] = ENABLE? DATA_IN[DATA_WIDTH-1-40-i] : DATA_IN[i+16];
			assign	DATA_OUT[i+24] = ENABLE? DATA_IN[DATA_WIDTH-1-32-i] : DATA_IN[i+24];
			assign	DATA_OUT[i+32] = ENABLE? DATA_IN[DATA_WIDTH-1-24-i] : DATA_IN[i+32];
			assign	DATA_OUT[i+40] = ENABLE? DATA_IN[DATA_WIDTH-1-16-i] : DATA_IN[i+40];
			assign	DATA_OUT[i+48] = ENABLE? DATA_IN[DATA_WIDTH-1-8-i] : DATA_IN[i+48];
			assign	DATA_OUT[i+56] = ENABLE? DATA_IN[DATA_WIDTH-1-i] : DATA_IN[i+56];
		end
	end
endgenerate

endmodule