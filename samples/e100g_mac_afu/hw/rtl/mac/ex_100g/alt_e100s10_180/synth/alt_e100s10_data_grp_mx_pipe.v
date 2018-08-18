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


module alt_e100s10_data_grp_mx_pipe #(
  parameter SIM_EMULATE = 1'b0,
  parameter SEL_SIZE =1,
  parameter KR_REG_SIZE = 10,
  parameter ENABLE_ANLT = 0
) (
   input  clk_in,
   input  [263:0] data_0,
   input  [263:0] data_1,
   input  [263:0] data_2,
   output [263:0] data_out,
   input  sel

);

(* altera_attribute = "-name FORCE_HYPER_REGISTER_FOR_PERIPHERY_CORE_TRANSFER ON" *)
//reg [263:0] data_out_r[REG_OUT_SIZE - 1:0];
reg [263:0] data_out_r;//[REG_OUT_SIZE - 1:0];
wire [263:0] data_out_d;
genvar i;

generate
if (ENABLE_ANLT==0) begin
  
  alt_e100s10_mux2_t2_w264_s1 #(
  .SIM_EMULATE(SIM_EMULATE)
  ) mux_inst(
    .clk(clk_in),
    .din({data_0,data_1}),  // sel=0 takes from least significant word
    .sel(sel),
    .dout(data_out_d)
  );

end  
else begin
	
  alt_e100s10_mux2_t2_w264_s1 #(
  .SIM_EMULATE(SIM_EMULATE)
  ) mux_inst(
    .clk(clk_in),
    .din({data_2,data_0}),  // sel=0 takes from least significant word
    .sel(sel),
    .dout(data_out_d)
  );
  
end  
endgenerate

always@(posedge clk_in) begin
  data_out_r <= data_out_d;
end  

//assign data_out = data_out_r;
assign data_out = data_out_r;//[REG_OUT_SIZE-1];
  
endmodule
