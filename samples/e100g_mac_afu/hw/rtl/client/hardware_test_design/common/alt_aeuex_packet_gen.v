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
// baeckler - 06-09-2010
// altera message_off 10199 10230
module alt_aeuex_packet_gen #(
	parameter WORDS = 2,
	parameter WIDTH = 64,
	parameter MORE_SPACING = 1'b1,
	parameter CNTR_PAYLOAD = 1'b0,
    parameter SOP_ON_LANE0 = 1'b0
)(
	input clk,
	input ena,
	input idle,
		
	output [WORDS-1:0] sop,
	output [WORDS*8-1:0] eop,
	output [WORDS*WIDTH-1:0] dout,
	
	output reg [WORDS*16-1:0] sernum
);

/////////////////////////////////////////////////
// build some semi reasonable random bits

reg [31:0] cntr = 0;
always @(posedge clk) begin
	if (ena) cntr <= cntr + 1'b1;
end

wire [31:0] poly0 = 32'h8000_0241;
reg [31:0] prand0 = 32'hffff_ffff;
always @(posedge clk) begin
	prand0 <= {prand0[30:0],1'b0} ^ ((prand0[31] ^ cntr[31]) ? poly0 : 32'h0);
end

wire [31:0] poly1 = 32'h8deadfb3;
reg [31:0] prand1 = 32'hffff_ffff;
always @(posedge clk) begin
	prand1 <= {prand1[30:0],1'b0} ^ ((prand1[31] ^ cntr[30]) ? poly1 : 32'h0);
end

reg [15:0] prand2 = 0;
always @(posedge clk) begin
	prand2 <= cntr[23:8] ^ prand0[15:0] ^ prand1[15:0];
end

// mostly 1
reg prand3 = 1'b0;
always @(posedge clk) begin
	prand3 <= |(prand0[17:16] ^ prand1[17:16] ^ cntr[25:24]);
end

/////////////////////////////////////////////////
// random sop and eop suggestions

reg [WORDS-1:0] sop0 = 0;
reg [WORDS*8-1:0] eop0 = 0;
reg [WORDS-1:0] nix0 = 0;

wire [WORDS-1:0] sop_prelim;
reg sop_ok;

//assign sop_prelim = (prand2[4:0] & prand2[15:11]);
assign sop_prelim = SOP_ON_LANE0 ? (|(prand2[4:0] & prand2[15:11]))<<(WORDS-1) :
                                   (prand2[4:0] & prand2[15:11]);

always @(*) begin
case (sop_prelim) 
		5'h0 : sop_ok = 1;
		5'h1 : sop_ok = 1;
		5'h2 : sop_ok = 1;
		5'h3 : sop_ok = 1;
		5'h4 : sop_ok = 1;
		5'h5 : sop_ok = 1;
		5'h6 : sop_ok = 1;
		5'h7 : sop_ok = 0;
		5'h8 : sop_ok = 1;
		5'h9 : sop_ok = 1;
		5'ha : sop_ok = 1;
		5'hb : sop_ok = 0;
		5'hc : sop_ok = 1;
		5'hd : sop_ok = 0;
		5'he : sop_ok = 0;
		5'hf : sop_ok = 0;
		5'h10 : sop_ok = 1;
		5'h11 : sop_ok = 1;
		5'h12 : sop_ok = 1;
		5'h13 : sop_ok = 0;
		5'h14 : sop_ok = 1;
		5'h15 : sop_ok = 0;
		5'h16 : sop_ok = 0;
		5'h17 : sop_ok = 0;
		5'h18 : sop_ok = 1;
		5'h19 : sop_ok = 0;
		5'h1a : sop_ok = 0;
		5'h1b : sop_ok = 0;
		5'h1c : sop_ok = 0;
		5'h1d : sop_ok = 0;
		5'h1e : sop_ok = 0;
		5'h1f : sop_ok = 0;			
		default : sop_ok = 0;		// LEDA		
	endcase	
	if(SOP_ON_LANE0) sop_ok = 1;
end

always @(posedge clk) begin
	sop0 <= idle ? {WORDS{1'b0}} : (sop_ok ? sop_prelim : {WORDS{1'b0}});
	eop0 <= (eop0 << 8);
	eop0 [prand2[7:5]] <= 1'b1;	
	nix0 <= (nix0 << 3) | prand2[10:8];
end

/////////////////////////////////////////////////
// make the SOP / EOP more sparse

reg [WORDS-1:0] sop1 = 0;
reg [WORDS*8-1:0] eop1 = 0;

