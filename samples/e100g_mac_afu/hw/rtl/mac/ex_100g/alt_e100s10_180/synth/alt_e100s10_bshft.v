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

// S10 100G Hybrid Barrel Shifter
// Faisal Khan
// 11/01/2016


module  alt_e100s10_bshft  (
            
        input           clk       , // pragma clock_port
        input   [3:0]   shft      ,
        input   [13:0]  din       ,
        input           din_hv    ,
        input           din_valid ,
        output  [13:0]  dout      ,
        output          dout_hv   ,
        output          dout_valid
);

reg [3:0] valid;
reg [3:0] hval;
always @(posedge clk) begin
    hval    <=  {hval[2:0] , din_hv};
    valid   <=  {valid[2:0], din_valid};
end

// input stage - bit aligner
reg [13+14-1:0] s1;
always @(posedge clk) begin
    if (hval[0])      s1  <=  { din[12:0], s1[13+:14] };
    else if (hval[1]) s1  <=  { din[13:0], s1[14+:13] };
    else              s1  <=  { din[13:0], s1[13+:13] };
end

// middle shift x4 stage
reg [14+4-1:0] s2;
always @(posedge clk) begin   
    case (shft[3:2])
        2'b00:  s2  <=  s1[0+:18];
        2'b01:  s2  <=  s1[4+:18];
        2'b10:  s2  <=  s1[8+:18];
        2'b11:  s2  <=  s1[12+:15];
        default: s2 <=  s1[0+:18];
    endcase
end


// final shift 1-3 stage
reg [13:0]  s3;
always @(posedge clk) begin
    case (shft[1:0])
        2'b00:  s3  <=  s2[0+:14];
        2'b01:  s3  <=  s2[1+:14];
        2'b10:  s3  <=  s2[2+:14];
        2'b11:  s3  <=  s2[3+:14];
        default:  s3  <=  s2[0+:14];
    endcase
end

assign  dout_valid   = valid[3];
assign  dout    = s3;
assign  dout_hv = hval[3];

endmodule

// BENCHMARK INFO : Date : Tue Feb 28 17:28:56 2017
// BENCHMARK INFO : Quartus version : /tools/acdskit/17.0/241/linux64/quartus/bin
// BENCHMARK INFO : benchmark P4 version: 18 
// BENCHMARK INFO : benchmark path: /data/fkhan/work/s100/walign
// BENCHMARK INFO : Number of LUT levels: Max 1.0 LUTs   Average 0.83
// BENCHMARK INFO : Number of Fitter seeds : 3
// BENCHMARK INFO : Device: 1SG280LU3F50I3VG
// BENCHMARK INFO : ALM usage: 50
// BENCHMARK INFO : Combinational ALUT usage: 55
// BENCHMARK INFO : Fitter seed 1000: Worst setup slack @ 450 MHz : 0.926 ns, From s1[24], To s2[12] 
// BENCHMARK INFO : Fitter seed 2234: Worst setup slack @ 450 MHz : 0.459 ns, From hval[0], To s1[7]~LAB_RE_X228_Y68_N0_I55_dff_Duplicate 
// BENCHMARK INFO : Fitter seed 3468: Worst setup slack @ 450 MHz : 0.919 ns, From hval[0], To s1[4] 
// BENCHMARK INFO : Elapsed benchmark time: 1598.0 seconds
