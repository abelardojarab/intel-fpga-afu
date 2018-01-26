
module altera_eth_10g_mac (
	avalon_st_pause_data,
	avalon_st_rx_data,
	avalon_st_rx_startofpacket,
	avalon_st_rx_valid,
	avalon_st_rx_empty,
	avalon_st_rx_error,
	avalon_st_rx_ready,
	avalon_st_rx_endofpacket,
	avalon_st_rxstatus_valid,
	avalon_st_rxstatus_data,
	avalon_st_rxstatus_error,
	avalon_st_tx_startofpacket,
	avalon_st_tx_endofpacket,
	avalon_st_tx_valid,
	avalon_st_tx_data,
	avalon_st_tx_empty,
	avalon_st_tx_error,
	avalon_st_tx_ready,
	avalon_st_txstatus_valid,
	avalon_st_txstatus_data,
	avalon_st_txstatus_error,
	csr_read,
	csr_write,
	csr_writedata,
	csr_readdata,
	csr_waitrequest,
	csr_address,
	csr_clk,
	csr_rst_n,
	link_fault_status_xgmii_rx_data,
	rx_156_25_clk,
	rx_312_5_clk,
	rx_rst_n,
	tx_156_25_clk,
	tx_312_5_clk,
	tx_rst_n,
	xgmii_rx,
	xgmii_tx);	

	input	[1:0]	avalon_st_pause_data;
	output	[31:0]	avalon_st_rx_data;
	output		avalon_st_rx_startofpacket;
	output		avalon_st_rx_valid;
	output	[1:0]	avalon_st_rx_empty;
	output	[5:0]	avalon_st_rx_error;
	input		avalon_st_rx_ready;
	output		avalon_st_rx_endofpacket;
	output		avalon_st_rxstatus_valid;
	output	[39:0]	avalon_st_rxstatus_data;
	output	[6:0]	avalon_st_rxstatus_error;
	input		avalon_st_tx_startofpacket;
	input		avalon_st_tx_endofpacket;
	input		avalon_st_tx_valid;
	input	[31:0]	avalon_st_tx_data;
	input	[1:0]	avalon_st_tx_empty;
	input		avalon_st_tx_error;
	output		avalon_st_tx_ready;
	output		avalon_st_txstatus_valid;
	output	[39:0]	avalon_st_txstatus_data;
	output	[6:0]	avalon_st_txstatus_error;
	input		csr_read;
	input		csr_write;
	input	[31:0]	csr_writedata;
	output	[31:0]	csr_readdata;
	output		csr_waitrequest;
	input	[9:0]	csr_address;
	input		csr_clk;
	input		csr_rst_n;
	output	[1:0]	link_fault_status_xgmii_rx_data;
	input		rx_156_25_clk;
	input		rx_312_5_clk;
	input		rx_rst_n;
	input		tx_156_25_clk;
	input		tx_312_5_clk;
	input		tx_rst_n;
	input	[71:0]	xgmii_rx;
	output	[71:0]	xgmii_tx;
endmodule
