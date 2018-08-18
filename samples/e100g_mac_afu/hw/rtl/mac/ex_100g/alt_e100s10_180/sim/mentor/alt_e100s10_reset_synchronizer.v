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

// DESCRIPTION
//
// This is a small register circuit for synchronizing aclr signals to produce asynchronous attack and
// synchronous release across clock domains.
//



// CONFIDENCE
// This component has significant hardware test coverage in reference designs and Altera IP cores.
//

module alt_e100s10_reset_synchronizer (
    input   aclr, // no domain
    input   clk,
    output  aclr_sync
);

wire aclr_sync_n;

    alt_e100s10_altera_std_synchronizer_nocut #(
                    .DEPTH(3),
                    .RST_VALUE(1'b0)
         )  synchronizer_nocut_inst  (
                    .clk(clk),
                    .reset_n(!aclr),
                    .din(1'b1),
                    .dout(aclr_sync_n)
    );

assign aclr_sync = ~aclr_sync_n;

endmodule