wire [WORDS-1:0] eop_blackout = prand3 ? {WORDS{1'b1}} : (sop0 | nix0);
wire [WORDS*8-1:0] exp_eop_blackout;
wire [WORDS-1:0] any_eop1_w;
reg [WORDS-1:0] any_eop1 = 0;

genvar i;
generate 
	for (i=0; i<WORDS; i=i+1) begin : bo
		assign exp_eop_blackout[(i+1)*8-1:i*8] = {8{eop_blackout[i]}};
		assign any_eop1_w[i] = |eop0[(i+1)*8-1:i*8];
	end
endgenerate

always @(posedge clk) begin
	if (ena) begin
		// avoid start+end on same cycle - need revision for short packets! @@@
        if (SOP_ON_LANE0) 
            sop1 <= (MORE_SPACING && (|sop1)) ? {WORDS{1'b0}} : 
                    sop0 & ~nix0 & ~( |(eop0 & ~exp_eop_blackout) << (WORDS-1) );
        else
			sop1 <= (MORE_SPACING && (|sop1)) ? {WORDS{1'b0}} : sop0 & ~nix0;
		eop1 <= eop0 & ~exp_eop_blackout;		
		any_eop1 <= any_eop1_w & ~eop_blackout;
	end
end

/////////////////////////////////////////////////
// fixup the start/stop alternating pattern

wire [WORDS+1-1:0] pending;
reg [WORDS-1:0] pending_r = 0;
reg [WORDS-1:0] sop2 = 0;
reg [WORDS*8-1:0] eop2 = 0;

reg pending_wrap = 0;
generate 
	for (i=0; i<WORDS; i=i+1) begin : pd
		assign pending[i] = pending[i+1] ? ~any_eop1[i] : sop1[i];
	end
endgenerate

assign pending[WORDS] = pending_wrap;
always @(posedge clk) begin
	if (ena) begin
		pending_wrap <= pending[0];
		pending_r <= pending[WORDS-1:0];
		sop2 <= sop1;
		eop2 <= eop1;
	end
end

reg [WORDS-1:0] sop3 = 0;
reg [WORDS*8-1:0] eop3 = 0;
reg prev_0 = 1'b0;
wire [WORDS-1:0] prev_pending = {prev_0,pending_r[WORDS-1:1]};
wire [WORDS*8-1:0] exp_prev_pending;

generate 
	for (i=0; i<WORDS; i=i+1) begin : pp
		assign exp_prev_pending[(i+1)*8-1:i*8] = {8{prev_pending[i]}};
	end
endgenerate

always @(posedge clk) begin
	if (ena) begin
		prev_0 <= pending_r[0];
		sop3 <= sop2 & ~prev_pending;
		eop3 <= eop2 & exp_prev_pending;
	end
end

/////////////////////////////////////////////////
// figure out the payload
// First word is 6 byte dest address, choice of 5, then 2 byte serial number
// for that address.   Last word is fixed.  Middle is random junk.

reg [WORDS-1:0] sop4 = 0;
reg [WORDS*8-1:0] eop4 = 0;

always @(posedge clk) begin
	if (ena) begin
		sop4 <= sop3;
		eop4 <= eop3;
	end
end

reg [WIDTH-1:0] rjunk = 0;
always @(posedge clk) begin
	rjunk <= (rjunk << 4'hf) ^ prand2;
end


reg [WORDS*WIDTH-1:0] dout4 = 0;
initial sernum = 0;

// set of mac addresses to scatter through
wire [WORDS*6*8-1:0] mac_dest = {
	48'h0007ed_ff1234,
	48'hffffff_ffffff,
	48'h0007ed_ff0000,
	48'h123456_ff1234, 
	48'h00215a_bdde43	
};

//wire [WORDS*6*8-1:0] mac_dest = {
//	48'h00215a_bdde43,
//	48'h00215a_bdde43,
//	48'h00215a_bdde43,
//	48'h00215a_bdde43,
//	48'h00215a_bdde43	
//};

generate 
    reg [WIDTH-1:0] pcntr[WORDS-1:0];	// LEDA
	for (i=0; i<WORDS; i=i+1) begin : sy
		always @(posedge clk) begin
		    pcntr[i] <= 0;	// LEDA
            if (ena) begin
				if (sop3[i]) begin
					dout4[(i+1)*WIDTH-1:i*WIDTH] <= {
						mac_dest[(i+1)*8*6-1:i*8*6],
						sernum[(i+1)*16-1:i*16]
					};						
					sernum[(i+1)*16-1:i*16] <= sernum[(i+1)*16-1:i*16] + 1'b1;					
				end
				else if (|eop3[(i+1)*8-1:i*8]) begin
					dout4[(i+1)*WIDTH-1:i*WIDTH] <= "caboose.";
				end
				else begin
					if (CNTR_PAYLOAD) begin
						//dout4[(i+1)*WIDTH-1:i*WIDTH] <= pcntr;	// LEDA
						dout4[(i+1)*WIDTH-1:i*WIDTH] <= pcntr[i];
						//pcntr <= pcntr+1'b1;	//LEDA
						pcntr[i] <= pcntr[i]+1'b1;
					end	
					else begin
						dout4[(i+1)*WIDTH-1:i*WIDTH] <= rjunk;
					end					
				end								
			end
		end				
	end
endgenerate

assign sop = sop4;
assign eop = eop4;
assign dout = dout4;

endmodule
