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


// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/lib/alt_e100s10_status_sync.v#2 $
// $Revision: #2 $
// $Date: 2013/09/04 $
// $Author: jilee $
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps
// baeckler - 01-20-2010
// weak meta hardening intended for low toggle rate / low priority status signals

module alt_e100s10_status_sync #(
	parameter WIDTH = 32
)(
	input clk,
	input [WIDTH-1:0] din,
	output [WIDTH-1:0] dout
);

generate
genvar i;
for (i=0; i<WIDTH; i=i+1)
begin : sync
           alt_e100s10_altera_std_synchronizer_nocut #(
                .DEPTH(3),
                .RST_VALUE({WIDTH{1'b0}})
            )  synchronizer_nocut_inst  (
                .clk(clk),
                .reset_n(1'b1),
                .din(din[i]),
                .dout(dout[i])
            );
end
endgenerate

endmodule
