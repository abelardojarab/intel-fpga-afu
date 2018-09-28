source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_tx_sc_fifo/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_mm_to_mac/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_tx_xcvr_half_clk/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_mm_to_phy/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_rx_sc_fifo/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_rx_xcvr_clk/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_clk_csr/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_eth_gen_mon/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_master_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_merlin_master_translator_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/address_decode/address_decode_tx_xcvr_clk/sim/common/modelsim_files.tcl]

namespace eval address_decode {
  proc get_design_libraries {} {
    set libraries [dict create]
    set libraries [dict merge $libraries [address_decode_tx_sc_fifo::get_design_libraries]]
    set libraries [dict merge $libraries [address_decode_mm_to_mac::get_design_libraries]]
    set libraries [dict merge $libraries [address_decode_tx_xcvr_half_clk::get_design_libraries]]
    set libraries [dict merge $libraries [address_decode_mm_to_phy::get_design_libraries]]
    set libraries [dict merge $libraries [address_decode_rx_sc_fifo::get_design_libraries]]
    set libraries [dict merge $libraries [address_decode_rx_xcvr_clk::get_design_libraries]]
    set libraries [dict merge $libraries [address_decode_clk_csr::get_design_libraries]]
    set libraries [dict merge $libraries [address_decode_eth_gen_mon::get_design_libraries]]
    set libraries [dict merge $libraries [address_decode_master_0::get_design_libraries]]
    set libraries [dict merge $libraries [address_decode_merlin_master_translator_0::get_design_libraries]]
    set libraries [dict merge $libraries [address_decode_tx_xcvr_clk::get_design_libraries]]
    dict set libraries altera_merlin_master_translator_181          1
    dict set libraries altera_merlin_slave_translator_181           1
    dict set libraries altera_merlin_master_agent_181               1
    dict set libraries altera_merlin_slave_agent_181                1
    dict set libraries altera_avalon_sc_fifo_181                    1
    dict set libraries altera_merlin_router_181                     1
    dict set libraries altera_merlin_traffic_limiter_181            1
    dict set libraries alt_hiconnect_sc_fifo_181                    1
    dict set libraries altera_merlin_burst_adapter_181              1
    dict set libraries altera_merlin_demultiplexer_181              1
    dict set libraries altera_merlin_multiplexer_181                1
    dict set libraries altera_avalon_st_handshake_clock_crosser_181 1
    dict set libraries altera_mm_interconnect_181                   1
    dict set libraries altera_reset_controller_181                  1
    dict set libraries address_decode                               1
    return $libraries
  }
  
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
  
