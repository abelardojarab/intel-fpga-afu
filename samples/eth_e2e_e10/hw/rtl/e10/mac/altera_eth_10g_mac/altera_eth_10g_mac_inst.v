	altera_eth_10g_mac u0 (
		.avalon_st_pause_data            (_connected_to_avalon_st_pause_data_),            //            avalon_st_pause.data
		.avalon_st_rx_data               (_connected_to_avalon_st_rx_data_),               //               avalon_st_rx.data
		.avalon_st_rx_startofpacket      (_connected_to_avalon_st_rx_startofpacket_),      //                           .startofpacket
		.avalon_st_rx_valid              (_connected_to_avalon_st_rx_valid_),              //                           .valid
		.avalon_st_rx_empty              (_connected_to_avalon_st_rx_empty_),              //                           .empty
		.avalon_st_rx_error              (_connected_to_avalon_st_rx_error_),              //                           .error
		.avalon_st_rx_ready              (_connected_to_avalon_st_rx_ready_),              //                           .ready
		.avalon_st_rx_endofpacket        (_connected_to_avalon_st_rx_endofpacket_),        //                           .endofpacket
		.avalon_st_rxstatus_valid        (_connected_to_avalon_st_rxstatus_valid_),        //         avalon_st_rxstatus.valid
		.avalon_st_rxstatus_data         (_connected_to_avalon_st_rxstatus_data_),         //                           .data
		.avalon_st_rxstatus_error        (_connected_to_avalon_st_rxstatus_error_),        //                           .error
		.avalon_st_tx_startofpacket      (_connected_to_avalon_st_tx_startofpacket_),      //               avalon_st_tx.startofpacket
		.avalon_st_tx_endofpacket        (_connected_to_avalon_st_tx_endofpacket_),        //                           .endofpacket
		.avalon_st_tx_valid              (_connected_to_avalon_st_tx_valid_),              //                           .valid
		.avalon_st_tx_data               (_connected_to_avalon_st_tx_data_),               //                           .data
		.avalon_st_tx_empty              (_connected_to_avalon_st_tx_empty_),              //                           .empty
		.avalon_st_tx_error              (_connected_to_avalon_st_tx_error_),              //                           .error
		.avalon_st_tx_ready              (_connected_to_avalon_st_tx_ready_),              //                           .ready
		.avalon_st_txstatus_valid        (_connected_to_avalon_st_txstatus_valid_),        //         avalon_st_txstatus.valid
		.avalon_st_txstatus_data         (_connected_to_avalon_st_txstatus_data_),         //                           .data
		.avalon_st_txstatus_error        (_connected_to_avalon_st_txstatus_error_),        //                           .error
		.csr_read                        (_connected_to_csr_read_),                        //                        csr.read
		.csr_write                       (_connected_to_csr_write_),                       //                           .write
		.csr_writedata                   (_connected_to_csr_writedata_),                   //                           .writedata
		.csr_readdata                    (_connected_to_csr_readdata_),                    //                           .readdata
		.csr_waitrequest                 (_connected_to_csr_waitrequest_),                 //                           .waitrequest
		.csr_address                     (_connected_to_csr_address_),                     //                           .address
		.csr_clk                         (_connected_to_csr_clk_),                         //                    csr_clk.clk
		.csr_rst_n                       (_connected_to_csr_rst_n_),                       //                  csr_rst_n.reset_n
		.link_fault_status_xgmii_rx_data (_connected_to_link_fault_status_xgmii_rx_data_), // link_fault_status_xgmii_rx.data
		.rx_156_25_clk                   (_connected_to_rx_156_25_clk_),                   //              rx_156_25_clk.clk
		.rx_312_5_clk                    (_connected_to_rx_312_5_clk_),                    //               rx_312_5_clk.clk
		.rx_rst_n                        (_connected_to_rx_rst_n_),                        //                   rx_rst_n.reset_n
		.tx_156_25_clk                   (_connected_to_tx_156_25_clk_),                   //              tx_156_25_clk.clk
		.tx_312_5_clk                    (_connected_to_tx_312_5_clk_),                    //               tx_312_5_clk.clk
		.tx_rst_n                        (_connected_to_tx_rst_n_),                        //                   tx_rst_n.reset_n
		.xgmii_rx                        (_connected_to_xgmii_rx_),                        //                   xgmii_rx.data
		.xgmii_tx                        (_connected_to_xgmii_tx_)                         //                   xgmii_tx.data
	);
