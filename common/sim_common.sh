#!/bin/bash
# script to setup common variables
set -e

#get exact script path
COMMON_SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
#get director of script path
COMMON_SCRIPT_DIR_PATH="$(dirname $COMMON_SCRIPT_PATH)"

usage_setup_sim() { 
   echo "Usage: $0 [-a <afu>] [-s <vcs|modelsim|questa>] [-b <opae base dir>]" 1>&2; 
   exit 1;
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

   # mandatory args
   if [ -z "${a}" ] || [ -z "${s}" ] || [ -z "${b}" ]; then
      usage_setup_sim;
   fi

   afu=${a};
   sim=${s};
   opae_base=${b}
   test_mode=${m};

   if [[ "$sim" != "vcs" ]] && [[ "$sim" != "questa" ]] && [[ "$sim" != "modelsim" ]] ; then
      echo "Supported simulators are vcs, modelsim and questa. You requsted $sim"
      usage_setup_sim;
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
   echo "Usage: $0 [-f <afu source>] [-a <application source>] [-b <opae base dir>] [-s <vcs|modelsim|questa>]" 1>&2; 
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

   if [[ "$sim" != "vcs" ]] && [[ "$sim" != "questa" ]] && [[ "$sim" != "modelsim" ]]   ; then
      echo "Supported simulators are VCS, Modelsim and Questa. You specified $sim"
      usage_regress;
   fi
}

