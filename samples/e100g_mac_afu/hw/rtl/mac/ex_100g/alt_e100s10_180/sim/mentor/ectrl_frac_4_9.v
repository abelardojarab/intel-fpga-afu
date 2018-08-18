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


// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/mac/ectrl_frac_4_9.v#1 $
// $Revision: #1 $
// $Date: 2013/02/27 $
// $Author: pscheidt $
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

`timescale 1ps / 1ps
// baeckler - 09-25-2012

// insert holes into the data stream as necessary to separate SOPs
// by at least 9 words, to make room for 8 word packet, 1 gap, 1 preamble 

// data tags only appear in their corresponding position, and should cycle
// 32103210... with holes when working properly

module ectrl_frac_4_9 (
	input clk,
	input sclr,
        input ena,
	//output req,
	output wire [4:0] req /* synthesis preserve_syn_only */, // S10TIM
	input [3:0] pat,
	output reg [4*3-1:0] otag // 111,110,101,100 data   000 hole
);

localparam s_base = 5'h0,
    s_g_g_0123 = 5'h1,
    s_g_0123 = 5'h2,
    s_0123 = 5'h3,
    s_g_g123 = 5'h4,
    s_g123 = 5'h5,
    s_g_g23 = 5'h6,
    s_g23 = 5'h7,
    s_g_g3 = 5'h8,
    s_g3 = 5'h9,
    s_g_g_01g_g_g23 = 5'ha,
    s_g_01g_g_g23 = 5'hb,
    s_01g_g_g23 = 5'hc,
    s_g_g_012g_g_g3 = 5'hd,
    s_g_012g_g_g3 = 5'he,
    s_012g_g_g3 = 5'hf,
    s_g_g12g_g_g3 = 5'h10,
    s_g12g_g_g3 = 5'h11;

localparam 
	o_0123 = 12'b111_110_101_100,
	o_g = 12'b000_000_000_000,
	o_0g = 12'b000_000_000_100,
	o_01g = 12'b000_000_101_100,
	o_012g = 12'b000_110_101_100,
	o_g123 = 12'b111_110_101_000,
	o_g23 = 12'b111_110_000_000,
	o_g3 = 12'b111_000_000_000,
	o_g12g = 12'b000_110_101_000;	
	
reg [3:0] hist  /* synthesis preserve_syn_only */;
reg [4:0] st;
reg start_req /* synthesis preserve_syn_only */;

always @(posedge clk) begin
	if (sclr) begin
		hist <= 4'h0; 
		st <= s_base;
		otag <= o_g;
		start_req <= 1;
	end
	else begin
           if (ena) begin
		   
		case (st)
			
			s_base : begin

				if (pat == 4'h0) begin
					if (hist == 4'h0) begin otag <= o_0123; st <= s_base; hist <= 4'h4; start_req <= 1; end
					if (hist == 4'h1) begin otag <= o_0123; st <= s_base; hist <= 4'h5; start_req <= 1; end
					if (hist == 4'h2) begin otag <= o_0123; st <= s_base; hist <= 4'h6; start_req <= 1; end
					if (hist == 4'h3) begin otag <= o_0123; st <= s_base; hist <= 4'h7; start_req <= 1; end
					if (hist == 4'h4) begin otag <= o_0123; st <= s_base; hist <= 4'h8; start_req <= 1; end
					if (hist == 4'h5) begin otag <= o_0123; st <= s_base; hist <= 4'h9; start_req <= 1; end
					if (hist == 4'h6) begin otag <= o_0123; st <= s_base; hist <= 4'h9; start_req <= 1; end
					if (hist == 4'h7) begin otag <= o_0123; st <= s_base; hist <= 4'h9; start_req <= 1; end
					if (hist == 4'h8) begin otag <= o_0123; st <= s_base; hist <= 4'h9; start_req <= 1; end
					if (hist == 4'h9) begin otag <= o_0123; st <= s_base; hist <= 4'h9; start_req <= 1; end
				end

				if (pat == 4'h1) begin
                    /*
					if (hist == 4'h0) begin otag <= o_0123; st <= s_base; hist <= 4'h4; start_req <= 1; end
					if (hist == 4'h1) begin otag <= o_g; st <= s_g_g_0123; hist <= 4'h4; start_req <= 0; end
					if (hist == 4'h2) begin otag <= o_g; st <= s_g_0123; hist <= 4'h4; start_req <= 0; end
					if (hist == 4'h3) begin otag <= o_g; st <= s_g_0123; hist <= 4'h4; start_req <= 0; end
					if (hist == 4'h4) begin otag <= o_g; st <= s_g_0123; hist <= 4'h4; start_req <= 0; end
					if (hist == 4'h5) begin otag <= o_g; st <= s_g_0123; hist <= 4'h4; start_req <= 0; end
					if (hist == 4'h6) begin otag <= o_g; st <= s_0123; hist <= 4'h4; start_req <= 0; end
					if (hist == 4'h7) begin otag <= o_g; st <= s_0123; hist <= 4'h4; start_req <= 0; end
					if (hist == 4'h8) begin otag <= o_g; st <= s_0123; hist <= 4'h4; start_req <= 0; end
					if (hist == 4'h9) begin otag <= o_0123; st <= s_base; hist <= 4'h4; start_req <= 1; end
                    */
					if (hist == 4'h0) begin otag <= o_0123; st <= s_base;  start_req <= 1; end
					if (hist == 4'h1) begin otag <= o_g; st <= s_g_g_0123; start_req <= 0; end
					if (hist == 4'h2) begin otag <= o_g; st <= s_g_0123;   start_req <= 0; end
					if (hist == 4'h3) begin otag <= o_g; st <= s_g_0123;   start_req <= 0; end
					if (hist == 4'h4) begin otag <= o_g; st <= s_g_0123;   start_req <= 0; end
					if (hist == 4'h5) begin otag <= o_g; st <= s_g_0123;   start_req <= 0; end
					if (hist == 4'h6) begin otag <= o_g; st <= s_0123;     start_req <= 0; end
					if (hist == 4'h7) begin otag <= o_g; st <= s_0123;     start_req <= 0; end
					if (hist == 4'h8) begin otag <= o_g; st <= s_0123;     start_req <= 0; end
					if (hist == 4'h9) begin otag <= o_0123; st <= s_base;  start_req <= 1; end
                    hist <= 4'h4; // S10TIM
				end

				if (pat == 4'h2) begin
                    /*
					if (hist == 4'h0) begin otag <= o_0123; st <= s_base; hist <= 4'h3; start_req <= 1; end
					if (hist == 4'h1) begin otag <= o_0g; st <= s_g_g123; hist <= 4'h3; start_req <= 0; end
					if (hist == 4'h2) begin otag <= o_0g; st <= s_g_g123; hist <= 4'h3; start_req <= 0; end
					if (hist == 4'h3) begin otag <= o_0g; st <= s_g_g123; hist <= 4'h3; start_req <= 0; end
					if (hist == 4'h4) begin otag <= o_0g; st <= s_g_g123; hist <= 4'h3; start_req <= 0; end
					if (hist == 4'h5) begin otag <= o_0g; st <= s_g123; hist <= 4'h3; start_req <= 0; end
					if (hist == 4'h6) begin otag <= o_0g; st <= s_g123; hist <= 4'h3; start_req <= 0; end
					if (hist == 4'h7) begin otag <= o_0g; st <= s_g123; hist <= 4'h3; start_req <= 0; end
					if (hist == 4'h8) begin otag <= o_0123; st <= s_base; hist <= 4'h3; start_req <= 1; end
					if (hist == 4'h9) begin otag <= o_0123; st <= s_base; hist <= 4'h3; start_req <= 1; end
                    */
					if (hist == 4'h0) begin otag <= o_0123; st <= s_base; start_req <= 1; end
					if (hist == 4'h1) begin otag <= o_0g; st <= s_g_g123; start_req <= 0; end
					if (hist == 4'h2) begin otag <= o_0g; st <= s_g_g123; start_req <= 0; end
					if (hist == 4'h3) begin otag <= o_0g; st <= s_g_g123; start_req <= 0; end
					if (hist == 4'h4) begin otag <= o_0g; st <= s_g_g123; start_req <= 0; end
					if (hist == 4'h5) begin otag <= o_0g; st <= s_g123;   start_req <= 0; end
					if (hist == 4'h6) begin otag <= o_0g; st <= s_g123;   start_req <= 0; end
					if (hist == 4'h7) begin otag <= o_0g; st <= s_g123;   start_req <= 0; end
					if (hist == 4'h8) begin otag <= o_0123; st <= s_base; start_req <= 1; end
					if (hist == 4'h9) begin otag <= o_0123; st <= s_base; start_req <= 1; end
                    hist <= 4'h3; // S10TIM
				end

				if (pat == 4'h4) begin
                    /*
					if (hist == 4'h0) begin otag <= o_0123; st <= s_base; hist <= 4'h2; start_req <= 1; end
					if (hist == 4'h1) begin otag <= o_01g; st <= s_g_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h2) begin otag <= o_01g; st <= s_g_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h3) begin otag <= o_01g; st <= s_g_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h4) begin otag <= o_01g; st <= s_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h5) begin otag <= o_01g; st <= s_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h6) begin otag <= o_01g; st <= s_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h7) begin otag <= o_0123; st <= s_base; hist <= 4'h2; start_req <= 1; end
					if (hist == 4'h8) begin otag <= o_0123; st <= s_base; hist <= 4'h2; start_req <= 1; end
					if (hist == 4'h9) begin otag <= o_0123; st <= s_base; hist <= 4'h2; start_req <= 1; end
                    */
					if (hist == 4'h0) begin otag <= o_0123; st <= s_base; start_req <= 1; end
					if (hist == 4'h1) begin otag <= o_01g; st <= s_g_g23; start_req <= 0; end
					if (hist == 4'h2) begin otag <= o_01g; st <= s_g_g23; start_req <= 0; end
					if (hist == 4'h3) begin otag <= o_01g; st <= s_g_g23; start_req <= 0; end
					if (hist == 4'h4) begin otag <= o_01g; st <= s_g23;   start_req <= 0; end
					if (hist == 4'h5) begin otag <= o_01g; st <= s_g23;   start_req <= 0; end
					if (hist == 4'h6) begin otag <= o_01g; st <= s_g23;   start_req <= 0; end
					if (hist == 4'h7) begin otag <= o_0123; st <= s_base; start_req <= 1; end
					if (hist == 4'h8) begin otag <= o_0123; st <= s_base; start_req <= 1; end
					if (hist == 4'h9) begin otag <= o_0123; st <= s_base; start_req <= 1; end
                    hist <= 4'h2; // S10TIM
				end

				if (pat == 4'h8) begin
                    /*
					if (hist == 4'h0) begin otag <= o_0123; st <= s_base; hist <= 4'h1; start_req <= 1; end
					if (hist == 4'h1) begin otag <= o_012g; st <= s_g_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h2) begin otag <= o_012g; st <= s_g_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h3) begin otag <= o_012g; st <= s_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h4) begin otag <= o_012g; st <= s_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h5) begin otag <= o_012g; st <= s_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h6) begin otag <= o_0123; st <= s_base; hist <= 4'h1; start_req <= 1; end
					if (hist == 4'h7) begin otag <= o_0123; st <= s_base; hist <= 4'h1; start_req <= 1; end
					if (hist == 4'h8) begin otag <= o_0123; st <= s_base; hist <= 4'h1; start_req <= 1; end
					if (hist == 4'h9) begin otag <= o_0123; st <= s_base; hist <= 4'h1; start_req <= 1; end
                    */
					if (hist == 4'h0) begin otag <= o_0123; st <= s_base; start_req <= 1; end
					if (hist == 4'h1) begin otag <= o_012g; st <= s_g_g3; start_req <= 0; end
					if (hist == 4'h2) begin otag <= o_012g; st <= s_g_g3; start_req <= 0; end
					if (hist == 4'h3) begin otag <= o_012g; st <= s_g3;   start_req <= 0; end
					if (hist == 4'h4) begin otag <= o_012g; st <= s_g3;   start_req <= 0; end
					if (hist == 4'h5) begin otag <= o_012g; st <= s_g3;   start_req <= 0; end
					if (hist == 4'h6) begin otag <= o_0123; st <= s_base; start_req <= 1; end
					if (hist == 4'h7) begin otag <= o_0123; st <= s_base; start_req <= 1; end
					if (hist == 4'h8) begin otag <= o_0123; st <= s_base; start_req <= 1; end
					if (hist == 4'h9) begin otag <= o_0123; st <= s_base; start_req <= 1; end
                    hist <= 4'h1; // S10TIM
				end

				if (pat == 4'h5) begin
                    /*
					if (hist == 4'h0) begin otag <= o_01g; st <= s_g_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h1) begin otag <= o_g; st <= s_g_g_01g_g_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h2) begin otag <= o_g; st <= s_g_01g_g_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h3) begin otag <= o_g; st <= s_g_01g_g_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h4) begin otag <= o_g; st <= s_g_01g_g_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h5) begin otag <= o_g; st <= s_01g_g_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h6) begin otag <= o_g; st <= s_01g_g_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h7) begin otag <= o_g; st <= s_01g_g_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h8) begin otag <= o_g; st <= s_01g_g_g23; hist <= 4'h2; start_req <= 0; end
					if (hist == 4'h9) begin otag <= o_01g; st <= s_g_g23; hist <= 4'h2; start_req <= 0; end
                    */
					if (hist == 4'h0) begin otag <= o_01g; st <= s_g_g23;       start_req <= 0; end
					if (hist == 4'h1) begin otag <= o_g; st <= s_g_g_01g_g_g23; start_req <= 0; end
					if (hist == 4'h2) begin otag <= o_g; st <= s_g_01g_g_g23;   start_req <= 0; end
					if (hist == 4'h3) begin otag <= o_g; st <= s_g_01g_g_g23;   start_req <= 0; end
					if (hist == 4'h4) begin otag <= o_g; st <= s_g_01g_g_g23;   start_req <= 0; end
					if (hist == 4'h5) begin otag <= o_g; st <= s_01g_g_g23;     start_req <= 0; end
					if (hist == 4'h6) begin otag <= o_g; st <= s_01g_g_g23;     start_req <= 0; end
					if (hist == 4'h7) begin otag <= o_g; st <= s_01g_g_g23;     start_req <= 0; end
					if (hist == 4'h8) begin otag <= o_g; st <= s_01g_g_g23;     start_req <= 0; end
					if (hist == 4'h9) begin otag <= o_01g; st <= s_g_g23;       start_req <= 0; end
                    hist <= 4'h2; // S10TIM
				end

				if (pat == 4'h9) begin
                    /*
					if (hist == 4'h0) begin otag <= o_012g; st <= s_g_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h1) begin otag <= o_g; st <= s_g_g_012g_g_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h2) begin otag <= o_g; st <= s_g_012g_g_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h3) begin otag <= o_g; st <= s_g_012g_g_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h4) begin otag <= o_g; st <= s_g_012g_g_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h5) begin otag <= o_g; st <= s_012g_g_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h6) begin otag <= o_g; st <= s_012g_g_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h7) begin otag <= o_g; st <= s_012g_g_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h8) begin otag <= o_g; st <= s_012g_g_g3; hist <= 4'h1; start_req <= 0; end
					if (hist == 4'h9) begin otag <= o_012g; st <= s_g_g3; hist <= 4'h1; start_req <= 0; end
                    */
					if (hist == 4'h0) begin otag <= o_012g; st <= s_g_g3;       start_req <= 0; end
					if (hist == 4'h1) begin otag <= o_g; st <= s_g_g_012g_g_g3; start_req <= 0; end
					if (hist == 4'h2) begin otag <= o_g; st <= s_g_012g_g_g3;   start_req <= 0; end
					if (hist == 4'h3) begin otag <= o_g; st <= s_g_012g_g_g3;   start_req <= 0; end
					if (hist == 4'h4) begin otag <= o_g; st <= s_g_012g_g_g3;   start_req <= 0; end
					if (hist == 4'h5) begin otag <= o_g; st <= s_012g_g_g3;     start_req <= 0; end
					if (hist == 4'h6) begin otag <= o_g; st <= s_012g_g_g3;     start_req <= 0; end
					if (hist == 4'h7) begin otag <= o_g; st <= s_012g_g_g3;     start_req <= 0; end
					if (hist == 4'h8) begin otag <= o_g; st <= s_012g_g_g3;     start_req <= 0; end
					if (hist == 4'h9) begin otag <= o_012g; st <= s_g_g3;       start_req <= 0; end
                    hist <= 4'h1; // S10TIM
				end

                                if (pat == 4'ha) begin
                                        /*
                                        if (hist == 4'h0) begin otag <= o_012g; st <= s_g_g3; hist <= 4'h1; start_req <= 0; end
                                        if (hist == 4'h1) begin otag <= o_0g; st <= s_g_g12g_g_g3; hist <= 4'h1; start_req <= 0; end
                                        if (hist == 4'h2) begin otag <= o_0g; st <= s_g_g12g_g_g3; hist <= 4'h1; start_req <= 0; end
                                        if (hist == 4'h3) begin otag <= o_0g; st <= s_g_g12g_g_g3; hist <= 4'h1; start_req <= 0; end
                                        if (hist == 4'h4) begin otag <= o_0g; st <= s_g_g12g_g_g3; hist <= 4'h1; start_req <= 0; end
                                        if (hist == 4'h5) begin otag <= o_0g; st <= s_g12g_g_g3; hist <= 4'h1; start_req <= 0; end
                                        if (hist == 4'h6) begin otag <= o_0g; st <= s_g12g_g_g3; hist <= 4'h1; start_req <= 0; end
                                        if (hist == 4'h7) begin otag <= o_0g; st <= s_g12g_g_g3; hist <= 4'h1; start_req <= 0; end
                                        if (hist == 4'h8) begin otag <= o_0g; st <= s_g12g_g_g3; hist <= 4'h1; start_req <= 0; end
                                        if (hist == 4'h9) begin otag <= o_012g; st <= s_g_g3; hist <= 4'h1; start_req <= 0; end
                                        */
                                        if (hist == 4'h0) begin otag <= o_012g; st <= s_g_g3;      start_req <= 0; end
                                        if (hist == 4'h1) begin otag <= o_0g; st <= s_g_g12g_g_g3; start_req <= 0; end
                                        if (hist == 4'h2) begin otag <= o_0g; st <= s_g_g12g_g_g3; start_req <= 0; end
                                        if (hist == 4'h3) begin otag <= o_0g; st <= s_g_g12g_g_g3; start_req <= 0; end
                                        if (hist == 4'h4) begin otag <= o_0g; st <= s_g_g12g_g_g3; start_req <= 0; end
                                        if (hist == 4'h5) begin otag <= o_0g; st <= s_g12g_g_g3;   start_req <= 0; end
                                        if (hist == 4'h6) begin otag <= o_0g; st <= s_g12g_g_g3;   start_req <= 0; end
                                        if (hist == 4'h7) begin otag <= o_0g; st <= s_g12g_g_g3;   start_req <= 0; end
                                        if (hist == 4'h8) begin otag <= o_0g; st <= s_g12g_g_g3;   start_req <= 0; end
                                        if (hist == 4'h9) begin otag <= o_012g; st <= s_g_g3;      start_req <= 0; end
                                        hist <= 4'h1; // S10TIM
                                end
			end
			s_g_g_0123 :        begin  otag <= o_g; st <= s_g_0123; start_req <= 0; end
			s_g_0123 :          begin  otag <= o_g; st <= s_0123; start_req <= 0; end
			s_0123 :            begin  otag <= o_0123; st <= s_base; start_req <= 1; end
			s_g_g123 :          begin  otag <= o_g; st <= s_g123; start_req <= 0; end
			s_g123 :            begin  otag <= o_g123; st <= s_base; start_req <= 1; end
			s_g_g23 :           begin  otag <= o_g; st <= s_g23; start_req <= 0; end
			s_g23 :             begin  otag <= o_g23; st <= s_base; start_req <= 1; end
			s_g_g3 :            begin  otag <= o_g; st <= s_g3; start_req <= 0; end
			s_g3 :              begin  otag <= o_g3; st <= s_base; start_req <= 1; end
			s_g_g_01g_g_g23 :   begin  otag <= o_g; st <= s_g_01g_g_g23; start_req <= 0; end
			s_g_01g_g_g23 :     begin  otag <= o_g; st <= s_01g_g_g23; start_req <= 0; end
			s_01g_g_g23 :       begin  otag <= o_01g; st <= s_g_g23; start_req <= 0; end
			s_g_g_012g_g_g3 :   begin  otag <= o_g; st <= s_g_012g_g_g3; start_req <= 0; end
			s_g_012g_g_g3 :     begin  otag <= o_g; st <= s_012g_g_g3; start_req <= 0; end
			s_012g_g_g3 :       begin  otag <= o_012g; st <= s_g_g3; start_req <= 0; end
			s_g_g12g_g_g3 :     begin  otag <= o_g; st <= s_g12g_g_g3; start_req <= 0; end
			s_g12g_g_g3 :       begin  otag <= o_g12g; st <= s_g_g3; start_req <= 0; end
		endcase
		end
           end
end

//assign req = start_req && ena;
assign req = {5{start_req && ena}};

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  4.0 LUTs
// BENCHMARK INFO :  Total registers : 32
// BENCHMARK INFO :  Total pins : 19
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.735 ns, From hist.0010, To otag[7]~reg0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.546 ns, From hist.0011, To otag[7]~reg0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.727 ns, From hist.0100, To otag[7]~reg0}
