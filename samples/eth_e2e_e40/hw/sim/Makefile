AFU_DIR := ../rtl
SIM_DIR := .
DEFINES := +define+E2E_E40
INC_DIRS := +incdir+$(SIM_DIR)/include +incdir+$(AFU_DIR)/e40/alt_eth_ultra_160/synth
VLOG_ARGS := -sv $(DEFINES) $(INC_DIRS)
VSIM_ARGS := -do "run -all" -c -suppress 3016
VSIM_ARGS_DEBUG := -do "log -r *;run -all" -gui -novopt -suppress 3016
MSIM_LIBS := -L $(SIM_DIR)/intellibs/lpm_ver \
	-L $(SIM_DIR)/intellibs/altera_ver \
	-L $(SIM_DIR)/intellibs/sgate_ver \
	-L $(SIM_DIR)/intellibs/altera_lnsim_ver \
	-L $(SIM_DIR)/intellibs/altera_mf_ver \
	-L $(SIM_DIR)/intellibs/twentynm_ver \
	-L $(SIM_DIR)/intellibs/twentynm_hip_ver \
	-L $(SIM_DIR)/intellibs/twentynm_hssi_ver \
	-L $(SIM_DIR)/libs/E40G \
	-L $(SIM_DIR)/libs/E40G_ncrypt \
	-L $(SIM_DIR)/work

default: clean sim

debug: clean sim_debug

