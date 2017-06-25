#!/bin/bash

# Simulation script for DMA AFU
# Generate Verilog simulation files
# Run this script from Terminal 1

set -v

sim_afu_path=$PWD/sim_afu

copy_qsys_ip_files () {
	QSYS_NAME=$1
	find $sim_afu_path/qsys/$QSYS_NAME/ \
	$sim_afu_path/qsys/ip/$QSYS_NAME/ \
	-name synth -type d | \
	\
	xargs -n1 -IAAA find AAA -name "*.*v" | \
	xargs -n1 -IAAA cp -f AAA $sim_afu_path/qsys_sim_files
}

afu_dir=$PWD/../afu
rm -rf sim_afu
mkdir -p sim_afu
rm -rf $sim_afu_path/qsys_sim_files

# copy afu sources here (except ccip_if_pkg.sv which is already included in ASE RTL source)
rsync -av --progress $afu_dir/* ./sim_afu --exclude ccip_if_pkg.sv

mkdir -p $sim_afu_path/qsys_sim_files
mkdir -p $sim_afu_path/dummy_rtl_dir

qsys-generate --synthesis=VERILOG $sim_afu_path/qsys/dma_test_system.qsys

copy_qsys_ip_files dma_test_system
copy_qsys_ip_files msgdma_bbb
copy_qsys_ip_files ccip_avmm_bridge

find $sim_afu_path/qsys_sim_files -type f > $sim_afu_path/qsys_sim_filelist.txt
cp -Rv sim.filelist $sim_afu_path
touch $sim_afu_path/dummy_rtl_dir/dummy_rtl_file.sv

# detect QUARTUS_HOME from environment
quartus_bin=`which quartus`
quartus_bin_dir=`dirname $quartus_bin`
export QUARTUS_HOME="$quartus_bin_dir/../"
echo "Info: Quartus home detected at $QUARTUS_HOME"

# navigate to ase in release drop
pushd $PWD/../../../../../sw/opae-0.3.0/ase/
rm -rf ase_sources.mk

touch dummy_rtl_dir/dummy_rtl_file.sv

./scripts/generate_ase_environment.py -t VCS -p dcp $sim_afu_path/dummy_rtl_dir
echo "-F $sim_afu_path/sim.filelist" > vlog_files.list

# run ase make
make platform=ASE_PLATFORM_DCP
make sim

popd
