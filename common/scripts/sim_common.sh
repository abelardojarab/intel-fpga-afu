#!/bin/bash
# script to setup common variables
set -e

# Get exact script path
COMMON_SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
# Get directory of script path
COMMON_SCRIPT_DIR_PATH="$(dirname $COMMON_SCRIPT_PATH)"

usage() {
   echo "Usage: $0 -a <afu dir> -r <rtl simulation dir>" 1>&2
   echo "                       [-s <vcs|modelsim|questa>] [-p <platform>] [-v <variant>]" 1>&2
   echo "                       [-b <opae base dir>] [-i <opae install path>]" 1>&2
   echo "                       [-m <EMIF_MODEL_BASIC|EMIF_MODEL_ADVANCED> memory model]" 1>&2
   exit 1
}

parse_args() {
   # Defaults
   v=""
   r=""
   b="${OPAE_BASEDIR}"
   i=""

   # By documented convention, OPAE_PLATFORM_ROOT points to the root of a release tree.
   # The platform's interface class is stored there.
   p="discrete"
   if [ "${OPAE_PLATFORM_ROOT}" != "" ]; then
      p=`cat "${OPAE_PLATFORM_ROOT}/hw/lib/fme-platform-class.txt"`
   fi

   if [ -x "$(command -v vcs)" ] ; then
      s="vcs"
   elif [ -x "$(command -v vsim)" ] ; then
      s="questa"
   fi

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
   app_base=${a}/sw
   variant=${v}
   platform=${p}
   rtl_sim_dir=${r}
   sim=${s}
   mem_model=${m}
   opae_base=${b}
   opae_install=${i}

   rtl_filelist="${rtl}/filelist.txt"
   if [ "${v}" != "" ]; then
      rtl_filelist="${rtl}/filelist_${variant}.txt"
   fi

   # mandatory args
   if [ -z "${a}" ] || [ -z "${s}" ] || [ -z "${r}" ]; then
      usage;
   fi

   if [[ "$sim" != "vcs" ]] && [[ "$sim" != "questa" ]] && [[ "$sim" != "modelsim" ]]   ; then
      echo "Supported simulators are VCS, Modelsim and Questa. You specified $sim"
      usage;
   fi

   if [[ ! $mem_model ]]; then
      # use default
      mem_model=EMIF_MODEL_BASIC
   fi

   echo "afu=$afu, rtl=$rtl, app_base=$app_base, sim=$sim, mem_model=$mem_model, variant=$variant, platform=$platform"
   echo "rtl_sim_dir=$rtl_sim_dir"
}

menu_run_app() {
   parse_args "$@"
}

# Quiet pushd/popd
pushd () {
  command pushd "$@" > /dev/null
}
popd () {
  command popd "$@" > /dev/null
}

setup_sim_dir() {
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

   popd
}

setup_quartus_home() {
   # use QUARTUS_HOME (from env)
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
      # Delete old generated content
      rm -rf ${q%.*}
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

   setup_quartus_home
}

build_sim() {
   setup_ase

   pushd $rtl_sim_dir
   # run ase make
   make
   popd
}

run_sim() {
   setup_ase

   pushd $rtl_sim_dir
   # build_sim must already have been called
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
   build_app
   exec_app
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
