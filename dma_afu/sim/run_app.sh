#!/bin/bash

#get exact script path
SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
#get director of script path
SCRIPT_DIR_PATH="$(dirname $SCRIPT_PATH)"
. $SCRIPT_DIR_PATH/sim_common.sh
# Run this script from Terminal 2

set -e

menu_run_app "$@"

wait_for_sim_ready
setup_app_env
build_app
# run the executable
$app_base/fpga_dma_test 1
