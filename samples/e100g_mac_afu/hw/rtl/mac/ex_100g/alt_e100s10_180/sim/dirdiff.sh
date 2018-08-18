# (C) 2001-2018 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


echo " Usage: sh dirdiff.sh <path1> <path2> \n";
perl ../../bin/hsldiff $1/ast	      $2/ast
perl ../../bin/hsldiff $1/clones      $2/clones
perl ../../bin/hsldiff $1/clones18    $2/clones18
perl ../../bin/hsldiff $1/csr         $2/csr
perl ../../bin/hsldiff $1/diff.rpt    $2/diff.rpt
perl ../../bin/hsldiff $1/efc         $2/efc
perl ../../bin/hsldiff $1/eth         $2/eth
perl ../../bin/hsldiff $1/lib         $2/lib
perl ../../bin/hsldiff $1/mac         $2/mac
perl ../../bin/hsldiff $1/pcs         $2/pcs
perl ../../bin/hsldiff $1/pfc         $2/pfc
perl ../../bin/hsldiff $1/pma         $2/pma
perl ../../bin/hsldiff $1/pma.a10     $2/pma.a10
perl ../../bin/hsldiff $1/ptp         $2/ptp
perl ../../bin/hsldiff $1/ptp_qrt     $2/ptp_qrt
perl ../../bin/hsldiff $1/ptp_sim     $2/ptp_sim
perl ../../bin/hsldiff $1/ptp_spy     $2/ptp_spy
perl ../../bin/hsldiff $1/ref         $2/ref
perl ../../bin/hsldiff $1/stacker2    $2/stacker2
