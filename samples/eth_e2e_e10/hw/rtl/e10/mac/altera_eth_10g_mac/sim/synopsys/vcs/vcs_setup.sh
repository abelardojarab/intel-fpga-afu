
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
# vcs - auto-generated simulation script

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
# testbench files, follow the guidelines below.
# 
# 1) Copy the shell script text from the TOP-LEVEL TEMPLATE section
# below into a new file, e.g. named "vcs_sim.sh".
# 
# 2) Copy the text from the DESIGN FILE LIST & OPTIONS TEMPLATE section into
# a separate file, e.g. named "filelist.f".
# 
# ----------------------------------------
# # TOP-LEVEL TEMPLATE - BEGIN
# #
# # TOP_LEVEL_NAME is used in the Quartus-generated IP simulation script to
# # set the top-level simulation or testbench module/entity name.
# #
# # QSYS_SIMDIR is used in the Quartus-generated IP simulation script to
# # construct paths to the files required to simulate the IP in your Quartus
# # project. By default, the IP script assumes that you are launching the
# # simulator from the IP script location. If launching from another
# # location, set QSYS_SIMDIR to the output directory you specified when you
# # generated the IP script, relative to the directory from which you launch
# # the simulator.
# #
# # Source the Quartus-generated IP simulation script and do the following:
# # - Compile the Quartus EDA simulation library and IP simulation files.
# # - Specify TOP_LEVEL_NAME and QSYS_SIMDIR.
# # - Compile the design and top-level simulation module/entity using
# #   information specified in "filelist.f".
# # - Override the default USER_DEFINED_SIM_OPTIONS. For example, to run
# #   until $finish(), set to an empty string: USER_DEFINED_SIM_OPTIONS="".
# # - Run the simulation.
# #
# source <script generation output directory>/synopsys/vcs/vcs_setup.sh \
# TOP_LEVEL_NAME=<simulation top> \
# QSYS_SIMDIR=<script generation output directory> \
# USER_DEFINED_ELAB_OPTIONS="\"-f filelist.f\"" \
# USER_DEFINED_SIM_OPTIONS=<simulation options for your design>
# #
# # TOP-LEVEL TEMPLATE - END
# ----------------------------------------
# 
# ----------------------------------------
# # DESIGN FILE LIST & OPTIONS TEMPLATE - BEGIN
# #
# # Compile all design files and testbench files, including the top level.
# # (These are all the files required for simulation other than the files
# # compiled by the Quartus-generated IP simulation script)
# #
# +systemverilogext+.sv
# <design and testbench files, compile-time options, elaboration options>
# #
# # DESIGN FILE LIST & OPTIONS TEMPLATE - END
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
TOP_LEVEL_NAME="altera_eth_10g_mac"
QSYS_SIMDIR="./../../"
QUARTUS_INSTALL_DIR="/swip_build/archive/acds/17.0/290/linux64/quartus/"
SKIP_FILE_COPY=0
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
# copy RAM/ROM files to simulation directory

vcs -lca -timescale=1ps/1ps -sverilog +verilog2001ext+.v -ntb_opts dtm $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v \
  $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/twentynm_atoms.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/twentynm_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/twentynm_hssi_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/twentynm_hssi_atoms.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/twentynm_hip_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/twentynm_hip_atoms.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/alt_em10g32.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/alt_em10g32unit.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_clk_rst.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_clock_crosser.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_crc32.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_crc32_gf_mult32_kc.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_creg_map.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_creg_top.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_frm_decoder.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_rs_gmii_mii_layer.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_pipeline_base.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_reset_synchronizer.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rr_clock_crosser.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rst_cnt.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_fctl_filter_crcpad_rem.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_fctl_overflow.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_fctl_preamble.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_frm_control.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_pfc_flow_control.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_pfc_pause_conversion.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_pkt_backpressure_control.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_rs_gmii16b.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_rs_gmii16b_top.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_rs_gmii_mii.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_rs_layer.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_rs_xgmii.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_status_aligner.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_top.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_stat_mem.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_stat_reg.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_data_frm_gen.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_srcaddr_inserter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_err_aligner.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_flow_control.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_frm_arbiter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_frm_muxer.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_pause_beat_conversion.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_pause_frm_gen.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_pause_req.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_pfc_frm_gen.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rr_buffer.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_rs_gmii16b.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_rs_gmii16b_top.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_rs_layer.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_rs_xgmii_layer.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_sc_fifo.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_top.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_gmii_decoder.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_gmii_decoder_dfa.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii_encoder.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii_encoder_dfa.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_gmii_mii_decoder_if.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii_mii_encoder_if.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_mm_adapter/altera_eth_avalon_mm_adapter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/altera_eth_avalon_st_adapter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter_avalon_st_rx.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter_avalon_st_tx.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/alt_em10g32_vldpkt_rddly.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/sideband_adapter_rx.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/sideband_adapter_tx.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/sideband_adapter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/altera_eth_sideband_crosser.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_avalon_st_adapter/altera_eth_sideband_crosser_sync.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_32_64_xgmii_conversion.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_32_to_64_xgmii_conversion.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_64_to_32_xgmii_conversion.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_dcfifo_32_to_64_xgmii_conversion.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_dcfifo_64_to_32_xgmii_conversion.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_32_to_64_adapter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_64_to_32_adapter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_data_format_adapter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_altsyncram_bundle.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_altsyncram.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avalon_dc_fifo_lat_calc.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avalon_dc_fifo_hecc.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avalon_dc_fifo_secc.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avalon_sc_fifo.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avalon_sc_fifo_hecc.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avalon_sc_fifo_secc.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_ecc_dec_18_12.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_ecc_dec_39_32.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_ecc_enc_12_18.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_ecc_enc_32_39.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_rs_xgmii_layer_ultra.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_rs_xgmii_ultra.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_avst_to_gmii_if.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_gmii_to_avst_if.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_gmii_tsu.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_gmii16b_tsu.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_lpm_mult.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_ptp_aligner.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_ptp_detector.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_rx_ptp_top.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii_crc_inserter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii16b_crc_inserter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii_ptp_inserter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii16b_ptp_inserter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_gmii16b_ptp_inserter_1g2p5g10g.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_ptp_processor.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_ptp_top.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_xgmii_crc_inserter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_tx_xgmii_ptp_inserter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_xgmii_tsu.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_crc328generator.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_crc32ctl8.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_crc32galois8.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_gmii_crc_inserter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_gmii16b_crc_inserter.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/synopsys/rtl/alt_em10g32_gmii16b_crc32.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/alt_em10g32_avalon_dc_fifo.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/alt_em10g32_dcfifo_synchronizer_bundle.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/alt_em10g32_std_synchronizer.v \
  $QSYS_SIMDIR/../alt_em10g32_170/sim/altera_std_synchronizer_nocut.v \
  $QSYS_SIMDIR/altera_eth_10g_mac.v \
  -top $TOP_LEVEL_NAME
# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS
fi
