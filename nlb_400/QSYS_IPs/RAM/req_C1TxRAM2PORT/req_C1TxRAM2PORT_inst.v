	req_C1TxRAM2PORT u0 (
		.data      (_connected_to_data_),      //  ram_input.datain
		.wraddress (_connected_to_wraddress_), //           .wraddress
		.rdaddress (_connected_to_rdaddress_), //           .rdaddress
		.wren      (_connected_to_wren_),      //           .wren
		.clock     (_connected_to_clock_),     //           .clock
		.q         (_connected_to_q_)          // ram_output.dataout
	);

