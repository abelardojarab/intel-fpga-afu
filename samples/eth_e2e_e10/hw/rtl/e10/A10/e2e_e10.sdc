set_time_format -unit ns -decimal_places 3

create_clock -name {hssi_pll_r_0_outclk0} -period 6.400 -waveform { 0.000 3.200 } [get_nets {*|inst_hssi_ctrl|pll_r_0|xcvr_fpll_a10_0|outclk0}]
create_clock -name {hssi_pll_r_0_outclk1} -period 3.200 -waveform { 0.000 1.600 } [get_nets {*|inst_hssi_ctrl|pll_r_0|xcvr_fpll_a10_0|outclk1}]
create_clock -name {hssi_pll_t_outclk0}   -period 6.400 -waveform { 0.000 3.200 } [get_nets {*|inst_hssi_ctrl|pll_t|xcvr_fpll_a10_0|outclk0}]
create_clock -name {hssi_pll_t_outclk1}   -period 3.200 -waveform { 0.000 1.600 } [get_nets {*|inst_hssi_ctrl|pll_t|xcvr_fpll_a10_0|outclk1}]

set_clock_groups -asynchronous -group [get_clocks {hssi_pll_r_0_outclk0 hssi_pll_r_0_outclk1}] \
							   -group [get_clocks {SYS_RefClk}] \
							   -group [get_clocks {u0|dcp_iopll|dcp_iopll|clk1x}] \
                               -group [get_clocks {hssi_pll_t_outclk0 hssi_pll_t_outclk1}]
set_clock_groups -asynchronous -group [get_clocks {fpga_top|inst_fiu_top|inst_hssi_ctrl|ntv0|xcvr_native_a10_0|g_xcvr_native_insts[*]*|rx_pma_clk}]

set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|ENET|rx_rst}] -to *
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|ENET|tx_rst}] -to *
set_false_path -from [get_registers {fpga_top|inst_fiu_top|inst_ccip_fabric_top|inst_fme_top|inst_PR_cntrl|pr2fme_freeze_32UI[0]}] -to *
set_false_path -from [get_ports SYS_RST_N] -to *
set_false_path -from [get_registers {*|inst_hssi_ctrl|system_status_r[*]}] -to [get_registers {*|inst_fiu_top|inst_ccip_fabric_top|inst_fme_top|inst_fme_csr|csr_reg[6][2][*]}]
set_false_path -to [get_registers {*|inst_hssi_ctrl|system_ctrl_r[*]}] -from [get_registers {*|inst_fiu_top|inst_ccip_fabric_top|inst_fme_top|inst_fme_csr|csr_reg[6][1][*]}]
set_false_path -from [get_registers {*|inst_fiu_top|inst_ccip_fabric_top|inst_fme_top|inst_PR_cntrl|pr2fme_freeze_32UI[0]}]	-to [get_registers {*|inst_fiu_top|inst_hssi_ctrl|aux_rdata[1]}]
set_false_path -through [get_nets {*|hssi.f2a_tx_cal_busy}]
set_false_path -through [get_nets {*|hssi.f2a_tx_cal_locked}]
set_false_path -through [get_nets {*|hssi.f2a_tx_locked}]
set_false_path -through [get_nets {*|hssi.f2a_tx_pll_locked}]
set_false_path -through [get_nets {*|hssi.f2a_rx_cal_busy}]
