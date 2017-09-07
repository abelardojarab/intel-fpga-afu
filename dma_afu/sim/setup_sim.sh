#!/bin/bash
#get exact script path
SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
#get director of script path
SCRIPT_DIR_PATH="$(dirname $SCRIPT_PATH)"

. $SCRIPT_DIR_PATH/sim_common.sh

set -e

menu_setup_sim "$@"
setup_sim_dir
setup_quartus_home

rm -rf $sim_afu_path/qsys_sim_files
mkdir -p $sim_afu_path/qsys_sim_files
mkdir -p $sim_afu_path/dummy_rtl_dir

# generate qsys systems
pushd sim_afu/interfaces
find . -name *.qsys -exec qsys-generate {} --simulation=VERILOG \;

qsys-generate --synthesis=VERILOG $sim_afu_path/qsys/dma_test_system.qsys
copy_qsys_ip_files dma_test_system
copy_qsys_ip_files msgdma_bbb
copy_qsys_ip_files ccip_avmm_bridge

find $sim_afu_path/qsys_sim_files -type f > $sim_afu_path/qsys_sim_filelist.txt
touch $sim_afu_path/dummy_rtl_dir/dummy_rtl_file.sv

# remove _inst.v , _bb.v and *.vhd
find $PWD -name *.vhd -exec rm -rf {} \;
find $PWD -name '*_inst.v' -exec rm -rf {} \;
find $PWD -name '*_bb.v' -exec rm -rf {} \;
popd

cp -Rv sim.filelist $sim_afu_path

pushd $opae_base/ase
rm -rf ase_sources.mk
touch $sim_afu_path/dummy_rtl_dir/dummy_rtl.sv

if [ "$sim" == "vcs" ]; then
  echo "Using VCS"
  ./scripts/generate_ase_environment.py -t VCS -p dcp $sim_afu_path/dummy_rtl_dir
  echo "-F $sim_afu_path/sim.filelist" > vlog_files.list
  echo "SNPS_VLOGAN_OPT+= +define+INCLUDE_DDR4" >> ase_sources.mk
  echo "SNPS_VLOGAN_OPT+= +define+INCLUDE_DDR4 +define+DDR_ADDR_WIDTH=26" >> ase_sources.mk
else
  echo "Using Questa"
  export MTI_HOME=$MODELSIM_ROOTDIR
  ./scripts/generate_ase_environment.py -t QUESTA -p dcp $sim_afu_path/dummy_rtl_dir
  echo "-F $sim_afu_path/sim.filelist" > vlog_files.list
  echo "MENT_VLOG_OPT += +define+INCLUDE_DDR4 +define+DDR_ADDR_WIDTH=26 -suppress 3485,3584" >> ase_sources.mk
  echo "MENT_VSIM_OPT += -suppress 3485,3584" >> ase_sources.mk
fi

# run ase make
make platform=ASE_PLATFORM_DCP
make sim &

popd
