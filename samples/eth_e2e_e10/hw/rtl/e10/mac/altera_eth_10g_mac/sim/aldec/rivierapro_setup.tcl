
# (C) 2001-2017 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Intel 
# Program License Subscription Agreement, Intel MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Intel and sold by Intel 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ACDS 17.0 290 linux 2017.11.29.16:17:28
# ----------------------------------------
# Auto-generated simulation script rivierapro_setup.tcl
# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     altera_eth_10g_mac.altera_eth_10g_mac
# 
# Intel recommends that you source this Quartus-generated IP simulation
# script from your own customized top-level script, and avoid editing this
# generated script.
# 
# To write a top-level script that compiles Intel simulation libraries and
# the Quartus-generated IP in your project, along with your design and
# testbench files, copy the text from the TOP-LEVEL TEMPLATE section below
# into a new file, e.g. named "aldec.do", and modify the text as directed.
# 
# ----------------------------------------
# # TOP-LEVEL TEMPLATE - BEGIN
# #
# # QSYS_SIMDIR is used in the Quartus-generated IP simulation script to
# # construct paths to the files required to simulate the IP in your Quartus
# # project. By default, the IP script assumes that you are launching the
# # simulator from the IP script location. If launching from another
# # location, set QSYS_SIMDIR to the output directory you specified when you
# # generated the IP script, relative to the directory from which you launch
# # the simulator.
# #
# set QSYS_SIMDIR <script generation output directory>
# #
# # Source the generated IP simulation script.
# source $QSYS_SIMDIR/aldec/rivierapro_setup.tcl
# #
# # Set any compilation options you require (this is unusual).
# set USER_DEFINED_COMPILE_OPTIONS <compilation options>
# set USER_DEFINED_VHDL_COMPILE_OPTIONS <compilation options for VHDL>
# set USER_DEFINED_VERILOG_COMPILE_OPTIONS <compilation options for Verilog>
# #
# # Call command to compile the Quartus EDA simulation library.
# dev_com
# #
# # Call command to compile the Quartus-generated IP simulation files.
# com
# #
# # Add commands to compile all design files and testbench files, including
# # the top level. (These are all the files required for simulation other
# # than the files compiled by the Quartus-generated IP simulation script)
# #
# vlog -sv2k5 <your compilation options> <design and testbench files>
# #
# # Set the top-level simulation or testbench module/entity name, which is
# # used by the elab command to elaborate the top level.
# #
# set TOP_LEVEL_NAME <simulation top>
# #
# # Set any elaboration options you require.
# set USER_DEFINED_ELAB_OPTIONS <elaboration options>
# #
# # Call command to elaborate your design and testbench.
# elab
# #
# # Run the simulation.
# run
# #
# # Report success to the shell.
# exit -code 0
# #
# # TOP-LEVEL TEMPLATE - END
# ----------------------------------------
# 
# IP SIMULATION SCRIPT
# ----------------------------------------
# If altera_eth_10g_mac.altera_eth_10g_mac is one of several IP cores in your
# Quartus project, you can generate a simulation script
# suitable for inclusion in your top-level simulation
# script by running the following command line:
# 
# ip-setup-simulation --quartus-project=<quartus project>
# 
# ip-setup-simulation will discover the Intel IP
# within the Quartus project, and generate a unified
# script which supports all the Intel IP within the design.
# ----------------------------------------

# ----------------------------------------
# Initialize variables
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
}

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "altera_eth_10g_mac.altera_eth_10g_mac"
}

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "./../"
}

if ![info exists QUARTUS_INSTALL_DIR] { 
  set QUARTUS_INSTALL_DIR "/swip_build/archive/acds/17.0/290/linux64/quartus/"
}

