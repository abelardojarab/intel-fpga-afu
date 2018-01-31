// ***************************************************************************  
//
//          Copyright (C) 2017 Intel Corporation All Rights Reserved.
//
// The source code contained or described herein and all  documents related to
// the  source  code  ("Material")  are  owned  by  Intel  Corporation  or its
// suppliers  or  licensors.    Title  to  the  Material  remains  with  Intel
// Corporation or  its suppliers  and licensors.  The Material  contains trade
// secrets  and  proprietary  and  confidential  information  of  Intel or its
// suppliers and licensors.  The Material is protected  by worldwide copyright
// and trade secret laws and treaty provisions. No part of the Material may be
// used,   copied,   reproduced,   modified,   published,   uploaded,  posted,
// transmitted,  distributed,  or  disclosed  in any way without Intel's prior
// express written permission.
//
// No license under any patent,  copyright, trade secret or other intellectual
// property  right  is  granted  to  or  conferred  upon  you by disclosure or
// delivery  of  the  Materials, either expressly, by implication, inducement,
// estoppel or otherwise.  Any license under such intellectual property rights
// must be express and approved by Intel in writing.

// maguirre - Modified for e10 E2E GBS (April/2017)

module e10_avl_st_gen
(
 input                 clk             // TX FIFO Interface clock
,input                 reset           // Reset signal
,input          [7:0]  address         // Register Address
,input                 write           // Register Write Strobe
,input                 read            // Register Read Strobe
,output wire           waitrequest  
,input          [31:0] writedata       // Register Write Data
,output reg     [31:0] readdata        // Register Read Data

,input                 tx_ready        // Avalon-ST Ready Input
,output reg     [63:0] tx_data         // Avalon-ST TX Data
,output reg            tx_valid        // Avalon-ST TX Valid
,output reg            tx_sop          // Avalon-ST TX StartOfPacket
,output reg            tx_eop          // Avalon-ST TX EndOfPacket
,output reg     [2:0]  tx_empty        // Avalon-ST TX Empty
,output wire           tx_error        // Avalon-ST TX Error
);

//--------------------------------------------------------------------------------
// Local parameters
//--------------------------------------------------------------------------------

localparam ADDR_MACDA0      = 8'h0;
localparam ADDR_MACDA1      = 8'h1;
localparam ADDR_MACSA0      = 8'h2;
localparam ADDR_MACSA1      = 8'h3;
localparam ADDR_NUMPKTS     = 8'h4;
localparam ADDR_PKTLENGTH   = 8'h5;
localparam ADDR_TXPKTCNT 	= 8'h6;
localparam ADDR_GEN_CTRL    = 8'h7;
localparam ADDR_GEN_STAT    = 8'h8;

//--------------------------------------------------------------------------------
// Internal signals
//--------------------------------------------------------------------------------

reg  [31:0] number_pkt;     // Register to store number of packets to be transmitted
reg  [31:0] src_addr0;      // Register to program the MAC source address [31:0]
reg  [31:0] src_addr1;      // Register to program the MAC source address [47:32]
reg  [31:0] dst_addr0;      // Register to program the MAC destination address [31:0]
reg  [31:0] dst_addr1;      // Register to program the MAC destination address [47:32]
reg  [31:0] pkt_tx_cnt;     // Register to count the number of succesfully transmitted packets
reg  [13:0] pkt_length;     // Fixed payload length for every packet

reg	        start_reg;
wire        start;          // Start operation of packet generator
reg         stop;           // Stop operation of packet generator
reg         clear_stop;     // Flag to de-assert stop signal
reg         continuous;     // Continuous generation mode
reg         rand_pkt_numb;
reg         rand_pkt_len;  // Select what type of packet length:0=fixed, 1=random

wire  [7:0] DA5,DA4,DA3,DA2,DA1,DA0; 
wire  [7:0] SA5,SA4,SA3,SA2,SA1,SA0;  

wire        S_IDLE;
wire        S_DEST_SRC;
wire        S_SRC_LEN_SEQ;
wire        S_DATA;
wire        S_TRANSITION;

reg   [2:0] ns;
reg   [2:0] ps;

