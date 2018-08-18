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

// S10 100G Word Delay
// Faisal Khan
// 11/01/2016

module  alt_e100s10_wdelay  #(
        parameter SIM_EMULATE = 1'b0
)(
        input               clk        ,
        input   [2:0]       delta      ,
        input   [14:0]      din        ,
        input               din_valid  ,
        output  reg [14:0]  dout       ,
        output  reg         dout_valid 
);



wire    [3:0]   raddr;
alt_e100s10_cnt4i rptr (
    .clk        (clk),
    .inc        (din_valid),
    .dout       (raddr)
);
defparam    rptr .SIM_EMULATE = SIM_EMULATE;

wire    [3:0]   waddr;
alt_e100s10_add4t1 wptr (
    .clk        (clk),
    .dina       (raddr),
    .dinb       ({1'b0,delta+2'h2}), 
    .dout       (waddr)
);

wire    [3:0]   noconnect;
wire    [14:0]  dout_w;
wire            dout_valid_w;
alt_e100s10_mlab mem (
    .wclk       (clk),
    .wena       (din_valid),
    .waddr_reg  (waddr),
    .wdata_reg  ({4'h0, din, din_valid}),
    .raddr      (raddr),
    .rdata      ({noconnect, dout_w, dout_valid_w}) 
);
defparam mem .WIDTH = 20;
defparam mem .ADDR_WIDTH = 4;
defparam mem .SIM_EMULATE = SIM_EMULATE;

always @(posedge clk)begin
    dout        <=  dout_w;
    dout_valid  <=  dout_valid_w;
end

endmodule

