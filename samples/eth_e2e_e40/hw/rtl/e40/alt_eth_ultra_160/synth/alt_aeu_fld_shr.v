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


// $Id: //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/pcs/e100_rx_pcs_4.v#1 $
// $Revision: #1 $
// $Date: 2013/02/27 $
// $Author: rkane $
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

module alt_aeu_fld_shr
  #(
    parameter TARGET_CHIP = 2, // 2: stratix v, 5: arria 10
	parameter W2_WIDTH = 9,
	parameter MAX_WIDTH = 16 + W2_WIDTH,
    parameter WORDS = 4
    )    
   (
	input srst,
	input [1:0] fld,

   input din_valid,
    input [(W2_WIDTH+1)*8-1:0] din,
    input [4:0] din_offset,
	input din_spl_hndl,
	input din_ipg,

    output dout_valid,
    output [WORDS*8*8-1:0] dout,
    output [WORDS*8-1:0] dout_mask,

    input clk
   
	);

   localparam REM_WORDS = 4*8-MAX_WIDTH;
   localparam WORDS_DIV_2 = WORDS/2;

   wire [REM_WORDS*8-1:0] 	   rem_bytes;
   assign rem_bytes = {REM_WORDS*8{1'b0}};

   reg 						 din_valid_d1;
   reg [(W2_WIDTH+1)*8-1:0]  din_d1;
   reg [4:0] 				 din_offset_d1 /* synthesis preserve */;
   reg [4:0] 				 din_offset_cp_d1 /* synthesis preserve */;
   reg 						 din_ipg_d1;
//   reg [(W2_WIDTH+1)*8-1:0]  din_alt;

//   always @(*)
//	 din_alt = (din << 16);

   always @(posedge clk)
	 begin
		din_valid_d1 <= din_valid;
		case (fld) // synthesis parallel_case
		  2'b11: begin
			if (din_spl_hndl)
			  din_d1 <= {((W2_WIDTH+1)*8-1){1'b0}}; // spl handling. checksum set to 0
			else
			  din_d1 <= din;
		  end
		  2'b01: begin
//			 if (din_spl_hndl)
//			   din_d1 <= din_alt;
//			   din_d1 <= {din[(W2_WIDTH-1)*8-1:0],16'd0};
//			 else
			   din_d1 <= din;
		  end
		  default: begin
			 din_d1 <= din;
		  end
		endcase // case (fld)
		din_offset_d1 <= din_offset;
		din_offset_cp_d1 <= din_offset;
		din_ipg_d1 <= din_ipg;
	 end

   // shift based on 2 lsbs. At the most by 3 bytes
   reg 						 din_valid_d2;
   reg [(W2_WIDTH+4)*8-1:0]  din_d2;
   reg [4:0] 				 din_offset_d2 /* synthesis preserve */;
   reg [4:0] 				 din_offset_cp1_d2 /* synthesis preserve */;
   reg [4:0] 				 din_offset_cp2_d2 /* synthesis preserve */;
   reg [W2_WIDTH+4-1:0] 	 din_mask_d2;
   reg 						 din_ipg_d2;

   wire [(W2_WIDTH+4)*8-1:0]					 vec00_d1;
   wire [(W2_WIDTH+4)*8-1:0]					 vec01_d1;
   wire [(W2_WIDTH+4)*8-1:0]					 vec10_d1;
   wire [(W2_WIDTH+4)*8-1:0]					 vec11_d1;

   assign vec00_d1 = {din_d1,24'd0};
   assign vec01_d1 = {8'd0,din_d1,16'd0};
   assign vec10_d1 = {16'd0,din_d1,8'd0};
   assign vec11_d1 = {24'd0,din_d1};

   always @(posedge clk)
	 begin
		din_valid_d2 <= din_valid_d1;
		din_offset_d2 <= din_offset_d1;
		din_offset_cp1_d2 <= din_offset_cp_d1;
		din_offset_cp2_d2 <= din_offset_cp_d1;
		din_ipg_d2 <= din_ipg_d1;
	 end // always @ (posedge clk)

   always @(posedge clk)
	 begin
		case (din_offset_d1[1:0]) // synthesis parallel_case
		  2'b00: din_d2 <= vec00_d1;
		  2'b01: din_d2 <= vec01_d1;
		  2'b10: din_d2 <= vec10_d1;
		  2'b11: din_d2 <= vec11_d1;
		endcase // case (din_offset_d1[3:2])
	 end

   wire [W2_WIDTH:0] mask_d1;
   assign mask_d1 = ~(0);
   
   wire [W2_WIDTH:0] mask_d1_corr;
   assign mask_d1_corr = {{(W2_WIDTH-1){1'b1}},2'b00};

   reg [W2_WIDTH:0] din_mask_d1;
   always @(posedge clk)
	 begin
		if ((fld == 2'b01) & (din_spl_hndl))
		  din_mask_d1 <= mask_d1_corr;
		else
		  din_mask_d1 <= mask_d1;
	 end
   
   always @(posedge clk)
	 begin
		if (din_valid_d1)
		  begin
			 case (din_offset_cp_d1[1:0]) // synthesis parallel_case
			   2'b00: din_mask_d2 <= {din_mask_d1,3'd0};
			   2'b01: din_mask_d2 <= {1'b0,din_mask_d1,2'b00};
			   2'b10: din_mask_d2 <= {2'b00,din_mask_d1,1'b0};
			   2'b11: din_mask_d2 <= {3'd0,din_mask_d1};
			 endcase // case (din_offset_cp_d1)
		  end // else: !if(din_valid_d1)
		else
		  begin
			 din_mask_d2 <= {W2_WIDTH+4{1'b0}};
		  end
	 end

   reg 						 din_valid_d3;
   reg [4:0] 				 din_offset_d3 /* synthesis preserve */;
   reg [4:0] 				 din_offset_cp1_d3 /* synthesis preserve */;
   reg [4:0] 				 din_offset_cp2_d3 /* synthesis preserve */;
   reg [MAX_WIDTH*8-1:0]  din_d3;
   reg [MAX_WIDTH-1:0] 	  din_mask_d3;
   reg 					  din_ipg_d3;

   always @(posedge clk)
	 begin
		din_valid_d3 <= din_valid_d2;
		din_offset_d3 <= din_offset_d2;
		din_offset_cp1_d3 <= din_offset_cp1_d2;
		din_offset_cp2_d3 <= din_offset_cp2_d2;
		din_ipg_d3 <= din_ipg_d2;
	 end // always @ (posedge clk)

   wire [MAX_WIDTH*8-1:0] vec00_d2;
   wire [MAX_WIDTH*8-1:0] vec01_d2;
   wire [MAX_WIDTH*8-1:0] vec10_d2;
   wire [MAX_WIDTH*8-1:0] vec11_d2;
   
   assign vec00_d2 = {din_d2,96'd0};
   assign vec01_d2 = {32'd0,din_d2,64'd0};
   assign vec10_d2 = {64'd0,din_d2,32'd0};
   assign vec11_d2 = {96'd0,din_d2};

   always @(posedge clk)
	 begin
		case (din_offset_d2[3:2]) // synthesis parallel_case
		  2'b00: din_d3[MAX_WIDTH*8-1:(MAX_WIDTH-8)*8] <= vec00_d2[MAX_WIDTH*8-1:(MAX_WIDTH-8)*8];
		  2'b01: din_d3[MAX_WIDTH*8-1:(MAX_WIDTH-8)*8] <= vec01_d2[MAX_WIDTH*8-1:(MAX_WIDTH-8)*8];
		  2'b10: din_d3[MAX_WIDTH*8-1:(MAX_WIDTH-8)*8] <= vec10_d2[MAX_WIDTH*8-1:(MAX_WIDTH-8)*8];
		  2'b11: din_d3[MAX_WIDTH*8-1:(MAX_WIDTH-8)*8] <= vec11_d2[MAX_WIDTH*8-1:(MAX_WIDTH-8)*8];
		endcase // case (din_offset_d2[3:2])
	 end // always @ (posedge clk)

   always @(posedge clk)
	 begin
		case (din_offset_cp1_d2[3:2]) // synthesis parallel_case
		  2'b00: din_d3[(MAX_WIDTH-8)*8-1:(MAX_WIDTH-16)*8] <= vec00_d2[(MAX_WIDTH-8)*8-1:(MAX_WIDTH-16)*8];
		  2'b01: din_d3[(MAX_WIDTH-8)*8-1:(MAX_WIDTH-16)*8] <= vec01_d2[(MAX_WIDTH-8)*8-1:(MAX_WIDTH-16)*8];
		  2'b10: din_d3[(MAX_WIDTH-8)*8-1:(MAX_WIDTH-16)*8] <= vec10_d2[(MAX_WIDTH-8)*8-1:(MAX_WIDTH-16)*8];
		  2'b11: din_d3[(MAX_WIDTH-8)*8-1:(MAX_WIDTH-16)*8] <= vec11_d2[(MAX_WIDTH-8)*8-1:(MAX_WIDTH-16)*8];
		endcase // case (din_offset_d2[3:2])
	 end // always @ (posedge clk)

   always @(posedge clk)
	 begin
		case (din_offset_cp2_d2[3:2]) // synthesis parallel_case
		  2'b00: din_d3[(MAX_WIDTH-16)*8-1:0] <= vec00_d2[(MAX_WIDTH-16)*8-1:0];
		  2'b01: din_d3[(MAX_WIDTH-16)*8-1:0] <= vec01_d2[(MAX_WIDTH-16)*8-1:0];
		  2'b10: din_d3[(MAX_WIDTH-16)*8-1:0] <= vec10_d2[(MAX_WIDTH-16)*8-1:0];
		  2'b11: din_d3[(MAX_WIDTH-16)*8-1:0] <= vec11_d2[(MAX_WIDTH-16)*8-1:0];
		endcase // case (din_offset_d2[3:2])
	 end // always @ (posedge clk)

   always @(posedge clk)
	 begin
		case (din_offset_cp2_d2[3:2]) // synthesis parallel_case
		  2'b00: din_mask_d3 <= {din_mask_d2,12'd0};
		  2'b01: din_mask_d3 <= {4'd0,din_mask_d2,8'd0};
		  2'b10: din_mask_d3 <= {8'd0,din_mask_d2,4'd0};
		  2'b11: din_mask_d3 <= {12'd0,din_mask_d2};
		endcase // case (din_offset_cp_d2)
	 end

   reg [WORDS*2*8*8-1:0]  din_d4;
   reg [WORDS*2*8-1:0] 	  din_mask_d4;
   reg [6:0] 			  din_mask_valid_d4;
   
   generate
	  if (WORDS == 4)
		begin: w4   
		   always @(posedge clk)
			 begin
				if (srst)
				  begin
					 din_mask_d4 <= {WORDS*2*8{1'b0}};
				  end
				else
				  begin
					 if (din_valid_d3)
					   begin
						  if (din_offset_d3[4] == 1'b0)
							begin
							   din_d4 <= {din_d3,rem_bytes,{WORDS*8*8{1'b0}}};
							   din_mask_d4 <= {din_mask_d3,{REM_WORDS{1'b0}},{WORDS*8{1'b0}}};
							end
						  else
							begin
							   din_d4 <= {{WORDS_DIV_2*8*8{1'b0}},din_d3,rem_bytes,{WORDS_DIV_2*8*8{1'b0}}};
							   din_mask_d4 <= {{WORDS_DIV_2*8{1'b0}},din_mask_d3,{REM_WORDS{1'b0}},{WORDS_DIV_2*8{1'b0}}};
							end // else: !if(din_offset_d3[4] == 1'b0)
					   end // if (din_valid_d3)
					 else
					   begin
						  if (din_mask_valid_d4[6] == 1'b1)
							begin
							   din_d4 <= {din_d4[WORDS*8*8-1:0],{WORDS*8*8{1'b0}}};
							   din_mask_d4 <= {din_mask_d4[WORDS*8-1:0],{WORDS*8{1'b0}}};
							end
					   end // else: !if(din_valid_d3)
				  end // else: !if(srst)
			 end // always @ (posedge clk)
		end // block: w4
	  else
		begin: w2
		   always @(posedge clk)
			 begin
				if (srst)
				  begin
					 din_mask_d4 <= {WORDS*2*8{1'b0}};
				  end
				else
				  begin
					 if (din_valid_d3)
					   begin
						  din_d4 <= {din_d3,rem_bytes};
						  din_mask_d4 <= {din_mask_d3,{REM_WORDS{1'b0}}};
					   end
					 else
					   begin
						  if (din_mask_valid_d4[6] == 1'b1)
							begin
							   din_d4 <= {din_d4[WORDS*8*8-1:0],{WORDS*8*8{1'b0}}};
							   din_mask_d4 <= {din_mask_d4[WORDS*8-1:0],{WORDS*8{1'b0}}};
							end
					   end
				  end // else: !if(srst)
			 end // always @ (posedge clk)
		end // block: w2
   endgenerate

   
   generate
	  if (WORDS == 4)
		begin: w4_1
		   always @(posedge clk)
			 begin
				if (srst)
				  din_mask_valid_d4 <= 7'b000_0000;
				else
				  begin
					 if (din_valid_d3)
					   begin
						  if (din_ipg_d3)
							din_mask_valid_d4 <= 7'b100_0001;
						  else
							din_mask_valid_d4 <= 7'b110_0000;
					   end
					 else
					   din_mask_valid_d4 <= {din_mask_valid_d4[5:0],1'b0};
				  end // else: !if(srst)
			 end // always @ (posedge clk)
		end // block: w4_1
	  else
		begin: w2_1
		   always @(posedge clk)
			 begin
				if (srst)
				  din_mask_valid_d4 <= 7'b000_0000;
				else
				  begin
					 if (din_valid_d3)
					   begin
						  if (din_ipg_d3)
							din_mask_valid_d4 <= 7'b1001_000;
						  else
							din_mask_valid_d4 <= 7'b1100_000;
					   end
					 else
					   din_mask_valid_d4 <= {din_mask_valid_d4[5:0],1'b0};
				  end // else: !if(srst)
			 end // always @ (posedge clk)
		end // block: w2_1
   endgenerate

   assign dout_valid = din_mask_valid_d4[6];
   assign dout = din_d4[WORDS*2*8*8-1:WORDS*8*8];
   assign dout_mask = din_mask_d4[WORDS*2*8-1:WORDS*8];
   
endmodule // alt_aeu_fld_shr

