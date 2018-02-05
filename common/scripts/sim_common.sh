#!/bin/bash
# script to setup common variables
set -e

# Get exact script path
COMMON_SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
# Get directory of script path
COMMON_SCRIPT_DIR_PATH="$(dirname $COMMON_SCRIPT_PATH)"

usage_setup_sim() { 
   echo "Usage: $0 -a <afu dir> -s <vcs|modelsim|questa> -b <opae base dir> [-p <platform>] [-v <variant>] [-r <rtl simulation dir>] [-m <EMIF_MODEL_BASIC|EMIF_MODEL_ADVANCED> memory model]" 1>&2
   echo "" 1>&2
   echo "Sources are normally found in <afu dir>/hw/rtl/filelist.txt.  When -v is" 1>&2
   echo "set, the sources file becomes <afu dir>/hw/rtl/filelist_<variant>.txt." 1>&2
   exit 1
}

find_default_sim() {
   if [ -x "$(command -v vcs)" ] ; then
      echo vcs
   elif [ -x "$(command -v vsim)" ] ; then
      echo questa
   fi
}

menu_setup_sim() {
   # Defaults
   s=`find_default_sim`
   b="${OPAE_BASEDIR}"
   v=""
   p="discrete"

   local OPTIND
   while getopts ":a:r:s:b:p:v:m:" o; do
      case "${o}" in
         a)
            a=${OPTARG}
            ;;
         r)
            r=${OPTARG}
            ;;
         s)
            s=${OPTARG}            
            ;;
         b)
            b=${OPTARG}            
            ;;
         p)
            p=${OPTARG}
            ;;
         v)
            v=${OPTARG}
            ;;
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

   afu=${a}
   rtl=${afu}/hw/rtl
   variant=${v}
   platform=${p}
   rtl_sim_dir=${r}
   sim=${s}
   opae_base=${b}
   mem_model=${m}

   rtl_filelist="${rtl}/filelist.txt"
   if [ "${v}" != "" ]; then
      rtl_filelist="${rtl}/filelist_${variant}.txt"
   fi

   if [ -z "$rtl_sim_dir" ]
   then
      # use default
      rtl_sim_dir=$opae_base/rtl_sim
   fi

   if [[ "$sim" != "vcs" ]] && [[ "$sim" != "questa" ]] && [[ "$sim" != "modelsim" ]] ; then
      echo "Supported simulators are vcs, modelsim and questa. You requsted $sim"
      usage_setup_sim;
   fi

   if [[ ! $mem_model ]]; then
      # use default
      mem_model=EMIF_MODEL_BASIC
   fi
}

usage_run_app() { 
   echo "Usage: $0 -a <afu dir> -b <opae base dir> [-i <opae install path>] [-r <rtl simulation dir>]" 1>&2;
   exit 1; 
}

menu_run_app() {
   # Defaults
   b="${OPAE_BASEDIR}"

   local OPTIND
   while getopts ":a:r:i:b:" o; do
      case "${o}" in
         a)
            a=${OPTARG}
            ;;
         r)
            r=${OPTARG}
            ;;
         i)
            i=${OPTARG}
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

   afu=${a}
   app_base=${a}/sw
   rtl_sim_dir=${r}
   opae_base=${b}
   opae_install=${i};
   if [ -z "$rtl_sim_dir" ]
   then
      # use default
      rtl_sim_dir=$opae_base/rtl_sim
   fi
}

usage_regress() { 
   echo "Usage: $0 -a <afu dir> -s <vcs|modelsim|questa> -b <opae base dir> [-p <platform>] [-v <variant>]" 1>&2
   echo "                       [-i <opae install path>] [-r <rtl simulation dir>]" 1>&2
   echo "                       [-m <EMIF_MODEL_BASIC|EMIF_MODEL_ADVANCED> memory model]" 1>&2
   exit 1
}

