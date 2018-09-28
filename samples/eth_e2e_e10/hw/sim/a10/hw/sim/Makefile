AFU_DIR := ../rtl
SIM_DIR := .
DEFINES := +define+E2E_E10
INC_DIRS := +incdir+$(SIM_DIR)/include
VLOG_ARGS := -sv $(DEFINES) $(INC_DIRS)
VSIM_ARGS := -do "run -all" -c -suppress 3016
VSIM_ARGS_DEBUG := -do "log -r *;run -all" -gui -novopt -suppress 3016
MSIM_LIBS := -L $(SIM_DIR)/libs/altera_eth_10g_mac \
	-L $(SIM_DIR)/libs/alt_em10g32_170  \
	-L $(SIM_DIR)/libs/reset_control \
	-L $(SIM_DIR)/libs/altera_xcvr_reset_control_170 \
	-L $(SIM_DIR)/libs/altera_avalon_dc_fifo_170 \
	-L $(SIM_DIR)/libs/dc_fifo_0 \
	-L $(SIM_DIR)/libs/dc_fifo \
	-L $(SIM_DIR)/libs/altera_avalon_sc_fifo_170 \
	-L $(SIM_DIR)/libs/sc_fifo \
	-L $(SIM_DIR)/libs/altera_iopll_170 \
	-L $(SIM_DIR)/libs/pll \
	-L $(SIM_DIR)/libs/altera_merlin_slave_translator_170 \
	-L $(SIM_DIR)/libs/altera_merlin_master_translator_170 \
	-L $(SIM_DIR)/libs/altera_merlin_master_agent_170 \
	-L $(SIM_DIR)/libs/altera_merlin_slave_agent_170 \
	-L $(SIM_DIR)/libs/altera_avalon_sc_fifo_170 \
	-L $(SIM_DIR)/libs/altera_merlin_router_170 \
	-L $(SIM_DIR)/libs/altera_merlin_traffic_limiter_170 \
	-L $(SIM_DIR)/libs/altera_merlin_burst_adapter_170 \
	-L $(SIM_DIR)/libs/altera_merlin_demultiplexer_170 \
	-L $(SIM_DIR)/libs/altera_merlin_multiplexer_170 \
	-L $(SIM_DIR)/libs/altera_avalon_st_handshake_clock_crosser_170 \
	-L $(SIM_DIR)/libs/error_adapter_170 \
	-L $(SIM_DIR)/libs/altera_avalon_st_adapter_170 \
	-L $(SIM_DIR)/libs/altera_mm_interconnect_170 \
	-L $(SIM_DIR)/libs/altera_reset_controller_170 \
	-L $(SIM_DIR)/libs/address_decode \
	-L $(SIM_DIR)/intellibs/lpm_ver \
	-L $(SIM_DIR)/intellibs/altera_ver \
	-L $(SIM_DIR)/intellibs/sgate_ver \
	-L $(SIM_DIR)/intellibs/altera_lnsim_ver \
	-L $(SIM_DIR)/intellibs/altera_mf_ver \
	-L $(SIM_DIR)/intellibs/twentynm_ver \
	-L $(SIM_DIR)/intellibs/twentynm_hip_ver \
	-L $(SIM_DIR)/intellibs/twentynm_hssi_ver

default: clean sim

debug: clean sim_debug

