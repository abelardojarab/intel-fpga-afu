#!/bin/bash
for i in `seq 1 10`;
do
	echo "Iteration = $i"
        ./fpga_dma_st_test -s 104857600 -p 1048576 -r mtos -t fixed
done
