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


// ____________________________________________________________________
//Copyright(C) 2013: Altera Corporation
// $Id: //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/eth/alt_e100_ultra_top.v#19 $
// $Revision: #19 $
// $Date: 2013/06/27 $
// $Author: adubey $
// ____________________________________________________________________
// adubey 06.2013
// altera message_off 10036  // value assigned but never used
 module alt_aeu_40_sfc_tx_idp 
     #( 
       parameter DWIDTH = 512 
      ,parameter EMPTYBITS = 6 
      ,parameter PDEPTH = 2 
      ,parameter ODEPTH = 2 
      ,parameter FSMPDEPTH = 2		// stages needed for fsm
      ,parameter VALID_BITS = 1
      ,parameter SOP_BITS = 1
      ,parameter EOP_BITS = 1
      ,parameter ERROR_BITS = 1
      ,parameter CWIDTH= VALID_BITS + SOP_BITS + EOP_BITS + EMPTYBITS + ERROR_BITS
      ,parameter WIDTH = DWIDTH+CWIDTH
      )(
       input wire clk 
      ,input wire rst_n 

 //   input data-path interface
      ,output wire in_ready      		// input ready
      ,input wire in_valid      		// input val
      ,input wire in_sop   			// sop word
      ,input wire in_eop   			// sop word
      ,input wire in_error
      ,input wire [DWIDTH-1:0] in_data 	// data 
      ,input wire [EMPTYBITS-1:0] in_empty 	// eop byte(one hot)

//     output data-path interface
      ,input wire out_ready			// stall input pipe
      ,output wire out_valid      		// output val
      ,output wire out_sop 			// sop cycle      
      ,output wire out_eop 			// eop cycle  
      ,output wire out_error
      ,output wire [DWIDTH-1:0] out_data 	// data
      ,output wire [EMPTYBITS-1:0] out_empty 	// eop byte (one hot)
      ,output wire [ODEPTH*WIDTH-1:0] pipe_data

      ,output reg pkt_end      		// 
     );

 // ____________________________________________________________________
 //   localparam  VALID_BITS = 1;
 //   localparam  SOP_BITS = 1;
 //   localparam  EOP_BITS = 1;
 //   localparam  DATA_BITS = 64*WORDS;
 //   localparam  DWIDTH= DATA_BITS;
 //   localparam  CWIDTH= VALID_BITS + SOP_BITS + EOP_BITS + EMPTYBITS;
 //   localparam  WIDTH = DWIDTH+CWIDTH;

 // ____________________________________________________________________
 // packing wires to move around the pipeline

     wire[WIDTH-1:0] in_bus, out_bus;
     assign in_bus = {in_error, in_valid, in_sop,in_eop, in_data, in_empty};


 // ___________________________________________________________________________________________________
 // input pipeline
 // ___________________________________________________________________________________________________
   wire [ODEPTH*WIDTH-1:0] pipe_line;
   alt_aeu_40_sfc_pipe_line #(.WIDTH(WIDTH), .PDEPTH(PDEPTH), .ODEPTH(ODEPTH))
   input_pipe 	 	(.clk(clk)
			,.rst_n(rst_n)
			,.in_ready(in_ready) 	// TBD: in_ready)
			,.in_data(in_bus)
			,.out_ready(out_ready) // TBD: out_ready)
			,.out_data(out_bus)
			,.pipe_data(pipe_data)
			);

 // _________________________________________________________________________________________________
 //	data packing and unpacking for pipeline
 // _________________________________________________________________________________________________
    wire pipe_stage1_valid; 	
    wire pipe_stage1_sop; 	
    wire pipe_stage1_eop; 	
    wire [DWIDTH-1:0] pipe_stage1_data; 	
    wire [EMPTYBITS-1:0] pipe_stage1_empty; 	


    assign {out_error, out_valid, out_sop, out_eop, out_data, out_empty} = out_bus;
 // _________________________________________________________________________________________________
 //	debug wires
 // _________________________________________________________________________________________________

    wire pipe_stage2_valid; 	
    wire pipe_stage2_sop; 	
    wire pipe_stage2_eop; 	
    wire [DWIDTH-1:0] pipe_stage2_data; 	
    wire [EMPTYBITS-1:0] pipe_stage2_empty; 	

    wire [WIDTH-1:0] pipe_data_st1 = pipe_data[1*WIDTH-1:0];
    wire [WIDTH-1:0] pipe_data_st2 = pipe_data[2*WIDTH-1:WIDTH];
    assign {pipe_stage1_valid, pipe_stage1_sop, pipe_stage1_eop, pipe_stage1_data, pipe_stage1_empty} = pipe_data_st1[WIDTH-2:0];
    assign {pipe_stage2_valid, pipe_stage2_sop, pipe_stage2_eop, pipe_stage2_data, pipe_stage2_empty} = pipe_data_st2[WIDTH-2:0];

    always@ (posedge clk or negedge rst_n) 
        begin
	   if (!rst_n) pkt_end <= 1'b1; 
	   else if (out_ready & pipe_stage1_valid & pipe_stage1_eop) pkt_end <= 1'b1; 
	   else if (out_ready & pipe_stage1_valid & pipe_stage1_sop) pkt_end <= 1'b0; 
        end

 endmodule