//--------------------------------------------------------------------------------
// State machine parameters
//--------------------------------------------------------------------------------

localparam state_idle         = 3'b000;         // Idle State
localparam state_dest_src     = 3'b001;         // Dest(47:0) & Src(47:32) State
localparam state_src_len_seq  = 3'b010;         // Src(31:0) & Length(15:0) & SeqNr(15:0) State
localparam state_data         = 3'b011;         // Data Pattern State
localparam state_transition   = 3'b100;         // Transition State

wire    [91:0] tx_prbs;
reg     [15:0] byte_count;
reg     [15:0] length;
reg     [15:0] seq_num;
reg     [31:0] numb_pkt_tx;

//--------------------------------------------------------------------------------
// Avalon-ST signals to CRC generator
//--------------------------------------------------------------------------------

wire    [3:0] empty;
reg     [63:0] tx_data_reg;
reg     tx_valid_reg;
reg     tx_sop_reg;
reg     tx_eop_reg;
reg     [2:0] tx_empty_reg;

wire    crc_valid;
wire    [31:0] crc;
reg     [31:0] crc_l1;
reg     [31:0] crc_l2;
reg     [31:0] crc_l3;
reg     [31:0] crc_l4;
reg     [2:0] crc_valid_count;
wire    [31:0] checksum;

wire    [63:0] tx_data_out;
wire    [5:0] tx_ctrl_out;

reg     add_extra_qword;
reg     valid_extended;
reg     eop_extended;
reg     [2:0] empty_extended;

//--------------------------------------------------------------------------------
// Configuration registers decoding
//--------------------------------------------------------------------------------

// GEN_CTRL
// [0] - Start packet generation (self-clearing)
// [1] - Stop packet generation (self-clearing)
// [2] - Continuous mode
// [3] - Random packet number
// [4] - Random packet length

// GEN_STAT
// [0] - Generation completed

always @ (posedge reset or posedge clk)
begin
    if (reset) 
    begin
        dst_addr0       <= 32'h0;
        dst_addr1       <= 32'h0;
        src_addr0       <= 32'h0;
        src_addr1       <= 32'h0;
        number_pkt      <= 32'h0;
        pkt_length      <= 14'd0;
        start_reg       <= 1'b0;
        stop            <= 1'b0;
        continuous      <= 1'b0;
        rand_pkt_numb   <= 1'b0;
        rand_pkt_len    <= 1'b0;
    end
    else
        if (write)
            case (address)
                ADDR_MACDA0:    dst_addr0       <= writedata;
                ADDR_MACDA1:    dst_addr1[15:0] <= writedata[15:0];
                ADDR_MACSA0:    src_addr0       <= writedata;
                ADDR_MACSA1:    src_addr1[15:0] <= writedata[15:0];
                ADDR_NUMPKTS:   number_pkt      <= writedata;
                ADDR_PKTLENGTH: pkt_length[13:0]<= writedata[13:0];
                ADDR_GEN_CTRL:  {rand_pkt_len,
                                 rand_pkt_numb,
                                 continuous,
                                 stop, 
                                 start_reg}     <= writedata[4:0];
            endcase
        else
        begin
            if (start_reg)
                start_reg <= 1'b0;
            if (clear_stop & stop)
                stop <= 1'b0;
        end
end

assign {DA5,DA4,DA3,DA2,DA1,DA0} = {dst_addr1[15:0], dst_addr0[31:0]};
assign {SA5,SA4,SA3,SA2,SA1,SA0} = {src_addr1[15:0], src_addr0[31:0]};

always@(posedge clk)
begin
    if (read)
        case (address)
            ADDR_MACDA0:    readdata <= dst_addr0;
            ADDR_MACDA1:    readdata <= dst_addr1;
            ADDR_MACSA0:    readdata <= src_addr0;
            ADDR_MACSA1:    readdata <= src_addr1;
            ADDR_NUMPKTS:   readdata <= number_pkt;
            ADDR_PKTLENGTH: readdata <= 32'b0 | pkt_length;
            ADDR_GEN_CTRL:  readdata <= 32'b0 | {rand_pkt_len,
                                                 rand_pkt_numb,
                                                 continuous,
                                                 stop, 
                                                 start_reg};
            ADDR_GEN_STAT:  readdata <= 32'b0 | S_IDLE;
            ADDR_TXPKTCNT:  readdata <= pkt_tx_cnt;
            default:        readdata <= 32'b0;
        endcase
