# (C) 2001-2018 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# -------------------------------------------------------------------------- #
# - 
# --- This file contains helper functions for Native PHY SDC file
# -
# -------------------------------------------------------------------------- #
set script_dir [file dirname [info script]]

load_package sdc_ext
load_package design

if {![info exists native_debug]} {
  global ::native_debug
}

set native_debug 0

# Create dictionary to map clocks to their respective target node
if {[info exists alt_xcvr_native_s10_target_clock_list_dict]} {
   unset alt_xcvr_native_s10_target_clock_list_dict
}
global ::alt_xcvr_native_s10_target_clock_list_dict
set alt_xcvr_native_s10_target_clock_list_dict [dict create]

# -------------------------------------------------------------------------- #
# ---                                                                    --- #
# --- Procedure to initialize the database of all required pins and      --- #
# --- registers to create clocks                                         --- #
# ---                                                                    --- #
# -------------------------------------------------------------------------- #
proc native_initialize_db_m3pnzmq { native_db } {

  # upvar links one variable to another variable at specified level of execution
  upvar $native_db local_native_db

  # Set the GLOBAL_corename in ip_parameters.tcl 
  global ::GLOBAL_corename
  global ::native_debug

  # Delete the database if it exists
  if [info exists local_native_db] {
    post_message -type info "IP SDC: Database existed before, deleting it now"
    unset local_native_db
  } 

  set local_native_db [dict create]

  post_message -type info "IP SDC: Initializing S10 Native PHY database for CORE $::GLOBAL_corename"

  # Find the current Native PHY instance name in the design
  set instance_name [get_current_instance]

  # Create dictionary of pins
  post_message -type info "IP SDC: Finding port-to-pin mapping for CORE: $::GLOBAL_corename INSTANCE: $instance_name"
  set all_pins [dict create]
  native_get_pins_m3pnzmq $all_pins
  
  # Set the associative array
  dict set local_native_db $instance_name $all_pins

}


