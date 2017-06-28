// ***************************************************************************
// Copyright (c) 2017, Intel Corporation
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// * Neither the name of Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// ***************************************************************************

module avst_to_avmm_slave #(
	parameter AVMM_ADDR_WIDTH = 18,
	parameter AVMM_DATA_WIDTH = 64
	)
	(
	input clk,
	input reset,

	input [AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+2-1:0] in_data,
    input in_valid,
    output logic in_ready,

    output logic 	[AVMM_DATA_WIDTH-1:0] out_data,
    output logic out_valid,
    input out_ready,

	input		avmm_waitrequest,
	input	[AVMM_DATA_WIDTH-1:0]	avmm_readdata,
	input		avmm_readdatavalid,
	output logic 	[0:0]	avmm_burstcount,
	output logic 	[AVMM_DATA_WIDTH-1:0]	avmm_writedata,
	output logic 	[AVMM_ADDR_WIDTH-1:0]	avmm_address,
	output logic 		avmm_write,
	output logic 		avmm_read,
	output logic 	[(AVMM_DATA_WIDTH/8)-1:0]	avmm_byteenable
);

	localparam INPUT_AVST_WIDTH = AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+2;
	localparam AVMM_BYTE_ENABLE_WIDTH=(AVMM_DATA_WIDTH/8);

	typedef struct packed { 
		logic is_read;
		logic is_32bit;
		logic [AVMM_ADDR_WIDTH-1:0] addr;
		logic [AVMM_DATA_WIDTH-1:0] write_data;
    } t_avst_input; 

    t_avst_input avst_input_data;
    assign avst_input_data = in_data;

    assign avmm_byteenable = avst_input_data.is_32bit ? 
    	(avst_input_data.addr[2] ? 8'b11110000 : 8'b00001111) : 8'b11111111;

	//read/write request
    assign avmm_address = avst_input_data.addr;
    assign avmm_writedata = avst_input_data.write_data;
	assign avmm_burstcount = 1'b1;

	assign in_ready = !reset & !avmm_waitrequest;	
    wire avmm_ready = !reset & (!avmm_waitrequest && in_valid);
    assign avmm_write = avmm_ready & !avst_input_data.is_read;
    assign avmm_read = avmm_ready & avst_input_data.is_read;

	//handle read response
	assign out_data = avmm_readdata;
	assign out_valid = reset ? 1'b0 : avmm_readdatavalid;
	
endmodule
