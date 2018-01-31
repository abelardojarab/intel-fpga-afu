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


// $Id: $
// $Revision: $
// $Date: $
// $Author: $
//-----------------------------------------------------------------------------

module alt_aeu_40_pcs_ber_sm
  (
    input wire             rstn,           // Active low Reset
    input wire             clk,            // Clock
    input wire             bypass_ber,     // Bypass BER Monitoring 
    input wire             align_status_in,
    input wire             data_in_valid,
    //input wire             rx_test_en,     // Indicates receiver is in test pattern mode
    input wire [20:0]      rxus_timer_window,  //MDIO for xus timer counter.  40G is 390625. 100G is 156250.
    input wire [6:0]       rbit_error_total_cnt, // MDIO for BER count. 10G is 16-1. 40G/100G is 97-1.   
    input wire [6:0]       ber_cnt_ns,           // Indicates BER Count
    output reg             hi_ber,          // Indicates High BER detected
    output reg [6:0]       ber_cnt_cs          // Indicates BER Count    
   );
   
   
   //********************************************************************
   // Define Parameters 
   //********************************************************************
   // BER SM States
   localparam                 ST_MONITOR                   = 1'b0;
   localparam                 ST_SET_HI_BER                = 1'b1;
   localparam                 rx_test_en                   = 1'b0;

   //********************************************************************
   // Define variables 
   //********************************************************************
   // Regs
   reg                      ber_sm;
   reg                      next_ber_sm;
   reg [20:0]               xus_timer;
   reg                      xus_timer_done;
   reg                      reset_timer_ber_cnt;
   reg                      set_hi_ber;
   reg                      clear_hi_ber;
  
   //********************************************************************
   // Bit Error Rate State Machine
   // 
   //********************************************************************
   always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
         ber_sm <= ST_MONITOR;
      end
      else if (bypass_ber || ~align_status_in) begin
            ber_sm <= ST_MONITOR;
      end
      else begin
         ber_sm <= next_ber_sm;
      end
   end
            
   //********************************************************************
   // Bit Error Rate State Machine
   // Output Logic
   //********************************************************************
   always @(*) begin
      reset_timer_ber_cnt = 0;
      set_hi_ber = 0;
      clear_hi_ber = 0;
      next_ber_sm = ber_sm;

      if (data_in_valid) begin
         case (ber_sm)

           ST_MONITOR: begin
              if (ber_cnt_cs >= rbit_error_total_cnt) begin
                 set_hi_ber = 1;
                 next_ber_sm = ST_SET_HI_BER;
              end
              else if (xus_timer_done) begin
                 reset_timer_ber_cnt = 1;
                 clear_hi_ber = 1;
                 next_ber_sm = ST_MONITOR;
              end
           end // case: ST_MONITOR
                   
           ST_SET_HI_BER: begin
              set_hi_ber = 1;
              if (xus_timer_done) begin
                 reset_timer_ber_cnt = 1;
                 next_ber_sm = ST_MONITOR;
              end
           end

           default: begin
              reset_timer_ber_cnt = 0;
              set_hi_ber = 0;
              clear_hi_ber = 0;
              next_ber_sm = ber_sm;
           end

         endcase // case(ber_sm)
      end // if (data_in_valid)
   end // always @ (*)
         
   
   //********************************************************************
   // xus_timer
   // hi_ber flag
   // xus_timer_done
   //********************************************************************
   always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
         xus_timer <= 'd0;
         hi_ber <= 1'b0;
         xus_timer_done <= 1'b0;
      end
      else  if (data_in_valid) begin
         if (rx_test_en || bypass_ber || ~align_status_in) begin
            xus_timer <= 'd0;
            hi_ber <= 1'b0;
            xus_timer_done <= 1'b0;
         end
         else begin
            
            // 125us_timer
            if (reset_timer_ber_cnt) begin
               xus_timer <= 'd0;
               xus_timer_done <= 1'b0;
            end
            else begin
               xus_timer <= xus_timer + 1'b1;
               xus_timer_done  <= (xus_timer >= rxus_timer_window) ? 1'b1 : 1'b0;
            end
            
            // hi_ber
            if (set_hi_ber) begin
               hi_ber <= 1'b1;
            end
            else if (clear_hi_ber) begin
               hi_ber <= 1'b0;
            end
        
         end // else: !if(rx_test_en || bypass_ber || ~align_status_in)
                  
      end // if (data_in_valid)
            
   end // always @ (posedge clk or negedge rstn)


   //********************************************************************
   // ber_cnt sequential logic
   // 
   //********************************************************************
   always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
         ber_cnt_cs <= 'd0;
      end
      else if (data_in_valid) begin
         if (rx_test_en || bypass_ber || ~align_status_in) begin
            ber_cnt_cs <= 'd0;
         end
         else if (reset_timer_ber_cnt) begin
            ber_cnt_cs <= 'd0;
         end
         else begin
            ber_cnt_cs <= ber_cnt_ns;
         end
      end
   end // always @ (posedge clk or negedge rstn)

endmodule // e40_pcs_ber_sm





   
