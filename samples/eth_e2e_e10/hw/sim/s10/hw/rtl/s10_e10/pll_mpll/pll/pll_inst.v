	pll u0 (
		.pll_refclk0  (_connected_to_pll_refclk0_),  //   input,  width = 1,  pll_refclk0.clk
		.outclk_div1  (_connected_to_outclk_div1_),  //  output,  width = 1,  outclk_div1.clk
		.outclk_div2  (_connected_to_outclk_div2_),  //  output,  width = 1,  outclk_div2.clk
		.pll_locked   (_connected_to_pll_locked_),   //  output,  width = 1,   pll_locked.pll_locked
		.pll_cal_busy (_connected_to_pll_cal_busy_)  //  output,  width = 1, pll_cal_busy.pll_cal_busy
	);

