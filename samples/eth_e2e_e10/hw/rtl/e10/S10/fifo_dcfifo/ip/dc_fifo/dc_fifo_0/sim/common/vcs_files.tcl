
namespace eval dc_fifo_0 {
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
    dict set design_files "dc_fifo_0_altera_avalon_dc_fifo_181_vevbyjq.v" "$QSYS_SIMDIR/../altera_avalon_dc_fifo_181/sim/dc_fifo_0_altera_avalon_dc_fifo_181_vevbyjq.v"
    dict set design_files "altera_dcfifo_synchronizer_bundle.v"           "$QSYS_SIMDIR/../altera_avalon_dc_fifo_181/sim/altera_dcfifo_synchronizer_bundle.v"          
    dict set design_files "altera_std_synchronizer_nocut.v"               "$QSYS_SIMDIR/../altera_avalon_dc_fifo_181/sim/altera_std_synchronizer_nocut.v"              
    dict set design_files "dc_fifo_0.v"                                   "$QSYS_SIMDIR/dc_fifo_0.v"                                                                   
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
