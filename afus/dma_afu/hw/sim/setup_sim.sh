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

set -e

# Get exact script path
SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
# Get directory of script path
SCRIPT_DIR_PATH="$(dirname $SCRIPT_PATH)"
# Find shared script directory (first parent with a "common" directory)
SCRIPT_COMMON_DIR=`${SCRIPT_DIR_PATH}/find_parent_dir.sh common`

. ${SCRIPT_COMMON_DIR}/scripts/sim_common.sh

menu_setup_sim "$@"
setup_sim_dir
setup_quartus_home

# Generate qsys systems
for q in `rtl_src_config --qsys --abs ${sim_afu_path}/filelist.txt | grep .qsys$`; do
  $QUARTUS_HOME/sopc_builder/bin/qsys-generate --synthesis=VERILOG $q
done

# Copy simulation Verilog files to a common directory
rm -rf $sim_afu_path/qsys_sim_files
mkdir -p $sim_afu_path/qsys_sim_files
copy_qsys_ip_files dma_test_system
copy_qsys_ip_files msgdma_bbb
# afu_id_avmm_slave.sv was already named explicitly
rm $sim_afu_path/qsys_sim_files/afu_id_avmm_slave.sv

# Discover all simulation Verilog files, converting them to absolute paths
find $sim_afu_path/qsys_sim_files -type f | xargs -n1 -IAAA readlink -f AAA > $sim_afu_path/qsys_sim_filelist.txt

pushd $rtl_sim_dir

# Make a dummy source file to keep generate_ase_environment happy
mkdir -p dummy_rtl_dir
touch dummy_rtl_dir/dummy_rtl.sv
rm -rf ase_sources.mk

if [ "$sim" == "vcs" ]; then
  get_vcs_home
  ./scripts/generate_ase_environment.py -t VCS -p discrete dummy_rtl_dir
  echo "SNPS_VLOGAN_OPT+= +define+INCLUDE_DDR4" >> ase_sources.mk
  echo "SNPS_VLOGAN_OPT+= +define+INCLUDE_DDR4 +define+DDR_ADDR_WIDTH=26" >> ase_sources.mk
else
  echo "Using Questa"
  get_mti_home
  ./scripts/generate_ase_environment.py -t QUESTA -p discrete dummy_rtl_dir
  echo "MENT_VLOG_OPT += +define+INCLUDE_DDR4 +define+DDR_ADDR_WIDTH=26 -suppress 3485,3584" >> ase_sources.mk
  echo "MENT_VSIM_OPT += -suppress 3485,3584" >> ase_sources.mk
fi

rm -rf dummy_rtl_dir

popd
# Emit source file list
rtl_src_config --abs --sim $sim_afu_path/filelist.txt | grep -v 'json$' > $rtl_sim_dir/vlog_files.list
pushd $rtl_sim_dir

# run ase make
make platform=ASE_PLATFORM_DCP
make sim

popd
