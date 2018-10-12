
namespace eval altera_eth_10g_mac {
  proc get_memory_files {QSYS_SIMDIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    dict set design_files "alt_em10g32.v"                                   "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/alt_em10g32.v"                                                                        
    dict set design_files "alt_em10g32unit.v"                               "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/alt_em10g32unit.v"                                                                    
    dict set design_files "alt_em10g32_clk_rst.v"                           "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_clk_rst.v"                                                            
    dict set design_files "alt_em10g32_clock_crosser.v"                     "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_clock_crosser.v"                                                      
    dict set design_files "alt_em10g32_crc32.v"                             "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_crc32.v"                                                              
    dict set design_files "alt_em10g32_crc32_gf_mult32_kc.v"                "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_crc32_gf_mult32_kc.v"                                                 
    dict set design_files "alt_em10g32_creg_map.v"                          "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_creg_map.v"                                                           
    dict set design_files "alt_em10g32_creg_top.v"                          "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_creg_top.v"                                                           
    dict set design_files "alt_em10g32_frm_decoder.v"                       "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_frm_decoder.v"                                                        
    dict set design_files "alt_em10g32_tx_rs_gmii_mii_layer.v"              "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_rs_gmii_mii_layer.v"                                               
    dict set design_files "alt_em10g32_pipeline_base.v"                     "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_pipeline_base.v"                                                      
    dict set design_files "alt_em10g32_reset_synchronizer.v"                "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_reset_synchronizer.v"                                                 
    dict set design_files "alt_em10g32_rr_clock_crosser.v"                  "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rr_clock_crosser.v"                                                   
    dict set design_files "alt_em10g32_rst_cnt.v"                           "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rst_cnt.v"                                                            
    dict set design_files "alt_em10g32_rx_fctl_filter_crcpad_rem.v"         "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_fctl_filter_crcpad_rem.v"                                          
    dict set design_files "alt_em10g32_rx_fctl_overflow.v"                  "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_fctl_overflow.v"                                                   
    dict set design_files "alt_em10g32_rx_fctl_preamble.v"                  "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_fctl_preamble.v"                                                   
    dict set design_files "alt_em10g32_rx_frm_control.v"                    "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_frm_control.v"                                                     
    dict set design_files "alt_em10g32_rx_pfc_flow_control.v"               "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_pfc_flow_control.v"                                                
    dict set design_files "alt_em10g32_rx_pfc_pause_conversion.v"           "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_pfc_pause_conversion.v"                                            
    dict set design_files "alt_em10g32_rx_pkt_backpressure_control.v"       "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_pkt_backpressure_control.v"                                        
    dict set design_files "alt_em10g32_rx_rs_gmii16b.v"                     "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_rs_gmii16b.v"                                                      
    dict set design_files "alt_em10g32_rx_rs_gmii16b_top.v"                 "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_rs_gmii16b_top.v"                                                  
    dict set design_files "alt_em10g32_rx_rs_gmii_mii.v"                    "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_rs_gmii_mii.v"                                                     
    dict set design_files "alt_em10g32_rx_rs_layer.v"                       "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_rs_layer.v"                                                        
    dict set design_files "alt_em10g32_rx_rs_xgmii.v"                       "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_rs_xgmii.v"                                                        
    dict set design_files "alt_em10g32_rx_status_aligner.v"                 "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_status_aligner.v"                                                  
    dict set design_files "alt_em10g32_rx_top.v"                            "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_top.v"                                                             
    dict set design_files "alt_em10g32_stat_mem.v"                          "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_stat_mem.v"                                                           
    dict set design_files "alt_em10g32_stat_reg.v"                          "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_stat_reg.v"                                                           
    dict set design_files "alt_em10g32_tx_data_frm_gen.v"                   "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_data_frm_gen.v"                                                    
    dict set design_files "alt_em10g32_tx_srcaddr_inserter.v"               "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_srcaddr_inserter.v"                                                
    dict set design_files "alt_em10g32_tx_err_aligner.v"                    "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_err_aligner.v"                                                     
    dict set design_files "alt_em10g32_tx_flow_control.v"                   "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_flow_control.v"                                                    
    dict set design_files "alt_em10g32_tx_frm_arbiter.v"                    "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_frm_arbiter.v"                                                     
    dict set design_files "alt_em10g32_tx_frm_muxer.v"                      "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_frm_muxer.v"                                                       
    dict set design_files "alt_em10g32_tx_pause_beat_conversion.v"          "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_pause_beat_conversion.v"                                           
    dict set design_files "alt_em10g32_tx_pause_frm_gen.v"                  "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_pause_frm_gen.v"                                                   
    dict set design_files "alt_em10g32_tx_pause_req.v"                      "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_pause_req.v"                                                       
    dict set design_files "alt_em10g32_tx_pfc_frm_gen.v"                    "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_pfc_frm_gen.v"                                                     
    dict set design_files "alt_em10g32_rr_buffer.v"                         "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rr_buffer.v"                                                          
    dict set design_files "alt_em10g32_tx_rs_gmii16b.v"                     "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_rs_gmii16b.v"                                                      
    dict set design_files "alt_em10g32_tx_rs_gmii16b_top.v"                 "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_rs_gmii16b_top.v"                                                  
    dict set design_files "alt_em10g32_tx_rs_layer.v"                       "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_rs_layer.v"                                                        
    dict set design_files "alt_em10g32_tx_rs_xgmii_layer.v"                 "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_rs_xgmii_layer.v"                                                  
    dict set design_files "alt_em10g32_sc_fifo.v"                           "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_sc_fifo.v"                                                            
    dict set design_files "alt_em10g32_tx_top.v"                            "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_top.v"                                                             
    dict set design_files "alt_em10g32_rx_gmii_decoder.v"                   "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_gmii_decoder.v"                                                    
    dict set design_files "alt_em10g32_rx_gmii_decoder_dfa.v"               "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_gmii_decoder_dfa.v"                                                
    dict set design_files "alt_em10g32_tx_gmii_encoder.v"                   "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_gmii_encoder.v"                                                    
    dict set design_files "alt_em10g32_tx_gmii_encoder_dfa.v"               "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_gmii_encoder_dfa.v"                                                
    dict set design_files "alt_em10g32_rx_gmii_mii_decoder_if.v"            "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_gmii_mii_decoder_if.v"                                             
    dict set design_files "alt_em10g32_tx_gmii_mii_encoder_if.v"            "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_gmii_mii_encoder_if.v"                                             
    dict set design_files "altera_eth_avalon_mm_adapter.v"                  "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_avalon_mm_adapter/altera_eth_avalon_mm_adapter.v"                 
    dict set design_files "altera_eth_avalon_st_adapter.v"                  "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_avalon_st_adapter/altera_eth_avalon_st_adapter.v"                 
    dict set design_files "avalon_st_adapter_avalon_st_rx.v"                "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter_avalon_st_rx.v"               
    dict set design_files "avalon_st_adapter_avalon_st_tx.v"                "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter_avalon_st_tx.v"               
    dict set design_files "avalon_st_adapter.v"                             "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter.v"                            
    dict set design_files "alt_em10g32_vldpkt_rddly.v"                      "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_avalon_st_adapter/alt_em10g32_vldpkt_rddly.v"                     
    dict set design_files "sideband_adapter_rx.v"                           "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_avalon_st_adapter/sideband_adapter_rx.v"                          
    dict set design_files "sideband_adapter_tx.v"                           "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_avalon_st_adapter/sideband_adapter_tx.v"                          
    dict set design_files "sideband_adapter.v"                              "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_avalon_st_adapter/sideband_adapter.v"                             
    dict set design_files "altera_eth_sideband_crosser.v"                   "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_avalon_st_adapter/altera_eth_sideband_crosser.v"                  
    dict set design_files "altera_eth_sideband_crosser_sync.v"              "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_avalon_st_adapter/altera_eth_sideband_crosser_sync.v"             
    dict set design_files "alt_em10g_32_64_xgmii_conversion.v"              "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_32_64_xgmii_conversion.v"           
    dict set design_files "alt_em10g_32_to_64_xgmii_conversion.v"           "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_32_to_64_xgmii_conversion.v"        
    dict set design_files "alt_em10g_64_to_32_xgmii_conversion.v"           "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_64_to_32_xgmii_conversion.v"        
    dict set design_files "alt_em10g_dcfifo_32_to_64_xgmii_conversion.v"    "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_dcfifo_32_to_64_xgmii_conversion.v" 
    dict set design_files "alt_em10g_dcfifo_64_to_32_xgmii_conversion.v"    "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_dcfifo_64_to_32_xgmii_conversion.v" 
    dict set design_files "alt_em10g32_xgmii_32_to_64_adapter.v"            "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_32_to_64_adapter.v"   
    dict set design_files "alt_em10g32_xgmii_64_to_32_adapter.v"            "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_64_to_32_adapter.v"   
    dict set design_files "alt_em10g32_xgmii_data_format_adapter.v"         "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_data_format_adapter.v"
    dict set design_files "alt_em10g32_altsyncram_bundle.v"                 "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_altsyncram_bundle.v"                                                  
    dict set design_files "alt_em10g32_altsyncram.v"                        "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_altsyncram.v"                                                         
    dict set design_files "alt_em10g32_avalon_dc_fifo_lat_calc.v"           "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_avalon_dc_fifo_lat_calc.v"                                            
    dict set design_files "alt_em10g32_avalon_dc_fifo_hecc.v"               "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_avalon_dc_fifo_hecc.v"                                                
    dict set design_files "alt_em10g32_avalon_dc_fifo_secc.v"               "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_avalon_dc_fifo_secc.v"                                                
    dict set design_files "alt_em10g32_avalon_sc_fifo.v"                    "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_avalon_sc_fifo.v"                                                     
    dict set design_files "alt_em10g32_avalon_sc_fifo_hecc.v"               "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_avalon_sc_fifo_hecc.v"                                                
    dict set design_files "alt_em10g32_avalon_sc_fifo_secc.v"               "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_avalon_sc_fifo_secc.v"                                                
    dict set design_files "alt_em10g32_ecc_dec_18_12.v"                     "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_ecc_dec_18_12.v"                                                      
    dict set design_files "alt_em10g32_ecc_dec_39_32.v"                     "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_ecc_dec_39_32.v"                                                      
    dict set design_files "alt_em10g32_ecc_enc_12_18.v"                     "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_ecc_enc_12_18.v"                                                      
    dict set design_files "alt_em10g32_ecc_enc_32_39.v"                     "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_ecc_enc_32_39.v"                                                      
    dict set design_files "alt_em10g32_tx_rs_xgmii_layer_ultra.v"           "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_rs_xgmii_layer_ultra.v"                                            
    dict set design_files "alt_em10g32_rx_rs_xgmii_ultra.v"                 "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_rs_xgmii_ultra.v"                                                  
    dict set design_files "alt_em10g32_avst_to_gmii_if.v"                   "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_avst_to_gmii_if.v"                                                    
    dict set design_files "alt_em10g32_gmii_to_avst_if.v"                   "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_gmii_to_avst_if.v"                                                    
    dict set design_files "alt_em10g32_gmii_tsu.v"                          "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_gmii_tsu.v"                                                           
    dict set design_files "alt_em10g32_gmii16b_tsu.v"                       "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_gmii16b_tsu.v"                                                        
    dict set design_files "alt_em10g32_lpm_mult.v"                          "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_lpm_mult.v"                                                           
    dict set design_files "alt_em10g32_rx_ptp_aligner.v"                    "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_ptp_aligner.v"                                                     
    dict set design_files "alt_em10g32_rx_ptp_detector.v"                   "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_ptp_detector.v"                                                    
    dict set design_files "alt_em10g32_rx_ptp_top.v"                        "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_rx_ptp_top.v"                                                         
    dict set design_files "alt_em10g32_tx_gmii_crc_inserter.v"              "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_gmii_crc_inserter.v"                                               
    dict set design_files "alt_em10g32_tx_gmii16b_crc_inserter.v"           "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_gmii16b_crc_inserter.v"                                            
    dict set design_files "alt_em10g32_tx_gmii_ptp_inserter.v"              "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_gmii_ptp_inserter.v"                                               
    dict set design_files "alt_em10g32_tx_gmii16b_ptp_inserter.v"           "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_gmii16b_ptp_inserter.v"                                            
    dict set design_files "alt_em10g32_tx_gmii16b_ptp_inserter_1g2p5g10g.v" "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_gmii16b_ptp_inserter_1g2p5g10g.v"                                  
    dict set design_files "alt_em10g32_tx_ptp_processor.v"                  "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_ptp_processor.v"                                                   
    dict set design_files "alt_em10g32_tx_ptp_top.v"                        "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_ptp_top.v"                                                         
    dict set design_files "alt_em10g32_tx_xgmii_crc_inserter.v"             "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_xgmii_crc_inserter.v"                                              
    dict set design_files "alt_em10g32_tx_xgmii_ptp_inserter.v"             "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_tx_xgmii_ptp_inserter.v"                                              
    dict set design_files "alt_em10g32_xgmii_tsu.v"                         "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_xgmii_tsu.v"                                                          
    dict set design_files "alt_em10g32_crc328generator.v"                   "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_crc328generator.v"                                                    
    dict set design_files "alt_em10g32_crc32ctl8.v"                         "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_crc32ctl8.v"                                                          
    dict set design_files "alt_em10g32_crc32galois8.v"                      "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_crc32galois8.v"                                                       
    dict set design_files "alt_em10g32_gmii_crc_inserter.v"                 "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_gmii_crc_inserter.v"                                                  
    dict set design_files "alt_em10g32_gmii16b_crc_inserter.v"              "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_gmii16b_crc_inserter.v"                                               
    dict set design_files "alt_em10g32_gmii16b_crc32.v"                     "$QSYS_SIMDIR/../alt_em10g32_181/sim/synopsys/rtl/alt_em10g32_gmii16b_crc32.v"                                                      
    dict set design_files "alt_em10g32_avalon_dc_fifo.v"                    "$QSYS_SIMDIR/../alt_em10g32_181/sim/alt_em10g32_avalon_dc_fifo.v"                                                                  
    dict set design_files "alt_em10g32_dcfifo_synchronizer_bundle.v"        "$QSYS_SIMDIR/../alt_em10g32_181/sim/alt_em10g32_dcfifo_synchronizer_bundle.v"                                                      
    dict set design_files "alt_em10g32_std_synchronizer.v"                  "$QSYS_SIMDIR/../alt_em10g32_181/sim/alt_em10g32_std_synchronizer.v"                                                                
    dict set design_files "altera_std_synchronizer_nocut.v"                 "$QSYS_SIMDIR/../alt_em10g32_181/sim/altera_std_synchronizer_nocut.v"                                                               
    dict set design_files "altera_eth_10g_mac.v"                            "$QSYS_SIMDIR/altera_eth_10g_mac.v"                                                                                                 
    return $design_files
  }
  
  proc get_elab_options {SIMULATOR_TOOL_BITNESS} {
    set ELAB_OPTIONS ""
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    dict set ENV_VARIABLES "LD_LIBRARY_PATH" $LD_LIBRARY_PATH
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ENV_VARIABLES
  }
  
  
}
