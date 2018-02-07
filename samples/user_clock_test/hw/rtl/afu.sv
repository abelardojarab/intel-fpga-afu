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
// Tie counters to CCI-P clocks in order to compare their frequencies.
// The frequency of pClk is exported via an MMIO CSR, allowing software
// to compute the actual frequencies of all clocks.
//

`include "platform_if.vh"
`include "afu_json_info.vh"

module afu (
    // ---------------------------global signals-------------------------------------------------
    input   pClk,     //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
    input   pClkDiv2,
    input   pClkDiv4,
    input   uClk_usr,
    input   uClk_usrDiv2,
    input   SoftReset,    //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH

    // ---------------------------IF signals between CCI and AFU  --------------------------------
    input   t_if_ccip_Rx    cp2af_sRxPort,
    output  t_if_ccip_Tx    af2cp_sTxPort
);

    // AFU UUID from the AFU JSON (stored in the generated afu_json_info.vh)
    logic [127:0] afu_id = `AFU_ACCEL_UUID;

    logic [63:0] scratch_reg = 0;

    logic [63:0] reset_counter = 0;
    logic [63:0] enable_counter = 0;
    logic [63:0] counter_max = 0;

    wire  [63:0] counter_pclk_value;
    wire  [63:0] counter_pclk_div2_value;
    wire  [63:0] counter_pclk_div4_value;
    wire  [63:0] counter_clkusr_value;
    wire  [63:0] counter_clkusr_div2_value;

    wire max_value_reached;
    clock_counter #(64) counter_pclk_inst (
        .clk(pClk),
        .count(counter_pclk_value),
        .max_value(counter_max),
        .max_value_reached(max_value_reached),
        .sync_reset(SoftReset | reset_counter[0]),
        .enable(enable_counter[0])
    );

    clock_counter #(64) counter_pclk_div2_inst (
        .clk(pClkDiv2),
        .count(counter_pclk_div2_value),
        .max_value('0),
        .max_value_reached(),
        .sync_reset(SoftReset | reset_counter[0]),
        .enable(enable_counter[0] & ~max_value_reached)
    );

    clock_counter #(64) counter_pclk_div4_inst (
        .clk(pClkDiv4),
        .count(counter_pclk_div4_value),
        .max_value('0),
        .max_value_reached(),
        .sync_reset(SoftReset | reset_counter[0]),
        .enable(enable_counter[0] & ~max_value_reached)
    );

    clock_counter #(64) counter_clkusr_inst (
        .clk(uClk_usr),
        .count(counter_clkusr_value),
        .max_value('0),
        .max_value_reached(),
        .sync_reset(SoftReset | reset_counter[0]),
        .enable(enable_counter[0] & ~max_value_reached)
    );

    clock_counter #(64) counter_clkusr_div2_inst (
        .clk(uClk_usrDiv2),
        .count(counter_clkusr_div2_value),
        .max_value('0),
        .max_value_reached(),
        .sync_reset(SoftReset | reset_counter[0]),
        .enable(enable_counter[0] & ~max_value_reached)
    );

    // cast c0 header into ReqMmioHdr
    t_ccip_c0_ReqMmioHdr mmioHdr;
    assign mmioHdr = t_ccip_c0_ReqMmioHdr'(cp2af_sRxPort.c0.hdr);

    always@(posedge pClk) begin
        if(SoftReset) begin
            af2cp_sTxPort.c1.hdr        <= '0;
            af2cp_sTxPort.c1.valid      <= '0;
            af2cp_sTxPort.c1.data       <= '0;
            af2cp_sTxPort.c0.hdr        <= '0;
            af2cp_sTxPort.c0.valid      <= '0;
            af2cp_sTxPort.c2.hdr        <= '0;
            af2cp_sTxPort.c2.data       <= '0;
            af2cp_sTxPort.c2.mmioRdValid <= '0;
            //avs_writedata  <= 64'b0;
            //avs_address    <= 32'b0;
            //avs_write      <= 1'b0;
            //avs_read       <= 1'b0;
            //avs_byteenable <= 8'b0;
            scratch_reg    <= '0;
            reset_counter  <= 64'b1;
            enable_counter <= '0;
            counter_max    <= '0;
        end
        else begin
            af2cp_sTxPort.c2.mmioRdValid <= 0;
            // set the registers on MMIO write request
            // these are user-defined AFU registers at offset 0x40 and 0x41
            if(cp2af_sRxPort.c0.mmioWrValid == 1)
                case(mmioHdr.address)
                    16'h0020: scratch_reg <= cp2af_sRxPort.c0.data[63:0];
                    16'h0022: reset_counter <= cp2af_sRxPort.c0.data[63:0];
                    16'h0024: enable_counter <= cp2af_sRxPort.c0.data[63:0];
                    16'h0026: counter_max <= cp2af_sRxPort.c0.data[63:0];
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
                    16'h0002: af2cp_sTxPort.c2.data <= afu_id[63:0]; // afu id low
                    16'h0004: af2cp_sTxPort.c2.data <= afu_id[127:64]; // afu id hi
                    16'h0006: af2cp_sTxPort.c2.data <= 64'h0; // reserved
                    16'h0008: af2cp_sTxPort.c2.data <= 64'h0; // reserved
                    16'h0020: af2cp_sTxPort.c2.data <= scratch_reg;
                    16'h0022: af2cp_sTxPort.c2.data <= reset_counter;
                    16'h0024: af2cp_sTxPort.c2.data <= enable_counter;
                    16'h0026: af2cp_sTxPort.c2.data <= counter_max;
                    16'h0028: af2cp_sTxPort.c2.data <= counter_pclk_value;
                    16'h002a: af2cp_sTxPort.c2.data <= counter_pclk_div2_value;
                    16'h002c: af2cp_sTxPort.c2.data <= counter_pclk_div4_value;
                    16'h002e: af2cp_sTxPort.c2.data <= counter_clkusr_value;
                    16'h0030: af2cp_sTxPort.c2.data <= counter_clkusr_div2_value;
                    16'h0032: af2cp_sTxPort.c2.data <= 64'(ccip_cfg_pkg::PCLK_FREQ);
                    default:  af2cp_sTxPort.c2.data <= 64'h0;
                endcase
                af2cp_sTxPort.c2.mmioRdValid <= 1; // post response
            end
        end
    end

endmodule

module clock_counter #(
  parameter COUNTER_WIDTH = 16
)
    (
    input clk,
    output reg [COUNTER_WIDTH-1:0] count,
    input [COUNTER_WIDTH-1:0] max_value,
    output reg max_value_reached,
    input sync_reset,
    input enable
    );

    reg sync_enable;
    wire max_value_reached_wire;

    //assign max_value_reached_wire = (max_value <= (count+1)) & (max_value != '0);
    assign max_value_reached_wire = !max_value ? 1'b0 : (count >= max_value);

    always @ ( posedge clk) begin
        if (sync_reset) begin
            count <= 1'b0;
            max_value_reached <= 1'b0;
            sync_enable <= enable;
            max_value_reached <= 1'b0;
        end
        else begin
            sync_enable <= enable;
            max_value_reached <= max_value_reached_wire;
            if(sync_enable & ~max_value_reached) begin
                count <= count+1;
            end
            else begin
                count <= count;
            end
        end
    end

endmodule
