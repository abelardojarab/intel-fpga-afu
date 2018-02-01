	address_decode u0 (
		.clk_csr_clk                                                 (_connected_to_clk_csr_clk_),                                                 //                                         clk_csr.clk
		.csr_reset_n                                                 (_connected_to_csr_reset_n_),                                                 //                                             csr.reset_n
		.eth_gen_mon_avalon_anti_slave_0_address                     (_connected_to_eth_gen_mon_avalon_anti_slave_0_address_),                     //                 eth_gen_mon_avalon_anti_slave_0.address
		.eth_gen_mon_avalon_anti_slave_0_write                       (_connected_to_eth_gen_mon_avalon_anti_slave_0_write_),                       //                                                .write
		.eth_gen_mon_avalon_anti_slave_0_read                        (_connected_to_eth_gen_mon_avalon_anti_slave_0_read_),                        //                                                .read
		.eth_gen_mon_avalon_anti_slave_0_readdata                    (_connected_to_eth_gen_mon_avalon_anti_slave_0_readdata_),                    //                                                .readdata
		.eth_gen_mon_avalon_anti_slave_0_writedata                   (_connected_to_eth_gen_mon_avalon_anti_slave_0_writedata_),                   //                                                .writedata
		.eth_gen_mon_avalon_anti_slave_0_waitrequest                 (_connected_to_eth_gen_mon_avalon_anti_slave_0_waitrequest_),                 //                                                .waitrequest
		.mac_avalon_anti_slave_0_address                             (_connected_to_mac_avalon_anti_slave_0_address_),                             //                         mac_avalon_anti_slave_0.address
		.mac_avalon_anti_slave_0_write                               (_connected_to_mac_avalon_anti_slave_0_write_),                               //                                                .write
		.mac_avalon_anti_slave_0_read                                (_connected_to_mac_avalon_anti_slave_0_read_),                                //                                                .read
		.mac_avalon_anti_slave_0_readdata                            (_connected_to_mac_avalon_anti_slave_0_readdata_),                            //                                                .readdata
		.mac_avalon_anti_slave_0_writedata                           (_connected_to_mac_avalon_anti_slave_0_writedata_),                           //                                                .writedata
		.mac_avalon_anti_slave_0_waitrequest                         (_connected_to_mac_avalon_anti_slave_0_waitrequest_),                         //                                                .waitrequest
		.merlin_master_translator_0_avalon_anti_master_0_address     (_connected_to_merlin_master_translator_0_avalon_anti_master_0_address_),     // merlin_master_translator_0_avalon_anti_master_0.address
		.merlin_master_translator_0_avalon_anti_master_0_waitrequest (_connected_to_merlin_master_translator_0_avalon_anti_master_0_waitrequest_), //                                                .waitrequest
		.merlin_master_translator_0_avalon_anti_master_0_read        (_connected_to_merlin_master_translator_0_avalon_anti_master_0_read_),        //                                                .read
		.merlin_master_translator_0_avalon_anti_master_0_readdata    (_connected_to_merlin_master_translator_0_avalon_anti_master_0_readdata_),    //                                                .readdata
		.merlin_master_translator_0_avalon_anti_master_0_write       (_connected_to_merlin_master_translator_0_avalon_anti_master_0_write_),       //                                                .write
		.merlin_master_translator_0_avalon_anti_master_0_writedata   (_connected_to_merlin_master_translator_0_avalon_anti_master_0_writedata_),   //                                                .writedata
		.phy_avalon_anti_slave_0_address                             (_connected_to_phy_avalon_anti_slave_0_address_),                             //                         phy_avalon_anti_slave_0.address
		.phy_avalon_anti_slave_0_write                               (_connected_to_phy_avalon_anti_slave_0_write_),                               //                                                .write
		.phy_avalon_anti_slave_0_read                                (_connected_to_phy_avalon_anti_slave_0_read_),                                //                                                .read
		.phy_avalon_anti_slave_0_readdata                            (_connected_to_phy_avalon_anti_slave_0_readdata_),                            //                                                .readdata
		.phy_avalon_anti_slave_0_writedata                           (_connected_to_phy_avalon_anti_slave_0_writedata_),                           //                                                .writedata
		.phy_avalon_anti_slave_0_waitrequest                         (_connected_to_phy_avalon_anti_slave_0_waitrequest_),                         //                                                .waitrequest
		.rx_sc_fifo_avalon_anti_slave_0_address                      (_connected_to_rx_sc_fifo_avalon_anti_slave_0_address_),                      //                  rx_sc_fifo_avalon_anti_slave_0.address
		.rx_sc_fifo_avalon_anti_slave_0_write                        (_connected_to_rx_sc_fifo_avalon_anti_slave_0_write_),                        //                                                .write
		.rx_sc_fifo_avalon_anti_slave_0_read                         (_connected_to_rx_sc_fifo_avalon_anti_slave_0_read_),                         //                                                .read
		.rx_sc_fifo_avalon_anti_slave_0_readdata                     (_connected_to_rx_sc_fifo_avalon_anti_slave_0_readdata_),                     //                                                .readdata
		.rx_sc_fifo_avalon_anti_slave_0_writedata                    (_connected_to_rx_sc_fifo_avalon_anti_slave_0_writedata_),                    //                                                .writedata
		.rx_xcvr_clk_clk                                             (_connected_to_rx_xcvr_clk_clk_),                                             //                                     rx_xcvr_clk.clk
		.sync_rx_rst_reset_n                                         (_connected_to_sync_rx_rst_reset_n_),                                         //                                     sync_rx_rst.reset_n
		.sync_tx_half_rst_reset_n                                    (_connected_to_sync_tx_half_rst_reset_n_),                                    //                                sync_tx_half_rst.reset_n
		.sync_tx_rst_reset_n                                         (_connected_to_sync_tx_rst_reset_n_),                                         //                                     sync_tx_rst.reset_n
		.tx_sc_fifo_avalon_anti_slave_0_address                      (_connected_to_tx_sc_fifo_avalon_anti_slave_0_address_),                      //                  tx_sc_fifo_avalon_anti_slave_0.address
		.tx_sc_fifo_avalon_anti_slave_0_write                        (_connected_to_tx_sc_fifo_avalon_anti_slave_0_write_),                        //                                                .write
		.tx_sc_fifo_avalon_anti_slave_0_read                         (_connected_to_tx_sc_fifo_avalon_anti_slave_0_read_),                         //                                                .read
		.tx_sc_fifo_avalon_anti_slave_0_readdata                     (_connected_to_tx_sc_fifo_avalon_anti_slave_0_readdata_),                     //                                                .readdata
		.tx_sc_fifo_avalon_anti_slave_0_writedata                    (_connected_to_tx_sc_fifo_avalon_anti_slave_0_writedata_),                    //                                                .writedata
		.tx_xcvr_clk_clk                                             (_connected_to_tx_xcvr_clk_clk_),                                             //                                     tx_xcvr_clk.clk
		.tx_xcvr_half_clk_clk                                        (_connected_to_tx_xcvr_half_clk_clk_)                                         //                                tx_xcvr_half_clk.clk
	);
