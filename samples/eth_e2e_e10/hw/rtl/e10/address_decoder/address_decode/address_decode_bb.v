
module address_decode (
	clk_csr_clk,
	csr_reset_n,
	eth_gen_mon_avalon_anti_slave_0_address,
	eth_gen_mon_avalon_anti_slave_0_write,
	eth_gen_mon_avalon_anti_slave_0_read,
	eth_gen_mon_avalon_anti_slave_0_readdata,
	eth_gen_mon_avalon_anti_slave_0_writedata,
	eth_gen_mon_avalon_anti_slave_0_waitrequest,
	mac_avalon_anti_slave_0_address,
	mac_avalon_anti_slave_0_write,
	mac_avalon_anti_slave_0_read,
	mac_avalon_anti_slave_0_readdata,
	mac_avalon_anti_slave_0_writedata,
	mac_avalon_anti_slave_0_waitrequest,
	merlin_master_translator_0_avalon_anti_master_0_address,
	merlin_master_translator_0_avalon_anti_master_0_waitrequest,
	merlin_master_translator_0_avalon_anti_master_0_read,
	merlin_master_translator_0_avalon_anti_master_0_readdata,
	merlin_master_translator_0_avalon_anti_master_0_write,
	merlin_master_translator_0_avalon_anti_master_0_writedata,
	phy_avalon_anti_slave_0_address,
	phy_avalon_anti_slave_0_write,
	phy_avalon_anti_slave_0_read,
	phy_avalon_anti_slave_0_readdata,
	phy_avalon_anti_slave_0_writedata,
	phy_avalon_anti_slave_0_waitrequest,
	rx_sc_fifo_avalon_anti_slave_0_address,
	rx_sc_fifo_avalon_anti_slave_0_write,
	rx_sc_fifo_avalon_anti_slave_0_read,
	rx_sc_fifo_avalon_anti_slave_0_readdata,
	rx_sc_fifo_avalon_anti_slave_0_writedata,
	rx_xcvr_clk_clk,
	sync_rx_rst_reset_n,
	sync_tx_half_rst_reset_n,
	sync_tx_rst_reset_n,
	tx_sc_fifo_avalon_anti_slave_0_address,
	tx_sc_fifo_avalon_anti_slave_0_write,
	tx_sc_fifo_avalon_anti_slave_0_read,
	tx_sc_fifo_avalon_anti_slave_0_readdata,
	tx_sc_fifo_avalon_anti_slave_0_writedata,
	tx_xcvr_clk_clk,
	tx_xcvr_half_clk_clk);	

	input		clk_csr_clk;
	input		csr_reset_n;
	output	[11:0]	eth_gen_mon_avalon_anti_slave_0_address;
	output		eth_gen_mon_avalon_anti_slave_0_write;
	output		eth_gen_mon_avalon_anti_slave_0_read;
	input	[31:0]	eth_gen_mon_avalon_anti_slave_0_readdata;
	output	[31:0]	eth_gen_mon_avalon_anti_slave_0_writedata;
	input		eth_gen_mon_avalon_anti_slave_0_waitrequest;
	output	[12:0]	mac_avalon_anti_slave_0_address;
	output		mac_avalon_anti_slave_0_write;
	output		mac_avalon_anti_slave_0_read;
	input	[31:0]	mac_avalon_anti_slave_0_readdata;
	output	[31:0]	mac_avalon_anti_slave_0_writedata;
	input		mac_avalon_anti_slave_0_waitrequest;
	input	[15:0]	merlin_master_translator_0_avalon_anti_master_0_address;
	output		merlin_master_translator_0_avalon_anti_master_0_waitrequest;
	input		merlin_master_translator_0_avalon_anti_master_0_read;
	output	[31:0]	merlin_master_translator_0_avalon_anti_master_0_readdata;
	input		merlin_master_translator_0_avalon_anti_master_0_write;
	input	[31:0]	merlin_master_translator_0_avalon_anti_master_0_writedata;
	output	[9:0]	phy_avalon_anti_slave_0_address;
	output		phy_avalon_anti_slave_0_write;
	output		phy_avalon_anti_slave_0_read;
	input	[31:0]	phy_avalon_anti_slave_0_readdata;
	output	[31:0]	phy_avalon_anti_slave_0_writedata;
	input		phy_avalon_anti_slave_0_waitrequest;
	output	[2:0]	rx_sc_fifo_avalon_anti_slave_0_address;
	output		rx_sc_fifo_avalon_anti_slave_0_write;
	output		rx_sc_fifo_avalon_anti_slave_0_read;
	input	[31:0]	rx_sc_fifo_avalon_anti_slave_0_readdata;
	output	[31:0]	rx_sc_fifo_avalon_anti_slave_0_writedata;
	input		rx_xcvr_clk_clk;
	input		sync_rx_rst_reset_n;
	input		sync_tx_half_rst_reset_n;
	input		sync_tx_rst_reset_n;
	output	[2:0]	tx_sc_fifo_avalon_anti_slave_0_address;
	output		tx_sc_fifo_avalon_anti_slave_0_write;
	output		tx_sc_fifo_avalon_anti_slave_0_read;
	input	[31:0]	tx_sc_fifo_avalon_anti_slave_0_readdata;
	output	[31:0]	tx_sc_fifo_avalon_anti_slave_0_writedata;
	input		tx_xcvr_clk_clk;
	input		tx_xcvr_half_clk_clk;
endmodule