setup_sim_dir() {
   rm -rf $COMMON_SCRIPT_DIR_PATH/sim_afu
   mkdir -p $COMMON_SCRIPT_DIR_PATH/sim_afu
   # get path of simulation afu dir
   sim_afu_path=$COMMON_SCRIPT_DIR_PATH/sim_afu
   # copy afu sources here (except ccip_if_pkg.sv which is already included in ASE RTL source)
   rsync -av --progress $afu/* $sim_afu_path --exclude ccip_if_pkg.sv --exclude green_top.sv   
}

setup_quartus_home() {
   # use QUARTUS_HOME (from env)
   # QSYS_HOME=$QUARTUS_HOME/sopc_builder/bin 
   if [ -z "$QUARTUS_HOME" ] ; then      
      # env not found
      echo "Your environment did not set QUARTUS_HOME. Trying to detect QUARTUS_HOME.. "
      quartus_bin=`which quartus`
      quartus_bin_dir=`dirname $quartus_bin`
      export QUARTUS_HOME="$quartus_bin_dir/../"
      echo "Info: Auto-detected QUARTUS_HOME at $QUARTUS_HOME"   
   else
      echo "Detected QUARTUS_HOME at $QUARTUS_HOME"
   fi
}

gen_qsys() {
   # generate qsys systems
   pushd $COMMON_SCRIPT_DIR_PATH/sim_afu

   find . -name *.qsys -exec $QUARTUS_HOME/sopc_builder/bin/qsys-generate {} --simulation=VERILOG \;
   find . -name *.ip -exec $QUARTUS_HOME/sopc_builder/bin/qsys-generate {} --simulation=VERILOG \;

   # remove _inst.v , _bb.v and *.vhd
   find $PWD -name *.vhd -exec rm -rf {} \;
   find $PWD -name '*_inst.v' -exec rm -rf {} \;
   find $PWD -name '*_bb.v' -exec rm -rf {} \;
   popd
}

add_text_macros() {     
   add_macros=$1;
}

get_vcs_home() {
   # Use VCS_HOME (if available in env)      
   if [ -z "$VCS_HOME" ] ; then      
      # env not found
      echo "Your environment did not set VCS_HOME. Trying to detect VCS.. "
      vcs_bin=`which vcs`
      if [ -z "$vcs_bin" ] ; then          
         echo "Unable to find VCS. Please set the env variable VCS_HOME to your VCS install path"
         exit 1;
      else            
         vcs_bin_dir=`dirname $vcs_bin`
         export VCS_HOME="$vcs_bin_dir/../"      
         echo "Auto-detected VCS_HOME at $VCS_HOME"
      fi
   else
      echo "Detected VCS_HOME at $VCS_HOME"
   fi
}

get_mti_home() {
	if [ -z "$MTI_HOME" ] ; then      
      # env not found
      echo "Your environment did not set MTI_HOME. Trying to detect Modelsim SE.. "
      vsim_bin=`which vsim`
      if [ -z "$vsim_bin" ] ; then
         echo "Unable to find Modelsim. Please set the env variable MTI_HOME to your Modelsim install path"
         exit 1;
      else
         vsim_bin_dir=`dirname $vsim_bin`
         export MTI_HOME="$vsim_bin_dir/../"   
         echo "Auto-detected MTI_HOME at $MTI_HOME"
      fi
   else
      echo "Detected MTI_HOME at $MTI_HOME"
   fi	
}


run_sim() {
   pushd $opae_base/ase
   rm -rf ase_sources.mk
   
   if [ "$sim" == "vcs" ] ; then
      echo "Using VCS"

      get_vcs_home

      # Else, try to auto-detect VCS_HOME
      ./scripts/generate_ase_environment.py -t VCS -p discrete $sim_afu_path
      echo "SNPS_VLOGAN_OPT+= +define+INCLUDE_DDR4 +define+DDR_ADDR_WIDTH=26" >> ase_sources.mk

      # add non-standard text macros (if any)
      # specify them using add_text_macros  
      echo "SNPS_VLOGAN_OPT+= $add_macros" >> ase_sources.mk      

   elif [ "$sim" == "modelsim" ] ; then
      get_mti_home

      echo "Info: MTI_ROOTDIR set to $MTI_HOME"
      # ASE treats modelsim and questa similarly
      ./scripts/generate_ase_environment.py -t QUESTA -p discrete $sim_afu_path
      echo "MENT_VLOG_OPT += +define+INCLUDE_DDR4 +define+DDR_ADDR_WIDTH=26 -suppress 3485,3584" >> ase_sources.mk
      echo "MENT_VLOG_OPT += $add_macros" >> ase_sources.mk
      echo "MENT_VSIM_OPT += -suppress 3485,3584" >> ase_sources.mk

      # add non-standard text macros (if any)
      # specify them using add_text_macros      
      echo "MENT_VSIM_OPT += $add_macros" >> ase_sources.mk
   elif [ "$sim" == "questa" ] ; then
      get_mti_home

      echo "Info: MTI_ROOTDIR set to $MTI_HOME"
      # ASE treats modelsim and questa similarly
      ./scripts/generate_ase_environment.py -t QUESTA -p discrete $sim_afu_path
      echo "MENT_VLOG_OPT += +define+INCLUDE_DDR4 +define+DDR_ADDR_WIDTH=26 -suppress 3485,3584" >> ase_sources.mk
      echo "MENT_VLOG_OPT += $add_macros" >> ase_sources.mk
      echo "MENT_VSIM_OPT += -suppress 3485,3584" >> ase_sources.mk

      # add non-standard text macros (if any)
      # specify them using add_text_macros      
      echo "MENT_VSIM_OPT += $add_macros" >> ase_sources.mk
   else
      echo "Unknown Simulator $sim"
      exit 1;
   fi

   # run ase make
   make platform=ASE_PLATFORM_DCP
   make sim
   popd
}

wait_for_sim_ready() {
   ASE_READY_FILE=$opae_base/ase/work/.ase_ready.pid
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
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$app_base
   export ASE_WORKDIR=$opae_base/ase/work/
   echo "ASE workdir is $ASE_WORKDIR"

}

build_app() {
   pushd $app_base
   # Build the software application
   make prefix=$opae_base USE_ASE=1
   popd
}

exec_app() {
   pushd $app_base
   # find the executable and run
   find . -type f -executable -exec {} \;
   popd
}

run_app() {
   setup_app_env
   wait_for_sim_ready
   pushd $app_base

   # Build the software application
   make prefix=$opae_base USE_ASE=1

   # find the executable and run
   find . -type f -executable -exec {} \;
   popd
}

kill_sim() {
   ase_workdir=$opae_base/ase/work/
   pid=`cat $ase_workdir/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`
   echo "Killing pid = $pid"
   kill $pid
   exit 0
}

configure_ase_reg_mode() {
   rm -f $COMMON_SCRIPT_DIR_PATH/ase.cfg
   echo "ASE_MODE = 4" >> $COMMON_SCRIPT_DIR_PATH/ase.cfg
   find $ASE_WORKDIR -name ase.cfg -exec cp $COMMON_SCRIPT_DIR_PATH/ase.cfg {} \;
}

copy_qsys_ip_files () {
    QSYS_NAME=$1
    find $sim_afu_path/qsys/$QSYS_NAME/ \
    $sim_afu_path/qsys/ip/$QSYS_NAME/ \
    -name synth -type d | \
    \
    xargs -n1 -IAAA find AAA -name "*.*v" | \
    xargs -n1 -IAAA cp -f AAA $sim_afu_path/qsys_sim_files
}