# -------------------------------------------------------------------------- #
# ---                                                                    --- #
# --- Procedure to find all the pins and registers for nodes of interest --- #
# ---                                                                    --- #
# -------------------------------------------------------------------------- #
proc native_get_pins_m3pnzmq { all_pins } {

  global ::native_debug

  # We need to make a local copy of the allpins associative array
  upvar all_pins native_pins

  # ------------------------------------------------------------------------- #
  # Define the pins here 
  # Include regex to grab pins for multiple channels

  # Dummy refclk source node
  set aib_tx_clk_source_node g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~aib_tx_clk_source
  set aib_rx_clk_source_node g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx~aib_rx_clk_source

  # Dummy flipflop to add large Tco to ensure timing failure in transfers between channels
  set aib_tx_internal_div_reg_node g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~aib_tx_internal_div.reg
  set aib_rx_internal_div_reg_node g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx~aib_rx_internal_div.reg

  # Output clocks from main adapter to core
  set tx_clkout_pin  g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_pcs_tx_clk_out1_dcm
  set tx_clkout2_pin g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_pcs_tx_clk_out2_dcm
  set rx_clkout_pin  g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_pcs_rx_clk_out1_dcm
  set rx_clkout2_pin g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_pcs_rx_clk_out2_dcm

  # Input clocks to main adapter from aib
  set aib_fabric_rx_transfer_clk_pin g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|aib_fabric_rx_transfer_clk

  # hclk
  set hclk_pin                       g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_pma_hclk_hioint
  set aib_hclk_internal_div_reg_node g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx~aib_hclk_internal_div.reg

  # ------------------------------------------------------------------------- #
  # Create a dictionary for each clock pin 
  set native_pins [dict create]

  # ------------------------------------------------------------------------- #
  set aib_tx_clk_source_id [get_nodes -nowarn $aib_tx_clk_source_node]

  if {[get_collection_size $aib_tx_clk_source_id] > 0} {
    foreach_in_collection clk $aib_tx_clk_source_id {
      dict lappend native_pins tx_pma_parallel_clk [get_node_info -name $clk] 
    }

    if {$native_debug == 1} {
      post_message -type info "IP SDC: After getting AIB TX CLK SOURCE node info: [dict get $native_pins tx_pma_parallel_clk]"
    }

    dict set native_pins tx_pma_parallel_clk [join [lsort -dictionary [dict get $native_pins tx_pma_parallel_clk]]]

  } else {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: Could not find pins for AIB TX CLK SOURCE"
    }
  }

  # ------------------------------------------------------------------------- #
  set aib_rx_clk_source_id [get_nodes -nowarn $aib_rx_clk_source_node]

  if {[get_collection_size $aib_rx_clk_source_id] > 0} {
    foreach_in_collection clk $aib_rx_clk_source_id {
      dict lappend native_pins rx_pma_parallel_clk [get_node_info -name $clk] 
    }

    if {$native_debug == 1} {
      post_message -type info "IP SDC: After getting AIB TX CLK SOURCE node info: [dict get $native_pins rx_pma_parallel_clk]"
    }

    dict set native_pins rx_pma_parallel_clk [join [lsort -dictionary [dict get $native_pins rx_pma_parallel_clk]]]

  } else {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: Could not find nodes for AIB RX CLK SOURCE"
    }
  }

  # ------------------------------------------------------------------------- #
  set aib_tx_internal_div_reg_id [get_registers -nowarn $aib_tx_internal_div_reg_node]

  if {[get_collection_size $aib_tx_internal_div_reg_id] > 0} {
    foreach_in_collection clk $aib_tx_internal_div_reg_id {
      dict lappend native_pins tx_pcs_x2_clk [get_node_info -name $clk] 
    }

    if {$native_debug == 1} {
      post_message -type info "IP SDC: After getting AIB TX INTERNAL DIV REG node info: [dict get $native_pins tx_pcs_x2_clk]"
    }

    dict set native_pins tx_pcs_x2_clk [join [lsort -dictionary [dict get $native_pins tx_pcs_x2_clk]]]

  } else {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: Could not find registers for AIB TX INTERNAL DIV REG"
    }
  }

  # ------------------------------------------------------------------------- #
  set aib_rx_internal_div_reg_id [get_registers -nowarn $aib_rx_internal_div_reg_node]

  if {[get_collection_size $aib_rx_internal_div_reg_id] > 0} {
    foreach_in_collection clk $aib_rx_internal_div_reg_id {
      dict lappend native_pins rx_pcs_x2_clk [get_node_info -name $clk] 
    }

    if {$native_debug == 1} {
      post_message -type info "IP SDC: After getting AIB RX INTERNAL DIV REG node info: [dict get $native_pins rx_pcs_x2_clk]"
    }

    dict set native_pins rx_pcs_x2_clk [join [lsort -dictionary [dict get $native_pins rx_pcs_x2_clk]]]

  } else {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: Could not find registers for AIB RX INTERNAL DIV REG"
    }
  }

  # ------------------------------------------------------------------------- #
  set tx_clkout_id [get_pins -compatibility_mode -nowarn $tx_clkout_pin]

  if {[get_collection_size $tx_clkout_id] == 0} {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: pld_pcs_tx_clk_out1_dcm does not exist."
    }
  }

  if {[get_collection_size $tx_clkout_id] > 0} {
    foreach_in_collection clk $tx_clkout_id {
      dict lappend native_pins tx_clkout [get_pin_info -name $clk] 
      # Pipe clocks
      dict lappend native_pins tx_clkout_pipe_g1 [get_pin_info -name $clk]
      dict lappend native_pins tx_clkout_pipe_g2 [get_pin_info -name $clk]
      dict lappend native_pins tx_clkout_pipe_g3 [get_pin_info -name $clk] 
    }

    if {$native_debug == 1} {
      post_message -type info "IP SDC: After getting TX CLKOUT node info: [dict get $native_pins tx_clkout]"
    }

    dict set native_pins tx_clkout [join [lsort -dictionary [dict get $native_pins tx_clkout]]]
    dict set native_pins tx_clkout_pipe_g1 [join [lsort -dictionary [dict get $native_pins tx_clkout_pipe_g1]]]
    dict set native_pins tx_clkout_pipe_g2 [join [lsort -dictionary [dict get $native_pins tx_clkout_pipe_g2]]]
    dict set native_pins tx_clkout_pipe_g3 [join [lsort -dictionary [dict get $native_pins tx_clkout_pipe_g3]]]

  } else {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: Could not find pins for TX CLKOUT"
    }
  }

  # ------------------------------------------------------------------------- #
  set tx_clkout2_id [get_pins -compatibility_mode -nowarn $tx_clkout2_pin]

  if {[get_collection_size $tx_clkout2_id] == 0} {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: pld_pcs_tx_clk_out2_dcm does not exist."
    }
  }

  if {[get_collection_size $tx_clkout2_id] > 0} {
    foreach_in_collection clk $tx_clkout2_id {
      dict lappend native_pins tx_clkout2 [get_pin_info -name $clk] 
      # Pipe clocks
      dict lappend native_pins tx_clkout2_pipe_g1 [get_pin_info -name $clk]
      dict lappend native_pins tx_clkout2_pipe_g2 [get_pin_info -name $clk]
      dict lappend native_pins tx_clkout2_pipe_g3 [get_pin_info -name $clk]
    }

    if {$native_debug == 1} {
      post_message -type info "IP SDC: After getting TX CLKOUT2 node info: [dict get $native_pins tx_clkout2]"
    }

    dict set native_pins tx_clkout2 [join [lsort -dictionary [dict get $native_pins tx_clkout2]]]
    dict set native_pins tx_clkout2_pipe_g1 [join [lsort -dictionary [dict get $native_pins tx_clkout2_pipe_g1]]]
    dict set native_pins tx_clkout2_pipe_g2 [join [lsort -dictionary [dict get $native_pins tx_clkout2_pipe_g2]]]
    dict set native_pins tx_clkout2_pipe_g3 [join [lsort -dictionary [dict get $native_pins tx_clkout2_pipe_g3]]]

  } else {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: Could not find pins for TX CLKOUT2"
    }
  }

  # ------------------------------------------------------------------------- #
  set rx_clkout_id [get_pins -compatibility_mode -nowarn $rx_clkout_pin]

  if {[get_collection_size $rx_clkout_id] == 0} {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: pld_pcs_rx_clk_out1_dcm does not exist."
    }
  }

  if {[get_collection_size $rx_clkout_id] > 0} {
    foreach_in_collection clk $rx_clkout_id {
      dict lappend native_pins rx_clkout [get_pin_info -name $clk]
      # Pipe clocks
      dict lappend native_pins rx_clkout_pipe_g1 [get_pin_info -name $clk]
      dict lappend native_pins rx_clkout_pipe_g2 [get_pin_info -name $clk]
      dict lappend native_pins rx_clkout_pipe_g3 [get_pin_info -name $clk]
    }

    if {$native_debug == 1} {
      post_message -type info "IP SDC: After getting RX CLKOUT node info: [dict get $native_pins rx_clkout]"
    }

    dict set native_pins rx_clkout [join [lsort -dictionary [dict get $native_pins rx_clkout]]]
    dict set native_pins rx_clkout_pipe_g1 [join [lsort -dictionary [dict get $native_pins rx_clkout_pipe_g1]]]
    dict set native_pins rx_clkout_pipe_g2 [join [lsort -dictionary [dict get $native_pins rx_clkout_pipe_g2]]]
    dict set native_pins rx_clkout_pipe_g3 [join [lsort -dictionary [dict get $native_pins rx_clkout_pipe_g3]]]

  } else {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: Could not find pins for RX CLKOUT"
    }
  }

  # ------------------------------------------------------------------------- #
  set rx_clkout2_id [get_pins -compatibility_mode -nowarn $rx_clkout2_pin]

  if {[get_collection_size $rx_clkout2_id] == 0} {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: pld_pcs_rx_clk_out2_dcm does not exist."
    }
  }

  if {[get_collection_size $rx_clkout2_id] > 0} {
    foreach_in_collection clk $rx_clkout2_id {
      dict lappend native_pins rx_clkout2 [get_pin_info -name $clk]
      # Pipe clocks
      dict lappend native_pins rx_clkout2_pipe_g1 [get_pin_info -name $clk]
      dict lappend native_pins rx_clkout2_pipe_g2 [get_pin_info -name $clk]
      dict lappend native_pins rx_clkout2_pipe_g3 [get_pin_info -name $clk]
    }

    if {$native_debug == 1} {
      post_message -type info "IP SDC: After getting RX CLKOUT2 node info: [dict get $native_pins rx_clkout2]"
    }

    dict set native_pins rx_clkout2 [join [lsort -dictionary [dict get $native_pins rx_clkout2]]]
    dict set native_pins rx_clkout2_pipe_g1 [join [lsort -dictionary [dict get $native_pins rx_clkout2_pipe_g1]]]
    dict set native_pins rx_clkout2_pipe_g2 [join [lsort -dictionary [dict get $native_pins rx_clkout2_pipe_g2]]]
    dict set native_pins rx_clkout2_pipe_g3 [join [lsort -dictionary [dict get $native_pins rx_clkout2_pipe_g3]]]

  } else {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: Could not find pins for RX CLKOUT2"
    }
  }

  # ------------------------------------------------------------------------- #
  set rx_transfer_clk_id [get_pins -compatibility_mode -nowarn $aib_fabric_rx_transfer_clk_pin]

  if {[get_collection_size $rx_transfer_clk_id] > 0} {
    foreach_in_collection clk $rx_transfer_clk_id {
      dict lappend native_pins rx_transfer_clk [get_pin_info -name $clk]
      dict lappend native_pins rx_transfer_clk2 [get_pin_info -name $clk] 
      dict lappend native_pins rx_transfer_clk_pipe_g1  [get_pin_info -name $clk]
      dict lappend native_pins rx_transfer_clk2_pipe_g1 [get_pin_info -name $clk] 
      dict lappend native_pins rx_transfer_clk_pipe_g2  [get_pin_info -name $clk]
      dict lappend native_pins rx_transfer_clk2_pipe_g2 [get_pin_info -name $clk] 
      dict lappend native_pins rx_transfer_clk_pipe_g3  [get_pin_info -name $clk]
      dict lappend native_pins rx_transfer_clk2_pipe_g3 [get_pin_info -name $clk] 
    }

    if {$native_debug == 1} {
      post_message -type info "IP SDC: After getting RX TRANSFER CLK node info: [dict get $native_pins rx_transfer_clk]"
    }

    dict set native_pins rx_transfer_clk [join [lsort -dictionary [dict get $native_pins rx_transfer_clk]]]
    dict set native_pins rx_transfer_clk2 [join [lsort -dictionary [dict get $native_pins rx_transfer_clk2]]]
    dict set native_pins rx_transfer_clk_pipe_g1  [join [lsort -dictionary [dict get $native_pins rx_transfer_clk_pipe_g1]]]
    dict set native_pins rx_transfer_clk2_pipe_g1 [join [lsort -dictionary [dict get $native_pins rx_transfer_clk2_pipe_g1]]]
    dict set native_pins rx_transfer_clk_pipe_g2  [join [lsort -dictionary [dict get $native_pins rx_transfer_clk_pipe_g2]]]
    dict set native_pins rx_transfer_clk2_pipe_g2 [join [lsort -dictionary [dict get $native_pins rx_transfer_clk2_pipe_g2]]]
    dict set native_pins rx_transfer_clk_pipe_g3  [join [lsort -dictionary [dict get $native_pins rx_transfer_clk_pipe_g3]]]
    dict set native_pins rx_transfer_clk2_pipe_g3 [join [lsort -dictionary [dict get $native_pins rx_transfer_clk2_pipe_g3]]]

  } else {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: Could not find pins for RX TRANSFER CLK"
    }
  }

  # ------------------------------------------------------------------------- #
  set hclk_pin_id [get_pins -compatibility_mode -nowarn $hclk_pin]

  if {[get_collection_size $hclk_pin_id] > 0} {
    foreach_in_collection clk $hclk_pin_id {
      dict lappend native_pins hclk [get_pin_info -name $clk] 
    }

    if {$native_debug == 1} {
      post_message -type info "IP SDC: After getting HCLK node info: [dict get $native_pins hclk]"
    }

    dict set native_pins hclk [join [lsort -dictionary [dict get $native_pins hclk]]]

  } else {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: Could not find pins for HCLK"
    }
  }

  # ------------------------------------------------------------------------- #
  set aib_hclk_internal_div_reg_id [get_registers -nowarn $aib_hclk_internal_div_reg_node]

  if {[get_collection_size $aib_hclk_internal_div_reg_id] > 0} {
    foreach_in_collection clk $aib_hclk_internal_div_reg_id {
      dict lappend native_pins hclk_internal_div_reg [get_node_info -name $clk] 
    }

    if {$native_debug == 1} {
      post_message -type info "IP SDC: After getting AIB HCLK INTERNAL DIV REG node info: [dict get $native_pins hclk_internal_div_reg]"
    }

    dict set native_pins hclk_internal_div_reg [join [lsort -dictionary [dict get $native_pins hclk_internal_div_reg]]]

  } else {
    if {$native_debug == 1} {
      post_message -type info "IP SDC: Could not find registers for AIB HCLK INTERNAL DIV REG"
    }
  }

}

