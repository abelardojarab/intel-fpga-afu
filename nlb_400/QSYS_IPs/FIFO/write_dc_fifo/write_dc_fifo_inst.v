	write_dc_fifo u0 (
		.data    (_connected_to_data_),    //  fifo_input.datain
		.wrreq   (_connected_to_wrreq_),   //            .wrreq
		.rdreq   (_connected_to_rdreq_),   //            .rdreq
		.wrclk   (_connected_to_wrclk_),   //            .wrclk
		.rdclk   (_connected_to_rdclk_),   //            .rdclk
		.aclr    (_connected_to_aclr_),    //            .aclr
		.q       (_connected_to_q_),       // fifo_output.dataout
		.rdempty (_connected_to_rdempty_), //            .rdempty
		.wrfull  (_connected_to_wrfull_)   //            .wrfull
	);

