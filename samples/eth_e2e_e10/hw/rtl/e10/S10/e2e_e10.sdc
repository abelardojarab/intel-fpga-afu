set_time_format -unit ns -decimal_places 3
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|ctrl_addr}]   -to [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|eth_ctrl_addr_o}]
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|wr_data}]     -to [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|eth_wr_data}]
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|eth_rd_data}] -to [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|rd_data}]
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|prz0|sloop[*]}] -to *
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|prz0|sync_tx_ready|sync_sr[*]}] -to *
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|prz0|sync_rx_ready|sync_sr[*]}] -to *
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|prz0|rx_rst}] -to *
set_false_path -from [get_registers {fpga_top|inst_green_bs*|ccip_std_afu|prz0|tx_rst}] -to *


derive_clock_uncertainty

# Function to constraint pointers
proc alt_em10g32_constraint_ptr_top {from_path from_reg to_path to_reg max_skew max_net_delay} {
    if { [string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)] } {
        # Check for instances
        set inst [get_registers -nowarn *${from_path}|${from_reg}\[0\]]
        
        # Check number of instances
        set inst_num [llength [query_collection -report -all $inst]]

        if {$inst_num > 0} {
            # Uncomment line below for debug purpose
            #puts "${inst_num} ${from_path}|${from_reg} instance(s) found"
        } else {
            # Uncomment line below for debug purpose
            #puts "No ${from_path}|${from_reg} instance found"
        }
        # Constraint one instance at a time to avoid set_max_skew apply to all instances
        foreach_in_collection each_inst_tmp $inst { 
            set each_inst [get_node_info -name $each_inst_tmp] 
            # Get the path to instance
            regexp "(.*|)(${from_reg})" $each_inst reg_path inst_name reg_name
            set_max_skew -from [get_registers ${inst_name}${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] $max_skew
            set_max_delay -from [get_registers ${inst_name}${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] 100ns
            set_min_delay -from [get_registers ${inst_name}${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] -100ns
        }
    } else {
        set_net_delay -from [get_pins -compatibility_mode *${from_path}|${from_reg}[*]|q] -to [get_registers *${to_path}|${to_reg}*] -max $max_net_delay
        # Relax the fitter effort
        set_max_delay -from [get_registers *${from_path}|${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] 3.2ns
        set_min_delay -from [get_registers *${from_path}|${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] -100ns
    }  
}

# this constraint is need when instantiate altera_eth_avalon_st_adapter
alt_em10g32_constraint_ptr_top  alt_em10g32_avalon_dc_fifo:*  in_wr_ptr_gray  alt_em10g32_avalon_dc_fifo:*|alt_em10g32_dcfifo_synchronizer_bundle:write_crosser|*  din_s1  3ns  2ns
alt_em10g32_constraint_ptr_top  alt_em10g32_avalon_dc_fifo:*  out_rd_ptr_gray  alt_em10g32_avalon_dc_fifo:*|alt_em10g32_dcfifo_synchronizer_bundle:read_crosser|*  din_s1  3ns  2ns
