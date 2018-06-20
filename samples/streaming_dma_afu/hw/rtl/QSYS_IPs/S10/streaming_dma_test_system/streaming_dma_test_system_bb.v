module streaming_dma_test_system (
		input  wire         dma_clock_clk,                 //    dma_clock.clk
		input  wire         emif_a_avmm_waitrequest,       //  emif_a_avmm.waitrequest
		input  wire [511:0] emif_a_avmm_readdata,          //             .readdata
		input  wire         emif_a_avmm_readdatavalid,     //             .readdatavalid
		output wire [2:0]   emif_a_avmm_burstcount,        //             .burstcount
		output wire [511:0] emif_a_avmm_writedata,         //             .writedata
		output wire [31:0]  emif_a_avmm_address,           //             .address
		output wire         emif_a_avmm_write,             //             .write
		output wire         emif_a_avmm_read,              //             .read
		output wire [63:0]  emif_a_avmm_byteenable,        //             .byteenable
		output wire         emif_a_avmm_debugaccess,       //             .debugaccess
		input  wire         emif_a_clock_clk,              // emif_a_clock.clk
		input  wire         emif_b_avmm_waitrequest,       //  emif_b_avmm.waitrequest
		input  wire [511:0] emif_b_avmm_readdata,          //             .readdata
		input  wire         emif_b_avmm_readdatavalid,     //             .readdatavalid
		output wire [2:0]   emif_b_avmm_burstcount,        //             .burstcount
		output wire [511:0] emif_b_avmm_writedata,         //             .writedata
		output wire [31:0]  emif_b_avmm_address,           //             .address
		output wire         emif_b_avmm_write,             //             .write
		output wire         emif_b_avmm_read,              //             .read
		output wire [63:0]  emif_b_avmm_byteenable,        //             .byteenable
		output wire         emif_b_avmm_debugaccess,       //             .debugaccess
		input  wire         emif_b_clock_clk,              // emif_b_clock.clk
		input  wire         host_read_waitrequest,         //    host_read.waitrequest
		input  wire [511:0] host_read_readdata,            //             .readdata
		input  wire         host_read_readdatavalid,       //             .readdatavalid
		output wire [2:0]   host_read_burstcount,          //             .burstcount
		output wire [511:0] host_read_writedata,           //             .writedata
		output wire [47:0]  host_read_address,             //             .address
		output wire         host_read_write,               //             .write
		output wire         host_read_read,                //             .read
		output wire [63:0]  host_read_byteenable,          //             .byteenable
		output wire         host_read_debugaccess,         //             .debugaccess
		output wire [47:0]  host_write_address,            //   host_write.address
		output wire [511:0] host_write_writedata,          //             .writedata
		output wire         host_write_write,              //             .write
		output wire [63:0]  host_write_byteenable,         //             .byteenable
		output wire [2:0]   host_write_burstcount,         //             .burstcount
		input  wire [1:0]   host_write_response,           //             .response
		input  wire         host_write_waitrequest,        //             .waitrequest
		input  wire         host_write_writeresponsevalid, //             .writeresponsevalid
		output wire         m2s_irq_irq,                   //      m2s_irq.irq
		output wire         mmio_avmm_waitrequest,         //    mmio_avmm.waitrequest
		output wire [63:0]  mmio_avmm_readdata,            //             .readdata
		output wire         mmio_avmm_readdatavalid,       //             .readdatavalid
		input  wire [0:0]   mmio_avmm_burstcount,          //             .burstcount
		input  wire [63:0]  mmio_avmm_writedata,           //             .writedata
		input  wire [17:0]  mmio_avmm_address,             //             .address
		input  wire         mmio_avmm_write,               //             .write
		input  wire         mmio_avmm_read,                //             .read
		input  wire [7:0]   mmio_avmm_byteenable,          //             .byteenable
		input  wire         mmio_avmm_debugaccess,         //             .debugaccess
		input  wire         reset_reset,                   //        reset.reset
		output wire         s2m_irq_irq                    //      s2m_irq.irq
	);
endmodule

