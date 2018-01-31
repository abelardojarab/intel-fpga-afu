
module dc_fifo_0 (
	in_data,
	in_valid,
	in_ready,
	in_startofpacket,
	in_endofpacket,
	in_empty,
	in_error,
	in_clk,
	in_reset_n,
	out_data,
	out_valid,
	out_ready,
	out_startofpacket,
	out_endofpacket,
	out_empty,
	out_error,
	out_clk,
	out_reset_n);	

	input	[31:0]	in_data;
	input		in_valid;
	output		in_ready;
	input		in_startofpacket;
	input		in_endofpacket;
	input	[1:0]	in_empty;
	input	[0:0]	in_error;
	input		in_clk;
	input		in_reset_n;
	output	[31:0]	out_data;
	output		out_valid;
	input		out_ready;
	output		out_startofpacket;
	output		out_endofpacket;
	output	[1:0]	out_empty;
	output	[0:0]	out_error;
	input		out_clk;
	input		out_reset_n;
endmodule
