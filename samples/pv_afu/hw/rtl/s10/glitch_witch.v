// baeckler -06-02-2017

module glitch_witch (
	input clk,
	input ena,
	input sclr,
	input sclr_err,
	output dout,
	output sticky_err
);

localparam NUM_CHAN = 200;
localparam ADD_BITS = 6;
localparam SIM_EMULATE = 1'b0;

///////////////////////////////////////////////////////
// adder rings feeding XORs
///////////////////////////////////////////////////////

reg ena_r = 1'b0 /* synthesis preserve */;
reg [ADD_BITS-1:0] ena_rr = {ADD_BITS{1'b0}} /* synthesis preserve */;
always @(posedge clk) ena_r <= ena;
always @(posedge clk) ena_rr <= {ADD_BITS{ena_r}};

wire [NUM_CHAN-1:0] mixed;
wire [(ADD_BITS*NUM_CHAN)-1:0] volatile;

genvar i;
generate
	for (i=0; i<NUM_CHAN; i=i+1) begin : lp0
		wire [ADD_BITS-1:0] silly_add = ena_rr + {{(ADD_BITS-1){1'b0}},silly_add[ADD_BITS-1]};

		intc_lut6 m2 (.din(silly_add),.dout(mixed[i]));
		defparam m2 .MASK = 64'h6996966996696996;
		defparam m2 .SIM_EMULATE = SIM_EMULATE;		
		
		assign volatile [(i+1)*ADD_BITS-1:i*ADD_BITS] = silly_add;
	end
endgenerate

///////////////////////////////////////////////////////
// comb multipliers feeding XORs
///////////////////////////////////////////////////////

wire [(NUM_CHAN/4)-1:0] mixed2;
generate
	for (i=0; i<NUM_CHAN/4; i=i+1) begin : lp1
		wire [ADD_BITS-1:0] p0,p1,p2,p3;
		assign {p0,p1,p2,p3} = volatile[(i+1)*(4*ADD_BITS)-1:i*(4*ADD_BITS)];

		wire [4*ADD_BITS-1:0] loco;
		assign loco = {p3,p2} * {p1,p0};
		assign mixed2[i] = ^loco;
	end
endgenerate

///////////////////////////////////////////////////////
// merge outputs
///////////////////////////////////////////////////////

reg dout_r;
always @(posedge clk) dout_r <= (^mixed) ^ (^mixed2);
assign dout = dout_r;

///////////////////////////////////////////////////////
// integrity check
///////////////////////////////////////////////////////

localparam CHECK_DECKS = 4;
localparam CHECKERS = 16;

wire [CHECK_DECKS-1:0] deck_sticky_err;

genvar j;
generate
	for (j=0; j<CHECK_DECKS; j=j+1) begin : lp5
		wire [CHECKERS-1:0] sclr_err_r;
		wire [CHECKERS-1:0] sclr_r;

		reg deck_sclr = 1'b0 /* synthesis preserve */; 
		reg deck_sclr_err = 1'b0 /* synthesis preserve */; 
		always @(posedge clk) begin
			deck_sclr <= sclr;
			deck_sclr_err <= sclr_err;
		end
		
		intc_spread32_t8 sp0 (
			.clk(clk),
			.din(deck_sclr),
			.dout(sclr_r)
		);

		intc_spread32_t8 sp1 (
			.clk(clk),
			.din(deck_sclr_err),
			.dout(sclr_err_r)
		);

		wire [CHECKERS-1:0] sticky_err_rom;
		wire [CHECKERS-1:0] sticky_err_lfsr;
		wire [CHECKERS-1:0] sticky_err_i;

		for (i=0; i<CHECKERS; i=i+1) begin : lp2
			bully_bully1 bb0 (
				.clk(clk),
				.sclr(sclr_r[i]),
				.sclr_err(sclr_err_r[i]),
				.sticky_err(sticky_err_lfsr[i])
			);
			
			redrom rr0 (
				.clk(clk),
				.sclr_err(sclr_err_r[i]),
				.sticky_err(sticky_err_rom[i])
			);
			
			reg mixed_err = 1'b0;
			always @(posedge clk) mixed_err <= sticky_err_lfsr[i] | sticky_err_rom[i];
			
			assign sticky_err_i[i] = mixed_err;
		end
	
		intc_or32_t8 seor (
			.clk(clk),
			.din(sticky_err_i),
			.dout(deck_sticky_err[j])
		);
	end
endgenerate

intc_or8_t2 seor (
	.clk(clk),
	.din(deck_sticky_err),
	.dout(sticky_err)
);

endmodule
