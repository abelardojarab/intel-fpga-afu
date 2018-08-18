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


`timescale 1ps/1ps

// S10 5x1 registered mux
// Delay: 2 cycles
// Faisal Khan
// 11/02/2016


module  alt_e100s10_mux5t2 #(
    parameter   WIDTH = 13
) (
    input                       clk,
    input   [5*WIDTH - 1:0]     din,
    input   [2:0]               sel,
    output  reg [WIDTH-1:0]     dout
);


reg [WIDTH-1:0] din_r1, din_r0; /* syn_preserve_syn_only */
reg sel_r;
always @(posedge clk) begin
    case (sel[1:0])
        2'b00:  din_r0  <=  din[WIDTH-1:0];
        2'b01:  din_r0  <=  din[WIDTH*2-1:WIDTH];
        2'b10:  din_r0  <=  din[WIDTH*3-1:WIDTH*2];
        2'b11:  din_r0  <=  din[WIDTH*4-1:WIDTH*3];
    endcase
    din_r1   <=  din[WIDTH*5-1:WIDTH*4];
    sel_r   <= sel[2];
end


always @(posedge clk) begin
    if (sel_r)
        dout    <=  din_r1;
    else
        dout    <=  din_r0;
end

endmodule
