#!/bin/bash

#get exact script path
SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
#get director of script path
SCRIPT_DIR_PATH="$(dirname $SCRIPT_PATH)"

. $SCRIPT_DIR_PATH/sim_common.sh
# Run this script from Terminal 2
menu_run_app "$@"
setup_app_env
pushd $app_base
# Build the software application
make prefix=$opae_base USE_ASE=1
wait_for_sim_ready
# usage: hello_mem_afu <bank#> <use_ase=1>
$app_base/hello_mem_afu 0 1
popd
