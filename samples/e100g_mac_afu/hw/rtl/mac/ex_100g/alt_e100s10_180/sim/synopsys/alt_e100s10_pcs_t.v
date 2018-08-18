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


/////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps
// faisal 

module alt_e100s10_pcs_t #(
    parameter SIM_EMULATE = 1'b0,
    parameter SIM_SHORT_AM = 1'b0,
    parameter SYNOPT_C4_RSFEC = 1'b0,
    parameter ENABLE_ANLT     = 1'b0
    //parameter CREATE_TX_SKEW = 1'b0
)(
    input clk,
    input reset,
    input enable_rsfec, 
    input [64*4-1:0] din_d, 
    input [8*4-1:0] din_c, 
    input din_am,
    
    //output pre_din_am, // advance warning
    //input tx_crc_ins_en,
	    
    output [66*4-1:0] dout, // lsbit first serial streams
    output dout_valid       // one cycle early
);

localparam  WORDS = 4;
genvar i;



////////////////////////////////////////////////////
// mii->66 block encode

wire [4*66-1:0] din_e;

generate 
	for (i=0; i<4; i=i+1) begin : e
		alt_e100s10_ethenc enc (
		    .clk    (clk), 
		    .din_c  (din_c[(i+1)*8-1:i*8]),
		    .din_d  (din_d[(i+1)*64-1:i*64]), // bit 0 first
		    .dout   (din_e[(i+1)*66-1:i*66])
		);
		defparam enc .SIM_EMULATE = SIM_EMULATE;
	end
endgenerate


wire din_e_am;
alt_e100s10_delay_regs dr1 (
	.clk    (clk),
	.din    (din_am),
	.dout   (din_e_am)
);
defparam dr1 .WIDTH = 1;
defparam dr1 .LATENCY = 4;


////////////////////////////////////////////////////
// scrambler - framing bypass

wire [2*WORDS-1:0] enc_frame_lag;
wire [64*WORDS-1:0] enc_data;	
	
alt_e100s10_unframe uf ( // need a different one
	.clk            (clk),
	.din            (din_e),
	.dout_frame_lag (enc_frame_lag),
	.dout_data      (enc_data)	
);
defparam uf .LATENCY = 2;

wire [WORDS*64-1:0] scram_data;
wire                dout_s_am;
alt_e100s10_scram256 sc (
    .clk            (clk),
    .din_valid      (!din_e_am),
    .din            (enc_data),        // bit 0 is to be sent first
    .dout           (scram_data),
    .dout_valid     (dout_s_am)
);
defparam sc .SIM_EMULATE = SIM_EMULATE;

wire [WORDS*66-1:0] din_es;
alt_e100s10_refram rf ( 
	.din_data   (scram_data),
	.din_frame  (enc_frame_lag),
	.dout       (din_es)	
);
defparam rf .WORDS = WORDS;


generate
if (SYNOPT_C4_RSFEC == 0) begin : PCS

////////////////////////////////////////////////////
// vlane tag + bip

wire reset_d;
alt_e100s10_delay_regs dr6 (
	.clk(clk),
	.din(reset),
	.dout(reset_d)
);
defparam dr6 .WIDTH = 1;
defparam dr6 .LATENCY = 5;  // updating the latency from 4 to account for +1 in scrambler - Check the tagger

wire [WORDS*66-1:0] din_est;
	for (i=0; i<WORDS; i=i+1) begin : tl
		alt_e100s10_tx_tagger_5way et (
			.clk(clk),
			.sclr(reset_d),  // this will regulate the order the tags are used in the TX round robin
			.din(din_es[(i+1)*66-1:i*66]),
			.am_insert(~dout_s_am),  // discard the din, insert alignment
			.dout(din_est[(i+1)*66-1:i*66])
		);
		defparam et .VLANE_SET = i;
	end

reg [3:0] reset_p;
always @(posedge clk) reset_p <= {reset_p[2:0], reset_d};


// Seprating out VLs, Shifting and Interleaving of VLs
	for (i=0; i<WORDS; i=i+1) begin : il

            alt_e100s10_c4ilv ilv(
                .clk        (clk),
                .reset      (reset_p[1]),
                .din        (din_est[66*i+:66]),
                .dout       (dout[66*i+:66])
            );
        end

assign dout_valid = ~reset_p[2];    //  one cycle early

