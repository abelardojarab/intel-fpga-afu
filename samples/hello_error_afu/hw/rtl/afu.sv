// ***************************************************************************
// Copyright (c) 2013-2017, Intel Corporation All Rights Reserved.
// The source code contained or described herein and all  documents related to
// the  source  code  ("Material")  are  owned by  Intel  Corporation  or  its
// suppliers  or  licensors.    Title  to  the  Material  remains  with  Intel
// Corporation or  its suppliers  and licensors.  The Material  contains trade
// secrets and  proprietary  and  confidential  information  of  Intel or  its
// suppliers and licensors.  The Material is protected  by worldwide copyright
// and trade secret laws and treaty provisions. No part of the Material may be
// copied,    reproduced,    modified,    published,     uploaded,     posted,
// transmitted,  distributed,  or  disclosed  in any way without Intel's prior
// express written permission.
// ***************************************************************************
//
// Module Name:         afu.sv
// Project:             Error AFU
// Modified:            PSG - ADAPT
// Description:         Error AFU to test violations in CCI-P and AVLMM and observe 
//                      port errors and port irq generation.
//                      Write to AFU CSR word address 0x28 (byte address 0xA0)
//                      generates a CCIP interrupt request packet
//                      Read from MMIO 0x40 to observe an MMIO RD Timeout Failure
// 

`include "platform_if.vh"

// Generate interrupt
function automatic t_if_ccip_c1_Tx ccip_genInterrupt(
    input [1:0] usr_intr_id,
    t_ccip_vc vc_select
);
    // use c1 to write interrupt ccip packets
    t_if_ccip_c1_Tx c1;
    t_ccip_c1_ReqIntrHdr intrHdr;

    intrHdr.vc_sel = vc_select;
    intrHdr.rsvd1 = 0;
    intrHdr.req_type = eREQ_INTR;
    intrHdr.rsvd0 = 0;
    intrHdr.id = usr_intr_id;

    c1.hdr = t_ccip_c1_ReqMemHdr'(intrHdr);
    c1.valid = 1;
    c1.data = 0;

    return c1;
endfunction

module afu #(
    parameter NUM_LOCAL_MEM_BANKS = 2
)(
        // ---------------------------global signals-------------------------------------------------
        input	Clk_400,	  //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
        input	SoftReset,	  //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH
        // ---------------------------IF signals between CCI and AFU  --------------------------------
`ifdef PLATFORM_PROVIDES_LOCAL_MEMORY
        // Local memory interface
        avalon_mem_if.to_fiu local_mem[NUM_LOCAL_MEM_BANKS],
`endif
        input	t_if_ccip_Rx	cp2af_sRxPort,
        output	t_if_ccip_Tx	af2cp_sTxPort
);

        //Hello_Error ID 5c1ea3c4-2bfb-4e2a-abf4-13c1e12541b0
        localparam HELLO_ERROR_ID_H = 64'h5c1e_a3c4_2bfb_4e2a;
        localparam HELLO_ERROR_ID_L = 64'habf4_13c1_e125_41b0;
        logic  [63:0] scratch_reg = 0;
        // a write to the intr_reg triggers an interrupt request
        reg           intr_reg;
        reg [1:0]     usr_intr_id;

        // cast c0 header into ReqMmioHdr
        t_ccip_c0_ReqMmioHdr mmioHdr;
        t_ccip_c1_ReqIntrHdr intrHdr;
        assign mmioHdr = t_ccip_c0_ReqMmioHdr'(cp2af_sRxPort.c0.hdr);
        assign intrHdr = t_ccip_c1_ReqIntrHdr'(cp2af_sRxPort.c1.hdr);

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
                if(cp2af_sRxPort.c0.mmioWrValid == 1) begin
                    case(mmioHdr.address)
                        16'h0020: scratch_reg <= cp2af_sRxPort.c0.data[63:0];
                        16'h0028: af2cp_sTxPort.c1 <= ccip_genInterrupt(usr_intr_id,af2cp_sTxPort.c1.hdr.vc_sel);
                        16'h0030: usr_intr_id <= cp2af_sRxPort.c0.data[1:0];
                    endcase
                end
                else begin
                  af2cp_sTxPort.c1.hdr   <= '0;
                  af2cp_sTxPort.c1.valid <= '0;
                  af2cp_sTxPort.c1.data  <= '0;
                end
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
                      16'h0002: af2cp_sTxPort.c2.data <= HELLO_ERROR_ID_L; // afu id low
                      16'h0004: af2cp_sTxPort.c2.data <= HELLO_ERROR_ID_H; // afu id hi
                      16'h0006: af2cp_sTxPort.c2.data <= 64'h0; // next AFU
                      16'h0008: af2cp_sTxPort.c2.data <= 64'h0; // reserved
                      16'h0020: af2cp_sTxPort.c2.data <= scratch_reg; // Scratch Register
                      16'h0028: af2cp_sTxPort.c2.data <= usr_intr_id; // User interrupt id register
                      default:  af2cp_sTxPort.c2.data <= 64'h0;
                  endcase
                  af2cp_sTxPort.c2.mmioRdValid <= (mmioHdr.address == 16'h0040) ? 0 : 1; // MMIO RD Timeout when readding form 'h40, else post response
              end
          end
      end

endmodule
