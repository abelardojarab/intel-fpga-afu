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

        //PV_AFU ID
        localparam PV_AFU_ID_H = 64'h16D6_3FA7_657A_446E;
        localparam PV_AFU_ID_L = 64'h81C0_31E4_0B08_CAE6;
        localparam num_gw = 32;
        logic  [63:0] scratch_reg = 0;
        logic  [15:0] gw_sel_reg = 0;
	logic  [num_gw-1:0]  gw_dout, gw_dout_bool;
        logic  [num_gw-1:0]  gw_sticky_err, gw_sticky_err_bool;
	logic  [num_gw-1:0] gw_ena_reg,gw_sclr_reg,gw_sclr_err_reg;
//	int num = 3;

        // cast c0 header into ReqMmioHdr
        t_ccip_c0_ReqMmioHdr mmioHdr;
        assign mmioHdr = t_ccip_c0_ReqMmioHdr'(cp2af_sRxPort.c0.hdr);

        always@(posedge Clk_400) begin
            if(SoftReset) begin
                af2cp_sTxPort.c1.hdr         <= '0;
                af2cp_sTxPort.c1.valid       <= '0;
                af2cp_sTxPort.c1.data        <= '0;
                af2cp_sTxPort.c0.hdr         <= '0;
                af2cp_sTxPort.c0.valid       <= '0;
                af2cp_sTxPort.c2.hdr         <= '0;
                af2cp_sTxPort.c2.data        <= '0;
                af2cp_sTxPort.c2.mmioRdValid <= '0;
                scratch_reg   		     <= '0;
		gw_ena_reg 	      	     <= '0;
		gw_sclr_reg		     <= '0;
		gw_sclr_err_reg		     <= '0;
		gw_sel_reg		     <= '0;
//		glitch_witch_ctrl_reg 	     <= '0;
//		glitch_witch_output_reg <= '0;
            end
            else begin
                af2cp_sTxPort.c2.mmioRdValid <= 0;
                // set the registers on MMIO write request
                // these are user-defined AFU registers at offset 0x40 and 0x41
                if(cp2af_sRxPort.c0.mmioWrValid == 1)
                    case(mmioHdr.address)
                        16'h0020: scratch_reg <= cp2af_sRxPort.c0.data[63:0];
			16'h0022: gw_sel_reg  <= cp2af_sRxPort.c0.data[15:0];
			16'h0024: gw_ena_reg[gw_sel_reg]  <= cp2af_sRxPort.c0.data[0];
                        16'h0026: gw_sclr_reg[gw_sel_reg] <= cp2af_sRxPort.c0.data[0];
                        16'h0028: gw_sclr_err_reg[gw_sel_reg] <= cp2af_sRxPort.c0.data[0];
		//	16'h0018: glitch_witch_ctrl_reg <= cp2af_sRxPort.c0.data[2:0]; // glitch_witch module reg

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
                      16'h0002: af2cp_sTxPort.c2.data <= PV_AFU_ID_L; // afu id low
                      16'h0004: af2cp_sTxPort.c2.data <= PV_AFU_ID_H; // afu id hi
                      16'h0006: af2cp_sTxPort.c2.data <= 64'h0; // next AFU
                      16'h0008: af2cp_sTxPort.c2.data <= 64'h0; // reserved
                      16'h0020: af2cp_sTxPort.c2.data <= scratch_reg;// Scratch Register
		      16'h0024: af2cp_sTxPort.c2.data <={63'h0, gw_ena_reg[gw_sel_reg]};
		      16'h0026: af2cp_sTxPort.c2.data <={63'h0,gw_sclr_reg[gw_sel_reg]};
		      16'h0028: af2cp_sTxPort.c2.data <={63'h0, gw_sclr_err_reg[gw_sel_reg]};
                      16'h0030: af2cp_sTxPort.c2.data <= {62'h0,gw_sticky_err_bool[gw_sel_reg],gw_dout_bool[gw_sel_reg]};
		    //  16'h0018: af2cp_sTxPort.c2.data <= {58'h0,gw_sticky_err_bool,gw_dout_bool, glitch_witch_ctrl_reg[2:0]}; // glitch_witch module reg
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

assign DDR4a_burstcount = 7'b1;
assign DDR4a_byteenable = 64'hFFFF_FFFF_FFFF_FFFF;
assign DDR4b_burstcount = 7'b1;
assign DDR4b_byteenable = 64'hFFFF_FFFF_FFFF_FFFF;
`endif

genvar j;
generate
for (j = 0; j<num_gw;j=j+1)
	
always @(posedge Clk_400) begin
	if(SoftReset) begin
		gw_dout_bool[j] <= 0;
		gw_sticky_err_bool[j] <= 0;
	end
	else begin
		if (gw_dout[j] == 1) 
			gw_dout_bool[j] <= 1;
		else 
			gw_dout_bool[j] <= 0;

		if (gw_sticky_err[j] == 1) 
			gw_sticky_err_bool[j] <= 1;
		else 
			gw_sticky_err_bool[j] <= 0;
	
	end
end
endgenerate


//Module instance of glitch_witch
genvar i;
generate
for (i = 0; i<num_gw;i=i+1)
	 begin: glitch_witches 
		glitch_witch instance_glitch_witch (	.clk 		(Clk_400),
					.ena 		(gw_ena_reg[i]),
					.sclr 		(gw_sclr_reg[i]),
					.sclr_err 	(gw_sclr_err_reg[i]),
					.dout 		(gw_dout[i]),
					.sticky_err	(gw_sticky_err[i])
				);
	end
endgenerate


endmodule
