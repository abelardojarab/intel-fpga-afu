# (C) 2001-2018 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.



derive_pll_clocks -create_base_clock 
derive_clock_uncertainty

set_false_path  -from [get_keepers {cpu_resetn}]
  
set RX_CORE_CLK [get_clocks *|phy*|*rxp|*rx_pll*|*|divclk]
set TX_CORE_CLK [get_clocks *|phy*|*txp|*tx_pll*|*|divclk]
set clk100 [get_clocks sp100|*|divclk]

set_clock_groups -asynchronous -group $TX_CORE_CLK -group $RX_CORE_CLK -group clk50 -group $clk100
