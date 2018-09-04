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


p4 integrate alt_e100s10_cgmii_custom_4.v		alt_e100s10_cgmii_custom_4.v
p4 integrate alt_e100s10_hproc_4.v                     alt_e100s10_hproc_4.v
p4 integrate alt_e100s10_mac_link_fault_det.v          alt_e100s10_mac_link_fault_det.v
p4 integrate alt_e100s10_mac_link_fault_gen.v          alt_e100s10_mac_link_fault_gen.v
p4 integrate alt_e100s10_mac_rx_4.v                    alt_e100s10_mac_rx_4.v
p4 integrate alt_e100s10_mac_stats_4.v                 alt_e100s10_mac_stats_4.v
p4 integrate alt_e100s10_mac_tx_4.v                    alt_e100s10_mac_tx_4.v
p4 integrate alt_e100s10_stats_reg.v		        alt_e100s10_stats_reg.v		

p4 integrate alt_e100s10_cgmii_custom_4.v		bak_alt_e100s10_files/alt_e100s10_cgmii_custom_4.v
p4 integrate alt_e100s10_hproc_4.v                     bak_alt_e100s10_files/alt_e100s10_hproc_4.v
p4 integrate alt_e100s10_mac_link_fault_det.v          bak_alt_e100s10_files/alt_e100s10_mac_link_fault_det.v
p4 integrate alt_e100s10_mac_link_fault_gen.v          bak_alt_e100s10_files/alt_e100s10_mac_link_fault_gen.v
p4 integrate alt_e100s10_mac_rx_4.v                    bak_alt_e100s10_files/alt_e100s10_mac_rx_4.v
p4 integrate alt_e100s10_mac_stats_4.v                 bak_alt_e100s10_files/alt_e100s10_mac_stats_4.v
p4 integrate alt_e100s10_mac_tx_4.v                    bak_alt_e100s10_files/alt_e100s10_mac_tx_4.v
p4 integrate alt_e100s10_stats_reg.v		        bak_alt_e100s10_files/alt_e100s10_stats_reg.v		

p4 delete alt_e100s10_cgmii_custom_4.v		     
p4 delete alt_e100s10_hproc_4.v                     
p4 delete alt_e100s10_mac_link_fault_det.v          
p4 delete alt_e100s10_mac_link_fault_gen.v          
p4 delete alt_e100s10_mac_rx_4.v                    
p4 delete alt_e100s10_mac_stats_4.v                 
p4 delete alt_e100s10_mac_tx_4.v                    
p4 delete alt_e100s10_stats_reg.v		     