# -------------------------------------------------------------------------------- #
# ---                                                                          --- #
# --- Procedure to call procedure to create clocks all channels in an instance --- #
# ---                                                                          --- #
# -------------------------------------------------------------------------------- #
proc native_prepare_to_create_clocks_all_ch_m3pnzmq { instance num_channels mode mode_clks profile_cnt profile alt_xcvr_native_s10_pins clk_freq_dict multiply_factor_dict divide_factor_dict all_profile_clocks_names } {
  global ::native_debug

  set list_of_clk_names [list]

  foreach clk_group $mode_clks { # Each mode can have multiple clocks; iterate over them
    if { $native_debug } {
      post_message -type info "IP SDC: Clock group in $mode_clks is: $clk_group"
    }

    if { [dict exists $alt_xcvr_native_s10_pins $instance $clk_group] } {

      set clk_pins [dict get $alt_xcvr_native_s10_pins $instance $clk_group]

      if { $native_debug } {
        post_message -type info "IP SDC: Pins for $clk_group: $clk_pins"
      }

      if { [llength $clk_pins] > 0 } { # Check to see if the corresponding pins exists 

        #Remap any backward slashes '' in the pins
        set clk_pins [string map {\\ \\\\} $clk_pins] 

        if { $mode == "tx_source_clks" || $mode == "rx_source_clks"} {
          set clk_freq [dict get $clk_freq_dict $clk_group]

          # Create clks for all channels for a clk group in mode clk
          lappend list_of_clk_names [native_create_clocks_all_ch_m3pnzmq $instance $clk_group $num_channels $clk_freq $clk_pins $profile_cnt $profile]

        } else {
          set clk_freq ""
          set multiply_factor [dict get $multiply_factor_dict $clk_group]
          set divide_factor   [dict get $divide_factor_dict   $clk_group]

          if { $clk_group == "tx_pcs_x2_clk" } {
            set source_nodes  [dict get $alt_xcvr_native_s10_pins $instance tx_pma_parallel_clk]
            set master_clocks [dict get $all_profile_clocks_names $profile  tx_source_clks]

          } elseif { $clk_group == "rx_pcs_x2_clk" } {
            set source_nodes  [dict get $alt_xcvr_native_s10_pins $instance rx_pma_parallel_clk]
            set master_clocks [dict get $all_profile_clocks_names $profile  rx_source_clks]

          } elseif { $clk_group == "hclk_internal_div_reg" } {
            set source_nodes  [dict get $alt_xcvr_native_s10_pins $instance rx_pma_parallel_clk]
            set master_clocks [dict get $all_profile_clocks_names $profile  rx_source_clks]

          } elseif { $mode == "tx_mode_clks" } {
            set source_nodes  [dict get $alt_xcvr_native_s10_pins $instance tx_pcs_x2_clk]
            set master_clocks [dict get $all_profile_clocks_names $profile  tx_internal_div_reg_clks]

          } elseif { $mode == "rx_mode_clks" } {
            
            # For rx_clkout2, check if RX is in register mode and rx_transfer_clk was created
            set full_instance_split [ split $instance | ]  
            set full_instance_split [lreplace $full_instance_split end end]
            set short_inst_name [join $full_instance_split "|"]
            set rx_transfer_clk_col [get_clocks -nowarn ${short_inst_name}*rx_transfer_clk|ch*]

            if {[get_collection_size $rx_transfer_clk_col] > 0} {
              set rx_transfer_clk_name_list [list]
              foreach_in_collection clk $rx_transfer_clk_col {
                lappend rx_transfer_clk_name_list [get_clock_info -name $clk]
              }
              set rx_transfer_clk_name_list [join [lsort -dictionary $rx_transfer_clk_name_list]]

              set source_nodes  [dict get $alt_xcvr_native_s10_pins $instance rx_transfer_clk]
              set master_clocks $rx_transfer_clk_name_list
            } else {
              set source_nodes  [dict get $alt_xcvr_native_s10_pins $instance rx_pcs_x2_clk]
              set master_clocks [dict get $all_profile_clocks_names $profile  rx_internal_div_reg_clks]
            }

          } elseif { $mode == "hclk_mode" } {
            set source_nodes  [dict get $alt_xcvr_native_s10_pins $instance hclk_internal_div_reg]
            set master_clocks [dict get $all_profile_clocks_names $profile  hclk_internal_div_reg_clks]

          } else {
            post_message -type warning "IP SDC Warning: Cannot find source node for $clk_group key in group $mode"
          }

          #Remap any backward slashes '' in the source clock nodes
          set source_nodes [string map {\\ \\\\} $source_nodes] 

          # Create clks for all channels for a clk group in mode clk
          lappend list_of_clk_names [native_create_clocks_all_ch_m3pnzmq $instance $clk_group $num_channels $clk_freq $clk_pins $profile_cnt $profile $source_nodes $master_clocks $multiply_factor $divide_factor]
        }
      }

     } else {
       if {$native_debug == 1} {
         post_message -type warning "IP SDC Warning: $clk_group key does not exist in pins dictionary"
       }
     }
  } ; # foreach clk_group in mode_clks

  return $list_of_clk_names

}

