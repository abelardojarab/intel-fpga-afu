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


// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/ast/alt_e100s10_wide_word_ram_8.v#1 $
// $Revision: #1 $
// $Date: 2013/02/27 $
// $Author: pscheidt $
//-----------------------------------------------------------------------------
// Copyright 2010 Altera Corporation. All rights reserved.  
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

// baeckler - 05-15-2009
// RAM with built in barrel shift to address by words
// on a multiword bus

`timescale 1 ps / 1 ps

module alt_e100s10_wide_word_ram_8 #(
	parameter WORD_WIDTH = 64,
	parameter NUM_WORDS = 8,  // barrel shifter mod required to override
	parameter ADDR_WIDTH = 8,
	parameter TARGET_CHIP = 2
)
(
	input clk,
    input [9:0] srst,
	input [NUM_WORDS * WORD_WIDTH-1:0] din,
	input [ADDR_WIDTH-1:0] wr_addr,		// addressing is in words
	input we,
	output [NUM_WORDS * WORD_WIDTH-1:0] dout,
	input [ADDR_WIDTH-1:0] rd_addr
);

localparam HALF_WORDS = NUM_WORDS >> 1;

/////////////////////////////////////////////////////
// pipelined write data barrel shift
//   and write addressing pipeline
/////////////////////////////////////////////////////

reg [NUM_WORDS * WORD_WIDTH-1:0] din_r;
reg [ADDR_WIDTH-1:0] wr_addr_r;
reg we_r;

always @(posedge clk) begin
	if (srst[0]) begin
		din_r <= 0;
		wr_addr_r <= 0;
		we_r <= 0;
	end
	else begin
		if (wr_addr[2]) begin
			din_r <= {din[HALF_WORDS*WORD_WIDTH-1:0],
						din[NUM_WORDS*WORD_WIDTH-1:HALF_WORDS*WORD_WIDTH]};					
		end
		else begin
			din_r <= din;
		end
		wr_addr_r <= wr_addr;
		we_r <= we;
	end
end

////////////////

reg [NUM_WORDS * WORD_WIDTH-1:0] din_rr;
reg [ADDR_WIDTH-1:0] wr_addr_rr;
reg [ADDR_WIDTH-3-1:0] wr_addr_plus_rr, wr_addr_same_rr;
reg [NUM_WORDS-1:0] wr_addr_mask_rr;
reg we_rr;

always @(posedge clk) begin
	if (srst[1]) begin
		din_rr <= 0;
		we_rr <= 0;
		wr_addr_rr <= 0;
		wr_addr_plus_rr <= 0;
		wr_addr_same_rr <= 0;		
        wr_addr_mask_rr <= 8'h00;
	end
	else begin
		if (wr_addr_r[1]) begin
			din_rr <= {din_r[2*WORD_WIDTH-1:0],
						din_r[NUM_WORDS*WORD_WIDTH-1:2*WORD_WIDTH]};					
		end
		else begin
			din_rr <= din_r;
		end
		wr_addr_rr <= wr_addr_r;
		
		case (wr_addr_r[2:0])
			3'h0 : wr_addr_mask_rr <= 8'h00;
			3'h1 : wr_addr_mask_rr <= 8'h80;
			3'h2 : wr_addr_mask_rr <= 8'hc0;
			3'h3 : wr_addr_mask_rr <= 8'he0;
			3'h4 : wr_addr_mask_rr <= 8'hf0;
			3'h5 : wr_addr_mask_rr <= 8'hf8;
			3'h6 : wr_addr_mask_rr <= 8'hfc;
			3'h7 : wr_addr_mask_rr <= 8'hfe;
			default : wr_addr_mask_rr <= 8'hfe;	// LEDA
		endcase	
		
		wr_addr_plus_rr <= wr_addr_r[ADDR_WIDTH-1:3] + 1'b1;
		wr_addr_same_rr <= wr_addr_r[ADDR_WIDTH-1:3];
		
		we_rr <= we_r;
	end
end

////////////////

reg [NUM_WORDS * WORD_WIDTH-1:0] din_rrr;
reg we_rrr;
reg [(ADDR_WIDTH-3)*NUM_WORDS-1:0] widx_rrr;

always @(posedge clk) begin
	if (srst[2]) begin
		din_rrr <= 0;
		we_rrr <= 0;
	end
	else begin
		if (wr_addr_rr[0]) begin
			din_rrr <= {din_rr[WORD_WIDTH-1:0],
						din_rr[NUM_WORDS*WORD_WIDTH-1:WORD_WIDTH]};					
		end
		else begin
			din_rrr <= din_rr;
		end	
		
		we_rrr <= we_rr;
	end
end

genvar i;
generate
for (i=0; i<NUM_WORDS; i=i+1) begin : wadr
	always @(posedge clk) begin
		if (srst[3]) begin
			widx_rrr[(i+1)*(ADDR_WIDTH-3)-1:i*(ADDR_WIDTH-3)] <= 0;
		end
		else begin
			widx_rrr[(i+1)*(ADDR_WIDTH-3)-1:i*(ADDR_WIDTH-3)] <= 
				wr_addr_mask_rr[i] ? wr_addr_plus_rr : wr_addr_same_rr;							
		end
	end
end
endgenerate

/////////////////////////////////////////////////////
// read addressing pipeline
/////////////////////////////////////////////////////

reg [NUM_WORDS-1:0] rd_addr_mask_r;
reg [ADDR_WIDTH-3-1:0] rd_addr_plus_r, rd_addr_same_r;
reg [2:0] rrot_r;

always @(posedge clk) begin
	if (srst[4]) begin
		rd_addr_mask_r <= 0;
		rd_addr_plus_r <= 0;
		rd_addr_same_r <= 0;
		rrot_r <= 0;
	end
	else begin
		rrot_r <= rd_addr[2:0];
		
		case (rd_addr[2:0])
			3'h0 : rd_addr_mask_r <= 8'h00;
			3'h1 : rd_addr_mask_r <= 8'h80;
			3'h2 : rd_addr_mask_r <= 8'hc0;
			3'h3 : rd_addr_mask_r <= 8'he0;
			3'h4 : rd_addr_mask_r <= 8'hf0;
			3'h5 : rd_addr_mask_r <= 8'hf8;
			3'h6 : rd_addr_mask_r <= 8'hfc;
			3'h7 : rd_addr_mask_r <= 8'hfe;
			default : rd_addr_mask_r <= 8'hfe;	// LEDA
		endcase	
		
		rd_addr_plus_r <= rd_addr[ADDR_WIDTH-1:3] + 1'b1;
		rd_addr_same_r <= rd_addr[ADDR_WIDTH-1:3];
	end
end

/////////////////////

reg [2:0] rrot_rr;
reg [(ADDR_WIDTH-3)*NUM_WORDS-1:0] ridx_rr;

always @(posedge clk) begin
	if (srst[5]) rrot_rr <= 0;
	else rrot_rr <= rrot_r;
end

generate
for (i=0; i<NUM_WORDS; i=i+1) begin : radr
	always @(posedge clk) begin
		if (srst[6]) begin
			ridx_rr[(i+1)*(ADDR_WIDTH-3)-1:i*(ADDR_WIDTH-3)] <= 0;
		end
		else begin
			ridx_rr[(i+1)*(ADDR_WIDTH-3)-1:i*(ADDR_WIDTH-3)] <= 
				rd_addr_mask_r[i] ? rd_addr_plus_r : rd_addr_same_r;							
		end
	end
end
endgenerate

/////////////////////////////////////////////////////
// storage
/////////////////////////////////////////////////////

wire [NUM_WORDS*WORD_WIDTH-1:0] ram_dout;

localparam DEVICE_FAMILY = (TARGET_CHIP == 5) ? "Arria 10" : "Stratix V";

generate 
for (i=0; i<NUM_WORDS; i=i+1) begin : m
	altsyncram	mem (
			.wren_a (we_rrr),
			.clock0 (clk),
			.address_a (widx_rrr[(i+1)*(ADDR_WIDTH-3)-1:i*(ADDR_WIDTH-3)]),
			.address_b (ridx_rr[(i+1)*(ADDR_WIDTH-3)-1:i*(ADDR_WIDTH-3)]),
			.data_a (din_rrr[(i+1)*WORD_WIDTH-1:i*WORD_WIDTH]),
			.q_b (ram_dout[(i+1)*WORD_WIDTH-1:i*WORD_WIDTH]),
			.aclr0 (1'b0),
			.aclr1 (1'b0),
			.addressstall_a (1'b0),
			.addressstall_b (1'b0),
			.byteena_a (1'b1),
			.byteena_b (1'b1),
			.clock1 (1'b1),
			.clocken0 (1'b1),
			.clocken1 (1'b1),
			.clocken2 (1'b1),
			.clocken3 (1'b1),
			.data_b ({WORD_WIDTH{1'b1}}),
			.eccstatus (),
			.q_a (),
			.rden_a (1'b1),
			.rden_b (1'b1),
			.wren_b (1'b0));
defparam
	mem.address_aclr_b = "NONE",
	mem.address_reg_b = "CLOCK0",
	mem.clock_enable_input_a = "BYPASS",
	mem.clock_enable_input_b = "BYPASS",
	mem.clock_enable_output_b = "BYPASS",
	mem.intended_device_family = DEVICE_FAMILY,
	mem.lpm_type = "altsyncram",
	mem.numwords_a = 1 << (ADDR_WIDTH-3),
	mem.numwords_b = 1 << (ADDR_WIDTH-3),
	mem.operation_mode = "DUAL_PORT",
	mem.outdata_aclr_b = "NONE",
	mem.outdata_reg_b = "CLOCK0",
	mem.power_up_uninitialized = "FALSE",
	mem.ram_block_type = "M20K", // "MLAB", "M20K",
	mem.read_during_write_mode_mixed_ports = "DONT_CARE",
	mem.widthad_a = ADDR_WIDTH-3,
	mem.widthad_b = ADDR_WIDTH-3,
	mem.width_a = WORD_WIDTH,
	mem.width_b = WORD_WIDTH,
	mem.width_byteena_a = 1;
end
endgenerate

/////////////////////////////////////////////////////
// mimic the RAM read latency
/////////////////////////////////////////////////////

reg [2:0] rrot_rrr;
always @(posedge clk) begin
	if (srst[7]) rrot_rrr <= 0;
	else rrot_rrr <= rrot_rr;
end

reg [2:0] rrot_rrrr;
always @(posedge clk) begin
	if (srst[7]) rrot_rrrr <= 0;
	else rrot_rrrr <= rrot_rrr;
end

wire [2:0] dout_rot = rrot_rrrr;

/////////////////////////////////////////////////////
// read data out barrel shift
/////////////////////////////////////////////////////

reg [NUM_WORDS*WORD_WIDTH-1:0] dout_r;
reg [2:0] dout_rot_r;
always @(posedge clk) begin
	if (srst[8]) begin
		dout_r <= 0;
		dout_rot_r <= 0;
	end
	else begin
		dout_rot_r <= dout_rot;
		if (dout_rot[2]) begin
			dout_r <= {ram_dout[HALF_WORDS*WORD_WIDTH-1:0],
						ram_dout[NUM_WORDS*WORD_WIDTH-1:HALF_WORDS*WORD_WIDTH]};					
		end
		else begin
			dout_r <= ram_dout;
		end		
	end
end
				
reg [NUM_WORDS*WORD_WIDTH-1:0] dout_rr;
reg [2:0] dout_rot_rr;
always @(posedge clk) begin
	if (srst[8]) begin
		dout_rr <= 0;
		dout_rot_rr <= 0;
	end
	else begin
		dout_rot_rr <= dout_rot_r;
	
		if (dout_rot_r[1]) begin
			dout_rr <= {dout_r[(NUM_WORDS-2)*WORD_WIDTH-1:0],
						dout_r[NUM_WORDS*WORD_WIDTH-1:(NUM_WORDS-2)*WORD_WIDTH]};					
		end
		else begin
			dout_rr <= dout_r;
		end		
	end
end

reg [NUM_WORDS*WORD_WIDTH-1:0] dout_rrr;
always @(posedge clk) begin
	if (srst[9]) begin
		dout_rrr <= 0;
	end
	else begin
		if (dout_rot_rr[0]) begin
			dout_rrr <= {dout_rr[(NUM_WORDS-1)*WORD_WIDTH-1:0],
						dout_rr[NUM_WORDS*WORD_WIDTH-1:(NUM_WORDS-1)*WORD_WIDTH]};					
		end
		else begin
			dout_rrr <= dout_rr;
		end		
	end
end

assign dout = dout_rrr;

endmodule
