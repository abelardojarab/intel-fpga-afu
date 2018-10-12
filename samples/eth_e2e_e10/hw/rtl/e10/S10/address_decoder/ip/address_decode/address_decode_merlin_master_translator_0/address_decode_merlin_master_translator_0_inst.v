	address_decode_merlin_master_translator_0 #(
		.AV_ADDRESS_W                (INTEGER_VALUE_FOR_AV_ADDRESS_W),
		.AV_DATA_W                   (INTEGER_VALUE_FOR_AV_DATA_W),
		.AV_BURSTCOUNT_W             (INTEGER_VALUE_FOR_AV_BURSTCOUNT_W),
		.AV_BYTEENABLE_W             (INTEGER_VALUE_FOR_AV_BYTEENABLE_W),
		.UAV_ADDRESS_W               (INTEGER_VALUE_FOR_UAV_ADDRESS_W),
		.UAV_BURSTCOUNT_W            (INTEGER_VALUE_FOR_UAV_BURSTCOUNT_W),
		.USE_READ                    (INTEGER_VALUE_FOR_USE_READ),
		.USE_WRITE                   (INTEGER_VALUE_FOR_USE_WRITE),
		.USE_BEGINBURSTTRANSFER      (INTEGER_VALUE_FOR_USE_BEGINBURSTTRANSFER),
		.USE_BEGINTRANSFER           (INTEGER_VALUE_FOR_USE_BEGINTRANSFER),
		.USE_CHIPSELECT              (INTEGER_VALUE_FOR_USE_CHIPSELECT),
		.USE_BURSTCOUNT              (INTEGER_VALUE_FOR_USE_BURSTCOUNT),
		.USE_READDATAVALID           (INTEGER_VALUE_FOR_USE_READDATAVALID),
		.USE_WAITREQUEST             (INTEGER_VALUE_FOR_USE_WAITREQUEST),
		.USE_READRESPONSE            (INTEGER_VALUE_FOR_USE_READRESPONSE),
		.USE_WRITERESPONSE           (INTEGER_VALUE_FOR_USE_WRITERESPONSE),
		.AV_SYMBOLS_PER_WORD         (INTEGER_VALUE_FOR_AV_SYMBOLS_PER_WORD),
		.AV_ADDRESS_SYMBOLS          (INTEGER_VALUE_FOR_AV_ADDRESS_SYMBOLS),
		.AV_BURSTCOUNT_SYMBOLS       (INTEGER_VALUE_FOR_AV_BURSTCOUNT_SYMBOLS),
		.AV_CONSTANT_BURST_BEHAVIOR  (INTEGER_VALUE_FOR_AV_CONSTANT_BURST_BEHAVIOR),
		.UAV_CONSTANT_BURST_BEHAVIOR (INTEGER_VALUE_FOR_UAV_CONSTANT_BURST_BEHAVIOR),
		.AV_LINEWRAPBURSTS           (INTEGER_VALUE_FOR_AV_LINEWRAPBURSTS),
		.AV_REGISTERINCOMINGSIGNALS  (INTEGER_VALUE_FOR_AV_REGISTERINCOMINGSIGNALS),
		.SYNC_RESET                  (INTEGER_VALUE_FOR_SYNC_RESET)
	) u0 (
		.clk               (_connected_to_clk_),               //   input,   width = 1,                       clk.clk
		.reset             (_connected_to_reset_),             //   input,   width = 1,                     reset.reset
		.uav_address       (_connected_to_uav_address_),       //  output,  width = 32, avalon_universal_master_0.address
		.uav_burstcount    (_connected_to_uav_burstcount_),    //  output,  width = 10,                          .burstcount
		.uav_read          (_connected_to_uav_read_),          //  output,   width = 1,                          .read
		.uav_write         (_connected_to_uav_write_),         //  output,   width = 1,                          .write
		.uav_waitrequest   (_connected_to_uav_waitrequest_),   //   input,   width = 1,                          .waitrequest
		.uav_readdatavalid (_connected_to_uav_readdatavalid_), //   input,   width = 1,                          .readdatavalid
		.uav_byteenable    (_connected_to_uav_byteenable_),    //  output,   width = 4,                          .byteenable
		.uav_readdata      (_connected_to_uav_readdata_),      //   input,  width = 32,                          .readdata
		.uav_writedata     (_connected_to_uav_writedata_),     //  output,  width = 32,                          .writedata
		.uav_lock          (_connected_to_uav_lock_),          //  output,   width = 1,                          .lock
		.uav_debugaccess   (_connected_to_uav_debugaccess_),   //  output,   width = 1,                          .debugaccess
		.av_address        (_connected_to_av_address_),        //   input,  width = 16,      avalon_anti_master_0.address
		.av_waitrequest    (_connected_to_av_waitrequest_),    //  output,   width = 1,                          .waitrequest
		.av_read           (_connected_to_av_read_),           //   input,   width = 1,                          .read
		.av_readdata       (_connected_to_av_readdata_),       //  output,  width = 32,                          .readdata
		.av_write          (_connected_to_av_write_),          //   input,   width = 1,                          .write
		.av_writedata      (_connected_to_av_writedata_)       //   input,  width = 32,                          .writedata
	);

