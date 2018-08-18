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



// baeckler - 09-06-2010
// create a gap between packet end and the next start

module alt_aeuex_traffic_break #(
	parameter WIDTH = 64,
	parameter WORDS = 2
)(
	input clk,
	input arst,
	
	input [WIDTH*WORDS-1:0] din,
	input [WORDS-1:0] din_start,
	input [8*WORDS-1:0] din_end_pos,
	output din_ack,
	input stall_req,
    input flush,
	
	output reg [WIDTH*WORDS-1:0] dout,
	output reg [WORDS-1:0] dout_start,
	output reg [8*WORDS-1:0] dout_end_pos,
	input dout_ack,
	output reg stalled
);

initial dout = 0;
initial dout_start = 0;
initial dout_end_pos = 0;

reg stall_req_i = 0;
always @(posedge clk) begin
	stall_req_i <= stall_req;
end

reg [WIDTH*WORDS-1:0] din_r = 0, din_rr = 0;
reg [WORDS-1:0] din_start_r = 0, din_start_rr = 0;
reg [8*WORDS-1:0] din_end_pos_r = 0, din_end_pos_rr = 0;

always @(posedge clk) begin
	if (din_ack) begin
		din_r <= din;
		din_start_r <= din_start;
		din_end_pos_r <= din_end_pos;		
		din_rr <= din_r;
		din_start_rr <= din_start_r;
		din_end_pos_rr <= din_end_pos_r;		
	end
end

reg in_packet = 0;

always @(posedge clk or posedge arst) begin
	if(arst) in_packet <= 0;
	else if(din_ack)
		// this check assume previous in_packet state is correct, and you can't have more than one start or end per cycle
		// (eg runts not supported on narrow interface)
		// also, if there's never a clean break (end without start), the fifo can underflow.
		in_packet <= (|din_start_r && !(|din_end_pos_r)) ||
					 ( in_packet   && !(|din_end_pos_r)) ||
					 (|din_start_r &&  (|din_end_pos_r) && in_packet);
end

wire stalled_i;

assign stalled_i = !((|din_start || |din_start_r) && flush) && 
                    (stall_req_i && (!in_packet || stalled));
assign din_ack = dout_ack && !stalled;


always @(posedge clk) begin
	if (dout_ack) begin
		dout <= stalled ? 0 : din_rr;
		dout_start <= stalled ? {WORDS{1'b0}} : din_start_rr;
		dout_end_pos <= stalled ? 0 : din_end_pos_rr;	

		stalled <= stalled_i;
	end
end

endmodule
