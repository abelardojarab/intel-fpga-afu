These tcl files are meant to provide examples of how to use
system console to access various components of the ethernet
core.

Quick start instructions for hardware testing:
1. Open system console
2. Source the main.tcl file: source main.tcl
3. Run example test script: run_test

Register map information:
The base addresses of the individual components are defined in
hwtest/altera/sval_top/reg_map_inc.tcl.
The address offsets are defined in the individual modules which
use them. For example, /hwtest/altera/alt_aeu_40/eth_ultra_mac_inc.tcl
contains the offsets for the ethernet MAC.
