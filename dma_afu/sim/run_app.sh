#!/bin/bash

# Run this script from Terminal 2

set -e

pushd ../sw

# Build the software application
make clean
make prefix=$PWD/../../../../../sw/opae-0.3.0 USE_ASE=1

# setup env variables
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/../../../../../sw/opae-0.3.0/build/lib:$PWD/../sw
export ASE_WORKDIR=$PWD/../../../../../sw/opae-0.3.0/ase/work/

# run the application
# usage: fpga_dma_test <use_ase=1>
./fpga_dma_test 1

popd

