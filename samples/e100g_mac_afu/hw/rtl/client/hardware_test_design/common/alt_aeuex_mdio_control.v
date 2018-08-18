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



`timescale 1 ps / 1 ps
// baeckler - 01-23-2010

module alt_aeuex_mdio_control (
	input sys_clk,
	input [4:0] addr1, addr2,
	
	// commands
	input read,					// regular read
	input read_post_inc,        // read and advance the address
	input write,				// regular data write
	input write_address,		// write wdata to the address register
	
	output reg [15:0] rdata,
	output reg rdata_valid,
	input [15:0] wdata,
	output reg busy,			// when busy R/W will be ignored
		
	// to MDIO peripheral
	output reg mdio_clk,
	output mdio_out,
	output mdio_oe,
	input mdio_in		
);

`include "alt_aeuex_log2.iv"

parameter CLOCK_DIVIDE = 25;
localparam HALF_DIVIDE = CLOCK_DIVIDE >> 1'b1;
localparam DIVIDE_BITS = alt_aeuex_log2(CLOCK_DIVIDE);

//////////////////////////////////////////
// slow down the clock
//////////////////////////////////////////

reg [DIVIDE_BITS-1:0] div_cntr = 0 /* synthesis preserve_syn_only */;
reg mdc_rise = 0, mdc_fall = 0;
initial mdio_clk = 1'b1;

always @(posedge sys_clk) begin
	mdc_rise <= 0;
	mdc_fall <= 0;
	
	if (div_cntr == (CLOCK_DIVIDE-1)) begin
		div_cntr <= 0;	
		mdc_rise <= 1'b1;
		mdio_clk <= 1'b1;
	end
	else div_cntr <= div_cntr + 1'b1;
	
	if (div_cntr == (HALF_DIVIDE-1)) begin
		mdc_fall <= 1'b1;	
		mdio_clk <= 1'b0;
	end
end

//////////////////////////////////////////
// MDIO shifters
//////////////////////////////////////////

reg [64:0] mdio_dsr = 0 /* synthesis preserve_syn_only */;
reg [64:0] mdio_osr = 0 /* synthesis preserve_syn_only */;
reg [6:0] mdio_holding = 0;
reg [4:0] mdio_a1;
reg [4:0] mdio_a2;
reg [15:0] mdio_wdata= 0;
reg [15:0] mdio_rsr = 0 /* synthesis preserve_syn_only */;
wire holding_any = |mdio_holding;
reg mdio_rd_req = 0, mdio_wr_req = 0;
reg mdio_completed = 0;
reg last_read = 1'b0;
reg special_mode = 1'b0;  // 1 for write address or read post inc

always @(posedge sys_clk) begin
	if (mdc_fall) begin
		if (mdio_rd_req) begin
			// opcodes 11 read or 10 read post increment
			mdio_dsr <= {1'b0, 32'hffffffff, 2'b00, 1'b1,special_mode^1'b1, mdio_a1, mdio_a2, 2'b10, 16'b0};
			mdio_osr <= {1'b0, 32'hffffffff, 2'b11, 2'b11, 5'b11111, 5'b11111, 2'b00, 16'h0};		
			mdio_holding <= 7'd65;
			last_read <= 1'b1;
		end
		else if (mdio_wr_req) begin
			// opcodes 01 write or 00 write addr
			mdio_dsr <= {1'b0, 32'hffffffff, 2'b00, 1'b0,special_mode^1'b1, mdio_a1, mdio_a2, 2'b10, mdio_wdata};
			mdio_osr <= {1'b0, 32'hffffffff, 2'b11, 2'b11, 5'b11111, 5'b11111, 2'b11, 16'hffff};			
			mdio_holding <= 7'd65;
			last_read <= 1'b0;
		end
		else begin
			mdio_dsr <= {mdio_dsr [63:0],1'b0};
			mdio_osr <= {mdio_osr [63:0],1'b0};
			if (holding_any) mdio_holding <= mdio_holding - 1'b1;		
		end	
	end	
end

reg last_holding_any = 0;
initial rdata = 0;
initial rdata_valid = 1'b0;
always @(posedge sys_clk) begin
	rdata_valid <= 1'b0;
	if (mdc_rise) begin
		mdio_completed <= 1'b0;
		last_holding_any <= holding_any;
		mdio_rsr <= {mdio_rsr[14:0],mdio_in};
		if (!holding_any && last_holding_any) begin
			if (last_read) begin
				// write will readback, but don't bother reporting it
				rdata <= mdio_rsr;
				rdata_valid <= 1'b1;
			end
			mdio_completed <= 1'b1;
		end
	end
end

assign mdio_out = mdio_dsr[64];
assign mdio_oe = mdio_osr[64];

//////////////////////////////////////////
// manage system read and write reqs
//////////////////////////////////////////

initial busy = 0;

/////////////////////////
// dev_clr sync-reset
/////////////////////////
wire user_mode_sync;
alt_aeuex_user_mode_det dev_clr(
    .ref_clk(sys_clk),
    .user_mode_sync(user_mode_sync)
);

//always @(posedge sys_clk) begin
always @(posedge sys_clk or negedge user_mode_sync) begin
   if (!user_mode_sync) begin
        busy <= 1'b0;
   end
   else begin
	if (!busy) begin
		// take a new request?
		if (read | write | write_address | read_post_inc) begin
			mdio_a1 <= addr1;
			mdio_a2 <= addr2;
			mdio_rd_req <= read | read_post_inc;
			mdio_wr_req <= write | write_address;
			special_mode <= write_address | read_post_inc;
			mdio_wdata <= wdata;
			busy <= 1'b1;		
		end		
	end
	
	if (mdc_fall & (mdio_rd_req | mdio_wr_req)) begin
		// the request is now in progress
		mdio_rd_req <= 1'b0;
		mdio_wr_req <= 1'b0;		
	end
	
	if (mdc_fall & mdio_completed) begin
		// transmission is complete, ready for new job
		busy <= 1'b0;
	end
   end
end

endmodule