end
else if (SYNOPT_C4_RSFEC == 1'b1 && ENABLE_ANLT == 1'b0) begin : DYN_FEC_PCS

wire reset_d;
wire reset_d_no_rsfec;
wire reset_d_rsfec;

alt_e100s10_delay_regs dr6_no_rsfec (
	.clk(clk),
	.din(reset),
	.dout(reset_d_no_rsfec)
);
defparam dr6_no_rsfec .WIDTH = 1;
defparam dr6_no_rsfec .LATENCY = 5;  // updating the latency from 4 to account for +1 in scrambler - Check the tagger

alt_e100s10_delay_regs dr6_rsfec (
	.clk(clk),
	.din(reset),
	.dout(reset_d_rsfec)
); 
defparam dr6_rsfec .WIDTH = 1;
defparam dr6_rsfec .LATENCY = 4;  // updating the latency from 4 to account for +1 in scrambler - Check the tagger

assign reset_d = (enable_rsfec == 1) ? reset_d_rsfec : reset_d_no_rsfec;

wire [WORDS*66-1:0] din_est;
for (i=0; i<WORDS; i=i+1) begin : tl
	alt_e100s10_tx_tagger_5way et (
	.clk(clk),
	.sclr(reset_d),  // this will regulate the order the tags are used in the TX round robin
	.din(din_es[(i+1)*66-1:i*66]),
	.am_insert(~dout_s_am),  // discard the din, insert alignment
	.dout(din_est[(i+1)*66-1:i*66])
	);
	defparam et .VLANE_SET = i;
end

reg  [3:0] reset_p;
always @(posedge clk) reset_p <= {reset_p[2:0], reset_d};

// Seprating out VLs, Shifting and Interleaving of VLs
wire [66*4-1:0] dout_no_rsfec;

for (i=0; i<WORDS; i=i+1) begin : il
alt_e100s10_c4ilv ilv(
   .clk        (clk),
   .reset      (reset_p[1]),
   .din        (din_est[66*i+:66]),
   .dout       (dout_no_rsfec[66*i+:66])
);
end


//assign  dout       =   din_es;
//assign  dout_valid =   dout_s_am;   // !valid => Alignment cycle, alvin-org
wire  dout_valid_p =   dout_s_am;   // !valid => Alignment cycle, alvin-new

/*alvin */
reg   dout_valid_p3, dout_valid_p2, dout_valid_p1;

always @(posedge clk) begin
dout_valid_p1 <= dout_valid_p;
dout_valid_p2 <= dout_valid_p1;
dout_valid_p3 <= dout_valid_p2;
end

assign dout       = (enable_rsfec == 1) ? din_est       : dout_no_rsfec;
assign dout_valid = (enable_rsfec == 1) ? dout_valid_p3 : ~reset_p[2];

end else begin: FEC_PCS
//assign  dout       =   din_es;
//assign  dout_valid =   dout_s_am;   // !valid => Alignment cycle, alvin-org
wire  dout_valid_p =   dout_s_am;   // !valid => Alignment cycle, alvin-new

/*alvin */
reg   dout_valid_p3, dout_valid_p2, dout_valid_p1;

always @(posedge clk) begin
dout_valid_p1 <= dout_valid_p;
dout_valid_p2 <= dout_valid_p1;
dout_valid_p3 <= dout_valid_p2;
end

assign dout_valid = dout_valid_p3;

wire reset_d;
alt_e100s10_delay_regs dr6 (
	.clk(clk),
	.din(reset),
	.dout(reset_d)
);
defparam dr6 .WIDTH = 1;
defparam dr6 .LATENCY = 4;  // updating the latency from 4 to account for +1 in scrambler - Check the tagger


wire [WORDS*66-1:0] din_est;
	for (i=0; i<WORDS; i=i+1) begin : tl
		alt_e100s10_tx_tagger_5way et (
			.clk(clk),
			.sclr(reset_d),  // this will regulate the order the tags are used in the TX round robin
			.din(din_es[(i+1)*66-1:i*66]),
			.am_insert(~dout_s_am),  // discard the din, insert alignment
			.dout(din_est[(i+1)*66-1:i*66])
		);
		defparam et .VLANE_SET = i;
	end

assign dout = din_est;
	
end	
endgenerate



endmodule


