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




// Registered 5x1 Mux in S10 using single ALM
// sel[0] => din[0]
// sel[1] => din[1]
// sel[2] => din[2]
// sel[4] => din[3]
// sel[6] => din[4]


// faisal - 02/14/2017

module alt_e100s10_mx5t1  (
    input   clk,
    input   [4:0]   din,
    input   [2:0]   sel,
    output  reg     dout
);

 
fourteennm_lcell_comb  comb (
                             .dataa     (sel[0]),     
                             .datab     (din[0]), 
                             .datac     (din[1]), 
                             .datad     (din[2]), 
                             .datae     (sel[1]), 
                             .dataf     (din[3]), 
                             .datag     (din[4]), 
                             .datah     (sel[2]), 
                             .cin       (1'b0),
                             .combout   (dout_w), 
                             .sumout    (),
                             .cout      (), 
                             // synthesis translate_off
                            .sharein(1'b0),  // does not exist in S10, but present in models for now
                            // synthesis translate_on
                             .shareout  ()
                            );
defparam comb .lut_mask = 64'h FF00F0F0FF00E4E4 ;
defparam comb .shared_arith = "off";
defparam comb .extended_lut = "on";


always @(posedge clk)   dout <= dout_w;

endmodule
