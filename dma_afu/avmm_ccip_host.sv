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
	parameter AVMM_BURST_WIDTH = 3,
	parameter INGORE_BYTE_ENABLE = 1,
	//derived parameters
	parameter INPUT_AVST_WIDTH = AVMM_DATA_WIDTH,
	parameter AVST_BYTE_ENABLE_WIDTH = ((INGORE_BYTE_ENABLE == 0) ? AVMM_DATA_WIDTH/8 : 0),
	parameter AVST_OUTPUT_CONTROL_WIDTH = 1+AVST_BYTE_ENABLE_WIDTH,
    parameter OUTPUT_AVST_WIDTH = AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+AVMM_BURST_WIDTH+AVST_OUTPUT_CONTROL_WIDTH
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
        logic [AVMM_BURST_WIDTH-1:0] burst;
		logic [AVST_OUTPUT_CONTROL_WIDTH-1:0] control;
    } t_avst_output;
    
    t_avst_output avmm_request;


    t_ccip_clLen burst_encoded;

    always @ (avmm_request.burst)
    begin
      case (avmm_request.burst)
        3'b010:  burst_encoded = eCL_LEN_2;
        3'b100:  burst_encoded = eCL_LEN_4;
        default:  burst_encoded = eCL_LEN_1;
      endcase
    end


    reg [1:0] burst_counter;
    wire burst_counter_enable;
    wire load_burst_counter;
    wire write_sop;
    reg [1:0] address_counter;
    wire avmm_write;

    /* Timing counter for signalling the write channel SOP.
       The incoming bursts are values of 0, 1, or 3.  The steady
       state of the counter is 0 and when 0 we load the counter when
       a new write burst arrives. If a burst of 1 or 3 arrives then
       for each beat coming out of the command channel decrements the
       counter by 1.  Every time the burst counter is set to 0 the
       SOP is asserted.  For back to back bursts the counter hits 0
       exactly at the same time the next burst arrives, and if there is
       a gap between bursts the counter still hits 0 and SOP will be
       asserted but the valid will remain deasserted until the next
       burst arrives. The two address LSBs must increment during a burst
       so on a 2nd, 3rd, or 4th beat the address_counter[1:0] will be
       used for the address LSB for write commands. */
    always @ (posedge clk or posedge reset)
    begin
      if (reset == 1'b1)
      begin
        burst_counter <= 2'b00;
        address_counter <= 2'b00;
      end
      else
      begin
        if (load_burst_counter == 1'b1)
        begin
          burst_counter <= burst_encoded;
          address_counter <= avmm_request.addr[7:6] + 1'b1;  // need to +1 because this counter is only used on beats 2-4
        end
        else if (burst_counter_enable == 1'b1)
        begin
          burst_counter <= burst_counter - 1'b1;
          address_counter <= address_counter + 1'b1;
        end
      end
    end

    assign write_sop = (burst_counter == 2'b00);
    assign load_burst_counter = (burst_counter == 2'b00) & (avmm_write == 1'b1) & (avst_avcmd_ready == 1'b1);
    assign burst_counter_enable = (burst_counter != 2'b00) & (avmm_write == 1'b1) & (avst_avcmd_ready == 1'b1);
	
	//read request
	assign avmm_request = avst_avcmd_data;
	wire avmm_read = avmm_request.control[0] & avst_avcmd_valid;
	assign c0tx_next.hdr.vc_sel = eVC_VH0;
	assign c0tx_next.hdr.rsvd1 = '0;
	assign c0tx_next.hdr.cl_len = burst_encoded;
	assign c0tx_next.hdr.req_type = eREQ_RDLINE_I;
	assign c0tx_next.hdr.address = avmm_request.addr[47:6];
	assign c0tx_next.hdr.mdata = rx_mdata;
	assign c0tx_next.valid = reset ? 1'b0 : avmm_read;
	
	//write request
	assign avmm_write = ~avmm_request.control[0] & avst_avcmd_valid;
	assign c1tx_next.hdr.rsvd2 = '0;
	assign c1tx_next.hdr.vc_sel = eVC_VH0;
	assign c1tx_next.hdr.sop = write_sop;
	assign c1tx_next.hdr.rsvd1 = '0;
	assign c1tx_next.hdr.cl_len = burst_encoded;
	assign c1tx_next.hdr.req_type = eREQ_WRLINE_I;
	assign c1tx_next.hdr.rsvd0 = '0;
    assign c1tx_next.hdr.address = {avmm_request.addr[47:8], ((write_sop == 1'b1)? avmm_request.addr[7:6] : address_counter)};
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
