
namespace eval address_decode_master_0 {
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
    dict set design_files "altera_avalon_st_jtag_interface.v"                               "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_avalon_st_jtag_interface.v"                               
    dict set design_files "altera_jtag_dc_streaming.v"                                      "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_jtag_dc_streaming.v"                                      
    dict set design_files "altera_jtag_sld_node.v"                                          "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_jtag_sld_node.v"                                          
    dict set design_files "altera_jtag_streaming.v"                                         "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_jtag_streaming.v"                                         
    dict set design_files "altera_avalon_st_clock_crosser.v"                                "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_avalon_st_clock_crosser.v"                                
    dict set design_files "altera_std_synchronizer_nocut.v"                                 "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_std_synchronizer_nocut.v"                                 
    dict set design_files "altera_avalon_st_pipeline_base.v"                                "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_avalon_st_pipeline_base.v"                                
    dict set design_files "altera_avalon_st_idle_remover.v"                                 "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_avalon_st_idle_remover.v"                                 
    dict set design_files "altera_avalon_st_idle_inserter.v"                                "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_avalon_st_idle_inserter.v"                                
    dict set design_files "altera_avalon_st_pipeline_stage.sv"                              "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_avalon_st_pipeline_stage.sv"                              
    dict set design_files "address_decode_master_0_timing_adapter_181_5bygnli.sv"           "$QSYS_SIMDIR/../timing_adapter_181/sim/address_decode_master_0_timing_adapter_181_5bygnli.sv"                     
    dict set design_files "address_decode_master_0_altera_avalon_sc_fifo_181_hseo73i.v"     "$QSYS_SIMDIR/../altera_avalon_sc_fifo_181/sim/address_decode_master_0_altera_avalon_sc_fifo_181_hseo73i.v"        
    dict set design_files "altera_avalon_st_bytes_to_packets.v"                             "$QSYS_SIMDIR/../altera_avalon_st_bytes_to_packets_181/sim/altera_avalon_st_bytes_to_packets.v"                    
    dict set design_files "altera_avalon_st_packets_to_bytes.v"                             "$QSYS_SIMDIR/../altera_avalon_st_packets_to_bytes_181/sim/altera_avalon_st_packets_to_bytes.v"                    
    dict set design_files "altera_avalon_packets_to_master.v"                               "$QSYS_SIMDIR/../altera_avalon_packets_to_master_181/sim/altera_avalon_packets_to_master.v"                        
    dict set design_files "address_decode_master_0_channel_adapter_181_brosi3y.sv"          "$QSYS_SIMDIR/../channel_adapter_181/sim/address_decode_master_0_channel_adapter_181_brosi3y.sv"                   
    dict set design_files "address_decode_master_0_channel_adapter_181_imsynky.sv"          "$QSYS_SIMDIR/../channel_adapter_181/sim/address_decode_master_0_channel_adapter_181_imsynky.sv"                   
    dict set design_files "altera_reset_controller.v"                                       "$QSYS_SIMDIR/../altera_reset_controller_181/sim/altera_reset_controller.v"                                        
    dict set design_files "altera_reset_synchronizer.v"                                     "$QSYS_SIMDIR/../altera_reset_controller_181/sim/altera_reset_synchronizer.v"                                      
    dict set design_files "address_decode_master_0_altera_jtag_avalon_master_181_2tlssti.v" "$QSYS_SIMDIR/../altera_jtag_avalon_master_181/sim/address_decode_master_0_altera_jtag_avalon_master_181_2tlssti.v"
    dict set design_files "address_decode_master_0.v"                                       "$QSYS_SIMDIR/address_decode_master_0.v"                                                                           
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
