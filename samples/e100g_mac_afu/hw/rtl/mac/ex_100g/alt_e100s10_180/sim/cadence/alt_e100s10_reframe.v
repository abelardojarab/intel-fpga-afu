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


// S100G reframer
// Re-frames 13/14-bit blocks into a 66-bit block
// Faisal - 02/22/017

`timescale 1 ps / 1 ps
module alt_e100s10_reframe (
    input           clk ,   
    input   [13:0]  din,
    input           phase,  // 10-bits on din
    output  [65:0]  dout,
    output  [65:0]  dout_sk
);


reg [65:0]  dout_r, dout_rr, dout_rrr;
reg load;
always @(posedge clk) begin

    if (~phase)
        dout_r  <=  {din[13:0], dout_r[65:14]} ;
     else
        dout_r  <=  {din[9:0], dout_r[65:10]};

    load    <=   phase;
    if (load)  begin // could be simplified
        dout_rr     <=  dout_r;
        dout_rrr    <=  dout_rr;
    end

end


assign dout = dout_r;
assign dout_sk = dout_rrr;


endmodule
