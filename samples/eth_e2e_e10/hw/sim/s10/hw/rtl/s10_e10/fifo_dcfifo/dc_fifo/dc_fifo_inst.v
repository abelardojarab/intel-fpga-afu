	dc_fifo u0 (
		.dc_fifo_0_in_data               (_connected_to_dc_fifo_0_in_data_),               //   input,  width = 32,            dc_fifo_0_in.data
		.dc_fifo_0_in_valid              (_connected_to_dc_fifo_0_in_valid_),              //   input,   width = 1,                        .valid
		.dc_fifo_0_in_ready              (_connected_to_dc_fifo_0_in_ready_),              //  output,   width = 1,                        .ready
		.dc_fifo_0_in_startofpacket      (_connected_to_dc_fifo_0_in_startofpacket_),      //   input,   width = 1,                        .startofpacket
		.dc_fifo_0_in_endofpacket        (_connected_to_dc_fifo_0_in_endofpacket_),        //   input,   width = 1,                        .endofpacket
		.dc_fifo_0_in_empty              (_connected_to_dc_fifo_0_in_empty_),              //   input,   width = 2,                        .empty
		.dc_fifo_0_in_error              (_connected_to_dc_fifo_0_in_error_),              //   input,   width = 1,                        .error
		.dc_fifo_0_in_clk_clk            (_connected_to_dc_fifo_0_in_clk_clk_),            //   input,   width = 1,        dc_fifo_0_in_clk.clk
		.dc_fifo_0_in_clk_reset_reset_n  (_connected_to_dc_fifo_0_in_clk_reset_reset_n_),  //   input,   width = 1,  dc_fifo_0_in_clk_reset.reset_n
		.dc_fifo_0_out_data              (_connected_to_dc_fifo_0_out_data_),              //  output,  width = 32,           dc_fifo_0_out.data
		.dc_fifo_0_out_valid             (_connected_to_dc_fifo_0_out_valid_),             //  output,   width = 1,                        .valid
		.dc_fifo_0_out_ready             (_connected_to_dc_fifo_0_out_ready_),             //   input,   width = 1,                        .ready
		.dc_fifo_0_out_startofpacket     (_connected_to_dc_fifo_0_out_startofpacket_),     //  output,   width = 1,                        .startofpacket
		.dc_fifo_0_out_endofpacket       (_connected_to_dc_fifo_0_out_endofpacket_),       //  output,   width = 1,                        .endofpacket
		.dc_fifo_0_out_empty             (_connected_to_dc_fifo_0_out_empty_),             //  output,   width = 2,                        .empty
		.dc_fifo_0_out_error             (_connected_to_dc_fifo_0_out_error_),             //  output,   width = 1,                        .error
		.dc_fifo_0_out_clk_clk           (_connected_to_dc_fifo_0_out_clk_clk_),           //   input,   width = 1,       dc_fifo_0_out_clk.clk
		.dc_fifo_0_out_clk_reset_reset_n (_connected_to_dc_fifo_0_out_clk_reset_reset_n_)  //   input,   width = 1, dc_fifo_0_out_clk_reset.reset_n
	);

