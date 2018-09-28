source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_tx_sc_fifo/sim/common/vcs_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_mm_to_mac/sim/common/vcs_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_tx_xcvr_half_clk/sim/common/vcs_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_mm_to_phy/sim/common/vcs_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_rx_sc_fifo/sim/common/vcs_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_rx_xcvr_clk/sim/common/vcs_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_clk_csr/sim/common/vcs_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_eth_gen_mon/sim/common/vcs_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_master_0/sim/common/vcs_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_merlin_master_translator_0/sim/common/vcs_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_tx_xcvr_clk/sim/common/vcs_files.tcl]

namespace eval address_decode {
  proc get_memory_files {QSYS_SIMDIR} {
    set memory_files [list]
    set memory_files [concat $memory_files [address_decode_tx_sc_fifo::get_memory_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_sc_fifo/sim/"]]
    set memory_files [concat $memory_files [address_decode_mm_to_mac::get_memory_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_mm_to_mac/sim/"]]
    set memory_files [concat $memory_files [address_decode_tx_xcvr_half_clk::get_memory_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_xcvr_half_clk/sim/"]]
    set memory_files [concat $memory_files [address_decode_mm_to_phy::get_memory_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_mm_to_phy/sim/"]]
    set memory_files [concat $memory_files [address_decode_rx_sc_fifo::get_memory_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_rx_sc_fifo/sim/"]]
    set memory_files [concat $memory_files [address_decode_rx_xcvr_clk::get_memory_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_rx_xcvr_clk/sim/"]]
    set memory_files [concat $memory_files [address_decode_clk_csr::get_memory_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_clk_csr/sim/"]]
    set memory_files [concat $memory_files [address_decode_eth_gen_mon::get_memory_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_eth_gen_mon/sim/"]]
    set memory_files [concat $memory_files [address_decode_master_0::get_memory_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_master_0/sim/"]]
    set memory_files [concat $memory_files [address_decode_merlin_master_translator_0::get_memory_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_merlin_master_translator_0/sim/"]]
    set memory_files [concat $memory_files [address_decode_tx_xcvr_clk::get_memory_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_xcvr_clk/sim/"]]
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [address_decode_tx_sc_fifo::get_common_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_sc_fifo/sim/"]]
    set design_files [dict merge $design_files [address_decode_mm_to_mac::get_common_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_mm_to_mac/sim/"]]
    set design_files [dict merge $design_files [address_decode_tx_xcvr_half_clk::get_common_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_xcvr_half_clk/sim/"]]
    set design_files [dict merge $design_files [address_decode_mm_to_phy::get_common_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_mm_to_phy/sim/"]]
    set design_files [dict merge $design_files [address_decode_rx_sc_fifo::get_common_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_rx_sc_fifo/sim/"]]
    set design_files [dict merge $design_files [address_decode_rx_xcvr_clk::get_common_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_rx_xcvr_clk/sim/"]]
    set design_files [dict merge $design_files [address_decode_clk_csr::get_common_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_clk_csr/sim/"]]
    set design_files [dict merge $design_files [address_decode_eth_gen_mon::get_common_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_eth_gen_mon/sim/"]]
    set design_files [dict merge $design_files [address_decode_master_0::get_common_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_master_0/sim/"]]
    set design_files [dict merge $design_files [address_decode_merlin_master_translator_0::get_common_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_merlin_master_translator_0/sim/"]]
    set design_files [dict merge $design_files [address_decode_tx_xcvr_clk::get_common_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_xcvr_clk/sim/"]]
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [address_decode_tx_sc_fifo::get_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_sc_fifo/sim/"]]
    set design_files [dict merge $design_files [address_decode_mm_to_mac::get_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_mm_to_mac/sim/"]]
    set design_files [dict merge $design_files [address_decode_tx_xcvr_half_clk::get_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_xcvr_half_clk/sim/"]]
    set design_files [dict merge $design_files [address_decode_mm_to_phy::get_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_mm_to_phy/sim/"]]
    set design_files [dict merge $design_files [address_decode_rx_sc_fifo::get_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_rx_sc_fifo/sim/"]]
    set design_files [dict merge $design_files [address_decode_rx_xcvr_clk::get_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_rx_xcvr_clk/sim/"]]
    set design_files [dict merge $design_files [address_decode_clk_csr::get_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_clk_csr/sim/"]]
    set design_files [dict merge $design_files [address_decode_eth_gen_mon::get_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_eth_gen_mon/sim/"]]
    set design_files [dict merge $design_files [address_decode_master_0::get_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_master_0/sim/"]]
    set design_files [dict merge $design_files [address_decode_merlin_master_translator_0::get_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_merlin_master_translator_0/sim/"]]
    set design_files [dict merge $design_files [address_decode_tx_xcvr_clk::get_design_files "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_xcvr_clk/sim/"]]
    dict set design_files "address_decode_altera_merlin_master_translator_181_mhudjri.sv"         "$QSYS_SIMDIR/../altera_merlin_master_translator_181/sim/address_decode_altera_merlin_master_translator_181_mhudjri.sv"                 
    dict set design_files "address_decode_altera_merlin_slave_translator_181_5aswt6a.sv"          "$QSYS_SIMDIR/../altera_merlin_slave_translator_181/sim/address_decode_altera_merlin_slave_translator_181_5aswt6a.sv"                   
    dict set design_files "address_decode_altera_merlin_master_agent_181_t5eyqrq.sv"              "$QSYS_SIMDIR/../altera_merlin_master_agent_181/sim/address_decode_altera_merlin_master_agent_181_t5eyqrq.sv"                           
    dict set design_files "address_decode_altera_merlin_slave_agent_181_a7g37xa.sv"               "$QSYS_SIMDIR/../altera_merlin_slave_agent_181/sim/address_decode_altera_merlin_slave_agent_181_a7g37xa.sv"                             
    dict set design_files "altera_merlin_burst_uncompressor.sv"                                   "$QSYS_SIMDIR/../altera_merlin_slave_agent_181/sim/altera_merlin_burst_uncompressor.sv"                                                 
    dict set design_files "address_decode_altera_avalon_sc_fifo_181_hseo73i.v"                    "$QSYS_SIMDIR/../altera_avalon_sc_fifo_181/sim/address_decode_altera_avalon_sc_fifo_181_hseo73i.v"                                      
    dict set design_files "address_decode_altera_merlin_router_181_dqij2zy.sv"                    "$QSYS_SIMDIR/../altera_merlin_router_181/sim/address_decode_altera_merlin_router_181_dqij2zy.sv"                                       
    dict set design_files "address_decode_altera_merlin_router_181_fet5uza.sv"                    "$QSYS_SIMDIR/../altera_merlin_router_181/sim/address_decode_altera_merlin_router_181_fet5uza.sv"                                       
    dict set design_files "address_decode_altera_merlin_traffic_limiter_181_ohcvrpq.v"            "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_181/sim/address_decode_altera_merlin_traffic_limiter_181_ohcvrpq.v"                      
    dict set design_files "address_decode_alt_hiconnect_sc_fifo_181_cjmuh4a.sv"                   "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/address_decode_alt_hiconnect_sc_fifo_181_cjmuh4a.sv"                                     
    dict set design_files "alt_st_infer_scfifo.sv"                                                "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/alt_st_infer_scfifo.sv"                                                                  
    dict set design_files "alt_st_mlab_scfifo.sv"                                                 "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/alt_st_mlab_scfifo.sv"                                                                   
    dict set design_files "alt_st_fifo_empty.sv"                                                  "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/alt_st_fifo_empty.sv"                                                                    
    dict set design_files "alt_st_mlab_scfifo_a6.sv"                                              "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/alt_st_mlab_scfifo_a6.sv"                                                                
    dict set design_files "alt_st_mlab_scfifo_a7.sv"                                              "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/alt_st_mlab_scfifo_a7.sv"                                                                
    dict set design_files "alt_st_reg_scfifo.sv"                                                  "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/alt_st_reg_scfifo.sv"                                                                    
    dict set design_files "address_decode_altera_merlin_traffic_limiter_181_avmww2q.v"            "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_181/sim/address_decode_altera_merlin_traffic_limiter_181_avmww2q.v"                      
    dict set design_files "altera_merlin_reorder_memory.sv"                                       "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_181/sim/altera_merlin_reorder_memory.sv"                                                 
    dict set design_files "altera_avalon_st_pipeline_base.v"                                      "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_181/sim/altera_avalon_st_pipeline_base.v"                                                
    dict set design_files "address_decode_altera_merlin_traffic_limiter_181_reppfiq.sv"           "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_181/sim/address_decode_altera_merlin_traffic_limiter_181_reppfiq.sv"                     
    dict set design_files "address_decode_altera_merlin_burst_adapter_181_hpj5oyy.sv"             "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/address_decode_altera_merlin_burst_adapter_181_hpj5oyy.sv"                         
    dict set design_files "altera_merlin_burst_adapter_uncmpr.sv"                                 "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_merlin_burst_adapter_uncmpr.sv"                                             
    dict set design_files "altera_merlin_burst_adapter_13_1.sv"                                   "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_merlin_burst_adapter_13_1.sv"                                               
    dict set design_files "altera_merlin_burst_adapter_new.sv"                                    "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_merlin_burst_adapter_new.sv"                                                
    dict set design_files "altera_incr_burst_converter.sv"                                        "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_incr_burst_converter.sv"                                                    
    dict set design_files "altera_wrap_burst_converter.sv"                                        "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_wrap_burst_converter.sv"                                                    
    dict set design_files "altera_default_burst_converter.sv"                                     "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_default_burst_converter.sv"                                                 
    dict set design_files "altera_merlin_address_alignment.sv"                                    "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_merlin_address_alignment.sv"                                                
    dict set design_files "altera_avalon_st_pipeline_stage.sv"                                    "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_avalon_st_pipeline_stage.sv"                                                
    dict set design_files "altera_avalon_st_pipeline_base.v"                                      "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_avalon_st_pipeline_base.v"                                                  
    dict set design_files "address_decode_altera_merlin_demultiplexer_181_233qqei.sv"             "$QSYS_SIMDIR/../altera_merlin_demultiplexer_181/sim/address_decode_altera_merlin_demultiplexer_181_233qqei.sv"                         
    dict set design_files "address_decode_altera_merlin_multiplexer_181_or5baiy.sv"               "$QSYS_SIMDIR/../altera_merlin_multiplexer_181/sim/address_decode_altera_merlin_multiplexer_181_or5baiy.sv"                             
    dict set design_files "altera_merlin_arbitrator.sv"                                           "$QSYS_SIMDIR/../altera_merlin_multiplexer_181/sim/altera_merlin_arbitrator.sv"                                                         
    dict set design_files "address_decode_altera_merlin_demultiplexer_181_qc6ddcy.sv"             "$QSYS_SIMDIR/../altera_merlin_demultiplexer_181/sim/address_decode_altera_merlin_demultiplexer_181_qc6ddcy.sv"                         
    dict set design_files "address_decode_altera_merlin_multiplexer_181_tzqtjwa.sv"               "$QSYS_SIMDIR/../altera_merlin_multiplexer_181/sim/address_decode_altera_merlin_multiplexer_181_tzqtjwa.sv"                             
    dict set design_files "altera_merlin_arbitrator.sv"                                           "$QSYS_SIMDIR/../altera_merlin_multiplexer_181/sim/altera_merlin_arbitrator.sv"                                                         
    dict set design_files "address_decode_altera_avalon_st_handshake_clock_crosser_181_oeeupgi.v" "$QSYS_SIMDIR/../altera_avalon_st_handshake_clock_crosser_181/sim/address_decode_altera_avalon_st_handshake_clock_crosser_181_oeeupgi.v"
    dict set design_files "altera_avalon_st_clock_crosser.v"                                      "$QSYS_SIMDIR/../altera_avalon_st_handshake_clock_crosser_181/sim/altera_avalon_st_clock_crosser.v"                                     
    dict set design_files "altera_avalon_st_pipeline_base.v"                                      "$QSYS_SIMDIR/../altera_avalon_st_handshake_clock_crosser_181/sim/altera_avalon_st_pipeline_base.v"                                     
    dict set design_files "altera_std_synchronizer_nocut.v"                                       "$QSYS_SIMDIR/../altera_avalon_st_handshake_clock_crosser_181/sim/altera_std_synchronizer_nocut.v"                                      
    dict set design_files "address_decode_altera_mm_interconnect_181_egdbf5q.v"                   "$QSYS_SIMDIR/../altera_mm_interconnect_181/sim/address_decode_altera_mm_interconnect_181_egdbf5q.v"                                    
    dict set design_files "altera_reset_controller.v"                                             "$QSYS_SIMDIR/../altera_reset_controller_181/sim/altera_reset_controller.v"                                                             
    dict set design_files "altera_reset_synchronizer.v"                                           "$QSYS_SIMDIR/../altera_reset_controller_181/sim/altera_reset_synchronizer.v"                                                           
    dict set design_files "address_decode.v"                                                      "$QSYS_SIMDIR/address_decode.v"                                                                                                         
    return $design_files
  }
  
  proc get_elab_options {SIMULATOR_TOOL_BITNESS} {
    set ELAB_OPTIONS ""
    append ELAB_OPTIONS [address_decode_tx_sc_fifo::get_elab_options $SIMULATOR_TOOL_BITNESS]
    append ELAB_OPTIONS [address_decode_mm_to_mac::get_elab_options $SIMULATOR_TOOL_BITNESS]
    append ELAB_OPTIONS [address_decode_tx_xcvr_half_clk::get_elab_options $SIMULATOR_TOOL_BITNESS]
    append ELAB_OPTIONS [address_decode_mm_to_phy::get_elab_options $SIMULATOR_TOOL_BITNESS]
    append ELAB_OPTIONS [address_decode_rx_sc_fifo::get_elab_options $SIMULATOR_TOOL_BITNESS]
    append ELAB_OPTIONS [address_decode_rx_xcvr_clk::get_elab_options $SIMULATOR_TOOL_BITNESS]
    append ELAB_OPTIONS [address_decode_clk_csr::get_elab_options $SIMULATOR_TOOL_BITNESS]
    append ELAB_OPTIONS [address_decode_eth_gen_mon::get_elab_options $SIMULATOR_TOOL_BITNESS]
    append ELAB_OPTIONS [address_decode_master_0::get_elab_options $SIMULATOR_TOOL_BITNESS]
    append ELAB_OPTIONS [address_decode_merlin_master_translator_0::get_elab_options $SIMULATOR_TOOL_BITNESS]
    append ELAB_OPTIONS [address_decode_tx_xcvr_clk::get_elab_options $SIMULATOR_TOOL_BITNESS]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    append SIM_OPTIONS [address_decode_tx_sc_fifo::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [address_decode_mm_to_mac::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [address_decode_tx_xcvr_half_clk::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [address_decode_mm_to_phy::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [address_decode_rx_sc_fifo::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [address_decode_rx_xcvr_clk::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [address_decode_clk_csr::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [address_decode_eth_gen_mon::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [address_decode_master_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [address_decode_merlin_master_translator_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [address_decode_tx_xcvr_clk::get_sim_options $SIMULATOR_TOOL_BITNESS]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [address_decode_tx_sc_fifo::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [address_decode_mm_to_mac::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [address_decode_tx_xcvr_half_clk::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [address_decode_mm_to_phy::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [address_decode_rx_sc_fifo::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [address_decode_rx_xcvr_clk::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [address_decode_clk_csr::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [address_decode_eth_gen_mon::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [address_decode_master_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [address_decode_merlin_master_translator_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [address_decode_tx_xcvr_clk::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    dict set ENV_VARIABLES "LD_LIBRARY_PATH" $LD_LIBRARY_PATH
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ENV_VARIABLES
  }
  
  
}
