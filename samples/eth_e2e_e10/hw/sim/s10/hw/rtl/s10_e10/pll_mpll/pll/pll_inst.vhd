	component pll is
		port (
			pll_refclk0  : in  std_logic := 'X'; -- clk
			outclk_div1  : out std_logic;        -- clk
			outclk_div2  : out std_logic;        -- clk
			pll_locked   : out std_logic;        -- pll_locked
			pll_cal_busy : out std_logic         -- pll_cal_busy
		);
	end component pll;

	u0 : component pll
		port map (
			pll_refclk0  => CONNECTED_TO_pll_refclk0,  --  pll_refclk0.clk
			outclk_div1  => CONNECTED_TO_outclk_div1,  --  outclk_div1.clk
			outclk_div2  => CONNECTED_TO_outclk_div2,  --  outclk_div2.clk
			pll_locked   => CONNECTED_TO_pll_locked,   --   pll_locked.pll_locked
			pll_cal_busy => CONNECTED_TO_pll_cal_busy  -- pll_cal_busy.pll_cal_busy
		);

