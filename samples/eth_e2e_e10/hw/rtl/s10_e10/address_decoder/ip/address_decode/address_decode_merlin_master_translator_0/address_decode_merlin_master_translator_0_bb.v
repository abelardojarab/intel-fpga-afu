module address_decode_merlin_master_translator_0 #(
		parameter AV_ADDRESS_W                = 16,
		parameter AV_DATA_W                   = 32,
		parameter AV_BURSTCOUNT_W             = 1,
		parameter AV_BYTEENABLE_W             = 4,
		parameter UAV_ADDRESS_W               = 32,
		parameter UAV_BURSTCOUNT_W            = 10,
		parameter USE_READ                    = 1,
		parameter USE_WRITE                   = 1,
		parameter USE_BEGINBURSTTRANSFER      = 0,
		parameter USE_BEGINTRANSFER           = 0,
		parameter USE_CHIPSELECT              = 0,
		parameter USE_BURSTCOUNT              = 0,
		parameter USE_READDATAVALID           = 0,
		parameter USE_WAITREQUEST             = 1,
		parameter USE_READRESPONSE            = 0,
		parameter USE_WRITERESPONSE           = 0,
		parameter AV_SYMBOLS_PER_WORD         = 4,
		parameter AV_ADDRESS_SYMBOLS          = 0,
		parameter AV_BURSTCOUNT_SYMBOLS       = 0,
		parameter AV_CONSTANT_BURST_BEHAVIOR  = 0,
		parameter UAV_CONSTANT_BURST_BEHAVIOR = 0,
		parameter AV_LINEWRAPBURSTS           = 0,
		parameter AV_REGISTERINCOMINGSIGNALS  = 0,
		parameter SYNC_RESET                  = 0
	) (
		input  wire        clk,               //                       clk.clk
		input  wire        reset,             //                     reset.reset
		output wire [31:0] uav_address,       // avalon_universal_master_0.address
		output wire [9:0]  uav_burstcount,    //                          .burstcount
		output wire        uav_read,          //                          .read
		output wire        uav_write,         //                          .write
		input  wire        uav_waitrequest,   //                          .waitrequest
		input  wire        uav_readdatavalid, //                          .readdatavalid
		output wire [3:0]  uav_byteenable,    //                          .byteenable
		input  wire [31:0] uav_readdata,      //                          .readdata
		output wire [31:0] uav_writedata,     //                          .writedata
		output wire        uav_lock,          //                          .lock
		output wire        uav_debugaccess,   //                          .debugaccess
		input  wire [15:0] av_address,        //      avalon_anti_master_0.address
		output wire        av_waitrequest,    //                          .waitrequest
		input  wire        av_read,           //                          .read
		output wire [31:0] av_readdata,       //                          .readdata
		input  wire        av_write,          //                          .write
		input  wire [31:0] av_writedata       //                          .writedata
	);
endmodule

