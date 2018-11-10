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
endmodule

