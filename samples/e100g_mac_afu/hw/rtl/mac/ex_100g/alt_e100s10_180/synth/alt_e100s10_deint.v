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

// S10 100 De-interleaver
// Faisal Khan
// 11/02/2016
// updated: 06/21/2017

module  alt_e100s10_deint (
    input               clk,  // pragma clock_port
    input   [65:0]      din,
    input               reset,
    input               din_valid,
    output  [5*14-1:0]  dout,
    output  reg         dout_valid = 1'b0,
    output  reg [4:0]   dout_hv,
    output  wire [2:0]   schd
);

reg [65:0] din_r;
always @(posedge clk) din_r <= din;
reg din_valid_r = 1'b0;
always @(posedge clk) din_valid_r <= din_valid;

reg [2:0]   schd_i, schd_c2;
always @(posedge clk) begin
    if (reset)
        schd_i    <=  3'h0;
    else if (din_valid_r) begin
        if (schd_i[2])
            schd_i    <=  3'h0;
        else
            schd_i   <=  schd_i + 1'b1;
    end
end

always @(posedge clk) begin
    schd_c2         <=  schd_i;
    dout_valid       <=  din_valid_r;
end
assign schd = schd_c2;

reg [2:0] schd_m;
always @(posedge clk) begin
    if (reset)
        schd_m  <=  3'h0;
    else if (din_valid_r) begin
        case (schd_m) 
            3'b000:    begin   schd_m   <=  3'b001;  end
            3'b001:    begin   schd_m   <=  3'b010;  end
            3'b010:    begin   schd_m   <=  3'b100;  end
            3'b100:    begin   schd_m   <=  3'b110;  end
            3'b110:    begin   schd_m   <=  3'b000;  end
            default:   begin   schd_m   <=  3'b000;  end
        endcase
    end
end

always @(posedge clk) begin
    case (schd_m)
        3'b000:     dout_hv <=  5'b00001;
        3'b001:     dout_hv <=  5'b00010;
        3'b010:     dout_hv <=  5'b00100;
        3'b100:     dout_hv <=  5'b01000;
        3'b110:     dout_hv <=  5'b10000;
        default:    dout_hv <=  5'b00001;
    endcase
end


wire  [13:0]    v0, v1, v2, v3, v4;
genvar i;
generate 
    for (i=0; i<13; i=i+1) begin : de
        assign v0[i]  = din_r[i*5];
        assign v1[i]  = din_r[i*5+1];
        assign v2[i]  = din_r[i*5+2];
        assign v3[i]  = din_r[i*5+3];
        assign v4[i]  = din_r[i*5+4];        
    end
    assign v0[13] = din_r[65];
    assign v1[13] = 0; assign v2[13] = 0; assign v3[13] = 0; assign v4[13] = 0;
endgenerate

wire    [13:0]  dout0, dout1, dout2, dout3, dout4;
alt_e100s10_mx5t1w d0 (
    .clk            (clk),
    .din            ({v1,v2,v3,v4,v0}),
    .sel            (schd_m),
    .dout           (dout0)
);
defparam d0 .WIDTH = 14;

alt_e100s10_mx5t1w d1 (
    .clk            (clk),
    .din            ({v2,v3,v4,v0,v1}),
    .sel            (schd_m),
    .dout           (dout1)
);
defparam d1 .WIDTH = 14;

alt_e100s10_mx5t1w d2 (
    .clk            (clk),
    .din            ({v3,v4,v0,v1,v2}),
    .sel            (schd_m),
    .dout           (dout2)
);
defparam d2 .WIDTH = 14;


alt_e100s10_mx5t1w d3 (
    .clk            (clk),
    .din            ({v4,v0,v1,v2,v3}),
    .sel            (schd_m),
    .dout           (dout3)
);
defparam d3 .WIDTH = 14;


alt_e100s10_mx5t1w d4 (
    .clk            (clk),
    .din            ({v0,v1,v2,v3,v4}),
    .sel            (schd_m),
    .dout           (dout4)
);
defparam d4 .WIDTH = 14;




assign dout = {dout4, dout3, dout2, dout1, dout0};

endmodule

// BENCHMARK INFO : Date : Wed Jun 21 19:49:21 2017
// BENCHMARK INFO : Quartus version : /tools/acdskit/17.1/121/linux64/quartus/bin
// BENCHMARK INFO : benchmark P4 version: 17 
// BENCHMARK INFO : benchmark path: /data/fkhan/work/s100
// BENCHMARK INFO : Number of LUT levels: Max 1.0 LUTs   Average 0.51
// BENCHMARK INFO : Number of Fitter seeds : 1
// BENCHMARK INFO : Device: 1SG280LU3F50I3VG
// BENCHMARK INFO : ALM usage: 64 (excluding ALMs used by virtual I/O pins)
// BENCHMARK INFO : Combinational ALUT usage: 82
// BENCHMARK INFO : Fitter seed 1000: Worst setup slack @ 450 MHz : 0.768 ns, From schd_m[0], To d3|dout[10] 
// BENCHMARK INFO : Elapsed benchmark time: 543.4 seconds
