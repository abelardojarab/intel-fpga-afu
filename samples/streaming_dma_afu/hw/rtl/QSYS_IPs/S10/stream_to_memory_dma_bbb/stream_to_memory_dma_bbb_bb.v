module stream_to_memory_dma_bbb (
		input  wire         clk_clk,                       //         clk.clk
		output wire         csr_waitrequest,               //         csr.waitrequest
		output wire [63:0]  csr_readdata,                  //            .readdata
		output wire         csr_readdatavalid,             //            .readdatavalid
		input  wire [0:0]   csr_burstcount,                //            .burstcount
		input  wire [63:0]  csr_writedata,                 //            .writedata
		input  wire [7:0]   csr_address,                   //            .address
		input  wire         csr_write,                     //            .write
		input  wire         csr_read,                      //            .read
		input  wire [7:0]   csr_byteenable,                //            .byteenable
		input  wire         csr_debugaccess,               //            .debugaccess
		output wire [47:0]  host_write_address,            //  host_write.address
		output wire [511:0] host_write_writedata,          //            .writedata
		output wire         host_write_write,              //            .write
		output wire [63:0]  host_write_byteenable,         //            .byteenable
		output wire [2:0]   host_write_burstcount,         //            .burstcount
		input  wire [1:0]   host_write_response,           //            .response
		input  wire         host_write_waitrequest,        //            .waitrequest
		input  wire         host_write_writeresponsevalid, //            .writeresponsevalid
		input  wire         mem_write_waitrequest,         //   mem_write.waitrequest
		input  wire [511:0] mem_write_readdata,            //            .readdata
		input  wire         mem_write_readdatavalid,       //            .readdatavalid
		output wire [2:0]   mem_write_burstcount,          //            .burstcount
		output wire [511:0] mem_write_writedata,           //            .writedata
		output wire [47:0]  mem_write_address,             //            .address
		output wire         mem_write_write,               //            .write
		output wire         mem_write_read,                //            .read
		output wire [63:0]  mem_write_byteenable,          //            .byteenable
		output wire         mem_write_debugaccess,         //            .debugaccess
		input  wire         reset_reset,                   //       reset.reset
		output wire         s2m_irq_irq,                   //     s2m_irq.irq
		input  wire [511:0] s2m_st_sink_data,              // s2m_st_sink.data
		input  wire [5:0]   s2m_st_sink_empty,             //            .empty
		input  wire         s2m_st_sink_endofpacket,       //            .endofpacket
		output wire         s2m_st_sink_ready,             //            .ready
		input  wire         s2m_st_sink_startofpacket,     //            .startofpacket
		input  wire         s2m_st_sink_valid              //            .valid
	);
endmodule

