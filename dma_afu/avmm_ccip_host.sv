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

import ccip_if_pkg::*;

module avmm_ccip_host #(
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
	input	reset,

	output logic [INPUT_AVST_WIDTH-1:0] avst_rd_rsp_data,
    output logic avst_rd_rsp_valid,
    input avst_rd_rsp_ready,
             
    input [OUTPUT_AVST_WIDTH-1:0] avst_avcmd_data,
    input avst_avcmd_valid,
    output logic avst_avcmd_ready,
    
	// ---------------------------IF signals between CCI and AFU  --------------------------------
	input c0TxAlmFull,
	input c1TxAlmFull,
	//for read response
	input t_if_ccip_c0_Rx      c0rx,
	//for write response.  don't need for now.  not using avmm write response
	//input t_if_ccip_c1_Rx      c1rx,
	
	//read request
	output t_if_ccip_c0_Tx c0tx,
	
	//write request
	output t_if_ccip_c1_Tx c1tx
);
	t_ccip_mdata tx_mdata;
	t_ccip_mdata rx_mdata;
	//read request
	t_if_ccip_c0_Tx c0tx_next;
	//write request
	t_if_ccip_c1_Tx c1tx_next;

	typedef struct packed { 
		logic [AVMM_ADDR_WIDTH-1:0] addr;
		logic [AVMM_DATA_WIDTH-1:0] write_data;
		logic [AVST_OUTPUT_CONTROL_WIDTH-1:0] control;
    } t_avst_output;
    
    t_avst_output avmm_request;
	
	//read request
	assign avmm_request = avst_avcmd_data;
	wire avmm_read = avmm_request.control[0] & avst_avcmd_valid;
	assign c0tx_next.hdr.vc_sel = eVC_VH0;
	assign c0tx_next.hdr.rsvd1 = '0;
	assign c0tx_next.hdr.cl_len = eCL_LEN_1;
	assign c0tx_next.hdr.req_type = eREQ_RDLINE_I;
	assign c0tx_next.hdr.address = avmm_request.addr[47:6];
	assign c0tx_next.hdr.mdata = rx_mdata;
	assign c0tx_next.valid = reset ? 1'b0 : avmm_read;
	
	//write request
	wire avmm_write = ~avmm_request.control[0] & avst_avcmd_valid;
	assign c1tx_next.hdr.rsvd2 = '0;
	assign c1tx_next.hdr.vc_sel = eVC_VH0;
	assign c1tx_next.hdr.sop = 1'b1;
	assign c1tx_next.hdr.rsvd1 = '0;
	assign c1tx_next.hdr.cl_len = eCL_LEN_1;
	assign c1tx_next.hdr.req_type = eREQ_WRLINE_I;
	assign c1tx_next.hdr.rsvd0 = '0;
	assign c1tx_next.hdr.address = avmm_request.addr[47:6];
	assign c1tx_next.hdr.mdata = tx_mdata;
	assign c1tx_next.data = avmm_request.write_data; 
    assign c1tx_next.valid = reset ? 1'b0 : avmm_write;
    
//`define TEST_CCIP_STALL2
`ifdef TEST_CCIP_STALL
    reg ready_was_stalled;
    //wire test_ccip_pipeline_stall = 1'b1 & ~ready_was_stalled;
    wire test_ccip_pipeline_stall = ~ready_was_stalled & (tx_mdata == 1);
    wire avst_avcmd_ready_next = ~(c0TxAlmFull | c1TxAlmFull | test_ccip_pipeline_stall);
	always @(posedge clk) begin
    	if (reset)
    		ready_was_stalled <= 1'b0;
		else
			ready_was_stalled <= ~avst_avcmd_ready;
	end
`elsif TEST_CCIP_STALL2

	logic [15:0] stall_counter;
	always @(posedge clk) begin
		if (reset) begin // global reset
			stall_counter <= '0;
		end
		else begin
			if(avst_avcmd_ready)
				stall_counter <= '0;
			else
				stall_counter <= stall_counter + 1;
		end
	end
	wire test_ccip_pipeline_stall = (stall_counter != 16);
	wire avst_avcmd_ready_next = ~(c0TxAlmFull | c1TxAlmFull | test_ccip_pipeline_stall);
`else
	wire avst_avcmd_ready_next = ~(c0TxAlmFull | c1TxAlmFull);
`endif
    
	always @(posedge clk) begin
		if (reset) begin // global reset
			//wait request
			avst_avcmd_ready <= 1'b0;
			
			//read response
			avst_rd_rsp_valid <= 1'b0;
			
			//mdata counter
			tx_mdata <= '0;
			rx_mdata <= '0;
		end
		else begin
			//this can be registered because it is an almost full signal
			//will driver avmm wait request
			avst_avcmd_ready <= avst_avcmd_ready_next;
	
			//read response
			avst_rd_rsp_valid <= c0rx.rspValid & 
				(c0rx.hdr.resp_type == eRSP_RDLINE);
			
			if(avst_avcmd_ready) begin
				//read/write request
				c0tx.valid <= c0tx_next.valid;
				c1tx.valid <= c1tx_next.valid;
					
				//mdata counter
				if(c1tx_next.valid)
					tx_mdata <= tx_mdata + 1;
				if(c0tx_next.valid)
					rx_mdata <= rx_mdata + 1;
			end
			else begin
				//read/write request
				c0tx.valid <= 1'b0;
				c1tx.valid <= 1'b0;
					
				//mdata counter
				tx_mdata <= tx_mdata;
				rx_mdata <= rx_mdata;
			end
				
			//debug
			if(avst_rd_rsp_valid) begin
				$display("DCP_DEBUG: rsp_mdata=%x rsp_data=%x\n", c0rx.hdr.mdata, avst_rd_rsp_data);
			end
		end
	end
	
	always @(posedge clk) begin
		//read response
		avst_rd_rsp_data <= c0rx.data;
		
		//read/write request
		c0tx.hdr <= c0tx_next.hdr;
		c1tx.hdr <= c1tx_next.hdr;
		c1tx.data <= c1tx_next.data;
	end

endmodule
