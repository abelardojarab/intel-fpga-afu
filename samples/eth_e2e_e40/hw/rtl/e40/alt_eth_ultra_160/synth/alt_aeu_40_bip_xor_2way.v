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

`timescale 1 ps / 1 ps
// baeckler - 08-21-2012

module alt_aeu_40_bip_xor_2way #(
	parameter TARGET_CHIP = 2
	) (
	input clk,
	input restart,
	input phase,
	input [65:0] din,
	output [7:0] dout
);

wire [7:0] xa,xb;
wire [65:0] d = din;

xor_r x0 (.clk(clk), .dout(xa[0]),.din({d[2], d[10], d[18], d[26]}));
xor_r xx0 (.clk(clk), .dout(xb[0]),.din({d[34], d[42], d[50], d[58]}));
xor_r x1 (.clk(clk), .dout(xa[1]),.din({d[3], d[11], d[19], d[27]}));
xor_r xx1 (.clk(clk), .dout(xb[1]),.din({d[35], d[43], d[51], d[59]}));
xor_r x2 (.clk(clk), .dout(xa[2]),.din({d[4], d[12], d[20], d[28]}));
xor_r xx2 (.clk(clk), .dout(xb[2]),.din({d[36], d[44], d[52], d[60]}));
xor_r x3 (.clk(clk), .dout(xa[3]),.din({d[0], d[5], d[13], d[21]})); 
xor_r xx3 (.clk(clk), .dout(xb[3]),.din({d[29], d[37], d[45], d[53], d[61]}));
xor_r x4 (.clk(clk), .dout(xa[4]),.din({d[1], d[6], d[14], d[22]})); 
xor_r xx4 (.clk(clk), .dout(xb[4]),.din({d[30], d[38], d[46], d[54], d[62]}));
xor_r x5 (.clk(clk), .dout(xa[5]),.din({d[7], d[15], d[23], d[31]}));
xor_r xx5 (.clk(clk), .dout(xb[5]),.din({d[39], d[47], d[55], d[63]}));
xor_r x6 (.clk(clk), .dout(xa[6]),.din({d[8], d[16], d[24], d[32]}));
xor_r xx6 (.clk(clk), .dout(xb[6]),.din({d[40], d[48], d[56], d[64]}));
xor_r x7 (.clk(clk), .dout(xa[7]),.din({d[9], d[17], d[25], d[33]}));
xor_r xx7 (.clk(clk), .dout(xb[7]),.din({d[41], d[49], d[57], d[65]}));

defparam x0 .WIDTH = 4;
defparam x1 .WIDTH = 4;
defparam x2 .WIDTH = 4;
defparam x3 .WIDTH = 4; 
defparam x4 .WIDTH = 4;
defparam x5 .WIDTH = 4;
defparam x6 .WIDTH = 4;
defparam x7 .WIDTH = 4;

defparam x0 .TARGET_CHIP = TARGET_CHIP;
defparam x1 .TARGET_CHIP = TARGET_CHIP;
defparam x2 .TARGET_CHIP = TARGET_CHIP;
defparam x3 .TARGET_CHIP = TARGET_CHIP; 
defparam x4 .TARGET_CHIP = TARGET_CHIP;
defparam x5 .TARGET_CHIP = TARGET_CHIP;
defparam x6 .TARGET_CHIP = TARGET_CHIP;
defparam x7 .TARGET_CHIP = TARGET_CHIP;

defparam xx0 .WIDTH = 4;
defparam xx1 .WIDTH = 4;
defparam xx2 .WIDTH = 4;
defparam xx3 .WIDTH = 5; 
defparam xx4 .WIDTH = 5;
defparam xx5 .WIDTH = 4;
defparam xx6 .WIDTH = 4;
defparam xx7 .WIDTH = 4;

defparam xx0 .TARGET_CHIP = TARGET_CHIP;
defparam xx1 .TARGET_CHIP = TARGET_CHIP;
defparam xx2 .TARGET_CHIP = TARGET_CHIP;
defparam xx3 .TARGET_CHIP = TARGET_CHIP; 
defparam xx4 .TARGET_CHIP = TARGET_CHIP;
defparam xx5 .TARGET_CHIP = TARGET_CHIP;
defparam xx6 .TARGET_CHIP = TARGET_CHIP;
defparam xx7 .TARGET_CHIP = TARGET_CHIP;

/*
/////////////////////////////////////////////////////////////////////
// time sliced accumulator 

wire [7:0] q;
reg [7:0] out_r2;
reg [7:0] out_r;
reg [7:0] out_d;

s5_2way_register rf (
	.clk(clk),
	.d_reg(out_d),
	.q(q)	
);
defparam rf .WIDTH = 8;

always @(*) begin
	if (restart) out_d = 8'h8; // the BIP of any vlane tag is 08
	else         out_d = q ^ xa ^ xb;
end

always @(posedge clk) begin
   out_r <= out_d;
   out_r2 <= out_r;
end

assign dout = out_r2;
*/

/////////////////////////////////////////////////////////////////////
// another implementation 

reg [7:0] xor0, xor0_r;
reg [7:0] xor1, xor1_r;

always @(posedge clk) begin
	if (restart) begin
           xor0 <= 8'h8; // the BIP of any vlane tag is 08
           xor1 <= 8'h8; // the BIP of any vlane tag is 08
        end
	else begin
           if (phase) xor0 <= xor0 ^ xa ^ xb;
           else       xor1 <= xor1 ^ xa ^ xb;
        end 
end

always @(posedge clk) begin
   xor0_r  <= xor0;
   xor1_r  <= xor1;
end

assign dout = phase ? xor0_r : xor1_r;

////////////////////////////////////////////////////////////////////////
/*

           __/---\___/---\___/---\___/---\___/---\___/---\___/---\___/

                 d0      d1      am0     am2     d0      d1      d0   

am_insert ___________________/---------------\___________________


am_insert_rr_________________________________/---------------\________



           __/---\___/---\___/---\___/---\___/---\___/---\___/---\___/
   
din              d0      d1      am0     am2     d0      d1      d0   

vlane_tag   _________________________________/-------X-------\_________
                                             \AM0+bip|AM2+bip/
                                             --------X-------

phase                 /-------\_______/------\_______/-------\_______/

                         xa0                   
                         xb0     xor0 => xor0_r last_bip
                         x0r0
                                   
                                 xa1
                                 xb1  => xor1   xor1_r last_bip
                                 xor1

           __/---\___/---\___/---\___/---\___/---\___/---\___/---\___/

bp_restart__________________________/----------------\_______________

din              d0      d1      am0     am2     d0      d1      d0   

                                                 _______________
xor0      -----------------------------------X  xor0=08     X--------
                                                  --------------
                                                      
                                                         xa0
                                                         xb0  => xor0
                                                         xor0    

           __/---\___/---\___/---\___/---\___/---\___/---\___/---\___/

din              d0      d1      am0     am2     d0      d1      d0   
                                             ________________________
xor1      -----------------------------------X  xor1=08     | xor1=8 X------
                                              -----------------------
                                                      
                                                                 xa1
                                                                 xb1  =>xor1
                                                                 xor1    


*/
////////////////////////////////////////////////////////////////////////

endmodule