if ![info exists USER_DEFINED_COMPILE_OPTIONS] { 
  set USER_DEFINED_COMPILE_OPTIONS ""
}
if ![info exists USER_DEFINED_VHDL_COMPILE_OPTIONS] { 
  set USER_DEFINED_VHDL_COMPILE_OPTIONS ""
}
if ![info exists USER_DEFINED_VERILOG_COMPILE_OPTIONS] { 
  set USER_DEFINED_VERILOG_COMPILE_OPTIONS ""
}
if ![info exists USER_DEFINED_ELAB_OPTIONS] { 
  set USER_DEFINED_ELAB_OPTIONS ""
}

# ----------------------------------------
# Initialize simulation properties - DO NOT MODIFY!
set ELAB_OPTIONS ""
set SIM_OPTIONS ""
if ![ string match "*-64 vsim*" [ vsim -version ] ] {
} else {
}

set Aldec "Riviera"
if { [ string match "*Active-HDL*" [ vsim -version ] ] } {
  set Aldec "Active"
}

if { [ string match "Active" $Aldec ] } {
  scripterconf -tcl
  createdesign "$TOP_LEVEL_NAME"  "."
  opendesign "$TOP_LEVEL_NAME"
}

# ----------------------------------------
# Copy ROM/RAM files to simulation directory
alias file_copy {
  echo "\[exec\] file_copy"
}

# ----------------------------------------
# Create compilation libraries
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib      ./libraries     
ensure_lib      ./libraries/work
vmap       work ./libraries/work
ensure_lib                   ./libraries/altera_ver       
vmap       altera_ver        ./libraries/altera_ver       
ensure_lib                   ./libraries/lpm_ver          
vmap       lpm_ver           ./libraries/lpm_ver          
ensure_lib                   ./libraries/sgate_ver        
vmap       sgate_ver         ./libraries/sgate_ver        
ensure_lib                   ./libraries/altera_mf_ver    
vmap       altera_mf_ver     ./libraries/altera_mf_ver    
ensure_lib                   ./libraries/altera_lnsim_ver 
vmap       altera_lnsim_ver  ./libraries/altera_lnsim_ver 
ensure_lib                   ./libraries/twentynm_ver     
vmap       twentynm_ver      ./libraries/twentynm_ver     
ensure_lib                   ./libraries/twentynm_hssi_ver
vmap       twentynm_hssi_ver ./libraries/twentynm_hssi_ver
ensure_lib                   ./libraries/twentynm_hip_ver 
vmap       twentynm_hip_ver  ./libraries/twentynm_hip_ver 
ensure_lib                    ./libraries/alt_em10g32_170   
vmap       alt_em10g32_170    ./libraries/alt_em10g32_170   
ensure_lib                    ./libraries/altera_eth_10g_mac
vmap       altera_eth_10g_mac ./libraries/altera_eth_10g_mac

# ----------------------------------------
# Compile device library files
alias dev_com {
  echo "\[exec\] dev_com"
  eval vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                -work altera_ver       
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                         -work lpm_ver          
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                            -work sgate_ver        
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                        -work altera_mf_ver    
  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                    -work altera_lnsim_ver 
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/twentynm_atoms.v"                   -work twentynm_ver     
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/twentynm_atoms_ncrypt.v"      -work twentynm_ver     
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/twentynm_hssi_atoms_ncrypt.v" -work twentynm_hssi_ver
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/twentynm_hssi_atoms.v"              -work twentynm_hssi_ver
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/twentynm_hip_atoms_ncrypt.v"  -work twentynm_hip_ver 
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/twentynm_hip_atoms.v"               -work twentynm_hip_ver 
}

