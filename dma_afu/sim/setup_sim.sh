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
find . -name *.qsys -exec $QUARTUS_HOME/sopc_builder/bin/qsys-generate {} --simulation=VERILOG \;

$QUARTUS_HOME/sopc_builder/bin/qsys-generate --synthesis=VERILOG $sim_afu_path/qsys/dma_test_system.qsys
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
