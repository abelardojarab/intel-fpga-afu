	dc_fifo u0 (
		.dc_fifo_0_in_data               (_connected_to_dc_fifo_0_in_data_),               //            dc_fifo_0_in.data
		.dc_fifo_0_in_valid              (_connected_to_dc_fifo_0_in_valid_),              //                        .valid
		.dc_fifo_0_in_ready              (_connected_to_dc_fifo_0_in_ready_),              //                        .ready
		.dc_fifo_0_in_startofpacket      (_connected_to_dc_fifo_0_in_startofpacket_),      //                        .startofpacket
		.dc_fifo_0_in_endofpacket        (_connected_to_dc_fifo_0_in_endofpacket_),        //                        .endofpacket
		.dc_fifo_0_in_empty              (_connected_to_dc_fifo_0_in_empty_),              //                        .empty
		.dc_fifo_0_in_error              (_connected_to_dc_fifo_0_in_error_),              //                        .error
		.dc_fifo_0_in_clk_clk            (_connected_to_dc_fifo_0_in_clk_clk_),            //        dc_fifo_0_in_clk.clk
		.dc_fifo_0_in_clk_reset_reset_n  (_connected_to_dc_fifo_0_in_clk_reset_reset_n_),  //  dc_fifo_0_in_clk_reset.reset_n
		.dc_fifo_0_out_data              (_connected_to_dc_fifo_0_out_data_),              //           dc_fifo_0_out.data
		.dc_fifo_0_out_valid             (_connected_to_dc_fifo_0_out_valid_),             //                        .valid
		.dc_fifo_0_out_ready             (_connected_to_dc_fifo_0_out_ready_),             //                        .ready
		.dc_fifo_0_out_startofpacket     (_connected_to_dc_fifo_0_out_startofpacket_),     //                        .startofpacket
		.dc_fifo_0_out_endofpacket       (_connected_to_dc_fifo_0_out_endofpacket_),       //                        .endofpacket
		.dc_fifo_0_out_empty             (_connected_to_dc_fifo_0_out_empty_),             //                        .empty
		.dc_fifo_0_out_error             (_connected_to_dc_fifo_0_out_error_),             //                        .error
		.dc_fifo_0_out_clk_clk           (_connected_to_dc_fifo_0_out_clk_clk_),           //       dc_fifo_0_out_clk.clk
		.dc_fifo_0_out_clk_reset_reset_n (_connected_to_dc_fifo_0_out_clk_reset_reset_n_)  // dc_fifo_0_out_clk_reset.reset_n
	);

