
module altera_xcvr_atx_pll_ip (
	mcgb_cal_busy,
	pll_cal_busy,
	pll_locked,
	pll_powerdown,
	pll_refclk0,
	tx_serial_clk);	

	output		mcgb_cal_busy;
	output		pll_cal_busy;
	output		pll_locked;
	input		pll_powerdown;
	input		pll_refclk0;
	output		tx_serial_clk;
endmodule
