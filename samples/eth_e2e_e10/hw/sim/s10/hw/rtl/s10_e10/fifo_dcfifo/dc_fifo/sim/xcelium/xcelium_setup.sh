
# (C) 2001-2018 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Intel 
# Program License Subscription Agreement, Intel MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Intel and sold by Intel 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ACDS 18.1 221 linux 2018.09.21.11:09:37

# ----------------------------------------
# xcelium - auto-generated simulation script

# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     dc_fifo
# 
# Intel recommends that you source this Quartus-generated IP simulation
# script from your own customized top-level script, and avoid editing this
# generated script.
# 
# Xcelium Simulation Script.
# To write a top-level shell script that compiles Intel simulation libraries
# and the Quartus-generated IP in your project, along with your design and
# testbench files, copy the text from the TOP-LEVEL TEMPLATE section below
# into a new file, e.g. named "xcelium_sim.sh", and modify text as directed.
# 
# You can also modify the simulation flow to suit your needs. Set the
# following variables to 1 to disable their corresponding processes:
# - SKIP_FILE_COPY: skip copying ROM/RAM initialization files
# - SKIP_DEV_COM: skip compiling the Quartus EDA simulation library
# - SKIP_COM: skip compiling Quartus-generated IP simulation files
# - SKIP_ELAB and SKIP_SIM: skip elaboration and simulation
# 
# ----------------------------------------
# # TOP-LEVEL TEMPLATE - BEGIN
# #
# # QSYS_SIMDIR is used in the Quartus-generated IP simulation script to
# # construct paths to the files required to simulate the IP in your Quartus
# # project. By default, the IP script assumes that you are launching the
# # simulator from the IP script location. If launching from another
# # location, set QSYS_SIMDIR to the output directory you specified when you
# # generated the IP script, relative to the directory from which you launch
# # the simulator. In this case, you must also copy the generated files
# # "cds.lib" and "hdl.var" - plus the directory "cds_libs" if generated - 
# # into the location from which you launch the simulator, or incorporate
# # into any existing library setup.
# #
# # Run Quartus-generated IP simulation script once to compile Quartus EDA
# # simulation libraries and Quartus-generated IP simulation files, and copy
# # any ROM/RAM initialization files to the simulation directory.
# # - If necessary, specify any compilation options:
# #   USER_DEFINED_COMPILE_OPTIONS
# #   USER_DEFINED_VHDL_COMPILE_OPTIONS applied to vhdl compiler
# #   USER_DEFINED_VERILOG_COMPILE_OPTIONS applied to verilog compiler
# #
# source <script generation output directory>/xcelium/xcelium_setup.sh \
# SKIP_ELAB=1 \
# SKIP_SIM=1 \
# USER_DEFINED_COMPILE_OPTIONS=<compilation options for your design> \
# USER_DEFINED_VHDL_COMPILE_OPTIONS=<VHDL compilation options for your design> \
# USER_DEFINED_VERILOG_COMPILE_OPTIONS=<Verilog compilation options for your design> \
# QSYS_SIMDIR=<script generation output directory>
# #
# # Compile all design files and testbench files, including the top level.
# # (These are all the files required for simulation other than the files
# # compiled by the IP script)
# #
# xmvlog <compilation options> <design and testbench files>
# #
# # TOP_LEVEL_NAME is used in this script to set the top-level simulation or
# # testbench module/entity name.
# #
# # Run the IP script again to elaborate and simulate the top level:
# # - Specify TOP_LEVEL_NAME and USER_DEFINED_ELAB_OPTIONS.
# # - Override the default USER_DEFINED_SIM_OPTIONS. For example, to run
# #   until $finish(), set to an empty string: USER_DEFINED_SIM_OPTIONS="".
# #
# source <script generation output directory>/xcelium/xcelium_setup.sh \
# SKIP_FILE_COPY=1 \
# SKIP_DEV_COM=1 \
# SKIP_COM=1 \
# TOP_LEVEL_NAME=<simulation top> \
# USER_DEFINED_ELAB_OPTIONS=<elaboration options for your design> \
# USER_DEFINED_SIM_OPTIONS=<simulation options for your design>
# #
# # TOP-LEVEL TEMPLATE - END
# ----------------------------------------
# 
# IP SIMULATION SCRIPT
# ----------------------------------------
# If dc_fifo is one of several IP cores in your
# Quartus project, you can generate a simulation script
# suitable for inclusion in your top-level simulation
# script by running the following command line:
# 
# ip-setup-simulation --quartus-project=<quartus project>
# 
# ip-setup-simulation will discover the Intel IP
# within the Quartus project, and generate a unified
# script which supports all the Intel IP within the design.
# ----------------------------------------
# ACDS 18.1 221 linux 2018.09.21.11:09:37
# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="dc_fifo.dc_fifo"
QSYS_SIMDIR="./../"
QUARTUS_INSTALL_DIR="/swip_build/releases/acds/18.1/221/linux64/quartus/"
SKIP_FILE_COPY=0
SKIP_DEV_COM=0
SKIP_COM=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="-input \"@run 100; exit\""

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

