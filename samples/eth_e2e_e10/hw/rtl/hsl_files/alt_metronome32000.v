// Copyright 2016 Altera Corporation. All rights reserved.
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////


`timescale 1ps/1ps

// DESCRIPTION
// Generate one pulse every 32000 cycles.
// Generated by one of Gregg's toys.   Share And Enjoy.

module alt_metronome32000 #(
    parameter SIM_EMULATE = 1'b0
) (
	input clk, 
    input sclr,
	output dout
);

reg [14:0] sclrin = 15'b0;
reg [14:0] ripin = 15'b0;
reg [14:0] sum = 15'b0;

wire [14:0] sum_w;
wire [13:0] car_w;

reg sclr_r = 1'b0;

always @(posedge clk) begin
    ripin <= {car_w[13:0],1'b1};
end

always @(posedge clk) begin
    sclrin <= {sclrin[13:0],sclr_r};
end

always @(posedge clk) begin
    sum <= sum_w;
end

alt_lut6 s0 (
    .din({sum[0],ripin[0],sclrin[0],3'h0}),
    .dout(sum_w[0])
);
defparam s0 .MASK = 64'h000000ff00ff0000;
defparam s0 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c0 (
    .din({sum[0],ripin[0],4'h0}),
    .dout(car_w[0])
);
defparam c0 .MASK = 64'hffff000000000000;
defparam c0 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s1 (
    .din({sum[1],ripin[1],sclrin[1],3'h0}),
    .dout(sum_w[1])
);
defparam s1 .MASK = 64'h000000ff00ff0000;
defparam s1 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c1 (
    .din({sum[1],ripin[1],4'h0}),
    .dout(car_w[1])
);
defparam c1 .MASK = 64'hffff000000000000;
defparam c1 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s2 (
    .din({sum[2],ripin[2],sclrin[2],3'h0}),
    .dout(sum_w[2])
);
defparam s2 .MASK = 64'h000000ff00ff0000;
defparam s2 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c2 (
    .din({sum[2],ripin[2],4'h0}),
    .dout(car_w[2])
);
defparam c2 .MASK = 64'hffff000000000000;
defparam c2 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s3 (
    .din({sum[3],ripin[3],sclrin[3],3'h0}),
    .dout(sum_w[3])
);
defparam s3 .MASK = 64'h000000ff00ff0000;
defparam s3 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c3 (
    .din({sum[3],ripin[3],4'h0}),
    .dout(car_w[3])
);
defparam c3 .MASK = 64'hffff000000000000;
defparam c3 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s4 (
    .din({sum[4],ripin[4],sclrin[4],3'h0}),
    .dout(sum_w[4])
);
defparam s4 .MASK = 64'h000000ff00ff0000;
defparam s4 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c4 (
    .din({sum[4],ripin[4],4'h0}),
    .dout(car_w[4])
);
defparam c4 .MASK = 64'hffff000000000000;
defparam c4 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s5 (
    .din({sum[5],ripin[5],sclrin[5],3'h0}),
    .dout(sum_w[5])
);
defparam s5 .MASK = 64'h000000ff00ff0000;
defparam s5 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c5 (
    .din({sum[5],ripin[5],4'h0}),
    .dout(car_w[5])
);
defparam c5 .MASK = 64'hffff000000000000;
defparam c5 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s6 (
    .din({sum[6],ripin[6],sclrin[6],3'h0}),
    .dout(sum_w[6])
);
defparam s6 .MASK = 64'h000000ff00ff0000;
defparam s6 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c6 (
    .din({sum[6],ripin[6],4'h0}),
    .dout(car_w[6])
);
defparam c6 .MASK = 64'hffff000000000000;
defparam c6 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s7 (
    .din({sum[7],ripin[7],sclrin[7],3'h0}),
    .dout(sum_w[7])
);
defparam s7 .MASK = 64'h000000ff00ff0000;
defparam s7 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c7 (
    .din({sum[7],ripin[7],4'h0}),
    .dout(car_w[7])
);
defparam c7 .MASK = 64'hffff000000000000;
defparam c7 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s8 (
    .din({sum[8],ripin[8],sclrin[8],3'h0}),
    .dout(sum_w[8])
);
defparam s8 .MASK = 64'h000000ff00ff0000;
defparam s8 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c8 (
    .din({sum[8],ripin[8],4'h0}),
    .dout(car_w[8])
);
defparam c8 .MASK = 64'hffff000000000000;
defparam c8 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s9 (
    .din({sum[9],ripin[9],sclrin[9],3'h0}),
    .dout(sum_w[9])
);
defparam s9 .MASK = 64'h000000ff00ff0000;
defparam s9 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c9 (
    .din({sum[9],ripin[9],4'h0}),
    .dout(car_w[9])
);
defparam c9 .MASK = 64'hffff000000000000;
defparam c9 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s10 (
    .din({sum[10],ripin[10],sclrin[10],3'h0}),
    .dout(sum_w[10])
);
defparam s10 .MASK = 64'h000000ff00ff0000;
defparam s10 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c10 (
    .din({sum[10],ripin[10],4'h0}),
    .dout(car_w[10])
);
defparam c10 .MASK = 64'hffff000000000000;
defparam c10 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s11 (
    .din({sum[11],ripin[11],sclrin[11],3'h0}),
    .dout(sum_w[11])
);
defparam s11 .MASK = 64'h000000ff00ff0000;
defparam s11 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c11 (
    .din({sum[11],ripin[11],4'h0}),
    .dout(car_w[11])
);
defparam c11 .MASK = 64'hffff000000000000;
defparam c11 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s12 (
    .din({sum[12],ripin[12],sclrin[12],3'h0}),
    .dout(sum_w[12])
);
defparam s12 .MASK = 64'h000000ff00ff0000;
defparam s12 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c12 (
    .din({sum[12],ripin[12],4'h0}),
    .dout(car_w[12])
);
defparam c12 .MASK = 64'hffff000000000000;
defparam c12 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s13 (
    .din({sum[13],ripin[13],sclrin[13],3'h0}),
    .dout(sum_w[13])
);
defparam s13 .MASK = 64'h000000ff00ff0000;
defparam s13 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 c13 (
    .din({sum[13],ripin[13],4'h0}),
    .dout(car_w[13])
);
defparam c13 .MASK = 64'hffff000000000000;
defparam c13 .SIM_EMULATE = SIM_EMULATE;

alt_lut6 s14 (
    .din({sum[14],ripin[14],sclrin[14],3'h0}),
    .dout(sum_w[14])
);
defparam s14 .MASK = 64'h000000ff00ff0000;
defparam s14 .SIM_EMULATE = SIM_EMULATE;

wire eq_sclr;
alt_eqc15h7cfbt2 cmp0 (
    .clk(clk),
    .din(sum),
    .dout(eq_sclr)
);
defparam cmp0 .SIM_EMULATE = SIM_EMULATE;

always @(posedge clk) sclr_r <= eq_sclr | sclr;
assign dout = sclr_r;

endmodule
