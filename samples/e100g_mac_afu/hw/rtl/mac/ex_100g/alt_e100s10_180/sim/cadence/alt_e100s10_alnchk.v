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



// Faisal (03/2017)


`timescale 1 ps / 1 ps

module alt_e100s10_alnchk #(
    parameter   SIM_EMULATE = 1'b0
)(
    input           clk,
    input           clr,
    input           reset,
    input  [19:0]   etag,
    output          all_recd
);

//reg     reset_i;
//always @(posedge clk)   reset_i <=  reset | clr;

//wire any_ping;
//alt_e100s10_or20t2 or0 (   //CC-2
//    .clk        (clk),
//    .din        (etag),
//    .dout       (any_ping)
//);
//defparam    or0 .SIM_EMULATE = SIM_EMULATE;

//wire recent_ping;
//alt_e100s10_pulse64 ps0 (  // CC-3
//    .clk        (clk),
//    .din        (any_ping),
//    .dout       (recent_ping)
//);
//defparam ps0 .SIM_EMULATE = SIM_EMULATE;

//reg recent_ping_d1;
//always @(posedge clk) recent_ping_d1    <=  recent_ping;

reg [19:0]  am_r;
always @(posedge clk) begin  // CC-2
    if (reset | clr)
        am_r    <=  etag;
    else
        am_r    <=  am_r | etag;  
end

alt_e100s10_and20t2 a0 (  // CC-4
    .clk        (clk),
    .din        (am_r),
    .dout       (all_recd)
);
defparam a0 .SIM_EMULATE = SIM_EMULATE;

endmodule
