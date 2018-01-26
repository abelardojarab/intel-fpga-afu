// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// (C) 2001-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.

`timescale 1 ps / 1 ps
 module alt_aeu_40_pfc_tx_idp
     #(
      parameter DWIDTH = 256,
      parameter EMPTYBITS = 5,
      parameter PDEPTH = 2,
      parameter ODEPTH = 2,
      parameter FSMPDEPTH = 2,			// stages needed for fsm
      parameter VALID_BITS = 1,
      parameter SOP_BITS = 1,
      parameter EOP_BITS = 1,
      parameter ERROR_BITS = 1,
      parameter CWIDTH= VALID_BITS + SOP_BITS + EOP_BITS + EMPTYBITS + ERROR_BITS,
      parameter WIDTH = DWIDTH+CWIDTH
      )(
      input clk,
      input rst_n,

 //   input data-path interface
      output in_ready,
      input in_valid,
      input in_sop,
      input in_eop,
      input in_error,
      input [DWIDTH-1:0] in_data,
      input [EMPTYBITS-1:0] in_empty,

//    output data-path interface
      input out_ready,			// stall input pipe
      output out_valid,
      output out_sop,
      output out_eop,
      output out_error,
      output [DWIDTH-1:0] out_data,
      output [EMPTYBITS-1:0] out_empty,

      output reg pkt_end
     );

     wire [ODEPTH*WIDTH-1:0] pipe_data;

 // packing wires to move around the pipeline
     wire[WIDTH-1:0] in_bus, out_bus;
     assign in_bus = {in_error, in_valid, in_sop,in_eop, in_data, in_empty};

 // input pipeline
	alt_aeu_40_pfc_mspipe  #(
		.WIDTH(WIDTH), 
		.PDEPTH(PDEPTH), 
		.ODEPTH(ODEPTH)
	) input_pipe (
		.clk(clk),
		.rst_n(rst_n),
		.in_ready(in_ready),
		.in_data(in_bus),
		.out_ready(out_ready),
		.out_data(out_bus),
		.pipe_data(pipe_data)
	);

 //	data packing and unpacking for pipeline
    wire pipe_stage1_valid;
    wire pipe_stage1_sop;
    wire pipe_stage1_eop;
    wire [DWIDTH-1:0] pipe_stage1_data;
    wire [EMPTYBITS-1:0] pipe_stage1_empty;

    assign {out_error, out_valid, out_sop, out_eop, out_data, out_empty} = out_bus;

    wire pipe_stage2_valid;
    wire pipe_stage2_sop;
    wire pipe_stage2_eop;
    wire [DWIDTH-1:0] pipe_stage2_data;
    wire [EMPTYBITS-1:0] pipe_stage2_empty;

    wire [WIDTH-1:0] pipe_data_st1 = pipe_data[1*WIDTH-1:0];
    wire [WIDTH-1:0] pipe_data_st2 = pipe_data[2*WIDTH-1:WIDTH];
    assign {pipe_stage1_valid, pipe_stage1_sop, pipe_stage1_eop, pipe_stage1_data, pipe_stage1_empty} = pipe_data_st1[WIDTH-2:0];
    assign {pipe_stage2_valid, pipe_stage2_sop, pipe_stage2_eop, pipe_stage2_data, pipe_stage2_empty} = pipe_data_st2[WIDTH-2:0];

	always@ (posedge clk or negedge rst_n) begin
		if (!rst_n) pkt_end <= 1'b1;
		else if (out_ready & pipe_stage1_valid & pipe_stage1_eop) pkt_end <= 1'b1;
		else if (out_ready & pipe_stage1_valid & pipe_stage1_sop) pkt_end <= 1'b0;
	end

endmodule
