#!/bin/bash

# NLB_MODE_0
# Run this script from Terminal 2

set -e
set -v

# Build the software application
pushd $PWD/../../../../../../sw/opae-0.3.0/samples
rm hello_fpga
gcc -g -o hello_fpga hello_fpga.c -L $PWD/../build/lib/ -I $PWD/../build/include/ -luuid -lpthread -lopae-c-ase -std=c99

# setup env variables
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/../build/lib
export ASE_WORKDIR=$PWD/../ase/work/

# run the application
./hello_fpga

popd

