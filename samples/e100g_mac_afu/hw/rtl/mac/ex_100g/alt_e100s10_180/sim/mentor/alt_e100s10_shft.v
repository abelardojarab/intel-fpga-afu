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


// S100G frame shift
// unifies the 13/14 bit schedule across the words
// Faisal - 02/22/017

`timescale 1 ps / 1 ps
module alt_e100s10_shft  (
    input               clk,
    input   [5*14-1:0]  din,
    input   [4:0]       din_hv,
    input   [4:0]       phase,  // phase aligns with when VLs are checked by the word aligner. Defines completion of a word's input cycles
    output  [5*14-1:0]  dout

);


reg [4:0]   load;
genvar i;
generate
for (i=0; i<5; i=i+1) begin : shft
    alt_e100s10_shft_w  shft_w  (
        .clk        (clk),
        .din        (din[14*i+:14]),
        .din_hv     (din_hv[i]),
        .load       (phase[i]),        
        .dout       (dout[14*i+:14])
    );
    defparam    shft_w .DELAY = 4-i;


end
endgenerate


endmodule
