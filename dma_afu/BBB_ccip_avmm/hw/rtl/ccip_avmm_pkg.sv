//
// Internal parameters and structs for ccip_avmm
//

package ccip_avmm_pkg;

	//18bit byte address for avalon, 16bit word address for ccip
	parameter CCIP_AVMM_MMIO_ADDR_WIDTH = 18;
	parameter CCIP_AVMM_MMIO_DATA_WIDTH = 64;

	typedef struct packed { 
		logic is_read;
		logic is_32bit;
		logic [CCIP_AVMM_MMIO_ADDR_WIDTH-1:0] addr;
		logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0] write_data;
	} t_ccip_avmm_mmio_cmd;

	parameter CCIP_AVMM_REQUESTOR_DATA_WIDTH = 512;
	parameter CCIP_AVMM_REQUESTOR_ADDR_WIDTH = 48;
	parameter CCIP_AVMM_REQUESTOR_BURST_WIDTH = 3;
	parameter CCIP_AVMM_REQUESTOR_CONTROL_WIDTH = 1;

endpackage // ccip_feature_list_pkg