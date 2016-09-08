// (C) 1992-2014 Altera Corporation. All rights reserved.                         
// Your use of Altera Corporation's design tools, logic functions and other       
// software and tools, and its AMPP partner logic functions, and any output       
// files any of the foregoing (including device programming or simulation         
// files), and any associated documentation or information are expressly subject  
// to the terms and conditions of the Altera Program License Subscription         
// Agreement, Altera MegaCore Function License Agreement, or other applicable     
// license agreement, including, without limitation, that your use is for the     
// sole purpose of programming logic devices manufactured by Altera and sold by   
// Altera or its authorized distributors.  Please refer to the applicable         
// agreement for further details.                                                 
    


module acl_fp_dot2_a10(running_sum, a1, b1, a2, b2, clock, enable, result);
// Latency 6, 2-element vector dot product.
input [31:0] running_sum;
input   [31:0] a1;
input   [31:0] a2;
input   [31:0] b1;
input   [31:0] b2;
input clock;
input enable;
output [31:0] result;

wire [31:0] ab;
wire [3:0] ab_flags;

// FP MAC wysiwyg
twentynm_fp_mac mac_fp_wys_01 (
    // inputs
    .accumulate(),
    .chainin_overflow(),
    .chainin_invalid(),
    .chainin_underflow(),
    .chainin_inexact(),
    .ax(running_sum),
    .ay(a1),
    .az(b1),
    .clk({2'b00,clock}),
    .ena({2'b11,enable}),
    .aclr(2'b00),
    .chainin(),
    // outputs
    .overflow(),
    .invalid(),
    .underflow(),
    .inexact(),
    .chainout_overflow(ab_flags[3]),
    .chainout_invalid(ab_flags[2]),
    .chainout_underflow(ab_flags[1]),
    .chainout_inexact(ab_flags[0]),
    .resulta(),
    .chainout(ab)
);
defparam mac_fp_wys_01.operation_mode = "sp_mult_add"; 
defparam mac_fp_wys_01.use_chainin = "false"; 
defparam mac_fp_wys_01.adder_subtract = "false"; 
defparam mac_fp_wys_01.ax_clock = "0"; 
defparam mac_fp_wys_01.ay_clock = "0"; 
defparam mac_fp_wys_01.az_clock = "0"; 
defparam mac_fp_wys_01.output_clock = "0"; 
defparam mac_fp_wys_01.accumulate_clock = "none"; 
defparam mac_fp_wys_01.ax_chainin_pl_clock = "0"; 
defparam mac_fp_wys_01.accum_pipeline_clock = "none"; 
defparam mac_fp_wys_01.mult_pipeline_clock = "0"; 
defparam mac_fp_wys_01.adder_input_clock = "0"; 
defparam mac_fp_wys_01.accum_adder_clock = "none"; 

// FP MAC wysiwyg
// Pipeline datac and datad by 2 cycles.

reg [31:0] d1;
reg [31:0] d2;
reg [31:0] c1;
reg [31:0] c2;

always@(posedge clock)
begin
  if (enable)
  begin
    d1 <= a2;
    d2 <= d1;
    c1 <= b2;
    c2 <= c1;
  end
end

twentynm_fp_mac mac_fp_wys_02 (
    // inputs
    .accumulate(),
    .chainin_overflow(ab_flags[3]),
    .chainin_invalid(ab_flags[2]),
    .chainin_underflow(ab_flags[1]),
    .chainin_inexact(ab_flags[0]),
    .ax(),
    .ay(c2),
    .az(d2),
    .clk({2'b00,clock}),
    .ena({2'b11,enable}),
    .aclr(2'b00),
    .chainin(ab),
    // outputs
    .overflow(),
    .invalid(),
    .underflow(),
    .inexact(),
    .chainout_overflow(),
    .chainout_invalid(),
    .chainout_underflow(),
    .chainout_inexact(),
      .resulta(result),
    .chainout()
);
defparam mac_fp_wys_02.operation_mode = "sp_mult_add"; 
defparam mac_fp_wys_02.use_chainin = "true"; 
defparam mac_fp_wys_02.adder_subtract = "false"; 
defparam mac_fp_wys_02.ax_clock = "none"; 
defparam mac_fp_wys_02.ay_clock = "0"; 
defparam mac_fp_wys_02.az_clock = "0"; 
defparam mac_fp_wys_02.output_clock = "0"; 
defparam mac_fp_wys_02.accumulate_clock = "none"; 
defparam mac_fp_wys_02.ax_chainin_pl_clock = "none"; 
defparam mac_fp_wys_02.accum_pipeline_clock = "none"; 
defparam mac_fp_wys_02.mult_pipeline_clock = "0"; 
defparam mac_fp_wys_02.adder_input_clock = "0"; 
defparam mac_fp_wys_02.accum_adder_clock = "none"; 

endmodule
