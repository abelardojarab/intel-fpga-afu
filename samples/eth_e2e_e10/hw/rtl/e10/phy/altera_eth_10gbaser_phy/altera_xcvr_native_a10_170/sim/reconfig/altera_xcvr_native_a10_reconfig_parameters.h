#ifndef __ALTERA_XCVR_NATIVE_A10_RECONFIG_PARAMETERS_H__
#define __ALTERA_XCVR_NATIVE_A10_RECONFIG_PARAMETERS_H__

#ifdef ALTERA_XCVR_NATIVE_A10_DECLARE_RAM_ARRAY
#define ALTERA_XCVR_NATIVE_A10_RAM_SIZE 146
unsigned int altera_xcvr_native_a10_ram_array[146] = {
    0x006DF03, /* [25:16]-DPRIO address=0x006; [15:8]-bit mask=0xDF; [7:7]-hssi_tx_pcs_pma_interface_sqwgen_clken=sqwgen_clk_dis(1'h0); [6:6]-hssi_tx_pcs_pma_interface_prbs_clken=prbs_clk_dis(1'h0); [4:4]-hssi_tx_pcs_pma_interface_master_clk_sel=master_tx_pma_clk(1'h0); [3:3]-hssi_tx_pcs_pma_interface_prbs9_dwidth=prbs9_64b(1'h0); [2:0]-hssi_tx_pcs_pma_interface_tx_pma_data_sel=ten_g_pcs(3'h3); */
    0x007FF01, /* [25:16]-DPRIO address=0x007; [15:8]-bit mask=0xFF; [7:4]-hssi_tx_pcs_pma_interface_prbs_gen_pat=prbs_gen_dis(4'h0); [3:3]-hssi_tx_pcs_pma_interface_tx_dyn_polarity_inversion=tx_dyn_polinv_dis(1'h0); [2:2]-hssi_tx_pcs_pma_interface_tx_static_polarity_inversion=tx_stat_polinv_dis(1'h0); [1:1]-hssi_tx_pcs_pma_interface_pmagate_en=pmagate_dis(1'h0); [0:0]-hssi_tx_pcs_pma_interface_bypass_pma_txelecidle=true(1'h1); */
    0x008FF04, /* [25:16]-DPRIO address=0x008; [15:8]-bit mask=0xFF; [7:7]-hssi_tx_pcs_pma_interface_pldif_datawidth_mode=pldif_data_10bit(1'h0); [6:5]-hssi_tx_pcs_pma_interface_tx_pma_data_sel=ten_g_pcs(2'h0); [4:4]-hssi_tx_pcs_pma_interface_prbs_gen_pat=prbs_gen_dis(1'h0); [3:0]-hssi_tx_pcs_pma_interface_sq_wave_num=sq_wave_default(4'h4); */
    0x00AFF02, /* [25:16]-DPRIO address=0x00A; [15:8]-bit mask=0xFF; [7:7]-hssi_rx_pcs_pma_interface_prbs_clken=prbs_clk_dis(1'h0); [6:5]-hssi_rx_pcs_pma_interface_master_clk_sel=master_rx_pma_clk(2'h0); [4:4]-hssi_rx_pcs_pma_interface_rx_static_polarity_inversion=rx_stat_polinv_dis(1'h0); [3:3]-hssi_rx_pcs_pma_interface_rx_lpbk_en=lpbk_dis(1'h0); [2:2]-hssi_rx_pcs_pma_interface_clkslip_sel=pld(1'h0); [1:0]-hssi_rx_pcs_pma_interface_block_sel=ten_g_pcs(2'h2); */
    0x00BFF02, /* [25:16]-DPRIO address=0x00B; [15:8]-bit mask=0xFF; [7:4]-hssi_rx_pcs_pma_interface_prbs_ver=prbs_off(4'h0); [3:2]-hssi_rx_pcs_pma_interface_rx_prbs_mask=prbsmask128(2'h0); [1:1]-hssi_rx_pcs_pma_interface_rx_prbs_mode=teng_mode(1'h1); [0:0]-hssi_rx_pcs_pma_interface_rx_dyn_polarity_inversion=rx_dyn_polinv_dis(1'h0); */
    0x00C0F02, /* [25:16]-DPRIO address=0x00C; [15:8]-bit mask=0x0F; [3:3]-hssi_rx_pcs_pma_interface_prbs9_dwidth=prbs9_64b(1'h0); [2:2]-hssi_rx_pcs_pma_interface_rx_signalok_signaldet_sel=sel_sig_det(1'h0); [1:1]-hssi_rx_pcs_pma_interface_rx_prbs_force_signal_ok=force_sig_ok(1'h1); [0:0]-hssi_rx_pcs_pma_interface_prbs_ver=prbs_off(1'h0); */
    0x00DFD00, /* [25:16]-DPRIO address=0x00D; [15:8]-bit mask=0xFD; [7:7]-hssi_common_pcs_pma_interface_ppm_deassert_early=deassert_early_dis(1'h0); [6:6]-hssi_common_pcs_pma_interface_ppm_cnt_rst=ppm_cnt_rst_dis(1'h0); [5:5]-hssi_common_pcs_pma_interface_asn_enable=dis_asn(1'h0); [4:4]-hssi_common_pcs_pma_interface_ppm_gen1_2_cnt=cnt_32k(1'h0); [3:3]-hssi_common_pcs_pma_interface_ppm_post_eidle_delay=cnt_200_cycles(1'h0); [2:2]-hssi_common_pcs_pma_interface_pipe_if_g3pcs=pipe_if_8gpcs(1'h0); [0:0]-hssi_common_pcs_pma_interface_block_sel=eight_g_pcs(1'h0); */
    0x00EFF80, /* [25:16]-DPRIO address=0x00E; [15:8]-bit mask=0xFF; [7:2]-hssi_common_pcs_pma_interface_ppmsel=ppmsel_1000(6'h20); [1:0]-hssi_common_pcs_pma_interface_force_freqdet=force_freqdet_dis(2'h0); */
    0x00F9F00, /* [25:16]-DPRIO address=0x00F; [15:8]-bit mask=0x9F; [7:7]-hssi_rx_pcs_pma_interface_pldif_datawidth_mode=pldif_data_10bit(1'h0); [4:4]-hssi_tx_pcs_pma_interface_pma_if_dft_en=dft_dis(1'h0); [3:3]-hssi_rx_pcs_pma_interface_pma_if_dft_val=dft_0(1'h0); [2:2]-hssi_rx_pcs_pma_interface_pma_if_dft_en=dft_dis(1'h0); [1:1]-hssi_common_pcs_pma_interface_pma_if_dft_val=dft_0(1'h0); [0:0]-hssi_common_pcs_pma_interface_pma_if_dft_en=dft_dis(1'h0); */
    0x010FF00, /* [25:16]-DPRIO address=0x010; [15:8]-bit mask=0xFF; [7:0]-hssi_common_pcs_pma_interface_pma_done_counter=0(8'h0); */
    0x011FF00, /* [25:16]-DPRIO address=0x011; [15:8]-bit mask=0xFF; [7:0]-hssi_common_pcs_pma_interface_pma_done_counter=0(8'h0); */
    0x012FF00, /* [25:16]-DPRIO address=0x012; [15:8]-bit mask=0xFF; [7:2]-hssi_common_pcs_pma_interface_phfifo_flush_wait=0(6'h0); [1:0]-hssi_common_pcs_pma_interface_pma_done_counter=0(2'h0); */
    0x013FF00, /* [25:16]-DPRIO address=0x013; [15:8]-bit mask=0xFF; [7:7]-hssi_common_pcs_pma_interface_ph_fifo_reg_mode=phfifo_reg_mode_dis(1'h0); [6:0]-hssi_common_pcs_pma_interface_pc_en_counter=0(7'h0); */
    0x0141F00, /* [25:16]-DPRIO address=0x014; [15:8]-bit mask=0x1F; [4:0]-hssi_common_pcs_pma_interface_pc_rst_counter=0(5'h0); */
    0x015F414, /* [25:16]-DPRIO address=0x015; [15:8]-bit mask=0xF4; [7:4]-hssi_common_pcs_pma_interface_testout_sel=asn_test(4'h1); [2:2]-hssi_common_pcs_pma_interface_bypass_send_syncp_fbkp=true(1'h1); */
    0x016FF00, /* [25:16]-DPRIO address=0x016; [15:8]-bit mask=0xFF; [7:0]-hssi_common_pcs_pma_interface_wait_send_syncp_fbkp=0(8'h0); */
    0x017F700, /* [25:16]-DPRIO address=0x017; [15:8]-bit mask=0xF7; [7:4]-hssi_common_pcs_pma_interface_wait_clk_on_off_timer=0(4'h0); [2:0]-hssi_common_pcs_pma_interface_wait_send_syncp_fbkp=0(3'h0); */
    0x018FF00, /* [25:16]-DPRIO address=0x018; [15:8]-bit mask=0xFF; [7:7]-hssi_common_pcs_pma_interface_free_run_clk_enable=false(1'h0); [6:6]-hssi_common_pcs_pma_interface_asn_clk_enable=false(1'h0); [5:5]-hssi_common_pcs_pma_interface_bypass_pma_sw_done=false(1'h0); [4:0]-hssi_common_pcs_pma_interface_wait_pipe_synchronizing=0(5'h0); */
    0x019FF17, /* [25:16]-DPRIO address=0x019; [15:8]-bit mask=0xFF; [7:7]-hssi_common_pcs_pma_interface_rxvalid_mask=rxvalid_mask_dis(1'h0); [6:6]-hssi_common_pcs_pma_interface_cid_enable=dis_cid_mode(1'h0); [5:5]-hssi_common_pcs_pma_interface_cdr_control=dis_cdr_ctrl(1'h0); [4:4]-hssi_common_pcs_pma_interface_bypass_pma_ltr=true(1'h1); [3:3]-hssi_common_pcs_pma_interface_bypass_ppm_lock=false(1'h0); [2:2]-hssi_common_pcs_pma_interface_bypass_txdetectrx=true(1'h1); [1:1]-hssi_common_pcs_pma_interface_bypass_early_eios=true(1'h1); [0:0]-hssi_common_pcs_pma_interface_bypass_pcie_switch=true(1'h1); */
    0x01AFF00, /* [25:16]-DPRIO address=0x01A; [15:8]-bit mask=0xFF; [7:0]-hssi_common_pcs_pma_interface_sigdet_wait_counter=0(8'h0); */
    0x01BFF00, /* [25:16]-DPRIO address=0x01B; [15:8]-bit mask=0xFF; [7:4]-hssi_common_pcs_pma_interface_dft_observation_clock_selection=dft_clk_obsrv_tx0(4'h0); [3:0]-hssi_common_pcs_pma_interface_sigdet_wait_counter=0(4'h0); */
    0x01CFF00, /* [25:16]-DPRIO address=0x01C; [15:8]-bit mask=0xFF; [7:0]-hssi_common_pcs_pma_interface_data_mask_count=0(8'h0); */
    0x01DFF00, /* [25:16]-DPRIO address=0x01D; [15:8]-bit mask=0xFF; [7:0]-hssi_common_pcs_pma_interface_data_mask_count=0(8'h0); */
    0x01EFF00, /* [25:16]-DPRIO address=0x01E; [15:8]-bit mask=0xFF; [7:7]-hssi_common_pcs_pma_interface_ignore_sigdet_g23=false(1'h0); [6:6]-hssi_common_pcs_pma_interface_spd_chg_rst_wait_cnt_en=false(1'h0); [5:3]-hssi_common_pcs_pma_interface_data_mask_count_multi=0(3'h0); [2:0]-hssi_common_pcs_pma_interface_sigdet_wait_counter_multi=0(3'h0); */
    0x01FFF00, /* [25:16]-DPRIO address=0x01F; [15:8]-bit mask=0xFF; [7:0]-hssi_common_pcs_pma_interface_early_eios_counter=0(8'h0); */
    0x0207E04, /* [25:16]-DPRIO address=0x020; [15:8]-bit mask=0x7E; [6:6]-hssi_tx_pld_pcs_interface_pcs_tx_delay2_clk_en=delay2_clk_disable(1'h0); [5:5]-hssi_tx_pld_pcs_interface_pcs_tx_delay1_clk_en=delay1_clk_disable(1'h0); [4:4]-hssi_tx_pld_pcs_interface_pcs_tx_delay1_data_sel=one_ff_delay(1'h0); [3:3]-hssi_tx_pld_pcs_interface_pcs_tx_output_sel=teng_output(1'h0); [2:2]-hssi_tx_pld_pcs_interface_pcs_tx_delay1_clk_sel=pcs_tx_clk(1'h1); [1:1]-hssi_tx_pld_pcs_interface_pcs_tx_data_source=hip_disable(1'h0); */
    0x021FF00, /* [25:16]-DPRIO address=0x021; [15:8]-bit mask=0xFF; [7:4]-hssi_tx_pld_pcs_interface_pcs_tx_delay2_ctrl=delay2_path0(4'h0); [3:0]-hssi_tx_pld_pcs_interface_pcs_tx_delay1_ctrl=delay1_path0(4'h0); */
    0x0220F05, /* [25:16]-DPRIO address=0x022; [15:8]-bit mask=0x0F; [3:2]-hssi_tx_pld_pcs_interface_pcs_tx_clk_source=teng(2'h1); [1:0]-hssi_tx_pld_pcs_interface_pcs_tx_clk_out_sel=teng_clk_out(2'h1); */
    0x024EF45, /* [25:16]-DPRIO address=0x024; [15:8]-bit mask=0xEF; [7:6]-hssi_rx_pld_pcs_interface_pcs_rx_clk_out_sel=teng_clk_out(2'h1); [5:5]-hssi_rx_pld_pcs_interface_pcs_rx_hip_clk_en=hip_rx_disable(1'h0); [3:3]-hssi_rx_pld_pcs_interface_pcs_rx_output_sel=teng_output(1'h0); [2:2]-hssi_rx_pld_pcs_interface_pcs_rx_clk_sel=pld_rx_clk(1'h1); [1:0]-hssi_rx_pld_pcs_interface_pcs_rx_block_sel=teng(2'h1); */
    0x028F704, /* [25:16]-DPRIO address=0x028; [15:8]-bit mask=0xF7; [7:5]-hssi_common_pld_pcs_interface_dft_clk_out_sel=teng_rx_dft_clk(3'h0); [4:4]-hssi_common_pld_pcs_interface_hrdrstctrl_en=hrst_dis(1'h0); [2:0]-hssi_common_pld_pcs_interface_pcs_testbus_block_sel=pma_if(3'h4); */
    0x0290100, /* [25:16]-DPRIO address=0x029; [15:8]-bit mask=0x01; [0:0]-hssi_common_pld_pcs_interface_dft_clk_out_en=dft_clk_out_disable(1'h0); */
    0x070FFD0, /* [25:16]-DPRIO address=0x070; [15:8]-bit mask=0xFF; [7:6]-hssi_10g_tx_pcs_txfifo_pfull=11(2'h3); [5:4]-hssi_10g_tx_pcs_wr_clk_sel=wr_tx_pld_clk(2'h1); [3:3]-hssi_10g_tx_pcs_scrm_bypass=scrm_bypass_dis(1'h0); [2:2]-hssi_10g_tx_pcs_tx_sm_bypass=tx_sm_bypass_dis(1'h0); [1:1]-hssi_10g_tx_pcs_enc_64b66b_txsm_bypass=enc_64b66b_txsm_bypass_dis(1'h0); [0:0]-hssi_10g_tx_pcs_fec_enable=fec_dis(1'h0); */
    0x0717B12, /* [25:16]-DPRIO address=0x071; [15:8]-bit mask=0x7B; [6:3]-hssi_10g_tx_pcs_txfifo_pempty=2(4'h2); [1:0]-hssi_10g_tx_pcs_txfifo_pfull=11(2'h2); */
    0x0793C00, /* [25:16]-DPRIO address=0x079; [15:8]-bit mask=0x3C; [5:2]-hssi_10g_tx_pcs_txfifo_empty=empty_default(4'h0); */
    0x07AFFFF, /* [25:16]-DPRIO address=0x07A; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_tx_pcs_pseudo_seed_b=288230376151711743(8'hFF); */
    0x07BFFFF, /* [25:16]-DPRIO address=0x07B; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_tx_pcs_pseudo_seed_b=288230376151711743(8'hFF); */
    0x07CFFFF, /* [25:16]-DPRIO address=0x07C; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_tx_pcs_pseudo_seed_b=288230376151711743(8'hFF); */
    0x07DFFFF, /* [25:16]-DPRIO address=0x07D; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_tx_pcs_pseudo_seed_b=288230376151711743(8'hFF); */
    0x07EFFFF, /* [25:16]-DPRIO address=0x07E; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_tx_pcs_pseudo_seed_b=288230376151711743(8'hFF); */
    0x07FFFFF, /* [25:16]-DPRIO address=0x07F; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_tx_pcs_pseudo_seed_b=288230376151711743(8'hFF); */
    0x080FFFF, /* [25:16]-DPRIO address=0x080; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_tx_pcs_pseudo_seed_b=288230376151711743(8'hFF); */
    0x0813F3F, /* [25:16]-DPRIO address=0x081; [15:8]-bit mask=0x3F; [5:2]-hssi_10g_tx_pcs_txfifo_full=full_default(4'hF); [1:0]-hssi_10g_tx_pcs_pseudo_seed_b=288230376151711743(2'h3); */
    0x0827B03, /* [25:16]-DPRIO address=0x082; [15:8]-bit mask=0x7B; [6:6]-hssi_10g_tx_pcs_sop_mark=sop_mark_dis(1'h0); [5:5]-hssi_10g_tx_pcs_random_disp=disable(1'h0); [4:4]-hssi_10g_tx_pcs_fifo_reg_fast=fifo_reg_fast_dis(1'h0); [3:3]-hssi_10g_tx_pcs_test_mode=test_off(1'h0); [1:1]-hssi_10g_tx_pcs_test_mode=test_off(1'h1); [0:0]-hssi_10g_tx_pcs_pseudo_random=all_0(1'h1); */
    0x084B784, /* [25:16]-DPRIO address=0x084; [15:8]-bit mask=0xB7; [7:7]-hssi_10g_tx_pcs_scrm_pipeln=enable(1'h1); [5:5]-hssi_10g_tx_pcs_frmgen_burst=frmgen_burst_dis(1'h0); [4:4]-hssi_10g_tx_pcs_frmgen_wordslip=frmgen_wordslip_dis(1'h0); [2:2]-hssi_10g_tx_pcs_tx_sm_pipeln=tx_sm_pipeln_en(1'h1); [1:1]-hssi_10g_tx_pcs_gb_pipeln_bypass=disable(1'h0); [0:0]-hssi_10g_tx_pcs_dispgen_pipeln=dispgen_pipeln_dis(1'h0); */
    0x0853B21, /* [25:16]-DPRIO address=0x085; [15:8]-bit mask=0x3B; [5:3]-hssi_10g_tx_pcs_txfifo_mode=phase_comp(3'h4); [1:1]-hssi_10g_tx_pcs_master_clk_sel=master_tx_pma_clk(1'h0); [0:0]-hssi_10g_tx_pcs_frmgen_pipeln=frmgen_pipeln_en(1'h1); */
    0x086FB31, /* [25:16]-DPRIO address=0x086; [15:8]-bit mask=0xFB; [7:7]-hssi_10g_tx_pcs_frmgen_clken=frmgen_clk_dis(1'h0); [6:6]-hssi_10g_tx_pcs_crcgen_clken=crcgen_clk_dis(1'h0); [5:5]-hssi_10g_tx_pcs_enc64b66b_txsm_clken=enc64b66b_txsm_clk_en(1'h1); [4:4]-hssi_10g_tx_pcs_scrm_clken=scrm_clk_en(1'h1); [3:3]-hssi_10g_tx_pcs_dispgen_clken=dispgen_clk_dis(1'h0); [1:1]-hssi_10g_tx_pcs_fec_clken=fec_clk_dis(1'h0); [0:0]-hssi_10g_tx_pcs_gbred_clken=gbred_clk_en(1'h1); */
    0x087E787, /* [25:16]-DPRIO address=0x087; [15:8]-bit mask=0xE7; [7:5]-hssi_10g_tx_pcs_phcomp_rd_del=phcomp_rd_del4(3'h4); [2:2]-hssi_10g_tx_pcs_ctrl_bit_reverse=ctrl_bit_reverse_en(1'h1); [1:1]-hssi_10g_tx_pcs_wrfifo_clken=wrfifo_clk_en(1'h1); [0:0]-hssi_10g_tx_pcs_rdfifo_clken=rdfifo_clk_en(1'h1); */
    0x088FFE0, /* [25:16]-DPRIO address=0x088; [15:8]-bit mask=0xFF; [7:7]-hssi_10g_tx_pcs_dispgen_bypass=dispgen_bypass_en(1'h1); [6:6]-hssi_10g_tx_pcs_crcgen_bypass=crcgen_bypass_en(1'h1); [5:5]-hssi_10g_tx_pcs_frmgen_bypass=frmgen_bypass_en(1'h1); [4:3]-hssi_10g_tx_pcs_gb_tx_odwidth=width_32(2'h0); [2:0]-hssi_10g_tx_pcs_gb_tx_idwidth=width_66(3'h0); */
    0x089FE10, /* [25:16]-DPRIO address=0x089; [15:8]-bit mask=0xFE; [7:7]-hssi_10g_tx_pcs_crcgen_err=crcgen_err_dis(1'h0); [6:6]-hssi_10g_tx_pcs_dispgen_err=dispgen_err_dis(1'h0); [5:5]-hssi_10g_tx_pcs_sh_err=sh_err_dis(1'h0); [4:4]-hssi_10g_tx_pcs_crcgen_inv=crcgen_inv_en(1'h1); [3:3]-hssi_10g_tx_pcs_scrm_mode=async(1'h0); [2:2]-hssi_10g_tx_pcs_frmgen_pyld_ins=frmgen_pyld_ins_dis(1'h0); [1:1]-hssi_10g_tx_pcs_data_bit_reverse=data_bit_reverse_dis(1'h0); */
    0x08AFF00, /* [25:16]-DPRIO address=0x08A; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_tx_pcs_frmgen_mfrm_length=2048(8'h0); */
    0x08BFF08, /* [25:16]-DPRIO address=0x08B; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_tx_pcs_frmgen_mfrm_length=2048(8'h8); */
    0x08C0F00, /* [25:16]-DPRIO address=0x08C; [15:8]-bit mask=0x0F; [3:0]-hssi_10g_tx_pcs_dft_clk_out_sel=tx_master_clk(4'h0); */
    0x08DF480, /* [25:16]-DPRIO address=0x08D; [15:8]-bit mask=0xF4; [7:6]-hssi_10g_tx_pcs_stretch_num_stages=two_stage(2'h2); [5:5]-hssi_10g_tx_pcs_fifo_double_write=fifo_double_write_dis(1'h0); [4:4]-hssi_10g_tx_pcs_bitslip_en=bitslip_dis(1'h0); [2:2]-hssi_10g_tx_pcs_fastpath=fastpath_dis(1'h0); */
    0x08FC000, /* [25:16]-DPRIO address=0x08F; [15:8]-bit mask=0xC0; [7:7]-hssi_10g_tx_pcs_bonding_dft_val=dft_0(1'h0); [6:6]-hssi_10g_tx_pcs_bonding_dft_en=dft_dis(1'h0); */
    0x090FEC8, /* [25:16]-DPRIO address=0x090; [15:8]-bit mask=0xFE; [7:5]-hssi_10g_tx_pcs_tx_testbus_sel=tx_fifo_testbus1(3'h6); [4:3]-hssi_10g_tx_pcs_tx_scrm_width=bit64(2'h1); [2:2]-hssi_10g_tx_pcs_tx_scrm_err=scrm_err_dis(1'h0); [1:1]-hssi_10g_tx_pcs_tx_sh_location=lsb(1'h0); */
    0x091FBC9, /* [25:16]-DPRIO address=0x091; [15:8]-bit mask=0xFB; [7:7]-hssi_10g_tx_pcs_full_flag_type=full_wr_side(1'h1); [6:6]-hssi_10g_tx_pcs_pfull_flag_type=pfull_wr_side(1'h1); [5:5]-hssi_10g_tx_pcs_pempty_flag_type=pempty_rd_side(1'h0); [4:4]-hssi_10g_tx_pcs_empty_flag_type=empty_rd_side(1'h0); [3:3]-hssi_10g_tx_pcs_fifo_stop_wr=n_wr_full(1'h1); [1:1]-hssi_10g_tx_pcs_fifo_stop_rd=rd_empty(1'h0); [0:0]-hssi_10g_tx_pcs_tx_testbus_sel=tx_fifo_testbus1(1'h1); */
    0x096EF80, /* [25:16]-DPRIO address=0x096; [15:8]-bit mask=0xEF; [7:7]-hssi_10g_rx_pcs_clr_errblk_cnt_en=enable(1'h1); [6:6]-hssi_10g_rx_pcs_blksync_bypass=blksync_bypass_dis(1'h0); [5:5]-hssi_10g_rx_pcs_bitslip_mode=bitslip_dis(1'h0); [3:3]-hssi_10g_rx_pcs_descrm_bypass=descrm_bypass_dis(1'h0); [2:2]-hssi_10g_rx_pcs_rx_sm_bypass=rx_sm_bypass_dis(1'h0); [1:1]-hssi_10g_rx_pcs_dec_64b66b_rxsm_bypass=dec_64b66b_rxsm_bypass_dis(1'h0); [0:0]-hssi_10g_rx_pcs_fec_enable=fec_dis(1'h0); */
    0x0970701, /* [25:16]-DPRIO address=0x097; [15:8]-bit mask=0x07; [2:2]-hssi_10g_rx_pcs_test_mode=test_off(1'h0); [1:0]-hssi_10g_rx_pcs_rd_clk_sel=rd_rx_pld_clk(2'h1); */
    0x098FF0F, /* [25:16]-DPRIO address=0x098; [15:8]-bit mask=0xFF; [7:7]-hssi_10g_rx_pcs_ber_bit_err_total_cnt=bit_err_total_cnt_10g(1'h0); [6:0]-hssi_10g_rx_pcs_blksync_enum_invalid_sh_cnt=enum_invalid_sh_cnt_10g(7'hF); */
    0x0993F08, /* [25:16]-DPRIO address=0x099; [15:8]-bit mask=0x3F; [5:0]-hssi_10g_rx_pcs_ber_bit_err_total_cnt=bit_err_total_cnt_10g(6'h8); */
    0x09AFF4A, /* [25:16]-DPRIO address=0x09A; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_rx_pcs_ber_xus_timer_window=19530(8'h4A); */
    0x09BFF4C, /* [25:16]-DPRIO address=0x09B; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_rx_pcs_ber_xus_timer_window=19530(8'h4C); */
    0x09CFFE0, /* [25:16]-DPRIO address=0x09C; [15:8]-bit mask=0xFF; [7:5]-hssi_10g_rx_pcs_blksync_knum_sh_cnt_postlock=knum_sh_cnt_postlock_10g(3'h7); [4:0]-hssi_10g_rx_pcs_ber_xus_timer_window=19530(5'h0); */
    0x09DFF07, /* [25:16]-DPRIO address=0x09D; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_rx_pcs_blksync_knum_sh_cnt_postlock=knum_sh_cnt_postlock_10g(8'h7); */
    0x09E7F3F, /* [25:16]-DPRIO address=0x09E; [15:8]-bit mask=0x7F; [6:0]-hssi_10g_rx_pcs_blksync_knum_sh_cnt_prelock=knum_sh_cnt_prelock_10g(7'h3F); */
    0x0A0FFE0, /* [25:16]-DPRIO address=0x0A0; [15:8]-bit mask=0xFF; [7:7]-hssi_10g_rx_pcs_dispchk_bypass=dispchk_bypass_en(1'h1); [6:6]-hssi_10g_rx_pcs_crcchk_bypass=crcchk_bypass_en(1'h1); [5:5]-hssi_10g_rx_pcs_frmsync_bypass=frmsync_bypass_en(1'h1); [4:3]-hssi_10g_rx_pcs_gb_rx_idwidth=width_32(2'h0); [2:0]-hssi_10g_rx_pcs_gb_rx_odwidth=width_66(3'h0); */
    0x0A2FFBB, /* [25:16]-DPRIO address=0x0A2; [15:8]-bit mask=0xFF; [7:7]-hssi_10g_rx_pcs_descrm_clken=descrm_clk_en(1'h1); [6:6]-hssi_10g_rx_pcs_frmsync_clken=frmsync_clk_dis(1'h0); [5:5]-hssi_10g_rx_pcs_dec64b66b_clken=dec64b66b_clk_en(1'h1); [4:4]-hssi_10g_rx_pcs_ber_clken=ber_clk_en(1'h1); [3:3]-hssi_10g_rx_pcs_rand_clken=rand_clk_en(1'h1); [2:2]-hssi_10g_rx_pcs_crcchk_clken=crcchk_clk_dis(1'h0); [1:1]-hssi_10g_rx_pcs_wrfifo_clken=wrfifo_clk_en(1'h1); [0:0]-hssi_10g_rx_pcs_rdfifo_clken=rdfifo_clk_en(1'h1); */
    0x0A30B0A, /* [25:16]-DPRIO address=0x0A3; [15:8]-bit mask=0x0B; [3:3]-hssi_10g_rx_pcs_gbexp_clken=gbexp_clk_en(1'h1); [1:1]-hssi_10g_rx_pcs_blksync_clken=blksync_clk_en(1'h1); [0:0]-hssi_10g_rx_pcs_fec_clken=fec_clk_dis(1'h0); */
    0x0A4FF8C, /* [25:16]-DPRIO address=0x0A4; [15:8]-bit mask=0xFF; [7:5]-hssi_10g_rx_pcs_frmsync_enum_sync=enum_sync_default(3'h4); [4:2]-hssi_10g_rx_pcs_frmsync_enum_scrm=enum_scrm_default(3'h3); [1:1]-hssi_10g_rx_pcs_force_align=force_align_dis(1'h0); [0:0]-hssi_10g_rx_pcs_align_del=align_del_dis(1'h0); */
    0x0A50704, /* [25:16]-DPRIO address=0x0A5; [15:8]-bit mask=0x07; [2:0]-hssi_10g_rx_pcs_frmsync_knum_sync=knum_sync_default(3'h4); */
    0x0A6FF00, /* [25:16]-DPRIO address=0x0A6; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_rx_pcs_control_del=control_del_none(8'h0); */
    0x0A71F17, /* [25:16]-DPRIO address=0x0A7; [15:8]-bit mask=0x1F; [4:0]-hssi_10g_rx_pcs_rxfifo_pfull=23(5'h17); */
    0x0A8FFE2, /* [25:16]-DPRIO address=0x0A8; [15:8]-bit mask=0xFF; [7:5]-hssi_10g_rx_pcs_rxfifo_full=full_default(3'h7); [4:0]-hssi_10g_rx_pcs_rxfifo_pempty=2(5'h2); */
    0x0A9FF03, /* [25:16]-DPRIO address=0x0A9; [15:8]-bit mask=0xFF; [7:7]-hssi_10g_rx_pcs_fast_path=fast_path_dis(1'h0); [6:2]-hssi_10g_rx_pcs_rxfifo_empty=empty_default(5'h0); [1:0]-hssi_10g_rx_pcs_rxfifo_full=full_default(2'h3); */
    0x0AADFDC, /* [25:16]-DPRIO address=0x0AA; [15:8]-bit mask=0xDF; [7:7]-hssi_10g_rx_pcs_descrm_pipeln=enable(1'h1); [6:6]-hssi_10g_rx_pcs_frmsync_pipeln=frmsync_pipeln_en(1'h1); [4:4]-hssi_10g_rx_pcs_rx_sm_pipeln=rx_sm_pipeln_en(1'h1); [3:3]-hssi_10g_rx_pcs_crcchk_pipeln=crcchk_pipeln_en(1'h1); [2:2]-hssi_10g_rx_pcs_crcflag_pipeln=crcflag_pipeln_en(1'h1); [1:0]-hssi_10g_rx_pcs_master_clk_sel=master_rx_pma_clk(2'h0); */
    0x0AB0300, /* [25:16]-DPRIO address=0x0AB; [15:8]-bit mask=0x03; [1:1]-hssi_10g_rx_pcs_dis_signal_ok=dis_signal_ok_en(1'h0); [0:0]-hssi_10g_rx_pcs_blksync_pipeln=blksync_pipeln_dis(1'h0); */
    0x0ACEF43, /* [25:16]-DPRIO address=0x0AC; [15:8]-bit mask=0xEF; [7:5]-hssi_10g_rx_pcs_rxfifo_mode=clk_comp_10g(3'h2); [3:3]-hssi_10g_rx_pcs_data_bit_reverse=data_bit_reverse_dis(1'h0); [2:2]-hssi_10g_rx_pcs_descrm_mode=async(1'h0); [1:1]-hssi_10g_rx_pcs_ctrl_bit_reverse=ctrl_bit_reverse_en(1'h1); [0:0]-hssi_10g_rx_pcs_test_mode=test_off(1'h1); */
    0x0ADFF2D, /* [25:16]-DPRIO address=0x0AD; [15:8]-bit mask=0xFF; [7:5]-hssi_10g_rx_pcs_blksync_bitslip_wait_cnt=1(3'h1); [4:4]-hssi_10g_rx_pcs_blksync_bitslip_type=bitslip_comb(1'h0); [3:3]-hssi_10g_rx_pcs_blksync_bitslip_wait_type=bitslip_cnt(1'h1); [2:2]-hssi_10g_rx_pcs_rx_sm_hiber=rx_sm_hiber_en(1'h1); [1:1]-hssi_10g_rx_pcs_frmsync_flag_type=location_only(1'h0); [0:0]-hssi_10g_rx_pcs_crcchk_inv=crcchk_inv_en(1'h1); */
    0x0AEFF00, /* [25:16]-DPRIO address=0x0AE; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_rx_pcs_frmsync_mfrm_length=2048(8'h0); */
    0x0AFFF08, /* [25:16]-DPRIO address=0x0AF; [15:8]-bit mask=0xFF; [7:0]-hssi_10g_rx_pcs_frmsync_mfrm_length=2048(8'h8); */
    0x0B0FB80, /* [25:16]-DPRIO address=0x0B0; [15:8]-bit mask=0xFB; [7:3]-hssi_10g_rx_pcs_rx_testbus_sel=rx_fifo_testbus1(5'h10); [1:1]-hssi_10g_rx_pcs_rx_sh_location=lsb(1'h0); [0:0]-hssi_10g_rx_pcs_rx_signal_ok_sel=synchronized_ver(1'h0); */
    0x0B15E4C, /* [25:16]-DPRIO address=0x0B1; [15:8]-bit mask=0x5E; [6:6]-hssi_10g_rx_pcs_rx_true_b2b=b2b(1'h1); [4:3]-hssi_10g_rx_pcs_rx_scrm_width=bit64(2'h1); [2:1]-hssi_10g_rx_pcs_stretch_num_stages=two_stage(2'h2); */
    0x0B2FF78, /* [25:16]-DPRIO address=0x0B2; [15:8]-bit mask=0xFF; [7:7]-hssi_10g_rx_pcs_fifo_double_read=fifo_double_read_dis(1'h0); [6:6]-hssi_10g_rx_pcs_fifo_stop_wr=n_wr_full(1'h1); [5:5]-hssi_10g_rx_pcs_fifo_stop_rd=n_rd_empty(1'h1); [4:4]-hssi_10g_rx_pcs_full_flag_type=full_wr_side(1'h1); [3:3]-hssi_10g_rx_pcs_pfull_flag_type=pfull_wr_side(1'h1); [2:2]-hssi_10g_rx_pcs_pempty_flag_type=pempty_rd_side(1'h0); [1:1]-hssi_10g_rx_pcs_empty_flag_type=empty_rd_side(1'h0); [0:0]-hssi_10g_rx_pcs_rx_fifo_write_ctrl=blklock_stops(1'h0); */
    0x0B37F02, /* [25:16]-DPRIO address=0x0B3; [15:8]-bit mask=0x7F; [6:3]-hssi_10g_rx_pcs_dft_clk_out_sel=rx_master_clk(4'h0); [2:0]-hssi_10g_rx_pcs_phcomp_rd_del=phcomp_rd_del2(3'h2); */
    0x0B80100, /* [25:16]-DPRIO address=0x0B8; [15:8]-bit mask=0x01; [0:0]-hssi_rx_pld_pcs_interface_hd_10g_test_bus_mode=rx(1'h0); */
    0x0BCDF10, /* [25:16]-DPRIO address=0x0BC; [15:8]-bit mask=0xDF; [7:7]-hssi_krfec_tx_pcs_enc_frame_query=enc_query_dis(1'h0); [6:6]-hssi_krfec_tx_pcs_transmit_order=transmit_lsb(1'h0); [4:4]-hssi_krfec_tx_pcs_ctrl_bit_reverse=ctrl_bit_reverse_en(1'h1); [3:3]-hssi_krfec_tx_pcs_data_bit_reverse=data_bit_reverse_dis(1'h0); [2:0]-hssi_krfec_tx_pcs_tx_testbus_sel=overall(3'h0); */
    0x0BDFF0C, /* [25:16]-DPRIO address=0x0BD; [15:8]-bit mask=0xFF; [7:4]-hssi_krfec_tx_pcs_burst_err_len=burst_err_len1(4'h0); [3:3]-hssi_krfec_tx_pcs_pipeln_encoder=enable(1'h1); [2:2]-hssi_krfec_tx_pcs_pipeln_scrambler=enable(1'h1); [1:1]-hssi_krfec_tx_pcs_burst_err=burst_err_dis(1'h0); [0:0]-hssi_krfec_tx_pcs_transcode_err=trans_err_dis(1'h0); */
    0x0BF7F20, /* [25:16]-DPRIO address=0x0BF; [15:8]-bit mask=0x7F; [6:6]-hssi_krfec_rx_pcs_pipeln_descrm=disable(1'h0); [5:5]-hssi_krfec_rx_pcs_pipeln_blksync=enable(1'h1); [4:0]-hssi_krfec_rx_pcs_rx_testbus_sel=overall(5'h0); */
    0x0C0F747, /* [25:16]-DPRIO address=0x0C0; [15:8]-bit mask=0xF7; [7:7]-hssi_krfec_rx_pcs_receive_order=receive_lsb(1'h0); [6:6]-hssi_krfec_rx_pcs_ctrl_bit_reverse=ctrl_bit_reverse_en(1'h1); [5:5]-hssi_krfec_rx_pcs_data_bit_reverse=data_bit_reverse_dis(1'h0); [4:4]-hssi_krfec_rx_pcs_blksync_cor_en=detect(1'h0); [2:2]-hssi_krfec_rx_pcs_dv_start=with_blklock(1'h1); [1:0]-hssi_krfec_rx_pcs_clr_ctrl=both_enabled(2'h3); */
    0x0C1FF08, /* [25:16]-DPRIO address=0x0C1; [15:8]-bit mask=0xFF; [7:0]-hssi_krfec_rx_pcs_parity_invalid_enum=8(8'h8); */
    0x0C2FF84, /* [25:16]-DPRIO address=0x0C2; [15:8]-bit mask=0xFF; [7:7]-hssi_krfec_rx_pcs_signal_ok_en=sig_ok_en(1'h1); [6:6]-hssi_krfec_rx_pcs_err_mark_type=err_mark_10g(1'h0); [5:5]-hssi_krfec_rx_pcs_error_marking_en=err_mark_dis(1'h0); [4:4]-hssi_krfec_rx_pcs_bypass_gb=bypass_dis(1'h0); [3:0]-hssi_krfec_rx_pcs_parity_valid_num=4(4'h4); */
    0x0C3FF45, /* [25:16]-DPRIO address=0x0C3; [15:8]-bit mask=0xFF; [7:7]-hssi_krfec_rx_pcs_pipeln_trans_dec=disable(1'h0); [6:6]-hssi_krfec_rx_pcs_pipeln_gearbox=enable(1'h1); [5:5]-hssi_krfec_rx_pcs_pipeln_errcorrect=disable(1'h0); [4:4]-hssi_krfec_rx_pcs_pipeln_errtrap_pat=disable(1'h0); [3:3]-hssi_krfec_rx_pcs_pipeln_errtrap_loc=disable(1'h0); [2:2]-hssi_krfec_rx_pcs_pipeln_errtrap_ind=enable(1'h1); [1:1]-hssi_krfec_rx_pcs_pipeln_errtrap_lfsr=disable(1'h0); [0:0]-hssi_krfec_rx_pcs_pipeln_syndrm=enable(1'h1); */
    0x0C40101, /* [25:16]-DPRIO address=0x0C4; [15:8]-bit mask=0x01; [0:0]-hssi_rx_pld_pcs_interface_hd_krfec_test_bus_mode=tx(1'h1); */
    0x0C50301, /* [25:16]-DPRIO address=0x0C5; [15:8]-bit mask=0x03; [1:1]-hssi_fifo_tx_pcs_double_write_mode=double_write_dis(1'h0); [0:0]-hssi_fifo_tx_pcs_prot_mode=teng_mode(1'h1); */
    0x0C70301, /* [25:16]-DPRIO address=0x0C7; [15:8]-bit mask=0x03; [1:1]-hssi_fifo_rx_pcs_double_read_mode=double_read_dis(1'h0); [0:0]-hssi_fifo_rx_pcs_prot_mode=teng_mode(1'h1); */
    0x1058000, /* [25:16]-DPRIO address=0x105; [15:8]-bit mask=0x80; [7:7]-pma_tx_buf_user_fir_coeff_ctrl_sel=ram_ctl(1'h0); */
    0x10D7E00, /* [25:16]-DPRIO address=0x10D; [15:8]-bit mask=0x7E; [6:3]-pma_tx_buf_rx_det=mode_0(4'h0); [2:2]-pma_tx_buf_rx_det_pdb=rx_det_off(1'h0); [1:1]-pma_tx_buf_rx_det_output_sel=rx_det_pcie_out(1'h0); */
    0x1103F1A, /* [25:16]-DPRIO address=0x110; [15:8]-bit mask=0x3F; [5:3]-pma_tx_ser_ser_clk_divtx_user_sel=divtx_user_2(3'h3); [2:0]-pma_cgb_ser_mode=thirty_two_bit(3'h2); */
    0x1120400, /* [25:16]-DPRIO address=0x112; [15:8]-bit mask=0x04; [2:2]-pma_cgb_bitslip_enable=disable_bitslip(1'h0); */
    0x1190F00, /* [25:16]-DPRIO address=0x119; [15:8]-bit mask=0x0F; [3:2]-pma_cgb_x1_div_m_sel=divbypass(2'h0); [1:1]-pma_rx_deser_pcie_gen_bitwidth=pcie_gen3_32b(1'h0); [0:0]-pma_rx_deser_pcie_gen=non_pcie(1'h0); */
    0x11B0200, /* [25:16]-DPRIO address=0x11B; [15:8]-bit mask=0x02; [1:1]-pma_rx_buf_qpi_enable=non_qpi_mode(1'h0); */
    0x11D0700, /* [25:16]-DPRIO address=0x11D; [15:8]-bit mask=0x07; [2:2]-pma_rx_buf_rx_refclk_divider=bypass_divider(1'h0); [1:1]-pma_rx_buf_refclk_en=disable(1'h0); [0:0]-cdr_pll_loopback_mode=loopback_disabled(1'h0); */
    0x11F0100, /* [25:16]-DPRIO address=0x11F; [15:8]-bit mask=0x01; [0:0]-pma_rx_buf_bypass_eqz_stages_234=bypass_off(1'h0); */
    0x1230F01, /* [25:16]-DPRIO address=0x123; [15:8]-bit mask=0x0F; [3:3]-pma_rx_dfe_pdb_fxtap4t7=fxtap4t7_powerdown(1'h0); [2:2]-pma_rx_dfe_pdb_floattap=floattap_dfe_powerdown(1'h0); [1:1]-pma_rx_dfe_pdb_fixedtap=fixtap_dfe_powerdown(1'h0); [0:0]-pma_rx_dfe_pdb=dfe_enable(1'h1); */
    0x1242000, /* [25:16]-DPRIO address=0x124; [15:8]-bit mask=0x20; [5:5]-pma_rx_dfe_dft_en=dft_disable(1'h0); */
    0x132F7B2, /* [25:16]-DPRIO address=0x132; [15:8]-bit mask=0xF7; [7:6]-cdr_pll_set_cdr_vco_speed_pciegen3=cdr_vco_max_speedbin_pciegen3(2'h2); [5:4]-cdr_pll_reverse_serial_loopback=no_loopback(2'h3); [2:2]-cdr_pll_set_cdr_vco_speed_fix=60(1'h0); [1:1]-cdr_pll_cdr_powerdown_mode=power_up(1'h1); [0:0]-cdr_pll_set_cdr_vco_speed_fix=60(1'h0); */
    0x133E360, /* [25:16]-DPRIO address=0x133; [15:8]-bit mask=0xE3; [7:5]-cdr_pll_chgpmp_current_up_pd=cp_current_pd_up_setting3(3'h3); [1:1]-cdr_pll_cdr_phaselock_mode=no_ignore_lock(1'h0); [0:0]-cdr_pll_gpon_lck2ref_control=gpon_lck2ref_off(1'h0); */
    0x134F7C2, /* [25:16]-DPRIO address=0x134; [15:8]-bit mask=0xF7; [7:7]-cdr_pll_txpll_hclk_driver_enable=false(1'h1); [6:6]-cdr_pll_set_cdr_vco_speed_fix=60(1'h1); [5:4]-cdr_pll_bbpd_data_pattern_filter_select=bbpd_data_pat_off(2'h0); [2:0]-cdr_pll_lck2ref_delay_control=lck2ref_delay_2(3'h2); */
    0x135FF4A, /* [25:16]-DPRIO address=0x135; [15:8]-bit mask=0xFF; [7:7]-cdr_pll_txpll_hclk_driver_enable=false(1'h0); [6:6]-cdr_pll_set_cdr_vco_speed_fix=60(1'h1); [5:5]-cdr_pll_chgpmp_current_up_trim=cp_current_trimming_up_setting0(1'h0); [4:4]-cdr_pll_lf_ripple_cap=lf_no_ripple(1'h0); [3:2]-cdr_pll_lf_resistor_pd=lf_pd_setting2(2'h2); [1:0]-cdr_pll_lf_resistor_pfd=lf_pfd_setting2(2'h2); */
    0x136FF0C, /* [25:16]-DPRIO address=0x136; [15:8]-bit mask=0xFF; [7:6]-cdr_pll_vco_underrange_voltage=vco_underange_off(2'h0); [5:4]-cdr_pll_vco_overrange_voltage=vco_overrange_off(2'h0); [3:0]-cdr_pll_set_cdr_vco_speed_fix=60(4'hC); */
    0x137FF0F, /* [25:16]-DPRIO address=0x137; [15:8]-bit mask=0xFF; [7:7]-cdr_pll_diag_loopback_enable=false(1'h0); [6:2]-cdr_pll_set_cdr_vco_speed=3(5'h3); [1:1]-cdr_pll_set_cdr_v2i_enable=true(1'h1); [0:0]-cdr_pll_set_cdr_vco_reset=false(1'h1); */
    0x138FF82, /* [25:16]-DPRIO address=0x138; [15:8]-bit mask=0xFF; [7:7]-cdr_pll_fb_select=direct_fb(1'h1); [6:6]-cdr_pll_cdr_odi_select=sel_cdr(1'h0); [5:5]-cdr_pll_auto_reset_on=auto_reset_off(1'h0); [4:0]-cdr_pll_set_cdr_vco_speed_pciegen3=cdr_vco_max_speedbin_pciegen3(5'h2); */
    0x139FF1A, /* [25:16]-DPRIO address=0x139; [15:8]-bit mask=0xFF; [7:7]-cdr_pll_pd_fastlock_mode=false(1'h0); [6:6]-cdr_pll_chgpmp_replicate=false(1'h0); [5:3]-cdr_pll_chgpmp_current_dn_pd=cp_current_pd_dn_setting3(3'h3); [2:0]-cdr_pll_chgpmp_current_pfd=cp_current_pfd_setting2(3'h2); */
    0x13AFF4A, /* [25:16]-DPRIO address=0x13A; [15:8]-bit mask=0xFF; [7:6]-cdr_pll_fref_clklow_div=2(2'h1); [5:3]-cdr_pll_pd_l_counter=1(3'h1); [2:0]-cdr_pll_pfd_l_counter=1(3'h2); */
    0x13BFF10, /* [25:16]-DPRIO address=0x13B; [15:8]-bit mask=0xFF; [7:0]-cdr_pll_m_counter=16(8'h10); */
    0x13CFD75, /* [25:16]-DPRIO address=0x13C; [15:8]-bit mask=0xFD; [7:7]-cdr_pll_reverse_serial_loopback=no_loopback(1'h0); [6:4]-cdr_pll_set_cdr_vco_speed_pciegen3=cdr_vco_max_speedbin_pciegen3(3'h7); [3:2]-cdr_pll_n_counter=2(2'h1); [0:0]-pma_rx_deser_rst_n_adapt_odi=no_rst_adapt_odi(1'h1); */
    0x13DFF00, /* [25:16]-DPRIO address=0x13D; [15:8]-bit mask=0xFF; [7:6]-cdr_pll_atb_select_control=atb_off(2'h0); [5:3]-cdr_pll_fref_mux_select=fref_mux_cdr_refclk(3'h0); [2:0]-cdr_pll_clklow_mux_select=clklow_mux_cdr_fbclk(3'h0); */
    0x13E7F00, /* [25:16]-DPRIO address=0x13E; [15:8]-bit mask=0x7F; [6:3]-cdr_pll_atb_select_control=atb_off(4'h0); [2:0]-cdr_pll_chgpmp_testmode=cp_test_disable(3'h0); */
    0x13F7F06, /* [25:16]-DPRIO address=0x13F; [15:8]-bit mask=0x7F; [6:6]-pma_rx_deser_sdclk_enable=false(1'h0); [5:4]-pma_rx_deser_clkdiv_source=vco_bypass_normal(2'h0); [3:0]-pma_rx_deser_deser_factor=32(4'h6); */
    0x140C703, /* [25:16]-DPRIO address=0x140; [15:8]-bit mask=0xC7; [7:6]-pma_rx_deser_force_clkdiv_for_testing=normal_clkdiv(2'h0); [2:0]-pma_rx_deser_clkdivrx_user_mode=clkdivrx_user_clkdiv_div2(3'h3); */
    0x1421F0F, /* [25:16]-DPRIO address=0x142; [15:8]-bit mask=0x1F; [4:4]-cdr_pll_loopback_mode=loopback_disabled(1'h0); [3:1]-cdr_pll_loop_filter_bias_select=lpflt_bias_7(3'h7); [0:0]-pma_rx_deser_bitslip_bypass=bs_bypass_yes(1'h1); */
    0x1445800, /* [25:16]-DPRIO address=0x144; [15:8]-bit mask=0x58; [6:6]-pma_rx_odi_step_ctrl_sel=dprio_mode(1'h0); [4:4]-pma_rx_odi_step_ctrl_sel=dprio_mode(1'h0); [3:3]-cdr_pll_cal_vco_count_length=sel_8b_count(1'h0); */
    0x1481F00, /* [25:16]-DPRIO address=0x148; [15:8]-bit mask=0x1F; [4:4]-pma_adapt_adp_ctle_en=radp_ctle_disable(1'h0); [3:3]-pma_adapt_adp_vga_en=radp_vga_disable(1'h0); [2:2]-pma_adapt_adp_vref_en=radp_vref_disable(1'h0); [1:1]-pma_adapt_adp_dfe_fltap_en=radp_dfe_fltap_disable(1'h0); [0:0]-pma_adapt_adp_dfe_fxtap_en=radp_dfe_fxtap_disable(1'h0); */
    0x1490F08, /* [25:16]-DPRIO address=0x149; [15:8]-bit mask=0x0F; [3:0]-pma_adapt_adp_mode=radp_mode_8(4'h8); */
    0x14B8000, /* [25:16]-DPRIO address=0x14B; [15:8]-bit mask=0x80; [7:7]-pma_adapt_adp_onetime_dfe=radp_onetime_dfe_0(1'h0); */
    0x14D0704, /* [25:16]-DPRIO address=0x14D; [15:8]-bit mask=0x07; [2:0]-pma_adapt_adp_dfe_mode=radp_dfe_mode_4(3'h4); */
    0x14F8000, /* [25:16]-DPRIO address=0x14F; [15:8]-bit mask=0x80; [7:7]-cdr_pll_set_cdr_input_freq_range=0(1'h0); */
    0x1528000, /* [25:16]-DPRIO address=0x152; [15:8]-bit mask=0x80; [7:7]-cdr_pll_set_cdr_input_freq_range=0(1'h0); */
    0x1538000, /* [25:16]-DPRIO address=0x153; [15:8]-bit mask=0x80; [7:7]-cdr_pll_set_cdr_input_freq_range=0(1'h0); */
    0x154C000, /* [25:16]-DPRIO address=0x154; [15:8]-bit mask=0xC0; [7:6]-cdr_pll_set_cdr_input_freq_range=0(2'h0); */
    0x155C000, /* [25:16]-DPRIO address=0x155; [15:8]-bit mask=0xC0; [7:6]-cdr_pll_set_cdr_input_freq_range=0(2'h0); */
    0x1564000, /* [25:16]-DPRIO address=0x156; [15:8]-bit mask=0x40; [6:6]-cdr_pll_set_cdr_input_freq_range=0(1'h0); */
    0x15B1505, /* [25:16]-DPRIO address=0x15B; [15:8]-bit mask=0x15; [4:4]-pma_adapt_adp_dfe_fxtap_hold_en=radp_dfe_fxtap_not_held(1'h0); [2:2]-pma_adapt_adp_dfe_fltap_bypass=radp_dfe_fltap_bypass_1(1'h1); [0:0]-pma_adapt_adp_dfe_fxtap_bypass=radp_dfe_fxtap_bypass_1(1'h1); */
    0x15E0101, /* [25:16]-DPRIO address=0x15E; [15:8]-bit mask=0x01; [0:0]-pma_adapt_adp_vref_bypass=radp_vref_bypass_1(1'h1); */
    0x1600101, /* [25:16]-DPRIO address=0x160; [15:8]-bit mask=0x01; [0:0]-pma_adapt_adp_vga_bypass=radp_vga_bypass_1(1'h1); */
    0x163E0E0, /* [25:16]-DPRIO address=0x163; [15:8]-bit mask=0xE0; [7:5]-pma_adapt_adp_ctle_adapt_cycle_window=radp_ctle_adapt_cycle_window_7(3'h7); */
    0x1660101, /* [25:16]-DPRIO address=0x166; [15:8]-bit mask=0x01; [0:0]-pma_adapt_adp_1s_ctle_bypass=radp_1s_ctle_bypass_1(1'h1); */
    0x1670101, /* [25:16]-DPRIO address=0x167; [15:8]-bit mask=0x01; [0:0]-pma_adapt_adp_4s_ctle_bypass=radp_4s_ctle_bypass_1(1'h1); */
    0x1680400, /* [25:16]-DPRIO address=0x168; [15:8]-bit mask=0x04; [2:2]-pma_adapt_odi_dfe_spec_en=rodi_dfe_spec_en_0(1'h0); */
    0x16FC000, /* [25:16]-DPRIO address=0x16F; [15:8]-bit mask=0xC0; [7:7]-cdr_pll_chgpmp_up_pd_trim_double=normal_up_trim_current(1'h0); [6:6]-cdr_pll_chgpmp_dn_pd_trim_double=normal_dn_trim_current(1'h0); */
    0x170FF01, /* [25:16]-DPRIO address=0x170; [15:8]-bit mask=0xFF; [7:4]-cdr_pll_chgpmp_current_dn_trim=cp_current_trimming_dn_setting0(4'h0); [3:1]-cdr_pll_chgpmp_current_up_trim=cp_current_trimming_up_setting0(3'h0); [0:0]-pma_rx_deser_pcie_gen=non_pcie(1'h1); */
    0x1710100, /* [25:16]-DPRIO address=0x171; [15:8]-bit mask=0x01; [0:0]-pma_rx_buf_pm_tx_rx_cvp_mode=cvp_off(1'h0); */
    0x1721000, /* [25:16]-DPRIO address=0x172; [15:8]-bit mask=0x10; [4:4]-cdr_pll_set_cdr_vco_speed_pciegen3=cdr_vco_max_speedbin_pciegen3(1'h0); */
    0x173FF31, /* [25:16]-DPRIO address=0x173; [15:8]-bit mask=0xFF; [7:4]-pma_rx_sd_sd_output_off=1(4'h3); [3:0]-pma_rx_sd_sd_output_on=15(4'h1); */
    0x1741F0C, /* [25:16]-DPRIO address=0x174; [15:8]-bit mask=0x1F; [4:0]-pma_rx_sd_sd_output_off=1(5'hC); */
    0x175F090  /* [25:16]-DPRIO address=0x175; [15:8]-bit mask=0xF0; [7:6]-cdr_pll_set_cdr_vco_speed_pciegen3=cdr_vco_max_speedbin_pciegen3(2'h2); [5:5]-pma_rx_sd_sd_pdb=sd_off(1'h0); [4:4]-pma_rx_sd_sd_output_on=15(1'h1); */
};
#endif

