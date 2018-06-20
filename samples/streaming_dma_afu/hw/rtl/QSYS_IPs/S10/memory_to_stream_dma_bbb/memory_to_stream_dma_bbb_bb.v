module memory_to_stream_dma_bbb (
		input  wire         clk_clk,                     //           clk.clk
		output wire         csr_waitrequest,             //           csr.waitrequest
		output wire [63:0]  csr_readdata,                //              .readdata
		output wire         csr_readdatavalid,           //              .readdatavalid
		input  wire [0:0]   csr_burstcount,              //              .burstcount
		input  wire [63:0]  csr_writedata,               //              .writedata
		input  wire [7:0]   csr_address,                 //              .address
		input  wire         csr_write,                   //              .write
		input  wire         csr_read,                    //              .read
		input  wire [7:0]   csr_byteenable,              //              .byteenable
		input  wire         csr_debugaccess,             //              .debugaccess
		input  wire         host_read_waitrequest,       //     host_read.waitrequest
		input  wire [511:0] host_read_readdata,          //              .readdata
		input  wire         host_read_readdatavalid,     //              .readdatavalid
		output wire [2:0]   host_read_burstcount,        //              .burstcount
		output wire [511:0] host_read_writedata,         //              .writedata
		output wire [47:0]  host_read_address,           //              .address
		output wire         host_read_write,             //              .write
		output wire         host_read_read,              //              .read
		output wire [63:0]  host_read_byteenable,        //              .byteenable
		output wire         host_read_debugaccess,       //              .debugaccess
		output wire         m2s_irq_irq,                 //       m2s_irq.irq
		output wire [511:0] m2s_st_source_data,          // m2s_st_source.data
		output wire         m2s_st_source_valid,         //              .valid
		input  wire         m2s_st_source_ready,         //              .ready
		output wire         m2s_st_source_startofpacket, //              .startofpacket
		output wire         m2s_st_source_endofpacket,   //              .endofpacket
		output wire [5:0]   m2s_st_source_empty,         //              .empty
		input  wire         mem_read_waitrequest,        //      mem_read.waitrequest
		input  wire [511:0] mem_read_readdata,           //              .readdata
		input  wire         mem_read_readdatavalid,      //              .readdatavalid
		output wire [2:0]   mem_read_burstcount,         //              .burstcount
		output wire [511:0] mem_read_writedata,          //              .writedata
		output wire [47:0]  mem_read_address,            //              .address
		output wire         mem_read_write,              //              .write
		output wire         mem_read_read,               //              .read
		output wire [63:0]  mem_read_byteenable,         //              .byteenable
		output wire         mem_read_debugaccess,        //              .debugaccess
		input  wire         reset_reset                  //         reset.reset
	);
endmodule

