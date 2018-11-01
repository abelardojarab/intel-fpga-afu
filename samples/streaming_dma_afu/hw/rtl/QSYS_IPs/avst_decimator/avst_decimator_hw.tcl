# TCL File Generated by Component Editor 17.1
# Thu Nov 01 13:51:19 CDT 2018
# DO NOT MODIFY


# 
# avst_decimator "avst_decimator" v1.0
# JCJB 2018.11.01.13:51:19
# Streaming module that will programmatically remove data from the stream.
# 

# 
# request TCL package from ACDS 17.1
# 
package require -exact qsys 17.1


# 
# module avst_decimator
# 
set_module_property DESCRIPTION "Streaming module that will programmatically remove data from the stream."
set_module_property NAME avst_decimator
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR JCJB
set_module_property DISPLAY_NAME avst_decimator
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL streaming_decimator
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file streaming_decimator.sv SYSTEM_VERILOG PATH streaming_decimator.sv TOP_LEVEL_FILE

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL streaming_decimator
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VERILOG ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file streaming_decimator.sv SYSTEM_VERILOG PATH streaming_decimator.sv

add_fileset SIM_VHDL SIM_VHDL "" ""
set_fileset_property SIM_VHDL TOP_LEVEL streaming_decimator
set_fileset_property SIM_VHDL ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VHDL ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file streaming_decimator.sv SYSTEM_VERILOG PATH streaming_decimator.sv



set_module_property VALIDATION_CALLBACK     validate_me

# 
# parameters
# 
add_parameter DATA_WIDTH INTEGER 512
set_parameter_property DATA_WIDTH DEFAULT_VALUE 512
set_parameter_property DATA_WIDTH ALLOWED_RANGES {16 32 64 128 256 512 1024}
set_parameter_property DATA_WIDTH DISPLAY_NAME "Data Width"
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH HDL_PARAMETER true

add_parameter EMPTY_WIDTH INTEGER 6
set_parameter_property EMPTY_WIDTH DEFAULT_VALUE 6
set_parameter_property EMPTY_WIDTH DISPLAY_NAME EMPTY_WIDTH
set_parameter_property EMPTY_WIDTH VISIBLE false
set_parameter_property EMPTY_WIDTH DERIVED true
set_parameter_property EMPTY_WIDTH UNITS None
set_parameter_property EMPTY_WIDTH HDL_PARAMETER true


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges BOTH
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point csr
# 
add_interface csr avalon end
set_interface_property csr addressGroup 0
set_interface_property csr addressUnits WORDS
set_interface_property csr associatedClock clock
set_interface_property csr associatedReset reset
set_interface_property csr bitsPerSymbol 8
set_interface_property csr bridgedAddressOffset ""
set_interface_property csr bridgesToMaster ""
set_interface_property csr burstOnBurstBoundariesOnly false
set_interface_property csr burstcountUnits WORDS
set_interface_property csr explicitAddressSpan 0
set_interface_property csr holdTime 0
set_interface_property csr linewrapBursts false
set_interface_property csr maximumPendingReadTransactions 0
set_interface_property csr maximumPendingWriteTransactions 0
set_interface_property csr minimumResponseLatency 1
set_interface_property csr readLatency 1
set_interface_property csr readWaitStates 0
set_interface_property csr readWaitTime 0
set_interface_property csr setupTime 0
set_interface_property csr timingUnits Cycles
set_interface_property csr transparentBridge false
set_interface_property csr waitrequestAllowance 0
set_interface_property csr writeWaitTime 0
set_interface_property csr ENABLED true
set_interface_property csr EXPORT_OF ""
set_interface_property csr PORT_NAME_MAP ""
set_interface_property csr CMSIS_SVD_VARIABLES ""
set_interface_property csr SVD_ADDRESS_GROUP ""

add_interface_port csr csr_write write Input 1
add_interface_port csr csr_writedata writedata Input 64
add_interface_port csr csr_byteenable byteenable Input 8
add_interface_port csr csr_read read Input 1
add_interface_port csr csr_readdata readdata Output 64
set_interface_assignment csr embeddedsw.configuration.isFlash 0
set_interface_assignment csr embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment csr embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment csr embeddedsw.configuration.isPrintableDevice 0


# 
# connection point source
# 
add_interface source avalon_streaming start
set_interface_property source associatedClock clock
set_interface_property source associatedReset reset
set_interface_property source dataBitsPerSymbol 8
set_interface_property source errorDescriptor ""
set_interface_property source firstSymbolInHighOrderBits true
set_interface_property source maxChannel 0
set_interface_property source readyLatency 0
set_interface_property source ENABLED true
set_interface_property source EXPORT_OF ""
set_interface_property source PORT_NAME_MAP ""
set_interface_property source CMSIS_SVD_VARIABLES ""
set_interface_property source SVD_ADDRESS_GROUP ""

add_interface_port source src_data data Output "((DATA_WIDTH - 1)) - (0) + 1"
add_interface_port source src_sop startofpacket Output 1
add_interface_port source src_eop endofpacket Output 1
add_interface_port source src_empty empty Output "((EMPTY_WIDTH - 1)) - (0) + 1"
add_interface_port source src_ready ready Input 1
add_interface_port source src_valid valid Output 1


# 
# connection point sink
# 
add_interface sink avalon_streaming end
set_interface_property sink associatedClock clock
set_interface_property sink associatedReset reset
set_interface_property sink dataBitsPerSymbol 8
set_interface_property sink errorDescriptor ""
set_interface_property sink firstSymbolInHighOrderBits true
set_interface_property sink maxChannel 0
set_interface_property sink readyLatency 0
set_interface_property sink ENABLED true
set_interface_property sink EXPORT_OF ""
set_interface_property sink PORT_NAME_MAP ""
set_interface_property sink CMSIS_SVD_VARIABLES ""
set_interface_property sink SVD_ADDRESS_GROUP ""

add_interface_port sink snk_data data Input "((DATA_WIDTH - 1)) - (0) + 1"
add_interface_port sink snk_sop startofpacket Input 1
add_interface_port sink snk_eop endofpacket Input 1
add_interface_port sink snk_empty empty Input "((EMPTY_WIDTH - 1)) - (0) + 1"
add_interface_port sink snk_valid valid Input 1
add_interface_port sink snk_ready ready Output 1


proc validate_me {}  {
  set_parameter_value EMPTY_WIDTH [expr {(log([get_parameter_value DATA_WIDTH] / 8) / log(2))}]
}