# ----------------------------------------
# Compile the design files in correct order
alias com {
  echo "\[exec\] com"
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/alt_em10g32.v"                                                                         -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/alt_em10g32unit.v"                                                                     -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_clk_rst.v"                                                             -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_clock_crosser.v"                                                       -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_crc32.v"                                                               -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_crc32_gf_mult32_kc.v"                                                  -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_creg_map.v"                                                            -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_creg_top.v"                                                            -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_frm_decoder.v"                                                         -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_rs_gmii_mii_layer.v"                                                -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_pipeline_base.v"                                                       -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_reset_synchronizer.v"                                                  -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rr_clock_crosser.v"                                                    -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rst_cnt.v"                                                             -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_fctl_filter_crcpad_rem.v"                                           -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_fctl_overflow.v"                                                    -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_fctl_preamble.v"                                                    -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_frm_control.v"                                                      -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_pfc_flow_control.v"                                                 -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_pfc_pause_conversion.v"                                             -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_pkt_backpressure_control.v"                                         -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_rs_gmii16b.v"                                                       -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_rs_gmii16b_top.v"                                                   -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_rs_gmii_mii.v"                                                      -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_rs_layer.v"                                                         -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_rs_xgmii.v"                                                         -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_status_aligner.v"                                                   -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_top.v"                                                              -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_stat_mem.v"                                                            -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_stat_reg.v"                                                            -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_data_frm_gen.v"                                                     -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_srcaddr_inserter.v"                                                 -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_err_aligner.v"                                                      -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_flow_control.v"                                                     -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_frm_arbiter.v"                                                      -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_frm_muxer.v"                                                        -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_pause_beat_conversion.v"                                            -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_pause_frm_gen.v"                                                    -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_pause_req.v"                                                        -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_pfc_frm_gen.v"                                                      -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rr_buffer.v"                                                           -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_rs_gmii16b.v"                                                       -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_rs_gmii16b_top.v"                                                   -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_rs_layer.v"                                                         -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_rs_xgmii_layer.v"                                                   -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_sc_fifo.v"                                                             -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_top.v"                                                              -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_gmii_decoder.v"                                                     -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_gmii_decoder_dfa.v"                                                 -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_gmii_encoder.v"                                                     -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_gmii_encoder_dfa.v"                                                 -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_gmii_mii_decoder_if.v"                                              -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_gmii_mii_encoder_if.v"                                              -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_avalon_mm_adapter/altera_eth_avalon_mm_adapter.v"                  -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_avalon_st_adapter/altera_eth_avalon_st_adapter.v"                  -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter_avalon_st_rx.v"                -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter_avalon_st_tx.v"                -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter.v"                             -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_avalon_st_adapter/alt_em10g32_vldpkt_rddly.v"                      -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_avalon_st_adapter/sideband_adapter_rx.v"                           -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_avalon_st_adapter/sideband_adapter_tx.v"                           -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_avalon_st_adapter/sideband_adapter.v"                              -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_avalon_st_adapter/altera_eth_sideband_crosser.v"                   -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_avalon_st_adapter/altera_eth_sideband_crosser_sync.v"              -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_32_64_xgmii_conversion.v"            -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_32_to_64_xgmii_conversion.v"         -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_64_to_32_xgmii_conversion.v"         -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_dcfifo_32_to_64_xgmii_conversion.v"  -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_dcfifo_64_to_32_xgmii_conversion.v"  -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_32_to_64_adapter.v"    -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_64_to_32_adapter.v"    -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_data_format_adapter.v" -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_altsyncram_bundle.v"                                                   -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_altsyncram.v"                                                          -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_avalon_dc_fifo_lat_calc.v"                                             -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_avalon_dc_fifo_hecc.v"                                                 -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_avalon_dc_fifo_secc.v"                                                 -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_avalon_sc_fifo.v"                                                      -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_avalon_sc_fifo_hecc.v"                                                 -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_avalon_sc_fifo_secc.v"                                                 -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_ecc_dec_18_12.v"                                                       -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_ecc_dec_39_32.v"                                                       -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_ecc_enc_12_18.v"                                                       -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_ecc_enc_32_39.v"                                                       -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_rs_xgmii_layer_ultra.v"                                             -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_rs_xgmii_ultra.v"                                                   -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_avst_to_gmii_if.v"                                                     -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_gmii_to_avst_if.v"                                                     -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_gmii_tsu.v"                                                            -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_gmii16b_tsu.v"                                                         -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_lpm_mult.v"                                                            -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_ptp_aligner.v"                                                      -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_ptp_detector.v"                                                     -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_rx_ptp_top.v"                                                          -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_gmii_crc_inserter.v"                                                -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_gmii16b_crc_inserter.v"                                             -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_gmii_ptp_inserter.v"                                                -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_gmii16b_ptp_inserter.v"                                             -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_gmii16b_ptp_inserter_1g2p5g10g.v"                                   -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_ptp_processor.v"                                                    -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_ptp_top.v"                                                          -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_xgmii_crc_inserter.v"                                               -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_tx_xgmii_ptp_inserter.v"                                               -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_xgmii_tsu.v"                                                           -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_crc328generator.v"                                                     -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_crc32ctl8.v"                                                           -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_crc32galois8.v"                                                        -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_gmii_crc_inserter.v"                                                   -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_gmii16b_crc_inserter.v"                                                -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/aldec/rtl/alt_em10g32_gmii16b_crc32.v"                                                       -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/alt_em10g32_avalon_dc_fifo.v"                                                                -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/alt_em10g32_dcfifo_synchronizer_bundle.v"                                                    -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/alt_em10g32_std_synchronizer.v"                                                              -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/altera_std_synchronizer_nocut.v"                                                             -work alt_em10g32_170   
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_eth_10g_mac.v"                                                                                               -work altera_eth_10g_mac
}