#-------------------------------------------
# check tclsh version no earlier than 8.5 
version=$(echo "puts [package vcompare [info tclversion] 8.5]; exit" | tclsh)
if [ $version -eq -1 ]; then 
  echo "Error: Minimum required tcl package version is 8.5." >&2 
  exit 1 
fi 

# ----------------------------------------
# initialize simulation properties - DO NOT MODIFY!
ELAB_OPTIONS=""
SIM_OPTIONS=""
if [[ `xmsim -version` != *"xmsim(64)"* ]]; then
  SIMULATOR_TOOL_BITNESS="bit_32"
else
  SIMULATOR_TOOL_BITNESS="bit_64"
fi
TCLSCRIPT='
set QSYS_SIMDIR [lindex $argv 1]
set SIMULATOR_TOOL_BITNESS [lindex $argv 2]
source $QSYS_SIMDIR/common/xcelium_files.tcl
set LD_LIBRARY_PATH [dict create]
set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [dc_fifo::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
if {[dict size $LD_LIBRARY_PATH] !=0 } {
  set LD_LIBRARY_PATH [join [dict keys $LD_LIBRARY_PATH] ":"]
  puts "LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH\""
}

set ELAB_OPTIONS ""
append ELAB_OPTIONS [dc_fifo::get_elab_options $SIMULATOR_TOOL_BITNESS]
puts "ELAB_OPTIONS+=\"$ELAB_OPTIONS\""
set SIM_OPTIONS ""
append SIM_OPTIONS [dc_fifo::get_sim_options $SIMULATOR_TOOL_BITNESS]
puts "SIM_OPTIONS+=\"$SIM_OPTIONS\""
exit 0
'
cmd_output=$(
tclsh -args "$QSYS_SIMDIR" "$SIMULATOR_TOOL_BITNESS" << SCRIPT
  $TCLSCRIPT
SCRIPT
)

eval $cmd_output

TCLSCRIPT='
set QSYS_SIMDIR [lindex $argv 1]
set libraries [dict create]
source $QSYS_SIMDIR/common/xcelium_files.tcl
set libraries [dict merge $libraries [dc_fifo::get_design_libraries]]
set design_libraries [dict keys $libraries]
foreach file $design_libraries { puts "$file" }
exit 0
'
cmd_output=$(
tclsh -args "$QSYS_SIMDIR" << SCRIPT
  $TCLSCRIPT
SCRIPT
)

design_libraries=$cmd_output

# ----------------------------------------
# create compilation libraries
mkdir -p ./libraries/work/
mkdir -p ./libraries/altera_ver/
mkdir -p ./libraries/lpm_ver/
mkdir -p ./libraries/sgate_ver/
mkdir -p ./libraries/altera_mf_ver/
mkdir -p ./libraries/fourteennm_ver/
mkdir -p ./libraries/fourteennm_ct1_ver/
mkdir -p ./libraries/altera/
mkdir -p ./libraries/lpm/
mkdir -p ./libraries/sgate/
mkdir -p ./libraries/altera_mf/
mkdir -p ./libraries/altera_lnsim/
mkdir -p ./libraries/fourteennm/
mkdir -p ./libraries/fourteennm_ct1/
for library in $design_libraries
do
  mkdir -p ./libraries/$library
done
#-------------------------------------------
# write out _default.cds.lib including all design libraries 
echo "# DO NOT MODIFY " > _default.cds.lib
for library in $design_libraries 
do 
  echo "DEFINE		$library 	./libraries/$library" >> _default.cds.lib 
done 

#-------------------------------------------
# create cds_libs for each design library  
for library in $design_libraries 
do 
   echo "INCLUDE device.cds.lib" > cds_libs/$library.cds.lib       
   if [[ $design_libraries =~ "altera_common_sv_packages" ]] && [[ $library !=  "altera_common_sv_packages" ]]; then 
      echo "DEFINE		altera_common_sv_packages		     ./../libraries/altera_common_sv_packages/"        >> cds_libs/$library.cds.lib 
   fi 
   echo "DEFINE     $library     ./../libraries/$library"   >> cds_libs/$library.cds.lib 
done 

# ----------------------------------------
# copy RAM/ROM files to simulation directory
TCLSCRIPT='
set QSYS_SIMDIR [lindex $argv 1]
set memory_files [list]
source $QSYS_SIMDIR/common/xcelium_files.tcl
set memory_files [concat $memory_files [dc_fifo::get_memory_files "$QSYS_SIMDIR"]]
foreach file $memory_files { puts "$file" }
exit 0
'
cmd_output=$(
tclsh -args "$QSYS_SIMDIR" << SCRIPT
  $TCLSCRIPT
SCRIPT
)

memory_files=$cmd_output
if [ $SKIP_FILE_COPY -eq 0 ]; then
  for file in $memory_files
  do
    cp -f $file ./
  done
fi

# ----------------------------------------
# compile device library files
if [ $SKIP_DEV_COM -eq 0 ]; then
  xmvlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                   -work altera_ver        
  xmvlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                            -work lpm_ver           
  xmvlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                               -work sgate_ver         
  xmvlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                           -work altera_mf_ver     
  xmvlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/fourteennm_atoms.sv"                   -work fourteennm_ver    
  xmvlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/ct1_hssi_atoms.sv"                     -work fourteennm_ct1_ver
  xmvlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/ct1_hip_atoms.sv"                      -work fourteennm_ct1_ver
  xmvlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/cadence/ct1_hip_atoms_ncrypt.sv"       -work fourteennm_ct1_ver
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_syn_attributes.vhd"             -work altera            
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_standard_functions.vhd"         -work altera            
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/alt_dspbuilder_package.vhd"            -work altera            
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_europa_support_lib.vhd"         -work altera            
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives_components.vhd"      -work altera            
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.vhd"                 -work altera            
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/220pack.vhd"                           -work lpm               
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.vhd"                          -work lpm               
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate_pack.vhd"                        -work sgate             
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.vhd"                             -work sgate             
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf_components.vhd"              -work altera_mf         
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.vhd"                         -work altera_mf         
  xmvlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                       -work altera_lnsim      
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim_components.vhd"           -work altera_lnsim      
  xmvlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/cadence/fourteennm_atoms_ncrypt.sv"    -work fourteennm        
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/fourteennm_atoms.vhd"                  -work fourteennm        
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/fourteennm_components.vhd"             -work fourteennm        
  xmvlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/cadence/ct1_hssi_atoms_ncrypt.sv"      -work fourteennm_ct1    
  xmvlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/cadence/cr3v0_serdes_models_ncrypt.sv" -work fourteennm_ct1    
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/ct1_hssi_components.vhd"               -work fourteennm_ct1    
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/ct1_hssi_atoms.vhd"                    -work fourteennm_ct1    
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/ct1_hip_components.vhd"                -work fourteennm_ct1    
  xmvhdl -v93 $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS   "$QUARTUS_INSTALL_DIR/eda/sim_lib/ct1_hip_atoms.vhd"                     -work fourteennm_ct1    
fi

# ----------------------------------------
# get common system verilog package design files
TCLSCRIPT='
set USER_DEFINED_COMPILE_OPTIONS [lindex $argv 1]
set USER_DEFINED_VERILOG_COMPILE_OPTIONS [lindex $argv 2]
set USER_DEFINED_VHDL_COMPILE_OPTIONS [lindex $argv 3]
set QSYS_SIMDIR [lindex $argv 4]
set design_files [dict create]
source $QSYS_SIMDIR/common/xcelium_files.tcl
set design_files [dict merge $design_files [dc_fifo::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR"]]
set common_design_files [dict values $design_files]
foreach file $common_design_files { puts "$file" }
exit 0
'
cmd_output=$(
tclsh -args "$USER_DEFINED_COMPILE_OPTIONS" "$USER_DEFINED_VERILOG_COMPILE_OPTIONS" "$USER_DEFINED_VHDL_COMPILE_OPTIONS" "$QSYS_SIMDIR" << SCRIPT
  $TCLSCRIPT
SCRIPT
)

common_design_files=$cmd_output

# ----------------------------------------
# get design files
TCLSCRIPT='
set USER_DEFINED_COMPILE_OPTIONS [lindex $argv 1]
set USER_DEFINED_VERILOG_COMPILE_OPTIONS [lindex $argv 2]
set USER_DEFINED_VHDL_COMPILE_OPTIONS [lindex $argv 3]
set QSYS_SIMDIR [lindex $argv 4]
set files [list]
source $QSYS_SIMDIR/common/xcelium_files.tcl
set files [concat $files [dc_fifo::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR"]]
set design_files $files
foreach file $design_files { puts "$file" }
exit 0
'
cmd_output=$(
tclsh -args "$USER_DEFINED_COMPILE_OPTIONS" "$USER_DEFINED_VERILOG_COMPILE_OPTIONS" "$USER_DEFINED_VHDL_COMPILE_OPTIONS" "$QSYS_SIMDIR" << SCRIPT
  $TCLSCRIPT
SCRIPT
)

design_files=$cmd_output

# ----------------------------------------
# compile design files in correct order
if [ $SKIP_COM -eq 0 ]; then
  eval "$common_design_files"
  eval "$design_files"
fi

# ----------------------------------------
# elaborate top level design
if [ $SKIP_ELAB -eq 0 ]; then
  xmelab -access +w+r+c -namemap_mixgen +DISABLEGENCHK -relax $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS $TOP_LEVEL_NAME
fi

# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  eval xmsim -licqueue $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS $TOP_LEVEL_NAME
fi