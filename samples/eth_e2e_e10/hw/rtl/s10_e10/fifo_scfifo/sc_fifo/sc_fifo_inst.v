	sc_fifo u0 (
		.rx_sc_fifo_almost_empty_data (_connected_to_rx_sc_fifo_almost_empty_data_), //  output,   width = 1, rx_sc_fifo_almost_empty.data
		.rx_sc_fifo_almost_full_data  (_connected_to_rx_sc_fifo_almost_full_data_),  //  output,   width = 1,  rx_sc_fifo_almost_full.data
		.rx_sc_fifo_clk_clk           (_connected_to_rx_sc_fifo_clk_clk_),           //   input,   width = 1,          rx_sc_fifo_clk.clk
		.rx_sc_fifo_clk_reset_reset   (_connected_to_rx_sc_fifo_clk_reset_reset_),   //   input,   width = 1,    rx_sc_fifo_clk_reset.reset
		.rx_sc_fifo_csr_address       (_connected_to_rx_sc_fifo_csr_address_),       //   input,   width = 3,          rx_sc_fifo_csr.address
		.rx_sc_fifo_csr_read          (_connected_to_rx_sc_fifo_csr_read_),          //   input,   width = 1,                        .read
		.rx_sc_fifo_csr_write         (_connected_to_rx_sc_fifo_csr_write_),         //   input,   width = 1,                        .write
		.rx_sc_fifo_csr_readdata      (_connected_to_rx_sc_fifo_csr_readdata_),      //  output,  width = 32,                        .readdata
		.rx_sc_fifo_csr_writedata     (_connected_to_rx_sc_fifo_csr_writedata_),     //   input,  width = 32,                        .writedata
		.rx_sc_fifo_in_data           (_connected_to_rx_sc_fifo_in_data_),           //   input,  width = 64,           rx_sc_fifo_in.data
		.rx_sc_fifo_in_valid          (_connected_to_rx_sc_fifo_in_valid_),          //   input,   width = 1,                        .valid
		.rx_sc_fifo_in_ready          (_connected_to_rx_sc_fifo_in_ready_),          //  output,   width = 1,                        .ready
		.rx_sc_fifo_in_startofpacket  (_connected_to_rx_sc_fifo_in_startofpacket_),  //   input,   width = 1,                        .startofpacket
		.rx_sc_fifo_in_endofpacket    (_connected_to_rx_sc_fifo_in_endofpacket_),    //   input,   width = 1,                        .endofpacket
		.rx_sc_fifo_in_empty          (_connected_to_rx_sc_fifo_in_empty_),          //   input,   width = 3,                        .empty
		.rx_sc_fifo_in_error          (_connected_to_rx_sc_fifo_in_error_),          //   input,   width = 6,                        .error
		.rx_sc_fifo_out_data          (_connected_to_rx_sc_fifo_out_data_),          //  output,  width = 64,          rx_sc_fifo_out.data
		.rx_sc_fifo_out_valid         (_connected_to_rx_sc_fifo_out_valid_),         //  output,   width = 1,                        .valid
		.rx_sc_fifo_out_ready         (_connected_to_rx_sc_fifo_out_ready_),         //   input,   width = 1,                        .ready
		.rx_sc_fifo_out_startofpacket (_connected_to_rx_sc_fifo_out_startofpacket_), //  output,   width = 1,                        .startofpacket
		.rx_sc_fifo_out_endofpacket   (_connected_to_rx_sc_fifo_out_endofpacket_),   //  output,   width = 1,                        .endofpacket
		.rx_sc_fifo_out_empty         (_connected_to_rx_sc_fifo_out_empty_),         //  output,   width = 3,                        .empty
		.rx_sc_fifo_out_error         (_connected_to_rx_sc_fifo_out_error_),         //  output,   width = 6,                        .error
		.tx_sc_fifo_clk_clk           (_connected_to_tx_sc_fifo_clk_clk_),           //   input,   width = 1,          tx_sc_fifo_clk.clk
		.tx_sc_fifo_clk_reset_reset   (_connected_to_tx_sc_fifo_clk_reset_reset_),   //   input,   width = 1,    tx_sc_fifo_clk_reset.reset
		.tx_sc_fifo_csr_address       (_connected_to_tx_sc_fifo_csr_address_),       //   input,   width = 3,          tx_sc_fifo_csr.address
		.tx_sc_fifo_csr_read          (_connected_to_tx_sc_fifo_csr_read_),          //   input,   width = 1,                        .read
		.tx_sc_fifo_csr_write         (_connected_to_tx_sc_fifo_csr_write_),         //   input,   width = 1,                        .write
		.tx_sc_fifo_csr_readdata      (_connected_to_tx_sc_fifo_csr_readdata_),      //  output,  width = 32,                        .readdata
		.tx_sc_fifo_csr_writedata     (_connected_to_tx_sc_fifo_csr_writedata_),     //   input,  width = 32,                        .writedata
		.tx_sc_fifo_in_data           (_connected_to_tx_sc_fifo_in_data_),           //   input,  width = 64,           tx_sc_fifo_in.data
		.tx_sc_fifo_in_valid          (_connected_to_tx_sc_fifo_in_valid_),          //   input,   width = 1,                        .valid
		.tx_sc_fifo_in_ready          (_connected_to_tx_sc_fifo_in_ready_),          //  output,   width = 1,                        .ready
		.tx_sc_fifo_in_startofpacket  (_connected_to_tx_sc_fifo_in_startofpacket_),  //   input,   width = 1,                        .startofpacket
		.tx_sc_fifo_in_endofpacket    (_connected_to_tx_sc_fifo_in_endofpacket_),    //   input,   width = 1,                        .endofpacket
		.tx_sc_fifo_in_empty          (_connected_to_tx_sc_fifo_in_empty_),          //   input,   width = 3,                        .empty
		.tx_sc_fifo_in_error          (_connected_to_tx_sc_fifo_in_error_),          //   input,   width = 1,                        .error
		.tx_sc_fifo_out_data          (_connected_to_tx_sc_fifo_out_data_),          //  output,  width = 64,          tx_sc_fifo_out.data
		.tx_sc_fifo_out_valid         (_connected_to_tx_sc_fifo_out_valid_),         //  output,   width = 1,                        .valid
		.tx_sc_fifo_out_ready         (_connected_to_tx_sc_fifo_out_ready_),         //   input,   width = 1,                        .ready
		.tx_sc_fifo_out_startofpacket (_connected_to_tx_sc_fifo_out_startofpacket_), //  output,   width = 1,                        .startofpacket
		.tx_sc_fifo_out_endofpacket   (_connected_to_tx_sc_fifo_out_endofpacket_),   //  output,   width = 1,                        .endofpacket
		.tx_sc_fifo_out_empty         (_connected_to_tx_sc_fifo_out_empty_),         //  output,   width = 3,                        .empty
		.tx_sc_fifo_out_error         (_connected_to_tx_sc_fifo_out_error_)          //  output,   width = 1,                        .error
	);

