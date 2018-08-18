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

module alt_e100s10_tx_fc_pb_timer
#(
    parameter WIDTH = 18
)(
    input clk,
    input reset_n,

    input load,
    input enable,
    input [WIDTH-1:0] pq_cycle,
    
    output reg pause,
    output done
);

	localparam IDLE   = 3'd0,
		      LOAD   = 3'd1,
		      EVAL1  = 3'd2,
		      EVAL2  = 3'd3,
		      EVAL3  = 3'd4,
		      COUNT  = 3'd5;

    reg [WIDTH-1:0] pq_cycle_reg;
    reg [WIDTH-1:0] pq_cycle_load;
    reg [WIDTH-1:0] quanta_timer;
    reg [10:0] quanta_timer_1cycle_more;
    reg start_count;
    reg [5:0] comparator;
    reg [2:0] state;
    reg count;
    reg retain_pause;
    
    //non-resettable flop
	always @ (posedge clk) begin
        pq_cycle_reg <= pq_cycle;
    end
    
    //synchronous reset flop
	always @ (posedge clk) begin
	    if (~reset_n) begin
		    state <= IDLE;
            retain_pause <= 1'b0;
	    end else begin
            case (state)
            IDLE:begin
                if (load) begin
                    state <= LOAD;
                    retain_pause <= 1'b0;
                end
            end
            LOAD:begin
                if (load) begin
                    state <= LOAD;
                end else begin
                    state <= EVAL1;
                end
                retain_pause <= retain_pause;
            end
            EVAL1:begin
                if (load) begin
                    state <= LOAD;
                end else begin
                    state <= EVAL2;
                end
                retain_pause <= retain_pause;
            end
            EVAL2:begin
                if (load) begin
                    state <= LOAD;
                end else begin
                    state <= EVAL3;
                end
                retain_pause <= retain_pause;
            end
            EVAL3:begin
                if (load) begin
                    state <= LOAD;
                    retain_pause <= retain_pause;
                end else if (count) begin
                    state <= COUNT;
                    retain_pause <= 1'b0;
                end else begin
                    state <= IDLE;
                    retain_pause <= 1'b0;
                end
            end
            COUNT:begin
                if (load) begin //when this happen, pause will go down until new quanta has been evaluated
                    state <= LOAD;
                    retain_pause <= 1'b1;
                end else if (count) begin
                    state <= COUNT;
                    retain_pause <= 1'b0;
                end else begin
                    state <= IDLE;
                    retain_pause <= 1'b0;
                end
            end
		    default:begin
			    state <= state;
                retain_pause <= retain_pause;
			end
            endcase
        end
    end

    //non-resettable flop
	always @ (posedge clk) begin
        case (state)
        IDLE:begin
            quanta_timer <= {WIDTH{1'b0}};
            pq_cycle_load <= {WIDTH{1'b0}};
            quanta_timer_1cycle_more <= 11'd0;
        end
        LOAD:begin
            quanta_timer <= {WIDTH{1'b0}};
            pq_cycle_load <= pq_cycle_reg;
            quanta_timer_1cycle_more <= 11'd0;
        end
        EVAL1:begin
            quanta_timer <= quanta_timer;
            pq_cycle_load <= pq_cycle_load;
            quanta_timer_1cycle_more <= 11'd0;
        end
        EVAL2:begin
            quanta_timer <= quanta_timer;
            pq_cycle_load <= pq_cycle_load;
            quanta_timer_1cycle_more <= 11'd0;
        end
        EVAL3:begin
            quanta_timer <= quanta_timer;
            pq_cycle_load <= pq_cycle_load;
            quanta_timer_1cycle_more <= 11'd0;
        end
        COUNT:begin
            pq_cycle_load <= pq_cycle_load;
            if (enable) begin
                quanta_timer[9:0] <= quanta_timer[9:0] + 10'd1;
                quanta_timer_1cycle_more[10:0] <= quanta_timer[9:0] + 10'd2;
                quanta_timer[WIDTH-1:10] <= quanta_timer[WIDTH-1:10] + (quanta_timer_1cycle_more[10] & ~quanta_timer_1cycle_more[0]);
            end
        end
		default:begin
            quanta_timer <= {WIDTH{1'b0}};
            pq_cycle_load <= {WIDTH{1'b0}};
            quanta_timer_1cycle_more <= 11'd0;
        end
        endcase
    end
    
    assign done = ~pause;
    
    always @ (posedge clk) begin
        if (~reset_n) begin
            count <= 1'b0;
            comparator <= 6'h0;
            pause <= 1'b0;
        end else begin
            count <= ~(&comparator);
            comparator[0] <= (quanta_timer[2:0] == pq_cycle_load[2:0]);
            comparator[1] <= (quanta_timer[5:3] == pq_cycle_load[5:3]);
            comparator[2] <= (quanta_timer[8:6] == pq_cycle_load[8:6]);
            comparator[3] <= (quanta_timer[11:9] == pq_cycle_load[11:9]);
            comparator[4] <= (quanta_timer[14:12] == pq_cycle_load[14:12]);
            comparator[5] <= (quanta_timer[WIDTH-1:15] == pq_cycle_load[WIDTH-1:15]);
            pause <= retain_pause ? pause : (state == COUNT);
        end
    end
 
endmodule


