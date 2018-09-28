source [file join [file dirname [info script]] ./../../../ip/sc_fifo/sc_fifo_rx_sc_fifo/sim/common/vcs_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/sc_fifo/sc_fifo_tx_sc_fifo/sim/common/vcs_files.tcl]

namespace eval sc_fifo {
  proc get_memory_files {QSYS_SIMDIR} {
    set memory_files [list]
    set memory_files [concat $memory_files [sc_fifo_rx_sc_fifo::get_memory_files "$QSYS_SIMDIR/../../ip/sc_fifo/sc_fifo_rx_sc_fifo/sim/"]]
    set memory_files [concat $memory_files [sc_fifo_tx_sc_fifo::get_memory_files "$QSYS_SIMDIR/../../ip/sc_fifo/sc_fifo_tx_sc_fifo/sim/"]]
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [sc_fifo_rx_sc_fifo::get_common_design_files "$QSYS_SIMDIR/../../ip/sc_fifo/sc_fifo_rx_sc_fifo/sim/"]]
    set design_files [dict merge $design_files [sc_fifo_tx_sc_fifo::get_common_design_files "$QSYS_SIMDIR/../../ip/sc_fifo/sc_fifo_tx_sc_fifo/sim/"]]
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [sc_fifo_rx_sc_fifo::get_design_files "$QSYS_SIMDIR/../../ip/sc_fifo/sc_fifo_rx_sc_fifo/sim/"]]
    set design_files [dict merge $design_files [sc_fifo_tx_sc_fifo::get_design_files "$QSYS_SIMDIR/../../ip/sc_fifo/sc_fifo_tx_sc_fifo/sim/"]]
    dict set design_files "sc_fifo.v" "$QSYS_SIMDIR/sc_fifo.v"
    return $design_files
  }
  
  proc get_elab_options {SIMULATOR_TOOL_BITNESS} {
    set ELAB_OPTIONS ""
    append ELAB_OPTIONS [sc_fifo_rx_sc_fifo::get_elab_options $SIMULATOR_TOOL_BITNESS]
    append ELAB_OPTIONS [sc_fifo_tx_sc_fifo::get_elab_options $SIMULATOR_TOOL_BITNESS]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    append SIM_OPTIONS [sc_fifo_rx_sc_fifo::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [sc_fifo_tx_sc_fifo::get_sim_options $SIMULATOR_TOOL_BITNESS]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [sc_fifo_rx_sc_fifo::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [sc_fifo_tx_sc_fifo::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    dict set ENV_VARIABLES "LD_LIBRARY_PATH" $LD_LIBRARY_PATH
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ENV_VARIABLES
  }
  
  
}
