#!/bin/bash
# script to setup common variables
set -e

#get exact script path
COMMON_SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
#get director of script path
COMMON_SCRIPT_DIR_PATH="$(dirname $COMMON_SCRIPT_PATH)"

usage() { 
   echo "Usage: $0 [-a <afu>] [-s <vcs|questa>] [-b <opae base dir>]" 1>&2; 
}

menu_setup_sim() {

   local OPTIND
   while getopts ":a:s:b:m:" o; do
      case "${o}" in
         a)
            a=${OPTARG}
            ;;
         s)
            s=${OPTARG}            
            ;;
         b)
            b=${OPTARG}            
         ;;    
        
         # optional mode argument for internal testing
         m)
            m=${OPTARG}            
            ;;
      esac
   done
   shift $((OPTIND-1))

   #echo "afu = $afu, sim=$sim, opae_base=$opae_base, test_mode=$test_mode"
   # mandatory args
   if [ -z "${a}" ] || [ -z "${s}" ] || [ -z "${b}" ]; then
      usage;
   fi

   afu=${a};
   sim=${s};
   opae_base=${b}
   test_mode=${m};

   if [[ "$sim" != "vcs" ]] && [[ "$sim" != "questa" ]]; then
      echo "Supported simulators are VCS or Questa"
      usage;
   fi
}

usage_run_app() { 
   echo "Usage: $0 [-a <application source>] [-b <opae base dir>]" 1>&2; 
   exit 1; 
}

menu_run_app() {
   local OPTIND
   while getopts ":a:b:" o; do
      case "${o}" in
         a)
            a=${OPTARG}
            ;;
         b)
            b=${OPTARG}
            ;;
      esac
   done
   shift $((OPTIND-1))

   # mandatory args
   if [ -z "${a}" ] || [ -z "${b}" ]; then
      usage_run_app;
   fi

   app_base=${a};
   opae_base=${b};
}

usage_regress() { 
   echo "Usage: $0 [-f <afu source>] [-a <application source>] [-b <opae base dir>] [-s <vcs|questa>]" 1>&2; 
   exit 1; 
}

menu_regress() {

   local OPTIND
   while getopts ":a:s:b:f:m:" o; do
      case "${o}" in
         a)
            a=${OPTARG}
            ;;
         s)
            s=${OPTARG}            
            ;;
         b)
            b=${OPTARG}            
         ;;    
         f)
            f=${OPTARG}            
         ;;    
         # optional mode argument for internal testing
         m)
            m=${OPTARG}            
            ;;
      esac
   done
   shift $((OPTIND-1))

   afu=${f};
   app=${a};
   sim=${s};
   opae_base=${b}
   test_mode=${m};

   echo "afu=$afu, app=$app, sim=$sim, base=$opae_base"
   # mandatory args
   if [ -z "${a}" ] || [ -z "${s}" ] || [ -z "${f}" ] || [ -z "${b}" ]; then
      usage_regress;
   fi

   if [[ "$sim" != "vcs" ]] && [[ "$sim" != "questa" ]]; then
      echo "Supported simulators are VCS or Questa"
      usage;
   fi
}




setup_sim_dir() {
   rm -rf $COMMON_SCRIPT_DIR_PATH/sim_afu
   mkdir -p $COMMON_SCRIPT_DIR_PATH/sim_afu
   # get path of simulation afu dir
   sim_afu_path=$COMMON_SCRIPT_DIR_PATH/sim_afu

   echo "Info: Using release mode"
   # copy afu sources here (except ccip_if_pkg.sv which is already included in ASE RTL source)
   rsync -av --progress $afu/* $sim_afu_path --exclude ccip_if_pkg.sv --exclude green_top.sv
   
}

setup_quartus_home() {
   # detect QUARTUS_HOME from environment
   quartus_bin=`which quartus`
   quartus_bin_dir=`dirname $quartus_bin`
   export QUARTUS_HOME="$quartus_bin_dir/../"
   echo "Info: Quartus home detected at $QUARTUS_HOME"
}

gen_qsys() {
   # generate qsys systems
   pushd $COMMON_SCRIPT_DIR_PATH/sim_afu/interfaces

   find . -name *.qsys -exec qsys-generate {} --simulation=VERILOG \;
   # remove _inst.v , _bb.v and *.vhd
   find $PWD -name *.vhd -exec rm -rf {} \;
   find $PWD -name '*_inst.v' -exec rm -rf {} \;
   find $PWD -name '*_bb.v' -exec rm -rf {} \;
   popd
}

run_sim() {
   pushd $opae_base/ase
   rm -rf ase_sources.mk

   echo "Sim is $sim"
   if [ "$sim" == "vcs" ] ; then
      echo "Using VCS"
      ./scripts/generate_ase_environment.py -t VCS -p dcp $sim_afu_path
      echo "SNPS_VLOGAN_OPT+= +define+INCLUDE_DDR4 +define+DDR_ADDR_WIDTH=26" >> ase_sources.mk
   else
      echo "Using QUESTA"
      export MTI_HOME=$MODELSIM_ROOTDIR
      ./scripts/generate_ase_environment.py -t QUESTA -p dcp $sim_afu_path
      echo "MENT_VLOG_OPT += +define+INCLUDE_DDR4 +define+DDR_ADDR_WIDTH=26" >> ase_sources.mk
   fi

   # run ase make
   make platform=ASE_PLATFORM_DCP
   make sim
   popd
}

wait_for_sim_ready() {
   ASE_READY_FILE=$ASE_WORKDIR/.ase_ready.pid
   while [ ! -f $ASE_READY_FILE ]
   do
      echo "Waiting for simulation to start..."
      sleep 1
   done
   echo "simulation is ready!"
}

setup_app_env() {
   # setup env variables
   export LD_LIBRARY_PATH=$opae_base/build/lib
   export ASE_WORKDIR=$opae_base/ase/work/
   echo "ASE workdir is $ASE_WORKDIR"

}

run_app() {
   setup_app_env
   pushd $app_base

   # Build the software application
   make prefix=$opae_base USE_ASE=1

   wait_for_sim_ready
   # find the executable and run
   find . -type f -executable -exec {} \;
   popd
}



configure_ase_reg_mode() {
   rm -f $COMMON_SCRIPT_DIR_PATH/ase.cfg
   echo "ASE_MODE = 4" >> $COMMON_SCRIPT_DIR_PATH/ase.cfg
   find $ASE_WORKDIR -name ase.cfg -exec cp $COMMON_SCRIPT_DIR_PATH/ase.cfg {} \;
}


