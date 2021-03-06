// sc_fifo.v

// Generated using ACDS version 17.0 290

`timescale 1 ps / 1 ps
module sc_fifo (
		output wire        rx_sc_fifo_almost_empty_data, // rx_sc_fifo_almost_empty.data
		output wire        rx_sc_fifo_almost_full_data,  //  rx_sc_fifo_almost_full.data
		input  wire        rx_sc_fifo_clk_clk,           //          rx_sc_fifo_clk.clk
		input  wire        rx_sc_fifo_clk_reset_reset,   //    rx_sc_fifo_clk_reset.reset
		input  wire [2:0]  rx_sc_fifo_csr_address,       //          rx_sc_fifo_csr.address
		input  wire        rx_sc_fifo_csr_read,          //                        .read
		input  wire        rx_sc_fifo_csr_write,         //                        .write
		output wire [31:0] rx_sc_fifo_csr_readdata,      //                        .readdata
		input  wire [31:0] rx_sc_fifo_csr_writedata,     //                        .writedata
		input  wire [63:0] rx_sc_fifo_in_data,           //           rx_sc_fifo_in.data
		input  wire        rx_sc_fifo_in_valid,          //                        .valid
		output wire        rx_sc_fifo_in_ready,          //                        .ready
		input  wire        rx_sc_fifo_in_startofpacket,  //                        .startofpacket
		input  wire        rx_sc_fifo_in_endofpacket,    //                        .endofpacket
		input  wire [2:0]  rx_sc_fifo_in_empty,          //                        .empty
		input  wire [5:0]  rx_sc_fifo_in_error,          //                        .error
		output wire [63:0] rx_sc_fifo_out_data,          //          rx_sc_fifo_out.data
		output wire        rx_sc_fifo_out_valid,         //                        .valid
		input  wire        rx_sc_fifo_out_ready,         //                        .ready
		output wire        rx_sc_fifo_out_startofpacket, //                        .startofpacket
		output wire        rx_sc_fifo_out_endofpacket,   //                        .endofpacket
		output wire [2:0]  rx_sc_fifo_out_empty,         //                        .empty
		output wire [5:0]  rx_sc_fifo_out_error,         //                        .error
		input  wire        tx_sc_fifo_clk_clk,           //          tx_sc_fifo_clk.clk
		input  wire        tx_sc_fifo_clk_reset_reset,   //    tx_sc_fifo_clk_reset.reset
		input  wire [2:0]  tx_sc_fifo_csr_address,       //          tx_sc_fifo_csr.address
		input  wire        tx_sc_fifo_csr_read,          //                        .read
		input  wire        tx_sc_fifo_csr_write,         //                        .write
		output wire [31:0] tx_sc_fifo_csr_readdata,      //                        .readdata
		input  wire [31:0] tx_sc_fifo_csr_writedata,     //                        .writedata
		input  wire [63:0] tx_sc_fifo_in_data,           //           tx_sc_fifo_in.data
		input  wire        tx_sc_fifo_in_valid,          //                        .valid
		output wire        tx_sc_fifo_in_ready,          //                        .ready
		input  wire        tx_sc_fifo_in_startofpacket,  //                        .startofpacket
		input  wire        tx_sc_fifo_in_endofpacket,    //                        .endofpacket
		input  wire [2:0]  tx_sc_fifo_in_empty,          //                        .empty
		input  wire [0:0]  tx_sc_fifo_in_error,          //                        .error
		output wire [63:0] tx_sc_fifo_out_data,          //          tx_sc_fifo_out.data
		output wire        tx_sc_fifo_out_valid,         //                        .valid
		input  wire        tx_sc_fifo_out_ready,         //                        .ready
		output wire        tx_sc_fifo_out_startofpacket, //                        .startofpacket
		output wire        tx_sc_fifo_out_endofpacket,   //                        .endofpacket
		output wire [2:0]  tx_sc_fifo_out_empty,         //                        .empty
		output wire [0:0]  tx_sc_fifo_out_error          //                        .error
	);

	altera_avalon_sc_fifo #(
		.SYMBOLS_PER_BEAT    (8),
		.BITS_PER_SYMBOL     (8),
		.FIFO_DEPTH          (1024),
		.CHANNEL_WIDTH       (0),
		.ERROR_WIDTH         (6),
		.USE_PACKETS         (1),
		.USE_FILL_LEVEL      (1),
		.EMPTY_LATENCY       (3),
		.USE_MEMORY_BLOCKS   (1),
		.USE_STORE_FORWARD   (1),
		.USE_ALMOST_FULL_IF  (1),
		.USE_ALMOST_EMPTY_IF (1)
	) rx_sc_fifo (
		.clk               (rx_sc_fifo_clk_clk),           //          clk.clk
		.reset             (rx_sc_fifo_clk_reset_reset),   //    clk_reset.reset
		.csr_address       (rx_sc_fifo_csr_address),       //          csr.address
		.csr_read          (rx_sc_fifo_csr_read),          //             .read
		.csr_write         (rx_sc_fifo_csr_write),         //             .write
		.csr_readdata      (rx_sc_fifo_csr_readdata),      //             .readdata
		.csr_writedata     (rx_sc_fifo_csr_writedata),     //             .writedata
		.almost_full_data  (rx_sc_fifo_almost_full_data),  //  almost_full.data
		.almost_empty_data (rx_sc_fifo_almost_empty_data), // almost_empty.data
		.in_data           (rx_sc_fifo_in_data),           //           in.data
		.in_valid          (rx_sc_fifo_in_valid),          //             .valid
		.in_ready          (rx_sc_fifo_in_ready),          //             .ready
		.in_startofpacket  (rx_sc_fifo_in_startofpacket),  //             .startofpacket
		.in_endofpacket    (rx_sc_fifo_in_endofpacket),    //             .endofpacket
		.in_empty          (rx_sc_fifo_in_empty),          //             .empty
		.in_error          (rx_sc_fifo_in_error),          //             .error
		.out_data          (rx_sc_fifo_out_data),          //          out.data
		.out_valid         (rx_sc_fifo_out_valid),         //             .valid
		.out_ready         (rx_sc_fifo_out_ready),         //             .ready
		.out_startofpacket (rx_sc_fifo_out_startofpacket), //             .startofpacket
		.out_endofpacket   (rx_sc_fifo_out_endofpacket),   //             .endofpacket
		.out_empty         (rx_sc_fifo_out_empty),         //             .empty
		.out_error         (rx_sc_fifo_out_error),         //             .error
		.in_channel        (1'b0),                         //  (terminated)
		.out_channel       ()                              //  (terminated)
	);

	altera_avalon_sc_fifo #(
		.SYMBOLS_PER_BEAT    (8),
		.BITS_PER_SYMBOL     (8),
		.FIFO_DEPTH          (1024),
		.CHANNEL_WIDTH       (0),
		.ERROR_WIDTH         (1),
		.USE_PACKETS         (1),
		.USE_FILL_LEVEL      (1),
		.EMPTY_LATENCY       (3),
		.USE_MEMORY_BLOCKS   (1),
		.USE_STORE_FORWARD   (1),
		.USE_ALMOST_FULL_IF  (0),
		.USE_ALMOST_EMPTY_IF (0)
	) tx_sc_fifo (
		.clk               (tx_sc_fifo_clk_clk),           //       clk.clk
		.reset             (tx_sc_fifo_clk_reset_reset),   // clk_reset.reset
		.csr_address       (tx_sc_fifo_csr_address),       //       csr.address
		.csr_read          (tx_sc_fifo_csr_read),          //          .read
		.csr_write         (tx_sc_fifo_csr_write),         //          .write
		.csr_readdata      (tx_sc_fifo_csr_readdata),      //          .readdata
		.csr_writedata     (tx_sc_fifo_csr_writedata),     //          .writedata
		.in_data           (tx_sc_fifo_in_data),           //        in.data
		.in_valid          (tx_sc_fifo_in_valid),          //          .valid
		.in_ready          (tx_sc_fifo_in_ready),          //          .ready
		.in_startofpacket  (tx_sc_fifo_in_startofpacket),  //          .startofpacket
		.in_endofpacket    (tx_sc_fifo_in_endofpacket),    //          .endofpacket
		.in_empty          (tx_sc_fifo_in_empty),          //          .empty
		.in_error          (tx_sc_fifo_in_error),          //          .error
		.out_data          (tx_sc_fifo_out_data),          //       out.data
		.out_valid         (tx_sc_fifo_out_valid),         //          .valid
		.out_ready         (tx_sc_fifo_out_ready),         //          .ready
		.out_startofpacket (tx_sc_fifo_out_startofpacket), //          .startofpacket
		.out_endofpacket   (tx_sc_fifo_out_endofpacket),   //          .endofpacket
		.out_empty         (tx_sc_fifo_out_empty),         //          .empty
		.out_error         (tx_sc_fifo_out_error),         //          .error
		.almost_full_data  (),                             // (terminated)
		.almost_empty_data (),                             // (terminated)
		.in_channel        (1'b0),                         // (terminated)
		.out_channel       ()                              // (terminated)
	);

endmodule