menu_regress() {
   # Defaults
   s=`find_default_sim`
   b="${OPAE_BASEDIR}"
   v=""
   p="discrete"

   local OPTIND
   while getopts ":a:r:s:b:p:v:f:i:m:" o; do
      case "${o}" in
         a)
            a=${OPTARG}
            ;;
         r)
            r=${OPTARG}
            ;;
         s)
            s=${OPTARG}            
            ;;
         b)
            b=${OPTARG}            
            ;;
         p)
            p=${OPTARG}
            ;;
         v)
            v=${OPTARG}
            ;;
         m)
            m=${OPTARG}            
            ;;
         i)
            i=${OPTARG}
            ;;
      esac
   done
   shift $((OPTIND-1))

   afu=${a}
   rtl=${a}/hw/rtl
   app=${a}/sw
   variant=${v}
   platform=${p}
   rtl_sim_dir=${r}
   sim=${s};
   opae_base=${b}
   mem_model=${m};
   opae_install=${i};
   if [ -z "$rtl_sim_dir" ]
   then
      # use default
      rtl_sim_dir=$opae_base/rtl_sim
   fi

   echo "afu=$afu, rtl=$rtl, app=$app, sim=$sim, base=$opae_base mem_model=$mem_model opae_install=$opae_install"
   echo "variant=$variant"
   echo "platform=$platform"
   # mandatory args
   if [ -z "${a}" ] || [ -z "${s}" ] || [ -z "${b}" ]; then
      usage_regress;
   fi

   if [[ "$sim" != "vcs" ]] && [[ "$sim" != "questa" ]] && [[ "$sim" != "modelsim" ]]   ; then
      echo "Supported simulators are VCS, Modelsim and Questa. You specified $sim"
      usage_regress;
   fi

   if [[ ! $mem_model ]]; then
      # use default
      mem_model=EMIF_MODEL_BASIC
   fi
}

# Quiet pushd/popd
pushd () {
  command pushd "$@" > /dev/null
}
popd () {
  command popd "$@" > /dev/null
}

