// ***************************************************************************
// Copyright (c) 2013-2017, Intel Corporation
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
//
// Module Name:         afu.sv
// Project:             Mixed Language AFU
// Modified:            PSG - ADAPT
// Description:         Mixed Language AFU illustrates the use of mixed-language design
//                      involving Verilog and VHDL.
//                      Supports MMIO Writes and Reads for the DCP 1.0 Release.
//
import ccip_if_pkg::*;

module afu (
        // ---------------------------global signals-------------------------------------------------
        input	Clk_400,	  //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
        input	SoftReset,	  //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH
        // ---------------------------IF signals between CCI and AFU  --------------------------------
`ifdef INCLUDE_DDR4
        input	wire		DDR4_USERCLK,
        input	wire		DDR4a_waitrequest,
        input	wire [511:0]	DDR4a_readdata,
        input	wire		DDR4a_readdatavalid,
        output	wire [6:0]	DDR4a_burstcount,
        output	reg  [511:0]	DDR4a_writedata,
        output	reg  [25:0]	DDR4a_address,
        output	reg		DDR4a_write,
        output	reg		DDR4a_read,
        output	wire [63:0]	DDR4a_byteenable,
        input	wire		DDR4b_waitrequest,
        input	wire [511:0]	DDR4b_readdata,
        input	wire		DDR4b_readdatavalid,
        output	wire [6:0]	DDR4b_burstcount,
        output	reg  [511:0]	DDR4b_writedata,
        output	reg  [25:0]	DDR4b_address,
        output	reg		DDR4b_write,
        output	reg		DDR4b_read,
        output	wire [63:0]	DDR4b_byteenable,
`endif
        input	t_if_ccip_Rx	cp2af_sRxPort,
        output	t_if_ccip_Tx	af2cp_sTxPort
);

        //Hello_AFU ID
        localparam MIXED_LANG_AFU_ID_H = 64'h850A_DCC2_6CEB_4B22;
        localparam MIXED_LANG_AFU_ID_L = 64'h9722_D433_75B6_1C66;

	logic scratch_en;
	wire [63:0] reg_out;

        // cast c0 header into ReqMmioHdr
        t_ccip_c0_ReqMmioHdr mmioHdr;
        assign mmioHdr = t_ccip_c0_ReqMmioHdr'(cp2af_sRxPort.c0.hdr);

        always@(posedge Clk_400) begin
            if(SoftReset) begin
                af2cp_sTxPort.c1.hdr        <= '0;
                af2cp_sTxPort.c1.valid      <= '0;
                af2cp_sTxPort.c1.data       <= '0;
                af2cp_sTxPort.c0.hdr        <= '0;
                af2cp_sTxPort.c0.valid      <= '0;
                af2cp_sTxPort.c2.hdr        <= '0;
                af2cp_sTxPort.c2.data       <= '0;
                af2cp_sTxPort.c2.mmioRdValid <= '0;
            end
            else begin
                af2cp_sTxPort.c2.mmioRdValid <= 0;
              // serve MMIO read requests
              if(cp2af_sRxPort.c0.mmioRdValid == 1) begin
                  af2cp_sTxPort.c2.hdr.tid <= mmioHdr.tid; // copy TID
                  case(mmioHdr.address)
                      // AFU header
                      16'h0000: af2cp_sTxPort.c2.data <= {
                         4'b0001, // Feature type = AFU
                         8'b0,    // reserved
                         4'b0,    // afu minor revision = 0
                         7'b0,    // reserved
                         1'b1,    // end of DFH list = 1
                         24'b0,   // next DFH offset = 0
                         4'b0,    // afu major revision = 0
                         12'b0    // feature ID = 0
                      };
                      16'h0002: af2cp_sTxPort.c2.data <= MIXED_LANG_AFU_ID_L; // afu id low
                      16'h0004: af2cp_sTxPort.c2.data <= MIXED_LANG_AFU_ID_H; // afu id hi
                      16'h0006: af2cp_sTxPort.c2.data <= 64'h0; // next AFU
                      16'h0008: af2cp_sTxPort.c2.data <= 64'h0; // reserved
                      16'h0020: af2cp_sTxPort.c2.data <= reg_out; // Scratch Register
                      default:  af2cp_sTxPort.c2.data <= 64'h0;
                  endcase
                  af2cp_sTxPort.c2.mmioRdValid <= 1; // post response
              end
          end
      end
`ifdef INCLUDE_DDR4
        always @(posedge DDR4_USERCLK) begin
            if(SoftReset) begin
                DDR4a_write <= 1'b0;
                DDR4a_read  <= 1'b0;
                DDR4b_write <= 1'b0;
                DDR4b_read  <= 1'b0;
            end
        end


    always_comb
	begin
	scratch_en = 1'b0; 
         if(cp2af_sRxPort.c0.mmioWrValid == 1)
                  case(mmioHdr.address)
                        16'h0020: scratch_en = 1'b1;
                  endcase
	end
	


reg_1x64 u1 (
	.data_in (cp2af_sRxPort.c0.data[63:0]),
	.enable (scratch_en),
	.clk    (Clk_400),
	.SoftReset (SoftReset),
	.data_out (reg_out)
	);

assign DDR4a_burstcount = 7'b1;
assign DDR4a_byteenable = 64'hFFFF_FFFF_FFFF_FFFF;
assign DDR4b_burstcount = 7'b1;
assign DDR4b_byteenable = 64'hFFFF_FFFF_FFFF_FFFF;
`endif
endmodule
