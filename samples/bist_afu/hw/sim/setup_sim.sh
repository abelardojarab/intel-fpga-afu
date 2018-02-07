#!/bin/bash
## Copyright(c) 2013-2017, Intel Corporation
##
## Redistribution  and  use  in source  and  binary  forms,  with  or  without
## modification, are permitted provided that the following conditions are met:
##
## * Redistributions of  source code  must retain the  above copyright notice,
##   this list of conditions and the following disclaimer.
## * Redistributions in binary form must reproduce the above copyright notice,
##   this list of conditions and the following disclaimer in the documentation
##   and/or other materials provided with the distribution.
## * Neither the name  of Intel Corporation  nor the names of its contributors
##   may be used to  endorse or promote  products derived  from this  software
##   without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO,  THE
## IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS BE
## LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
## CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
## SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
## INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
## CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.

#get exact script path
SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
#get director of script path
SCRIPT_DIR_PATH="$(dirname $SCRIPT_PATH)"

set -e
. $ADAPT_SRC_ROOT/afu/common/scripts/sim_common.sh
menu_setup_sim "$@"
setup_sim_dir
setup_quartus_home
gen_qsys

sim_afu_path="$ADAPT_SRC_ROOT/regtest/dcp_1.0-skx/ase/bist_afu_vcs/build/fpga_api_src/rtl_sim/sim_afu"
echo "sim_afu_path is ${sim_afu_path}"

rm -rf $sim_afu_path/ddr_bist
mkdir -p $sim_afu_path/ddr_bist

mkdir $sim_afu_path/../sim
cp -r $ADAPT_SRC_ROOT/afu/samples/bist_afu/hw/sim/* $sim_afu_path/../sim/
rm -rf $sim_afu_path/ddr_bist/synth/*
mkdir -p $sim_afu_path/dummy_rtl_dir

#bist needs additional user-defined macros
add_text_macros +define+NLB400_MODE_0

touch $sim_afu_path/dummy_rtl_dir/dummy_rtl_file.sv

cp -Rv sim.filelist $sim_afu_path
cp -Rv sim.qsys_filelist $sim_afu_path

# Generate qsys systems
for q in `rtl_src_config --qsys --abs ${sim_afu_path}/sim.qsys_filelist`; do
  $QUARTUS_HOME/sopc_builder/bin/qsys-generate --synthesis=VERILOG --simulation=VERILOG $q
done


pushd $rtl_sim_dir
rm -rf ase_sources.mk
touch $sim_afu_path/dummy_rtl_dir/dummy_rtl.sv

if [ "$sim" == "vcs" ]; then
  get_vcs_home
  ./scripts/generate_ase_environment.py -t VCS -p discrete $sim_afu_path/dummy_rtl_dir
  echo "-F $sim_afu_path/sim.filelist" > vlog_files.list
  echo "SNPS_VLOGAN_OPT+= +define+INCLUDE_DDR4" >> ase_sources.mk
  echo "SNPS_VLOGAN_OPT+= +define+INCLUDE_DDR4 +define+DDR_ADDR_WIDTH=26" >> ase_sources.mk
else
  echo "Using Questa"
  get_mti_home
  ./scripts/generate_ase_environment.py -t QUESTA -p discrete $sim_afu_path/dummy_rtl_dir
  echo "-F $sim_afu_path/sim.filelist" > vlog_files.list
  echo "MENT_VLOG_OPT += +define+INCLUDE_DDR4 +define+DDR_ADDR_WIDTH=26 -suppress 3485,3584" >> ase_sources.mk
  echo "MENT_VSIM_OPT += -suppress 3485,3584" >> ase_sources.mk
fi

# run ase make
make platform=ASE_PLATFORM_DCP
make sim

popd

# run_sim

