
module dc_fifo (
	dc_fifo_0_in_data,
	dc_fifo_0_in_valid,
	dc_fifo_0_in_ready,
	dc_fifo_0_in_startofpacket,
	dc_fifo_0_in_endofpacket,
	dc_fifo_0_in_empty,
	dc_fifo_0_in_error,
	dc_fifo_0_in_clk_clk,
	dc_fifo_0_in_clk_reset_reset_n,
	dc_fifo_0_out_data,
	dc_fifo_0_out_valid,
	dc_fifo_0_out_ready,
	dc_fifo_0_out_startofpacket,
	dc_fifo_0_out_endofpacket,
	dc_fifo_0_out_empty,
	dc_fifo_0_out_error,
	dc_fifo_0_out_clk_clk,
	dc_fifo_0_out_clk_reset_reset_n);	

	input	[31:0]	dc_fifo_0_in_data;
	input		dc_fifo_0_in_valid;
	output		dc_fifo_0_in_ready;
	input		dc_fifo_0_in_startofpacket;
	input		dc_fifo_0_in_endofpacket;
	input	[1:0]	dc_fifo_0_in_empty;
	input	[0:0]	dc_fifo_0_in_error;
	input		dc_fifo_0_in_clk_clk;
	input		dc_fifo_0_in_clk_reset_reset_n;
	output	[31:0]	dc_fifo_0_out_data;
	output		dc_fifo_0_out_valid;
	input		dc_fifo_0_out_ready;
	output		dc_fifo_0_out_startofpacket;
	output		dc_fifo_0_out_endofpacket;
	output	[1:0]	dc_fifo_0_out_empty;
	output	[0:0]	dc_fifo_0_out_error;
	input		dc_fifo_0_out_clk_clk;
	input		dc_fifo_0_out_clk_reset_reset_n;
endmodule
