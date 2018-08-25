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



// baeckler - 9-03-2008
// pipeline for ack 

module alt_aeuex_ack_skid #(
	parameter WIDTH = 16
)
(
	input clk,
	
	input [WIDTH-1:0] dat_i,
	output ack_i,
	
	output reg [WIDTH-1:0] dat_o,
	input ack_o	
) /* synthesis ALTERA_ATTRIBUTE = "ALLOW_SYNCH_CTRL_USAGE=OFF" */;

initial dat_o = 0;

reg ack_i_r = 0 /* synthesis preserve_syn_only */;
reg ack_i_r_dupe = 0 /* synthesis preserve_syn_only */;
assign ack_i = ack_i_r;

reg [WIDTH-1:0] slush = 0;
reg slush_valid = 1'b0;

always @(posedge clk) begin
	ack_i_r <= ack_o;
	ack_i_r_dupe <= ack_o;
		
	if (ack_i_r_dupe) begin
		// taking input
		if (ack_o) begin
			if (slush_valid) begin
				slush <= dat_i;
				dat_o <= slush;
			end
			else begin
				dat_o <= dat_i;
			end
		end
		else begin
			// taking input not outputting
			slush <= dat_i;
			slush_valid <= 1'b1;
		end
	end	
	else begin
		// not taking input
		if (ack_o) begin
			// outputting, no new input
			if (slush_valid) begin
				dat_o <= slush;
				slush_valid <= 1'b0;
			end
			else begin
				// this happens when flushing, no slush available - call it slush
				dat_o <= slush;
				slush_valid <= 1'b0;
			end
		end
		else begin
			// not outputting
			// wait			
		end	
	end
	
end

endmodule
