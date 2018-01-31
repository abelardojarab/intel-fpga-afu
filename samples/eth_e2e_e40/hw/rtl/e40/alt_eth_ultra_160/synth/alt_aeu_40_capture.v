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
// baeckler - 08-25-2012
// capture samples around the first trigger after sclr

module alt_aeu_40_capture #(
	parameter TARGET_CHIP = 2
)(
	input clk,
	input sclr,
	input trigger,
	input [15:0] din_reg,
	
	input [3:0] raddr,
	output [15:0] dout		
);

reg [3:0] addr = 0;
reg wena = 1'b0;
reg [3:0] center = 0;
reg [3:0] stop_cnt = 4'h0;
reg triggered = 1'b0;
wire [15:0] dout_w;

// recenter read requests
reg [3:0] raddr_adj = 0;
always @(posedge clk) begin
	raddr_adj <= center + raddr;
end

// black out data if the capture hasn't triggered
reg [15:0] dout_r = 0;
always @(posedge clk) begin
	dout_r <= dout_w & {16{stop_cnt[3]}};
end
assign dout = dout_r;

generate
	if (TARGET_CHIP == 2) begin
		// storage
		s5mlab ml (
			.wclk(clk),
			.wena(wena),
			.waddr_reg(addr),
			.wdata_reg(din_reg),
			.raddr(raddr_adj),
			.rdata(dout_w)		
		);
		defparam ml .WIDTH = 16;
		defparam ml .ADDR_WIDTH = 4;
	end
	else if (TARGET_CHIP == 5) begin
		// storage
		a10mlab ml (
			.wclk(clk),
			.wena(wena),
			.waddr_reg(addr),
			.wdata_reg(din_reg),
			.raddr(raddr_adj),
			.rdata(dout_w)		
		);
		defparam ml .WIDTH = 16;
		defparam ml .ADDR_WIDTH = 4;
	end
endgenerate
	
	
// control
always @(posedge clk) begin
	if (sclr) begin
		wena <= 1'b1;
		addr <= 4'h0;
		center <= 4'h0;
		stop_cnt <= 4'h0;
		triggered <= 1'b0;
	end
	else begin
		addr <= addr + 1'b1;
		if (trigger && !triggered) begin
			center <= addr;
			triggered <= 1'b1;
		end
		if (triggered) begin
			if (stop_cnt[3]) wena <= 1'b0;
			else stop_cnt <= stop_cnt + 1'b1;
		end				
	end
end

endmodule
