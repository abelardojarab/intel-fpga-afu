	reset_control u0 (
		.clock              (_connected_to_clock_),              //              clock.clk
		.pll_locked         (_connected_to_pll_locked_),         //         pll_locked.pll_locked
		.pll_powerdown      (_connected_to_pll_powerdown_),      //      pll_powerdown.pll_powerdown
		.pll_select         (_connected_to_pll_select_),         //         pll_select.pll_select
		.reset              (_connected_to_reset_),              //              reset.reset
		.rx_analogreset     (_connected_to_rx_analogreset_),     //     rx_analogreset.rx_analogreset
		.rx_cal_busy        (_connected_to_rx_cal_busy_),        //        rx_cal_busy.rx_cal_busy
		.rx_digitalreset    (_connected_to_rx_digitalreset_),    //    rx_digitalreset.rx_digitalreset
		.rx_is_lockedtodata (_connected_to_rx_is_lockedtodata_), // rx_is_lockedtodata.rx_is_lockedtodata
		.rx_ready           (_connected_to_rx_ready_),           //           rx_ready.rx_ready
		.tx_analogreset     (_connected_to_tx_analogreset_),     //     tx_analogreset.tx_analogreset
		.tx_cal_busy        (_connected_to_tx_cal_busy_),        //        tx_cal_busy.tx_cal_busy
		.tx_digitalreset    (_connected_to_tx_digitalreset_),    //    tx_digitalreset.tx_digitalreset
		.tx_ready           (_connected_to_tx_ready_)            //           tx_ready.tx_ready
	);