#define ALTERA_XCVR_NATIVE_A10_PLL_SELECT_VALUE 0

#define ALTERA_XCVR_NATIVE_A10_CDR_REFCLK_SELECT_VALUE 0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BLKSYNC_COR_EN_VALUE "detect"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BLKSYNC_COR_EN_ADDR_OFST 192
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BLKSYNC_COR_EN_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BLKSYNC_COR_EN_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BLKSYNC_COR_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BLKSYNC_COR_EN_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BLKSYNC_COR_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BLKSYNC_COR_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BYPASS_GB_VALUE "bypass_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BYPASS_GB_ADDR_OFST 194
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BYPASS_GB_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BYPASS_GB_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BYPASS_GB_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BYPASS_GB_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BYPASS_GB_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_BYPASS_GB_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CLR_CTRL_VALUE "both_enabled"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CLR_CTRL_ADDR_OFST 192
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CLR_CTRL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CLR_CTRL_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CLR_CTRL_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CLR_CTRL_ADDR_FIELD_BITMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CLR_CTRL_ADDR_FIELD_VALMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CLR_CTRL_ADDR_FIELD_VALUE 0x3

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CTRL_BIT_REVERSE_VALUE "ctrl_bit_reverse_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CTRL_BIT_REVERSE_ADDR_OFST 192
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DATA_BIT_REVERSE_VALUE "data_bit_reverse_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DATA_BIT_REVERSE_ADDR_OFST 192
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DV_START_VALUE "with_blklock"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DV_START_ADDR_OFST 192
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DV_START_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DV_START_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DV_START_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DV_START_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DV_START_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_DV_START_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERR_MARK_TYPE_VALUE "err_mark_10g"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERR_MARK_TYPE_ADDR_OFST 194
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERR_MARK_TYPE_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERR_MARK_TYPE_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERR_MARK_TYPE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERR_MARK_TYPE_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERR_MARK_TYPE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERR_MARK_TYPE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERROR_MARKING_EN_VALUE "err_mark_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERROR_MARKING_EN_ADDR_OFST 194
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERROR_MARKING_EN_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERROR_MARKING_EN_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERROR_MARKING_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERROR_MARKING_EN_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERROR_MARKING_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_ERROR_MARKING_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_LOW_LATENCY_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_LPBK_MODE_VALUE "lpbk_dis"

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_INVALID_ENUM_VALUE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_INVALID_ENUM_ADDR_OFST 193
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_INVALID_ENUM_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_INVALID_ENUM_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_INVALID_ENUM_ADDR_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_INVALID_ENUM_ADDR_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_INVALID_ENUM_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_INVALID_ENUM_ADDR_FIELD_VALUE 0x8

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_VALID_NUM_VALUE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_VALID_NUM_ADDR_OFST 194
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_VALID_NUM_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_VALID_NUM_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_VALID_NUM_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_VALID_NUM_ADDR_FIELD_BITMASK 0x0000000F
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_VALID_NUM_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PARITY_VALID_NUM_ADDR_FIELD_VALUE 0x4

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_BLKSYNC_VALUE "enable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_BLKSYNC_ADDR_OFST 191
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_BLKSYNC_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_BLKSYNC_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_BLKSYNC_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_BLKSYNC_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_BLKSYNC_ADDR_FIELD_VALMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_BLKSYNC_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_DESCRM_VALUE "disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_DESCRM_ADDR_OFST 191
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_DESCRM_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_DESCRM_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_DESCRM_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_DESCRM_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_DESCRM_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_DESCRM_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRCORRECT_VALUE "disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRCORRECT_ADDR_OFST 195
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRCORRECT_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRCORRECT_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRCORRECT_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRCORRECT_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRCORRECT_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRCORRECT_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_IND_VALUE "enable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_IND_ADDR_OFST 195
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_IND_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_IND_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_IND_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_IND_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_IND_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_IND_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LFSR_VALUE "disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LFSR_ADDR_OFST 195
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LFSR_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LFSR_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LFSR_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LFSR_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LFSR_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LFSR_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LOC_VALUE "disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LOC_ADDR_OFST 195
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LOC_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LOC_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LOC_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LOC_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LOC_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_LOC_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_PAT_VALUE "disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_PAT_ADDR_OFST 195
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_PAT_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_PAT_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_PAT_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_PAT_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_PAT_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_ERRTRAP_PAT_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_GEARBOX_VALUE "enable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_GEARBOX_ADDR_OFST 195
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_GEARBOX_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_GEARBOX_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_GEARBOX_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_GEARBOX_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_GEARBOX_ADDR_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_GEARBOX_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_SYNDRM_VALUE "enable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_SYNDRM_ADDR_OFST 195
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_SYNDRM_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_SYNDRM_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_SYNDRM_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_SYNDRM_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_SYNDRM_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_SYNDRM_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_TRANS_DEC_VALUE "disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_TRANS_DEC_ADDR_OFST 195
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_TRANS_DEC_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_TRANS_DEC_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_TRANS_DEC_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_TRANS_DEC_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_TRANS_DEC_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PIPELN_TRANS_DEC_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_PROT_MODE_VALUE "disable_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RECEIVE_ORDER_VALUE "receive_lsb"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RECEIVE_ORDER_ADDR_OFST 192
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RECEIVE_ORDER_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RECEIVE_ORDER_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RECEIVE_ORDER_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RECEIVE_ORDER_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RECEIVE_ORDER_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RECEIVE_ORDER_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RX_TESTBUS_SEL_VALUE "overall"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RX_TESTBUS_SEL_ADDR_OFST 191
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RX_TESTBUS_SEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RX_TESTBUS_SEL_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RX_TESTBUS_SEL_ADDR_FIELD_SIZE 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RX_TESTBUS_SEL_ADDR_FIELD_BITMASK 0x0000001F
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RX_TESTBUS_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RX_TESTBUS_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_SIGNAL_OK_EN_VALUE "sig_ok_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_SIGNAL_OK_EN_ADDR_OFST 194
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_SIGNAL_OK_EN_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_SIGNAL_OK_EN_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_SIGNAL_OK_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_SIGNAL_OK_EN_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_SIGNAL_OK_EN_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_SIGNAL_OK_EN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_RX_PCS_RECONFIG_SETTINGS_VALUE "{}"

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_VALUE "burst_err_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_ADDR_OFST 189
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_LEN_VALUE "burst_err_len1"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_LEN_ADDR_OFST 189
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_LEN_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_LEN_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_LEN_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_LEN_ADDR_FIELD_BITMASK 0x000000F0
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_LEN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_BURST_ERR_LEN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_CTRL_BIT_REVERSE_VALUE "ctrl_bit_reverse_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_CTRL_BIT_REVERSE_ADDR_OFST 188
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_VALMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_DATA_BIT_REVERSE_VALUE "data_bit_reverse_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_DATA_BIT_REVERSE_ADDR_OFST 188
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_ENC_FRAME_QUERY_VALUE "enc_query_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_ENC_FRAME_QUERY_ADDR_OFST 188
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_ENC_FRAME_QUERY_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_ENC_FRAME_QUERY_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_ENC_FRAME_QUERY_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_ENC_FRAME_QUERY_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_ENC_FRAME_QUERY_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_ENC_FRAME_QUERY_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_LOW_LATENCY_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_ENCODER_VALUE "enable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_ENCODER_ADDR_OFST 189
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_ENCODER_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_ENCODER_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_ENCODER_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_ENCODER_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_ENCODER_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_ENCODER_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_SCRAMBLER_VALUE "enable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_SCRAMBLER_ADDR_OFST 189
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_SCRAMBLER_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_SCRAMBLER_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_SCRAMBLER_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_SCRAMBLER_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_SCRAMBLER_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PIPELN_SCRAMBLER_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_PROT_MODE_VALUE "disable_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSCODE_ERR_VALUE "trans_err_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSCODE_ERR_ADDR_OFST 189
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSCODE_ERR_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSCODE_ERR_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSCODE_ERR_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSCODE_ERR_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSCODE_ERR_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSCODE_ERR_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSMIT_ORDER_VALUE "transmit_lsb"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSMIT_ORDER_ADDR_OFST 188
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSMIT_ORDER_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSMIT_ORDER_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSMIT_ORDER_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSMIT_ORDER_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSMIT_ORDER_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TRANSMIT_ORDER_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TX_TESTBUS_SEL_VALUE "overall"
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TX_TESTBUS_SEL_ADDR_OFST 188
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TX_TESTBUS_SEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TX_TESTBUS_SEL_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TX_TESTBUS_SEL_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TX_TESTBUS_SEL_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TX_TESTBUS_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_KRFEC_TX_PCS_TX_TESTBUS_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_ALIGN_DEL_VALUE "align_del_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_ALIGN_DEL_ADDR_OFST 164
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_ALIGN_DEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_ALIGN_DEL_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_ALIGN_DEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_ALIGN_DEL_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_ALIGN_DEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_ALIGN_DEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_VALUE "bit_err_total_cnt_10g"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR0_OFST 152
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR0_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR0_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR0_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR1_OFST 153
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR1_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR1_FIELD_SIZE 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR1_FIELD_BITMASK 0x0000003F
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR1_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_BIT_ERR_TOTAL_CNT_ADDR1_FIELD_VALUE 0x8

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_CLKEN_VALUE "ber_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_CLKEN_ADDR_OFST 162
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_CLKEN_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_CLKEN_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_CLKEN_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_CLKEN_ADDR_FIELD_VALMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_VALUE 19530
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR0_OFST 154
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR0_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR0_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR0_FIELD_VALMASK 0x0000004A
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR0_FIELD_VALUE 0x4A
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR1_OFST 155
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR1_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR1_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR1_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR1_FIELD_VALMASK 0x0000004C
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR1_FIELD_VALUE 0x4C
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR2_OFST 156
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR2_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR2_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR2_FIELD_SIZE 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR2_FIELD_BITMASK 0x0000001F
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR2_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BER_XUS_TIMER_WINDOW_ADDR2_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BITSLIP_MODE_VALUE "bitslip_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BITSLIP_MODE_ADDR_OFST 150
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BITSLIP_MODE_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BITSLIP_MODE_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BITSLIP_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BITSLIP_MODE_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BITSLIP_MODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BITSLIP_MODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_TYPE_VALUE "bitslip_comb"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_TYPE_ADDR_OFST 173
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_TYPE_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_TYPE_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_TYPE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_TYPE_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_TYPE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_TYPE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_CNT_VALUE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_CNT_ADDR_OFST 173
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_CNT_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_CNT_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_CNT_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_CNT_ADDR_FIELD_BITMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_CNT_ADDR_FIELD_VALMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_CNT_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_TYPE_VALUE "bitslip_cnt"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_TYPE_ADDR_OFST 173
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_TYPE_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_TYPE_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_TYPE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_TYPE_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_TYPE_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BITSLIP_WAIT_TYPE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BYPASS_VALUE "blksync_bypass_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BYPASS_ADDR_OFST 150
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BYPASS_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BYPASS_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BYPASS_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BYPASS_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_BYPASS_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_CLKEN_VALUE "blksync_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_CLKEN_ADDR_OFST 163
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_CLKEN_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_CLKEN_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_CLKEN_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_CLKEN_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_ENUM_INVALID_SH_CNT_VALUE "enum_invalid_sh_cnt_10g"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_ENUM_INVALID_SH_CNT_ADDR_OFST 152
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_ENUM_INVALID_SH_CNT_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_ENUM_INVALID_SH_CNT_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_ENUM_INVALID_SH_CNT_ADDR_FIELD_SIZE 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_ENUM_INVALID_SH_CNT_ADDR_FIELD_BITMASK 0x0000007F
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_ENUM_INVALID_SH_CNT_ADDR_FIELD_VALMASK 0x0000000F
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_ENUM_INVALID_SH_CNT_ADDR_FIELD_VALUE 0xF

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_VALUE "knum_sh_cnt_postlock_10g"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR0_OFST 156
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR0_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR0_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR0_FIELD_BITMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR0_FIELD_VALMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR0_FIELD_VALUE 0x7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR1_OFST 157
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR1_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR1_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR1_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR1_FIELD_VALMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_POSTLOCK_ADDR1_FIELD_VALUE 0x7

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_PRELOCK_VALUE "knum_sh_cnt_prelock_10g"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_PRELOCK_ADDR_OFST 158
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_PRELOCK_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_PRELOCK_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_PRELOCK_ADDR_FIELD_SIZE 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_PRELOCK_ADDR_FIELD_BITMASK 0x0000007F
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_PRELOCK_ADDR_FIELD_VALMASK 0x0000003F
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_KNUM_SH_CNT_PRELOCK_ADDR_FIELD_VALUE 0x3F

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_PIPELN_VALUE "blksync_pipeln_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_PIPELN_ADDR_OFST 171
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_PIPELN_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_PIPELN_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_PIPELN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_PIPELN_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_PIPELN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_BLKSYNC_PIPELN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CLR_ERRBLK_CNT_EN_VALUE "enable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CLR_ERRBLK_CNT_EN_ADDR_OFST 150
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CLR_ERRBLK_CNT_EN_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CLR_ERRBLK_CNT_EN_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CLR_ERRBLK_CNT_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CLR_ERRBLK_CNT_EN_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CLR_ERRBLK_CNT_EN_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CLR_ERRBLK_CNT_EN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CONTROL_DEL_VALUE "control_del_none"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CONTROL_DEL_ADDR_OFST 166
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CONTROL_DEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CONTROL_DEL_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CONTROL_DEL_ADDR_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CONTROL_DEL_ADDR_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CONTROL_DEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CONTROL_DEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_BYPASS_VALUE "crcchk_bypass_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_BYPASS_ADDR_OFST 160
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_BYPASS_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_BYPASS_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_BYPASS_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_BYPASS_ADDR_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_CLKEN_VALUE "crcchk_clk_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_CLKEN_ADDR_OFST 162
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_CLKEN_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_CLKEN_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_CLKEN_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_CLKEN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_CLKEN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_INV_VALUE "crcchk_inv_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_INV_ADDR_OFST 173
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_INV_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_INV_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_INV_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_INV_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_INV_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_INV_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_PIPELN_VALUE "crcchk_pipeln_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_PIPELN_ADDR_OFST 170
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_PIPELN_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_PIPELN_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_PIPELN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_PIPELN_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_PIPELN_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCCHK_PIPELN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCFLAG_PIPELN_VALUE "crcflag_pipeln_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCFLAG_PIPELN_ADDR_OFST 170
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCFLAG_PIPELN_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCFLAG_PIPELN_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCFLAG_PIPELN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCFLAG_PIPELN_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCFLAG_PIPELN_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CRCFLAG_PIPELN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CTRL_BIT_REVERSE_VALUE "ctrl_bit_reverse_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CTRL_BIT_REVERSE_ADDR_OFST 172
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DATA_BIT_REVERSE_VALUE "data_bit_reverse_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DATA_BIT_REVERSE_ADDR_OFST 172
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC_64B66B_RXSM_BYPASS_VALUE "dec_64b66b_rxsm_bypass_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC_64B66B_RXSM_BYPASS_ADDR_OFST 150
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC_64B66B_RXSM_BYPASS_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC_64B66B_RXSM_BYPASS_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC_64B66B_RXSM_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC_64B66B_RXSM_BYPASS_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC_64B66B_RXSM_BYPASS_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC_64B66B_RXSM_BYPASS_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC64B66B_CLKEN_VALUE "dec64b66b_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC64B66B_CLKEN_ADDR_OFST 162
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC64B66B_CLKEN_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC64B66B_CLKEN_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC64B66B_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC64B66B_CLKEN_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC64B66B_CLKEN_ADDR_FIELD_VALMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DEC64B66B_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_BYPASS_VALUE "descrm_bypass_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_BYPASS_ADDR_OFST 150
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_BYPASS_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_BYPASS_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_BYPASS_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_BYPASS_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_BYPASS_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_CLKEN_VALUE "descrm_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_CLKEN_ADDR_OFST 162
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_CLKEN_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_CLKEN_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_CLKEN_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_CLKEN_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_MODE_VALUE "async"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_MODE_ADDR_OFST 172
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_MODE_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_MODE_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_MODE_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_MODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_MODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_PIPELN_VALUE "enable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_PIPELN_ADDR_OFST 170
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_PIPELN_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_PIPELN_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_PIPELN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_PIPELN_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_PIPELN_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DESCRM_PIPELN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DFT_CLK_OUT_SEL_VALUE "rx_master_clk"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DFT_CLK_OUT_SEL_ADDR_OFST 179
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DFT_CLK_OUT_SEL_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DFT_CLK_OUT_SEL_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DFT_CLK_OUT_SEL_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DFT_CLK_OUT_SEL_ADDR_FIELD_BITMASK 0x00000078
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DFT_CLK_OUT_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DFT_CLK_OUT_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DIS_SIGNAL_OK_VALUE "dis_signal_ok_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DIS_SIGNAL_OK_ADDR_OFST 171
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DIS_SIGNAL_OK_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DIS_SIGNAL_OK_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DIS_SIGNAL_OK_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DIS_SIGNAL_OK_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DIS_SIGNAL_OK_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DIS_SIGNAL_OK_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DISPCHK_BYPASS_VALUE "dispchk_bypass_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DISPCHK_BYPASS_ADDR_OFST 160
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DISPCHK_BYPASS_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DISPCHK_BYPASS_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DISPCHK_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DISPCHK_BYPASS_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DISPCHK_BYPASS_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_DISPCHK_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_EMPTY_FLAG_TYPE_VALUE "empty_rd_side"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_EMPTY_FLAG_TYPE_ADDR_OFST 178
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_EMPTY_FLAG_TYPE_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_EMPTY_FLAG_TYPE_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_EMPTY_FLAG_TYPE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_EMPTY_FLAG_TYPE_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_EMPTY_FLAG_TYPE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_EMPTY_FLAG_TYPE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FAST_PATH_VALUE "fast_path_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FAST_PATH_ADDR_OFST 169
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FAST_PATH_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FAST_PATH_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FAST_PATH_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FAST_PATH_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FAST_PATH_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FAST_PATH_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_CLKEN_VALUE "fec_clk_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_CLKEN_ADDR_OFST 163
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_CLKEN_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_CLKEN_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_CLKEN_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_CLKEN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_CLKEN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_ENABLE_VALUE "fec_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_ENABLE_ADDR_OFST 150
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_ENABLE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_ENABLE_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_ENABLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_ENABLE_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_ENABLE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FEC_ENABLE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_DOUBLE_READ_VALUE "fifo_double_read_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_DOUBLE_READ_ADDR_OFST 178
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_DOUBLE_READ_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_DOUBLE_READ_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_DOUBLE_READ_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_DOUBLE_READ_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_DOUBLE_READ_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_DOUBLE_READ_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_RD_VALUE "n_rd_empty"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_RD_ADDR_OFST 178
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_RD_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_RD_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_RD_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_RD_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_RD_ADDR_FIELD_VALMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_RD_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_WR_VALUE "n_wr_full"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_WR_ADDR_OFST 178
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_WR_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_WR_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_WR_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_WR_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_WR_ADDR_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FIFO_STOP_WR_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FORCE_ALIGN_VALUE "force_align_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FORCE_ALIGN_ADDR_OFST 164
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FORCE_ALIGN_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FORCE_ALIGN_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FORCE_ALIGN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FORCE_ALIGN_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FORCE_ALIGN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FORCE_ALIGN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_BYPASS_VALUE "frmsync_bypass_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_BYPASS_ADDR_OFST 160
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_BYPASS_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_BYPASS_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_BYPASS_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_BYPASS_ADDR_FIELD_VALMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_CLKEN_VALUE "frmsync_clk_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_CLKEN_ADDR_OFST 162
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_CLKEN_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_CLKEN_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_CLKEN_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_CLKEN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_CLKEN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SCRM_VALUE "enum_scrm_default"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SCRM_ADDR_OFST 164
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SCRM_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SCRM_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SCRM_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SCRM_ADDR_FIELD_BITMASK 0x0000001C
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SCRM_ADDR_FIELD_VALMASK 0x0000000C
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SCRM_ADDR_FIELD_VALUE 0x3

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SYNC_VALUE "enum_sync_default"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SYNC_ADDR_OFST 164
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SYNC_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SYNC_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SYNC_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SYNC_ADDR_FIELD_BITMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SYNC_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_ENUM_SYNC_ADDR_FIELD_VALUE 0x4

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_FLAG_TYPE_VALUE "location_only"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_FLAG_TYPE_ADDR_OFST 173
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_FLAG_TYPE_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_FLAG_TYPE_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_FLAG_TYPE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_FLAG_TYPE_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_FLAG_TYPE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_FLAG_TYPE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_KNUM_SYNC_VALUE "knum_sync_default"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_KNUM_SYNC_ADDR_OFST 165
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_KNUM_SYNC_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_KNUM_SYNC_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_KNUM_SYNC_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_KNUM_SYNC_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_KNUM_SYNC_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_KNUM_SYNC_ADDR_FIELD_VALUE 0x4

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_VALUE 2048
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR0_OFST 174
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR0_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR0_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR1_OFST 175
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR1_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR1_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR1_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR1_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_MFRM_LENGTH_ADDR1_FIELD_VALUE 0x8

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_PIPELN_VALUE "frmsync_pipeln_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_PIPELN_ADDR_OFST 170
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_PIPELN_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_PIPELN_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_PIPELN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_PIPELN_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_PIPELN_ADDR_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FRMSYNC_PIPELN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FULL_FLAG_TYPE_VALUE "full_wr_side"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FULL_FLAG_TYPE_ADDR_OFST 178
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FULL_FLAG_TYPE_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FULL_FLAG_TYPE_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FULL_FLAG_TYPE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FULL_FLAG_TYPE_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FULL_FLAG_TYPE_ADDR_FIELD_VALMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_FULL_FLAG_TYPE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_IDWIDTH_VALUE "width_32"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_IDWIDTH_ADDR_OFST 160
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_IDWIDTH_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_IDWIDTH_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_IDWIDTH_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_IDWIDTH_ADDR_FIELD_BITMASK 0x00000018
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_IDWIDTH_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_IDWIDTH_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_ODWIDTH_VALUE "width_66"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_ODWIDTH_ADDR_OFST 160
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_ODWIDTH_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_ODWIDTH_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_ODWIDTH_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_ODWIDTH_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_ODWIDTH_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GB_RX_ODWIDTH_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GBEXP_CLKEN_VALUE "gbexp_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GBEXP_CLKEN_ADDR_OFST 163
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GBEXP_CLKEN_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GBEXP_CLKEN_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GBEXP_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GBEXP_CLKEN_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GBEXP_CLKEN_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_GBEXP_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_LOW_LATENCY_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_LPBK_MODE_VALUE "lpbk_dis"

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_MASTER_CLK_SEL_VALUE "master_rx_pma_clk"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_MASTER_CLK_SEL_ADDR_OFST 170
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_MASTER_CLK_SEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_MASTER_CLK_SEL_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_MASTER_CLK_SEL_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_MASTER_CLK_SEL_ADDR_FIELD_BITMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_MASTER_CLK_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_MASTER_CLK_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PEMPTY_FLAG_TYPE_VALUE "pempty_rd_side"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PEMPTY_FLAG_TYPE_ADDR_OFST 178
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PEMPTY_FLAG_TYPE_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PEMPTY_FLAG_TYPE_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PEMPTY_FLAG_TYPE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PEMPTY_FLAG_TYPE_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PEMPTY_FLAG_TYPE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PEMPTY_FLAG_TYPE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PFULL_FLAG_TYPE_VALUE "pfull_wr_side"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PFULL_FLAG_TYPE_ADDR_OFST 178
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PFULL_FLAG_TYPE_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PFULL_FLAG_TYPE_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PFULL_FLAG_TYPE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PFULL_FLAG_TYPE_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PFULL_FLAG_TYPE_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PFULL_FLAG_TYPE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PHCOMP_RD_DEL_VALUE "phcomp_rd_del2"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PHCOMP_RD_DEL_ADDR_OFST 179
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PHCOMP_RD_DEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PHCOMP_RD_DEL_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PHCOMP_RD_DEL_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PHCOMP_RD_DEL_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PHCOMP_RD_DEL_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PHCOMP_RD_DEL_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PLD_IF_TYPE_VALUE "fifo"

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_PROT_MODE_VALUE "teng_baser_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RAND_CLKEN_VALUE "rand_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RAND_CLKEN_ADDR_OFST 162
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RAND_CLKEN_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RAND_CLKEN_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RAND_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RAND_CLKEN_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RAND_CLKEN_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RAND_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RD_CLK_SEL_VALUE "rd_rx_pld_clk"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RD_CLK_SEL_ADDR_OFST 151
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RD_CLK_SEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RD_CLK_SEL_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RD_CLK_SEL_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RD_CLK_SEL_ADDR_FIELD_BITMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RD_CLK_SEL_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RD_CLK_SEL_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RDFIFO_CLKEN_VALUE "rdfifo_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RDFIFO_CLKEN_ADDR_OFST 162
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RDFIFO_CLKEN_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RDFIFO_CLKEN_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RDFIFO_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RDFIFO_CLKEN_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RDFIFO_CLKEN_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RDFIFO_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_FIFO_WRITE_CTRL_VALUE "blklock_stops"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_FIFO_WRITE_CTRL_ADDR_OFST 178
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_FIFO_WRITE_CTRL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_FIFO_WRITE_CTRL_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_FIFO_WRITE_CTRL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_FIFO_WRITE_CTRL_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_FIFO_WRITE_CTRL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_FIFO_WRITE_CTRL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SCRM_WIDTH_VALUE "bit64"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SCRM_WIDTH_ADDR_OFST 177
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SCRM_WIDTH_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SCRM_WIDTH_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SCRM_WIDTH_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SCRM_WIDTH_ADDR_FIELD_BITMASK 0x00000018
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SCRM_WIDTH_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SCRM_WIDTH_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SH_LOCATION_VALUE "lsb"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SH_LOCATION_ADDR_OFST 176
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SH_LOCATION_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SH_LOCATION_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SH_LOCATION_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SH_LOCATION_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SH_LOCATION_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SH_LOCATION_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SIGNAL_OK_SEL_VALUE "synchronized_ver"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SIGNAL_OK_SEL_ADDR_OFST 176
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SIGNAL_OK_SEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SIGNAL_OK_SEL_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SIGNAL_OK_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SIGNAL_OK_SEL_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SIGNAL_OK_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SIGNAL_OK_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_BYPASS_VALUE "rx_sm_bypass_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_BYPASS_ADDR_OFST 150
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_BYPASS_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_BYPASS_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_BYPASS_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_BYPASS_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_BYPASS_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_HIBER_VALUE "rx_sm_hiber_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_HIBER_ADDR_OFST 173
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_HIBER_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_HIBER_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_HIBER_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_HIBER_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_HIBER_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_HIBER_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_PIPELN_VALUE "rx_sm_pipeln_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_PIPELN_ADDR_OFST 170
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_PIPELN_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_PIPELN_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_PIPELN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_PIPELN_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_PIPELN_ADDR_FIELD_VALMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_SM_PIPELN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TESTBUS_SEL_VALUE "rx_fifo_testbus1"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TESTBUS_SEL_ADDR_OFST 176
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TESTBUS_SEL_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TESTBUS_SEL_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TESTBUS_SEL_ADDR_FIELD_SIZE 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TESTBUS_SEL_ADDR_FIELD_BITMASK 0x000000F8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TESTBUS_SEL_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TESTBUS_SEL_ADDR_FIELD_VALUE 0x10

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TRUE_B2B_VALUE "b2b"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TRUE_B2B_ADDR_OFST 177
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TRUE_B2B_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TRUE_B2B_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TRUE_B2B_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TRUE_B2B_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TRUE_B2B_ADDR_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RX_TRUE_B2B_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_EMPTY_VALUE "empty_default"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_EMPTY_ADDR_OFST 169
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_EMPTY_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_EMPTY_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_EMPTY_ADDR_FIELD_SIZE 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_EMPTY_ADDR_FIELD_BITMASK 0x0000007C
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_EMPTY_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_EMPTY_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_VALUE "full_default"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR0_OFST 168
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR0_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR0_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR0_FIELD_BITMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR0_FIELD_VALMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR0_FIELD_VALUE 0x7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR1_OFST 169
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR1_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR1_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR1_FIELD_BITMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR1_FIELD_VALMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_FULL_ADDR1_FIELD_VALUE 0x3

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_MODE_VALUE "clk_comp_10g"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_MODE_ADDR_OFST 172
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_MODE_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_MODE_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_MODE_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_MODE_ADDR_FIELD_BITMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_MODE_ADDR_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_MODE_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PEMPTY_VALUE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PEMPTY_ADDR_OFST 168
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PEMPTY_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PEMPTY_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PEMPTY_ADDR_FIELD_SIZE 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PEMPTY_ADDR_FIELD_BITMASK 0x0000001F
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PEMPTY_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PEMPTY_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PFULL_VALUE 23
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PFULL_ADDR_OFST 167
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PFULL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PFULL_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PFULL_ADDR_FIELD_SIZE 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PFULL_ADDR_FIELD_BITMASK 0x0000001F
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PFULL_ADDR_FIELD_VALMASK 0x00000017
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RXFIFO_PFULL_ADDR_FIELD_VALUE 0x17

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_STRETCH_NUM_STAGES_VALUE "two_stage"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_STRETCH_NUM_STAGES_ADDR_OFST 177
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_STRETCH_NUM_STAGES_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_STRETCH_NUM_STAGES_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_STRETCH_NUM_STAGES_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_STRETCH_NUM_STAGES_ADDR_FIELD_BITMASK 0x00000006
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_STRETCH_NUM_STAGES_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_STRETCH_NUM_STAGES_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_VALUE "test_off"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR0_OFST 151
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR0_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR0_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR0_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR0_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR1_OFST 172
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR1_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR1_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR1_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_TEST_MODE_ADDR1_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_WRFIFO_CLKEN_VALUE "wrfifo_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_WRFIFO_CLKEN_ADDR_OFST 162
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_WRFIFO_CLKEN_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_WRFIFO_CLKEN_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_WRFIFO_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_WRFIFO_CLKEN_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_WRFIFO_CLKEN_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_WRFIFO_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_ADVANCED_USER_MODE_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_RX_PCS_RECONFIG_SETTINGS_VALUE "{}"

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BITSLIP_EN_VALUE "bitslip_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BITSLIP_EN_ADDR_OFST 141
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BITSLIP_EN_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BITSLIP_EN_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BITSLIP_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BITSLIP_EN_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BITSLIP_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BITSLIP_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_EN_VALUE "dft_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_EN_ADDR_OFST 143
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_EN_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_EN_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_EN_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_VAL_VALUE "dft_0"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_VAL_ADDR_OFST 143
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_VAL_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_VAL_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_VAL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_VAL_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_VAL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_BONDING_DFT_VAL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_BYPASS_VALUE "crcgen_bypass_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_BYPASS_ADDR_OFST 136
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_BYPASS_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_BYPASS_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_BYPASS_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_BYPASS_ADDR_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_CLKEN_VALUE "crcgen_clk_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_CLKEN_ADDR_OFST 134
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_CLKEN_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_CLKEN_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_CLKEN_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_CLKEN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_CLKEN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_ERR_VALUE "crcgen_err_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_ERR_ADDR_OFST 137
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_ERR_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_ERR_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_ERR_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_ERR_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_ERR_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_ERR_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_INV_VALUE "crcgen_inv_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_INV_ADDR_OFST 137
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_INV_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_INV_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_INV_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_INV_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_INV_ADDR_FIELD_VALMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CRCGEN_INV_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CTRL_BIT_REVERSE_VALUE "ctrl_bit_reverse_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CTRL_BIT_REVERSE_ADDR_OFST 135
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_CTRL_BIT_REVERSE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DATA_BIT_REVERSE_VALUE "data_bit_reverse_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DATA_BIT_REVERSE_ADDR_OFST 137
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DATA_BIT_REVERSE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DFT_CLK_OUT_SEL_VALUE "tx_master_clk"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DFT_CLK_OUT_SEL_ADDR_OFST 140
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DFT_CLK_OUT_SEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DFT_CLK_OUT_SEL_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DFT_CLK_OUT_SEL_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DFT_CLK_OUT_SEL_ADDR_FIELD_BITMASK 0x0000000F
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DFT_CLK_OUT_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DFT_CLK_OUT_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_BYPASS_VALUE "dispgen_bypass_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_BYPASS_ADDR_OFST 136
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_BYPASS_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_BYPASS_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_BYPASS_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_BYPASS_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_CLKEN_VALUE "dispgen_clk_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_CLKEN_ADDR_OFST 134
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_CLKEN_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_CLKEN_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_CLKEN_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_CLKEN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_CLKEN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_ERR_VALUE "dispgen_err_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_ERR_ADDR_OFST 137
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_ERR_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_ERR_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_ERR_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_ERR_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_ERR_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_ERR_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_PIPELN_VALUE "dispgen_pipeln_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_PIPELN_ADDR_OFST 132
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_PIPELN_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_PIPELN_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_PIPELN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_PIPELN_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_PIPELN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_DISPGEN_PIPELN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_EMPTY_FLAG_TYPE_VALUE "empty_rd_side"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_EMPTY_FLAG_TYPE_ADDR_OFST 145
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_EMPTY_FLAG_TYPE_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_EMPTY_FLAG_TYPE_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_EMPTY_FLAG_TYPE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_EMPTY_FLAG_TYPE_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_EMPTY_FLAG_TYPE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_EMPTY_FLAG_TYPE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC_64B66B_TXSM_BYPASS_VALUE "enc_64b66b_txsm_bypass_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC_64B66B_TXSM_BYPASS_ADDR_OFST 112
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC_64B66B_TXSM_BYPASS_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC_64B66B_TXSM_BYPASS_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC_64B66B_TXSM_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC_64B66B_TXSM_BYPASS_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC_64B66B_TXSM_BYPASS_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC_64B66B_TXSM_BYPASS_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC64B66B_TXSM_CLKEN_VALUE "enc64b66b_txsm_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC64B66B_TXSM_CLKEN_ADDR_OFST 134
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC64B66B_TXSM_CLKEN_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC64B66B_TXSM_CLKEN_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC64B66B_TXSM_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC64B66B_TXSM_CLKEN_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC64B66B_TXSM_CLKEN_ADDR_FIELD_VALMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ENC64B66B_TXSM_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FASTPATH_VALUE "fastpath_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FASTPATH_ADDR_OFST 141
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FASTPATH_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FASTPATH_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FASTPATH_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FASTPATH_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FASTPATH_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FASTPATH_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_CLKEN_VALUE "fec_clk_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_CLKEN_ADDR_OFST 134
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_CLKEN_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_CLKEN_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_CLKEN_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_CLKEN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_CLKEN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_ENABLE_VALUE "fec_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_ENABLE_ADDR_OFST 112
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_ENABLE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_ENABLE_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_ENABLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_ENABLE_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_ENABLE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FEC_ENABLE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_DOUBLE_WRITE_VALUE "fifo_double_write_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_DOUBLE_WRITE_ADDR_OFST 141
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_DOUBLE_WRITE_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_DOUBLE_WRITE_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_DOUBLE_WRITE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_DOUBLE_WRITE_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_DOUBLE_WRITE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_DOUBLE_WRITE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_REG_FAST_VALUE "fifo_reg_fast_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_REG_FAST_ADDR_OFST 130
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_REG_FAST_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_REG_FAST_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_REG_FAST_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_REG_FAST_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_REG_FAST_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_REG_FAST_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_RD_VALUE "rd_empty"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_RD_ADDR_OFST 145
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_RD_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_RD_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_RD_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_RD_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_RD_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_RD_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_WR_VALUE "n_wr_full"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_WR_ADDR_OFST 145
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_WR_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_WR_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_WR_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_WR_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_WR_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FIFO_STOP_WR_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BURST_VALUE "frmgen_burst_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BURST_ADDR_OFST 132
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BURST_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BURST_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BURST_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BURST_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BURST_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BURST_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BYPASS_VALUE "frmgen_bypass_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BYPASS_ADDR_OFST 136
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BYPASS_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BYPASS_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BYPASS_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BYPASS_ADDR_FIELD_VALMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_CLKEN_VALUE "frmgen_clk_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_CLKEN_ADDR_OFST 134
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_CLKEN_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_CLKEN_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_CLKEN_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_CLKEN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_CLKEN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_VALUE 2048
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR0_OFST 138
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR0_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR0_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR1_OFST 139
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR1_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR1_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR1_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR1_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_MFRM_LENGTH_ADDR1_FIELD_VALUE 0x8

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PIPELN_VALUE "frmgen_pipeln_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PIPELN_ADDR_OFST 133
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PIPELN_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PIPELN_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PIPELN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PIPELN_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PIPELN_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PIPELN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PYLD_INS_VALUE "frmgen_pyld_ins_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PYLD_INS_ADDR_OFST 137
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PYLD_INS_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PYLD_INS_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PYLD_INS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PYLD_INS_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PYLD_INS_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_PYLD_INS_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_WORDSLIP_VALUE "frmgen_wordslip_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_WORDSLIP_ADDR_OFST 132
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_WORDSLIP_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_WORDSLIP_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_WORDSLIP_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_WORDSLIP_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_WORDSLIP_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FRMGEN_WORDSLIP_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FULL_FLAG_TYPE_VALUE "full_wr_side"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FULL_FLAG_TYPE_ADDR_OFST 145
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FULL_FLAG_TYPE_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FULL_FLAG_TYPE_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FULL_FLAG_TYPE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FULL_FLAG_TYPE_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FULL_FLAG_TYPE_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_FULL_FLAG_TYPE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_PIPELN_BYPASS_VALUE "disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_PIPELN_BYPASS_ADDR_OFST 132
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_PIPELN_BYPASS_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_PIPELN_BYPASS_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_PIPELN_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_PIPELN_BYPASS_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_PIPELN_BYPASS_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_PIPELN_BYPASS_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_IDWIDTH_VALUE "width_66"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_IDWIDTH_ADDR_OFST 136
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_IDWIDTH_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_IDWIDTH_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_IDWIDTH_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_IDWIDTH_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_IDWIDTH_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_IDWIDTH_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_ODWIDTH_VALUE "width_32"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_ODWIDTH_ADDR_OFST 136
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_ODWIDTH_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_ODWIDTH_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_ODWIDTH_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_ODWIDTH_ADDR_FIELD_BITMASK 0x00000018
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_ODWIDTH_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GB_TX_ODWIDTH_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GBRED_CLKEN_VALUE "gbred_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GBRED_CLKEN_ADDR_OFST 134
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GBRED_CLKEN_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GBRED_CLKEN_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GBRED_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GBRED_CLKEN_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GBRED_CLKEN_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_GBRED_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_LOW_LATENCY_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_MASTER_CLK_SEL_VALUE "master_tx_pma_clk"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_MASTER_CLK_SEL_ADDR_OFST 133
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_MASTER_CLK_SEL_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_MASTER_CLK_SEL_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_MASTER_CLK_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_MASTER_CLK_SEL_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_MASTER_CLK_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_MASTER_CLK_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PEMPTY_FLAG_TYPE_VALUE "pempty_rd_side"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PEMPTY_FLAG_TYPE_ADDR_OFST 145
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PEMPTY_FLAG_TYPE_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PEMPTY_FLAG_TYPE_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PEMPTY_FLAG_TYPE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PEMPTY_FLAG_TYPE_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PEMPTY_FLAG_TYPE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PEMPTY_FLAG_TYPE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PFULL_FLAG_TYPE_VALUE "pfull_wr_side"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PFULL_FLAG_TYPE_ADDR_OFST 145
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PFULL_FLAG_TYPE_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PFULL_FLAG_TYPE_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PFULL_FLAG_TYPE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PFULL_FLAG_TYPE_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PFULL_FLAG_TYPE_ADDR_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PFULL_FLAG_TYPE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PHCOMP_RD_DEL_VALUE "phcomp_rd_del4"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PHCOMP_RD_DEL_ADDR_OFST 135
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PHCOMP_RD_DEL_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PHCOMP_RD_DEL_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PHCOMP_RD_DEL_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PHCOMP_RD_DEL_ADDR_FIELD_BITMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PHCOMP_RD_DEL_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PHCOMP_RD_DEL_ADDR_FIELD_VALUE 0x4

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PLD_IF_TYPE_VALUE "fifo"

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PROT_MODE_VALUE "teng_baser_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_RANDOM_VALUE "all_0"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_RANDOM_ADDR_OFST 130
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_RANDOM_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_RANDOM_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_RANDOM_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_RANDOM_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_RANDOM_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_RANDOM_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_VALUE "288230376151711743"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR0_OFST 122
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR0_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR0_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR0_FIELD_VALMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR0_FIELD_VALUE 0xFF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR1_OFST 123
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR1_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR1_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR1_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR1_FIELD_VALMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR1_FIELD_VALUE 0xFF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR2_OFST 124
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR2_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR2_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR2_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR2_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR2_FIELD_VALMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR2_FIELD_VALUE 0xFF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR3_OFST 125
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR3_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR3_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR3_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR3_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR3_FIELD_VALMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR3_FIELD_VALUE 0xFF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR4_OFST 126
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR4_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR4_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR4_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR4_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR4_FIELD_VALMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR4_FIELD_VALUE 0xFF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR5_OFST 127
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR5_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR5_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR5_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR5_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR5_FIELD_VALMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR5_FIELD_VALUE 0xFF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR6_OFST 128
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR6_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR6_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR6_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR6_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR6_FIELD_VALMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR6_FIELD_VALUE 0xFF
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR7_OFST 129
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR7_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR7_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR7_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR7_FIELD_BITMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR7_FIELD_VALMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_PSEUDO_SEED_B_ADDR7_FIELD_VALUE 0x3

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RANDOM_DISP_VALUE "disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RANDOM_DISP_ADDR_OFST 130
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RANDOM_DISP_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RANDOM_DISP_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RANDOM_DISP_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RANDOM_DISP_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RANDOM_DISP_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RANDOM_DISP_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RDFIFO_CLKEN_VALUE "rdfifo_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RDFIFO_CLKEN_ADDR_OFST 135
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RDFIFO_CLKEN_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RDFIFO_CLKEN_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RDFIFO_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RDFIFO_CLKEN_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RDFIFO_CLKEN_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RDFIFO_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_BYPASS_VALUE "scrm_bypass_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_BYPASS_ADDR_OFST 112
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_BYPASS_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_BYPASS_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_BYPASS_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_BYPASS_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_BYPASS_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_CLKEN_VALUE "scrm_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_CLKEN_ADDR_OFST 134
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_CLKEN_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_CLKEN_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_CLKEN_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_CLKEN_ADDR_FIELD_VALMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_MODE_VALUE "async"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_MODE_ADDR_OFST 137
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_MODE_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_MODE_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_MODE_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_MODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_MODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_PIPELN_VALUE "enable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_PIPELN_ADDR_OFST 132
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_PIPELN_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_PIPELN_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_PIPELN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_PIPELN_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_PIPELN_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SCRM_PIPELN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SH_ERR_VALUE "sh_err_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SH_ERR_ADDR_OFST 137
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SH_ERR_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SH_ERR_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SH_ERR_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SH_ERR_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SH_ERR_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SH_ERR_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SOP_MARK_VALUE "sop_mark_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SOP_MARK_ADDR_OFST 130
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SOP_MARK_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SOP_MARK_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SOP_MARK_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SOP_MARK_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SOP_MARK_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SOP_MARK_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_STRETCH_NUM_STAGES_VALUE "two_stage"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_STRETCH_NUM_STAGES_ADDR_OFST 141
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_STRETCH_NUM_STAGES_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_STRETCH_NUM_STAGES_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_STRETCH_NUM_STAGES_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_STRETCH_NUM_STAGES_ADDR_FIELD_BITMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_STRETCH_NUM_STAGES_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_STRETCH_NUM_STAGES_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_VALUE "test_off"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_OFST 130
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_FIELD0_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_FIELD0_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_FIELD0_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_FIELD0_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_FIELD0_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_FIELD0_VALUE 0x1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_FIELD1_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_FIELD1_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_FIELD1_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_FIELD1_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_FIELD1_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TEST_MODE_ADDR_FIELD1_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_ERR_VALUE "scrm_err_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_ERR_ADDR_OFST 144
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_ERR_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_ERR_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_ERR_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_ERR_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_ERR_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_ERR_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_WIDTH_VALUE "bit64"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_WIDTH_ADDR_OFST 144
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_WIDTH_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_WIDTH_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_WIDTH_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_WIDTH_ADDR_FIELD_BITMASK 0x00000018
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_WIDTH_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SCRM_WIDTH_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SH_LOCATION_VALUE "lsb"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SH_LOCATION_ADDR_OFST 144
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SH_LOCATION_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SH_LOCATION_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SH_LOCATION_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SH_LOCATION_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SH_LOCATION_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SH_LOCATION_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_BYPASS_VALUE "tx_sm_bypass_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_BYPASS_ADDR_OFST 112
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_BYPASS_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_BYPASS_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_BYPASS_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_BYPASS_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_BYPASS_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_PIPELN_VALUE "tx_sm_pipeln_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_PIPELN_ADDR_OFST 132
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_PIPELN_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_PIPELN_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_PIPELN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_PIPELN_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_PIPELN_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_SM_PIPELN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_VALUE "tx_fifo_testbus1"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR0_OFST 144
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR0_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR0_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR0_FIELD_BITMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR0_FIELD_VALMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR0_FIELD_VALUE 0x6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR1_OFST 145
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR1_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR1_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR1_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TX_TESTBUS_SEL_ADDR1_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_EMPTY_VALUE "empty_default"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_EMPTY_ADDR_OFST 121
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_EMPTY_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_EMPTY_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_EMPTY_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_EMPTY_ADDR_FIELD_BITMASK 0x0000003C
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_EMPTY_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_EMPTY_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_FULL_VALUE "full_default"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_FULL_ADDR_OFST 129
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_FULL_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_FULL_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_FULL_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_FULL_ADDR_FIELD_BITMASK 0x0000003C
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_FULL_ADDR_FIELD_VALMASK 0x0000003C
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_FULL_ADDR_FIELD_VALUE 0xF

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_MODE_VALUE "phase_comp"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_MODE_ADDR_OFST 133
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_MODE_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_MODE_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_MODE_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_MODE_ADDR_FIELD_BITMASK 0x00000038
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_MODE_ADDR_FIELD_VALMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_MODE_ADDR_FIELD_VALUE 0x4

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PEMPTY_VALUE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PEMPTY_ADDR_OFST 113
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PEMPTY_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PEMPTY_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PEMPTY_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PEMPTY_ADDR_FIELD_BITMASK 0x00000078
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PEMPTY_ADDR_FIELD_VALMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PEMPTY_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_VALUE 11
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR0_OFST 112
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR0_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR0_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR0_FIELD_BITMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR0_FIELD_VALMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR0_FIELD_VALUE 0x3
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR1_OFST 113
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR1_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR1_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR1_FIELD_BITMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR1_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_TXFIFO_PFULL_ADDR1_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WR_CLK_SEL_VALUE "wr_tx_pld_clk"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WR_CLK_SEL_ADDR_OFST 112
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WR_CLK_SEL_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WR_CLK_SEL_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WR_CLK_SEL_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WR_CLK_SEL_ADDR_FIELD_BITMASK 0x00000030
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WR_CLK_SEL_ADDR_FIELD_VALMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WR_CLK_SEL_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WRFIFO_CLKEN_VALUE "wrfifo_clk_en"
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WRFIFO_CLKEN_ADDR_OFST 135
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WRFIFO_CLKEN_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WRFIFO_CLKEN_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WRFIFO_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WRFIFO_CLKEN_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WRFIFO_CLKEN_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_WRFIFO_CLKEN_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_ADVANCED_USER_MODE_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_10G_TX_PCS_RECONFIG_SETTINGS_VALUE "{}"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_HIP_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_HRDRSTCTL_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_PROT_MODE_TX_VALUE "teng_baser_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_CTRL_PLANE_BONDING_TX_VALUE "individual_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_PMA_DW_TX_VALUE "pma_32b_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_PLD_FIFO_MODE_TX_VALUE "fifo_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_SHARED_FIFO_WIDTH_TX_VALUE "single_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_LOW_LATENCY_EN_TX_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_FUNC_MODE_VALUE "enable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_LPBK_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_FREQUENCY_RULES_EN_VALUE "enable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_PMA_TX_CLK_HZ_VALUE 322265625

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_CHNL_PLD_TX_CLK_HZ_VALUE 156250000

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_FIFO_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_FIFO_PROT_MODE_TX_VALUE "teng_mode_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_FIFO_SHARED_FIFO_WIDTH_TX_VALUE "single_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_10G_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_10G_LPBK_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_10G_ADVANCED_USER_MODE_TX_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_10G_PMA_DW_TX_VALUE "pma_32b_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_10G_FIFO_MODE_TX_VALUE "fifo_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_10G_PROT_MODE_TX_VALUE "teng_baser_mode_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_10G_LOW_LATENCY_EN_TX_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_10G_SHARED_FIFO_WIDTH_TX_VALUE "single_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_8G_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_8G_LPBK_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_8G_PROT_MODE_TX_VALUE "disabled_prot_mode_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_8G_HIP_MODE_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_8G_PMA_DW_TX_VALUE "pma_10b_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_8G_FIFO_MODE_TX_VALUE "fifo_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_G3_PROT_MODE_VALUE "disabled_prot_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_KRFEC_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_KRFEC_LPBK_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_KRFEC_PROT_MODE_TX_VALUE "disabled_prot_mode_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_KRFEC_LOW_LATENCY_EN_TX_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_PMAIF_LPBK_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_PMAIF_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_PMAIF_SIM_MODE_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_PMAIF_PROT_MODE_TX_VALUE "teng_krfec_mode_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_PMAIF_PMA_DW_TX_VALUE "pma_32b_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_PLDIF_PROT_MODE_TX_VALUE "teng_pld_fifo_mode_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_HD_PLDIF_HRDRSTCTL_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_SOURCE_VALUE "teng"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_SOURCE_ADDR_OFST 34
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_SOURCE_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_SOURCE_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_SOURCE_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_SOURCE_ADDR_FIELD_BITMASK 0x0000000C
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_SOURCE_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_SOURCE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DATA_SOURCE_VALUE "hip_disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DATA_SOURCE_ADDR_OFST 32
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DATA_SOURCE_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DATA_SOURCE_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DATA_SOURCE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DATA_SOURCE_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DATA_SOURCE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DATA_SOURCE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_EN_VALUE "delay1_clk_disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_EN_ADDR_OFST 32
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_EN_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_EN_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_EN_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_SEL_VALUE "pcs_tx_clk"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_SEL_ADDR_OFST 32
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_SEL_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_SEL_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_SEL_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_SEL_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CLK_SEL_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CTRL_VALUE "delay1_path0"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CTRL_ADDR_OFST 33
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CTRL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CTRL_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CTRL_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CTRL_ADDR_FIELD_BITMASK 0x0000000F
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CTRL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_CTRL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_DATA_SEL_VALUE "one_ff_delay"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_DATA_SEL_ADDR_OFST 32
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_DATA_SEL_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_DATA_SEL_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_DATA_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_DATA_SEL_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_DATA_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY1_DATA_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CLK_EN_VALUE "delay2_clk_disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CLK_EN_ADDR_OFST 32
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CLK_EN_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CLK_EN_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CLK_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CLK_EN_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CLK_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CLK_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CTRL_VALUE "delay2_path0"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CTRL_ADDR_OFST 33
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CTRL_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CTRL_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CTRL_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CTRL_ADDR_FIELD_BITMASK 0x000000F0
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CTRL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_DELAY2_CTRL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_OUTPUT_SEL_VALUE "teng_output"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_OUTPUT_SEL_ADDR_OFST 32
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_OUTPUT_SEL_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_OUTPUT_SEL_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_OUTPUT_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_OUTPUT_SEL_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_OUTPUT_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_OUTPUT_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_OUT_SEL_VALUE "teng_clk_out"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_OUT_SEL_ADDR_OFST 34
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_OUT_SEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_OUT_SEL_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_OUT_SEL_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_OUT_SEL_ADDR_FIELD_BITMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_OUT_SEL_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_PCS_TX_CLK_OUT_SEL_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PLD_PCS_INTERFACE_RECONFIG_SETTINGS_VALUE "{}"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_HIP_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_TRANSPARENT_PCS_RX_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_HRDRSTCTL_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_PROT_MODE_RX_VALUE "teng_baser_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_CTRL_PLANE_BONDING_RX_VALUE "individual_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_PMA_DW_RX_VALUE "pma_32b_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_PLD_FIFO_MODE_RX_VALUE "fifo_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_SHARED_FIFO_WIDTH_RX_VALUE "single_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_LOW_LATENCY_EN_RX_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_FUNC_MODE_VALUE "enable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_LPBK_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_ADVANCED_USER_MODE_RX_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_FREQUENCY_RULES_EN_VALUE "enable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_PMA_RX_CLK_HZ_VALUE 322265625

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_PLD_RX_CLK_HZ_VALUE 156250000

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_FREF_CLK_HZ_VALUE 322265625

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_CHNL_CLKLOW_CLK_HZ_VALUE 322265625

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_FIFO_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_FIFO_PROT_MODE_RX_VALUE "teng_mode_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_FIFO_SHARED_FIFO_WIDTH_RX_VALUE "single_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_LPBK_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_PMA_DW_RX_VALUE "pma_32b_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_FIFO_MODE_RX_VALUE "fifo_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_PROT_MODE_RX_VALUE "teng_baser_mode_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_LOW_LATENCY_EN_RX_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_SHARED_FIFO_WIDTH_RX_VALUE "single_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_TEST_BUS_MODE_VALUE "rx"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_TEST_BUS_MODE_ADDR_OFST 184
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_TEST_BUS_MODE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_TEST_BUS_MODE_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_TEST_BUS_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_TEST_BUS_MODE_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_TEST_BUS_MODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_10G_TEST_BUS_MODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_8G_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_8G_LPBK_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_8G_PROT_MODE_RX_VALUE "disabled_prot_mode_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_8G_HIP_MODE_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_8G_PMA_DW_RX_VALUE "pma_10b_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_8G_FIFO_MODE_RX_VALUE "fifo_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_G3_PROT_MODE_VALUE "disabled_prot_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_KRFEC_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_KRFEC_LPBK_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_KRFEC_PROT_MODE_RX_VALUE "disabled_prot_mode_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_KRFEC_LOW_LATENCY_EN_RX_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_KRFEC_TEST_BUS_MODE_VALUE "tx"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_KRFEC_TEST_BUS_MODE_ADDR_OFST 196
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_KRFEC_TEST_BUS_MODE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_KRFEC_TEST_BUS_MODE_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_KRFEC_TEST_BUS_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_KRFEC_TEST_BUS_MODE_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_KRFEC_TEST_BUS_MODE_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_KRFEC_TEST_BUS_MODE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_PMAIF_LPBK_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_PMAIF_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_PMAIF_SIM_MODE_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_PMAIF_PROT_MODE_RX_VALUE "teng_krfec_mode_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_PMAIF_PMA_DW_RX_VALUE "pma_32b_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_PLDIF_PROT_MODE_RX_VALUE "teng_pld_fifo_mode_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_HD_PLDIF_HRDRSTCTL_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_BLOCK_SEL_VALUE "teng"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_BLOCK_SEL_ADDR_OFST 36
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_BLOCK_SEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_BLOCK_SEL_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_BLOCK_SEL_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_BLOCK_SEL_ADDR_FIELD_BITMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_BLOCK_SEL_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_BLOCK_SEL_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_SEL_VALUE "pld_rx_clk"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_SEL_ADDR_OFST 36
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_SEL_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_SEL_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_SEL_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_SEL_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_SEL_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_HIP_CLK_EN_VALUE "hip_rx_disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_HIP_CLK_EN_ADDR_OFST 36
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_HIP_CLK_EN_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_HIP_CLK_EN_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_HIP_CLK_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_HIP_CLK_EN_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_HIP_CLK_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_HIP_CLK_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_OUTPUT_SEL_VALUE "teng_output"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_OUTPUT_SEL_ADDR_OFST 36
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_OUTPUT_SEL_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_OUTPUT_SEL_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_OUTPUT_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_OUTPUT_SEL_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_OUTPUT_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_OUTPUT_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_OUT_SEL_VALUE "teng_clk_out"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_OUT_SEL_ADDR_OFST 36
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_OUT_SEL_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_OUT_SEL_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_OUT_SEL_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_OUT_SEL_ADDR_FIELD_BITMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_OUT_SEL_ADDR_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_PCS_RX_CLK_OUT_SEL_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PLD_PCS_INTERFACE_RECONFIG_SETTINGS_VALUE "{}"

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_EN_VALUE "dft_clk_out_disable"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_EN_ADDR_OFST 41
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_EN_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_EN_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_EN_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_SEL_VALUE "teng_rx_dft_clk"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_SEL_ADDR_OFST 40
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_SEL_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_SEL_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_SEL_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_SEL_ADDR_FIELD_BITMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_DFT_CLK_OUT_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_HRDRSTCTRL_EN_VALUE "hrst_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_HRDRSTCTRL_EN_ADDR_OFST 40
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_HRDRSTCTRL_EN_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_HRDRSTCTRL_EN_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_HRDRSTCTRL_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_HRDRSTCTRL_EN_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_HRDRSTCTRL_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_HRDRSTCTRL_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_PCS_TESTBUS_BLOCK_SEL_VALUE "pma_if"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_PCS_TESTBUS_BLOCK_SEL_ADDR_OFST 40
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_PCS_TESTBUS_BLOCK_SEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_PCS_TESTBUS_BLOCK_SEL_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_PCS_TESTBUS_BLOCK_SEL_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_PCS_TESTBUS_BLOCK_SEL_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_PCS_TESTBUS_BLOCK_SEL_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_PCS_TESTBUS_BLOCK_SEL_ADDR_FIELD_VALUE 0x4

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PLD_PCS_INTERFACE_RECONFIG_SETTINGS_VALUE "{}"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_BLOCK_SEL_VALUE "ten_g_pcs"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_OFST 10
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_FIELD_BITMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_CLKSLIP_SEL_VALUE "pld"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_CLKSLIP_SEL_ADDR_OFST 10
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_CLKSLIP_SEL_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_CLKSLIP_SEL_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_CLKSLIP_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_CLKSLIP_SEL_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_CLKSLIP_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_CLKSLIP_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_LPBK_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_VALUE "master_rx_pma_clk"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_OFST 10
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_FIELD_BITMASK 0x00000060
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_VALUE "pldif_data_10bit"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_OFST 15
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_DW_RX_VALUE "pma_32b_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_VALUE "dft_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_OFST 15
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_VALUE "dft_0"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_OFST 15
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_CLKEN_VALUE "prbs_clk_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_OFST 10
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_VALUE "prbs_off"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR0_OFST 11
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR0_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR0_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR0_FIELD_BITMASK 0x000000F0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR1_OFST 12
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR1_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR1_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS_VER_ADDR1_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_VALUE "prbs9_64b"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_OFST 12
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_PROT_MODE_RX_VALUE "teng_krfec_mode_rx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_DYN_POLARITY_INVERSION_VALUE "rx_dyn_polinv_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_DYN_POLARITY_INVERSION_ADDR_OFST 11
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_DYN_POLARITY_INVERSION_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_DYN_POLARITY_INVERSION_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_DYN_POLARITY_INVERSION_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_DYN_POLARITY_INVERSION_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_DYN_POLARITY_INVERSION_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_DYN_POLARITY_INVERSION_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_LPBK_EN_VALUE "lpbk_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_LPBK_EN_ADDR_OFST 10
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_LPBK_EN_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_LPBK_EN_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_LPBK_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_LPBK_EN_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_LPBK_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_LPBK_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_FORCE_SIGNAL_OK_VALUE "force_sig_ok"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_FORCE_SIGNAL_OK_ADDR_OFST 12
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_FORCE_SIGNAL_OK_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_FORCE_SIGNAL_OK_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_FORCE_SIGNAL_OK_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_FORCE_SIGNAL_OK_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_FORCE_SIGNAL_OK_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_FORCE_SIGNAL_OK_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MASK_VALUE "prbsmask128"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MASK_ADDR_OFST 11
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MASK_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MASK_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MASK_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MASK_ADDR_FIELD_BITMASK 0x0000000C
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MASK_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MASK_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MODE_VALUE "teng_mode"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MODE_ADDR_OFST 11
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MODE_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MODE_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MODE_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MODE_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_PRBS_MODE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_SIGNALOK_SIGNALDET_SEL_VALUE "sel_sig_det"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_SIGNALOK_SIGNALDET_SEL_ADDR_OFST 12
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_SIGNALOK_SIGNALDET_SEL_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_SIGNALOK_SIGNALDET_SEL_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_SIGNALOK_SIGNALDET_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_SIGNALOK_SIGNALDET_SEL_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_SIGNALOK_SIGNALDET_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_SIGNALOK_SIGNALDET_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_STATIC_POLARITY_INVERSION_VALUE "rx_stat_polinv_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_STATIC_POLARITY_INVERSION_ADDR_OFST 10
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_STATIC_POLARITY_INVERSION_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_STATIC_POLARITY_INVERSION_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_STATIC_POLARITY_INVERSION_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_STATIC_POLARITY_INVERSION_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_STATIC_POLARITY_INVERSION_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RX_STATIC_POLARITY_INVERSION_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_RX_PCS_PMA_INTERFACE_RECONFIG_SETTINGS_VALUE "{}"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_BYPASS_PMA_TXELECIDLE_VALUE "true"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_BYPASS_PMA_TXELECIDLE_ADDR_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_BYPASS_PMA_TXELECIDLE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_BYPASS_PMA_TXELECIDLE_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_BYPASS_PMA_TXELECIDLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_BYPASS_PMA_TXELECIDLE_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_BYPASS_PMA_TXELECIDLE_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_BYPASS_PMA_TXELECIDLE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_CHANNEL_OPERATION_MODE_VALUE "tx_rx_pair_enabled"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_LPBK_EN_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_VALUE "master_tx_pma_clk"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_MASTER_CLK_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PCIE_SUB_PROT_MODE_TX_VALUE "other_prot_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_VALUE "pldif_data_10bit"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_OFST 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PLDIF_DATAWIDTH_MODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMA_DW_TX_VALUE "pma_32b_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_VALUE "dft_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_OFST 15
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMAGATE_EN_VALUE "pmagate_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMAGATE_EN_ADDR_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMAGATE_EN_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMAGATE_EN_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMAGATE_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMAGATE_EN_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMAGATE_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PMAGATE_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_CLKEN_VALUE "prbs_clk_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_CLKEN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_VALUE "prbs_gen_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR0_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR0_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR0_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR0_FIELD_BITMASK 0x000000F0
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR1_OFST 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR1_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR1_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR1_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS_GEN_PAT_ADDR1_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_VALUE "prbs9_64b"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PRBS9_DWIDTH_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_PROT_MODE_TX_VALUE "teng_krfec_mode_tx"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQ_WAVE_NUM_VALUE "sq_wave_default"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQ_WAVE_NUM_ADDR_OFST 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQ_WAVE_NUM_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQ_WAVE_NUM_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQ_WAVE_NUM_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQ_WAVE_NUM_ADDR_FIELD_BITMASK 0x0000000F
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQ_WAVE_NUM_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQ_WAVE_NUM_ADDR_FIELD_VALUE 0x4

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQWGEN_CLKEN_VALUE "sqwgen_clk_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQWGEN_CLKEN_ADDR_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQWGEN_CLKEN_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQWGEN_CLKEN_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQWGEN_CLKEN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQWGEN_CLKEN_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQWGEN_CLKEN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SQWGEN_CLKEN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_DYN_POLARITY_INVERSION_VALUE "tx_dyn_polinv_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_DYN_POLARITY_INVERSION_ADDR_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_DYN_POLARITY_INVERSION_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_DYN_POLARITY_INVERSION_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_DYN_POLARITY_INVERSION_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_DYN_POLARITY_INVERSION_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_DYN_POLARITY_INVERSION_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_DYN_POLARITY_INVERSION_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_VALUE "ten_g_pcs"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR0_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR0_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR0_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR0_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR0_FIELD_VALMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR0_FIELD_VALUE 0x3
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR1_OFST 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR1_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR1_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR1_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR1_FIELD_BITMASK 0x00000060
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_PMA_DATA_SEL_ADDR1_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_STATIC_POLARITY_INVERSION_VALUE "tx_stat_polinv_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_STATIC_POLARITY_INVERSION_ADDR_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_STATIC_POLARITY_INVERSION_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_STATIC_POLARITY_INVERSION_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_STATIC_POLARITY_INVERSION_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_STATIC_POLARITY_INVERSION_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_STATIC_POLARITY_INVERSION_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_TX_STATIC_POLARITY_INVERSION_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_TX_PCS_PMA_INTERFACE_RECONFIG_SETTINGS_VALUE "{}"

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_CLK_ENABLE_VALUE "false"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_CLK_ENABLE_ADDR_OFST 24
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_CLK_ENABLE_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_CLK_ENABLE_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_CLK_ENABLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_CLK_ENABLE_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_CLK_ENABLE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_CLK_ENABLE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_ENABLE_VALUE "dis_asn"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_ENABLE_ADDR_OFST 13
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_ENABLE_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_ENABLE_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_ENABLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_ENABLE_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_ENABLE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_ASN_ENABLE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BLOCK_SEL_VALUE "eight_g_pcs"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_OFST 13
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BLOCK_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_EARLY_EIOS_VALUE "true"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_EARLY_EIOS_ADDR_OFST 25
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_EARLY_EIOS_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_EARLY_EIOS_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_EARLY_EIOS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_EARLY_EIOS_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_EARLY_EIOS_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_EARLY_EIOS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PCIE_SWITCH_VALUE "true"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PCIE_SWITCH_ADDR_OFST 25
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PCIE_SWITCH_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PCIE_SWITCH_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PCIE_SWITCH_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PCIE_SWITCH_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PCIE_SWITCH_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PCIE_SWITCH_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_LTR_VALUE "true"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_LTR_ADDR_OFST 25
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_LTR_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_LTR_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_LTR_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_LTR_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_LTR_ADDR_FIELD_VALMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_LTR_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_SW_DONE_VALUE "false"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_SW_DONE_ADDR_OFST 24
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_SW_DONE_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_SW_DONE_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_SW_DONE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_SW_DONE_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_SW_DONE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PMA_SW_DONE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PPM_LOCK_VALUE "false"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PPM_LOCK_ADDR_OFST 25
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PPM_LOCK_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PPM_LOCK_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PPM_LOCK_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PPM_LOCK_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PPM_LOCK_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_PPM_LOCK_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_SEND_SYNCP_FBKP_VALUE "true"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_SEND_SYNCP_FBKP_ADDR_OFST 21
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_SEND_SYNCP_FBKP_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_SEND_SYNCP_FBKP_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_SEND_SYNCP_FBKP_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_SEND_SYNCP_FBKP_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_SEND_SYNCP_FBKP_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_SEND_SYNCP_FBKP_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_TXDETECTRX_VALUE "true"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_TXDETECTRX_ADDR_OFST 25
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_TXDETECTRX_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_TXDETECTRX_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_TXDETECTRX_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_TXDETECTRX_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_TXDETECTRX_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_BYPASS_TXDETECTRX_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CDR_CONTROL_VALUE "dis_cdr_ctrl"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CDR_CONTROL_ADDR_OFST 25
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CDR_CONTROL_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CDR_CONTROL_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CDR_CONTROL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CDR_CONTROL_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CDR_CONTROL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CDR_CONTROL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CID_ENABLE_VALUE "dis_cid_mode"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CID_ENABLE_ADDR_OFST 25
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CID_ENABLE_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CID_ENABLE_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CID_ENABLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CID_ENABLE_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CID_ENABLE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_CID_ENABLE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR0_OFST 28
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR0_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR0_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR1_OFST 29
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR1_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR1_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR1_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_ADDR1_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_MULTI_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_MULTI_ADDR_OFST 30
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_MULTI_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_MULTI_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_MULTI_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_MULTI_ADDR_FIELD_BITMASK 0x00000038
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_MULTI_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DATA_MASK_COUNT_MULTI_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DFT_OBSERVATION_CLOCK_SELECTION_VALUE "dft_clk_obsrv_tx0"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DFT_OBSERVATION_CLOCK_SELECTION_ADDR_OFST 27
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DFT_OBSERVATION_CLOCK_SELECTION_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DFT_OBSERVATION_CLOCK_SELECTION_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DFT_OBSERVATION_CLOCK_SELECTION_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DFT_OBSERVATION_CLOCK_SELECTION_ADDR_FIELD_BITMASK 0x000000F0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DFT_OBSERVATION_CLOCK_SELECTION_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_DFT_OBSERVATION_CLOCK_SELECTION_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_EARLY_EIOS_COUNTER_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_EARLY_EIOS_COUNTER_ADDR_OFST 31
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_EARLY_EIOS_COUNTER_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_EARLY_EIOS_COUNTER_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_EARLY_EIOS_COUNTER_ADDR_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_EARLY_EIOS_COUNTER_ADDR_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_EARLY_EIOS_COUNTER_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_EARLY_EIOS_COUNTER_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FORCE_FREQDET_VALUE "force_freqdet_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FORCE_FREQDET_ADDR_OFST 14
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FORCE_FREQDET_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FORCE_FREQDET_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FORCE_FREQDET_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FORCE_FREQDET_ADDR_FIELD_BITMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FORCE_FREQDET_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FORCE_FREQDET_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FREE_RUN_CLK_ENABLE_VALUE "false"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FREE_RUN_CLK_ENABLE_ADDR_OFST 24
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FREE_RUN_CLK_ENABLE_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FREE_RUN_CLK_ENABLE_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FREE_RUN_CLK_ENABLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FREE_RUN_CLK_ENABLE_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FREE_RUN_CLK_ENABLE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_FREE_RUN_CLK_ENABLE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_IGNORE_SIGDET_G23_VALUE "false"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_IGNORE_SIGDET_G23_ADDR_OFST 30
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_IGNORE_SIGDET_G23_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_IGNORE_SIGDET_G23_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_IGNORE_SIGDET_G23_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_IGNORE_SIGDET_G23_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_IGNORE_SIGDET_G23_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_IGNORE_SIGDET_G23_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_EN_COUNTER_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_EN_COUNTER_ADDR_OFST 19
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_EN_COUNTER_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_EN_COUNTER_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_EN_COUNTER_ADDR_FIELD_SIZE 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_EN_COUNTER_ADDR_FIELD_BITMASK 0x0000007F
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_EN_COUNTER_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_EN_COUNTER_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_RST_COUNTER_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_RST_COUNTER_ADDR_OFST 20
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_RST_COUNTER_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_RST_COUNTER_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_RST_COUNTER_ADDR_FIELD_SIZE 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_RST_COUNTER_ADDR_FIELD_BITMASK 0x0000001F
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_RST_COUNTER_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PC_RST_COUNTER_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PCIE_HIP_MODE_VALUE "hip_disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PH_FIFO_REG_MODE_VALUE "phfifo_reg_mode_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PH_FIFO_REG_MODE_ADDR_OFST 19
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PH_FIFO_REG_MODE_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PH_FIFO_REG_MODE_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PH_FIFO_REG_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PH_FIFO_REG_MODE_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PH_FIFO_REG_MODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PH_FIFO_REG_MODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PHFIFO_FLUSH_WAIT_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PHFIFO_FLUSH_WAIT_ADDR_OFST 18
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PHFIFO_FLUSH_WAIT_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PHFIFO_FLUSH_WAIT_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PHFIFO_FLUSH_WAIT_ADDR_FIELD_SIZE 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PHFIFO_FLUSH_WAIT_ADDR_FIELD_BITMASK 0x000000FC
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PHFIFO_FLUSH_WAIT_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PHFIFO_FLUSH_WAIT_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PIPE_IF_G3PCS_VALUE "pipe_if_8gpcs"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PIPE_IF_G3PCS_ADDR_OFST 13
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PIPE_IF_G3PCS_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PIPE_IF_G3PCS_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PIPE_IF_G3PCS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PIPE_IF_G3PCS_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PIPE_IF_G3PCS_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PIPE_IF_G3PCS_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR0_OFST 16
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR0_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR0_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR1_OFST 17
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR1_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR1_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR1_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR1_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR2_OFST 18
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR2_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR2_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR2_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR2_FIELD_BITMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR2_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_DONE_COUNTER_ADDR2_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_VALUE "dft_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_OFST 15
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_VALUE "dft_0"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_OFST 15
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PMA_IF_DFT_VAL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_CNT_RST_VALUE "ppm_cnt_rst_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_CNT_RST_ADDR_OFST 13
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_CNT_RST_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_CNT_RST_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_CNT_RST_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_CNT_RST_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_CNT_RST_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_CNT_RST_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_DEASSERT_EARLY_VALUE "deassert_early_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_DEASSERT_EARLY_ADDR_OFST 13
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_DEASSERT_EARLY_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_DEASSERT_EARLY_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_DEASSERT_EARLY_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_DEASSERT_EARLY_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_DEASSERT_EARLY_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_DEASSERT_EARLY_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_GEN1_2_CNT_VALUE "cnt_32k"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_GEN1_2_CNT_ADDR_OFST 13
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_GEN1_2_CNT_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_GEN1_2_CNT_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_GEN1_2_CNT_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_GEN1_2_CNT_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_GEN1_2_CNT_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_GEN1_2_CNT_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_POST_EIDLE_DELAY_VALUE "cnt_200_cycles"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_POST_EIDLE_DELAY_ADDR_OFST 13
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_POST_EIDLE_DELAY_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_POST_EIDLE_DELAY_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_POST_EIDLE_DELAY_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_POST_EIDLE_DELAY_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_POST_EIDLE_DELAY_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPM_POST_EIDLE_DELAY_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPMSEL_VALUE "ppmsel_1000"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPMSEL_ADDR_OFST 14
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPMSEL_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPMSEL_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPMSEL_ADDR_FIELD_SIZE 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPMSEL_ADDR_FIELD_BITMASK 0x000000FC
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPMSEL_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PPMSEL_ADDR_FIELD_VALUE 0x20

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_PROT_MODE_VALUE "other_protocols"

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_RXVALID_MASK_VALUE "rxvalid_mask_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_RXVALID_MASK_ADDR_OFST 25
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_RXVALID_MASK_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_RXVALID_MASK_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_RXVALID_MASK_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_RXVALID_MASK_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_RXVALID_MASK_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_RXVALID_MASK_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR0_OFST 26
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR0_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR0_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR1_OFST 27
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR1_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR1_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR1_FIELD_BITMASK 0x0000000F
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_ADDR1_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_MULTI_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_MULTI_ADDR_OFST 30
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_MULTI_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_MULTI_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_MULTI_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_MULTI_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_MULTI_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIGDET_WAIT_COUNTER_MULTI_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SIM_MODE_VALUE "disable"

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SPD_CHG_RST_WAIT_CNT_EN_VALUE "false"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SPD_CHG_RST_WAIT_CNT_EN_ADDR_OFST 30
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SPD_CHG_RST_WAIT_CNT_EN_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SPD_CHG_RST_WAIT_CNT_EN_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SPD_CHG_RST_WAIT_CNT_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SPD_CHG_RST_WAIT_CNT_EN_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SPD_CHG_RST_WAIT_CNT_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SPD_CHG_RST_WAIT_CNT_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_TESTOUT_SEL_VALUE "asn_test"
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_TESTOUT_SEL_ADDR_OFST 21
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_TESTOUT_SEL_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_TESTOUT_SEL_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_TESTOUT_SEL_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_TESTOUT_SEL_ADDR_FIELD_BITMASK 0x000000F0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_TESTOUT_SEL_ADDR_FIELD_VALMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_TESTOUT_SEL_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_CLK_ON_OFF_TIMER_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_CLK_ON_OFF_TIMER_ADDR_OFST 23
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_CLK_ON_OFF_TIMER_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_CLK_ON_OFF_TIMER_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_CLK_ON_OFF_TIMER_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_CLK_ON_OFF_TIMER_ADDR_FIELD_BITMASK 0x000000F0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_CLK_ON_OFF_TIMER_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_CLK_ON_OFF_TIMER_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_PIPE_SYNCHRONIZING_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_PIPE_SYNCHRONIZING_ADDR_OFST 24
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_PIPE_SYNCHRONIZING_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_PIPE_SYNCHRONIZING_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_PIPE_SYNCHRONIZING_ADDR_FIELD_SIZE 5
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_PIPE_SYNCHRONIZING_ADDR_FIELD_BITMASK 0x0000001F
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_PIPE_SYNCHRONIZING_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_PIPE_SYNCHRONIZING_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR0_OFST 22
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR0_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR0_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR1_OFST 23
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR1_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR1_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR1_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_WAIT_SEND_SYNCP_FBKP_ADDR1_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_COMMON_PCS_PMA_INTERFACE_RECONFIG_SETTINGS_VALUE "{}"