$(SIM_DIR)/libs:
	mkdir $(SIM_DIR)/libs
	vlib $(SIM_DIR)/libs/E40G
	vlib $(SIM_DIR)/libs/E40G_ncrypt
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/a10_40bit_4pack.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/a10_5way_register.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/a10mlab.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/accum.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/aclr_filter.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/agtb_16.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/agtb_8.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/align_16.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/alt_aeu_40_eth_2.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/alt_aeu_40_pcs_assembly.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/alt_aeu_40_top.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/alt_delay_dynamic_m20k.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/and_r.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/aneb_18.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/arria10_atx_pll.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/bip_xor_5way.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/bip_xor.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/capture_m20k.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/capture.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/clos_20_perm.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/clos_20_unperm.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/clos_20.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/cntr.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/compressor_4to3.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/crc32_byte_roll.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/crc32_d64_sig.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/crc32_rev_1.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/crc32_rev_2.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/crc32_rev_4.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/crc32_z64_x1.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/crc32_z64_x2.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/crc32_z64_x3.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/crc32_z64_x4.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/crc32_z64_xn.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/cross_handshake.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/cross_mlab.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/cross_sparse_valid.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/cross_strobe.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/dcfifo_mlab_ack.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/dcfifo_mlab.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/delay_dynamic.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/delay_mlab.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/delay_regs_ena.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/delay_regs.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/descrambler.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/descrambler_wys.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/dip8_32.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/divider.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/e40_io_frame_40.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/e40_reco.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/e40_rx_pll.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/e40_tx_pll_644.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/e40.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/ecrc_4.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/ectrl_frac_4.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/ectrl_tag_4.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/eq_10_const.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/eq_18_const.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/eq_18.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/eq_5_ena.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/eth_reframe.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/eth_tx_tagger_5way.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/eth_tx_tagger.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/eth_unframe.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/frequency_monitor.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/gb_16_66_x5.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/grace_period_16.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/grace_period_64.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/grace_period_8.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/gray_cntr_4_sl.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/gray_cntr_4.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/gray_cntr_5_sl.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/gray_to_bin_4.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/gray_to_bin_5.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/gx_a10_40g_644.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/interval_timer.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/jtag_bytes.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/jtag_master.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/jtag_shift_reg.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/lfsr.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/mix_odd_even.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/mlab_32word_32bit.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/mx16r.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/mx4r.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/mx5r.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/mx8r.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/neq_5_ena.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/opposite_18.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/opposite_36.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/opposite_3.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/or_r.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/pgen.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/reg_tree.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/reset_delay.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/reverse_bits.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/reverse_bytes.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/s5_40bit_4pack.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/s5_40bit_trip_raw.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/s5_5way_register.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/s5mlab.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/s5xcvr.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/scfifo_a10m20k.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/scfifo_mlab.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/scfifo_s5m20k.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/scrambler.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/sep_odd_even.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/serif_master.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/serif_slave_async.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/serif_slave.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/serif_tap.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/shifter_100ge_gbx.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/sim_block_decoder_ns.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/sim_block_decoder.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/sim_mii_decode_multiple.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/stacker2.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/stat_ram_16x64b.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/stripe_5way.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/sync_regs_aclr_m2.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/sync_regs_m2.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/sync_regs.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/uart.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/vlane_id.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/watchdog_timer.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/wys_lut.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/xbar_4.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/xbar_5.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/xor_2tick_b.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/xor_2tick_t.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/xor_2tick.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/xor_lut.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/xor_r_b.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/xor_r_t.v
	vlog $(VLOG_ARGS) -work ./libs/E40G $(AFU_DIR)/e40/alt_eth_ultra_160/synth/xor_r.v
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_adapter_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_adapter_rx.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_adapter_tx.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_align_40.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_avl_filter.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_bip_xor_2way.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_capture.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_efc_top.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_gb_40_66_x2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_hproc_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_interval_timer.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_mac_chk_pkt.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_mac_link_fault_det.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_mac_link_fault_gen.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_mac_rx_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_mac_rx_csr.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_mac_stats_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_mac_tx_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_mac_tx_csr.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pcs_ber_cnt_ns.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pcs_ber_sm.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pcs_ber.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_mspipe.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_rx_counter.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_rx_csr.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_rx_ctrl.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_rx_dp.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_rx_qctrl.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_rx.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_top.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_tx_csr.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_tx_ctrl.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_tx_dpipe.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_tx_idp.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_tx_lctrl.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_tx_odp.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_tx_qctrl.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_pfc_tx.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_rx_pcs_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sane_block_decode.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sane_block_encode.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_pipe_line.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_rx_csr.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_rx_ctrl.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_rx_dp.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_rx_qctrl.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_rx.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_top.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_tx_csr.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_tx_ctrl.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_tx_dfsm.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_tx_dpipe.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_tx_idp.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_tx_lctrl.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_tx_odp.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_tx_qctrl.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sfc_tx.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_stats_reg.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_status_sync.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_stripe_2way.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_sync_arst.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_tx_error.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_tx_pcs_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_tx_tagger_2way.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_vlane_id.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_wide_l4if_rx2to4fifo.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_wide_l4if_rx2to4.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_wide_l4if_sopfifo.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_wide_l4if_tx4to2fifo.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_wide_l4if_tx4to2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_40_xlgmii_custom_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_adj_offset.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_adp_ff.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_chk_sum.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_clks_40.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_cor_chksum.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_cyc_ahd.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_dform.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_dly_3_cyc.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_dly_mlab.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_fifo_depth_40.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_fld_mod.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_fld_shl.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_fld_shr.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_ptp_2calc.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_ptp_extr.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_ptp_fld.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_ptp_rx_40.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_ptp_tx.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_tx_pkt_40.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/alt_aeu_wd_match.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/crc32_z64_x2_unreg.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/ecrc_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/ectrl_dic_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/ectrl_frac_2_8.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/ectrl_frac_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/ectrl_gap_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/ectrl_ins_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/ectrl_ins4preamble_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/ectrl_preamble_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/ectrl_tag_2.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/sc_fifo_ptp.vp
	vlog $(VLOG_ARGS) -work ./libs/E40G_ncrypt $(AFU_DIR)/e40/alt_eth_ultra_160/mentor/shifter_40ge_gbx.vp

