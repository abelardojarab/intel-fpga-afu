
namespace eval ex_100g {
  proc get_design_libraries {} {
    set libraries [dict create]
    dict set libraries altera_common_sv_packages         1
    dict set libraries altera_xcvr_atx_pll_s10_htile_180 1
    dict set libraries alt_e100s10_180                   1
    dict set libraries altera_xcvr_native_s10_htile_180  1
    dict set libraries altera_xcvr_reset_control_s10_180 1
    dict set libraries altera_xcvr_fpll_s10_htile_180    1
    dict set libraries ex_100g                           1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [dict create]
    dict set design_files "altera_common_sv_packages::altera_xcvr_native_s10_functions_h" "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_s10_htile_180/sim/altera_xcvr_native_s10_functions_h.sv"]\"  -work altera_common_sv_packages"
    return $design_files
  }
  
  proc get_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [list]
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_s10_htile_180/sim/altera_std_synchronizer_nocut.v"]\"  -work altera_xcvr_atx_pll_s10_htile_180"                                            
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_s10_htile_180/sim/alt_xcvr_resync.sv"]\" -l altera_common_sv_packages -work altera_xcvr_atx_pll_s10_htile_180"                                  
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_s10_htile_180/sim/alt_xcvr_arbiter.sv"]\" -l altera_common_sv_packages -work altera_xcvr_atx_pll_s10_htile_180"                                 
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_s10_htile_180/sim/s10_avmm_h.sv"]\" -l altera_common_sv_packages -work altera_xcvr_atx_pll_s10_htile_180"                                       
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_s10_htile_180/sim/alt_xcvr_native_anlg_reset_seq.sv"]\" -l altera_common_sv_packages -work altera_xcvr_atx_pll_s10_htile_180"                   
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_s10_htile_180/sim/alt_xcvr_pll_rcfg_arb.sv"]\" -l altera_common_sv_packages -work altera_xcvr_atx_pll_s10_htile_180"                            
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_s10_htile_180/sim/alt_xcvr_pll_embedded_debug.sv"]\" -l altera_common_sv_packages -work altera_xcvr_atx_pll_s10_htile_180"                      
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_s10_htile_180/sim/alt_xcvr_pll_avmm_csr.sv"]\" -l altera_common_sv_packages -work altera_xcvr_atx_pll_s10_htile_180"                            
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_s10_htile_180/sim/ex_100g_altera_xcvr_atx_pll_s10_htile_180_cvcjara.sv"]\" -l altera_common_sv_packages -work altera_xcvr_atx_pll_s10_htile_180"
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_atx_pll_s10_htile_180/sim/alt_xcvr_pll_rcfg_opt_logic_cvcjara.sv"]\" -l altera_common_sv_packages -work altera_xcvr_atx_pll_s10_htile_180"              
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_e100s10_180/sim/atx_pll_s100.v"]\"  -work alt_e100s10_180"                                                                                                 
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/alt_xcvr_arbiter.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"                                   
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/altera_std_synchronizer_nocut.v"]\"  -work altera_xcvr_native_s10_htile_180"                                              
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/alt_xcvr_resync_std.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"                                
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/alt_xcvr_reset_counter_s10.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"                         
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/s10_avmm_h.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"                                         
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/alt_xcvr_native_avmm_csr.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"                           
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/alt_xcvr_native_prbs_accum.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"                         
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/alt_xcvr_native_odi_accel.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"                          
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/alt_xcvr_native_rcfg_arb.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"                           
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/alt_xcvr_native_anlg_reset_seq.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"                     
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/alt_xcvr_native_dig_reset_seq.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"                      
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/alt_xcvr_native_reset_seq.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"                          
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/alt_xcvr_native_anlg_reset_seq_wrapper.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"             
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/ex_100g_altera_xcvr_native_s10_htile_180_m3pnzmq.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"   
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_native_s10_htile_180/sim/alt_xcvr_native_rcfg_opt_logic_m3pnzmq.sv"]\" -l altera_common_sv_packages -work altera_xcvr_native_s10_htile_180"             
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_e100s10_180/sim/caui4_xcvr_644.v"]\"  -work alt_e100s10_180"                                                                                               
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_reset_control_s10_180/sim/altera_std_synchronizer_nocut.v"]\"  -work altera_xcvr_reset_control_s10_180"                                            
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_reset_control_s10_180/sim/alt_xcvr_resync_std.sv"]\" -l altera_common_sv_packages -work altera_xcvr_reset_control_s10_180"                              
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_reset_control_s10_180/sim/altera_xcvr_reset_control_s10.sv"]\" -l altera_common_sv_packages -work altera_xcvr_reset_control_s10_180"                    
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_reset_control_s10_180/sim/alt_xcvr_reset_counter_s10.sv"]\" -l altera_common_sv_packages -work altera_xcvr_reset_control_s10_180"                       
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_e100s10_180/sim/s10_xcvr_reset_controller.v"]\"  -work alt_e100s10_180"                                                                                    
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_180/sim/altera_std_synchronizer_nocut.v"]\"  -work altera_xcvr_fpll_s10_htile_180"                                                  
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_180/sim/s10_avmm_h.sv"]\" -l altera_common_sv_packages -work altera_xcvr_fpll_s10_htile_180"                                             
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_180/sim/alt_xcvr_native_anlg_reset_seq.sv"]\" -l altera_common_sv_packages -work altera_xcvr_fpll_s10_htile_180"                         
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_180/sim/alt_xcvr_pll_rcfg_arb.sv"]\" -l altera_common_sv_packages -work altera_xcvr_fpll_s10_htile_180"                                  
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_180/sim/alt_xcvr_pll_embedded_debug.sv"]\" -l altera_common_sv_packages -work altera_xcvr_fpll_s10_htile_180"                            
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_180/sim/alt_xcvr_pll_avmm_csr.sv"]\" -l altera_common_sv_packages -work altera_xcvr_fpll_s10_htile_180"                                  
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_180/sim/alt_xcvr_resync.sv"]\" -l altera_common_sv_packages -work altera_xcvr_fpll_s10_htile_180"                                        
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_180/sim/alt_xcvr_arbiter.sv"]\" -l altera_common_sv_packages -work altera_xcvr_fpll_s10_htile_180"                                       
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_180/sim/ex_100g_altera_xcvr_fpll_s10_htile_180_5guwkiq.sv"]\" -l altera_common_sv_packages -work altera_xcvr_fpll_s10_htile_180"         
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_xcvr_fpll_s10_htile_180/sim/alt_xcvr_pll_rcfg_opt_logic_5guwkiq.sv"]\" -l altera_common_sv_packages -work altera_xcvr_fpll_s10_htile_180"                    
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_e100s10_180/sim/altera_xcvr_fpll_s10_tx_ext.v"]\"  -work alt_e100s10_180"                                                                                  
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_e100s10_180/sim/ex_100g_alt_e100s10_180_sqg2ueq.v"]\"  -work alt_e100s10_180"                                                                              
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_e100s10_180/sim/alt_e100s10_fecpll.v"]\"  -work alt_e100s10_180"                                                                                           
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_e100s10_180/sim/alt_e100s10_eth_4.v"]\"  -work alt_e100s10_180"                                                                                            
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_e100s10_180/sim/alt_e100s10_stats_counters.v"]\"  -work alt_e100s10_180"                                                                                   
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/ex_100g.v"]\"  -work ex_100g"                                                                                                                                     
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
