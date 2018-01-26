	component altera_xcvr_atx_pll_ip is
		port (
			mcgb_cal_busy : out std_logic;        -- mcgb_cal_busy
			pll_cal_busy  : out std_logic;        -- pll_cal_busy
			pll_locked    : out std_logic;        -- pll_locked
			pll_powerdown : in  std_logic := 'X'; -- pll_powerdown
			pll_refclk0   : in  std_logic := 'X'; -- clk
			tx_serial_clk : out std_logic         -- clk
		);
	end component altera_xcvr_atx_pll_ip;

	u0 : component altera_xcvr_atx_pll_ip
		port map (
			mcgb_cal_busy => CONNECTED_TO_mcgb_cal_busy, -- mcgb_cal_busy.mcgb_cal_busy
			pll_cal_busy  => CONNECTED_TO_pll_cal_busy,  --  pll_cal_busy.pll_cal_busy
			pll_locked    => CONNECTED_TO_pll_locked,    --    pll_locked.pll_locked
			pll_powerdown => CONNECTED_TO_pll_powerdown, -- pll_powerdown.pll_powerdown
			pll_refclk0   => CONNECTED_TO_pll_refclk0,   --   pll_refclk0.clk
			tx_serial_clk => CONNECTED_TO_tx_serial_clk  -- tx_serial_clk.clk
		);

