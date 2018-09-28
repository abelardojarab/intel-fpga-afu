module sc_fifo_rx_sc_fifo #(
		parameter SYMBOLS_PER_BEAT    = 8,
		parameter BITS_PER_SYMBOL     = 8,
		parameter FIFO_DEPTH          = 1024,
		parameter CHANNEL_WIDTH       = 0,
		parameter ERROR_WIDTH         = 6,
		parameter USE_PACKETS         = 1,
		parameter USE_FILL_LEVEL      = 1,
		parameter EMPTY_LATENCY       = 3,
		parameter USE_MEMORY_BLOCKS   = 1,
		parameter USE_STORE_FORWARD   = 1,
		parameter USE_ALMOST_FULL_IF  = 1,
		parameter USE_ALMOST_EMPTY_IF = 1
	) (
		input  wire        clk,               //          clk.clk
		input  wire        reset,             //    clk_reset.reset
		input  wire [2:0]  csr_address,       //          csr.address
		input  wire        csr_read,          //             .read
		input  wire        csr_write,         //             .write
		output wire [31:0] csr_readdata,      //             .readdata
		input  wire [31:0] csr_writedata,     //             .writedata
		output wire        almost_full_data,  //  almost_full.data
		output wire        almost_empty_data, // almost_empty.data
		input  wire [63:0] in_data,           //           in.data
		input  wire        in_valid,          //             .valid
		output wire        in_ready,          //             .ready
		input  wire        in_startofpacket,  //             .startofpacket
		input  wire        in_endofpacket,    //             .endofpacket
		input  wire [2:0]  in_empty,          //             .empty
		input  wire [5:0]  in_error,          //             .error
		output wire [63:0] out_data,          //          out.data
		output wire        out_valid,         //             .valid
		input  wire        out_ready,         //             .ready
		output wire        out_startofpacket, //             .startofpacket
		output wire        out_endofpacket,   //             .endofpacket
		output wire [2:0]  out_empty,         //             .empty
		output wire [5:0]  out_error          //             .error
	);
endmodule

