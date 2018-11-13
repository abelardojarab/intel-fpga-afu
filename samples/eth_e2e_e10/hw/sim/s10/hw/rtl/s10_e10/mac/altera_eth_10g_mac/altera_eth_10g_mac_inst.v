	altera_eth_10g_mac u0 (
		.csr_read                        (_connected_to_csr_read_),                        //   input,   width = 1,                        csr.read
		.csr_write                       (_connected_to_csr_write_),                       //   input,   width = 1,                           .write
		.csr_writedata                   (_connected_to_csr_writedata_),                   //   input,  width = 32,                           .writedata
		.csr_readdata                    (_connected_to_csr_readdata_),                    //  output,  width = 32,                           .readdata
		.csr_waitrequest                 (_connected_to_csr_waitrequest_),                 //  output,   width = 1,                           .waitrequest
		.csr_address                     (_connected_to_csr_address_),                     //   input,  width = 10,                           .address
		.tx_312_5_clk                    (_connected_to_tx_312_5_clk_),                    //   input,   width = 1,               tx_312_5_clk.clk
		.tx_156_25_clk                   (_connected_to_tx_156_25_clk_),                   //   input,   width = 1,              tx_156_25_clk.clk
		.rx_312_5_clk                    (_connected_to_rx_312_5_clk_),                    //   input,   width = 1,               rx_312_5_clk.clk
		.rx_156_25_clk                   (_connected_to_rx_156_25_clk_),                   //   input,   width = 1,              rx_156_25_clk.clk
		.csr_clk                         (_connected_to_csr_clk_),                         //   input,   width = 1,                    csr_clk.clk
		.csr_rst_n                       (_connected_to_csr_rst_n_),                       //   input,   width = 1,                  csr_rst_n.reset_n
		.tx_rst_n                        (_connected_to_tx_rst_n_),                        //   input,   width = 1,                   tx_rst_n.reset_n
		.rx_rst_n                        (_connected_to_rx_rst_n_),                        //   input,   width = 1,                   rx_rst_n.reset_n
		.avalon_st_tx_startofpacket      (_connected_to_avalon_st_tx_startofpacket_),      //   input,   width = 1,               avalon_st_tx.startofpacket
		.avalon_st_tx_endofpacket        (_connected_to_avalon_st_tx_endofpacket_),        //   input,   width = 1,                           .endofpacket
		.avalon_st_tx_valid              (_connected_to_avalon_st_tx_valid_),              //   input,   width = 1,                           .valid
		.avalon_st_tx_data               (_connected_to_avalon_st_tx_data_),               //   input,  width = 32,                           .data
		.avalon_st_tx_empty              (_connected_to_avalon_st_tx_empty_),              //   input,   width = 2,                           .empty
		.avalon_st_tx_error              (_connected_to_avalon_st_tx_error_),              //   input,   width = 1,                           .error
		.avalon_st_tx_ready              (_connected_to_avalon_st_tx_ready_),              //  output,   width = 1,                           .ready
		.avalon_st_pause_data            (_connected_to_avalon_st_pause_data_),            //   input,   width = 2,            avalon_st_pause.data
		.xgmii_tx                        (_connected_to_xgmii_tx_),                        //  output,  width = 72,                   xgmii_tx.data
		.avalon_st_txstatus_valid        (_connected_to_avalon_st_txstatus_valid_),        //  output,   width = 1,         avalon_st_txstatus.valid
		.avalon_st_txstatus_data         (_connected_to_avalon_st_txstatus_data_),         //  output,  width = 40,                           .data
		.avalon_st_txstatus_error        (_connected_to_avalon_st_txstatus_error_),        //  output,   width = 7,                           .error
		.xgmii_rx                        (_connected_to_xgmii_rx_),                        //   input,  width = 72,                   xgmii_rx.data
		.link_fault_status_xgmii_rx_data (_connected_to_link_fault_status_xgmii_rx_data_), //  output,   width = 2, link_fault_status_xgmii_rx.data
		.avalon_st_rx_data               (_connected_to_avalon_st_rx_data_),               //  output,  width = 32,               avalon_st_rx.data
		.avalon_st_rx_startofpacket      (_connected_to_avalon_st_rx_startofpacket_),      //  output,   width = 1,                           .startofpacket
		.avalon_st_rx_valid              (_connected_to_avalon_st_rx_valid_),              //  output,   width = 1,                           .valid
		.avalon_st_rx_empty              (_connected_to_avalon_st_rx_empty_),              //  output,   width = 2,                           .empty
		.avalon_st_rx_error              (_connected_to_avalon_st_rx_error_),              //  output,   width = 6,                           .error
		.avalon_st_rx_ready              (_connected_to_avalon_st_rx_ready_),              //   input,   width = 1,                           .ready
		.avalon_st_rx_endofpacket        (_connected_to_avalon_st_rx_endofpacket_),        //  output,   width = 1,                           .endofpacket
		.avalon_st_rxstatus_valid        (_connected_to_avalon_st_rxstatus_valid_),        //  output,   width = 1,         avalon_st_rxstatus.valid
		.avalon_st_rxstatus_data         (_connected_to_avalon_st_rxstatus_data_),         //  output,  width = 40,                           .data
		.avalon_st_rxstatus_error        (_connected_to_avalon_st_rxstatus_error_)         //  output,   width = 7,                           .error
	);
