module			dot_4_a10
(
	clk,
	en,
	running_sum,
	a1,
	a2,
	a3,
	a4,
	b1,
	b2,
	b3,
	b4,
	dot_2_result_1,
	dot_2_result_2,
	result
);


input						clk;
input						en;
input		[31:0]			running_sum;
input		[31:0]			a1;
input		[31:0]			a2;
input		[31:0]			a3;
input		[31:0]			a4;
input		[31:0]			b1;
input		[31:0]			b2;
input		[31:0]			b3;
input		[31:0]			b4;
output		[31:0]			result;
output		[31:0]			dot_2_result_1;
output		[31:0]			dot_2_result_2;

// Internal Wire

wire		[31:0]			dot_2_result_1;
wire		[31:0]			a3_delayed;
wire		[31:0]			b3_delayed;
wire		[31:0]			a4_delayed;
wire		[31:0]			b4_delayed;

// Instantiate Dot-2 Modules

acl_fp_dot2_a10			DOT_2_INST_1
(
	.running_sum	(running_sum),
    .a1				(a1),
    .a2				(a2),
    .b1				(b1),
    .b2				(b2),
    .clock			(clk),
    .enable			(en),
    .result			(dot_2_result_1)
);

//Instantiate the Param delay to match the latency of dot_2_result_1(6 cycle latency) with a3
param_delay	#
(
.DEPTH		(6),
.WIDTH		(32)
) DELAY_A3
(
	.clock		(clk),
	.reset		(),
	.data_in	(a3),
	.data_out   (a3_delayed)
);
//Instantiate the Param delay to match the latency of dot_2_result_1(6 cycle latency) with b3
param_delay		#
(
.DEPTH		(6),
.WIDTH		(32)
) DELAY_B3
(
	.clock		(clk),
	.reset		(),
	.data_in	(b3),
	.data_out   (b3_delayed)
);
//Instantiate the Param delay to match the latency 
param_delay		#
(
.DEPTH		(6),
.WIDTH		(32)
) DELAY_A4
(
	.clock		(clk),
	.reset		(),
	.data_in	(a4),
	.data_out   (a4_delayed)
);

//Instantiate the Param delay to match the latency of dot_2_result_1(6 cycle latency) with a3
param_delay		#
(
.DEPTH		(6),
.WIDTH		(32)
) DELAY_B4
(
	.clock		(clk),
	.reset		(),
	.data_in	(b4),
	.data_out   (b4_delayed)
);
//Instantiate Dot-2 Module
acl_fp_dot2_a10			DOT_2_INST_2
(
	.running_sum	(dot_2_result_1),
    .a1				(a3_delayed),
    .a2				(a4_delayed),
    .b1				(b3_delayed),
    .b2				(b4_delayed),
    .clock			(clk),
    .enable			(en),
    .result			(result)
);
endmodule