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


// $Id:
// //acds/main/ip/ethernet/alt_e100s10_100g/rtl/mac/alt_e100s10_tx_error.v#1 $
// $Revision: #1 $
// $Date: 2014/02/05 $
// $Author: fkhan $
//-----------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module alt_e100s10_tx_error #(

    parameter   WORDS    = 4,
    parameter   WIDTH    = 64,
    parameter   TARGET_CHIP = 2
) (

    input                   clk,
    input                   sclr,
    input   [WORDS-1:0]     din_eop,
    input   [WORDS-1:0]     tx_error,
    input                   req,

    input   [WORDS-1:0]     tag_eop,
    input                   enable,

    output  reg             error
);


/////////////////////////////////////////
// TX ERROR INSERTION LOGIC


wire [19:0] rdata_err;
wire        empty_err;
reg         rreq_err;

scfifo_mlab scer (
             .clk(clk),
             .sclr(sclr),

             .wdata({12'b0, din_eop, tx_error}),
             .wreq(|din_eop & req),
             .full(), 

             .rdata(rdata_err ),
             .rreq(rreq_err ),
             .empty(empty_err),

             .used()
     );
     defparam scer .TARGET_CHIP = TARGET_CHIP;
     defparam scer .WIDTH = 20;
     defparam scer .PREVENT_OVERFLOW = 1'b0;
     defparam scer .PREVENT_UNDERFLOW = 1'b0;
     defparam scer .ADDR_WIDTH = 5;



reg [3:0]   state;
reg         read_next;
wire        two_eops;

assign      two_eops = |rdata_err[7:6] & |rdata_err[5:4];


localparam  INIT        = 4'b0001;
localparam  WAIT_EOP    = 4'b0010;
localparam  EVAL_EOP    = 4'b0100;
localparam  SEND_EOP    = 4'b1000;


always @(posedge clk) begin

    if (sclr) begin
        error <= 0;
        read_next <=1;
        rreq_err <=0;
        state <= INIT;
    end
    else 
    case (state)
        
        INIT:       begin
                        error       <= 1'b0;
                        read_next   <= 1'b1;
                        if (!empty_err) begin
                            rreq_err    <= 1'b1;
                            state       <= WAIT_EOP;
                        end
                        else
                            state       <=  INIT;
                    end
        WAIT_EOP:   begin
                        rreq_err <= 1'b0;
                        if (|tag_eop & enable) begin
                            if (read_next)
                                state       <=  EVAL_EOP;   
                            else
                                state       <=  SEND_EOP;
                        end
                        else
                            state   <= WAIT_EOP;
                    end
        EVAL_EOP:   begin
                        if (two_eops) begin
                            read_next   <=  1'b0;
                            rreq_err    <=  1'b0;
                            error       <=  |rdata_err[3:2]; 
                            state       <=  WAIT_EOP;
                        end else begin
                            read_next   <=  1'b1;
                            rreq_err    <=  ~empty_err;
                            error       <=  |rdata_err[3:0]; 

                            if (!empty_err)
                                state   <=  WAIT_EOP;
                        end

                    end
        SEND_EOP:   begin                        
                        error       <=  |rdata_err[1:0]; 
                        read_next   <=  1'b1;
                        rreq_err    <=  ~empty_err;
                        
                        if (!empty_err) begin
                            state   <=  WAIT_EOP;
                        end

                    end
        default:    begin
                        error       <=  1'b0;
                        read_next   <=  1'b1;
                        rreq_err    <=  1'b0;
                        state       <=  INIT;
                    end

    endcase
end


endmodule
