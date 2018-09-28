	address_decode_eth_gen_mon #(
		.AV_ADDRESS_W                   (INTEGER_VALUE_FOR_AV_ADDRESS_W),
		.AV_DATA_W                      (INTEGER_VALUE_FOR_AV_DATA_W),
		.UAV_DATA_W                     (INTEGER_VALUE_FOR_UAV_DATA_W),
		.AV_BURSTCOUNT_W                (INTEGER_VALUE_FOR_AV_BURSTCOUNT_W),
		.AV_BYTEENABLE_W                (INTEGER_VALUE_FOR_AV_BYTEENABLE_W),
		.UAV_BYTEENABLE_W               (INTEGER_VALUE_FOR_UAV_BYTEENABLE_W),
		.UAV_ADDRESS_W                  (INTEGER_VALUE_FOR_UAV_ADDRESS_W),
		.UAV_BURSTCOUNT_W               (INTEGER_VALUE_FOR_UAV_BURSTCOUNT_W),
		.AV_READLATENCY                 (INTEGER_VALUE_FOR_AV_READLATENCY),
		.USE_READDATAVALID              (INTEGER_VALUE_FOR_USE_READDATAVALID),
		.USE_WAITREQUEST                (INTEGER_VALUE_FOR_USE_WAITREQUEST),
		.USE_UAV_CLKEN                  (INTEGER_VALUE_FOR_USE_UAV_CLKEN),
		.USE_READRESPONSE               (INTEGER_VALUE_FOR_USE_READRESPONSE),
		.USE_WRITERESPONSE              (INTEGER_VALUE_FOR_USE_WRITERESPONSE),
		.AV_SYMBOLS_PER_WORD            (INTEGER_VALUE_FOR_AV_SYMBOLS_PER_WORD),
		.AV_ADDRESS_SYMBOLS             (INTEGER_VALUE_FOR_AV_ADDRESS_SYMBOLS),
		.AV_BURSTCOUNT_SYMBOLS          (INTEGER_VALUE_FOR_AV_BURSTCOUNT_SYMBOLS),
		.AV_CONSTANT_BURST_BEHAVIOR     (INTEGER_VALUE_FOR_AV_CONSTANT_BURST_BEHAVIOR),
		.UAV_CONSTANT_BURST_BEHAVIOR    (INTEGER_VALUE_FOR_UAV_CONSTANT_BURST_BEHAVIOR),
		.AV_REQUIRE_UNALIGNED_ADDRESSES (INTEGER_VALUE_FOR_AV_REQUIRE_UNALIGNED_ADDRESSES),
		.CHIPSELECT_THROUGH_READLATENCY (INTEGER_VALUE_FOR_CHIPSELECT_THROUGH_READLATENCY),
		.AV_READ_WAIT_CYCLES            (INTEGER_VALUE_FOR_AV_READ_WAIT_CYCLES),
		.AV_WRITE_WAIT_CYCLES           (INTEGER_VALUE_FOR_AV_WRITE_WAIT_CYCLES),
		.AV_SETUP_WAIT_CYCLES           (INTEGER_VALUE_FOR_AV_SETUP_WAIT_CYCLES),
		.AV_DATA_HOLD_CYCLES            (INTEGER_VALUE_FOR_AV_DATA_HOLD_CYCLES),
		.WAITREQUEST_ALLOWANCE          (INTEGER_VALUE_FOR_WAITREQUEST_ALLOWANCE),
		.SYNC_RESET                     (INTEGER_VALUE_FOR_SYNC_RESET)
	) u0 (
		.clk               (_connected_to_clk_),               //   input,   width = 1,                      clk.clk
		.reset             (_connected_to_reset_),             //   input,   width = 1,                    reset.reset
		.uav_address       (_connected_to_uav_address_),       //   input,  width = 14, avalon_universal_slave_0.address
		.uav_burstcount    (_connected_to_uav_burstcount_),    //   input,   width = 4,                         .burstcount
		.uav_read          (_connected_to_uav_read_),          //   input,   width = 1,                         .read
		.uav_write         (_connected_to_uav_write_),         //   input,   width = 1,                         .write
		.uav_waitrequest   (_connected_to_uav_waitrequest_),   //  output,   width = 1,                         .waitrequest
		.uav_readdatavalid (_connected_to_uav_readdatavalid_), //  output,   width = 1,                         .readdatavalid
		.uav_byteenable    (_connected_to_uav_byteenable_),    //   input,   width = 4,                         .byteenable
		.uav_readdata      (_connected_to_uav_readdata_),      //  output,  width = 32,                         .readdata
		.uav_writedata     (_connected_to_uav_writedata_),     //   input,  width = 32,                         .writedata
		.uav_lock          (_connected_to_uav_lock_),          //   input,   width = 1,                         .lock
		.uav_debugaccess   (_connected_to_uav_debugaccess_),   //   input,   width = 1,                         .debugaccess
		.av_address        (_connected_to_av_address_),        //  output,  width = 12,      avalon_anti_slave_0.address
		.av_write          (_connected_to_av_write_),          //  output,   width = 1,                         .write
		.av_read           (_connected_to_av_read_),           //  output,   width = 1,                         .read
		.av_readdata       (_connected_to_av_readdata_),       //   input,  width = 32,                         .readdata
		.av_writedata      (_connected_to_av_writedata_),      //  output,  width = 32,                         .writedata
		.av_waitrequest    (_connected_to_av_waitrequest_)     //   input,   width = 1,                         .waitrequest
	);