setup_sim_dir() {
   # Ensure that the OPAE build is on the path during regression runs.
   export PATH=${PATH}:${opae_base}/inst/bin:${opae_base}/build/bin

   echo "Configuring ASE in ${rtl_sim_dir}"
   afu_sim_setup --source "${rtl_filelist}" --platform ${platform} --tool ${sim} --force \
                 --ase-mode 1 --ase-verbose \
                 "${rtl_sim_dir}"

   pushd "$rtl_sim_dir"

   # Add a place holder for QSYS generated Verilog
   touch vlog_files.list qsys_sim_files.list
   echo "-F qsys_sim_files.list" >> vlog_files.list

   # AFUs should be getting these from platform_if.vh.  Once legacy AFUs are
   # gone, we can remove these.
   echo "SNPS_VLOGAN_OPT += +define+INCLUDE_DDR4" >> ase_sources.mk
   echo "MENT_VLOG_OPT += +define+INCLUDE_DDR4" >> ase_sources.mk

   # Suppress some ModelSim warnings
   echo "MENT_VLOG_OPT += -suppress 3485,3584" >> ase_sources.mk
   echo "MENT_VSIM_OPT += -suppress 3485,3584" >> ase_sources.mk

   # add non-standard text macros (if any)
   # specify them using add_text_macros
   if [ "${add_macros}" != "" ]; then
      echo "SNPS_VLOGAN_OPT += $add_macros" >> ase_sources.mk
      echo "MENT_VLOG_OPT += $add_macros" >> ase_sources.mk
      echo "MENT_VSIM_OPT += $add_macros" >> ase_sources.mk
   fi

   echo "ASE_DISCRETE_EMIF_MODEL=$mem_model" >> ase_sources.mk
   echo "OPAE_BASEDIR=$opae_base" >> ase_sources.mk

   popd
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
   # Copy the source tree to the RTL simulator tree in order to avoid
   # polluting the source tree with Qsys-generated files.  Qsys doesn't
   # have a mode in which files are written outside the tree.
   rm -rf "$rtl_sim_dir/qsys_sim_src"
   rsync -a "$rtl/" "$rtl_sim_dir/qsys_sim_src/"

   pushd "$rtl_sim_dir"

   # Use the copied file list
   qsys_sim_filelist=qsys_sim_src/`basename ${rtl_filelist}`

   # Generate Qsys
   for q in `rtl_src_config --abs --qsys "${qsys_sim_filelist}" | grep .qsys$`; do
      $QUARTUS_HOME/sopc_builder/bin/qsys-generate "${q}" --synthesis=VERILOG
   done

   # remove _inst.v , _bb.v and *.vhd
   find qsys_sim_src -name *.vhd -exec rm -rf {} \;
   find qsys_sim_src -name '*_inst.v' -exec rm -rf {} \;
   find qsys_sim_src -name '*_bb.v' -exec rm -rf {} \;

   # There are duplicate generated files in the Qsys tree.  Copy all generated
   # Verilog to a single directory, forcing the base names to be unique.
   rm -rf qsys_sim_files
   mkdir qsys_sim_files
   for q in `rtl_src_config --abs --qsys "${qsys_sim_filelist}"`; do
      # Search in directories with the same names as Qsys files
      find "${q%.*}/" -name synth -type d | \
         xargs -n1 -IAAA find AAA -name "*.*v" | \
         xargs -n1 -IAAA cp -f AAA qsys_sim_files/
   done

   # One final hack: remove files with names matching base names already listed
   # as sources, assuming they are duplicates.
   for q in `rtl_src_config --sim "${qsys_sim_filelist}" | grep '.*v$'`; do
      b=`basename "$q"`
      if [ -f "qsys_sim_files/${b}" ]; then
         echo "Removing duplicate Qsys ${b} already named in source list"
         rm qsys_sim_files/${b}
      fi
   done

   # Add generated Verilog to the list of sources
   find qsys_sim_files -type f > qsys_sim_files.list

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

setup_ase() {
   echo "Using ${sim} simulator"

   if [ "$sim" == "vcs" ] ; then
      get_vcs_home
   elif [ "$sim" == "modelsim" ] || [ "$sim" == "questa" ] ; then
      get_mti_home
   else
      echo "Unknown simulator"
      exit 1
   fi
}

run_sim() {
   # The contents of setup_ase used to be in run_sim. When scripts all invoke setup_ase
   # explicitly we can remove this.
   setup_ase

   # run ase make
   pushd $rtl_sim_dir
   make platform=ASE_PLATFORM_DCP
   make sim
   popd
}

wait_for_sim_ready() {
   ASE_READY_FILE=$rtl_sim_dir/work/.ase_ready.pid
   while [ ! -f $ASE_READY_FILE ]
   do
      echo "Waiting for simulation to start..."
      sleep 5
   done
   echo "simulation is ready!"
}

setup_app_env() {
   # setup env variables
   if [[ $opae_install ]]; then
      # non-RPM flow
      export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$opae_install/lib
	fi
   export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$app_base
   export ASE_WORKDIR=`readlink -m ${rtl_sim_dir}/work`
   echo "ASE workdir is $ASE_WORKDIR"

}

build_app() {
   set -x
   pushd $app_base
   # Build the software application
   if [[ $opae_install ]]; then
      # non-RPM flow
      echo "Non-RPM Flow"
      make prefix=$opae_install USE_ASE=1
   else
      # RPM flow
      echo "RPM Flow"
      make USE_ASE=1
   fi

   popd
}

exec_app() {
   pushd $app_base
   # find the executable and run
   find . -maxdepth 1 -type f -executable -exec {} \;
   popd
}

run_app() {
   setup_app_env
   wait_for_sim_ready
   pushd $app_base

   # Build the software application
   # make prefix=$opae_base USE_ASE=1

   # Build the software application
   if [[ $opae_install ]]; then
      # non-RPM flow
      echo "Non-RPM Flow"
      make prefix=$opae_install USE_ASE=1
   else
      # RPM flow
      echo "RPM Flow"
      make USE_ASE=1
   fi

   # find the executable and run
   find . -type f -executable -exec {} \;
   popd
}

kill_sim() {
   ase_workdir=$rtl_sim_dir/work/
   pid=`cat $ase_workdir/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`
   echo "Killing pid = $pid"
   kill $pid
   exit 0
}

configure_ase_reg_mode() {
   rm -f $rtl_sim_dir/sim_afu/ase.cfg
   echo "ASE_MODE = 4" >> $rtl_sim_dir/sim_afu/ase.cfg
   find $ASE_WORKDIR -name ase.cfg -exec cp $rtl_sim_dir/sim_afu/ase.cfg {} \;
}

copy_qsys_ip_files () {
   # No longer needed
   return 0
}
