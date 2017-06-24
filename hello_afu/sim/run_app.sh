#!/bin/bash

# Run this script from Terminal 2

set -e

pushd ../sw

# Build the software application
make prefix=$PWD/../../../../../sw/opae-0.3.0 USE_ASE=1

# setup env variables
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/../../../../../sw/opae-0.3.0/build/lib
export ASE_WORKDIR=$PWD/../../../../../sw/opae-0.3.0/ase/work/

# run the application
./hello_afu

popd

