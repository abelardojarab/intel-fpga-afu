#!/bin/bash

#get exact script path
SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
#get director of script path
SCRIPT_DIR_PATH="$(dirname $SCRIPT_PATH)"

. $SCRIPT_DIR_PATH/sim_common.sh
# Run this script from Terminal 2
menu_regress "$@"
sh setup_sim.sh -a $afu -b $opae_base -s $sim &
sh run_app.sh -a $app -b $opae_base
kill_sim