$(SIM_DIR)/intellibs:
	mkdir $(SIM_DIR)/intellibs
	vlog $(VLOG_ARGS) $(QUARTUS_DIR)/eda/sim_lib/altera_primitives.v                 -work $(SIM_DIR)/intellibs/altera_ver
	vlog $(VLOG_ARGS) $(QUARTUS_DIR)/eda/sim_lib/220model.v                          -work $(SIM_DIR)/intellibs/lpm_ver
	vlog $(VLOG_ARGS) $(QUARTUS_DIR)/eda/sim_lib/sgate.v                             -work $(SIM_DIR)/intellibs/sgate_ver
	vlog $(VLOG_ARGS) $(QUARTUS_DIR)/eda/sim_lib/altera_mf.v                         -work $(SIM_DIR)/intellibs/altera_mf_ver
	vlog $(VLOG_ARGS) $(QUARTUS_DIR)/eda/sim_lib/altera_lnsim.sv                     -work $(SIM_DIR)/intellibs/altera_lnsim_ver
	vlog $(VLOG_ARGS) $(QUARTUS_DIR)/eda/sim_lib/twentynm_atoms.v                    -work $(SIM_DIR)/intellibs/twentynm_ver
	vlog $(VLOG_ARGS) $(QUARTUS_DIR)/eda/sim_lib/mentor/twentynm_atoms_ncrypt.v      -work $(SIM_DIR)/intellibs/twentynm_ver
	vlog $(VLOG_ARGS) $(QUARTUS_DIR)/eda/sim_lib/mentor/twentynm_hssi_atoms_ncrypt.v -work $(SIM_DIR)/intellibs/twentynm_hssi_ver
	vlog $(VLOG_ARGS) $(QUARTUS_DIR)/eda/sim_lib/twentynm_hssi_atoms.v               -work $(SIM_DIR)/intellibs/twentynm_hssi_ver
	vlog $(VLOG_ARGS) $(QUARTUS_DIR)/eda/sim_lib/mentor/twentynm_hip_atoms_ncrypt.v  -work $(SIM_DIR)/intellibs/twentynm_hip_ver
	vlog $(VLOG_ARGS) $(QUARTUS_DIR)/eda/sim_lib/twentynm_hip_atoms.v                -work $(SIM_DIR)/intellibs/twentynm_hip_ver  

$(SIM_DIR)/work:
	vlib $(SIM_DIR)/work
	vmap work $(SIM_DIR)/work
	vlog $(VLOG_ARGS) -work work $(SIM_DIR)/include/ccip_if_pkg.sv
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/ccip_interface_reg.sv
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/ccip_std_afu.sv
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/e10_avl_st_gen.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/e10_avl_st_mon.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/eth_e2e_e40.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/eth_pkt_csr.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/eth_pkt_gen.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/eth_pkt_mon.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/eth_traff_ctrl.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/i2c_contrl.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/trans_bit.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/hsl_files/*.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/e40/synth/e40.v
	vlog $(VLOG_ARGS) -work work ./tb.sv
	
sim_debug: $(SIM_DIR)/work $(SIM_DIR)/libs $(SIM_DIR)/intellibs
	cp $(AFU_DIR)/e40/alt_eth_ultra_160/synth/*.hex $(SIM_DIR)
	vsim $(VSIM_ARGS_DEBUG) tb $(MSIM_LIBS)  $(INC_DIRS)
	

sim: $(SIM_DIR)/work $(SIM_DIR)/libs $(SIM_DIR)/intellibs
	cp $(AFU_DIR)/e40/alt_eth_ultra_160/synth/*.hex $(SIM_DIR)
	vsim $(VSIM_ARGS) tb $(MSIM_LIBS) $(INC_DIRS)

clean:
	rm -f $(SIM_DIR)/*.hex
	rm -f $(SIM_DIR)/*.ver
	rm -f $(SIM_DIR)/transcript
	rm -f $(SIM_DIR)/vsim.wlf
	rm -f $(SIM_DIR)/modelsim.ini
	rm -rf $(SIM_DIR)/work
	
clobber: clean
	rm -rf $(SIM_DIR)/libs
	rm -rf $(SIM_DIR)/intellibs
