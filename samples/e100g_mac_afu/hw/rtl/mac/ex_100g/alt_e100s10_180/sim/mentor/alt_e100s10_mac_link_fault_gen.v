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


// (C) 2001-2015 Altera Corporation. All rights reserved.
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

module alt_e100s10_mac_link_fault_gen  #(
           parameter WORDS = 4
)
(
                        input                       clk,
                        input                       reset,
                        input                       cfg_unidirectional_en,
                        input                       cfg_en_link_fault_gen,
                        input                       cfg_unidir_en_disable_rf,    //disable remote fault             
                        input                       cfg_force_rf,                //force remote fault
                        input                       remote_fault_status,
                        input                       local_fault_status,
                        input  [WORDS*8 - 1:0]      mii_c_in,
                        input  [WORDS*64 - 1:0]     mii_d_in,
                        input                       mii_valid_in,                //alignment marker(= ~mii_valid_in) 
                        output reg [WORDS*8 - 1:0]  mii_c_out,
                        output reg [WORDS*64 - 1:0] mii_d_out,
                        output reg                  mii_valid_out
                        );
    
    //---------------------------------------------------------------------------------------------------
    // Local Parameters Definitions - General
    //---------------------------------------------------------------------------------------------------
    // Symbols used in the core
    // Symbols that represent data on the lane
    localparam SYMBOL_SEQUENCE            = 8'h9C;
    localparam SYMBOL_IDLE                = 8'h07;
    localparam SYMBOL_REMOTE_FAULT        = 8'h02;
    localparam INSERT_REMOTE              = 2'b11;
    localparam INSERT_IDLE                = 2'b01;
    localparam REMOTE_FAULT_ORDERED_SET   = {SYMBOL_SEQUENCE, 8'h0, 8'h0, SYMBOL_REMOTE_FAULT, 8'h0, 8'h0, 8'h0, 8'h0};

genvar i, j; 
    //---------------------------------------------------------------------------------------------------
    // Internal Declarations
    //---------------------------------------------------------------------------------------------------
//reg  mux_sel_remote;
//reg  mux_sel_idle;
wire remote_fault_sync;
wire local_fault_sync;
alt_e100s10_status_sync fault_sync (
    .clk  (clk),
    .din  ({remote_fault_status, local_fault_status}),
    .dout ({remote_fault_sync, local_fault_sync})
);
defparam fault_sync.WIDTH = 2;

//always @(posedge clk) begin
   //mux_sel_remote <= remote_fault_sync && (remote_fault_config== INSERT_REMOTE) ||
   //                  local_fault_sync &&  (local_fault_config== INSERT_REMOTE); 
    
   //mux_sel_idle   <= remote_fault_sync && (remote_fault_config== INSERT_IDLE) ||
   //                  local_fault_sync &&  (local_fault_config== INSERT_IDLE); 
//end 

//always @(*) begin   
//   mux_sel_remote = local_fault_sync;
//   mux_sel_idle   = remote_fault_sync;
//end 

reg [WORDS*8-1:0]  byte_is_idle;   
wire [WORDS-1:0]    word_is_idle;   
reg                 last_word_is_idle;
reg  [WORDS*8-1:0]  mii_c_r;
reg  [WORDS*64-1:0] mii_d_r;
reg                 mii_valid_r;
reg  [WORDS-1:0]    replace;
wire [WORDS*8-1:0]  replaced_mii_c;
wire [WORDS*64-1:0] replaced_mii_d;

