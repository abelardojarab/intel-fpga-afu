	sc_fifo_tx_sc_fifo #(
		.SYMBOLS_PER_BEAT    (INTEGER_VALUE_FOR_SYMBOLS_PER_BEAT),
		.BITS_PER_SYMBOL     (INTEGER_VALUE_FOR_BITS_PER_SYMBOL),
		.FIFO_DEPTH          (INTEGER_VALUE_FOR_FIFO_DEPTH),
		.CHANNEL_WIDTH       (INTEGER_VALUE_FOR_CHANNEL_WIDTH),
		.ERROR_WIDTH         (INTEGER_VALUE_FOR_ERROR_WIDTH),
		.USE_PACKETS         (INTEGER_VALUE_FOR_USE_PACKETS),
		.USE_FILL_LEVEL      (INTEGER_VALUE_FOR_USE_FILL_LEVEL),
		.EMPTY_LATENCY       (INTEGER_VALUE_FOR_EMPTY_LATENCY),
		.USE_MEMORY_BLOCKS   (INTEGER_VALUE_FOR_USE_MEMORY_BLOCKS),
		.USE_STORE_FORWARD   (INTEGER_VALUE_FOR_USE_STORE_FORWARD),
		.USE_ALMOST_FULL_IF  (INTEGER_VALUE_FOR_USE_ALMOST_FULL_IF),
		.USE_ALMOST_EMPTY_IF (INTEGER_VALUE_FOR_USE_ALMOST_EMPTY_IF)
	) u0 (
		.clk               (_connected_to_clk_),               //   input,   width = 1,       clk.clk
		.reset             (_connected_to_reset_),             //   input,   width = 1, clk_reset.reset
		.csr_address       (_connected_to_csr_address_),       //   input,   width = 3,       csr.address
		.csr_read          (_connected_to_csr_read_),          //   input,   width = 1,          .read
		.csr_write         (_connected_to_csr_write_),         //   input,   width = 1,          .write
		.csr_readdata      (_connected_to_csr_readdata_),      //  output,  width = 32,          .readdata
		.csr_writedata     (_connected_to_csr_writedata_),     //   input,  width = 32,          .writedata
		.in_data           (_connected_to_in_data_),           //   input,  width = 64,        in.data
		.in_valid          (_connected_to_in_valid_),          //   input,   width = 1,          .valid
		.in_ready          (_connected_to_in_ready_),          //  output,   width = 1,          .ready
		.in_startofpacket  (_connected_to_in_startofpacket_),  //   input,   width = 1,          .startofpacket
		.in_endofpacket    (_connected_to_in_endofpacket_),    //   input,   width = 1,          .endofpacket
		.in_empty          (_connected_to_in_empty_),          //   input,   width = 3,          .empty
		.in_error          (_connected_to_in_error_),          //   input,   width = 1,          .error
		.out_data          (_connected_to_out_data_),          //  output,  width = 64,       out.data
		.out_valid         (_connected_to_out_valid_),         //  output,   width = 1,          .valid
		.out_ready         (_connected_to_out_ready_),         //   input,   width = 1,          .ready
		.out_startofpacket (_connected_to_out_startofpacket_), //  output,   width = 1,          .startofpacket
		.out_endofpacket   (_connected_to_out_endofpacket_),   //  output,   width = 1,          .endofpacket
		.out_empty         (_connected_to_out_empty_),         //  output,   width = 3,          .empty
		.out_error         (_connected_to_out_error_)          //  output,   width = 1,          .error
	);