# ----------------------------------------------------------------------------- #
# ---                                                                       --- #
# --- Procedure to create HSSI clocks for all channels in an instance       --- #
# ---                                                                       --- #
# ----------------------------------------------------------------------------- #
proc native_create_clocks_all_ch_m3pnzmq { instance clk_group num_channels freq clk_list profile_cnt profile args } {
  global ::native_debug

  set clock_name_list [list]

  # Remove the 'xcvr_native_s10_0' from each full instance name
  set full_instance_split [ split $instance | ]  
  set full_instance_split [lreplace $full_instance_split end end]
  set short_inst_name [join $full_instance_split "|"]

  # Replace any '[' and ']' characters with with '?' since Tcl string matching doesn't work with explicit '[' and ']' characters
  set regex_instance [regsub -all {\[} $instance {?}]
  set regex_instance [regsub -all {\]} $regex_instance {?}]

  # Iterate through all channels
  for { set channel 0 } { $channel < $num_channels } { incr channel } {

    # Match channel node with nodes in the clock group
    set channel_node_regexp $regex_instance|g_xcvr_native_insts?$channel?.ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_?x.inst_ct1_hssi_pldadapt_?x*
    set channel_node_regexp [string map {\\ \\\\} $channel_node_regexp]
    set matching_clk_nodes  [lsearch -inline $clk_list $channel_node_regexp]
    set matching_clk_nodes  [string map {\\ \\\\} $matching_clk_nodes]

    if { $native_debug == 1 } {
      post_message -type info "IP SDC: Matching Channel $channel nodes: $matching_clk_nodes"
    }

    # Iterate through all nodes in the clock group
    foreach clk_node $matching_clk_nodes {

      # Remove the instance name from the clock node due to auto promotion in SDC_ENTITY
      set no_inst_clk_node [string replace $clk_node 0 [string length $instance]]
  
      # Shorten the clock name if multiple profiles are not used
      if { $profile_cnt > 1 } { 
        set clock_name ${short_inst_name}|profile$profile|$clk_group|ch$channel
      } else {
        set clock_name ${short_inst_name}|$clk_group|ch$channel
      }
      # Add the clock name to the list 
      lappend clock_name_list $clock_name
      
      # Check if clock with same name already exists, if so skip clock creation
      set matching_clocks_list [get_clocks -nowarn $clock_name]

      if { [get_collection_size $matching_clocks_list] > 0 } {
        foreach_in_collection matching_clk $matching_clocks_list {

          # Check if clock is declared AND defined (i.e. create_clock or create_generated_clock was used)
          if { [is_clock_defined $clock_name] == 1 } {
            if { $native_debug == 1 } {
              post_message -type warning "Clock already exists with name $clock_name with period [get_clock_info $matching_clk -period]ns on node [get_object_info -name [get_clock_info $matching_clk -targets]]"
            }

          # Clock was declared, but not defined, so we need to create the clock still (i.e. "declare_clock" command was used)
          } else {

            if { $args != "" } {
              set source_nodes  [lindex $args 0]
              set master_clocks [lindex $args 1]
  
              set clk_source_node  [lindex $source_nodes  $channel]
              set clk_master_clock [lindex $master_clocks $channel]

              # Remove the instance name from the clock source node due to auto promotion in SDC_ENTITY
              set no_inst_clk_source_node [string replace $clk_source_node 0 [string length $instance]]

              set multiply_factor [lindex $args 2] 
              set divide_factor   [lindex $args end]

              # Call procedure to create generated clock for given clock node 
              native_create_clock_m3pnzmq $clk_group $clock_name $freq $no_inst_clk_node $channel $no_inst_clk_source_node $clk_master_clock $multiply_factor $divide_factor

            } else {

              # Call procedure to create source clock for given clock node 
              native_create_clock_m3pnzmq $clk_group $clock_name $freq $no_inst_clk_node $channel
            }
          }
        }; #foreach_in_collection matching_clk matching_clocks_list

      # Create clock if no clock exists already with same name
      } else { 


        if { $args != "" } {
          set source_nodes  [lindex $args 0]
          set master_clocks [lindex $args 1]
  
          set clk_source_node  [lindex $source_nodes  $channel]
          set clk_master_clock [lindex $master_clocks $channel]

          # Remove the instance name from the clock source node due to auto promotion in SDC_ENTITY
          set no_inst_clk_source_node [string replace $clk_source_node 0 [string length $instance]]

          set multiply_factor [lindex $args 2] 
          set divide_factor   [lindex $args end]

          # Call procedure to create generated clock for given clock node 
          native_create_clock_m3pnzmq $clk_group $clock_name $freq $no_inst_clk_node $channel $no_inst_clk_source_node $clk_master_clock $multiply_factor $divide_factor

        } else {

          # Call procedure to create source clock for given clock node 
          native_create_clock_m3pnzmq $clk_group $clock_name $freq $no_inst_clk_node $channel
        }
      }

    }; # foreach clk in clk_list
  }; # foreach channel

  # Return the list of clock names  
  return $clock_name_list

}