#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_DOUBLE_READ_MODE_VALUE "double_read_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_DOUBLE_READ_MODE_ADDR_OFST 199
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_DOUBLE_READ_MODE_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_DOUBLE_READ_MODE_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_DOUBLE_READ_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_DOUBLE_READ_MODE_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_DOUBLE_READ_MODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_DOUBLE_READ_MODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_PROT_MODE_VALUE "teng_mode"
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_PROT_MODE_ADDR_OFST 199
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_PROT_MODE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_PROT_MODE_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_PROT_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_PROT_MODE_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_PROT_MODE_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_RX_PCS_PROT_MODE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_DOUBLE_WRITE_MODE_VALUE "double_write_dis"
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_DOUBLE_WRITE_MODE_ADDR_OFST 197
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_DOUBLE_WRITE_MODE_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_DOUBLE_WRITE_MODE_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_DOUBLE_WRITE_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_DOUBLE_WRITE_MODE_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_DOUBLE_WRITE_MODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_DOUBLE_WRITE_MODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_PROT_MODE_VALUE "teng_mode"
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_PROT_MODE_ADDR_OFST 197
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_PROT_MODE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_PROT_MODE_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_PROT_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_PROT_MODE_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_PROT_MODE_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_HSSI_FIFO_TX_PCS_PROT_MODE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_1S_CTLE_BYPASS_VALUE "radp_1s_ctle_bypass_1"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_1S_CTLE_BYPASS_ADDR_OFST 358
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_1S_CTLE_BYPASS_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_1S_CTLE_BYPASS_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_1S_CTLE_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_1S_CTLE_BYPASS_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_1S_CTLE_BYPASS_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_1S_CTLE_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_4S_CTLE_BYPASS_VALUE "radp_4s_ctle_bypass_1"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_4S_CTLE_BYPASS_ADDR_OFST 359
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_4S_CTLE_BYPASS_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_4S_CTLE_BYPASS_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_4S_CTLE_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_4S_CTLE_BYPASS_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_4S_CTLE_BYPASS_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_4S_CTLE_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_EN_VALUE "radp_ctle_disable"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_EN_ADDR_OFST 328
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_EN_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_EN_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_EN_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_BYPASS_VALUE "radp_dfe_fltap_bypass_1"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_BYPASS_ADDR_OFST 347
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_BYPASS_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_BYPASS_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_BYPASS_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_BYPASS_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_EN_VALUE "radp_dfe_fltap_disable"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_EN_ADDR_OFST 328
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_EN_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_EN_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_EN_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FLTAP_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_BYPASS_VALUE "radp_dfe_fxtap_bypass_1"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_BYPASS_ADDR_OFST 347
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_BYPASS_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_BYPASS_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_BYPASS_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_BYPASS_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_EN_VALUE "radp_dfe_fxtap_disable"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_EN_ADDR_OFST 328
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_EN_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_EN_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_EN_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_HOLD_EN_VALUE "radp_dfe_fxtap_not_held"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_HOLD_EN_ADDR_OFST 347
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_HOLD_EN_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_HOLD_EN_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_HOLD_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_HOLD_EN_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_HOLD_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_FXTAP_HOLD_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_MODE_VALUE "radp_dfe_mode_4"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_MODE_ADDR_OFST 333
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_MODE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_MODE_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_MODE_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_MODE_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_MODE_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_DFE_MODE_ADDR_FIELD_VALUE 0x4

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_BYPASS_VALUE "radp_vga_bypass_1"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_BYPASS_ADDR_OFST 352
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_BYPASS_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_BYPASS_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_BYPASS_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_BYPASS_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_EN_VALUE "radp_vga_disable"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_EN_ADDR_OFST 328
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_EN_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_EN_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_EN_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VGA_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_BYPASS_VALUE "radp_vref_bypass_1"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_BYPASS_ADDR_OFST 350
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_BYPASS_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_BYPASS_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_BYPASS_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_BYPASS_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_EN_VALUE "radp_vref_disable"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_EN_ADDR_OFST 328
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_EN_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_EN_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_EN_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_VREF_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_DATARATE_VALUE "10312500000 bps"

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_PROT_MODE_VALUE "basic_rx"

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_ADAPT_CYCLE_WINDOW_VALUE "radp_ctle_adapt_cycle_window_7"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_ADAPT_CYCLE_WINDOW_ADDR_OFST 355
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_ADAPT_CYCLE_WINDOW_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_ADAPT_CYCLE_WINDOW_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_ADAPT_CYCLE_WINDOW_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_ADAPT_CYCLE_WINDOW_ADDR_FIELD_BITMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_ADAPT_CYCLE_WINDOW_ADDR_FIELD_VALMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_CTLE_ADAPT_CYCLE_WINDOW_ADDR_FIELD_VALUE 0x7

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ODI_DFE_SPEC_EN_VALUE "rodi_dfe_spec_en_0"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ODI_DFE_SPEC_EN_ADDR_OFST 360
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ODI_DFE_SPEC_EN_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ODI_DFE_SPEC_EN_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ODI_DFE_SPEC_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ODI_DFE_SPEC_EN_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ODI_DFE_SPEC_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ODI_DFE_SPEC_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADAPT_MODE_VALUE "manual"

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_ONETIME_DFE_VALUE "radp_onetime_dfe_0"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_ONETIME_DFE_ADDR_OFST 331
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_ONETIME_DFE_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_ONETIME_DFE_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_ONETIME_DFE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_ONETIME_DFE_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_ONETIME_DFE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_ONETIME_DFE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_MODE_VALUE "radp_mode_8"
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_MODE_ADDR_OFST 329
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_MODE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_MODE_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_MODE_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_MODE_ADDR_FIELD_BITMASK 0x0000000F
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_MODE_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_PMA_ADAPT_ADP_MODE_ADDR_FIELD_VALUE 0x8