# ----------------------------------------
# Elaborate top level design
alias elab {
  echo "\[exec\] elab"
  eval vsim +access +r -t ps $ELAB_OPTIONS -L work -L alt_em10g32_170 -L altera_eth_10g_mac -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L twentynm_ver -L twentynm_hssi_ver -L twentynm_hip_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Elaborate the top level design with -dbg -O2 option
alias elab_debug {
  echo "\[exec\] elab_debug"
  eval vsim -dbg -O2 +access +r -t ps $ELAB_OPTIONS -L work -L alt_em10g32_170 -L altera_eth_10g_mac -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L twentynm_ver -L twentynm_hssi_ver -L twentynm_hip_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with -dbg -O2
alias ld_debug "
  dev_com
  com
  elab_debug
"

# ----------------------------------------
# Print out user commmand line aliases
alias h {
  echo "List Of Command Line Aliases"
  echo
  echo "file_copy                                         -- Copy ROM/RAM files to simulation directory"
  echo
  echo "dev_com                                           -- Compile device library files"
  echo
  echo "com                                               -- Compile the design files in correct order"
  echo
  echo "elab                                              -- Elaborate top level design"
  echo
  echo "elab_debug                                        -- Elaborate the top level design with -dbg -O2 option"
  echo
  echo "ld                                                -- Compile all the design files and elaborate the top level design"
  echo
  echo "ld_debug                                          -- Compile all the design files and elaborate the top level design with -dbg -O2"
  echo
  echo 
  echo
  echo "List Of Variables"
  echo
  echo "TOP_LEVEL_NAME                                    -- Top level module name."
  echo "                                                     For most designs, this should be overridden"
  echo "                                                     to enable the elab/elab_debug aliases."
  echo
  echo "SYSTEM_INSTANCE_NAME                              -- Instantiated system module name inside top level module."
  echo
  echo "QSYS_SIMDIR                                       -- Qsys base simulation directory."
  echo
  echo "QUARTUS_INSTALL_DIR                               -- Quartus installation directory."
  echo
  echo "USER_DEFINED_COMPILE_OPTIONS                      -- User-defined compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_VHDL_COMPILE_OPTIONS                 -- User-defined vhdl compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_VERILOG_COMPILE_OPTIONS              -- User-defined verilog compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_ELAB_OPTIONS                         -- User-defined elaboration options, added to elab/elab_debug aliases."
}
file_copy
h
