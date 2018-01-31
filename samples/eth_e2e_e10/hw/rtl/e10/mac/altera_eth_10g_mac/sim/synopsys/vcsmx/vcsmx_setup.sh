
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
# vcsmx - auto-generated simulation script

# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     altera_eth_10g_mac.altera_eth_10g_mac
# 
# Intel recommends that you source this Quartus-generated IP simulation
# script from your own customized top-level script, and avoid editing this
# generated script.
# 
# To write a top-level shell script that compiles Intel simulation libraries 
# and the Quartus-generated IP in your project, along with your design and
# testbench files, copy the text from the TOP-LEVEL TEMPLATE section below
# into a new file, e.g. named "vcsmx_sim.sh", and modify text as directed.
# 
# You can also modify the simulation flow to suit your needs. Set the
# following variables to 1 to disable their corresponding processes:
# - SKIP_FILE_COPY: skip copying ROM/RAM initialization files
# - SKIP_DEV_COM: skip compiling the Quartus EDA simulation library
# - SKIP_COM: skip compiling Quartus-generated IP simulation files
# - SKIP_ELAB and SKIP_SIM: skip elaboration and simulation
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
# # the simulator. In this case, you must also copy the generated library
# # setup "synopsys_sim.setup" into the location from which you launch the
# # simulator, or incorporate into any existing library setup.
# #
# # Run Quartus-generated IP simulation script once to compile Quartus EDA
# # simulation libraries and Quartus-generated IP simulation files, and copy
# # any ROM/RAM initialization files to the simulation directory.
# #
# # - If necessary, specify any compilation options:
# #   USER_DEFINED_COMPILE_OPTIONS
# #   USER_DEFINED_VHDL_COMPILE_OPTIONS applied to vhdl compiler
# #   USER_DEFINED_VERILOG_COMPILE_OPTIONS applied to verilog compiler
# #
# source <script generation output directory>/synopsys/vcsmx/vcsmx_setup.sh \
# SKIP_ELAB=1 \
# SKIP_SIM=1 \
# USER_DEFINED_COMPILE_OPTIONS=<compilation options for your design> \
# USER_DEFINED_VHDL_COMPILE_OPTIONS=<VHDL compilation options for your design> \
# USER_DEFINED_VERILOG_COMPILE_OPTIONS=<Verilog compilation options for your design> \
# QSYS_SIMDIR=<script generation output directory>
# #
# # Compile all design files and testbench files, including the top level.
# # (These are all the files required for simulation other than the files
# # compiled by the IP script)
# #
# vlogan <compilation options> <design and testbench files>
# #
# # TOP_LEVEL_NAME is used in this script to set the top-level simulation or
# # testbench module/entity name.
# #
# # Run the IP script again to elaborate and simulate the top level:
# # - Specify TOP_LEVEL_NAME and USER_DEFINED_ELAB_OPTIONS.
# # - Override the default USER_DEFINED_SIM_OPTIONS. For example, to run
# #   until $finish(), set to an empty string: USER_DEFINED_SIM_OPTIONS="".
# #
# source <script generation output directory>/synopsys/vcsmx/vcsmx_setup.sh \
# SKIP_FILE_COPY=1 \
# SKIP_DEV_COM=1 \
# SKIP_COM=1 \
# TOP_LEVEL_NAME="'-top <simulation top>'" \
# QSYS_SIMDIR=<script generation output directory> \
# USER_DEFINED_ELAB_OPTIONS=<elaboration options for your design> \
# USER_DEFINED_SIM_OPTIONS=<simulation options for your design>
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
# ACDS 17.0 290 linux 2017.11.29.16:17:28
# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="altera_eth_10g_mac.altera_eth_10g_mac"
QSYS_SIMDIR="./../../"
QUARTUS_INSTALL_DIR="/swip_build/archive/acds/17.0/290/linux64/quartus/"
SKIP_FILE_COPY=0
SKIP_DEV_COM=0
SKIP_COM=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

# ----------------------------------------
# initialize simulation properties - DO NOT MODIFY!
ELAB_OPTIONS=""
SIM_OPTIONS=""
if [[ `vcs -platform` != *"amd64"* ]]; then
  :
else
  :
fi

# ----------------------------------------
# create compilation libraries
mkdir -p ./libraries/work/
mkdir -p ./libraries/alt_em10g32_170/
mkdir -p ./libraries/altera_eth_10g_mac/
mkdir -p ./libraries/altera_ver/
mkdir -p ./libraries/lpm_ver/
mkdir -p ./libraries/sgate_ver/
mkdir -p ./libraries/altera_mf_ver/
mkdir -p ./libraries/altera_lnsim_ver/
mkdir -p ./libraries/twentynm_ver/
mkdir -p ./libraries/twentynm_hssi_ver/
mkdir -p ./libraries/twentynm_hip_ver/

# ----------------------------------------
# copy RAM/ROM files to simulation directory

# ----------------------------------------
# compile device library files
if [ $SKIP_DEV_COM -eq 0 ]; then
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                   -work altera_ver       
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                            -work lpm_ver          
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                               -work sgate_ver        
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                           -work altera_mf_ver    
  vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                       -work altera_lnsim_ver 
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/twentynm_atoms.v"                      -work twentynm_ver     
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/twentynm_atoms_ncrypt.v"      -work twentynm_ver     
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/twentynm_hssi_atoms_ncrypt.v" -work twentynm_hssi_ver
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/twentynm_hssi_atoms.v"                 -work twentynm_hssi_ver
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/twentynm_hip_atoms_ncrypt.v"  -work twentynm_hip_ver 
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/twentynm_hip_atoms.v"                  -work twentynm_hip_ver 
fi

