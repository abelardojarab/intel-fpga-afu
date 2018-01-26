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


// $Id:
// //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/mac/alt_aeu_40_tx_error.v#1 $
// $Revision: #1 $
// $Date: 2014/02/05 $
// $Author: fkhan $
//-----------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module alt_aeu_40_tx_error #(

    parameter   WORDS    = 4,
    parameter   WIDTH    = 64,
    parameter   TARGET_CHIP = 2
) (

    input                   clk,
    input                   sclr,
    input   [WORDS-1:0]     din_eop,
    input   [WORDS-1:0]     din_error,
    input                   req,

    input   [WORDS-1:0]     tag_eop,
    input                   enable,

    output                  error
);


/////////////////////////////////////////
// TX ERROR INSERTION LOGIC
wire [19:0] rdata_err;
wire        empty_err;
reg         rreq_err =  1'b0;

scfifo_mlab scer (
             .clk(clk),
             .sclr(sclr),

             .wdata(|din_error),
             .wreq(|din_eop & req),
             .full(), 

             .rdata(error),
             .rreq(rreq_err ),
             .empty(empty_err),

             .used()
     );
     defparam scer .TARGET_CHIP = TARGET_CHIP;
     defparam scer .WIDTH = 1;
     defparam scer .PREVENT_OVERFLOW = 1'b0;
     defparam scer .PREVENT_UNDERFLOW = 1'b0;
     defparam scer .ADDR_WIDTH = 5;



reg [2:0]   state = 3'b001;

localparam  INIT        = 3'b001;
localparam  WAIT_EOP    = 3'b010;
localparam  SEND_EOP    = 3'b100;


always @(posedge clk) begin

    case (state)
        
        INIT:       begin
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
                            state       <=  SEND_EOP;
                        end
                        else
                            state   <= WAIT_EOP;
                    end


        SEND_EOP:   begin                        
                        rreq_err    <=  ~empty_err;
                        if (!empty_err) begin
                            state   <=  WAIT_EOP;
                        end

                    end
        default:    begin
                        rreq_err    <=  1'b0;
                        state       <=  INIT;
                    end

    endcase
end


endmodule