#define ALTERA_XCVR_NATIVE_A10_PMA_CDR_REFCLK_POWERDOWN_MODE_VALUE "powerup"

#define ALTERA_XCVR_NATIVE_A10_PMA_CDR_REFCLK_REFCLK_SELECT_VALUE "ref_iqclk0"

#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_BITSLIP_ENABLE_VALUE "disable_bitslip"
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_BITSLIP_ENABLE_ADDR_OFST 274
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_BITSLIP_ENABLE_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_BITSLIP_ENABLE_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_BITSLIP_ENABLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_BITSLIP_ENABLE_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_BITSLIP_ENABLE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_BITSLIP_ENABLE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_DATARATE_VALUE "10312500000 bps"

#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_PCIE_GEN3_BITWIDTH_VALUE "pciegen3_wide"
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_PCIE_GEN3_BITWIDTH_ADDR_OFST 281
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_PCIE_GEN3_BITWIDTH_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_PCIE_GEN3_BITWIDTH_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_PCIE_GEN3_BITWIDTH_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_PCIE_GEN3_BITWIDTH_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_PCIE_GEN3_BITWIDTH_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_PCIE_GEN3_BITWIDTH_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_PROT_MODE_VALUE "basic_tx"

#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_SER_MODE_VALUE "thirty_two_bit"
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_SER_MODE_ADDR_OFST 272
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_SER_MODE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_SER_MODE_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_SER_MODE_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_SER_MODE_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_SER_MODE_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_SER_MODE_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_X1_DIV_M_SEL_VALUE "divbypass"
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_X1_DIV_M_SEL_ADDR_OFST 281
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_X1_DIV_M_SEL_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_X1_DIV_M_SEL_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_X1_DIV_M_SEL_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_X1_DIV_M_SEL_ADDR_FIELD_BITMASK 0x0000000C
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_X1_DIV_M_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_X1_DIV_M_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_INPUT_SELECT_X1_VALUE "fpll_bot"

