// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ps / 1 ps
module sc_fifo_ptp #(
	parameter DEVICE_FAMILY         = "Stratix V",
    
    // Parameter: ECC
    parameter ENABLE_MEM_ECC        = 0,
    parameter REGISTER_ENC_INPUT    = 0,
    
    // Parameter: alt_em10g32_avalon_sc_fifo
    parameter SYMBOLS_PER_BEAT  = 1,
    parameter BITS_PER_SYMBOL   = 8,
    parameter FIFO_DEPTH        = 16,
    parameter CHANNEL_WIDTH     = 0,
    parameter ERROR_WIDTH       = 0,
    parameter USE_PACKETS       = 0,
    
    parameter DATA_WIDTH  = SYMBOLS_PER_BEAT * BITS_PER_SYMBOL,
    parameter EMPTY_WIDTH = log2ceil(SYMBOLS_PER_BEAT)
) (
    input                       clk,
    input                       reset,

    input [DATA_WIDTH-1: 0]     in_data,
    input                       in_valid,
    input                       in_startofpacket,
    input                       in_endofpacket,
    input [((EMPTY_WIDTH>0) ? (EMPTY_WIDTH-1):0) : 0]     in_empty,
    input [((ERROR_WIDTH>0) ? (ERROR_WIDTH-1):0) : 0]     in_error,
    input [((CHANNEL_WIDTH>0) ? (CHANNEL_WIDTH-1):0): 0]  in_channel,
    output                      in_ready,

    output [DATA_WIDTH-1 : 0]   out_data,
    output                      out_valid,
    output                      out_startofpacket,
    output                      out_endofpacket,
    output [((EMPTY_WIDTH>0) ? (EMPTY_WIDTH-1):0) : 0]    out_empty,
    output [((ERROR_WIDTH>0) ? (ERROR_WIDTH-1):0) : 0]    out_error,
    output [((CHANNEL_WIDTH>0) ? (CHANNEL_WIDTH-1):0): 0] out_channel,
    input                       out_ready,
    
    output reg                  ecc_err_corrected,
    output reg                  ecc_err_fatal
);
    
    // Local Parameters
    localparam PKT_SIGNALS_WIDTH    = 2 + EMPTY_WIDTH;
    localparam PAYLOAD_WIDTH        = (USE_PACKETS == 1) ? 
                                       2 + EMPTY_WIDTH + DATA_WIDTH + ERROR_WIDTH + CHANNEL_WIDTH :
                                       DATA_WIDTH + ERROR_WIDTH + CHANNEL_WIDTH;
    localparam ADDR_WIDTH           = log2ceil(FIFO_DEPTH);
    
    wire [PKT_SIGNALS_WIDTH-1 : 0] in_packet_signals;
    wire [PKT_SIGNALS_WIDTH-1 : 0] out_packet_signals;
    
    wire [PAYLOAD_WIDTH-1 : 0] in_payload;
    
    wire                       pipeline_enc_in_sink_valid;
    wire                       pipeline_enc_in_sink_ready;
    wire [PAYLOAD_WIDTH-1 : 0] pipeline_enc_in_sink_data;
    
    wire                       pipeline_enc_in_src_valid;
    wire                       pipeline_enc_in_src_ready;
    wire [PAYLOAD_WIDTH-1 : 0] pipeline_enc_in_src_data;
    
    wire                       sc_fifo_sink_valid;
    wire                       sc_fifo_sink_ready;
    wire [PAYLOAD_WIDTH-1 : 0] sc_fifo_sink_data;
    
    wire                       sc_fifo_src_valid;
    wire                       sc_fifo_src_ready;
    wire [PAYLOAD_WIDTH-1 : 0] sc_fifo_src_data;
    
    wire [PAYLOAD_WIDTH-1 : 0] out_payload;
    
    wire [1:0] ecc_status;
    
    wire wrreq;
    wire rdreq;
    
    wire qualified_write;
    wire qualified_read;
    
    //wire empty;
    reg  empty_reg;
    wire full;
    reg  full_reg;
    
    reg [ADDR_WIDTH+1-1:0] waddr;
    reg [ADDR_WIDTH+1-1:0] waddr_plus_one;
    reg [ADDR_WIDTH+1-1:0] waddr_p1;
    reg [ADDR_WIDTH+1-1:0] waddr_p2;
    reg [ADDR_WIDTH+1-1:0] waddr_p3;
    //reg [ADDR_WIDTH+1-1:0] waddr_p4;
    reg [ADDR_WIDTH+1-1:0] raddr;
    reg [ADDR_WIDTH+1-1:0] raddr_plus_one;
    wire [ADDR_WIDTH+1-1:0] raddr_immediate;
    
    genvar i;
    
    // --------------------------------------------------
    // Define Payload
    //
    // Icky part where we decide which signals form the
    // payload to the FIFO with generate blocks.
    // --------------------------------------------------
    
    generate
        if (EMPTY_WIDTH > 0) begin
            assign in_packet_signals = {in_startofpacket, in_endofpacket, in_empty};
            assign {out_startofpacket, out_endofpacket, out_empty} = out_packet_signals;
        end 
        else begin
            assign out_empty = in_empty;
            assign in_packet_signals = {in_startofpacket, in_endofpacket};
            assign {out_startofpacket, out_endofpacket} = out_packet_signals;
        end
    endgenerate

    generate
        if (USE_PACKETS) begin
            if (ERROR_WIDTH > 0) begin
                if (CHANNEL_WIDTH > 0) begin
                    assign in_payload = {in_packet_signals, in_data, in_error, in_channel};
                    assign {out_packet_signals, out_data, out_error, out_channel} = out_payload;
                end
                else begin
                    assign out_channel = in_channel;
                    assign in_payload = {in_packet_signals, in_data, in_error};
                    assign {out_packet_signals, out_data, out_error} = out_payload;
                end
            end
            else begin
                assign out_error = in_error;
                if (CHANNEL_WIDTH > 0) begin
                    assign in_payload = {in_packet_signals, in_data, in_channel};
                    assign {out_packet_signals, out_data, out_channel} = out_payload;
                end
                else begin
                    assign out_channel = in_channel;
                    assign in_payload = {in_packet_signals, in_data};
                    assign {out_packet_signals, out_data} = out_payload;
                end
            end
        end
        else begin 
            assign out_packet_signals = in_packet_signals;
            if (ERROR_WIDTH > 0) begin
                if (CHANNEL_WIDTH > 0) begin
                    assign in_payload = {in_data, in_error, in_channel};
                    assign {out_data, out_error, out_channel} = out_payload;
                end
                else begin
                    assign out_channel = in_channel;
                    assign in_payload = {in_data, in_error};
                    assign {out_data, out_error} = out_payload;
                end
            end
            else begin
                assign out_error = in_error;
                if (CHANNEL_WIDTH > 0) begin
                    assign in_payload = {in_data, in_channel};
                    assign {out_data, out_channel} = out_payload;
                end
                else begin
                    assign out_channel = in_channel;
                    assign in_payload = in_data;
                    assign out_data = out_payload;
                end
            end
        end
    endgenerate
    
    // Register input for ECC Encoder
    assign pipeline_enc_in_sink_valid = in_valid;
    assign pipeline_enc_in_sink_data = in_payload;
    assign in_ready = REGISTER_ENC_INPUT ? pipeline_enc_in_sink_ready : pipeline_enc_in_src_ready;
    
    pipeline_base_1588 #(
        .BITS_PER_SYMBOL    (PAYLOAD_WIDTH),
        .SYMBOLS_PER_BEAT   (1),
        .PIPELINE_READY     (0)
    ) pipeline_enc_in (
        .clk        (clk),
        .reset_n    (~reset),
        .in_valid   (pipeline_enc_in_sink_valid),
        .in_ready   (pipeline_enc_in_sink_ready),
        .in_data    (pipeline_enc_in_sink_data),
        .out_valid  (pipeline_enc_in_src_valid),
        .out_ready  (pipeline_enc_in_src_ready),
        .out_data   (pipeline_enc_in_src_data)
    );
    
    // SC FIFO
    assign sc_fifo_sink_valid = REGISTER_ENC_INPUT ? pipeline_enc_in_src_valid : pipeline_enc_in_sink_valid;
    assign sc_fifo_sink_data = REGISTER_ENC_INPUT ? pipeline_enc_in_src_data : pipeline_enc_in_sink_data;
    assign pipeline_enc_in_src_ready = sc_fifo_sink_ready;
    
    assign wrreq = sc_fifo_sink_valid;
    assign rdreq = sc_fifo_src_ready;
    assign sc_fifo_sink_ready = ~full_reg;
    
    assign qualified_write = wrreq & !full_reg;
    assign qualified_read = rdreq & !empty_reg;
    
    always @(posedge clk) begin
        if (reset) begin
            waddr <= {(ADDR_WIDTH+1){1'b0}};
            waddr_plus_one <= {(ADDR_WIDTH+1){1'b0}};
            waddr_p1 <= {(ADDR_WIDTH+1){1'b0}};
            waddr_p2 <= {(ADDR_WIDTH+1){1'b0}};
            waddr_p3 <= {(ADDR_WIDTH+1){1'b0}};
            //waddr_p4 <= {(ADDR_WIDTH+1){1'b0}};
        end
        else begin
            if (qualified_write) begin
                waddr <= waddr + 1'b1;
                waddr_plus_one <= waddr + 2'h2;
            end
            
            waddr_p1 <= waddr;
            waddr_p2 <= waddr_p1;
            waddr_p3 <= waddr_p2;
            //waddr_p4 <= waddr_p3;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            raddr <= {(ADDR_WIDTH+1){1'b0}};
            raddr_plus_one <= {{(ADDR_WIDTH){1'b0}},1'b1};
        end
        else begin
            if (qualified_read) begin
                raddr <= raddr + 1'b1;
                raddr_plus_one <= raddr + 2'h2;
            end
        end
    end
    
    //to make read address change immediately when read is asserted
    //this will reduce out data to output port by 1 clock cycle
    assign raddr_immediate = qualified_read ? raddr_plus_one : raddr;

    //assign empty = (waddr_p4 == raddr) ? 1'b1 : 1'b0;
    //assign full = (waddr == (raddr ^ {1'b1,{ADDR_WIDTH{1'b0}}})) ? 1'b1 : 1'b0;
    
    always @(posedge clk) begin
        if (reset) begin
            empty_reg <= 1'b1;
            full_reg <= 1'b0;
        end
        else begin
            if (qualified_read) begin
                empty_reg <= (waddr_p3 == raddr_plus_one) ? 1'b1 : 1'b0;
            end
            else begin
                empty_reg <= (waddr_p3 == raddr) ? 1'b1 : 1'b0;
            end
            
            case ({qualified_write, qualified_read})
                2'b00: full_reg <= (waddr == (raddr ^ {1'b1,{ADDR_WIDTH{1'b0}}})) ? 1'b1 : 1'b0;
                2'b01: full_reg <= (waddr == (raddr_plus_one ^ {1'b1,{ADDR_WIDTH{1'b0}}})) ? 1'b1 : 1'b0;
                2'b10: full_reg <= (waddr_plus_one == (raddr ^ {1'b1,{ADDR_WIDTH{1'b0}}})) ? 1'b1 : 1'b0;
                2'b11: full_reg <= (waddr_plus_one == (raddr_plus_one ^ {1'b1,{ADDR_WIDTH{1'b0}}})) ? 1'b1 : 1'b0;
                default: full_reg <= (waddr == (raddr ^ {1'b1,{ADDR_WIDTH{1'b0}}})) ? 1'b1 : 1'b0;
            endcase
        end
    end
    
    altsyncram_bundle_1588 #(
        .DEVICE_FAMILY              (DEVICE_FAMILY),
        .WIDTH                      (PAYLOAD_WIDTH),
        .DEPTH                      (FIFO_DEPTH),
        .ENABLE_MEM_ECC             (ENABLE_MEM_ECC),
        .ENABLE_ECC_PIPELINE_STAGE  (0),
        .REGISTERED_OUTPUT          (1)
    ) mem1 (
        .data       (sc_fifo_sink_data),
        .rd_aclr    (reset),
        .rdaddress  (raddr_immediate[ADDR_WIDTH-1:0]),
        .rdclock    (clk),
        .rden       (1'b1),
        .wraddress  (waddr[ADDR_WIDTH-1:0]),
        .wrclock    (clk),
        .wren       (qualified_write),
        .eccstatus  (ecc_status),
        .q          (sc_fifo_src_data)
    );
    
    assign sc_fifo_src_valid = ~empty_reg;
    
    assign out_valid = sc_fifo_src_valid;
    assign out_payload = sc_fifo_src_data;
    assign sc_fifo_src_ready = out_ready;
    
    always @(posedge clk) begin
        if(reset) begin
            ecc_err_corrected <= 1'b0;
            ecc_err_fatal <= 1'b0;
        end
        else begin
            ecc_err_corrected <= ENABLE_MEM_ECC ? (ecc_status[1] & ~ecc_status[0] & out_valid & out_ready) : 1'b0;
            ecc_err_fatal <= ENABLE_MEM_ECC ? (ecc_status[1] & ecc_status[0] & out_valid & out_ready) : 1'b0;
        end
    end
    
    
    // --------------------------------------------------
    // Calculates the log2ceil of the input value
    // --------------------------------------------------
    function integer log2ceil;
        input integer val;
        integer i;
        
        begin
            i = 1;
            log2ceil = 0;
            
            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction
    
    // --------------------------------------------------
    // Calculates the divceil of the input value (m/n)
    // --------------------------------------------------
    function integer divceil;
        input integer m;
		input integer n;
        integer i;
        
        begin
            i = m % n;
            divceil = (m/n);
            if (i > 0) begin
                divceil = divceil + 1;
			end
        end
    endfunction	

endmodule
