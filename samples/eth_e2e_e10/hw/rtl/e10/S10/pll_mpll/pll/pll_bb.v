module pll (
		input  wire  pll_refclk0,  //  pll_refclk0.clk
		output wire  outclk_div1,  //  outclk_div1.clk
		output wire  outclk_div2,  //  outclk_div2.clk
		output wire  pll_locked,   //   pll_locked.pll_locked
		output wire  pll_cal_busy  // pll_cal_busy.pll_cal_busy
	);
endmodule

