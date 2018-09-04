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


// (C) 2001-2017 Intel Corporation. All rights reserved.
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


// (C) 2001-2017 Intel Corporation. All rights reserved.
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


// (C) 2001-2017 Intel Corporation. All rights reserved.
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


// altera message_off 10236
module stats_counter #(
    parameter WIDTH     = 64,
    parameter HS_WIDTH  = 5
) (
    input               csr_clk,
    input               csr_clear,
    output [WIDTH-1:0]  count,

    input               incr_clk,
    input               incr_count
);

    // Increment high-speed count
    wire [HS_WIDTH-1:0] hs_count;
    wire hs_clear;
    counter #(
        .WIDTH  (HS_WIDTH)
    ) hs_counter (
        .clk    (incr_clk),
        .incr   (incr_count),
        .clr    (hs_clear),
        .count  (hs_count)
    );

    // Get high-speed count
    wire [HS_WIDTH-1:0] local_count;
    wire count_valid;
    get_count_and_clear #(
        .WIDTH      (HS_WIDTH)
    ) gc_clr (
        .clk_in     (incr_clk),
        .count_in   (hs_count),
        .clr_count  (hs_clear),

        .clk_out    (csr_clk),
        .count_out  (local_count),
        .valid      (count_valid)
    );

    // Increment csr count
    accumulator #(
        .WIDTH      (WIDTH)
    ) acmlr (
        .clk        (csr_clk),
        .clr        (csr_clear),
        .accumulate (count_valid),
        .count_in   ({{(WIDTH-HS_WIDTH){1'b0}}, local_count}),
        .total      (count)
    );
endmodule

module accumulator #(
    parameter WIDTH = 8
) (
    input                  clk,
    input                  clr,
    input                  accumulate,
    input      [WIDTH-1:0] count_in,
    output reg [WIDTH-1:0] total
);

    always @(posedge clk) begin
        if (accumulate) begin
            if (clr) begin
                total <= count_in;
            end else begin
                total <= total + count_in;
            end
        end else begin
            if (clr) begin
                total <= 'd0;
            end else begin
                total <= total;
            end
        end
    end
endmodule

module get_count_and_clear #(
    parameter WIDTH = 8
) (
    input              clk_in,
    input  [WIDTH-1:0] count_in,
    input              clk_out,
    output reg [WIDTH-1:0] count_out,
    output reg              clr_count,
    output reg         valid
);

    wire data_ack_sync;
    reg data_ack;
    wire data_valid_sync;
    reg data_valid;

    localparam IN_STATE_CLEAR       = 0,
               IN_STATE_VALID       = 1,
               IN_STATE_WAIT_ACK    = 2,
               IN_STATE_NOT_VALID   = 3,
               IN_STATE_WAIT_DEACK  = 4;

    reg [2:0] in_state;
    reg [WIDTH-1:0] count_in_reg;
    
    alt_e100s10_synchronizer ack_sync (
        .clk    (clk_in),
        .din    (data_ack),
        .dout   (data_ack_sync)
    );

    always @(posedge clk_in) begin
        data_valid <= 1'b0;
        count_in_reg <= count_in_reg;
        in_state <= in_state;
        clr_count <= 1'b0;
        case (in_state)
            IN_STATE_CLEAR: begin
                clr_count <= 1'b1;
                in_state <= IN_STATE_VALID;
            end
            IN_STATE_VALID: begin
                data_valid <= 1'b1;
                count_in_reg <= count_in;
                in_state <= IN_STATE_WAIT_ACK;
            end
            IN_STATE_WAIT_ACK: begin
                data_valid <= 1'b1;
                if (data_ack_sync) in_state <= IN_STATE_NOT_VALID;
            end
            IN_STATE_NOT_VALID: begin
                if (!data_ack_sync) in_state <= IN_STATE_CLEAR;
            end
            default: in_state <= IN_STATE_CLEAR;
        endcase
    end

    localparam OUT_STATE_WAIT_VALID     = 0,
               OUT_STATE_WAIT_NOT_VALID = 1;
    reg [1:0] out_state;

    alt_e100s10_synchronizer valid_sync (
        .clk    (clk_in),
        .din    (data_valid),
        .dout   (data_valid_sync)
    );

    always @(posedge clk_out) begin
        out_state <= out_state;
        count_out <= count_out;
        data_ack  <= 1'b0;
        valid <= 1'b0;
        case (out_state)
            OUT_STATE_WAIT_VALID: begin
                if (data_valid_sync) begin
                    count_out <= count_in_reg;
                    valid <= 1'b1;
                    out_state <= OUT_STATE_WAIT_NOT_VALID;
                end
            end
            OUT_STATE_WAIT_NOT_VALID: begin
                data_ack  <= 1'b1;
                if (!data_valid_sync) begin
                    out_state <= OUT_STATE_WAIT_VALID;
                end
            end
            default: out_state <= OUT_STATE_WAIT_VALID;
        endcase
    end
endmodule

module counter #(
    parameter WIDTH = 8
) (
    input                  clk,
    input                  incr,
    input                  clr,
    output reg [WIDTH-1:0] count
);
wire [WIDTH:0]  count_tmp= count + 'd1;
    always @(posedge clk) begin
        if (incr) begin
            if (clr) begin
                count <= 'd1;
            end else begin
                count <= count_tmp[WIDTH-1:0];
            end
        end else begin
            if (clr) begin
                count <= 'd0;
            end else begin
                count <= count;
            end
        end
    end
endmodule


