	altera_xcvr_atx_pll_ip u0 (
		.mcgb_cal_busy (_connected_to_mcgb_cal_busy_), // mcgb_cal_busy.mcgb_cal_busy
		.pll_cal_busy  (_connected_to_pll_cal_busy_),  //  pll_cal_busy.pll_cal_busy
		.pll_locked    (_connected_to_pll_locked_),    //    pll_locked.pll_locked
		.pll_powerdown (_connected_to_pll_powerdown_), // pll_powerdown.pll_powerdown
		.pll_refclk0   (_connected_to_pll_refclk0_),   //   pll_refclk0.clk
		.tx_serial_clk (_connected_to_tx_serial_clk_)  // tx_serial_clk.clk
	);

