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


// S10 100G 66-bit Block Re-aligner & Shifter
// Faisal
// 02/2017

`timescale 1 ps / 1 ps

module alt_e100s10_shft_w  #(
    parameter       DELAY = 0
)(
    input           clk,
    input   [13:0]  din,
    input           din_hv,
    input           load,
    output  [13:0]  dout

);

reg [65:0]  din_r;
reg [65+DELAY*14:0] din_rr;

always @(posedge clk) begin

    if (din_hv)  din_r  <=  {din[13:0], din_r[65:14]};   
    else         din_r  <=  {din[12:0], din_r[65:13]}; 

end

reg load_r; 
always @(posedge clk) load_r <= load;
always @(posedge clk) begin
    if (load_r)
        din_rr  <=  {din_r, {DELAY*14{1'b0}} } | (din_rr >> 14) ;
    else
        din_rr <=   din_rr >> 14;

end


assign dout = din_rr[13:0]; 

endmodule

