	req_C1TxRAM2PORT u0 (
		.data      (_connected_to_data_),      //   input,  width = 556,  ram_input.datain
		.wraddress (_connected_to_wraddress_), //   input,    width = 9,           .wraddress
		.rdaddress (_connected_to_rdaddress_), //   input,    width = 9,           .rdaddress
		.wren      (_connected_to_wren_),      //   input,    width = 1,           .wren
		.clock     (_connected_to_clock_),     //   input,    width = 1,           .clock
		.q         (_connected_to_q_)          //  output,  width = 556, ram_output.dataout
	);

