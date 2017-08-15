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
gen_qsys
run_sim
