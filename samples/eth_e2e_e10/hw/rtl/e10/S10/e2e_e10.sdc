set_time_format -unit ns -decimal_places 3
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|ctrl_addr}] -to [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|eth_ctrl_addr_o}]
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|wr_data}] -to [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|eth_wr_data}]
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|eth_rd_data}] -to [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|rd_data}]

set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|prz0|sloop}] -to *
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|prz0|hssi.f2a_tx_ready}] -to *
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|prz0|hssi.f2a_rx_ready}] -to *