#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_INPUT_SELECT_GEN3_VALUE "unused"

#define ALTERA_XCVR_NATIVE_A10_PMA_CGB_INPUT_SELECT_XN_VALUE "unused"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_DATARATE_VALUE "10312500000 bps"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_DFT_EN_VALUE "dft_disable"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_DFT_EN_ADDR_OFST 292
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_DFT_EN_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_DFT_EN_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_DFT_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_DFT_EN_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_DFT_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_DFT_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_VALUE "dfe_enable"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_ADDR_OFST 291
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FIXEDTAP_VALUE "fixtap_dfe_powerdown"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FIXEDTAP_ADDR_OFST 291
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FIXEDTAP_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FIXEDTAP_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FIXEDTAP_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FIXEDTAP_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FIXEDTAP_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FIXEDTAP_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FLOATTAP_VALUE "floattap_dfe_powerdown"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FLOATTAP_ADDR_OFST 291
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FLOATTAP_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FLOATTAP_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FLOATTAP_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FLOATTAP_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FLOATTAP_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FLOATTAP_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FXTAP4T7_VALUE "fxtap4t7_powerdown"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FXTAP4T7_ADDR_OFST 291
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FXTAP4T7_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FXTAP4T7_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FXTAP4T7_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FXTAP4T7_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FXTAP4T7_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PDB_FXTAP4T7_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DFE_PROT_MODE_VALUE "basic_rx"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_DATARATE_VALUE "10312500000 bps"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_VALUE "dprio_mode"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_OFST 324
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_FIELD0_OFST 4
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_FIELD0_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_FIELD0_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_FIELD0_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_FIELD0_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_FIELD0_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_FIELD1_OFST 6
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_FIELD1_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_FIELD1_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_FIELD1_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_FIELD1_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_STEP_CTRL_SEL_ADDR_FIELD1_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_ODI_PROT_MODE_VALUE "basic_rx"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_BYPASS_EQZ_STAGES_234_VALUE "bypass_off"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_BYPASS_EQZ_STAGES_234_ADDR_OFST 287
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_BYPASS_EQZ_STAGES_234_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_BYPASS_EQZ_STAGES_234_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_BYPASS_EQZ_STAGES_234_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_BYPASS_EQZ_STAGES_234_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_BYPASS_EQZ_STAGES_234_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_BYPASS_EQZ_STAGES_234_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_DATARATE_VALUE "10312500000 bps"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_DIAG_LP_EN_VALUE "dlp_off"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_DIAG_LP_EN_ADDR_OFST 285
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_DIAG_LP_EN_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_DIAG_LP_EN_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_DIAG_LP_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_DIAG_LP_EN_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_DIAG_LP_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_DIAG_LP_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PROT_MODE_VALUE "basic_rx"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_QPI_ENABLE_VALUE "non_qpi_mode"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_QPI_ENABLE_ADDR_OFST 283
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_QPI_ENABLE_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_QPI_ENABLE_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_QPI_ENABLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_QPI_ENABLE_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_QPI_ENABLE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_QPI_ENABLE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_RX_REFCLK_DIVIDER_VALUE "bypass_divider"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_RX_REFCLK_DIVIDER_ADDR_OFST 285
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_RX_REFCLK_DIVIDER_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_RX_REFCLK_DIVIDER_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_RX_REFCLK_DIVIDER_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_RX_REFCLK_DIVIDER_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_RX_REFCLK_DIVIDER_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_RX_REFCLK_DIVIDER_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_LOOPBACK_MODES_VALUE "lpbk_disable"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_REFCLK_EN_VALUE "disable"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_REFCLK_EN_ADDR_OFST 285
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_REFCLK_EN_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_REFCLK_EN_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_REFCLK_EN_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_REFCLK_EN_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_REFCLK_EN_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_REFCLK_EN_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_VALUE "non_pcie"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR0_OFST 281
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR0_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR0_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR0_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR1_OFST 368
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR1_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR1_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR1_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_ADDR1_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_BITWIDTH_VALUE "pcie_gen3_32b"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_BITWIDTH_ADDR_OFST 281
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_BITWIDTH_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_BITWIDTH_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_BITWIDTH_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_BITWIDTH_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_BITWIDTH_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_PCIE_GEN_BITWIDTH_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_CVP_MODE_VALUE "cvp_off"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_CVP_MODE_ADDR_OFST 369
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_CVP_MODE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_CVP_MODE_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_CVP_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_CVP_MODE_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_CVP_MODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_PM_TX_RX_CVP_MODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_XRX_PATH_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_XRX_PATH_PROT_MODE_VALUE "basic_rx"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_XRX_PATH_DATARATE_VALUE "10312500000 bps"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_XRX_PATH_DATAWIDTH_VALUE 32

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_BUF_XRX_PATH_PMA_RX_DIVCLK_HZ_VALUE "322265625"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_PROT_MODE_VALUE "basic_rx"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_VALUE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR0_OFST 371
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR0_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR0_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR0_FIELD_BITMASK 0x000000F0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR0_FIELD_VALMASK 0x00000030
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR0_FIELD_VALUE 0x3
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR1_OFST 372
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR1_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR1_FIELD_SIZE 5
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR1_FIELD_BITMASK 0x0000001F
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR1_FIELD_VALMASK 0x0000000C
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_OFF_ADDR1_FIELD_VALUE 0xC

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_VALUE 15
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR0_OFST 371
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR0_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR0_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR0_FIELD_BITMASK 0x0000000F
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR0_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR0_FIELD_VALUE 0x1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR1_OFST 373
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR1_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR1_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR1_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR1_FIELD_VALMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_OUTPUT_ON_ADDR1_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_PDB_VALUE "sd_off"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_PDB_ADDR_OFST 373
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_PDB_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_PDB_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_PDB_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_PDB_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_PDB_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SD_PDB_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_SD_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_SER_SER_CLK_DIVTX_USER_SEL_VALUE "divtx_user_2"
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_SER_SER_CLK_DIVTX_USER_SEL_ADDR_OFST 272
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_SER_SER_CLK_DIVTX_USER_SEL_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_SER_SER_CLK_DIVTX_USER_SEL_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_SER_SER_CLK_DIVTX_USER_SEL_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_SER_SER_CLK_DIVTX_USER_SEL_ADDR_FIELD_BITMASK 0x00000038
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_SER_SER_CLK_DIVTX_USER_SEL_ADDR_FIELD_VALMASK 0x00000018
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_SER_SER_CLK_DIVTX_USER_SEL_ADDR_FIELD_VALUE 0x3

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_SER_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_SER_PROT_MODE_VALUE "basic_tx"

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_DATARATE_VALUE "10312500000 bps"

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_PROT_MODE_VALUE "basic_tx"

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_VALUE "mode_0"
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_ADDR_OFST 269
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_ADDR_FIELD_BITMASK 0x00000078
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_OUTPUT_SEL_VALUE "rx_det_pcie_out"
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_OUTPUT_SEL_ADDR_OFST 269
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_OUTPUT_SEL_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_OUTPUT_SEL_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_OUTPUT_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_OUTPUT_SEL_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_OUTPUT_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_OUTPUT_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_PDB_VALUE "rx_det_off"
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_PDB_ADDR_OFST 269
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_PDB_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_PDB_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_PDB_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_PDB_ADDR_FIELD_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_PDB_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_RX_DET_PDB_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_USER_FIR_COEFF_CTRL_SEL_VALUE "ram_ctl"
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_USER_FIR_COEFF_CTRL_SEL_ADDR_OFST 261
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_USER_FIR_COEFF_CTRL_SEL_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_USER_FIR_COEFF_CTRL_SEL_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_USER_FIR_COEFF_CTRL_SEL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_USER_FIR_COEFF_CTRL_SEL_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_USER_FIR_COEFF_CTRL_SEL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_USER_FIR_COEFF_CTRL_SEL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_XTX_PATH_PROT_MODE_VALUE "basic_tx"

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_XTX_PATH_DATARATE_VALUE "10312500000 bps"

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_XTX_PATH_DATAWIDTH_VALUE 32

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_XTX_PATH_CLOCK_DIVIDER_RATIO_VALUE 1

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_XTX_PATH_PMA_TX_DIVCLK_HZ_VALUE "322265625"

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_XTX_PATH_TX_PLL_CLK_HZ_VALUE "5156250000"