end

//--------------------------------------------------------------------------------
// Start pulse generation
//--------------------------------------------------------------------------------

reg start_d;

always @ (posedge reset or posedge clk)
if (reset) 
    start_d <= 1'b0;
else 
    start_d <= start_reg; 

assign start = start_reg & ~start_d; 

//--------------------------------------------------------------------------------
// pkt_tx_cnt register
//--------------------------------------------------------------------------------

always @ (posedge clk)
begin
    if (start)
        pkt_tx_cnt <= 32'h0;
    else
        if (tx_ready & S_SRC_LEN_SEQ)
            pkt_tx_cnt <= pkt_tx_cnt + 32'h1;
end

//--------------------------------------------------------------------------------
// AVL-MM wait request signal generation
//--------------------------------------------------------------------------------

reg rddly, wrdly;

always@(posedge clk or posedge reset)
begin
    if(reset) 
    begin 
        wrdly <= 1'b0; 
        rddly <= 1'b0; 
    end 
    else 
    begin 
        wrdly <= write; 
        rddly <= read; 
    end 
end

wire wredge = write& ~wrdly;
wire rdedge = read & ~rddly;

// this module is done with AVL-MM transaction when this goes down
assign waitrequest = (wredge|rdedge); 

//--------------------------------------------------------------------------------
// PRBS Pattern Generator
//--------------------------------------------------------------------------------

