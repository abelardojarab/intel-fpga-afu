#!/bin/bash

#get exact script path
SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
#get director of script path
SCRIPT_DIR_PATH="$(dirname $SCRIPT_PATH)"

. $SCRIPT_DIR_PATH/sim_common.sh
# Run this script from Terminal 2
menu_run_app "$@"
# nlb requires special build since app source isn't located with afu
gcc -g -o $app_base/hello_fpga $app_base/hello_fpga.c -L $opae_base/inst/lib/ -I $opae_base/inst/include -luuid -lpthread -lopae-c-ase -std=c99
run_app
