// sc_fifo_tx_sc_fifo.v

// Generated using ACDS version 18.1 221

`timescale 1 ps / 1 ps
module sc_fifo_tx_sc_fifo #(
		parameter SYMBOLS_PER_BEAT    = 8,
		parameter BITS_PER_SYMBOL     = 8,
		parameter FIFO_DEPTH          = 1024,
		parameter CHANNEL_WIDTH       = 0,
		parameter ERROR_WIDTH         = 1,
		parameter USE_PACKETS         = 1,
		parameter USE_FILL_LEVEL      = 1,
		parameter EMPTY_LATENCY       = 3,
		parameter USE_MEMORY_BLOCKS   = 1,
		parameter USE_STORE_FORWARD   = 1,
		parameter USE_ALMOST_FULL_IF  = 0,
		parameter USE_ALMOST_EMPTY_IF = 0
	) (
		input  wire        clk,               //       clk.clk
		input  wire        reset,             // clk_reset.reset
		input  wire [2:0]  csr_address,       //       csr.address
		input  wire        csr_read,          //          .read
		input  wire        csr_write,         //          .write
		output wire [31:0] csr_readdata,      //          .readdata
		input  wire [31:0] csr_writedata,     //          .writedata
		input  wire [63:0] in_data,           //        in.data
		input  wire        in_valid,          //          .valid
		output wire        in_ready,          //          .ready
		input  wire        in_startofpacket,  //          .startofpacket
		input  wire        in_endofpacket,    //          .endofpacket
		input  wire [2:0]  in_empty,          //          .empty
		input  wire [0:0]  in_error,          //          .error
		output wire [63:0] out_data,          //       out.data
		output wire        out_valid,         //          .valid
		input  wire        out_ready,         //          .ready
		output wire        out_startofpacket, //          .startofpacket
		output wire        out_endofpacket,   //          .endofpacket
		output wire [2:0]  out_empty,         //          .empty
		output wire [0:0]  out_error          //          .error
	);

	sc_fifo_tx_sc_fifo_altera_avalon_sc_fifo_181_hseo73i #(
		.SYMBOLS_PER_BEAT    (SYMBOLS_PER_BEAT),
		.BITS_PER_SYMBOL     (BITS_PER_SYMBOL),
		.FIFO_DEPTH          (FIFO_DEPTH),
		.CHANNEL_WIDTH       (CHANNEL_WIDTH),
		.ERROR_WIDTH         (ERROR_WIDTH),
		.USE_PACKETS         (USE_PACKETS),
		.USE_FILL_LEVEL      (USE_FILL_LEVEL),
		.EMPTY_LATENCY       (EMPTY_LATENCY),
		.USE_MEMORY_BLOCKS   (USE_MEMORY_BLOCKS),
		.USE_STORE_FORWARD   (USE_STORE_FORWARD),
		.USE_ALMOST_FULL_IF  (USE_ALMOST_FULL_IF),
		.USE_ALMOST_EMPTY_IF (USE_ALMOST_EMPTY_IF)
	) tx_sc_fifo (
		.clk               (clk),               //   input,   width = 1,       clk.clk
		.reset             (reset),             //   input,   width = 1, clk_reset.reset
		.csr_address       (csr_address),       //   input,   width = 3,       csr.address
		.csr_read          (csr_read),          //   input,   width = 1,          .read
		.csr_write         (csr_write),         //   input,   width = 1,          .write
		.csr_readdata      (csr_readdata),      //  output,  width = 32,          .readdata
		.csr_writedata     (csr_writedata),     //   input,  width = 32,          .writedata
		.in_data           (in_data),           //   input,  width = 64,        in.data
		.in_valid          (in_valid),          //   input,   width = 1,          .valid
		.in_ready          (in_ready),          //  output,   width = 1,          .ready
		.in_startofpacket  (in_startofpacket),  //   input,   width = 1,          .startofpacket
		.in_endofpacket    (in_endofpacket),    //   input,   width = 1,          .endofpacket
		.in_empty          (in_empty),          //   input,   width = 3,          .empty
		.in_error          (in_error),          //   input,   width = 1,          .error
		.out_data          (out_data),          //  output,  width = 64,       out.data
		.out_valid         (out_valid),         //  output,   width = 1,          .valid
		.out_ready         (out_ready),         //   input,   width = 1,          .ready
		.out_startofpacket (out_startofpacket), //  output,   width = 1,          .startofpacket
		.out_endofpacket   (out_endofpacket),   //  output,   width = 1,          .endofpacket
		.out_empty         (out_empty),         //  output,   width = 3,          .empty
		.out_error         (out_error),         //  output,   width = 1,          .error
		.almost_full_data  (),                  // (terminated),                        
		.almost_empty_data (),                  // (terminated),                        
		.in_channel        (1'b0),              // (terminated),                        
		.out_channel       ()                   // (terminated),                        
	);

endmodule
