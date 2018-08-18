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
// Faisal


module alt_e100s10_c4ilv #(
    parameter INSERT_SKEWS = 0, // SIM_ONLY
    parameter SKEW0 = 1,        // can be from 0 to 824 bits (~12.48 words external)
    parameter SKEW1 = 2,
    parameter SKEW2 = 3,
    parameter SKEW3 = 4,
    parameter SKEW4 = 5
)(
    input           clk,
    input           reset,  // deassert 1 cycle before din
    input   [65:0]  din,
    output  [65:0]  dout

);

reg [4:0]   schd;
always @(posedge clk) begin

    if (reset)
        schd    <=  5'b00001;
    else
        schd    <=  {schd[3:0], schd[4]} ;

end

reg [65:0]  d0, d1, d2, d3, d4, din_i;
wire    [13:0]  din0, din1, din2, din3, din4;

generate
if (INSERT_SKEWS == 1) begin : skew
    reg [66*15-1:0] din0_shft, din1_shft, din2_shft, din3_shft, din4_shft;
    reg [9:0] skew0 = SKEW0, skew1 = SKEW1, skew2 = SKEW2, skew3 = SKEW3, skew4 = SKEW4;
    always @(posedge clk) begin
        case (schd) 
            5'b10000:   begin  din0_shft <=  (din << (skew0)) | (din0_shft >> 66);      end
            5'b00001:   begin  din1_shft <=  (din << (skew1)) | (din1_shft >> 66);      end
            5'b00010:   begin  din2_shft <=  (din << (skew2)) | (din2_shft >> 66);      end
            5'b00100:   begin  din3_shft <=  (din << (skew3)) | (din3_shft >> 66);      end
            5'b01000:   begin  din4_shft <=  (din << (skew4)) | (din4_shft >> 66);      end
        endcase
    end
    always @(din0_shft or din1_shft or din2_shft or din3_shft or din4_shft) begin
        case (schd)
            5'b00001:   begin   din_i = din0_shft[0+:66];  end
            5'b00010:   begin   din_i = din1_shft[0+:66];  end
            5'b00100:   begin   din_i = din2_shft[0+:66];  end
            5'b01000:   begin   din_i = din3_shft[0+:66];  end
            5'b10000:   begin   din_i = din4_shft[0+:66];  end
        endcase
    end

end else begin
    always @(din)
       din_i = din;
end
endgenerate

always @(posedge clk) begin

    if (schd[0])
        d0  <=  din_i;
    else if (schd[1])
        d0  <=  d0 >> 14;
    else
        d0  <=  d0  >> 13;

end
assign  din0 = d0[13:0];

always @(posedge clk) begin

    if (schd[1])
        d1  <=  din_i;
    else if (schd[2])
        d1  <=  d1 >> 14;
    else
        d1  <=  d1  >> 13;

end
assign  din1 = d1[13:0];

always @(posedge clk) begin

    if (schd[2])
        d2  <=  din_i;
    else if (schd[3])
        d2  <=  d2 >> 14;
    else
        d2  <=  d2  >> 13;

end
assign  din2 = d2[13:0];

always @(posedge clk) begin

    if (schd[3])
        d3  <=  din_i;
    else if (schd[4])
        d3  <=  d3 >> 14;
    else
        d3  <=  d3  >> 13;

end
assign  din3 = d3[13:0];

always @(posedge clk) begin

    if (schd[4])
        d4  <=  din_i;
    else if (schd[0])
        d4  <=  d4 >> 14;
    else
        d4  <=  d4  >> 13;

end
assign  din4 = d4[13:0];

reg [2:0]   mschd;
always @(posedge clk) begin
    case (schd)
        5'b00001:    begin   mschd   <=  3'b000;  end
        5'b00010:    begin   mschd   <=  3'b001;  end
        5'b00100:    begin   mschd   <=  3'b010;  end
        5'b01000:    begin   mschd   <=  3'b100;  end
        5'b10000:    begin   mschd   <=  3'b110;  end
        default:     begin   mschd   <=  3'b000;  end
    endcase
end

wire    [13:0]  dout0, dout1, dout2, dout3, dout4;

alt_e100s10_mx5t1w m0 (
    .clk        (clk),
    .din        ({din4, din3, din2, din1, din0}),
    .sel        (mschd),
    .dout       (dout0)
);
defparam    m0 .WIDTH = 14;

alt_e100s10_mx5t1w m1 (
    .clk        (clk),
    .din        ({din0, din4, din3, din2, din1}),
    .sel        (mschd),
    .dout       (dout1)
);
defparam    m1 .WIDTH = 14;

alt_e100s10_mx5t1w m2 (
    .clk        (clk),
    .din        ({din1, din0, din4, din3, din2}),
    .sel        (mschd),
    .dout       (dout2)
);
defparam    m2 .WIDTH = 14;

alt_e100s10_mx5t1w m3 (
    .clk        (clk),
    .din        ({din2, din1, din0, din4, din3}),
    .sel        (mschd),
    .dout       (dout3)
);
defparam    m3 .WIDTH = 14;

alt_e100s10_mx5t1w m4 (
    .clk        (clk),
    .din        ({din3, din2, din1, din0, din4}),
    .sel        (mschd),
    .dout       (dout4)
);
defparam    m4 .WIDTH = 14;


genvar i;
generate
    for (i=0; i<13; i=i+1) begin : ilv
        assign   dout[i*5+:5]   = {dout4[i],dout3[i],dout2[i],dout1[i],dout0[i]};
    end
endgenerate

assign  dout[65] = dout0[13];

endmodule
