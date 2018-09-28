
namespace eval pll {
  proc get_memory_files {QSYS_SIMDIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    dict set design_files "altera_common_sv_packages::altera_xcvr_native_s10_functions_h" "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_181/sim/altera_xcvr_native_s10_functions_h.sv"
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    dict set design_files "altera_std_synchronizer_nocut.v"               "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_181/sim/altera_std_synchronizer_nocut.v"              
    dict set design_files "s10_avmm_h.sv"                                 "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_181/sim/s10_avmm_h.sv"                                
    dict set design_files "alt_xcvr_native_anlg_reset_seq.sv"             "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_181/sim/alt_xcvr_native_anlg_reset_seq.sv"            
    dict set design_files "alt_xcvr_pll_rcfg_arb.sv"                      "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_181/sim/alt_xcvr_pll_rcfg_arb.sv"                     
    dict set design_files "alt_xcvr_pll_embedded_debug.sv"                "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_181/sim/alt_xcvr_pll_embedded_debug.sv"               
    dict set design_files "alt_xcvr_pll_avmm_csr.sv"                      "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_181/sim/alt_xcvr_pll_avmm_csr.sv"                     
    dict set design_files "alt_xcvr_resync.sv"                            "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_181/sim/alt_xcvr_resync.sv"                           
    dict set design_files "alt_xcvr_arbiter.sv"                           "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_181/sim/alt_xcvr_arbiter.sv"                          
    dict set design_files "pll_altera_xcvr_fpll_s10_htile_181_3xznj3i.sv" "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_181/sim/pll_altera_xcvr_fpll_s10_htile_181_3xznj3i.sv"
    dict set design_files "alt_xcvr_pll_rcfg_opt_logic_3xznj3i.sv"        "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_181/sim/alt_xcvr_pll_rcfg_opt_logic_3xznj3i.sv"       
    dict set design_files "pll.v"                                         "$QSYS_SIMDIR/pll.v"                                                                              
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
