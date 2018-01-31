
module altera_eth_10gbaser_phy (
	reconfig_write,
	reconfig_read,
	reconfig_address,
	reconfig_writedata,
	reconfig_readdata,
	reconfig_waitrequest,
	reconfig_clk,
	reconfig_reset,
	rx_analogreset,
	rx_cal_busy,
	rx_cdr_refclk0,
	rx_clkout,
	rx_control,
	rx_coreclkin,
	rx_digitalreset,
	rx_enh_blk_lock,
	rx_enh_data_valid,
	rx_enh_fifo_del,
	rx_enh_fifo_empty,
	rx_enh_fifo_full,
	rx_enh_fifo_insert,
	rx_enh_highber,
	rx_is_lockedtodata,
	rx_is_lockedtoref,
	rx_parallel_data,
	rx_pma_div_clkout,
	rx_serial_data,
	tx_analogreset,
	tx_cal_busy,
	tx_clkout,
	tx_control,
	tx_coreclkin,
	tx_digitalreset,
	tx_enh_data_valid,
	tx_enh_fifo_empty,
	tx_enh_fifo_full,
	tx_enh_fifo_pempty,
	tx_enh_fifo_pfull,
	tx_err_ins,
	tx_parallel_data,
	tx_pma_div_clkout,
	tx_serial_clk0,
	tx_serial_data,
	unused_rx_control,
	unused_rx_parallel_data,
	unused_tx_control,
	unused_tx_parallel_data);	

	input	[0:0]	reconfig_write;
	input	[0:0]	reconfig_read;
	input	[9:0]	reconfig_address;
	input	[31:0]	reconfig_writedata;
	output	[31:0]	reconfig_readdata;
	output	[0:0]	reconfig_waitrequest;
	input	[0:0]	reconfig_clk;
	input	[0:0]	reconfig_reset;
	input	[0:0]	rx_analogreset;
	output	[0:0]	rx_cal_busy;
	input		rx_cdr_refclk0;
	output	[0:0]	rx_clkout;
	output	[7:0]	rx_control;
	input	[0:0]	rx_coreclkin;
	input	[0:0]	rx_digitalreset;
	output	[0:0]	rx_enh_blk_lock;
	output	[0:0]	rx_enh_data_valid;
	output	[0:0]	rx_enh_fifo_del;
	output	[0:0]	rx_enh_fifo_empty;
	output	[0:0]	rx_enh_fifo_full;
	output	[0:0]	rx_enh_fifo_insert;
	output	[0:0]	rx_enh_highber;
	output	[0:0]	rx_is_lockedtodata;
	output	[0:0]	rx_is_lockedtoref;
	output	[63:0]	rx_parallel_data;
	output	[0:0]	rx_pma_div_clkout;
	input	[0:0]	rx_serial_data;
	input	[0:0]	tx_analogreset;
	output	[0:0]	tx_cal_busy;
	output	[0:0]	tx_clkout;
	input	[7:0]	tx_control;
	input	[0:0]	tx_coreclkin;
	input	[0:0]	tx_digitalreset;
	input	[0:0]	tx_enh_data_valid;
	output	[0:0]	tx_enh_fifo_empty;
	output	[0:0]	tx_enh_fifo_full;
	output	[0:0]	tx_enh_fifo_pempty;
	output	[0:0]	tx_enh_fifo_pfull;
	input		tx_err_ins;
	input	[63:0]	tx_parallel_data;
	output	[0:0]	tx_pma_div_clkout;
	input	[0:0]	tx_serial_clk0;
	output	[0:0]	tx_serial_data;
	output	[11:0]	unused_rx_control;
	output	[63:0]	unused_rx_parallel_data;
	input	[8:0]	unused_tx_control;
	input	[63:0]	unused_tx_parallel_data;
endmodule
