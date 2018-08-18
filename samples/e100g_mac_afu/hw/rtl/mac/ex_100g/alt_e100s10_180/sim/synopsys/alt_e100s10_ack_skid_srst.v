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


module alt_e100s10_ack_skid_srst #(
	parameter WIDTH = 16
)
(
	input clk,
    input srst,
	
	input [WIDTH-1:0] dat_i,
	output ack_i,
	
	output reg [WIDTH-1:0]  dat_o,
	input ack_o	
);

reg ack_reg_data = 0 /* synthesis preserve_syn_only */;
reg ack_reg_outp = 0 /* synthesis preserve_syn_only */;
reg ack_reg_flag = 0 /* synthesis preserve_syn_only */;

reg [WIDTH-1:0] slush_left  = 0;
reg [WIDTH-1:0] slush_right = 0;

always @(posedge clk) begin
    if (srst) begin
	  ack_reg_data <= 0; // Manually replicated ack signal for datapath use (timing opt)
	  ack_reg_outp <= 0; // Manually replicated ack signal for output   use (timing opt)
	  ack_reg_flag <= 0; // Manually replicated ack signal for dataflag use (timing opt)
	  slush_left[WIDTH-1:0]  <= 0;
	  slush_right[WIDTH-1:0] <= 0;
      dat_o <= 0;
  end
  else begin

	ack_reg_data <= ack_o; // Manually replicated ack signal for datapath use (timing opt)
	ack_reg_outp <= ack_o; // Manually replicated ack signal for output   use (timing opt)
	ack_reg_flag <= ack_o; // Manually replicated ack signal for dataflag use (timing opt)
	
	if (ack_reg_data) begin
		slush_left[WIDTH-1:4]  <= dat_i[WIDTH-1:4];
		slush_right[WIDTH-1:4] <= slush_left[WIDTH-1:4];
	end
	
	if (ack_reg_flag) begin
		slush_left[3:0]  <= dat_i[3:0];
		slush_right[3:0] <= slush_left[3:0];
	end

        case ({ack_o, ack_reg_data}) 
            2'b00 :  dat_o [WIDTH-1:4] <= slush_right [WIDTH-1:4] ; 
            2'b01 :  dat_o [WIDTH-1:4] <= slush_left  [WIDTH-1:4] ; 
            2'b10 :  dat_o [WIDTH-1:4] <= slush_left  [WIDTH-1:4] ; 
            2'b11 :  dat_o [WIDTH-1:4] <= dat_i       [WIDTH-1:4] ; 
        endcase
        
        case ({ack_o, ack_reg_flag}) 
            2'b00 :  dat_o [3:0] <= slush_right [3:0] ; 
            2'b01 :  dat_o [3:0] <= slush_left [3:0] ; 
            2'b10 :  dat_o [3:0] <= slush_left  [3:0] ; 
            2'b11 :  dat_o [3:0] <= dat_i       [3:0] ; 
       endcase
        
   end

end

assign ack_i = ack_reg_outp;

endmodule
