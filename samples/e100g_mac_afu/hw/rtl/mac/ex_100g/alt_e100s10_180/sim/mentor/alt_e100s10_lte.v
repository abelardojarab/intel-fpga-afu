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

// less than equal comparator
// latency = 3
// fkhan 10/09/2015

module alt_e100s10_lte (  // a <= b
    input           clk,
    input   [17:0]  dina,
    input   [17:0]  dinb,
    output  reg     lte
);

reg    [5:0] lt_w;
reg    [5:0] eq_w;
genvar i;
generate
    for (i=0; i<6; i=i+1) begin : tree
        always @(posedge clk) begin
            lt_w[i]    <=  (dina[(i+1)*3-1:i*3] < dinb[(i+1)*3-1:i*3]) ;
            eq_w[i]    <=  (dina[(i+1)*3-1:i*3] == dinb[(i+1)*3-1:i*3]) ;
        end
    end
endgenerate


reg lt_0, lt_1, lt_2, eq;
always @(posedge clk) begin
    lt_0  <=  lt_w[5] | (eq_w[5] & lt_w[4]) | (eq_w[5] & eq_w[4] & lt_w[3]) ; 
    lt_1  <= (eq_w[5] & eq_w[4] & eq_w[3] & lt_w[2]) | (eq_w[5] & eq_w[4] & eq_w[3] & eq_w[2] & lt_w[1]) ;
    lt_2  <= (eq_w[5] & eq_w[4] & eq_w[3] & eq_w[2] & eq_w[1] & lt_w[0]) ;
    eq <=  (eq_w[5] & eq_w[4] & eq_w[3] & eq_w[2] & eq_w[1] & eq_w[0] ); 

    lte <=  (lt_0 | lt_1 | lt_2) | eq ;
end

endmodule
// BENCHMARK INFO : Date : Sat Oct 10 00:17:52 2015
// BENCHMARK INFO : Quartus version : /data/fkhan/qshells/50g/acds/quartus/bin
// BENCHMARK INFO : benchmark P4 version: 16 
// BENCHMARK INFO : benchmark path: /tools/ipd_tools/1.24/linux64/bin
// BENCHMARK INFO : Total registers : 17
// BENCHMARK INFO : Total pins : 38
// BENCHMARK INFO : Total virtual pins : 0
// BENCHMARK INFO : Total block memory bits : 0
// BENCHMARK INFO : Number of LUT levels: Max 1.0 LUTs   Average 0.97
// BENCHMARK INFO : Number of Fitter seeds : 3
// BENCHMARK INFO : Device: 10AX115K4F36I3SG
// BENCHMARK INFO : ALM usage: 16
// BENCHMARK INFO : Combinational ALUT usage: 17
// BENCHMARK INFO : Fitter seed 1000: Worst setup slack @ 450 MHz : 1.270 ns, From eq_w[4], To lt_0 
// BENCHMARK INFO : Fitter seed 2234: Worst setup slack @ 450 MHz : 1.362 ns, From lt_0, To lte~reg0 
// BENCHMARK INFO : Fitter seed 3468: Worst setup slack @ 450 MHz : 1.142 ns, From lt_w[0], To lt_2 
// BENCHMARK INFO : Elapsed benchmark time: 2952.8 seconds
