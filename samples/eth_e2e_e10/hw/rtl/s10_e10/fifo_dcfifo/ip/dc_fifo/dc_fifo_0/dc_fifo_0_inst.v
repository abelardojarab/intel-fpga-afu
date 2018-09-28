	dc_fifo_0 #(
		.SYMBOLS_PER_BEAT   (INTEGER_VALUE_FOR_SYMBOLS_PER_BEAT),
		.BITS_PER_SYMBOL    (INTEGER_VALUE_FOR_BITS_PER_SYMBOL),
		.FIFO_DEPTH         (INTEGER_VALUE_FOR_FIFO_DEPTH),
		.CHANNEL_WIDTH      (INTEGER_VALUE_FOR_CHANNEL_WIDTH),
		.ERROR_WIDTH        (INTEGER_VALUE_FOR_ERROR_WIDTH),
		.USE_PACKETS        (INTEGER_VALUE_FOR_USE_PACKETS),
		.USE_IN_FILL_LEVEL  (INTEGER_VALUE_FOR_USE_IN_FILL_LEVEL),
		.USE_OUT_FILL_LEVEL (INTEGER_VALUE_FOR_USE_OUT_FILL_LEVEL),
		.WR_SYNC_DEPTH      (INTEGER_VALUE_FOR_WR_SYNC_DEPTH),
		.RD_SYNC_DEPTH      (INTEGER_VALUE_FOR_RD_SYNC_DEPTH)
	) u0 (
		.in_clk            (_connected_to_in_clk_),            //   input,   width = 1,        in_clk.clk
		.in_reset_n        (_connected_to_in_reset_n_),        //   input,   width = 1,  in_clk_reset.reset_n
		.out_clk           (_connected_to_out_clk_),           //   input,   width = 1,       out_clk.clk
		.out_reset_n       (_connected_to_out_reset_n_),       //   input,   width = 1, out_clk_reset.reset_n
		.in_data           (_connected_to_in_data_),           //   input,  width = 32,            in.data
		.in_valid          (_connected_to_in_valid_),          //   input,   width = 1,              .valid
		.in_ready          (_connected_to_in_ready_),          //  output,   width = 1,              .ready
		.in_startofpacket  (_connected_to_in_startofpacket_),  //   input,   width = 1,              .startofpacket
		.in_endofpacket    (_connected_to_in_endofpacket_),    //   input,   width = 1,              .endofpacket
		.in_empty          (_connected_to_in_empty_),          //   input,   width = 2,              .empty
		.in_error          (_connected_to_in_error_),          //   input,   width = 1,              .error
		.out_data          (_connected_to_out_data_),          //  output,  width = 32,           out.data
		.out_valid         (_connected_to_out_valid_),         //  output,   width = 1,              .valid
		.out_ready         (_connected_to_out_ready_),         //   input,   width = 1,              .ready
		.out_startofpacket (_connected_to_out_startofpacket_), //  output,   width = 1,              .startofpacket
		.out_endofpacket   (_connected_to_out_endofpacket_),   //  output,   width = 1,              .endofpacket
		.out_empty         (_connected_to_out_empty_),         //  output,   width = 2,              .empty
		.out_error         (_connected_to_out_error_)          //  output,   width = 1,              .error
	);

