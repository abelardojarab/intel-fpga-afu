include ../../../bcommon/common.mk

AFU.NAME := boardtest
AFU.PLATFORMS := dcp_1.0-skx dcp_1.0-rc
AFU.VARIANTS := skx_fpga_dcp_ddr

AFU_AOC_OPTIONS ?=
AFU_AOC_OPTIONS += --no-interleaving default 
AFU_AOC_OPTIONS += --duplicate-ring 

include ../../../bcommon/opencl_kernel.mk