$(SIM_DIR)/libs:
	mkdir $(SIM_DIR)/libs
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_slave_translator_170/sim/altera_merlin_slave_translator.sv                                 -work $(SIM_DIR)/libs/altera_merlin_slave_translator_170          
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_master_translator_170/sim/altera_merlin_master_translator.sv                               -work $(SIM_DIR)/libs/altera_merlin_master_translator_170         
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_master_agent_170/sim/altera_merlin_master_agent.sv                                         -work $(SIM_DIR)/libs/altera_merlin_master_agent_170              
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_slave_agent_170/sim/altera_merlin_slave_agent.sv                                           -work $(SIM_DIR)/libs/altera_merlin_slave_agent_170               
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_slave_agent_170/sim/altera_merlin_burst_uncompressor.sv                                    -work $(SIM_DIR)/libs/altera_merlin_slave_agent_170               
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_avalon_sc_fifo_170/sim/altera_avalon_sc_fifo.v                                                    -work $(SIM_DIR)/libs/altera_avalon_sc_fifo_170                   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_router_170/sim/address_decode_altera_merlin_router_170_tziitua.sv                          -work $(SIM_DIR)/libs/altera_merlin_router_170                    
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_router_170/sim/address_decode_altera_merlin_router_170_5dqbt4y.sv                          -work $(SIM_DIR)/libs/altera_merlin_router_170                    
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_traffic_limiter_170/sim/altera_merlin_traffic_limiter.sv                                   -work $(SIM_DIR)/libs/altera_merlin_traffic_limiter_170           
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_traffic_limiter_170/sim/altera_merlin_reorder_memory.sv                                    -work $(SIM_DIR)/libs/altera_merlin_traffic_limiter_170           
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_traffic_limiter_170/sim/altera_avalon_sc_fifo.v                                            -work $(SIM_DIR)/libs/altera_merlin_traffic_limiter_170           
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_traffic_limiter_170/sim/altera_avalon_st_pipeline_base.v                                   -work $(SIM_DIR)/libs/altera_merlin_traffic_limiter_170           
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_burst_adapter_170/sim/altera_merlin_burst_adapter.sv                                       -work $(SIM_DIR)/libs/altera_merlin_burst_adapter_170             
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_burst_adapter_170/sim/altera_merlin_burst_adapter_uncmpr.sv                                -work $(SIM_DIR)/libs/altera_merlin_burst_adapter_170             
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_burst_adapter_170/sim/altera_merlin_burst_adapter_13_1.sv                                  -work $(SIM_DIR)/libs/altera_merlin_burst_adapter_170             
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_burst_adapter_170/sim/altera_merlin_burst_adapter_new.sv                                   -work $(SIM_DIR)/libs/altera_merlin_burst_adapter_170             
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_burst_adapter_170/sim/altera_incr_burst_converter.sv                                       -work $(SIM_DIR)/libs/altera_merlin_burst_adapter_170             
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_burst_adapter_170/sim/altera_wrap_burst_converter.sv                                       -work $(SIM_DIR)/libs/altera_merlin_burst_adapter_170             
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_burst_adapter_170/sim/altera_default_burst_converter.sv                                    -work $(SIM_DIR)/libs/altera_merlin_burst_adapter_170             
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_burst_adapter_170/sim/altera_merlin_address_alignment.sv                                   -work $(SIM_DIR)/libs/altera_merlin_burst_adapter_170             
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_burst_adapter_170/sim/altera_avalon_st_pipeline_stage.sv                                   -work $(SIM_DIR)/libs/altera_merlin_burst_adapter_170             
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_burst_adapter_170/sim/altera_avalon_st_pipeline_base.v                                     -work $(SIM_DIR)/libs/altera_merlin_burst_adapter_170             
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_demultiplexer_170/sim/address_decode_altera_merlin_demultiplexer_170_hxcg55y.sv            -work $(SIM_DIR)/libs/altera_merlin_demultiplexer_170             
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_multiplexer_170/sim/address_decode_altera_merlin_multiplexer_170_4o2qzii.sv                -work $(SIM_DIR)/libs/altera_merlin_multiplexer_170               
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_multiplexer_170/sim/altera_merlin_arbitrator.sv                                            -work $(SIM_DIR)/libs/altera_merlin_multiplexer_170               
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_demultiplexer_170/sim/address_decode_altera_merlin_demultiplexer_170_jvvh5ma.sv            -work $(SIM_DIR)/libs/altera_merlin_demultiplexer_170             
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_multiplexer_170/sim/address_decode_altera_merlin_multiplexer_170_or75vma.sv                -work $(SIM_DIR)/libs/altera_merlin_multiplexer_170               
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_merlin_multiplexer_170/sim/altera_merlin_arbitrator.sv                                            -work $(SIM_DIR)/libs/altera_merlin_multiplexer_170               
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_avalon_st_handshake_clock_crosser_170/sim/altera_avalon_st_handshake_clock_crosser.v              -work $(SIM_DIR)/libs/altera_avalon_st_handshake_clock_crosser_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_avalon_st_handshake_clock_crosser_170/sim/altera_avalon_st_clock_crosser.v                        -work $(SIM_DIR)/libs/altera_avalon_st_handshake_clock_crosser_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_avalon_st_handshake_clock_crosser_170/sim/altera_avalon_st_pipeline_base.v                        -work $(SIM_DIR)/libs/altera_avalon_st_handshake_clock_crosser_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_avalon_st_handshake_clock_crosser_170/sim/altera_std_synchronizer_nocut.v                         -work $(SIM_DIR)/libs/altera_avalon_st_handshake_clock_crosser_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../error_adapter_170/sim/address_decode_error_adapter_170_mtlhioy.sv                                        -work $(SIM_DIR)/libs/error_adapter_170                           
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_avalon_st_adapter_170/sim/address_decode_altera_avalon_st_adapter_170_4tlgflq.v                   -work $(SIM_DIR)/libs/altera_avalon_st_adapter_170                
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_mm_interconnect_170/sim/address_decode_altera_mm_interconnect_170_o4jemda.v                       -work $(SIM_DIR)/libs/altera_mm_interconnect_170                  
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_reset_controller_170/sim/altera_reset_controller.v                                                -work $(SIM_DIR)/libs/altera_reset_controller_170                 
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/../altera_reset_controller_170/sim/altera_reset_synchronizer.v                                              -work $(SIM_DIR)/libs/altera_reset_controller_170                 
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/address_decoder/address_decode/sim/address_decode.v                                                                                            -work $(SIM_DIR)/libs/address_decode   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/fifo_dcfifo/dc_fifo/sim/../../ip/dc_fifo/dc_fifo_0/altera_avalon_dc_fifo_170/sim/altera_avalon_dc_fifo.v                                       -work $(SIM_DIR)/libs/altera_avalon_dc_fifo_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/fifo_dcfifo/dc_fifo/sim/../../ip/dc_fifo/dc_fifo_0/altera_avalon_dc_fifo_170/sim/altera_dcfifo_synchronizer_bundle.v                           -work $(SIM_DIR)/libs/altera_avalon_dc_fifo_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/fifo_dcfifo/dc_fifo/sim/../../ip/dc_fifo/dc_fifo_0/altera_avalon_dc_fifo_170/sim/altera_std_synchronizer_nocut.v                               -work $(SIM_DIR)/libs/altera_avalon_dc_fifo_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/fifo_dcfifo/dc_fifo/sim/../../ip/dc_fifo/dc_fifo_0/sim/dc_fifo_0.v                                                                             -work $(SIM_DIR)/libs/dc_fifo_0                
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/fifo_dcfifo/dc_fifo/sim/dc_fifo.v                                                                                                              -work $(SIM_DIR)/libs/dc_fifo  
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/fifo_scfifo/sc_fifo/sim/../altera_avalon_sc_fifo_170/sim/altera_avalon_sc_fifo.v                                                               -work $(SIM_DIR)/libs/altera_avalon_sc_fifo_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/fifo_scfifo/sc_fifo/sim/sc_fifo.v                                                                                                              -work $(SIM_DIR)/libs/sc_fifo
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/pll_mpll/pll/sim/../altera_iopll_170/sim/pll_altera_iopll_170_yi6tfeq.vo                                                                       -work $(SIM_DIR)/libs/altera_iopll_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/pll_mpll/pll/sim/pll.v                                                                                                                         -work $(SIM_DIR)/libs/pll    
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/xcvr_reset_controller/reset_control/sim/../altera_xcvr_reset_control_170/sim/altera_xcvr_functions.sv                                          -work $(SIM_DIR)/libs/altera_xcvr_reset_control_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/xcvr_reset_controller/reset_control/sim/../altera_xcvr_reset_control_170/sim/mentor/altera_xcvr_functions.sv                                   -work $(SIM_DIR)/libs/altera_xcvr_reset_control_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/xcvr_reset_controller/reset_control/sim/../altera_xcvr_reset_control_170/sim/alt_xcvr_resync.sv                                                -work $(SIM_DIR)/libs/altera_xcvr_reset_control_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/xcvr_reset_controller/reset_control/sim/../altera_xcvr_reset_control_170/sim/mentor/alt_xcvr_resync.sv                                         -work $(SIM_DIR)/libs/altera_xcvr_reset_control_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/xcvr_reset_controller/reset_control/sim/../altera_xcvr_reset_control_170/sim/altera_xcvr_reset_control.sv                                      -work $(SIM_DIR)/libs/altera_xcvr_reset_control_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/xcvr_reset_controller/reset_control/sim/../altera_xcvr_reset_control_170/sim/alt_xcvr_reset_counter.sv                                         -work $(SIM_DIR)/libs/altera_xcvr_reset_control_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/xcvr_reset_controller/reset_control/sim/../altera_xcvr_reset_control_170/sim/mentor/altera_xcvr_reset_control.sv                               -work $(SIM_DIR)/libs/altera_xcvr_reset_control_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/xcvr_reset_controller/reset_control/sim/../altera_xcvr_reset_control_170/sim/mentor/alt_xcvr_reset_counter.sv                                  -work $(SIM_DIR)/libs/altera_xcvr_reset_control_170
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/xcvr_reset_controller/reset_control/sim/reset_control.v                                                                                        -work $(SIM_DIR)/libs/reset_control   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/alt_em10g32.v                                                                         -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/alt_em10g32unit.v                                                                     -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_clk_rst.v                                                             -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_clock_crosser.v                                                       -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_crc32.v                                                               -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_crc32_gf_mult32_kc.v                                                  -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_creg_map.v                                                            -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_creg_top.v                                                            -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_frm_decoder.v                                                         -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_rs_gmii_mii_layer.v                                                -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_pipeline_base.v                                                       -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_reset_synchronizer.v                                                  -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rr_clock_crosser.v                                                    -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rst_cnt.v                                                             -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_fctl_filter_crcpad_rem.v                                           -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_fctl_overflow.v                                                    -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_fctl_preamble.v                                                    -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_frm_control.v                                                      -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_pfc_flow_control.v                                                 -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_pfc_pause_conversion.v                                             -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_pkt_backpressure_control.v                                         -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_rs_gmii16b.v                                                       -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_rs_gmii16b_top.v                                                   -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_rs_gmii_mii.v                                                      -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_rs_layer.v                                                         -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_rs_xgmii.v                                                         -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_status_aligner.v                                                   -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_top.v                                                              -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_stat_mem.v                                                            -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_stat_reg.v                                                            -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_data_frm_gen.v                                                     -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_srcaddr_inserter.v                                                 -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_err_aligner.v                                                      -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_flow_control.v                                                     -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_frm_arbiter.v                                                      -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_frm_muxer.v                                                        -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_pause_beat_conversion.v                                            -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_pause_frm_gen.v                                                    -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_pause_req.v                                                        -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_pfc_frm_gen.v                                                      -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rr_buffer.v                                                           -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_rs_gmii16b.v                                                       -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_rs_gmii16b_top.v                                                   -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_rs_layer.v                                                         -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_rs_xgmii_layer.v                                                   -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_sc_fifo.v                                                             -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_top.v                                                              -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_gmii_decoder.v                                                     -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_gmii_decoder_dfa.v                                                 -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_gmii_encoder.v                                                     -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_gmii_encoder_dfa.v                                                 -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_gmii_mii_decoder_if.v                                              -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_gmii_mii_encoder_if.v                                              -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_avalon_mm_adapter/altera_eth_avalon_mm_adapter.v                  -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_avalon_st_adapter/altera_eth_avalon_st_adapter.v                  -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter_avalon_st_rx.v                -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter_avalon_st_tx.v                -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter.v                             -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_avalon_st_adapter/alt_em10g32_vldpkt_rddly.v                      -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_avalon_st_adapter/sideband_adapter_rx.v                           -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_avalon_st_adapter/sideband_adapter_tx.v                           -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_avalon_st_adapter/sideband_adapter.v                              -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_avalon_st_adapter/altera_eth_sideband_crosser.v                   -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_avalon_st_adapter/altera_eth_sideband_crosser_sync.v              -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_32_64_xgmii_conversion.v            -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_32_to_64_xgmii_conversion.v         -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_64_to_32_xgmii_conversion.v         -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_dcfifo_32_to_64_xgmii_conversion.v  -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_dcfifo_64_to_32_xgmii_conversion.v  -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_32_to_64_adapter.v    -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_64_to_32_adapter.v    -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_data_format_adapter.v -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_altsyncram_bundle.v                                                   -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_altsyncram.v                                                          -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_avalon_dc_fifo_lat_calc.v                                             -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_avalon_dc_fifo_hecc.v                                                 -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_avalon_dc_fifo_secc.v                                                 -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_avalon_sc_fifo.v                                                      -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_avalon_sc_fifo_hecc.v                                                 -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_avalon_sc_fifo_secc.v                                                 -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_ecc_dec_18_12.v                                                       -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_ecc_dec_39_32.v                                                       -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_ecc_enc_12_18.v                                                       -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_ecc_enc_32_39.v                                                       -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_rs_xgmii_layer_ultra.v                                             -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_rs_xgmii_ultra.v                                                   -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_avst_to_gmii_if.v                                                     -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_gmii_to_avst_if.v                                                     -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_gmii_tsu.v                                                            -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_gmii16b_tsu.v                                                         -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_lpm_mult.v                                                            -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_ptp_aligner.v                                                      -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_ptp_detector.v                                                     -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_rx_ptp_top.v                                                          -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_gmii_crc_inserter.v                                                -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_gmii16b_crc_inserter.v                                             -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_gmii_ptp_inserter.v                                                -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_gmii16b_ptp_inserter.v                                             -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_gmii16b_ptp_inserter_1g2p5g10g.v                                   -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_ptp_processor.v                                                    -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_ptp_top.v                                                          -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_xgmii_crc_inserter.v                                               -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_tx_xgmii_ptp_inserter.v                                               -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_xgmii_tsu.v                                                           -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_crc328generator.v                                                     -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_crc32ctl8.v                                                           -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_crc32galois8.v                                                        -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_gmii_crc_inserter.v                                                   -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_gmii16b_crc_inserter.v                                                -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/mentor/rtl/alt_em10g32_gmii16b_crc32.v                                                       -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/alt_em10g32_avalon_dc_fifo.v                                                                 -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/alt_em10g32_dcfifo_synchronizer_bundle.v                                                     -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/alt_em10g32_std_synchronizer.v                                                               -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/../alt_em10g32_170/sim/altera_std_synchronizer_nocut.v                                                              -work $(SIM_DIR)/libs/alt_em10g32_170   
	vlog $(VLOG_ARGS) $(AFU_DIR)/e10/mac/altera_eth_10g_mac/sim/altera_eth_10g_mac.v                                                                                                -work $(SIM_DIR)/libs/altera_eth_10g_mac
	
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
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/ccip_std_afu.sv
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/ccip_interface_reg.sv
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/eth_e2e_e10.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/e10_avl_st_gen.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/e10_avl_st_mon.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/i2c_contrl.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/trans_bit.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/hsl_files/*.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/e10/altera_eth_10g_mac_base_r.v
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/e10/eth_traffic_controller/*.*v                 
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/e10/eth_traffic_controller/*.*v                 
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/e10/eth_traffic_controller/crc32/*.*v           
	vlog $(VLOG_ARGS) -work work $(AFU_DIR)/e10/eth_traffic_controller/crc32/crc32_lib/*.*v 
	vlog $(VLOG_ARGS) -work work ./tb.sv
	
sim_debug: $(SIM_DIR)/work $(SIM_DIR)/libs $(SIM_DIR)/intellibs
	vsim $(VSIM_ARGS_DEBUG) tb $(MSIM_LIBS)
	

sim: $(SIM_DIR)/work $(SIM_DIR)/libs $(SIM_DIR)/intellibs
	vsim $(VSIM_ARGS) tb $(MSIM_LIBS)

clean:
	rm -f $(SIM_DIR)/transcript
	rm -f $(SIM_DIR)/vsim.wlf
	rm -f $(SIM_DIR)/modelsim.ini
	rm -rf $(SIM_DIR)/work
	
clobber: clean
	rm -rf $(SIM_DIR)/libs
	rm -rf $(SIM_DIR)/intellibs
