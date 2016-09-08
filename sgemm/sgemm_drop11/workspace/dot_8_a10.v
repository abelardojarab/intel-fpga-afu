module					dot_8_a10
(
	clk,
	en,
	running_sum,
	a1,
	a2,
	a3,
	a4,
	a5,
	a6,
	a7,
	a8,
	b1,
	b2,
	b3,
	b4,
	b5,
	b6,
	b7,
	b8,
	result
);

input								clk;
input								en;
input			[31:0]			running_sum;
input			[31:0]			a1;
input			[31:0]			a2;
input			[31:0]			a3;
input			[31:0]			a4;
input			[31:0]			a5;
input			[31:0]			a6;
input			[31:0]			a7;
input			[31:0]			a8;
input			[31:0]			b1;
input			[31:0]			b2;
input			[31:0]			b3;
input			[31:0]			b4;
input			[31:0]			b5;
input			[31:0]			b6;
input			[31:0]			b7;
input			[31:0]			b8;

output			[31:0]			result;

//Internal Wires

wire			[31:0]			dot_4_result_1;
wire			[31:0]			a5_delayed;
wire			[31:0]			a6_delayed;
wire			[31:0]			a7_delayed;
wire			[31:0]			a8_delayed;
wire			[31:0]			b5_delayed;
wire			[31:0]			b6_delayed;
wire			[31:0]			b7_delayed;
wire			[31:0]			b8_delayed;

dot_4_a10			DOT_4_INST_1
(
	.clk				(clk),
    .en					(en),
    .running_sum		(running_sum),
    .a1					(a1),
    .a2					(a2),
    .a3					(a3),
    .a4					(a4),
    .b1					(b1),
    .b2					(b2),
    .b3					(b3),
    .b4					(b4),
    .dot_2_result_1		(),
    .dot_2_result_2		(),
    .result				(dot_4_result_1)
);
//Delay a5,a6,a7,a8 by 12 cycles
param_delay	#
(
.DEPTH		(12),
.WIDTH		(32)
) DELAY_A5
(
	.clock		(clk),
	.reset		(),
	.data_in	(a5),
	.data_out   (a5_delayed)
);
param_delay	#
(
.DEPTH		(12),
.WIDTH		(32)
) DELAY_A6
(
	.clock		(clk),
	.reset		(),
	.data_in	(a6),
	.data_out   (a6_delayed)
);
param_delay	#
(
.DEPTH		(12),
.WIDTH		(32)
) DELAY_A7
(
	.clock		(clk),
	.reset		(),
	.data_in	(a7),
	.data_out   (a7_delayed)
);
param_delay	#
(
.DEPTH		(12),
.WIDTH		(32)
) DELAY_A8
(
	.clock		(clk),
	.reset		(),
	.data_in	(a8),
	.data_out   (a8_delayed)
);
//Delay b5,b6,b7,b8 by 12 cycles
param_delay	#
(
.DEPTH		(12),
.WIDTH		(32)
) DELAY_B5
(
	.clock		(clk),
	.reset		(),
	.data_in	(b5),
	.data_out   (b5_delayed)
);
param_delay	#
(
.DEPTH		(12),
.WIDTH		(32)
) DELAY_B6
(
	.clock		(clk),
	.reset		(),
	.data_in	(b6),
	.data_out   (b6_delayed)
);
param_delay	#
(
.DEPTH		(12),
.WIDTH		(32)
) DELAY_B7
(
	.clock		(clk),
	.reset		(),
	.data_in	(b7),
	.data_out   (b7_delayed)
);
param_delay	#
(
.DEPTH		(12),
.WIDTH		(32)
) DELAY_B8
(
	.clock		(clk),
	.reset		(),
	.data_in	(b8),
	.data_out   (b8_delayed)
);


dot_4_a10			DOT_4_INST_2
(
	.clk				(clk),
	.en					(en),
	.running_sum		(dot_4_result_1),
    .a1					(a5_delayed),
    .a2					(a6_delayed),
    .a3					(a7_delayed),
    .a4					(a8_delayed),
    .b1					(b5_delayed),
    .b2					(b6_delayed),
    .b3					(b7_delayed),
    .b4					(b8_delayed),
    .dot_2_result_1		(),
    .dot_2_result_2		(),
    .result				(result)
);
endmodule