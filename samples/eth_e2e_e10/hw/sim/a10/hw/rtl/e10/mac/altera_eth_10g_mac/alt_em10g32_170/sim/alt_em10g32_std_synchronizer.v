// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1ns / 1ns

module alt_em10g32_std_synchronizer (
                                clk, 
                                reset_n, 
                                din, 
                                dout
                                );

    // GLOBAL PARAMETER DECLARATION
    parameter depth = 3; // This value must be >= 2 !
     
  
    // INPUT PORT DECLARATION 
    input   clk;
    input   reset_n;    
    input   din;

    // OUTPUT PORT DECLARATION 
    output  dout;

    altera_std_synchronizer_nocut #(
        .depth(depth)
    ) std_sync_no_cut (
        .clk        (clk),
        .reset_n    (reset_n),
        .din        (din),
        .dout       (dout)
    );
   
endmodule  // alt_em10g32_std_synchronizer
// END OF MODULE
                        
