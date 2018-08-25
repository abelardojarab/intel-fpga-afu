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


proc rename_generated_clock {clock_object clock_name} {
                set divide_by     [get_clock_info -divide_by $clock_object]
                set duty_cycle    [get_clock_info -duty_cycle $clock_object]
                set edge_shifts   [get_clock_info -edge_shifts $clock_object]
                set edges         [get_clock_info -edges $clock_object]
                set is_inverted   [get_clock_info -is_inverted $clock_object]
                set master_clock  [get_clock_info -master_clock $clock_object]
                set master_clock_pin  [get_clock_info -master_clock_pin $clock_object]
                set multiply_by   [get_clock_info -multiply_by $clock_object]
                set name          [get_clock_info -name $clock_object]
                set offset        [get_clock_info -offset $clock_object]
                set phase         [get_clock_info -phase $clock_object]
                set targets       [get_clock_info -targets $clock_object]
                
                set command [concat    "create_generated_clock "       [expr {[expr {$divide_by eq ""}] ? "" : "-divide_by $divide_by"}] \
                                       [expr {[expr {$duty_cycle eq ""}] ? "" : "-duty_cycle $duty_cycle"}] \
                                                                                                   [expr {[expr {$edges eq ""}] ? "" : "-edges $edges"}]\
                                                                                                   [expr {[expr {$master_clock eq ""}] ? "" : "-master_clock $master_clock"}] \
                                                                                                   [expr {[expr {$multiply_by eq ""}] ? "" : "-multiply_by $multiply_by"}] \
                                                                                                   [expr {[expr {$is_inverted ? "-invert" : ""}]}] \
                                                                                                   "-name $clock_name" \
                                                                                                   [expr {[expr {$offset eq ""}] ? "" : "-offset $offset"}] \
                                                                                                   [expr {[expr {$phase eq ""}] ? "" : "-phase $phase"}] \
                                                                                                   [expr {[expr {$master_clock eq ""}] ? "" : "-source $master_clock_pin"}] \
                                                                                                   $targets ]
                
                set none [eval "remove_clock $clock_object"]
                set none [eval $command]
                
}

proc rename_clock {clock_object clock_name} {
                set edges         [get_clock_info -edges $clock_object]
                set targets       [get_clock_info -targets $clock_object]
                set period        [get_clock_info -period $clock_object]
                
                set command [concat    "create_clock "      \
                                                                                                   "-name $clock_name"  \
                                                                                                   "-period $period"    \
                                                                                                   [expr {[expr {$edges eq ""}] ? "" : "-waveform $edges"}] \
                                                                                                   $targets ]
                
                set none [eval "remove_clock $clock_object"]
                set none [eval $command]
                
}