#define ALTERA_XCVR_NATIVE_A10_PMA_TX_BUF_XTX_PATH_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PMA_WIDTH_VALUE 32

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CGB_DIV_VALUE 1

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_IS_CASCADED_PLL_VALUE "false"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_DATARATE_VALUE "10312500000 bps"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LPD_COUNTER_VALUE 1

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LPFD_COUNTER_VALUE 1

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_N_COUNTER_SCRATCH_VALUE 2

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_OUTPUT_CLOCK_FREQUENCY_VALUE "5156250000 Hz"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REFERENCE_CLOCK_FREQUENCY_VALUE "644531250 hz"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_VALUE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_ADDR_OFST 311
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_ADDR_FIELD_SIZE 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_ADDR_FIELD_BITMASK 0x0000007C
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_ADDR_FIELD_VALMASK 0x0000000C
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_ADDR_FIELD_VALUE 0x3

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_VALUE 60
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_OFST 306
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_FIELD0_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_FIELD0_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_FIELD0_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_FIELD0_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_FIELD0_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_FIELD0_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_FIELD1_OFST 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_FIELD1_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_FIELD1_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_FIELD1_BITMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_FIELD1_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR0_FIELD1_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR1_OFST 308
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR1_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR1_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR1_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR1_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR1_FIELD_VALUE 0x1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR2_OFST 309
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR2_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR2_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR2_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR2_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR2_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR2_FIELD_VALUE 0x1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR3_OFST 310
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR3_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR3_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR3_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR3_FIELD_BITMASK 0x0000000F
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR3_FIELD_VALMASK 0x0000000C
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_FIX_ADDR3_FIELD_VALUE 0xC

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_FREQ_VALUE "5156250000 Hz"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_VALUE "atb_off"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR0_OFST 317
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR0_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR0_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR0_FIELD_BITMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR1_OFST 318
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR1_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR1_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR1_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR1_FIELD_BITMASK 0x00000078
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_ATB_SELECT_CONTROL_ADDR1_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_AUTO_RESET_ON_VALUE "auto_reset_off"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_AUTO_RESET_ON_ADDR_OFST 312
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_AUTO_RESET_ON_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_AUTO_RESET_ON_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_AUTO_RESET_ON_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_AUTO_RESET_ON_ADDR_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_AUTO_RESET_ON_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_AUTO_RESET_ON_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_BBPD_DATA_PATTERN_FILTER_SELECT_VALUE "bbpd_data_pat_off"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_BBPD_DATA_PATTERN_FILTER_SELECT_ADDR_OFST 308
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_BBPD_DATA_PATTERN_FILTER_SELECT_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_BBPD_DATA_PATTERN_FILTER_SELECT_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_BBPD_DATA_PATTERN_FILTER_SELECT_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_BBPD_DATA_PATTERN_FILTER_SELECT_ADDR_FIELD_BITMASK 0x00000030
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_BBPD_DATA_PATTERN_FILTER_SELECT_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_BBPD_DATA_PATTERN_FILTER_SELECT_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_BW_SEL_VALUE "medium"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_ODI_SELECT_VALUE "sel_cdr"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_ODI_SELECT_ADDR_OFST 312
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_ODI_SELECT_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_ODI_SELECT_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_ODI_SELECT_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_ODI_SELECT_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_ODI_SELECT_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_ODI_SELECT_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_PHASELOCK_MODE_VALUE "no_ignore_lock"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_PHASELOCK_MODE_ADDR_OFST 307
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_PHASELOCK_MODE_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_PHASELOCK_MODE_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_PHASELOCK_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_PHASELOCK_MODE_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_PHASELOCK_MODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_PHASELOCK_MODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_POWERDOWN_MODE_VALUE "power_up"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_POWERDOWN_MODE_ADDR_OFST 306
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_POWERDOWN_MODE_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_POWERDOWN_MODE_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_POWERDOWN_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_POWERDOWN_MODE_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_POWERDOWN_MODE_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CDR_POWERDOWN_MODE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_PD_VALUE "cp_current_pd_setting0"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_PFD_VALUE "cp_current_pfd_setting2"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_PFD_ADDR_OFST 313
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_PFD_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_PFD_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_PFD_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_PFD_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_PFD_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_PFD_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_REPLICATE_VALUE "false"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_REPLICATE_ADDR_OFST 313
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_REPLICATE_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_REPLICATE_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_REPLICATE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_REPLICATE_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_REPLICATE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_REPLICATE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_TESTMODE_VALUE "cp_test_disable"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_TESTMODE_ADDR_OFST 318
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_TESTMODE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_TESTMODE_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_TESTMODE_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_TESTMODE_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_TESTMODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_TESTMODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CLKLOW_MUX_SELECT_VALUE "clklow_mux_cdr_fbclk"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CLKLOW_MUX_SELECT_ADDR_OFST 317
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CLKLOW_MUX_SELECT_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CLKLOW_MUX_SELECT_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CLKLOW_MUX_SELECT_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CLKLOW_MUX_SELECT_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CLKLOW_MUX_SELECT_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CLKLOW_MUX_SELECT_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_DIAG_LOOPBACK_ENABLE_VALUE "false"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_DIAG_LOOPBACK_ENABLE_ADDR_OFST 311
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_DIAG_LOOPBACK_ENABLE_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_DIAG_LOOPBACK_ENABLE_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_DIAG_LOOPBACK_ENABLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_DIAG_LOOPBACK_ENABLE_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_DIAG_LOOPBACK_ENABLE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_DIAG_LOOPBACK_ENABLE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_DISABLE_UP_DN_VALUE "true"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_CLKLOW_DIV_VALUE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_CLKLOW_DIV_ADDR_OFST 314
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_CLKLOW_DIV_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_CLKLOW_DIV_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_CLKLOW_DIV_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_CLKLOW_DIV_ADDR_FIELD_BITMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_CLKLOW_DIV_ADDR_FIELD_VALMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_CLKLOW_DIV_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_MUX_SELECT_VALUE "fref_mux_cdr_refclk"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_MUX_SELECT_ADDR_OFST 317
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_MUX_SELECT_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_MUX_SELECT_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_MUX_SELECT_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_MUX_SELECT_ADDR_FIELD_BITMASK 0x00000038
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_MUX_SELECT_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FREF_MUX_SELECT_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_GPON_LCK2REF_CONTROL_VALUE "gpon_lck2ref_off"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_GPON_LCK2REF_CONTROL_ADDR_OFST 307
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_GPON_LCK2REF_CONTROL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_GPON_LCK2REF_CONTROL_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_GPON_LCK2REF_CONTROL_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_GPON_LCK2REF_CONTROL_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_GPON_LCK2REF_CONTROL_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_GPON_LCK2REF_CONTROL_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_INITIAL_SETTINGS_VALUE "true"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LCK2REF_DELAY_CONTROL_VALUE "lck2ref_delay_2"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LCK2REF_DELAY_CONTROL_ADDR_OFST 308
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LCK2REF_DELAY_CONTROL_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LCK2REF_DELAY_CONTROL_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LCK2REF_DELAY_CONTROL_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LCK2REF_DELAY_CONTROL_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LCK2REF_DELAY_CONTROL_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LCK2REF_DELAY_CONTROL_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PD_VALUE "lf_pd_setting2"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PD_ADDR_OFST 309
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PD_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PD_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PD_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PD_ADDR_FIELD_BITMASK 0x0000000C
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PD_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PD_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PFD_VALUE "lf_pfd_setting2"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PFD_ADDR_OFST 309
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PFD_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PFD_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PFD_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PFD_ADDR_FIELD_BITMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PFD_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RESISTOR_PFD_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RIPPLE_CAP_VALUE "lf_no_ripple"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RIPPLE_CAP_ADDR_OFST 309
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RIPPLE_CAP_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RIPPLE_CAP_ADDR_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RIPPLE_CAP_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RIPPLE_CAP_ADDR_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RIPPLE_CAP_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LF_RIPPLE_CAP_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOP_FILTER_BIAS_SELECT_VALUE "lpflt_bias_7"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOP_FILTER_BIAS_SELECT_ADDR_OFST 322
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOP_FILTER_BIAS_SELECT_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOP_FILTER_BIAS_SELECT_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOP_FILTER_BIAS_SELECT_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOP_FILTER_BIAS_SELECT_ADDR_FIELD_BITMASK 0x0000000E
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOP_FILTER_BIAS_SELECT_ADDR_FIELD_VALMASK 0x0000000E
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOP_FILTER_BIAS_SELECT_ADDR_FIELD_VALUE 0x7

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_VALUE "loopback_disabled"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR0_OFST 285
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR0_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR0_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR0_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR1_OFST 316
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR1_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR1_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR1_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR1_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR2_OFST 322
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR2_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR2_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR2_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR2_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR2_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_LOOPBACK_MODE_ADDR2_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_M_COUNTER_VALUE 16
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_M_COUNTER_ADDR_OFST 315
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_M_COUNTER_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_M_COUNTER_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_M_COUNTER_ADDR_FIELD_SIZE 8
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_M_COUNTER_ADDR_FIELD_BITMASK 0x000000FF
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_M_COUNTER_ADDR_FIELD_VALMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_M_COUNTER_ADDR_FIELD_VALUE 0x10

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_N_COUNTER_VALUE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_N_COUNTER_ADDR_OFST 316
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_N_COUNTER_ADDR_FIELD_OFST 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_N_COUNTER_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_N_COUNTER_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_N_COUNTER_ADDR_FIELD_BITMASK 0x0000000C
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_N_COUNTER_ADDR_FIELD_VALMASK 0x00000004
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_N_COUNTER_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_FASTLOCK_MODE_VALUE "false"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_FASTLOCK_MODE_ADDR_OFST 313
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_FASTLOCK_MODE_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_FASTLOCK_MODE_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_FASTLOCK_MODE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_FASTLOCK_MODE_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_FASTLOCK_MODE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_FASTLOCK_MODE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_L_COUNTER_VALUE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_L_COUNTER_ADDR_OFST 314
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_L_COUNTER_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_L_COUNTER_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_L_COUNTER_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_L_COUNTER_ADDR_FIELD_BITMASK 0x00000038
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_L_COUNTER_ADDR_FIELD_VALMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PD_L_COUNTER_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PFD_L_COUNTER_VALUE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PFD_L_COUNTER_ADDR_OFST 314
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PFD_L_COUNTER_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PFD_L_COUNTER_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PFD_L_COUNTER_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PFD_L_COUNTER_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PFD_L_COUNTER_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PFD_L_COUNTER_ADDR_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PRIMARY_USE_VALUE "cdr"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PROT_MODE_VALUE "basic_rx"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_VALUE "no_loopback"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR0_OFST 306
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR0_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR0_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR0_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR0_FIELD_BITMASK 0x00000030
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR0_FIELD_VALMASK 0x00000030
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR0_FIELD_VALUE 0x3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR1_OFST 316
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR1_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR1_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR1_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_REVERSE_SERIAL_LOOPBACK_ADDR1_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_V2I_ENABLE_VALUE "true"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_V2I_ENABLE_ADDR_OFST 311
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_V2I_ENABLE_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_V2I_ENABLE_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_V2I_ENABLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_V2I_ENABLE_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_V2I_ENABLE_ADDR_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_V2I_ENABLE_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_RESET_VALUE "false"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_RESET_ADDR_OFST 311
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_RESET_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_RESET_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_RESET_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_RESET_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_RESET_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_RESET_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_VALUE "cdr_vco_max_speedbin_pciegen3"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR0_OFST 306
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR0_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR0_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR0_FIELD_BITMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR0_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR0_FIELD_VALUE 0x2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR1_OFST 312
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR1_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR1_FIELD_SIZE 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR1_FIELD_BITMASK 0x0000001F
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR1_FIELD_VALMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR1_FIELD_VALUE 0x2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR2_OFST 316
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR2_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR2_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR2_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR2_FIELD_BITMASK 0x00000070
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR2_FIELD_VALMASK 0x00000070
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR2_FIELD_VALUE 0x7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR3_OFST 370
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR3_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR3_FIELD_HIGH 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR3_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR3_FIELD_BITMASK 0x00000010
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR3_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR3_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR4_OFST 373
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR4_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR4_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR4_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR4_FIELD_BITMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR4_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_VCO_SPEED_PCIEGEN3_ADDR4_FIELD_VALUE 0x2

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TX_PLL_PROT_MODE_VALUE "txpll_unused"

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_VALUE "false"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR0_OFST 308
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR0_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR0_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR0_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR0_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR0_FIELD_VALUE 0x1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR1_OFST 309
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR1_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR1_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR1_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_TXPLL_HCLK_DRIVER_ENABLE_ADDR1_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_OVERRANGE_VOLTAGE_VALUE "vco_overrange_off"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_OVERRANGE_VOLTAGE_ADDR_OFST 310
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_OVERRANGE_VOLTAGE_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_OVERRANGE_VOLTAGE_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_OVERRANGE_VOLTAGE_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_OVERRANGE_VOLTAGE_ADDR_FIELD_BITMASK 0x00000030
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_OVERRANGE_VOLTAGE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_OVERRANGE_VOLTAGE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_UNDERRANGE_VOLTAGE_VALUE "vco_underange_off"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_UNDERRANGE_VOLTAGE_ADDR_OFST 310
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_UNDERRANGE_VOLTAGE_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_UNDERRANGE_VOLTAGE_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_UNDERRANGE_VOLTAGE_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_UNDERRANGE_VOLTAGE_ADDR_FIELD_BITMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_UNDERRANGE_VOLTAGE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_VCO_UNDERRANGE_VOLTAGE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FB_SELECT_VALUE "direct_fb"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FB_SELECT_ADDR_OFST 312
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FB_SELECT_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FB_SELECT_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FB_SELECT_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FB_SELECT_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FB_SELECT_ADDR_FIELD_VALMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_FB_SELECT_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_VALUE "non_pcie"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR0_OFST 281
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR0_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR0_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR0_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR1_OFST 368
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR1_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR1_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR1_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_PCIE_GEN_ADDR1_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_VALUE 0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR0_OFST 335
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR0_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR0_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR0_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR0_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR1_OFST 338
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR1_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR1_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR1_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR1_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR2_OFST 339
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR2_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR2_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR2_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR2_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR2_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR2_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR3_OFST 340
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR3_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR3_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR3_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR3_FIELD_BITMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR3_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR3_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR4_OFST 341
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR4_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR4_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR4_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR4_FIELD_BITMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR4_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR4_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR5_OFST 342
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR5_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR5_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR5_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR5_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR5_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_SET_CDR_INPUT_FREQ_RANGE_ADDR5_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_TRIM_VALUE "cp_current_trimming_dn_setting0"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_TRIM_ADDR_OFST 368
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_TRIM_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_TRIM_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_TRIM_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_TRIM_ADDR_FIELD_BITMASK 0x000000F0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_TRIM_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_TRIM_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_UP_PD_TRIM_DOUBLE_VALUE "normal_up_trim_current"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_UP_PD_TRIM_DOUBLE_ADDR_OFST 367
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_UP_PD_TRIM_DOUBLE_ADDR_FIELD_OFST 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_UP_PD_TRIM_DOUBLE_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_UP_PD_TRIM_DOUBLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_UP_PD_TRIM_DOUBLE_ADDR_FIELD_BITMASK 0x00000080
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_UP_PD_TRIM_DOUBLE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_UP_PD_TRIM_DOUBLE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_PD_VALUE "cp_current_pd_up_setting3"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_PD_ADDR_OFST 307
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_PD_ADDR_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_PD_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_PD_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_PD_ADDR_FIELD_BITMASK 0x000000E0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_PD_ADDR_FIELD_VALMASK 0x00000060
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_PD_ADDR_FIELD_VALUE 0x3

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_VALUE "cp_current_trimming_up_setting0"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR0_OFST 309
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR0_FIELD_OFST 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR0_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR0_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR0_FIELD_BITMASK 0x00000020
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR1_OFST 368
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR1_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR1_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR1_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR1_FIELD_BITMASK 0x0000000E
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR1_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_UP_TRIM_ADDR1_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_DN_PD_TRIM_DOUBLE_VALUE "normal_dn_trim_current"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_DN_PD_TRIM_DOUBLE_ADDR_OFST 367
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_DN_PD_TRIM_DOUBLE_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_DN_PD_TRIM_DOUBLE_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_DN_PD_TRIM_DOUBLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_DN_PD_TRIM_DOUBLE_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_DN_PD_TRIM_DOUBLE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_DN_PD_TRIM_DOUBLE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CAL_VCO_COUNT_LENGTH_VALUE "sel_8b_count"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CAL_VCO_COUNT_LENGTH_ADDR_OFST 324
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CAL_VCO_COUNT_LENGTH_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CAL_VCO_COUNT_LENGTH_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CAL_VCO_COUNT_LENGTH_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CAL_VCO_COUNT_LENGTH_ADDR_FIELD_BITMASK 0x00000008
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CAL_VCO_COUNT_LENGTH_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CAL_VCO_COUNT_LENGTH_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_PD_VALUE "cp_current_pd_dn_setting3"
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_PD_ADDR_OFST 313
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_PD_ADDR_FIELD_OFST 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_PD_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_PD_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_PD_ADDR_FIELD_BITMASK 0x00000038
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_PD_ADDR_FIELD_VALMASK 0x00000018
#define ALTERA_XCVR_NATIVE_A10_CDR_PLL_CHGPMP_CURRENT_DN_PD_ADDR_FIELD_VALUE 0x3

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIV_SOURCE_VALUE "vco_bypass_normal"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIV_SOURCE_ADDR_OFST 319
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIV_SOURCE_ADDR_FIELD_OFST 4
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIV_SOURCE_ADDR_FIELD_HIGH 5
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIV_SOURCE_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIV_SOURCE_ADDR_FIELD_BITMASK 0x00000030
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIV_SOURCE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIV_SOURCE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIVRX_USER_MODE_VALUE "clkdivrx_user_clkdiv_div2"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIVRX_USER_MODE_ADDR_OFST 320
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIVRX_USER_MODE_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIVRX_USER_MODE_ADDR_FIELD_HIGH 2
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIVRX_USER_MODE_ADDR_FIELD_SIZE 3
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIVRX_USER_MODE_ADDR_FIELD_BITMASK 0x00000007
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIVRX_USER_MODE_ADDR_FIELD_VALMASK 0x00000003
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_CLKDIVRX_USER_MODE_ADDR_FIELD_VALUE 0x3

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_DATARATE_VALUE "10312500000 bps"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_DESER_FACTOR_VALUE 32
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_DESER_FACTOR_ADDR_OFST 319
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_DESER_FACTOR_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_DESER_FACTOR_ADDR_FIELD_HIGH 3
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_DESER_FACTOR_ADDR_FIELD_SIZE 4
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_DESER_FACTOR_ADDR_FIELD_BITMASK 0x0000000F
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_DESER_FACTOR_ADDR_FIELD_VALMASK 0x00000006
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_DESER_FACTOR_ADDR_FIELD_VALUE 0x6

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_FORCE_CLKDIV_FOR_TESTING_VALUE "normal_clkdiv"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_FORCE_CLKDIV_FOR_TESTING_ADDR_OFST 320
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_FORCE_CLKDIV_FOR_TESTING_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_FORCE_CLKDIV_FOR_TESTING_ADDR_FIELD_HIGH 7
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_FORCE_CLKDIV_FOR_TESTING_ADDR_FIELD_SIZE 2
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_FORCE_CLKDIV_FOR_TESTING_ADDR_FIELD_BITMASK 0x000000C0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_FORCE_CLKDIV_FOR_TESTING_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_FORCE_CLKDIV_FOR_TESTING_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_SDCLK_ENABLE_VALUE "false"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_SDCLK_ENABLE_ADDR_OFST 319
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_SDCLK_ENABLE_ADDR_FIELD_OFST 6
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_SDCLK_ENABLE_ADDR_FIELD_HIGH 6
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_SDCLK_ENABLE_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_SDCLK_ENABLE_ADDR_FIELD_BITMASK 0x00000040
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_SDCLK_ENABLE_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_SDCLK_ENABLE_ADDR_FIELD_VALUE 0x0

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_SUP_MODE_VALUE "user_mode"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_RST_N_ADAPT_ODI_VALUE "no_rst_adapt_odi"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_RST_N_ADAPT_ODI_ADDR_OFST 316
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_RST_N_ADAPT_ODI_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_RST_N_ADAPT_ODI_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_RST_N_ADAPT_ODI_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_RST_N_ADAPT_ODI_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_RST_N_ADAPT_ODI_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_RST_N_ADAPT_ODI_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_BITSLIP_BYPASS_VALUE "bs_bypass_yes"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_BITSLIP_BYPASS_ADDR_OFST 322
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_BITSLIP_BYPASS_ADDR_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_BITSLIP_BYPASS_ADDR_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_BITSLIP_BYPASS_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_BITSLIP_BYPASS_ADDR_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_BITSLIP_BYPASS_ADDR_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_BITSLIP_BYPASS_ADDR_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PROT_MODE_VALUE "basic_rx"

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_VALUE "non_pcie"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR0_OFST 281
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR0_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR0_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR0_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR0_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR0_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR0_FIELD_VALUE 0x0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR1_OFST 368
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR1_FIELD_OFST 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR1_FIELD_HIGH 0
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR1_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR1_FIELD_BITMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR1_FIELD_VALMASK 0x00000001
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_ADDR1_FIELD_VALUE 0x1

#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_BITWIDTH_VALUE "pcie_gen3_32b"
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_BITWIDTH_ADDR_OFST 281
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_BITWIDTH_ADDR_FIELD_OFST 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_BITWIDTH_ADDR_FIELD_HIGH 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_BITWIDTH_ADDR_FIELD_SIZE 1
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_BITWIDTH_ADDR_FIELD_BITMASK 0x00000002
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_BITWIDTH_ADDR_FIELD_VALMASK 0x00000000
#define ALTERA_XCVR_NATIVE_A10_PMA_RX_DESER_PCIE_GEN_BITWIDTH_ADDR_FIELD_VALUE 0x0

#endif //__ALTERA_XCVR_NATIVE_A10_RECONFIG_PARAMETERS_H__
