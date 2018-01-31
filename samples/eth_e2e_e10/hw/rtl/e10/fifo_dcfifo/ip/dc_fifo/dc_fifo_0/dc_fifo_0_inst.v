	dc_fifo_0 u0 (
		.in_data           (_connected_to_in_data_),           //            in.data
		.in_valid          (_connected_to_in_valid_),          //              .valid
		.in_ready          (_connected_to_in_ready_),          //              .ready
		.in_startofpacket  (_connected_to_in_startofpacket_),  //              .startofpacket
		.in_endofpacket    (_connected_to_in_endofpacket_),    //              .endofpacket
		.in_empty          (_connected_to_in_empty_),          //              .empty
		.in_error          (_connected_to_in_error_),          //              .error
		.in_clk            (_connected_to_in_clk_),            //        in_clk.clk
		.in_reset_n        (_connected_to_in_reset_n_),        //  in_clk_reset.reset_n
		.out_data          (_connected_to_out_data_),          //           out.data
		.out_valid         (_connected_to_out_valid_),         //              .valid
		.out_ready         (_connected_to_out_ready_),         //              .ready
		.out_startofpacket (_connected_to_out_startofpacket_), //              .startofpacket
		.out_endofpacket   (_connected_to_out_endofpacket_),   //              .endofpacket
		.out_empty         (_connected_to_out_empty_),         //              .empty
		.out_error         (_connected_to_out_error_),         //              .error
		.out_clk           (_connected_to_out_clk_),           //       out_clk.clk
		.out_reset_n       (_connected_to_out_reset_n_)        // out_clk_reset.reset_n
	);

