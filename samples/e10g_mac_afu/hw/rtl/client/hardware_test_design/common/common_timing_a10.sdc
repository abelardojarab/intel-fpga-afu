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
set_false_path -from [get_clocks {clk50}] -to [get_clocks {clk_ref_r}]
  
set RX_CORE_CLK [get_clocks *|phy*|*rxp|*rx_pll*|rx_core_clk]
set TX_CORE_CLK [get_clocks *|phy*|*txp|*tx_pll*|tx_core_clk]
set clk100 [get_clocks *|*iopll*|outclk0]

set_clock_groups -asynchronous \
    -group $TX_CORE_CLK \
    -group $RX_CORE_CLK \
    -group $clk100

#I2C
set SCL     [get_keepers {I2C_18V_SCL}]
set SDA     [get_keepers {I2C_18V_SDA}]

set_false_path -from $SCL
set_false_path -to   $SCL
set_false_path -from $SDA
set_false_path -to   $SDA

#QSFP
set INTL    [get_keepers {eQSFP_intl}]
set MODPRS  [get_keepers {eQSFP_modprsL}]
set LPMODE  [get_keepers {eQSFP_LPmode}]
set RESETL  [get_keepers {eQSFP_resetL}]

set_false_path -from $INTL
set_false_path -from $MODPRS
set_false_path -to   $LPMODE
set_false_path -to   $RESETL

# From "AV SoC Golden Hardware Reference Design"
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_ntrst]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

