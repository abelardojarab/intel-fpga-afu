set_global_assignment -entity "reset_control" -library "lib_reset_control" -name IP_TOOL_NAME "QsysPrimePro"
set_global_assignment -entity "reset_control" -library "lib_reset_control" -name IP_TOOL_VERSION "16.0"
set_global_assignment -entity "reset_control" -library "lib_reset_control" -name IP_TOOL_ENV "QsysPrimePro"
set_global_assignment -library "lib_reset_control" -name SPD_FILE [file join $::quartus(sip_path) "reset_control.spd"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "../reset_control.qsys"]

set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "sim/reset_control.v"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/altera_xcvr_functions.sv"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/mentor/altera_xcvr_functions.sv"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/alt_xcvr_resync.sv"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/mentor/alt_xcvr_resync.sv"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/altera_xcvr_reset_control.sv"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/alt_xcvr_reset_counter.sv"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/mentor/altera_xcvr_reset_control.sv"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/mentor/alt_xcvr_reset_counter.sv"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/plain_files.txt"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/mentor_files.txt"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/cadence_files.txt"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/synopsys_files.txt"]
set_global_assignment -library "lib_reset_control" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_160/sim/aldec_files.txt"]