# ----------------------------------------------------------------------------- #
# ---                                                                       --- #
# --- Procedure to create single HSSI clock for given node and clock name   --- #
# ---                                                                       --- #
# ----------------------------------------------------------------------------- #
proc native_create_clock_m3pnzmq { clk_group clock_name freq clk_node channel args } {
  global ::native_debug
  global ::alt_xcvr_native_s10_target_clock_list_dict

  if { $native_debug == 1 } {
    post_message -type info "IP SDC: Clock name = $clock_name"
  }
  
  # Use "create_clock" for source nodes
  if { $clk_group == "tx_pma_parallel_clk" || $clk_group == "rx_pma_parallel_clk" } {
  
    create_clock \
        -name    $clock_name \
        -period "$freq MHz" \
                 $clk_node -add
  
    # Add clock to target node key in the target clock list dictionary
    dict lappend alt_xcvr_native_s10_target_clock_list_dict $clk_node $clock_name

    if { $native_debug == 1 } {
      post_message -type info "IP SDC: Clocks on target node $clk_node"
      post_message -type info "                => [dict get $alt_xcvr_native_s10_target_clock_list_dict $clk_node]"
    }

  # Use "create_generated_clock" for the downstream nodes (*~aib_tx/rx_internal_div.reg and MAIB output pins)
  } elseif { $args != "" } {
  
    set clk_source_node  [lindex $args 0]
    set clk_master_clock [lindex $args 1]
    set multiply_factor  [lindex $args 2] 
    set divide_factor    [lindex $args end]
  
    if { $native_debug == 1 } {
            post_message -type info "IP SDC: Source node is $clk_source_node"
            post_message -type info "        Master clock is $clk_master_clock"
    }
  
    create_generated_clock \
        -name         $clock_name \
        -source       $clk_source_node \
        -master_clock $clk_master_clock \
        -multiply_by  $multiply_factor \
        -divide_by    $divide_factor \
                      $clk_node -add

    # Add clock to target node key in the target clock list dictionary
    dict lappend alt_xcvr_native_s10_target_clock_list_dict $clk_node $clock_name

    if { $native_debug == 1 } {
      post_message -type info "IP SDC: Clocks on target node $clk_node"
      post_message -type info "                => [dict get $alt_xcvr_native_s10_target_clock_list_dict $clk_node]"
    }

  }

}


