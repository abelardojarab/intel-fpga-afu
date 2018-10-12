// dc_fifo_0.v

// Generated using ACDS version 18.1 221

`timescale 1 ps / 1 ps
module dc_fifo_0 #(
		parameter SYMBOLS_PER_BEAT   = 4,
		parameter BITS_PER_SYMBOL    = 8,
		parameter FIFO_DEPTH         = 16,
		parameter CHANNEL_WIDTH      = 0,
		parameter ERROR_WIDTH        = 1,
		parameter USE_PACKETS        = 1,
		parameter USE_IN_FILL_LEVEL  = 0,
		parameter USE_OUT_FILL_LEVEL = 0,
		parameter WR_SYNC_DEPTH      = 3,
		parameter RD_SYNC_DEPTH      = 3
	) (
		input  wire        in_clk,            //        in_clk.clk
		input  wire        in_reset_n,        //  in_clk_reset.reset_n
		input  wire        out_clk,           //       out_clk.clk
		input  wire        out_reset_n,       // out_clk_reset.reset_n
		input  wire [31:0] in_data,           //            in.data
		input  wire        in_valid,          //              .valid
		output wire        in_ready,          //              .ready
		input  wire        in_startofpacket,  //              .startofpacket
		input  wire        in_endofpacket,    //              .endofpacket
		input  wire [1:0]  in_empty,          //              .empty
		input  wire [0:0]  in_error,          //              .error
		output wire [31:0] out_data,          //           out.data
		output wire        out_valid,         //              .valid
		input  wire        out_ready,         //              .ready
		output wire        out_startofpacket, //              .startofpacket
		output wire        out_endofpacket,   //              .endofpacket
		output wire [1:0]  out_empty,         //              .empty
		output wire [0:0]  out_error          //              .error
	);

	dc_fifo_0_altera_avalon_dc_fifo_181_vevbyjq #(
		.SYMBOLS_PER_BEAT   (SYMBOLS_PER_BEAT),
		.BITS_PER_SYMBOL    (BITS_PER_SYMBOL),
		.FIFO_DEPTH         (FIFO_DEPTH),
		.CHANNEL_WIDTH      (CHANNEL_WIDTH),
		.ERROR_WIDTH        (ERROR_WIDTH),
		.USE_PACKETS        (USE_PACKETS),
		.USE_IN_FILL_LEVEL  (USE_IN_FILL_LEVEL),
		.USE_OUT_FILL_LEVEL (USE_OUT_FILL_LEVEL),
		.WR_SYNC_DEPTH      (WR_SYNC_DEPTH),
		.RD_SYNC_DEPTH      (RD_SYNC_DEPTH),
		.SYNC_RESET         (0)
	) dc_fifo_0 (
		.in_clk            (in_clk),                               //   input,   width = 1,        in_clk.clk
		.in_reset_n        (in_reset_n),                           //   input,   width = 1,  in_clk_reset.reset_n
		.out_clk           (out_clk),                              //   input,   width = 1,       out_clk.clk
		.out_reset_n       (out_reset_n),                          //   input,   width = 1, out_clk_reset.reset_n
		.in_data           (in_data),                              //   input,  width = 32,            in.data
		.in_valid          (in_valid),                             //   input,   width = 1,              .valid
		.in_ready          (in_ready),                             //  output,   width = 1,              .ready
		.in_startofpacket  (in_startofpacket),                     //   input,   width = 1,              .startofpacket
		.in_endofpacket    (in_endofpacket),                       //   input,   width = 1,              .endofpacket
		.in_empty          (in_empty),                             //   input,   width = 2,              .empty
		.in_error          (in_error),                             //   input,   width = 1,              .error
		.out_data          (out_data),                             //  output,  width = 32,           out.data
		.out_valid         (out_valid),                            //  output,   width = 1,              .valid
		.out_ready         (out_ready),                            //   input,   width = 1,              .ready
		.out_startofpacket (out_startofpacket),                    //  output,   width = 1,              .startofpacket
		.out_endofpacket   (out_endofpacket),                      //  output,   width = 1,              .endofpacket
		.out_empty         (out_empty),                            //  output,   width = 2,              .empty
		.out_error         (out_error),                            //  output,   width = 1,              .error
		.in_csr_address    (1'b0),                                 // (terminated),                            
		.in_csr_read       (1'b0),                                 // (terminated),                            
		.in_csr_write      (1'b0),                                 // (terminated),                            
		.in_csr_readdata   (),                                     // (terminated),                            
		.in_csr_writedata  (32'b00000000000000000000000000000000), // (terminated),                            
		.out_csr_address   (1'b0),                                 // (terminated),                            
		.out_csr_read      (1'b0),                                 // (terminated),                            
		.out_csr_write     (1'b0),                                 // (terminated),                            
		.out_csr_readdata  (),                                     // (terminated),                            
		.out_csr_writedata (32'b00000000000000000000000000000000), // (terminated),                            
		.in_channel        (1'b0),                                 // (terminated),                            
		.out_channel       (),                                     // (terminated),                            
		.space_avail_data  ()                                      // (terminated),                            
	);

endmodule
