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
import cci_mpf_csrs_pkg::*;

module ccip_avmm_mmio #(
	parameter AVMM_ADDR_WIDTH = 16,
	parameter AVMM_DATA_WIDTH = 64
	)
	
	(
	input clk,
	input	SoftReset,

	output logic [AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+2-1:0] in_data,
    output logic in_valid,
    input in_ready,
             
    input [AVMM_DATA_WIDTH-1:0] out_data,
    input out_valid,
    output logic out_ready,
	
	// ---------------------------IF signals between CCI and AFU  --------------------------------
	//input	t_if_ccip_Rx    cp2af_sRxPort,
	input t_if_ccip_c0_Rx ccip_c0_Rx_port,
	//output	t_if_ccip_Tx	af2cp_sTxPort
	output t_if_ccip_c2_Tx ccip_c2_Tx_port
);
	localparam INPUT_AVST_WIDTH = AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+2;
	localparam TID_FIFO_WIDTH = CCIP_TID_WIDTH+1;

	typedef struct packed { 
		logic is_read;
		logic is_32bit;
		logic [AVMM_ADDR_WIDTH-1:0] addr;
		logic [AVMM_DATA_WIDTH-1:0] write_data;
    } t_avst_input;
    
    t_avst_input avst_input_data;
    assign in_data = avst_input_data;

	// cast c0 header into ReqMmioHdr
	t_ccip_c0_ReqMmioHdr mmioHdr;
	assign mmioHdr = t_ccip_c0_ReqMmioHdr'(ccip_c0_Rx_port.hdr);
	wire mmio32_req = (mmioHdr.length == 2'b00);
	wire mmio32_highword_req = mmio32_req & mmioHdr.address[0];
	
	logic tid_fifo_wrreq;
	reg tid_fifo_rdreq;
	logic [TID_FIFO_WIDTH-1:0] tid_fifo_input;
	wire [TID_FIFO_WIDTH-1:0] tid_fifo_output;
	reg [63:0] rd_rsp_data_reg;
	reg [63:0] rd_rsp_data_reg2;
	reg rd_rsp_valid_reg;
	
	wire fifo_mmio32_highword_req = tid_fifo_output[TID_FIFO_WIDTH-1];
	
	//need to avoid region that MPF responds to
	wire mmio_address_valid = !(mmioHdr.address >= 16'h800 && mmioHdr.address < (16'h800+CCI_MPF_MMIO_SIZE/4));
	
	scfifo  tid_fifo_inst (
		.data(tid_fifo_input),
		.q(tid_fifo_output),
		.sclr(SoftReset),
		.clock(clk),
		.wrreq(tid_fifo_wrreq),
		.rdreq(tid_fifo_rdreq),
		.aclr (),
		.almost_empty (),
		.almost_full (),
		.eccstatus (),
		.empty (),
		.full (),
		.usedw ()
	);
    defparam
        tid_fifo_inst.add_ram_output_register  = "ON",
        tid_fifo_inst.enable_ecc  = "FALSE",
        tid_fifo_inst.intended_device_family  = "Arria 10",
        tid_fifo_inst.lpm_numwords  = 64,
        tid_fifo_inst.lpm_showahead  = "OFF",
        tid_fifo_inst.lpm_type  = "scfifo",
        tid_fifo_inst.lpm_width  = TID_FIFO_WIDTH,
        tid_fifo_inst.lpm_widthu  = 6,
        tid_fifo_inst.overflow_checking  = "ON",
        tid_fifo_inst.underflow_checking  = "ON",
        tid_fifo_inst.use_eab  = "ON";

	always_ff @(posedge clk)
	begin
		out_ready <= SoftReset ? 1'b0 : 1'b1;
		
		//MMIO request (read or write)
		in_valid <= SoftReset ? 1'b0 : (ccip_c0_Rx_port.mmioRdValid || ccip_c0_Rx_port.mmioWrValid) && mmio_address_valid;
		avst_input_data.addr <= {mmioHdr.address, 2'b00};
		avst_input_data.is_32bit <= mmio32_req;
		avst_input_data.is_read <= ccip_c0_Rx_port.mmioRdValid && mmio_address_valid;

		//MMIO write request
		avst_input_data.write_data[31:0] <= ccip_c0_Rx_port.data[31:0];
		avst_input_data.write_data[63:32] <= mmio32_highword_req ? ccip_c0_Rx_port.data[31:0] : ccip_c0_Rx_port.data[63:32];
		
		//MMIO read requests
		tid_fifo_wrreq <= SoftReset ? 1'b0 : (ccip_c0_Rx_port.mmioRdValid && mmio_address_valid);
		tid_fifo_input <= {mmio32_highword_req, mmioHdr.tid}; // copy TID

		//MMIO read response
		tid_fifo_rdreq <= SoftReset ? 1'b0 : out_valid;
		rd_rsp_valid_reg <= SoftReset ? 1'b0 : tid_fifo_rdreq;
		rd_rsp_data_reg <= out_data;
		rd_rsp_data_reg2 <= rd_rsp_data_reg;
		ccip_c2_Tx_port.mmioRdValid <= SoftReset ? 1'b0 : rd_rsp_valid_reg; // post response
		ccip_c2_Tx_port.hdr.tid <= tid_fifo_output[CCIP_TID_WIDTH-1:0];
		ccip_c2_Tx_port.data[31:0] <= fifo_mmio32_highword_req ? rd_rsp_data_reg2[63:32] : rd_rsp_data_reg2[31:0];
		ccip_c2_Tx_port.data[63:32] <= rd_rsp_data_reg2[63:32];
	end

endmodule
