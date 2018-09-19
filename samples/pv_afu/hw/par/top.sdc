#create_clock -name {tck} -period 100MHz [get_ports tck]
#create_clock -name {clk50m} -period 50MHz [get_ports clk50m]
#create_clock -name {clk100m} -period 100MHz [get_ports clk100m]

if { [string equal quartus_sta $::TimeQuestInfo(nameofexecutable)] } {
	set_max_delay -from [get_registers {*instance_glitch_witch*|ena_rr*}] -to [get_registers {*instance_glitch_witch*|dout_r}] 15ns
}


# is this working right?   
# derive_pll_clocks -create_base_clock
# derive_clocks -period 300MHz

#set_max_delay -from [get_registers *] -to [get_ports *] 16
#set_max_delay -to [get_registers *] -from [get_ports *] 16
#set_false_path -hold -from [get_registers *] -to [get_ports *]
#set_false_path -hold -to [get_registers *] -from [get_ports *]
#
#set_max_delay -from [get_registers *] -to [get_ports tdo] 1
#set_max_delay -to [get_registers *] -from [get_ports tdi] 1
#set_max_delay -to [get_registers *] -from [get_ports tck] 1
#set_max_delay -to [get_registers *] -from [get_ports tms] 1
#
#
#derive_clock_uncertainty
