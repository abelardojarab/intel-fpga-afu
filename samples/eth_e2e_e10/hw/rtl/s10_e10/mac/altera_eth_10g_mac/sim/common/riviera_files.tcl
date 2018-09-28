
namespace eval altera_eth_10g_mac {
  proc get_design_libraries {} {
    set libraries [dict create]
    dict set libraries alt_em10g32_181    1
    dict set libraries altera_eth_10g_mac 1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [dict create]
    return $design_files
  }
  
  proc get_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [list]
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/alt_em10g32.v"]\"  -work alt_em10g32_181"                                                                        
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/alt_em10g32unit.v"]\"  -work alt_em10g32_181"                                                                    
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_clk_rst.v"]\"  -work alt_em10g32_181"                                                            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_clock_crosser.v"]\"  -work alt_em10g32_181"                                                      
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_crc32.v"]\"  -work alt_em10g32_181"                                                              
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_crc32_gf_mult32_kc.v"]\"  -work alt_em10g32_181"                                                 
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_creg_map.v"]\"  -work alt_em10g32_181"                                                           
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_creg_top.v"]\"  -work alt_em10g32_181"                                                           
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_frm_decoder.v"]\"  -work alt_em10g32_181"                                                        
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_rs_gmii_mii_layer.v"]\"  -work alt_em10g32_181"                                               
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_pipeline_base.v"]\"  -work alt_em10g32_181"                                                      
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_reset_synchronizer.v"]\"  -work alt_em10g32_181"                                                 
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rr_clock_crosser.v"]\"  -work alt_em10g32_181"                                                   
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rst_cnt.v"]\"  -work alt_em10g32_181"                                                            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_fctl_filter_crcpad_rem.v"]\"  -work alt_em10g32_181"                                          
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_fctl_overflow.v"]\"  -work alt_em10g32_181"                                                   
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_fctl_preamble.v"]\"  -work alt_em10g32_181"                                                   
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_frm_control.v"]\"  -work alt_em10g32_181"                                                     
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_pfc_flow_control.v"]\"  -work alt_em10g32_181"                                                
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_pfc_pause_conversion.v"]\"  -work alt_em10g32_181"                                            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_pkt_backpressure_control.v"]\"  -work alt_em10g32_181"                                        
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_rs_gmii16b.v"]\"  -work alt_em10g32_181"                                                      
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_rs_gmii16b_top.v"]\"  -work alt_em10g32_181"                                                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_rs_gmii_mii.v"]\"  -work alt_em10g32_181"                                                     
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_rs_layer.v"]\"  -work alt_em10g32_181"                                                        
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_rs_xgmii.v"]\"  -work alt_em10g32_181"                                                        
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_status_aligner.v"]\"  -work alt_em10g32_181"                                                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_top.v"]\"  -work alt_em10g32_181"                                                             
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_stat_mem.v"]\"  -work alt_em10g32_181"                                                           
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_stat_reg.v"]\"  -work alt_em10g32_181"                                                           
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_data_frm_gen.v"]\"  -work alt_em10g32_181"                                                    
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_srcaddr_inserter.v"]\"  -work alt_em10g32_181"                                                
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_err_aligner.v"]\"  -work alt_em10g32_181"                                                     
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_flow_control.v"]\"  -work alt_em10g32_181"                                                    
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_frm_arbiter.v"]\"  -work alt_em10g32_181"                                                     
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_frm_muxer.v"]\"  -work alt_em10g32_181"                                                       
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_pause_beat_conversion.v"]\"  -work alt_em10g32_181"                                           
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_pause_frm_gen.v"]\"  -work alt_em10g32_181"                                                   
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_pause_req.v"]\"  -work alt_em10g32_181"                                                       
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_pfc_frm_gen.v"]\"  -work alt_em10g32_181"                                                     
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rr_buffer.v"]\"  -work alt_em10g32_181"                                                          
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_rs_gmii16b.v"]\"  -work alt_em10g32_181"                                                      
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_rs_gmii16b_top.v"]\"  -work alt_em10g32_181"                                                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_rs_layer.v"]\"  -work alt_em10g32_181"                                                        
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_rs_xgmii_layer.v"]\"  -work alt_em10g32_181"                                                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_sc_fifo.v"]\"  -work alt_em10g32_181"                                                            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_top.v"]\"  -work alt_em10g32_181"                                                             
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_gmii_decoder.v"]\"  -work alt_em10g32_181"                                                    
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_gmii_decoder_dfa.v"]\"  -work alt_em10g32_181"                                                
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_gmii_encoder.v"]\"  -work alt_em10g32_181"                                                    
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_gmii_encoder_dfa.v"]\"  -work alt_em10g32_181"                                                
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_gmii_mii_decoder_if.v"]\"  -work alt_em10g32_181"                                             
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_gmii_mii_encoder_if.v"]\"  -work alt_em10g32_181"                                             
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_avalon_mm_adapter/altera_eth_avalon_mm_adapter.v"]\"  -work alt_em10g32_181"                 
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_avalon_st_adapter/altera_eth_avalon_st_adapter.v"]\"  -work alt_em10g32_181"                 
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter_avalon_st_rx.v"]\"  -work alt_em10g32_181"               
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter_avalon_st_tx.v"]\"  -work alt_em10g32_181"               
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_avalon_st_adapter/avalon_st_adapter.v"]\"  -work alt_em10g32_181"                            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_avalon_st_adapter/alt_em10g32_vldpkt_rddly.v"]\"  -work alt_em10g32_181"                     
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_avalon_st_adapter/sideband_adapter_rx.v"]\"  -work alt_em10g32_181"                          
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_avalon_st_adapter/sideband_adapter_tx.v"]\"  -work alt_em10g32_181"                          
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_avalon_st_adapter/sideband_adapter.v"]\"  -work alt_em10g32_181"                             
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_avalon_st_adapter/altera_eth_sideband_crosser.v"]\"  -work alt_em10g32_181"                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_avalon_st_adapter/altera_eth_sideband_crosser_sync.v"]\"  -work alt_em10g32_181"             
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_32_64_xgmii_conversion.v"]\"  -work alt_em10g32_181"           
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_32_to_64_xgmii_conversion.v"]\"  -work alt_em10g32_181"        
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_64_to_32_xgmii_conversion.v"]\"  -work alt_em10g32_181"        
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_dcfifo_32_to_64_xgmii_conversion.v"]\"  -work alt_em10g32_181" 
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_xgmii_width_adaptor/alt_em10g_dcfifo_64_to_32_xgmii_conversion.v"]\"  -work alt_em10g32_181" 
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_32_to_64_adapter.v"]\"  -work alt_em10g32_181"   
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_64_to_32_adapter.v"]\"  -work alt_em10g32_181"   
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/adapters/altera_eth_xgmii_data_format_adapter/alt_em10g32_xgmii_data_format_adapter.v"]\"  -work alt_em10g32_181"
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_altsyncram_bundle.v"]\"  -work alt_em10g32_181"                                                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_altsyncram.v"]\"  -work alt_em10g32_181"                                                         
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_avalon_dc_fifo_lat_calc.v"]\"  -work alt_em10g32_181"                                            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_avalon_dc_fifo_hecc.v"]\"  -work alt_em10g32_181"                                                
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_avalon_dc_fifo_secc.v"]\"  -work alt_em10g32_181"                                                
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_avalon_sc_fifo.v"]\"  -work alt_em10g32_181"                                                     
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_avalon_sc_fifo_hecc.v"]\"  -work alt_em10g32_181"                                                
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_avalon_sc_fifo_secc.v"]\"  -work alt_em10g32_181"                                                
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_ecc_dec_18_12.v"]\"  -work alt_em10g32_181"                                                      
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_ecc_dec_39_32.v"]\"  -work alt_em10g32_181"                                                      
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_ecc_enc_12_18.v"]\"  -work alt_em10g32_181"                                                      
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_ecc_enc_32_39.v"]\"  -work alt_em10g32_181"                                                      
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_rs_xgmii_layer_ultra.v"]\"  -work alt_em10g32_181"                                            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_rs_xgmii_ultra.v"]\"  -work alt_em10g32_181"                                                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_avst_to_gmii_if.v"]\"  -work alt_em10g32_181"                                                    
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_gmii_to_avst_if.v"]\"  -work alt_em10g32_181"                                                    
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_gmii_tsu.v"]\"  -work alt_em10g32_181"                                                           
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_gmii16b_tsu.v"]\"  -work alt_em10g32_181"                                                        
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_lpm_mult.v"]\"  -work alt_em10g32_181"                                                           
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_ptp_aligner.v"]\"  -work alt_em10g32_181"                                                     
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_ptp_detector.v"]\"  -work alt_em10g32_181"                                                    
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_rx_ptp_top.v"]\"  -work alt_em10g32_181"                                                         
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_gmii_crc_inserter.v"]\"  -work alt_em10g32_181"                                               
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_gmii16b_crc_inserter.v"]\"  -work alt_em10g32_181"                                            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_gmii_ptp_inserter.v"]\"  -work alt_em10g32_181"                                               
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_gmii16b_ptp_inserter.v"]\"  -work alt_em10g32_181"                                            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_gmii16b_ptp_inserter_1g2p5g10g.v"]\"  -work alt_em10g32_181"                                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_ptp_processor.v"]\"  -work alt_em10g32_181"                                                   
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_ptp_top.v"]\"  -work alt_em10g32_181"                                                         
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_xgmii_crc_inserter.v"]\"  -work alt_em10g32_181"                                              
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_tx_xgmii_ptp_inserter.v"]\"  -work alt_em10g32_181"                                              
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_xgmii_tsu.v"]\"  -work alt_em10g32_181"                                                          
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_crc328generator.v"]\"  -work alt_em10g32_181"                                                    
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_crc32ctl8.v"]\"  -work alt_em10g32_181"                                                          
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_crc32galois8.v"]\"  -work alt_em10g32_181"                                                       
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_gmii_crc_inserter.v"]\"  -work alt_em10g32_181"                                                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_gmii16b_crc_inserter.v"]\"  -work alt_em10g32_181"                                               
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/aldec/rtl/alt_em10g32_gmii16b_crc32.v"]\"  -work alt_em10g32_181"                                                      
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/alt_em10g32_avalon_dc_fifo.v"]\"  -work alt_em10g32_181"                                                               
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/alt_em10g32_dcfifo_synchronizer_bundle.v"]\"  -work alt_em10g32_181"                                                   
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/alt_em10g32_std_synchronizer.v"]\"  -work alt_em10g32_181"                                                             
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_em10g32_181/sim/altera_std_synchronizer_nocut.v"]\"  -work alt_em10g32_181"                                                            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/altera_eth_10g_mac.v"]\"  -work altera_eth_10g_mac"                                                                                           
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
  
  
  proc normalize_path {FILEPATH} {
      if {[catch { package require fileutil } err]} { 
          return $FILEPATH 
      } 
      set path [fileutil::lexnormalize [file join [pwd] $FILEPATH]]  
      if {[file pathtype $FILEPATH] eq "relative"} { 
          set path [fileutil::relative [pwd] $path] 
      } 
      return $path 
  } 
}
