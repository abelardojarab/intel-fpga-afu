set_global_assignment -entity "altera_eth_10g_mac" -library "lib_altera_eth_10g_mac" -name IP_TOOL_NAME "QsysPrimePro"
set_global_assignment -entity "altera_eth_10g_mac" -library "lib_altera_eth_10g_mac" -name IP_TOOL_VERSION "16.0"
set_global_assignment -entity "altera_eth_10g_mac" -library "lib_altera_eth_10g_mac" -name IP_TOOL_ENV "QsysPrimePro"
set_global_assignment -library "lib_altera_eth_10g_mac" -name SPD_FILE [file join $::quartus(sip_path) "altera_eth_10g_mac.spd"]
set_global_assignment -library "lib_altera_eth_10g_mac" -name MISC_FILE [file join $::quartus(sip_path) "../altera_eth_10g_mac.qsys"]

set_global_assignment -library "lib_altera_eth_10g_mac" -name MISC_FILE [file join $::quartus(sip_path) "sim/altera_eth_10g_mac.v"]
set_global_assignment -library "lib_altera_eth_10g_mac" -name MISC_FILE [file join $::quartus(sip_path) "alt_em10g32_160/sim/mentor/alt_em10g32.v"]
set_global_assignment -library "lib_altera_eth_10g_mac" -name MISC_FILE [file join $::quartus(sip_path) "alt_em10g32_160/sim/aldec/alt_em10g32.v"]
