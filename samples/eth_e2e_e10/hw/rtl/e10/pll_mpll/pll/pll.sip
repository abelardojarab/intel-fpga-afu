set_global_assignment -entity "pll" -library "lib_pll" -name IP_TOOL_NAME "QsysPrimePro"
set_global_assignment -entity "pll" -library "lib_pll" -name IP_TOOL_VERSION "16.0"
set_global_assignment -entity "pll" -library "lib_pll" -name IP_TOOL_ENV "QsysPrimePro"
set_global_assignment -library "lib_pll" -name SPD_FILE [file join $::quartus(sip_path) "pll.spd"]
set_global_assignment -library "lib_pll" -name MISC_FILE [file join $::quartus(sip_path) "../pll.qsys"]

set_global_assignment -library "lib_pll" -name MISC_FILE [file join $::quartus(sip_path) "sim/pll.v"]
set_global_assignment -library "lib_pll" -name MISC_FILE [file join $::quartus(sip_path) "altera_iopll_160/sim/pll_altera_iopll_160_w5ozlyi.vo"]
