set_time_format -unit ns -decimal_places 3

set_max_skew -from [get_keepers {fpga_top|inst_green_bs|inst_ccip_std_afu|inst_green_ccip_interface_reg|pck_cp2af_softReset_T0_q}] -to [get_pins {fpga_top|inst_green_bs|inst_ccip_std_afu|nlb_lpbk|Clk_100_reset_sync|resync_chains[0].synchronizer_nocut|*|clrn}] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.800 
set_max_delay -from [get_keepers {fpga_top|inst_green_bs|inst_ccip_std_afu|inst_green_ccip_interface_reg|pck_cp2af_softReset_T0_q}] -to [get_pins {fpga_top|inst_green_bs|inst_ccip_std_afu|nlb_lpbk|Clk_100_reset_sync|resync_chains[0].synchronizer_nocut|*|clrn}] 100.000
set_min_delay -from [get_keepers {fpga_top|inst_green_bs|inst_ccip_std_afu|inst_green_ccip_interface_reg|pck_cp2af_softReset_T0_q}] -to [get_pins {fpga_top|inst_green_bs|inst_ccip_std_afu|nlb_lpbk|Clk_100_reset_sync|resync_chains[0].synchronizer_nocut|*|clrn}] -100.000


