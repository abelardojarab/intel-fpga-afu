module dma_test_system (
		output wire         ccip_avmm_mmio_waitrequest,           //         ccip_avmm_mmio.waitrequest
		output wire [63:0]  ccip_avmm_mmio_readdata,              //                       .readdata
		output wire         ccip_avmm_mmio_readdatavalid,         //                       .readdatavalid
		input  wire [0:0]   ccip_avmm_mmio_burstcount,            //                       .burstcount
		input  wire [63:0]  ccip_avmm_mmio_writedata,             //                       .writedata
		input  wire [17:0]  ccip_avmm_mmio_address,               //                       .address
		input  wire         ccip_avmm_mmio_write,                 //                       .write
		input  wire         ccip_avmm_mmio_read,                  //                       .read
		input  wire [7:0]   ccip_avmm_mmio_byteenable,            //                       .byteenable
		input  wire         ccip_avmm_mmio_debugaccess,           //                       .debugaccess
		input  wire         ccip_avmm_requestor_rd_waitrequest,   // ccip_avmm_requestor_rd.waitrequest
		input  wire [511:0] ccip_avmm_requestor_rd_readdata,      //                       .readdata
		input  wire         ccip_avmm_requestor_rd_readdatavalid, //                       .readdatavalid
		output wire [2:0]   ccip_avmm_requestor_rd_burstcount,    //                       .burstcount
		output wire [511:0] ccip_avmm_requestor_rd_writedata,     //                       .writedata
		output wire [47:0]  ccip_avmm_requestor_rd_address,       //                       .address
		output wire         ccip_avmm_requestor_rd_write,         //                       .write
		output wire         ccip_avmm_requestor_rd_read,          //                       .read
		output wire [63:0]  ccip_avmm_requestor_rd_byteenable,    //                       .byteenable
		output wire         ccip_avmm_requestor_rd_debugaccess,   //                       .debugaccess
		input  wire         ccip_avmm_requestor_wr_waitrequest,   // ccip_avmm_requestor_wr.waitrequest
		input  wire [511:0] ccip_avmm_requestor_wr_readdata,      //                       .readdata
		input  wire         ccip_avmm_requestor_wr_readdatavalid, //                       .readdatavalid
		output wire [2:0]   ccip_avmm_requestor_wr_burstcount,    //                       .burstcount
		output wire [511:0] ccip_avmm_requestor_wr_writedata,     //                       .writedata
		output wire [48:0]  ccip_avmm_requestor_wr_address,       //                       .address
		output wire         ccip_avmm_requestor_wr_write,         //                       .write
		output wire         ccip_avmm_requestor_wr_read,          //                       .read
		output wire [63:0]  ccip_avmm_requestor_wr_byteenable,    //                       .byteenable
		output wire         ccip_avmm_requestor_wr_debugaccess,   //                       .debugaccess
		input  wire         ddr4a_clk_clk,                        //              ddr4a_clk.clk
		input  wire         ddr4a_master_waitrequest,             //           ddr4a_master.waitrequest
		input  wire [511:0] ddr4a_master_readdata,                //                       .readdata
		input  wire         ddr4a_master_readdatavalid,           //                       .readdatavalid
		output wire [2:0]   ddr4a_master_burstcount,              //                       .burstcount
		output wire [511:0] ddr4a_master_writedata,               //                       .writedata
		output wire [31:0]  ddr4a_master_address,                 //                       .address
		output wire         ddr4a_master_write,                   //                       .write
		output wire         ddr4a_master_read,                    //                       .read
		output wire [63:0]  ddr4a_master_byteenable,              //                       .byteenable
		output wire         ddr4a_master_debugaccess,             //                       .debugaccess
		input  wire         ddr4b_clk_clk,                        //              ddr4b_clk.clk
		input  wire         ddr4b_master_waitrequest,             //           ddr4b_master.waitrequest
		input  wire [511:0] ddr4b_master_readdata,                //                       .readdata
		input  wire         ddr4b_master_readdatavalid,           //                       .readdatavalid
		output wire [2:0]   ddr4b_master_burstcount,              //                       .burstcount
		output wire [511:0] ddr4b_master_writedata,               //                       .writedata
		output wire [31:0]  ddr4b_master_address,                 //                       .address
		output wire         ddr4b_master_write,                   //                       .write
		output wire         ddr4b_master_read,                    //                       .read
		output wire [63:0]  ddr4b_master_byteenable,              //                       .byteenable
		output wire         ddr4b_master_debugaccess,             //                       .debugaccess
		input  wire         ddr4c_clk_clk,                        //              ddr4c_clk.clk
		input  wire         ddr4c_master_waitrequest,             //           ddr4c_master.waitrequest
		input  wire [511:0] ddr4c_master_readdata,                //                       .readdata
		input  wire         ddr4c_master_readdatavalid,           //                       .readdatavalid
		output wire [2:0]   ddr4c_master_burstcount,              //                       .burstcount
		output wire [511:0] ddr4c_master_writedata,               //                       .writedata
		output wire [31:0]  ddr4c_master_address,                 //                       .address
		output wire         ddr4c_master_write,                   //                       .write
		output wire         ddr4c_master_read,                    //                       .read
		output wire [63:0]  ddr4c_master_byteenable,              //                       .byteenable
		output wire         ddr4c_master_debugaccess,             //                       .debugaccess
		input  wire         ddr4d_clk_clk,                        //              ddr4d_clk.clk
		input  wire         ddr4d_master_waitrequest,             //           ddr4d_master.waitrequest
		input  wire [511:0] ddr4d_master_readdata,                //                       .readdata
		input  wire         ddr4d_master_readdatavalid,           //                       .readdatavalid
		output wire [2:0]   ddr4d_master_burstcount,              //                       .burstcount
		output wire [511:0] ddr4d_master_writedata,               //                       .writedata
		output wire [31:0]  ddr4d_master_address,                 //                       .address
		output wire         ddr4d_master_write,                   //                       .write
		output wire         ddr4d_master_read,                    //                       .read
		output wire [63:0]  ddr4d_master_byteenable,              //                       .byteenable
		output wire         ddr4d_master_debugaccess,             //                       .debugaccess
		output wire         dma_irq_irq,                          //                dma_irq.irq
		input  wire         host_clk_clk,                         //               host_clk.clk
		input  wire         reset_reset                           //                  reset.reset
	);
endmodule

