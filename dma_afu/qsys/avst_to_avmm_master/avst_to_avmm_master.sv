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

module avst_to_avmm_master #(
	parameter AVMM_ADDR_WIDTH = 48,
	parameter AVMM_DATA_WIDTH = 512,
	parameter AVMM_BURST_COUNT = 1,
	parameter INGORE_BYTE_ENABLE = 1,
	//derived parameters
	parameter INPUT_AVST_WIDTH = AVMM_DATA_WIDTH,
	parameter AVST_BYTE_ENABLE_WIDTH = (INGORE_BYTE_ENABLE == 0 ? AVMM_DATA_WIDTH/8 : 0),
	parameter AVST_OUTPUT_CONTROL_WIDTH = 1+AVST_BYTE_ENABLE_WIDTH,
	parameter OUTPUT_AVST_WIDTH = AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+AVST_OUTPUT_CONTROL_WIDTH
	)
	(
	input clk,
	input reset,
	
	//for read response
	input [INPUT_AVST_WIDTH-1:0] avst_rd_rsp_data,
    input avst_rd_rsp_valid,
    output logic avst_rd_rsp_ready,
    
    //for read/write request
    output logic 	[OUTPUT_AVST_WIDTH-1:0] avst_avcmd_data,
    output logic avst_avcmd_valid,
    input avst_avcmd_ready,
	
	output logic		avmm_waitrequest,
	output logic	[AVMM_DATA_WIDTH-1:0]	avmm_readdata,
	output logic		avmm_readdatavalid,
	input 	[AVMM_DATA_WIDTH-1:0]	avmm_writedata,
	input 	[AVMM_ADDR_WIDTH-1:0]	avmm_address,
	input 		avmm_write,
	input 		avmm_read,
	
	//not used right now
	input 	[AVMM_BURST_COUNT-1:0]	avmm_burstcount,
	input 	[(AVMM_DATA_WIDTH/8)-1:0]	avmm_byteenable
);
	typedef struct packed { 
		logic [AVMM_ADDR_WIDTH-1:0] addr;
		logic [AVMM_DATA_WIDTH-1:0] write_data;
		logic [AVST_OUTPUT_CONTROL_WIDTH-1:0] control;
    } t_avst_output;
    
    t_avst_output output_next;
    
    //read/write request
    assign output_next.addr = avmm_address;
	assign output_next.write_data = avmm_writedata;
	assign output_next.control[0] = avmm_read;
    
    assign avmm_waitrequest = ~avst_avcmd_ready;
	assign avst_avcmd_valid = reset ? 1'b0 : (avmm_read | avmm_write);
	assign avst_avcmd_data = output_next;
		
	//read resp
    assign avmm_readdatavalid = reset ? 1'b0 : avst_rd_rsp_valid;
	assign avmm_readdata = avst_rd_rsp_data;
	assign avst_rd_rsp_ready = ~reset;
    
endmodule
