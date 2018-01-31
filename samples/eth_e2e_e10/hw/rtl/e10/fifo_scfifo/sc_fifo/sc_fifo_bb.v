
module sc_fifo (
	rx_sc_fifo_almost_empty_data,
	rx_sc_fifo_almost_full_data,
	rx_sc_fifo_clk_clk,
	rx_sc_fifo_clk_reset_reset,
	rx_sc_fifo_csr_address,
	rx_sc_fifo_csr_read,
	rx_sc_fifo_csr_write,
	rx_sc_fifo_csr_readdata,
	rx_sc_fifo_csr_writedata,
	rx_sc_fifo_in_data,
	rx_sc_fifo_in_valid,
	rx_sc_fifo_in_ready,
	rx_sc_fifo_in_startofpacket,
	rx_sc_fifo_in_endofpacket,
	rx_sc_fifo_in_empty,
	rx_sc_fifo_in_error,
	rx_sc_fifo_out_data,
	rx_sc_fifo_out_valid,
	rx_sc_fifo_out_ready,
	rx_sc_fifo_out_startofpacket,
	rx_sc_fifo_out_endofpacket,
	rx_sc_fifo_out_empty,
	rx_sc_fifo_out_error,
	tx_sc_fifo_clk_clk,
	tx_sc_fifo_clk_reset_reset,
	tx_sc_fifo_csr_address,
	tx_sc_fifo_csr_read,
	tx_sc_fifo_csr_write,
	tx_sc_fifo_csr_readdata,
	tx_sc_fifo_csr_writedata,
	tx_sc_fifo_in_data,
	tx_sc_fifo_in_valid,
	tx_sc_fifo_in_ready,
	tx_sc_fifo_in_startofpacket,
	tx_sc_fifo_in_endofpacket,
	tx_sc_fifo_in_empty,
	tx_sc_fifo_in_error,
	tx_sc_fifo_out_data,
	tx_sc_fifo_out_valid,
	tx_sc_fifo_out_ready,
	tx_sc_fifo_out_startofpacket,
	tx_sc_fifo_out_endofpacket,
	tx_sc_fifo_out_empty,
	tx_sc_fifo_out_error);	

	output		rx_sc_fifo_almost_empty_data;
	output		rx_sc_fifo_almost_full_data;
	input		rx_sc_fifo_clk_clk;
	input		rx_sc_fifo_clk_reset_reset;
	input	[2:0]	rx_sc_fifo_csr_address;
	input		rx_sc_fifo_csr_read;
	input		rx_sc_fifo_csr_write;
	output	[31:0]	rx_sc_fifo_csr_readdata;
	input	[31:0]	rx_sc_fifo_csr_writedata;
	input	[63:0]	rx_sc_fifo_in_data;
	input		rx_sc_fifo_in_valid;
	output		rx_sc_fifo_in_ready;
	input		rx_sc_fifo_in_startofpacket;
	input		rx_sc_fifo_in_endofpacket;
	input	[2:0]	rx_sc_fifo_in_empty;
	input	[5:0]	rx_sc_fifo_in_error;
	output	[63:0]	rx_sc_fifo_out_data;
	output		rx_sc_fifo_out_valid;
	input		rx_sc_fifo_out_ready;
	output		rx_sc_fifo_out_startofpacket;
	output		rx_sc_fifo_out_endofpacket;
	output	[2:0]	rx_sc_fifo_out_empty;
	output	[5:0]	rx_sc_fifo_out_error;
	input		tx_sc_fifo_clk_clk;
	input		tx_sc_fifo_clk_reset_reset;
	input	[2:0]	tx_sc_fifo_csr_address;
	input		tx_sc_fifo_csr_read;
	input		tx_sc_fifo_csr_write;
	output	[31:0]	tx_sc_fifo_csr_readdata;
	input	[31:0]	tx_sc_fifo_csr_writedata;
	input	[63:0]	tx_sc_fifo_in_data;
	input		tx_sc_fifo_in_valid;
	output		tx_sc_fifo_in_ready;
	input		tx_sc_fifo_in_startofpacket;
	input		tx_sc_fifo_in_endofpacket;
	input	[2:0]	tx_sc_fifo_in_empty;
	input	[0:0]	tx_sc_fifo_in_error;
	output	[63:0]	tx_sc_fifo_out_data;
	output		tx_sc_fifo_out_valid;
	input		tx_sc_fifo_out_ready;
	output		tx_sc_fifo_out_startofpacket;
	output		tx_sc_fifo_out_endofpacket;
	output	[2:0]	tx_sc_fifo_out_empty;
	output	[0:0]	tx_sc_fifo_out_error;
endmodule
