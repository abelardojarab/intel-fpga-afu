
namespace eval reset_control {
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
    dict set design_files "altera_std_synchronizer_nocut.v"  "$QSYS_SIMDIR/../altera_xcvr_reset_control_s10_181/sim/altera_std_synchronizer_nocut.v" 
    dict set design_files "alt_xcvr_resync_std.sv"           "$QSYS_SIMDIR/../altera_xcvr_reset_control_s10_181/sim/alt_xcvr_resync_std.sv"          
    dict set design_files "altera_xcvr_reset_control_s10.sv" "$QSYS_SIMDIR/../altera_xcvr_reset_control_s10_181/sim/altera_xcvr_reset_control_s10.sv"
    dict set design_files "alt_xcvr_reset_counter_s10.sv"    "$QSYS_SIMDIR/../altera_xcvr_reset_control_s10_181/sim/alt_xcvr_reset_counter_s10.sv"   
    dict set design_files "reset_control.v"                  "$QSYS_SIMDIR/reset_control.v"                                                          
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
