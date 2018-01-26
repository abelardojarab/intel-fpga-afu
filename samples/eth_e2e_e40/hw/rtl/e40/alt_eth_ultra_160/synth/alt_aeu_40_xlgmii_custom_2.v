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


 // _____________________________________________________________________________
 //
 // $Id: //acds/main/ip/ethernet/alt_eth_ultra/40g/rtl/mac/e40_xlgmii_custom.v#1 $
 // $Revision: #1 $
 // $Date: 2013/10/31 $
 // $Author: adubey $
 // _____________________________________________________________________________
 // 
 `timescale 1 ps / 1 ps
  module alt_aeu_40_xlgmii_custom_2 #(
	 parameter WIDTH = 64,
	 parameter WORDS = 2,
	 parameter TARGET_CHIP = 2
  )(
  input wire clk,
  input wire reset,
  
  input wire [WORDS*WIDTH-1:0] in_mii_d,
  input wire [8*WORDS-1:0] in_mii_c,
  input wire in_mii_valid,
  
  output wire out_valid,        		// word contains first data (on leftmost byte)
  output wire [8*WORDS-1:0] out_ctrl,
  output wire [WORDS-1:0] out_sop,        	// word contains first data (on leftmost byte)
  output wire [WORDS-1:0] out_eop,	    	// byte position of last data
  output wire out_error,
  output wire [3*WORDS-1:0] out_eop_empty,  	// byte position of last data
  output wire [WORDS*WIDTH-1:0] out_data     	// data, read left to right
);


 // _____________________________________________________________________________
 //	reusable functions 	
 // _____________________________________________________________________________
  
  function [2:0] bit2dec; 
     input [7:0] bitin;
        reg[2:0] out;
	begin
	    case(bitin)
	      8'b00000000: out = 3'd0;
	      8'b00000001: out = 3'd1;
	      8'b00000010: out = 3'd2;
	      8'b00000100: out = 3'd3;
	      8'b00001000: out = 3'd4;
	      8'b00010000: out = 3'd5;
	      8'b00100000: out = 3'd6;
	      8'b01000000: out = 3'd7;
	      default:     out = 3'd0;
	    endcase
	  bit2dec = out;
	end
     endfunction

 // _____________________________________________________________________________
 //	input pipe stages
 // _____________________________________________________________________________
  
  reg pipe1_mii_v=0;
  reg[08*WORDS-1:0] pipe1_mii_c=0;
  reg[WIDTH*WORDS-1:0] pipe1_mii_d=0;

  always@(posedge clk)
       begin
	  pipe1_mii_v <= in_mii_valid; 
	  if (in_mii_valid) pipe1_mii_d <= in_mii_d; 
	  if (in_mii_valid) pipe1_mii_c <= in_mii_c; 
       end

  genvar i;
  wire[08*WORDS-1:0] pipe1_sop_byte; 
  wire[08*WORDS-1:0] pipe1_eop_byte; 
  wire[08*WORDS-1:0] pipe1_err_byte; 
  generate for (i=0; i <= 08*WORDS-1; i=i+1) 
     begin: pipe1_sop_w
     	assign pipe1_sop_byte[i] = (pipe1_mii_v)&&(pipe1_mii_c[i])&&(pipe1_mii_d[08*(i+1)-1:08*i]==8'hfb);
     	assign pipe1_eop_byte[i] = (pipe1_mii_v)&&(pipe1_mii_c[i])&&(pipe1_mii_d[08*(i+1)-1:08*i]==8'hfd);
        assign pipe1_err_byte[i] = (pipe1_mii_v)&&(pipe1_mii_c[i])&&(pipe1_mii_d[08*(i+1)-1:08*i]==8'hfe);
     end
  endgenerate

 // _____________________________________________________________________________
 //	pipe stage-2
 // _____________________________________________________________________________
  
  reg pipe2_mii_v=0;
  reg[08*WORDS-1:0] pipe2_mii_c=0;
  reg[WIDTH*WORDS-1:0] pipe2_mii_d=0;
  reg[08*WORDS-1:0] pipe2_sop_byte=0, pipe2_eop_byte=0;
  wire pipe2_mid_pkt = !(|(pipe2_sop_byte|pipe2_eop_byte));
  reg pipe2_any_eop = 1'b0;
  reg pipe2_err = 1'b0;

  always@(posedge clk)
       begin
	  if (pipe1_mii_v) pipe2_mii_d <= pipe1_mii_d;
	  if (pipe1_mii_v) pipe2_mii_c <= pipe1_mii_c;
	  if (pipe1_mii_v) pipe2_sop_byte <= pipe1_sop_byte;
	  if (pipe1_mii_v) pipe2_eop_byte <= pipe1_eop_byte;
          if (pipe1_mii_v) pipe2_any_eop <= |pipe1_eop_byte;
          if (pipe1_mii_v) pipe2_err    <= |pipe1_err_byte;
	  pipe2_mii_v <= pipe1_mii_v;

       end

  genvar j;
  wire[03*WORDS-1:0] pipe2_eop_empty;
  generate for (j=0; j <= WORDS-1; j=j+1) 
     begin: pipe2_empty
 	assign pipe2_eop_empty[3*(j+1)-1:3*j]= bit2dec(pipe2_eop_byte[8*(j+1)-1:08*j]);
     end 
  endgenerate

 

 // _____________________________________________________________________________
 //	pipe stage-3
 // _____________________________________________________________________________
  
  reg pipe3_mii_v=0;
  reg[08*WORDS-1:0] pipe3_mii_c=0;
  reg[WIDTH*WORDS-1:0] pipe3_mii_d=0;
  reg[WORDS-1:0] pipe3_sop_word=0, pipe3_eop_word=0;
  reg[3*WORDS-1:0] pipe3_eop_empty=0;
  reg next_error = 1'b0;
  reg pipe3_any_eop = 1'b0;

  always@(posedge clk)
       begin
	 pipe3_mii_d <= pipe2_mii_d;
	 pipe3_mii_c <= pipe2_mii_c;

      // since fd is not part of pkt the eop is shifted in previous work, make sure valid is asserted high to account this eop
      // if (!pipe1_mii_v & pipe2_mid_pkt) pipe3_mii_v <= 1'b0; 
	 if (pipe2_mid_pkt) pipe3_mii_v <= pipe1_mii_v;
	 else if (pipe1_eop_byte[15] & pipe2_mid_pkt) pipe3_mii_v <= 1'b1;
	 else pipe3_mii_v <= pipe2_mii_v;
	 pipe3_sop_word <= {|pipe2_sop_byte[15:8], |pipe2_sop_byte[7:0]};
	 pipe3_eop_word <= {|pipe2_eop_byte[14:7], |{pipe2_eop_byte[6:0], pipe1_eop_byte[15]}};// fd is actually not part of pkt
 	 pipe3_eop_empty<= pipe2_eop_empty;
       end

  always @(posedge clk) 
    begin
        if (pipe2_mii_v)  pipe3_any_eop  <= pipe2_any_eop;
        next_error <= (pipe2_err & ~pipe3_any_eop) | (next_error & pipe2_any_eop)  ;
    end


 // _____________________________________________________________________________
 //	output wiring
 // _____________________________________________________________________________
  assign out_valid = pipe3_mii_v;      	// data is valid on this cycle
  assign out_sop = pipe3_sop_word;      // word contains first data (on leftmost byte)
  assign out_eop = pipe3_eop_word;	// word contains last data
  assign out_data = pipe3_mii_d;     	// data, read left to right
  assign out_ctrl = pipe3_mii_c;     	// control, read left to right
  assign out_eop_empty = pipe3_eop_empty;//byte position of last data (per word)
  assign out_error = next_error ;
  


endmodule