generate
   for (i=0; i< WORDS; i=i+1) begin : idle_word
         for (j=0; j<=7; j=j+1) begin : idle_byte
		always @(posedge clk) begin
			byte_is_idle[i*8+j] <= ((mii_d_in[(i*8+j+1)*8-1:(i*8+j)*8] == 8'h07) && mii_c_in[i*8+j]);  
		end
         end
         assign word_is_idle[i] = & byte_is_idle[i*8+:8];
   end
endgenerate

reg		mii_valid_d;
always @(posedge clk) begin
   if (mii_valid_d) begin 
      last_word_is_idle <= word_is_idle[0];
   end
end

reg  [WORDS*8-1:0]  mii_c_d;
reg  [WORDS*64-1:0] mii_d_d;
always @(posedge clk) begin
	mii_c_d <= mii_c_in;
	mii_d_d <= mii_d_in;
	mii_c_r <= mii_c_d;
	mii_d_r <= mii_d_d;
	mii_valid_d <= mii_valid_in;
	mii_valid_r <= mii_valid_d;
end


// For handling Remote Fault for clause 66. Reserve 1 Idle after data transaction, then replace the rest as Remote Fault
always @(posedge clk) begin
   if (mii_valid_d) begin 
      replace[0] <= word_is_idle[0] && word_is_idle[1];
      replace[1] <= word_is_idle[1] && word_is_idle[2];
      replace[2] <= word_is_idle[2] && word_is_idle[3];
      replace[3] <= word_is_idle[3] && last_word_is_idle;
   end
end

assign replaced_mii_c[ 7: 0] = replace[0] ? 8'h80 : mii_c_r[ 7: 0];
assign replaced_mii_c[15: 8] = replace[1] ? 8'h80 : mii_c_r[15: 8];
assign replaced_mii_c[23:16] = replace[2] ? 8'h80 : mii_c_r[23:16];
assign replaced_mii_c[31:24] = replace[3] ? 8'h80 : mii_c_r[31:24];

assign replaced_mii_d[ 63:  0] = replace[0] ? REMOTE_FAULT_ORDERED_SET : mii_d_r[ 63:  0];
assign replaced_mii_d[127: 64] = replace[1] ? REMOTE_FAULT_ORDERED_SET : mii_d_r[127: 64];
assign replaced_mii_d[191:128] = replace[2] ? REMOTE_FAULT_ORDERED_SET : mii_d_r[191:128];
assign replaced_mii_d[255:192] = replace[3] ? REMOTE_FAULT_ORDERED_SET : mii_d_r[255:192];



   
    //---------------------------------------------------------------------------------------------------
//      Link fault support based on config and link fault status
    //---------------------------------------------------------------------------------------------------
//  
//  +-----------------------+----------------+-----------------------+--------------------------+-------------+--------------+----------+----------+----------------------------------------------------+
//  | cfg_en_link_fault_gen | cfg_force_rf   | cfg_unidirectional_en | cfg_unidir_en_disable_rf | Local Fault | Remote Fault | Transmit | Transmit | Comment                                            |
//  |                       | (ALU)          |                       | (ALU)                    | Received    | Received     |   Data   |   RF     |                                                    |
//  +-----------------------+----------------+-----------------------+--------------------------+-------------+--------------+----------+----------+----------------------------------------------------+
//  | 1'b0                  | Don't care     | Don't care            | Don't care               |     N/A     |     N/A      |   ON     |   OFF    | Link fault disable                                 |
//  +-----------------------+----------------+-----------------------+--------------------------+-------------+--------------+----------+----------+----------------------------------------------------+
//  | 1'b1                  | 1'b1           | Don't care            | Don't care               | Don't care  | Don't care   |   OFF    |   ON     | Force RF: stop data, transmit RF                   |
//  +-----------------------+----------------+-----------------------+--------------------------+-------------+--------------+----------+----------+----------------------------------------------------+
//  | 1'b1                  | 1'b0           | 1'b1                  | 1'b1                     | Don't care  | Don't care   |   ON     |   OFF    | Unidir backward compatible:transmit data, no RF    |
//  +-----------------------+----------------+-----------------------+--------------------------+-------------+--------------+----------+----------+----------------------------------------------------+
//  | 1'b1                  | 1'b0           | 1'b1                  | 1'b0                     |     1'b1    |      1'b0    |   ON     |   ON     | Unidir, LF received:                               |
//  |                       |                |                       |                          |             |              |          |          | tranmit data (1 colum of IDLE after end of packet),|
//  |                       |                |                       |                          |             |              |          |          | transmit RF                                        |
//  +-----------------------+----------------+-----------------------+--------------------------+-------------+--------------+----------+----------+----------------------------------------------------+
//  | 1'b1                  | 1'b0           | 1'b1                  | 1'b0                     |     1'b0    |      1'b1    |   ON     |   OFF    | Unidir, RF received: transmit data, no RF          |
//  +-----------------------+----------------+-----------------------+--------------------------+-------------+--------------+----------+----------+----------------------------------------------------+
//  | 1'b1                  | 1'b0           | 1'b1                  | 1'b0                     |     1'b0    |      1'b0    |   ON     |   OFF    | Unidir, no link fault: transmit data, no RF        |
//  +-----------------------+----------------+-----------------------+--------------------------+-------------+--------------+----------+----------+----------------------------------------------------+
//  | 1'b1                  | 1'b0           | 1'b0                  | Don't care               |     1'b1    |      1'b0    |   OFF    |   ON     | Bidir, LF received: stop data transmit RF          |
//  +-----------------------+----------------+-----------------------+--------------------------+-------------+--------------+----------+----------+----------------------------------------------------+
//  | 1'b1                  | 1'b0           | 1'b0                  | Don't care               |     1'b0    |      1'b1    |   OFF    |   OFF    | Bidir, RF received: stop data, no RF               |
//  +-----------------------+----------------+-----------------------+--------------------------+-------------+--------------+----------+----------+----------------------------------------------------+
//  | 1'b1                  | 1'b0           | 1'b0                  | Dont' care               |     1'b0    |      1'b0    |   ON     |   OFF    | Birdir, no link fault: transmit data, no RF        |
//  +-----------------------+----------------+-----------------------+--------------------------+-------------+--------------+----------+----------+----------------------------------------------------+

   
            always @(posedge clk) begin
                      mii_valid_out <= mii_valid_r;
            end

            always @(posedge clk) begin
            
                if(!cfg_en_link_fault_gen) begin
                      mii_c_out[WORDS*8-1:0] <= mii_c_r;
                      mii_d_out[WORDS*64-1:0] <= mii_d_r;
                end                
                else begin
                  if (cfg_force_rf) begin
                        mii_c_out[WORDS*8-1:0]  <= {WORDS{8'h80}};                     
                        mii_d_out[WORDS*64-1:0] <= {WORDS{REMOTE_FAULT_ORDERED_SET}};
                  end    
                  else begin
                    if (cfg_unidirectional_en) begin
                                if(cfg_unidir_en_disable_rf) begin
                                        mii_c_out[WORDS*8-1:0]  <= mii_c_r;   
                                        mii_d_out[WORDS*64-1:0] <= mii_d_r;  
                                end
                                else begin  
                                        if (local_fault_sync) begin // Replace IPG with Remote fault when local fault received, but keep 1 IDLE after Data 
                          mii_c_out[WORDS*8-1:0] <= replaced_mii_c;
                          mii_d_out[WORDS*64-1:0] <= replaced_mii_d;
                       end
                       else begin // If no fault or remote status receive, send the data received
                          mii_c_out[WORDS*8-1:0] <= mii_c_r;
                          mii_d_out[WORDS*64-1:0] <= mii_d_r;
                       end
                    end
                        end
                    else begin
                       if (local_fault_sync) begin // Generate remote fault response upon receive local fault status
                          mii_c_out[WORDS*8-1:0] <= {WORDS{8'h80}};
                          mii_d_out[WORDS*64-1:0] <= {WORDS{REMOTE_FAULT_ORDERED_SET}};
                       end
                       else if (remote_fault_sync) begin // Generate idle control character upon receive remote fault status
                          mii_c_out[WORDS*8-1:0] <= {WORDS{8'hff}};
                          mii_d_out[WORDS*64-1:0] <= {(WORDS*8){SYMBOL_IDLE}};
                       end
                       else begin // If no fault status receive, send the data received
                          mii_c_out[WORDS*8-1:0] <= mii_c_r;
                          mii_d_out[WORDS*64-1:0] <= mii_d_r;
                       end
                           
                        end // else: !if(cfg_unidirectional_en)

                  end // else: !if(cfg_force_rf)
                     
                end // else: !if(!cfg_en_link_fault_gen)
               
            end // always @ (posedge clk)
   
endmodule



