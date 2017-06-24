#!/bin/bash

# NLB Mode 0
# Generate Verilog simulation files
# Run this script from Terminal 1

set -e

# generate all .qsys files under afu
afu_dir=$PWD/../afu

# cleanup
rm -rf sim_afu
mkdir -p sim_afu

# copy afu sources here (except ccip_if_pkg.sv which is already included in ASE RTL source)
rsync -av --progress $afu_dir/* ./sim_afu --exclude ccip_if_pkg.sv

find $PWD -name *.qsys -exec qsys-generate --simulation=VERILOG {} \;

# get path of simulation afu dir
sim_afu_path=$PWD/sim_afu

# remove _inst.v , _bb.v and *.vhd
find $PWD -name *.vhd -exec rm -rf {} \;
find $PWD -name '*_inst.v' -exec rm -rf {} \;
find $PWD -name '*_bb.v' -exec rm -rf {} \;

# detect QUARTUS_HOME from environment
quartus_bin=`which quartus`
quartus_bin_dir=`dirname $quartus_bin`
export QUARTUS_HOME="$quartus_bin_dir/../"
echo "Info: Quartus home detected at $QUARTUS_HOME"

# navigate to ase in release drop
pushd $PWD/../../../../../../sw/opae-0.3.0/ase/
rm -rf ase_sources.mk
./scripts/generate_ase_environment.py -t VCS -p dcp $sim_afu_path

# enable INCLUDE_DDR4 macro for DCP simulation
echo "SNPS_VLOGAN_OPT+= +define+INCLUDE_DDR4 +define+NLB400_MODE_0" >> ase_sources.mk

# run ase make
make platform=ASE_PLATFORM_DCP
make sim

popd