prbs23 prbs_tx0
(
   .clk        (clk),
   .rst_n      (~reset),
   .load       (S_IDLE),
   .enable     (tx_ready & (S_SRC_LEN_SEQ | S_DATA)),
   .seed       (23'h05eed0),
   .d          (tx_prbs[22:0]),
   .m          (tx_prbs[22:0])
);

prbs23 prbs_tx1
(
   .clk        (clk),
   .rst_n      (~reset),
   .load       (S_IDLE),
   .enable     (tx_ready & (S_SRC_LEN_SEQ | S_DATA)),
   .seed       (23'h15eed1),
   .d          (tx_prbs[45:23]),
   .m          (tx_prbs[45:23])
);

prbs23 prbs_tx2
(
   .clk        (clk),
   .rst_n      (~reset),
   .load       (S_IDLE),
   .enable     (tx_ready & (S_SRC_LEN_SEQ | S_DATA)),
   .seed       (23'h25eed2),
   .d          (tx_prbs[68:46]),
   .m          (tx_prbs[68:46])
);

prbs23 prbs_tx3
(
   .clk        (clk),
   .rst_n      (~reset),
   .load       (S_IDLE),
   .enable     (tx_ready & (S_SRC_LEN_SEQ | S_DATA)),
   .seed       (23'h35eed3),
   .d          (tx_prbs[91:69]),
   .m          (tx_prbs[91:69])
);

//--------------------------------------------------------------------------------
// FSM State Machine for Generator
//--------------------------------------------------------------------------------

always @ (posedge reset or posedge clk)
begin
    if (reset)
        ps <= state_idle;
    else
        ps <= ns;
end

always @ (*)
   begin
      clear_stop = 1'b0;
      ns = ps;
      case (ps)
         state_idle:begin
            if (start) begin
               ns = state_dest_src;
            end
         end
         state_dest_src:begin
            if (tx_ready) begin
               ns = state_src_len_seq;
            end
         end
         state_src_len_seq:begin
            if (tx_ready)
                ns = state_data;
         end
         state_data:begin
            if (tx_ready & (byte_count[15] | byte_count == 16'h0)) begin
               ns = state_transition;
            end
         end
         state_transition:begin
            clear_stop = 1'b1;
            if (stop | ((pkt_tx_cnt == numb_pkt_tx) & ~continuous)) begin
               ns = state_idle;
            end else if (tx_ready) begin
               ns = state_dest_src;
            end      
         end
         default:   ns = state_idle;
      endcase
   end

 assign S_IDLE        = (ns == state_idle)        ? 1'b1 : 1'b0;
 assign S_DEST_SRC    = (ns == state_dest_src)    ? 1'b1 : 1'b0;
 assign S_SRC_LEN_SEQ = (ns == state_src_len_seq) ? 1'b1 : 1'b0;
 assign S_DATA        = (ns == state_data)        ? 1'b1 : 1'b0;
 assign S_TRANSITION  = (ns == state_transition)  ? 1'b1 : 1'b0;

// Length is used to store the payload length size.
// Allowable payload Length: 46 -> 1500
// We are subtracting 6 due to seq_num (2 bytes) and CRC (4 bytes)
// --------------------------------------------------

always @ (posedge clk)
begin
    if (S_IDLE | S_TRANSITION)
    begin
        if (rand_pkt_len)
            length <= (tx_prbs[74:64] % 16'd1494);
        else
        begin
            if (pkt_length < 14'd46)
                length <= 16'd40;
            else
                if (pkt_length > 14'd1500)
                    length <= 16'd1494;
                else
                    length <= {2'b00, pkt_length - 14'd6};
        end
    end
end

// numb_pkt_tx is used to store the number of packets to be transmitted
// --------------------------------------------------

always @ (posedge clk)
begin
    if (start)
    begin
        if (rand_pkt_numb)
            numb_pkt_tx <= tx_prbs[31:0];
        else
            numb_pkt_tx <= number_pkt;
    end
end

// Byte_count is used to keep track of how many bytes of data payload being generated out
// --------------------------------------------------------------------------------------

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         byte_count <= 16'h0;
      end else begin
         if (S_DEST_SRC) begin
            byte_count <= length;
         end else if (S_DATA & tx_ready) begin
            byte_count <= byte_count - 16'h8;
         end
      end
   end

// Seq_num is inserted into the first 2 bytes of data payload of every packet
// ---------------------------------------------------------------------------

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         seq_num <= 16'h0;
      end else begin
         if (start) begin
            seq_num <= 16'h0;
         end else if (S_TRANSITION & tx_ready) begin
            seq_num <= seq_num + 16'h1;
         end
      end
   end

// Avalon-ST tx_data interface to CRC generator
// ---------------------------------------------

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_data_reg <= 64'h0;
      end else begin
         if (S_DEST_SRC) begin
            tx_data_reg[63:32] <= {DA5,DA4,DA3,DA2};
            tx_data_reg[31: 0] <= {DA1,DA0,SA5,SA4};
         end else if (S_SRC_LEN_SEQ) begin
            tx_data_reg[63:32] <= {SA3,SA2,SA1,SA0};
            tx_data_reg[31: 0] <= {length + 16'd6, seq_num};
         end else if (S_DATA & tx_ready) begin
            tx_data_reg <= tx_prbs[63:0];
         end
      end
   end

// Avalon-ST tx_valid interface to CRC generator
// ----------------------------------------------
always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_valid_reg <= 1'b0;
      end else begin
         if (S_IDLE | S_TRANSITION) begin
            tx_valid_reg <= 1'b0;
         end else begin
            tx_valid_reg <= 1'b1;
         end
      end
   end

   // Avalon-ST tx_sop interface to CRC generator
// --------------------------------------------
always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_sop_reg <= 1'b0;
      end else begin
         if (S_DEST_SRC) begin
            tx_sop_reg <= 1'b1;
         end else begin
            tx_sop_reg <= 1'b0;
         end
      end
   end

// Avalon-ST tx_eop interface to CRC generator
// --------------------------------------------
always @ (posedge reset or posedge clk)
begin
    if (reset)
        tx_eop_reg <= 1'b0;
    else 
        if (S_DATA & tx_ready & (byte_count <= 8)) 
            tx_eop_reg <= 1'b1;
        else 
            if (S_TRANSITION)
                tx_eop_reg <= 1'b0;
end

// Avalon-ST tx_empty interface to CRC generator
// ----------------------------------------------

assign empty = 4'h8 - length[2:0];

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_empty_reg <= 3'b000;
      end else begin
         if (S_DATA & tx_ready & (byte_count <= 8)) begin
            tx_empty_reg <= empty[2:0];
         end else if (S_TRANSITION) begin
            tx_empty_reg <= 3'b000;
         end
      end
   end

// Using CRC Compiler to generate checksum and append it to EOP
// -------------------------------------------------------------



crc32_gen  #(64,3)
//	.DATA_WIDTH (64),
//	.EMPTY_WIDTH (3),
//	.CRC_WIDTH	(32),
//	.REVERSE_DATA (1),
//	.OPERATION_MODE (1)
//)

crc32_gen_inst(
   .CLK    (clk),
	.RESET_N    (~reset),
	.AVST_VALID   (tx_valid_reg & tx_ready),
	.AVST_SOP      (tx_sop_reg),
	.AVST_DATA    (tx_data_reg),
	.AVST_EOP      (tx_eop_reg),
	.AVST_EMPTY     (tx_empty_reg),
	.CRC_VALID   (crc_valid),
	.CRC_CHECKSUM	(crc),
	.AVST_READY   ());

// Using RAM based shift register to delay packet payload sending to TSE TX FIFO
// interface for CRC checksum merging at EOP
// -------------------------------------------------------------------------------

shiftreg_data shiftreg_data_inst
(
        .aclr           (reset),
        .clken          (tx_ready),
        .clock          (clk),
        .shiftin        (tx_data_reg),
        .shiftout       (tx_data_out),
        .taps           ()
);

// Using RAM based shift register to store and delay control signals
// ------------------------------------------------------------------

shiftreg_ctrl shiftreg_ctrl_inst
(
        .aclr           (reset),
        .clken          (tx_ready),
        .clock          (clk),
        .shiftin        ({tx_valid_reg, tx_sop_reg, tx_eop_reg, tx_empty_reg}),
        .shiftout       (tx_ctrl_out),
        .taps           ()
);

reg [2:0] start_cnt;

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         crc_valid_count <= 3'b000;
		 start_cnt <= 0;
      end else begin
		 if (start_cnt < 4)
			start_cnt = start_cnt + 1;
		 else
			crc_valid_count <= crc_valid_count + (crc_valid) - (tx_ready & tx_eop);
      end
   end

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         crc_l1 <= 32'h0;
         crc_l2 <= 32'h0;
      end else begin
         if (crc_valid) begin
            crc_l1 <= crc;
            crc_l2 <= crc_l1;
            crc_l3 <= crc_l2;
            crc_l4 <= crc_l3;
         end
      end
   end

assign checksum = (crc_valid_count == 3'b001) ? crc_l1 :
                  (crc_valid_count == 3'b010) ? crc_l2 :
                  (crc_valid_count == 3'b011) ? crc_l3 :
                  (crc_valid_count == 3'b100) ? crc_l4 :
                  32'h0;

// Extend packet by one cycle when not enough
// space in last word to add in checksum
// -------------------------------------------

always @ (*)
   begin
      add_extra_qword <= 1'b0;
      if (tx_ctrl_out[5] & tx_ctrl_out[3]) begin // valid eop
         if (tx_ctrl_out[2] == 1'b0) begin // Less than 4 empty bytes
            add_extra_qword <= 1'b1;
         end
      end
   end

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         valid_extended <= 1'b0;
         eop_extended   <= 1'b0;
         empty_extended <= 3'b000;
      end else begin
         if (tx_ready) begin
            if (add_extra_qword) begin
               valid_extended <= 1'b1;
               eop_extended   <= 1'b1;
               empty_extended[2]   <= 1'b1;
               empty_extended[1:0] <= tx_ctrl_out[1:0];
            end else begin
               valid_extended <= 1'b0;
               eop_extended   <= 1'b0;
               empty_extended[2]   <= 1'b0;
               empty_extended[1:0] <= 3'b000;
            end
         end
      end
   end

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_valid <= 1'b0;
         tx_sop   <= 1'b0;
         tx_eop   <= 1'b0;
         tx_empty <= 1'b0;
      end else begin
         if (tx_ready) begin
            tx_valid <= tx_ctrl_out[5] | valid_extended;
         end else begin
            //tx_valid <= 1'b0 ;
            tx_valid <= tx_valid ; // ajay: remain unchanged
         end    

         if (tx_ready) begin
            //tx_valid <= tx_ctrl_out[5] | valid_extended; // ajay: unnecessary: already defined above
            tx_sop   <= tx_ctrl_out[4];
            if (tx_ctrl_out[5] & tx_ctrl_out[3]) begin // valid eop
               tx_eop <= !add_extra_qword; // keep original
            end else begin
               tx_eop <= eop_extended;
            end
            if (tx_ctrl_out[5] & tx_ctrl_out[3]) begin // valid eop
               if (add_extra_qword) begin
                  tx_empty <= 3'b000;
               end else begin
                  tx_empty <= tx_ctrl_out[2:0] - 3'h4;
               end
            end else begin
               tx_empty <= empty_extended[2:0];
            end
         end
      end
   end

 always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_data <= 64'h0;
      end else begin
         if (tx_ready) begin
            tx_data <= tx_data_out; // By default

            if (tx_ctrl_out[3]) begin // Normal EOP field
               case (tx_ctrl_out[2:0])
                  3'b000: tx_data <=  tx_data_out[63:0];
                  3'b001: tx_data <= {tx_data_out[63:8],  checksum[31:24]};
                  3'b010: tx_data <= {tx_data_out[63:16], checksum[31:16]};
                  3'b011: tx_data <= {tx_data_out[63:24], checksum[31: 8]};
                  3'b100: tx_data <= {tx_data_out[63:32], checksum[31: 0]};
                  3'b101: tx_data <= {tx_data_out[63:40], checksum[31: 0],  8'h0};
                  3'b110: tx_data <= {tx_data_out[63:48], checksum[31: 0], 16'h0};
                  3'b111: tx_data <= {tx_data_out[63:56], checksum[31: 0], 24'h0};
                  default: tx_data <= tx_data_out;
               endcase
            end else if (eop_extended) begin
               case (empty_extended)
                  3'b100: tx_data <= {checksum[31:0], 32'h0};
                  3'b101: tx_data <= {checksum[23:0], 40'h0};
                  3'b110: tx_data <= {checksum[15:0], 48'h0};
                  3'b111: tx_data <= {checksum[ 7:0], 56'h0};
                  default: tx_data <= 64'h0;
               endcase
            end
         end
      end
   end

assign tx_error = 1'b0;

endmodule

 // ___________________________________________________________________________________________________
 //	PRBS23 GENERATOR
 // ___________________________________________________________________________________________________

//-----------------------------------------------------------------------------
// Functional Description:
// This module is the Pseudo-Random Bit Sequence 23 Block
// where g(x) = x^23 + x^18 + x^0
//
// use lsb of m 1st first
// k can be > N, but part of the sequence will be skipped
//
//-------------------------------------------------------------------------------
  
module prbs23 ( clk, rst_n, load, enable, seed, d, m);

	parameter k = 23;       //step value = a^k
	parameter N = 23;

	input   clk;
	input   rst_n;
	input   load;
	input   enable;
	input   [N-1:0] seed;
	input   [N-1:0] d;
	output  [N-1:0] m;
	
	reg     [N-1:0] m;
	reg     [N-1:0] tmpa;
	reg     [N-1:0] tmpb;
	integer i,j;


	always @ (d)
	begin
   	    tmpa = d;
   	    for (i=0; i<k; i=i+1) 
 	       begin
                 for (j=0; j<(N-1); j=j+1) begin tmpb[j] = tmpa[j+1]; end
      		 tmpb[N-1] = tmpa[18] ^ tmpa[0];      //x^23 + x[18] + x[0]
      		 tmpa = tmpb;
   	       end
	end

	always @(posedge clk or negedge rst_n)
        begin
	    begin
    		if (!rst_n) m <= 0;
    		else if (load) m <= seed;
    		else if (enable) m <= tmpb;
    	    end
	end

 endmodule
