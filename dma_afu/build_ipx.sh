#!/bin/bash

PATH_TO_AFU_SRC="."
if [ "$1" != "" ]; then                                                         
    PATH_TO_AFU_SRC=$1
fi

ip-make-ipx --source-directory=$PATH_TO_AFU_SRC,$PATH_TO_AFU_SRC/qsys/,$PATH_TO_AFU_SRC/qsys/afu_id_avmm_slave/,$PATH_TO_AFU_SRC/qsys/avst_to_avmm/,$PATH_TO_AFU_SRC/qsys/avst_to_avmm_master/