# ----------------------------------------
# compile design files in correct order
if [ $SKIP_COM -eq 0 ]; then
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/alt_em10g32.v"                                                                         -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/alt_em10g32unit.v"                                                                     -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_clk_rst.v"                                                             -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_clock_crosser.v"                                                       -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_crc32.v"                                                               -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_crc32_gf_mult32_kc.v"                                                  -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_creg_map.v"                                                            -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_creg_top.v"                                                            -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_frm_decoder.v"                                                         -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_rs_gmii_mii_layer.v"                                                -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_pipeline_base.v"                                                       -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_reset_synchronizer.v"                                                  -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rr_clock_crosser.v"                                                    -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rst_cnt.v"                                                             -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_fctl_filter_crcpad_rem.v"                                           -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_fctl_overflow.v"                                                    -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_fctl_preamble.v"                                                    -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_frm_control.v"                                                      -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_pfc_flow_control.v"                                                 -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_pfc_pause_conversion.v"                                             -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_pkt_backpressure_control.v"                                         -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_rs_gmii16b.v"                                                       -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_rs_gmii16b_top.v"                                                   -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_rs_gmii_mii.v"                                                      -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_rs_layer.v"                                                         -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_rs_xgmii.v"                                                         -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_status_aligner.v"                                                   -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_top.v"                                                              -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_stat_mem.v"                                                            -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_stat_reg.v"                                                            -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_data_frm_gen.v"                                                     -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_srcaddr_inserter.v"                                                 -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_err_aligner.v"                                                      -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_flow_control.v"                                                     -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_frm_arbiter.v"                                                      -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_frm_muxer.v"                                                        -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_pause_beat_conversion.v"                                            -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_pause_frm_gen.v"                                                    -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_pause_req.v"                                                        -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_pfc_frm_gen.v"                                                      -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rr_buffer.v"                                                           -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_rs_gmii16b.v"                                                       -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_rs_gmii16b_top.v"                                                   -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_rs_layer.v"                                                         -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_rs_xgmii_layer.v"                                                   -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_sc_fifo.v"                                                             -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_top.v"                                                              -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_gmii_decoder.v"                                                     -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_gmii_decoder_dfa.v"                                                 -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii_encoder.v"                                                     -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii_encoder_dfa.v"                                                 -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_gmii_mii_decoder_if.v"                                              -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii_mii_encoder_if.v"                                              -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_mm_adapter/altera_eth_avalon_mm_adapter.v"                  -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/altera_eth_avalon_st_adapter.v"                  -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter_avalon_st_rx.v"                -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter_avalon_st_tx.v"                -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter.v"                             -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/alt_em10g32_vldpkt_rddly.v"                      -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/sideband_adapter_rx.v"                           -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/sideband_adapter_tx.v"                           -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/sideband_adapter.v"                              -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/altera_eth_sideband_crosser.v"                   -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/altera_eth_sideband_crosser_sync.v"              -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_32_64_xgmii_conversion.v"            -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_32_to_64_xgmii_conversion.v"         -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_64_to_32_xgmii_conversion.v"         -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_dcfifo_32_to_64_xgmii_conversion.v"  -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_dcfifo_64_to_32_xgmii_conversion.v"  -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_32_to_64_adapter.v"    -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_64_to_32_adapter.v"    -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_data_format_adapter.v" -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_altsyncram_bundle.v"                                                   -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_altsyncram.v"                                                          -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avalon_dc_fifo_lat_calc.v"                                             -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avalon_dc_fifo_hecc.v"                                                 -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avalon_dc_fifo_secc.v"                                                 -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avalon_sc_fifo.v"                                                      -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avalon_sc_fifo_hecc.v"                                                 -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avalon_sc_fifo_secc.v"                                                 -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_ecc_dec_18_12.v"                                                       -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_ecc_dec_39_32.v"                                                       -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_ecc_enc_12_18.v"                                                       -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_ecc_enc_32_39.v"                                                       -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_rs_xgmii_layer_ultra.v"                                             -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_rs_xgmii_ultra.v"                                                   -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avst_to_gmii_if.v"                                                     -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_gmii_to_avst_if.v"                                                     -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_gmii_tsu.v"                                                            -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_gmii16b_tsu.v"                                                         -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_lpm_mult.v"                                                            -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_ptp_aligner.v"                                                      -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_ptp_detector.v"                                                     -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_ptp_top.v"                                                          -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii_crc_inserter.v"                                                -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii16b_crc_inserter.v"                                             -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii_ptp_inserter.v"                                                -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii16b_ptp_inserter.v"                                             -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii16b_ptp_inserter_1g2p5g10g.v"                                   -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_ptp_processor.v"                                                    -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_ptp_top.v"                                                          -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_xgmii_crc_inserter.v"                                               -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_xgmii_ptp_inserter.v"                                               -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_xgmii_tsu.v"                                                           -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_crc328generator.v"                                                     -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_crc32ctl8.v"                                                           -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_crc32galois8.v"                                                        -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_gmii_crc_inserter.v"                                                   -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_gmii16b_crc_inserter.v"                                                -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_gmii16b_crc32.v"                                                       -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/alt_em10g32_avalon_dc_fifo.v"                                                                   -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/alt_em10g32_dcfifo_synchronizer_bundle.v"                                                       -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/alt_em10g32_std_synchronizer.v"                                                                 -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/../alt_em10g32_170/sim/altera_std_synchronizer_nocut.v"                                                                -work alt_em10g32_170   
  vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_eth_10g_mac.v"                                                                                                  -work altera_eth_10g_mac
fi

# ----------------------------------------
# elaborate top level design
if [ $SKIP_ELAB -eq 0 ]; then
  vcs -lca -t ps $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS $TOP_LEVEL_NAME
fi

# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS
fi
