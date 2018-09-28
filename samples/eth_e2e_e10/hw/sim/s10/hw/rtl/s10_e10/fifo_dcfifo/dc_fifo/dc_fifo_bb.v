module dc_fifo (
		input  wire [31:0] dc_fifo_0_in_data,               //            dc_fifo_0_in.data
		input  wire        dc_fifo_0_in_valid,              //                        .valid
		output wire        dc_fifo_0_in_ready,              //                        .ready
		input  wire        dc_fifo_0_in_startofpacket,      //                        .startofpacket
		input  wire        dc_fifo_0_in_endofpacket,        //                        .endofpacket
		input  wire [1:0]  dc_fifo_0_in_empty,              //                        .empty
		input  wire [0:0]  dc_fifo_0_in_error,              //                        .error
		input  wire        dc_fifo_0_in_clk_clk,            //        dc_fifo_0_in_clk.clk
		input  wire        dc_fifo_0_in_clk_reset_reset_n,  //  dc_fifo_0_in_clk_reset.reset_n
		output wire [31:0] dc_fifo_0_out_data,              //           dc_fifo_0_out.data
		output wire        dc_fifo_0_out_valid,             //                        .valid
		input  wire        dc_fifo_0_out_ready,             //                        .ready
		output wire        dc_fifo_0_out_startofpacket,     //                        .startofpacket
		output wire        dc_fifo_0_out_endofpacket,       //                        .endofpacket
		output wire [1:0]  dc_fifo_0_out_empty,             //                        .empty
		output wire [0:0]  dc_fifo_0_out_error,             //                        .error
		input  wire        dc_fifo_0_out_clk_clk,           //       dc_fifo_0_out_clk.clk
		input  wire        dc_fifo_0_out_clk_reset_reset_n  // dc_fifo_0_out_clk_reset.reset_n
	);
endmodule

