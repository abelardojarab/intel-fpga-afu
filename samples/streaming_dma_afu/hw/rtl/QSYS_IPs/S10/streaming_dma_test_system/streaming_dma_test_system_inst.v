	streaming_dma_test_system u0 (
		.dma_clock_clk                 (_connected_to_dma_clock_clk_),                 //   input,    width = 1,    dma_clock.clk
		.emif_a_avmm_waitrequest       (_connected_to_emif_a_avmm_waitrequest_),       //   input,    width = 1,  emif_a_avmm.waitrequest
		.emif_a_avmm_readdata          (_connected_to_emif_a_avmm_readdata_),          //   input,  width = 512,             .readdata
		.emif_a_avmm_readdatavalid     (_connected_to_emif_a_avmm_readdatavalid_),     //   input,    width = 1,             .readdatavalid
		.emif_a_avmm_burstcount        (_connected_to_emif_a_avmm_burstcount_),        //  output,    width = 3,             .burstcount
		.emif_a_avmm_writedata         (_connected_to_emif_a_avmm_writedata_),         //  output,  width = 512,             .writedata
		.emif_a_avmm_address           (_connected_to_emif_a_avmm_address_),           //  output,   width = 32,             .address
		.emif_a_avmm_write             (_connected_to_emif_a_avmm_write_),             //  output,    width = 1,             .write
		.emif_a_avmm_read              (_connected_to_emif_a_avmm_read_),              //  output,    width = 1,             .read
		.emif_a_avmm_byteenable        (_connected_to_emif_a_avmm_byteenable_),        //  output,   width = 64,             .byteenable
		.emif_a_avmm_debugaccess       (_connected_to_emif_a_avmm_debugaccess_),       //  output,    width = 1,             .debugaccess
		.emif_a_clock_clk              (_connected_to_emif_a_clock_clk_),              //   input,    width = 1, emif_a_clock.clk
		.emif_b_avmm_waitrequest       (_connected_to_emif_b_avmm_waitrequest_),       //   input,    width = 1,  emif_b_avmm.waitrequest
		.emif_b_avmm_readdata          (_connected_to_emif_b_avmm_readdata_),          //   input,  width = 512,             .readdata
		.emif_b_avmm_readdatavalid     (_connected_to_emif_b_avmm_readdatavalid_),     //   input,    width = 1,             .readdatavalid
		.emif_b_avmm_burstcount        (_connected_to_emif_b_avmm_burstcount_),        //  output,    width = 3,             .burstcount
		.emif_b_avmm_writedata         (_connected_to_emif_b_avmm_writedata_),         //  output,  width = 512,             .writedata
		.emif_b_avmm_address           (_connected_to_emif_b_avmm_address_),           //  output,   width = 32,             .address
		.emif_b_avmm_write             (_connected_to_emif_b_avmm_write_),             //  output,    width = 1,             .write
		.emif_b_avmm_read              (_connected_to_emif_b_avmm_read_),              //  output,    width = 1,             .read
		.emif_b_avmm_byteenable        (_connected_to_emif_b_avmm_byteenable_),        //  output,   width = 64,             .byteenable
		.emif_b_avmm_debugaccess       (_connected_to_emif_b_avmm_debugaccess_),       //  output,    width = 1,             .debugaccess
		.emif_b_clock_clk              (_connected_to_emif_b_clock_clk_),              //   input,    width = 1, emif_b_clock.clk
		.host_read_waitrequest         (_connected_to_host_read_waitrequest_),         //   input,    width = 1,    host_read.waitrequest
		.host_read_readdata            (_connected_to_host_read_readdata_),            //   input,  width = 512,             .readdata
		.host_read_readdatavalid       (_connected_to_host_read_readdatavalid_),       //   input,    width = 1,             .readdatavalid
		.host_read_burstcount          (_connected_to_host_read_burstcount_),          //  output,    width = 3,             .burstcount
		.host_read_writedata           (_connected_to_host_read_writedata_),           //  output,  width = 512,             .writedata
		.host_read_address             (_connected_to_host_read_address_),             //  output,   width = 48,             .address
		.host_read_write               (_connected_to_host_read_write_),               //  output,    width = 1,             .write
		.host_read_read                (_connected_to_host_read_read_),                //  output,    width = 1,             .read
		.host_read_byteenable          (_connected_to_host_read_byteenable_),          //  output,   width = 64,             .byteenable
		.host_read_debugaccess         (_connected_to_host_read_debugaccess_),         //  output,    width = 1,             .debugaccess
		.host_write_address            (_connected_to_host_write_address_),            //  output,   width = 48,   host_write.address
		.host_write_writedata          (_connected_to_host_write_writedata_),          //  output,  width = 512,             .writedata
		.host_write_write              (_connected_to_host_write_write_),              //  output,    width = 1,             .write
		.host_write_byteenable         (_connected_to_host_write_byteenable_),         //  output,   width = 64,             .byteenable
		.host_write_burstcount         (_connected_to_host_write_burstcount_),         //  output,    width = 3,             .burstcount
		.host_write_response           (_connected_to_host_write_response_),           //   input,    width = 2,             .response
		.host_write_waitrequest        (_connected_to_host_write_waitrequest_),        //   input,    width = 1,             .waitrequest
		.host_write_writeresponsevalid (_connected_to_host_write_writeresponsevalid_), //   input,    width = 1,             .writeresponsevalid
		.m2s_irq_irq                   (_connected_to_m2s_irq_irq_),                   //  output,    width = 1,      m2s_irq.irq
		.mmio_avmm_waitrequest         (_connected_to_mmio_avmm_waitrequest_),         //  output,    width = 1,    mmio_avmm.waitrequest
		.mmio_avmm_readdata            (_connected_to_mmio_avmm_readdata_),            //  output,   width = 64,             .readdata
		.mmio_avmm_readdatavalid       (_connected_to_mmio_avmm_readdatavalid_),       //  output,    width = 1,             .readdatavalid
		.mmio_avmm_burstcount          (_connected_to_mmio_avmm_burstcount_),          //   input,    width = 1,             .burstcount
		.mmio_avmm_writedata           (_connected_to_mmio_avmm_writedata_),           //   input,   width = 64,             .writedata
		.mmio_avmm_address             (_connected_to_mmio_avmm_address_),             //   input,   width = 18,             .address
		.mmio_avmm_write               (_connected_to_mmio_avmm_write_),               //   input,    width = 1,             .write
		.mmio_avmm_read                (_connected_to_mmio_avmm_read_),                //   input,    width = 1,             .read
		.mmio_avmm_byteenable          (_connected_to_mmio_avmm_byteenable_),          //   input,    width = 8,             .byteenable
		.mmio_avmm_debugaccess         (_connected_to_mmio_avmm_debugaccess_),         //   input,    width = 1,             .debugaccess
		.reset_reset                   (_connected_to_reset_reset_),                   //   input,    width = 1,        reset.reset
		.s2m_irq_irq                   (_connected_to_s2m_irq_irq_)                    //  output,    width = 1,      s2m_irq.irq
	);
