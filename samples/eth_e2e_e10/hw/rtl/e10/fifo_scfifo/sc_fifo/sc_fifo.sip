set_global_assignment -entity "sc_fifo" -library "lib_sc_fifo" -name IP_TOOL_NAME "QsysPrimePro"
set_global_assignment -entity "sc_fifo" -library "lib_sc_fifo" -name IP_TOOL_VERSION "16.0"
set_global_assignment -entity "sc_fifo" -library "lib_sc_fifo" -name IP_TOOL_ENV "QsysPrimePro"
set_global_assignment -library "lib_sc_fifo" -name SPD_FILE [file join $::quartus(sip_path) "sc_fifo.spd"]
set_global_assignment -library "lib_sc_fifo" -name MISC_FILE [file join $::quartus(sip_path) "../sc_fifo.qsys"]

set_global_assignment -library "lib_sc_fifo" -name MISC_FILE [file join $::quartus(sip_path) "sim/sc_fifo.v"]
set_global_assignment -library "lib_sc_fifo" -name MISC_FILE [file join $::quartus(sip_path) "altera_avalon_sc_fifo_160/sim/altera_avalon_sc_fifo.v"]
