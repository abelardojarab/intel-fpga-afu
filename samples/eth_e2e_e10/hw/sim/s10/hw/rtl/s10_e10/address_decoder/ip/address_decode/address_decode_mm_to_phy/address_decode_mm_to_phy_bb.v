module address_decode_mm_to_phy #(
		parameter AV_ADDRESS_W                   = 11,
		parameter AV_DATA_W                      = 32,
		parameter UAV_DATA_W                     = 32,
		parameter AV_BURSTCOUNT_W                = 4,
		parameter AV_BYTEENABLE_W                = 4,
		parameter UAV_BYTEENABLE_W               = 4,
		parameter UAV_ADDRESS_W                  = 13,
		parameter UAV_BURSTCOUNT_W               = 4,
		parameter AV_READLATENCY                 = 0,
		parameter USE_READDATAVALID              = 0,
		parameter USE_WAITREQUEST                = 1,
		parameter USE_UAV_CLKEN                  = 0,
		parameter USE_READRESPONSE               = 0,
		parameter USE_WRITERESPONSE              = 0,
		parameter AV_SYMBOLS_PER_WORD            = 4,
		parameter AV_ADDRESS_SYMBOLS             = 0,
		parameter AV_BURSTCOUNT_SYMBOLS          = 0,
		parameter AV_CONSTANT_BURST_BEHAVIOR     = 0,
		parameter UAV_CONSTANT_BURST_BEHAVIOR    = 0,
		parameter AV_REQUIRE_UNALIGNED_ADDRESSES = 0,
		parameter CHIPSELECT_THROUGH_READLATENCY = 0,
		parameter AV_READ_WAIT_CYCLES            = 1,
		parameter AV_WRITE_WAIT_CYCLES           = 0,
		parameter AV_SETUP_WAIT_CYCLES           = 0,
		parameter AV_DATA_HOLD_CYCLES            = 0,
		parameter WAITREQUEST_ALLOWANCE          = 0,
		parameter SYNC_RESET                     = 0
	) (
		input  wire        clk,               //                      clk.clk
		input  wire        reset,             //                    reset.reset
		input  wire [12:0] uav_address,       // avalon_universal_slave_0.address
		input  wire [3:0]  uav_burstcount,    //                         .burstcount
		input  wire        uav_read,          //                         .read
		input  wire        uav_write,         //                         .write
		output wire        uav_waitrequest,   //                         .waitrequest
		output wire        uav_readdatavalid, //                         .readdatavalid
		input  wire [3:0]  uav_byteenable,    //                         .byteenable
		output wire [31:0] uav_readdata,      //                         .readdata
		input  wire [31:0] uav_writedata,     //                         .writedata
		input  wire        uav_lock,          //                         .lock
		input  wire        uav_debugaccess,   //                         .debugaccess
		output wire [10:0] av_address,        //      avalon_anti_slave_0.address
		output wire        av_write,          //                         .write
		output wire        av_read,           //                         .read
		input  wire [31:0] av_readdata,       //                         .readdata
		output wire [31:0] av_writedata,      //                         .writedata
		input  wire        av_waitrequest     //                         .waitrequest
	);
endmodule

