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


// ____________________________________________________________________
//      Copyright(C) 2013: Altera Corporation
// ____________________________________________________________________
// altera message_off 10036 // assigned bu never used

 module alt_aeu_40_sfc_rx_dp 
      #( 
         parameter SYNOPT_ALIGN_FCSEOP = 0
        ,parameter WORDS = 8
        ,parameter EMPTYBITS = 6
        ,parameter RXERRWIDTH = 6
        ,parameter RXSTATUSWIDTH =3 //RxCtrl
       )

       (input  wire clk,
        input  wire reset_n,

 //     avalon st source (mac) to pause interface Rx 
        input  wire [RXERRWIDTH-1:0]    in_error ,
        input  wire [RXSTATUSWIDTH-1:0] in_status,//RxCtrl
        input  wire in_error_valid,
        input  wire in_valid,
        input  wire in_sop,
        input  wire in_eop,
        input  wire[64*WORDS-1:0]  in_data,
        input  wire[EMPTYBITS-1:0] in_empty, 

        input  wire drop_this_frame,

 //     pause to avalon st sink (buffer scheduler) Rx 
        output  wire[1:0]  out_sband,
        output  reg out_eop,
        output  wire [RXERRWIDTH-1:0]    out_error ,
        output  wire [RXSTATUSWIDTH-1:0] out_status,//RxCtrl    
        output  wire out_error_valid,
        output  reg out_sop,
        output  reg out_valid,
        output  reg[64*WORDS-1:0]  out_data,
        output  reg[EMPTYBITS-1:0] out_empty 
      );

 //     _________________________________________________________________
 //
        reg  out_dropped;
        reg  pipe_1_rx_in_eop;
        reg  [RXERRWIDTH-1:0]    pipe_1_rx_in_error ;
        reg  [RXSTATUSWIDTH-1:0] pipe_1_rx_in_status;
        reg  pipe_1_rx_in_sop;
        reg  pipe_1_rx_in_val;
        reg[64*WORDS-1:0]  pipe_1_rx_in_data;
        reg[EMPTYBITS-1:0] pipe_1_rx_in_empty; 
                        
        always@(posedge clk or negedge reset_n)
           begin
                if (!reset_n)
                   begin
                        pipe_1_rx_in_eop        <= 1'b0;
                        pipe_1_rx_in_error      <= {RXERRWIDTH{1'b0}};
                        pipe_1_rx_in_status     <= {RXSTATUSWIDTH{1'b0}}; //RxCtrl
                        pipe_1_rx_in_sop        <= 1'b0;
                        pipe_1_rx_in_val        <= 1'b0;
                        pipe_1_rx_in_data       <= 0;
                        pipe_1_rx_in_empty      <= {EMPTYBITS{1'd0}}; 
                   end
                else 
                   begin
                        pipe_1_rx_in_eop        <= in_eop;
                        pipe_1_rx_in_error      <= in_error ;
                        pipe_1_rx_in_status     <= in_status;
                        pipe_1_rx_in_sop        <= in_sop;
                        pipe_1_rx_in_val        <= in_valid;
                        pipe_1_rx_in_data       <= in_data;
                        pipe_1_rx_in_empty      <= in_empty; 
                   end
           end


 // ____________________________________________________________________
 //
        reg  [RXERRWIDTH-1:0]    pipe_2_rx_in_error ;
        reg  [RXSTATUSWIDTH-1:0] pipe_2_rx_in_status;
        always@(posedge clk or negedge reset_n)
           begin
                if (!reset_n)
                   begin
                        out_dropped <= 0;
                        out_valid <= 0;
                        out_sop   <= 0;
                        out_eop   <= 0;
                        out_data  <= 0;
                        out_empty <= 0; 
                        pipe_2_rx_in_error <= 0;
                        pipe_2_rx_in_status<= 0;
                   end
                else if (drop_this_frame) //  aligned with pipe stage 1
                   begin
                        out_dropped <= 1;
                        out_valid <= 0;
                        out_sop   <= 0;
                        out_eop   <= 0;
                        out_data  <= 0;
                        out_empty <= 0; 
                        pipe_2_rx_in_error <= 0;
                   end
                else 
                   begin
                        out_dropped <= 0;
                        out_valid  <= pipe_1_rx_in_val;
                        out_sop    <= pipe_1_rx_in_sop;
                        out_eop    <= pipe_1_rx_in_eop;
                        out_data   <= pipe_1_rx_in_data;
                        out_empty  <= pipe_1_rx_in_empty; 
                        pipe_2_rx_in_error <= pipe_1_rx_in_error ;
                        pipe_2_rx_in_status<= pipe_1_rx_in_status;
                   end
           end
   assign out_sband = {pipe_1_rx_in_sop, pipe_1_rx_in_val};

 // ____________________________________________________________________
 //
   generate if (SYNOPT_ALIGN_FCSEOP == 1) 
        begin:fcseop_aligned
            assign out_error  = pipe_2_rx_in_error ;
            assign out_status = pipe_2_rx_in_status;
            assign out_error_valid = out_eop;
        end
   else 
        begin:fcseop_skewed
            assign out_error  = in_error ;
            assign out_status = in_status;
            assign out_error_valid = in_error_valid;
        end
   endgenerate

 endmodule


