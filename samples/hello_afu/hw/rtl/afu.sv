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
// Project:             Hello AFU
// Modified:            PSG - ADAPT
// Description:         Hello AFU supports MMIO Writes and Reads for the DCP 1.0 Release.
//
// Hello_AFU is provided as as starting point for developing AFUs with the dcp_1.0 release for MMIO
// Writes and Reads.
//
// It is strongly recommended:
// - register all AFU inputs and outputs
// - output registers should be initialized with a reset
// - Host Writes and Reads must be sent on Virtual Channel (VC): VH0 - PCIe0 link
// - MMIO addressing must be QuardWord Aligned (Quadword = 8 bytes)
// - AFU_ID must be re-generated for new AFUs.
//
// Please see the CCI-P specification for more information about the CCI-P interfaces.
// AFU template provides 4 AFU CSR registers required by the CCI-P protocol(see
// specification for more information) and a scratch register to issue MMIO Writes and Reads.
//
// Scratch_Reg[63:0] @ Byte Address 0x0080 is provided to test MMIO Reads and Writes to the AFU.
//
import ccip_if_pkg::*;

module afu (
        // ---------------------------global signals-------------------------------------------------
        input	Clk_400,	  //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
        input	SoftReset,	  //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH
        // ---------------------------IF signals between CCI and AFU  --------------------------------

        input	t_if_ccip_Rx	cp2af_sRxPort,
        output	t_if_ccip_Tx	af2cp_sTxPort
);

        //Hello_AFU ID
        localparam HELLO_AFU_ID_H = 64'h850A_DCC2_6CEB_4B22;
        localparam HELLO_AFU_ID_L = 64'h9722_D433_75B6_1C66;

        logic  [63:0] scratch_reg = 0;

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
                scratch_reg    <= '0;
            end
            else begin
                af2cp_sTxPort.c2.mmioRdValid <= 0;
                // set the registers on MMIO write request
                // these are user-defined AFU registers at offset 0x40 and 0x41
                if(cp2af_sRxPort.c0.mmioWrValid == 1)
                    case(mmioHdr.address)
                        16'h0020: scratch_reg <= cp2af_sRxPort.c0.data[63:0];
                    endcase
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
                      16'h0002: af2cp_sTxPort.c2.data <= HELLO_AFU_ID_L; // afu id low
                      16'h0004: af2cp_sTxPort.c2.data <= HELLO_AFU_ID_H; // afu id hi
                      16'h0006: af2cp_sTxPort.c2.data <= 64'h0; // next AFU
                      16'h0008: af2cp_sTxPort.c2.data <= 64'h0; // reserved
                      16'h0020: af2cp_sTxPort.c2.data <= scratch_reg; // Scratch Register
                      default:  af2cp_sTxPort.c2.data <= 64'h0;
                  endcase
                  af2cp_sTxPort.c2.mmioRdValid <= 1; // post response
              end
          end
      end
endmodule
