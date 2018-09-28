
namespace eval address_decode_master_0 {
  proc get_design_libraries {} {
    set libraries [dict create]
    dict set libraries altera_jtag_dc_streaming_181          1
    dict set libraries timing_adapter_181                    1
    dict set libraries altera_avalon_sc_fifo_181             1
    dict set libraries altera_avalon_st_bytes_to_packets_181 1
    dict set libraries altera_avalon_st_packets_to_bytes_181 1
    dict set libraries altera_avalon_packets_to_master_181   1
    dict set libraries channel_adapter_181                   1
    dict set libraries altera_reset_controller_181           1
    dict set libraries altera_jtag_avalon_master_181         1
    dict set libraries address_decode_master_0               1
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
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_avalon_st_jtag_interface.v"]\"  -work altera_jtag_dc_streaming_181"                                
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_jtag_dc_streaming.v"]\"  -work altera_jtag_dc_streaming_181"                                       
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_jtag_sld_node.v"]\"  -work altera_jtag_dc_streaming_181"                                           
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_jtag_streaming.v"]\"  -work altera_jtag_dc_streaming_181"                                          
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_avalon_st_clock_crosser.v"]\"  -work altera_jtag_dc_streaming_181"                                 
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_std_synchronizer_nocut.v"]\"  -work altera_jtag_dc_streaming_181"                                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_avalon_st_pipeline_base.v"]\"  -work altera_jtag_dc_streaming_181"                                 
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_avalon_st_idle_remover.v"]\"  -work altera_jtag_dc_streaming_181"                                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_avalon_st_idle_inserter.v"]\"  -work altera_jtag_dc_streaming_181"                                 
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_dc_streaming_181/sim/altera_avalon_st_pipeline_stage.sv"]\"  -work altera_jtag_dc_streaming_181"                                    
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../timing_adapter_181/sim/address_decode_master_0_timing_adapter_181_5bygnli.sv"]\"  -work timing_adapter_181"                                     
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_sc_fifo_181/sim/address_decode_master_0_altera_avalon_sc_fifo_181_hseo73i.v"]\"  -work altera_avalon_sc_fifo_181"            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_bytes_to_packets_181/sim/altera_avalon_st_bytes_to_packets.v"]\"  -work altera_avalon_st_bytes_to_packets_181"            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_packets_to_bytes_181/sim/altera_avalon_st_packets_to_bytes.v"]\"  -work altera_avalon_st_packets_to_bytes_181"            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_packets_to_master_181/sim/altera_avalon_packets_to_master.v"]\"  -work altera_avalon_packets_to_master_181"                  
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../channel_adapter_181/sim/address_decode_master_0_channel_adapter_181_brosi3y.sv"]\"  -work channel_adapter_181"                                  
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../channel_adapter_181/sim/address_decode_master_0_channel_adapter_181_imsynky.sv"]\"  -work channel_adapter_181"                                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_181/sim/altera_reset_controller.v"]\"  -work altera_reset_controller_181"                                          
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_181/sim/altera_reset_synchronizer.v"]\"  -work altera_reset_controller_181"                                        
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_jtag_avalon_master_181/sim/address_decode_master_0_altera_jtag_avalon_master_181_2tlssti.v"]\"  -work altera_jtag_avalon_master_181"
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/address_decode_master_0.v"]\"  -work address_decode_master_0"                                                                                 
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
