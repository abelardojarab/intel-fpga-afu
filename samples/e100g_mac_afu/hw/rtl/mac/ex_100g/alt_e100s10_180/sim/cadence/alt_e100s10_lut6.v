// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ps / 1 ps

module alt_e100s10_lut6 #(
    parameter MASK = 64'h80000000_00000000,
    parameter SIM_EMULATE = 1'b0
) (
    input [5:0] din,
    output dout
);

generate
    if (SIM_EMULATE) begin
        assign dout = MASK [din];
    end else begin

        fourteennm_lcell_comb s10c (
            .dataa (din[0]),
            .datab (din[1]),
            .datac (din[2]),
            .datad (din[3]),
            .datae (din[4]),
            .dataf (din[5]),
            .datag(1'b1),
            .cin(1'b1),
            // synthesis translate_off
            .datah(1'b1),
            .sharein(1'b0),  // does not exist in S10, but present in models for now
            // synthesis translate_on
            .sumout(),.cout(),.shareout(),
            .combout(dout)
        );
        defparam s10c .lut_mask = MASK;
        defparam s10c .shared_arith = "off";
        defparam s10c .extended_lut = "off";
    end
endgenerate

endmodule
