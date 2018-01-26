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


module alt_aeu_40_avl_filter #(
   parameter      SYNOPT_READY_LATENCY = 0
)(
    input         clk,
    input         rst,
    input         avl_ready,      //core is ready, output from core to user if    
    input         avl_sop,        //input from user if to core
    input         avl_eop,        //input from user if to core
    input         avl_valid,      //input from user if to core
    input  [4:0]  avl_empty,
    output        filtered_sop,
    output        filtered_eop,
    output [4:0]  filtered_empty,  
    output [3:0]  protocol_err    
    
 );


 localparam          STATE = 2;
 localparam [STATE-1:0]      
            IDLE           = 2'd0,
            PKT_VALID_DOWN = 2'd1,
            PKT            = 2'd2;
 
 reg     [STATE -1:0] state_r  = 2'h0;
 reg     [STATE -1:0] state_nx = 2'h0;
 
 reg [1:0] sop_b2b_cnt          = 2'b0;
 reg [1:0] eop_b2b_cnt          = 2'b0;
 reg       eop_b2b_cnt_carry    = 1'b0;//dummy
 reg       sop_b2b_cnt_carry    = 1'b0;//dummy
 reg       sop_eop_sameword    = 1'b0;
 
   
 reg [1:0] sop_b2b_cnt_r        = 2'b0;
 reg [1:0] eop_b2b_cnt_r        = 2'b0;
 
 wire      sop_b2b; //sop back2back, no eop in between
 wire      eop_b2b; //eop back2back, no sop in between
 wire      inpkt_valid_down;
   
 //Only check inputs when IP core is ready
 wire ready;
 wire valid = ready & avl_valid;
 wire sop   = valid & avl_sop  ;
 wire eop   = valid & avl_eop  ;

  //--------------------------------------------------         
  //- Output 
  //  Filtered Avalon ST signals
  //  Avalon ST protocol error    
  //--------------------------------------------------    
  assign filtered_sop   = sop & (~sop_b2b) & (~sop_eop_sameword);
  assign filtered_eop   = eop & (~eop_b2b) & (~sop_eop_sameword);
  assign filtered_empty = avl_empty & {5{filtered_eop}};
  assign protocol_err   = {inpkt_valid_down, eop_b2b, sop_b2b, sop_eop_sameword}; 
     
  //--------------------------------------------------         
  //- Ready latency handling   
  //--------------------------------------------------     
  generate if (SYNOPT_READY_LATENCY !=0 ) 
  begin
     reg avl_ready_d  = 1'b0;
     reg avl_ready_d1 = 1'b0;
     reg avl_ready_d2 = 1'b0;
     
     always@(clk) begin
       avl_ready_d  <= avl_ready   ;
       avl_ready_d1 <= avl_ready_d ; 
       avl_ready_d2 <= avl_ready_d1;
     end
  
     assign ready = avl_ready_d2;
  end
  else begin
     assign ready = avl_ready;
  end
  endgenerate
  
  //--------------------------------------------------         
  //- Error Indication
  //--------------------------------------------------    
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      sop_b2b_cnt_r        <= 2'h0; 
      eop_b2b_cnt_r        <= 2'h0;
    end    
    else begin
      sop_b2b_cnt_r        <= sop_b2b_cnt   ; 
      eop_b2b_cnt_r        <= eop_b2b_cnt   ;
    end    
  end
  
  //SOP, EOP same word   
  always @(*) begin
      if (sop & eop & (&avl_empty[4:3])) sop_eop_sameword = 1'b1;//empty>='d24
      else                               sop_eop_sameword = 1'b0;
  end
  
  //Back2Back SOP count  
  always @(*) begin
     sop_b2b_cnt = sop_b2b_cnt_r;
     if ( ~(sop & eop)) begin      //sop and eop not the same cycle 
       if (sop_b2b_cnt_r[1]) sop_b2b_cnt = {1'b0, sop};   
       else if (sop & (sop_b2b_cnt_r <2'h3)) {sop_b2b_cnt_carry, sop_b2b_cnt} = sop_b2b_cnt_r + 1'b1;
       else if (eop & (sop_b2b_cnt_r >2'h0)) {sop_b2b_cnt_carry, sop_b2b_cnt} = sop_b2b_cnt_r - 1'b1;
  
     end    
  end
  
  //Back2Back EOP count  
  always @(*) begin
     eop_b2b_cnt = eop_b2b_cnt_r;
     if ( ~(sop & eop)) begin      //sop and eop not the same cycle 
       if (eop_b2b_cnt_r[1]) eop_b2b_cnt = {1'b0, eop};   
       else if (eop & (eop_b2b_cnt_r <2'h3)) {eop_b2b_cnt_carry, eop_b2b_cnt} = eop_b2b_cnt_r + 1'b1;
       else if (sop & (eop_b2b_cnt_r >2'h0)) {eop_b2b_cnt_carry, eop_b2b_cnt} = eop_b2b_cnt_r - 1'b1;
  
     end    
  end
  
  //Back2Back SOP/EOP indication   
  assign sop_b2b = sop_b2b_cnt[1]; //sop_b2b_cnt > 2'b1
  assign eop_b2b = eop_b2b_cnt[1]; //eop_b2b_cnt > 2'b1
  
  //FSM for valid goes low within a packet (between sop and eop)   
  always@(posedge clk or posedge rst)begin
    if(rst) state_r <= IDLE;
    else    state_r <= state_nx;
  end
  
  always@(*)begin
    state_nx = state_r;
    case(state_r)
      IDLE: begin
         //if (ready & ~avl_valid & (avl_sop | avl_eop)) state_nx = PKT_VALID_DOWN;
         if (sop & ~eop) state_nx = PKT;
      end
      PKT:begin
          if (eop & ~sop)              state_nx = IDLE;
          else if (ready & ~avl_valid) state_nx = PKT_VALID_DOWN;
      end
      PKT_VALID_DOWN:begin
          if (sop & ~eop) state_nx = PKT;
          else if (eop)   state_nx = IDLE;
      end
      default:begin
         state_nx = IDLE;
      end    
    endcase
  end
  
  assign inpkt_valid_down = (state_r == PKT_VALID_DOWN);
  


endmodule 
