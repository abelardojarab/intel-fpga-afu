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

module alt_aeu_40_mac_link_fault_det
  #(
    parameter                            WORDS    = 2
    )
    (
    input                clk,
    input                rstn,
    input                ena,
    input [WORDS*64-1:0] mii_data_in,  // read bytes left to right
    input [WORDS*8-1:0]  mii_ctl_in,   // read bits left to right   
    output wire          remote_fault_status,
    output wire          local_fault_status
   );

   //********************************************************************
   // Define Parameters
   //********************************************************************
   // Link Fault SM States
   localparam SEQUENCE                  = 8'h9C;
   localparam NO_FAULT                  = 8'h00;
   localparam LOCAL_FAULT               = 8'h01;
   localparam REMOTE_FAULT              = 8'h02;
   localparam MII_DATA_LOCAL_SEQ_OS  = {SEQUENCE,8'h0,8'h0,LOCAL_FAULT,8'h0,8'h0,8'h0,8'h0};
   localparam MII_DATA_REMOTE_SEQ_OS = {SEQUENCE,8'h0,8'h0,REMOTE_FAULT,8'h0,8'h0,8'h0,8'h0};

   localparam OK_ST             = 1'b0;
   localparam FAULT_ST          = 1'b1;
   localparam NO_FAULT_TYPE     = 2'b00;
   localparam LOCAL_FAULT_TYPE  = 2'b01;
   localparam REMOTE_FAULT_TYPE = 2'b10;
   //********************************************************************
   // Define variables 
   //********************************************************************
   genvar            i;
   
   // Regs
   reg                state=0; 
   reg                next_state=0; 
   reg [7:0]          col_cnt=0; 
   reg [7:0]          next_col_cnt=0; 
   reg [1:0]          seq_type=0;
   reg [1:0]          next_seq_type=0;
   reg [WORDS*64-1:0] mii_data_q=0;  // read bytes left to right
   reg [WORDS*8-1:0]  mii_ctl_q=0;   // read bits left to right   
   reg [WORDS-1:0]    local_seq_type=0;
   reg [WORDS-1:0]    remote_seq_type=0;
   reg [WORDS-1:0]    fault_sequence=0;
   

   reg [WORDS-1:0] local_seq_type_prev  =0; always @(posedge clk) begin local_seq_type_prev  <= local_seq_type;  end
   reg [WORDS-1:0] remote_seq_type_prev =0; always @(posedge clk) begin remote_seq_type_prev <= remote_seq_type; end
   reg [WORDS-1:0] fault_sequence_prev  =0; always @(posedge clk) begin fault_sequence_prev  <= fault_sequence;  end
     
   wire four_local_seqs = &(local_seq_type & local_seq_type_prev);
   wire four_remote_seqs= &(remote_seq_type & remote_seq_type_prev);
   wire four_fault_seqs = &(fault_sequence & fault_sequence_prev);

// wire four_local_seqs = & local_seq_type ;
// wire four_remote_seqs= & remote_seq_type;
// wire four_fault_seqs = & local_seq_type ;
   
   
   //********************************************************************
   // Pipeline Aggregate block_lock and align_status signals 
   // to match datapath latency
   //********************************************************************
  
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         mii_ctl_q <= 0;
      end
      else if (ena) begin
         mii_ctl_q <= mii_ctl_in;
      end
   end

   always @(posedge clk) begin
      if (ena) begin
         mii_data_q <= mii_data_in;
      end
   end

   generate
      for (i=0; i < WORDS; i=i+1) begin : LF_FAULT_SEQ
         always @(posedge clk or negedge rstn) begin
            if (!rstn) begin
               local_seq_type[i]  <= 1'b0;
               remote_seq_type[i] <= 1'b0;
               fault_sequence[i]  <= 1'b0;
            end
            else if (ena) begin
               local_seq_type[i]  <= (mii_data_q[64*(i+1)-1:64*i] == MII_DATA_LOCAL_SEQ_OS);
               remote_seq_type[i] <= (mii_data_q[64*(i+1)-1:64*i] == MII_DATA_REMOTE_SEQ_OS);
               fault_sequence[i]  <= (mii_ctl_q[8*(i+1)-1:8*i]==8'h80) && 
                                     ((mii_data_q[64*(i+1)-1:64*i] == MII_DATA_LOCAL_SEQ_OS) || 
                                      (mii_data_q[64*(i+1)-1:64*i] == MII_DATA_REMOTE_SEQ_OS));
            end
         end 
      end
   endgenerate      
  
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         state <= OK_ST;
         seq_type <= NO_FAULT_TYPE;
         col_cnt <= 0;
      end
      else if (ena) begin
         state <= next_state;
         seq_type <= next_seq_type;
         col_cnt <= next_col_cnt;
      end
   end


   always @(*) begin
         next_state = state;
         next_col_cnt = col_cnt;
         next_seq_type = seq_type; 

         case(state)
            OK_ST : begin
                       //if (&fault_sequence &&  &local_seq_type) begin // 4 columns of local faults
                       if (four_fault_seqs &&  four_local_seqs) begin // 4 columns of local faults
                          next_state  = FAULT_ST;
                          next_seq_type = LOCAL_FAULT_TYPE;
                          next_col_cnt = 0;
                       end
                       //else if (&fault_sequence &&  &remote_seq_type) begin // 4 columns of remote faults
                       else if (four_fault_seqs &&  four_remote_seqs) begin // 4 columns of local faults
                          next_state  = FAULT_ST;
                          next_seq_type = REMOTE_FAULT_TYPE;
                          next_col_cnt = 0;
                       end
                    end

            FAULT_ST : begin
                          // if (&fault_sequence &&  &local_seq_type) begin  // all lanes local faults
                          if (four_fault_seqs &&  four_local_seqs) begin // 4 columns of local faults
                             next_state  = FAULT_ST;
                             next_seq_type = LOCAL_FAULT_TYPE;
                             next_col_cnt = 0;
                          end
                          // else if (&fault_sequence &&  &remote_seq_type) begin // all lanes remote faults
                          else if (four_fault_seqs &&  four_remote_seqs) begin // 4 columns of local faults
                             next_state  = FAULT_ST;
                             next_seq_type = REMOTE_FAULT_TYPE;
                             next_col_cnt = 0;
                          end
                          else if (|fault_sequence) begin // any fault -> reset col_cnt
                             next_state  = FAULT_ST;
                             next_seq_type = seq_type;
                             next_col_cnt = 0;
                          end
                          else begin // no fault
                             if (col_cnt[6]) begin
                                next_state = OK_ST;
                                next_seq_type = NO_FAULT_TYPE;
                                next_col_cnt = 0;
                             end
                             else begin
                                next_state = FAULT_ST;
                                next_seq_type = seq_type;
                                next_col_cnt = col_cnt + 1'b1;
                             end
                          end
                       end
          endcase
   end

assign local_fault_status = seq_type[0]; 
assign remote_fault_status = seq_type[1];
 
endmodule // e40_mac_link_fault_det

         
   
   