  proc get_common_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [address_decode_tx_sc_fifo::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_sc_fifo/sim/"]]
    set design_files [dict merge $design_files [address_decode_mm_to_mac::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_mm_to_mac/sim/"]]
    set design_files [dict merge $design_files [address_decode_tx_xcvr_half_clk::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_xcvr_half_clk/sim/"]]
    set design_files [dict merge $design_files [address_decode_mm_to_phy::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_mm_to_phy/sim/"]]
    set design_files [dict merge $design_files [address_decode_rx_sc_fifo::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_rx_sc_fifo/sim/"]]
    set design_files [dict merge $design_files [address_decode_rx_xcvr_clk::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_rx_xcvr_clk/sim/"]]
    set design_files [dict merge $design_files [address_decode_clk_csr::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_clk_csr/sim/"]]
    set design_files [dict merge $design_files [address_decode_eth_gen_mon::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_eth_gen_mon/sim/"]]
    set design_files [dict merge $design_files [address_decode_master_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_master_0/sim/"]]
    set design_files [dict merge $design_files [address_decode_merlin_master_translator_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_merlin_master_translator_0/sim/"]]
    set design_files [dict merge $design_files [address_decode_tx_xcvr_clk::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_xcvr_clk/sim/"]]
    return $design_files
  }
  
  proc get_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [list]
    set design_files [concat $design_files [address_decode_tx_sc_fifo::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_sc_fifo/sim/"]]
    set design_files [concat $design_files [address_decode_mm_to_mac::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_mm_to_mac/sim/"]]
    set design_files [concat $design_files [address_decode_tx_xcvr_half_clk::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_xcvr_half_clk/sim/"]]
    set design_files [concat $design_files [address_decode_mm_to_phy::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_mm_to_phy/sim/"]]
    set design_files [concat $design_files [address_decode_rx_sc_fifo::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_rx_sc_fifo/sim/"]]
    set design_files [concat $design_files [address_decode_rx_xcvr_clk::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_rx_xcvr_clk/sim/"]]
    set design_files [concat $design_files [address_decode_clk_csr::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_clk_csr/sim/"]]
    set design_files [concat $design_files [address_decode_eth_gen_mon::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_eth_gen_mon/sim/"]]
    set design_files [concat $design_files [address_decode_master_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_master_0/sim/"]]
    set design_files [concat $design_files [address_decode_merlin_master_translator_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_merlin_master_translator_0/sim/"]]
    set design_files [concat $design_files [address_decode_tx_xcvr_clk::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/address_decode/address_decode_tx_xcvr_clk/sim/"]]
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_translator_181/sim/address_decode_altera_merlin_master_translator_181_mhudjri.sv"]\"  -work altera_merlin_master_translator_181"                      
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_translator_181/sim/address_decode_altera_merlin_slave_translator_181_5aswt6a.sv"]\"  -work altera_merlin_slave_translator_181"                         
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_agent_181/sim/address_decode_altera_merlin_master_agent_181_t5eyqrq.sv"]\"  -work altera_merlin_master_agent_181"                                     
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_agent_181/sim/address_decode_altera_merlin_slave_agent_181_a7g37xa.sv"]\"  -work altera_merlin_slave_agent_181"                                        
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_agent_181/sim/altera_merlin_burst_uncompressor.sv"]\"  -work altera_merlin_slave_agent_181"                                                            
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_sc_fifo_181/sim/address_decode_altera_avalon_sc_fifo_181_hseo73i.v"]\"  -work altera_avalon_sc_fifo_181"                                                         
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_181/sim/address_decode_altera_merlin_router_181_dqij2zy.sv"]\"  -work altera_merlin_router_181"                                                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_181/sim/address_decode_altera_merlin_router_181_fet5uza.sv"]\"  -work altera_merlin_router_181"                                                       
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_181/sim/address_decode_altera_merlin_traffic_limiter_181_ohcvrpq.v"]\"  -work altera_merlin_traffic_limiter_181"                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/address_decode_alt_hiconnect_sc_fifo_181_cjmuh4a.sv"]\"  -work alt_hiconnect_sc_fifo_181"                                                    
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/alt_st_infer_scfifo.sv"]\"  -work alt_hiconnect_sc_fifo_181"                                                                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/alt_st_mlab_scfifo.sv"]\"  -work alt_hiconnect_sc_fifo_181"                                                                                  
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/alt_st_fifo_empty.sv"]\"  -work alt_hiconnect_sc_fifo_181"                                                                                   
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/alt_st_mlab_scfifo_a6.sv"]\"  -work alt_hiconnect_sc_fifo_181"                                                                               
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/alt_st_mlab_scfifo_a7.sv"]\"  -work alt_hiconnect_sc_fifo_181"                                                                               
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_hiconnect_sc_fifo_181/sim/alt_st_reg_scfifo.sv"]\"  -work alt_hiconnect_sc_fifo_181"                                                                                   
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_181/sim/address_decode_altera_merlin_traffic_limiter_181_avmww2q.v"]\"  -work altera_merlin_traffic_limiter_181"                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_181/sim/altera_merlin_reorder_memory.sv"]\"  -work altera_merlin_traffic_limiter_181"                                                        
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_181/sim/altera_avalon_st_pipeline_base.v"]\"  -work altera_merlin_traffic_limiter_181"                                                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_181/sim/address_decode_altera_merlin_traffic_limiter_181_reppfiq.sv"]\"  -work altera_merlin_traffic_limiter_181"                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/address_decode_altera_merlin_burst_adapter_181_hpj5oyy.sv"]\"  -work altera_merlin_burst_adapter_181"                                  
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_merlin_burst_adapter_uncmpr.sv"]\"  -work altera_merlin_burst_adapter_181"                                                      
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_merlin_burst_adapter_13_1.sv"]\"  -work altera_merlin_burst_adapter_181"                                                        
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_merlin_burst_adapter_new.sv"]\"  -work altera_merlin_burst_adapter_181"                                                         
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_incr_burst_converter.sv"]\"  -work altera_merlin_burst_adapter_181"                                                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_wrap_burst_converter.sv"]\"  -work altera_merlin_burst_adapter_181"                                                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_default_burst_converter.sv"]\"  -work altera_merlin_burst_adapter_181"                                                          
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_merlin_address_alignment.sv"]\"  -work altera_merlin_burst_adapter_181"                                                         
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_avalon_st_pipeline_stage.sv"]\"  -work altera_merlin_burst_adapter_181"                                                         
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_181/sim/altera_avalon_st_pipeline_base.v"]\"  -work altera_merlin_burst_adapter_181"                                                           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_181/sim/address_decode_altera_merlin_demultiplexer_181_233qqei.sv"]\"  -work altera_merlin_demultiplexer_181"                                  
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_181/sim/address_decode_altera_merlin_multiplexer_181_or5baiy.sv"]\"  -work altera_merlin_multiplexer_181"                                        
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_181/sim/altera_merlin_arbitrator.sv"]\"  -work altera_merlin_multiplexer_181"                                                                    
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_181/sim/address_decode_altera_merlin_demultiplexer_181_qc6ddcy.sv"]\"  -work altera_merlin_demultiplexer_181"                                  
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_181/sim/address_decode_altera_merlin_multiplexer_181_tzqtjwa.sv"]\"  -work altera_merlin_multiplexer_181"                                        
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_181/sim/altera_merlin_arbitrator.sv"]\"  -work altera_merlin_multiplexer_181"                                                                    
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_handshake_clock_crosser_181/sim/address_decode_altera_avalon_st_handshake_clock_crosser_181_oeeupgi.v"]\"  -work altera_avalon_st_handshake_clock_crosser_181"
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_handshake_clock_crosser_181/sim/altera_avalon_st_clock_crosser.v"]\"  -work altera_avalon_st_handshake_clock_crosser_181"                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_handshake_clock_crosser_181/sim/altera_avalon_st_pipeline_base.v"]\"  -work altera_avalon_st_handshake_clock_crosser_181"                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_handshake_clock_crosser_181/sim/altera_std_synchronizer_nocut.v"]\"  -work altera_avalon_st_handshake_clock_crosser_181"                                  
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_181/sim/address_decode_altera_mm_interconnect_181_egdbf5q.v"]\"  -work altera_mm_interconnect_181"                                                      
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_181/sim/altera_reset_controller.v"]\"  -work altera_reset_controller_181"                                                                              
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_181/sim/altera_reset_synchronizer.v"]\"  -work altera_reset_controller_181"                                                                            
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/address_decode.v"]\"  -work address_decode"                                                                                                                                       
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
