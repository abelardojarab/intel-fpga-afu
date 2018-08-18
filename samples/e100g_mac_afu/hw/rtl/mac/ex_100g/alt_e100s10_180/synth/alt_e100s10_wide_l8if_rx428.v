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


// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/ast/alt_e100s10_wide_l8if_rx428.v#8 $
// $Revision: #8 $
// $Date: 2013/09/10 $
// $Author: jilee $
//-----------------------------------------------------------------------------
`timescale 1ps / 1ps

// set_instance_assignment -name VIRTUAL_PIN ON -to rx8l_d
// set_instance_assignment -name VIRTUAL_PIN ON -to rx8l_empty
// set_instance_assignment -name VIRTUAL_PIN ON -to rx4l_d
// set_instance_assignment -name VIRTUAL_PIN ON -to rx4l_sop
// set_instance_assignment -name VIRTUAL_PIN ON -to rx4l_idle
// set_instance_assignment -name VIRTUAL_PIN ON -to rx4l_eop_empty
// set_global_assignment -name SEARCH_PATH ../../hsl12
// set_global_assignment -name SEARCH_PATH ../../rtl/lib
// set_global_assignment -name SEARCH_PATH ../../rtl/clones
// set_global_assignment -name SEARCH_PATH ../../rtl/ast

module alt_e100s10_wide_l8if_rx428 #(
    parameter TARGET_CHIP = 2,
    parameter SYNOPT_ALIGN_FCSEOP = 0,  
                          // 0: no alignment 
                          // 1: align at custom & avalon interface. additional 11 cycle latency in packet to align
                          // 2: align at avalon interface, no extra latency
    parameter RXSIDEBANDWIDTH = 9
)(
    srst, clk_rxmac, rx8l_d, rx8l_sop, rx8l_eop, rx8l_empty, rx8l_sideband, rx8l_fcs_error, rx8l_fcs_valid,
    rx8l_wrfull, rx8l_wrreq, rx4l_d, rx4l_sop, rx4l_idle, rx4l_eop, rx4l_eop_empty, rx4l_sideband, rx4l_fcs_valid, rx4l_valid

);


localparam WORDS_IN = 4;
localparam WORDS = 8;
localparam WORD_LEN = 64;
//localparam EXP_WORD_LEN = WORD_LEN + 1 + 1 + 3 + 1 /* data, sop, eop, eop_empty, fcs_error */;
localparam EXP_WORD_LEN = WORD_LEN + 1 + 1 + 3 + RXSIDEBANDWIDTH /* data, sop, eop, eop_empty, error */;

//--- ports
input               srst;
input               clk_rxmac;     // MAC + PCS clock - at least 312.5Mhz  

output reg  [511:0] rx8l_d;        // 8 lane payload data
output reg          rx8l_sop;
output reg          rx8l_eop;
output reg    [5:0] rx8l_empty;
output              rx8l_fcs_error;
output        [RXSIDEBANDWIDTH-1:0] rx8l_sideband;
output              rx8l_fcs_valid;
input               rx8l_wrfull;
output reg          rx8l_wrreq;

input       [255:0] rx4l_d;        // 4 lane payload to send
input       [4-1:0] rx4l_sop;      // 4 lane start position
input       [4-1:0] rx4l_idle;      // 4 lane idle position
input       [4-1:0] rx4l_eop;      // 4 lane eop position
input       [4*3-1:0] rx4l_eop_empty;   // 4 lane # of empty bytes
input       [RXSIDEBANDWIDTH-1:0]    rx4l_sideband;
input               rx4l_fcs_valid;
input               rx4l_valid;    // payload is accepted


// pipeline input ports
reg [255:0] rx4l_d_q;
reg [3:0]       rx4l_sop_q;
reg [3:0]       rx4l_idle_q;
reg [3:0]       rx4l_eop_q;
reg [RXSIDEBANDWIDTH-1:0]        rx4l_sideband_q;
reg [11:0]      rx4l_eop_empty_q;
//wire            srst;
reg [4:0]         srst_r;

//alt_e100s10_sync_arst sync_arst (clk_rxmac, arst, srst);
always @(posedge clk_rxmac) srst_r[4:0] <= {5{srst}}; // S10TIM arst is actually sync'ed reset

always @(*) begin
   rx4l_sop_q = rx4l_sop;
   rx4l_eop_q = rx4l_eop;
   rx4l_sideband_q = rx4l_sideband;
   rx4l_idle_q = rx4l_idle;
   rx4l_eop_empty_q = rx4l_eop_empty;
   rx4l_d_q = rx4l_d;
end

///////////////////////////////////////////////////////
// compact_words to remove junk data between eop and sop
///////////////////////////////////////////////////////

// convert rx4l_eop_bm_q to rx4l_eopbits (gregg's eopbits notaion);
wire [4*WORDS_IN-1:0] rx4l_eopbits;

genvar i;
generate
        for (i=0; i<WORDS_IN; i= i+1) begin : gen_eopbits
                assign rx4l_eopbits [i*4+3] = rx4l_eop_q[i];
                assign rx4l_eopbits [i*4+2 : i*4] = rx4l_eop_empty_q[i*3+2 : i*3];
        end
endgenerate


// expand to words to { SOP, EOP[3:0], data }
wire [EXP_WORD_LEN*WORDS_IN-1:0] exp_annot;
reg [EXP_WORD_LEN*WORDS_IN-1:0] exp_annot_q;    // input of alt_e100s10_wide_compact_words_8

generate
        for (i=0; i<WORDS_IN; i= i+1) begin : exp_ann
                assign exp_annot [(i+1)*EXP_WORD_LEN-1:i*EXP_WORD_LEN] =
                        {       rx4l_sop_q[i], 
                                rx4l_eopbits[i*4+3 : i*4], 
                                //rx4l_fcs_error_q && rx4l_eop_q[i],
                                rx4l_sideband_q & {RXSIDEBANDWIDTH{rx4l_eop_q[i]}},
                                rx4l_d_q[(i+1)*WORD_LEN-1:i*WORD_LEN]};
        end
endgenerate

// annot_words_valid
reg [3:0]       annot_words_valid;
reg [3:0]       annot_words_valid_q;            // input of alt_e100s10_wide_compact_words_8

always @ (*) annot_words_valid = ~rx4l_idle_q;

////////////////////////////////////////////
// compact used words together on the bus
// e.g. 10001 to 11000
////////////////////////////////////////////

always @ (posedge clk_rxmac)
   if (srst_r[0]) annot_words_valid_q <= 4'b0;
   else      annot_words_valid_q <= annot_words_valid;

always @ (posedge clk_rxmac) exp_annot_q <= exp_annot;

wire [WORDS*EXP_WORD_LEN-1:0] compact_words;            // output of alt_e100s10_wide_compact_words_8
wire [WORDS_IN*EXP_WORD_LEN-1:0] compact_words_4;       // output of alt_e100s10_wide_compact_words_4
wire [3:0] num_compact_words_valid      ;               // output of alt_e100s10_wide_compact_words_8

assign compact_words = {compact_words_4, {{(WORDS-WORDS_IN)*EXP_WORD_LEN}{1'b0}}};
// power-on reset

alt_e100s10_wide_compact_words_4 cw
(
        .clk(clk_rxmac),
        .srst(srst_r[1]),
                
        .din_valid_mask(annot_words_valid_q),
        .din_words(exp_annot_q),
                
        // packed toward more significant end
        .dout_words(compact_words_4),
        .num_dout_words_valid(num_compact_words_valid)  
);
defparam cw .WORDS = WORDS_IN;
defparam cw .WORD_LEN = EXP_WORD_LEN;   

////////////////////////////////////////////
// split back up 
////////////////////////////////////////////

wire [WORDS-1:0] compact_sop;
wire [4*WORDS-1:0] compact_eopbits;
wire [(WORD_LEN+RXSIDEBANDWIDTH)*WORDS-1:0] compact_dat;

generate
        for (i=0; i<WORDS; i= i+1) begin : spl
                assign compact_dat[(i+1)*(WORD_LEN+RXSIDEBANDWIDTH)-1:i*(WORD_LEN+RXSIDEBANDWIDTH)] = compact_words [(i+1)*EXP_WORD_LEN-6:i*EXP_WORD_LEN];
                assign {compact_sop[i], compact_eopbits[(i+1)*4-1:i*4]} = (num_compact_words_valid==0)? 5'b0 :  compact_words [(i+1)*EXP_WORD_LEN-1:(i+1)*EXP_WORD_LEN-5];
 
        end
endgenerate

////////////////////////////////////////////
// realign to SOP boundaries
////////////////////////////////////////////

wire [3:0] num_dout_words_valid;  // 0..8 valid, grouped toward left
wire dout_sop;                    // referring to the first valid word
wire [3:0] dout_eopbits;          // referring to the last valid word
wire [WORDS*(WORD_LEN+RXSIDEBANDWIDTH)-1:0] dout; 
wire overflow;

// power-on reset

alt_e100s10_wide_regroup_8 rg (        
        .clk(clk_rxmac),
        .srst(srst_r[3:2]),
        .din_num_valid(num_compact_words_valid),  // 0..8 valid, grouped toward left
        .din_sop(compact_sop),                  // per input word
        .din_eopbits(compact_eopbits), // per input word        
        .din(compact_dat), 
                
        .dout_num_valid(num_dout_words_valid), // 0..8 valid, grouped toward left
        .dout_sop(dout_sop),                    // referring to the first valid word    
        .dout_eopbits(dout_eopbits),    // referring to the last valid word
        .dout(dout),
        .overflow(overflow)     
);
//defparam rg .WORD_WIDTH = WORD_LEN+1;
defparam rg .WORD_WIDTH = WORD_LEN+RXSIDEBANDWIDTH;
defparam rg .TARGET_CHIP = TARGET_CHIP;

// flop output from alt_e100s10_wide_regroup_8 logic

wire [RXSIDEBANDWIDTH*WORDS-1:0] rx8l_sideband_bits;
generate
        for (i=0; i<WORDS; i=i+1) begin : split_fcs_and_data
                //assign rx8l_fcs_error_bits[i] = dout [(i+1)*(WORD_LEN+1)-1];
                assign rx8l_sideband_bits[(i+1)*RXSIDEBANDWIDTH-1:i*RXSIDEBANDWIDTH] = dout [(i+1)*(WORD_LEN+RXSIDEBANDWIDTH)-1:(i+1)*(WORD_LEN+RXSIDEBANDWIDTH)-RXSIDEBANDWIDTH];
                always @ (posedge clk_rxmac) begin
                        rx8l_d [(i+1)*WORD_LEN-1 : i*WORD_LEN] <= dout [(i+1)*(WORD_LEN+RXSIDEBANDWIDTH)-RXSIDEBANDWIDTH-1:i*(WORD_LEN+RXSIDEBANDWIDTH)];
                end
        end
endgenerate

wire [6:0] rx8l_empty_tmp;
assign rx8l_empty_tmp[6:3] = 4'b1000 - num_dout_words_valid;
assign rx8l_empty_tmp[2:0] =  dout_eopbits[2:0];

reg [RXSIDEBANDWIDTH-1:0] rx8l_sideband_aligned;

always @ (posedge clk_rxmac)
if (srst_r[0]) begin
        rx8l_sop <= 0;
        rx8l_eop <= 0;
        rx8l_empty <= 0; //7'b1000000
        rx8l_wrreq <= 0;
        rx8l_sideband_aligned <= 0;
end
else begin
        rx8l_sop <= dout_sop;
        rx8l_eop <= dout_eopbits [3];
        rx8l_empty <= rx8l_empty_tmp[5:0];
        rx8l_wrreq <= (|num_dout_words_valid);
        //rx8l_sideband <= overflow;
/*
        rx8l_fcs_error_aligned <= (num_dout_words_valid==4'h1 && rx8l_fcs_error_bits[7]) ||
                                  (num_dout_words_valid==4'h2 && rx8l_fcs_error_bits[6]) ||
                                  (num_dout_words_valid==4'h3 && rx8l_fcs_error_bits[5]) ||
                                  (num_dout_words_valid==4'h4 && rx8l_fcs_error_bits[4]) ||
                                  (num_dout_words_valid==4'h5 && rx8l_fcs_error_bits[3]) ||
                                  (num_dout_words_valid==4'h6 && rx8l_fcs_error_bits[2]) ||
                                  (num_dout_words_valid==4'h7 && rx8l_fcs_error_bits[1]) ||
                                  (num_dout_words_valid==4'h8 && rx8l_fcs_error_bits[0]);
*/
        if (num_dout_words_valid==4'h1)      rx8l_sideband_aligned <= rx8l_sideband_bits[8*RXSIDEBANDWIDTH-1:7*RXSIDEBANDWIDTH];
        else if (num_dout_words_valid==4'h2) rx8l_sideband_aligned <= rx8l_sideband_bits[7*RXSIDEBANDWIDTH-1:6*RXSIDEBANDWIDTH];
        else if (num_dout_words_valid==4'h3) rx8l_sideband_aligned <= rx8l_sideband_bits[6*RXSIDEBANDWIDTH-1:5*RXSIDEBANDWIDTH];
        else if (num_dout_words_valid==4'h4) rx8l_sideband_aligned <= rx8l_sideband_bits[5*RXSIDEBANDWIDTH-1:4*RXSIDEBANDWIDTH];
        else if (num_dout_words_valid==4'h5) rx8l_sideband_aligned <= rx8l_sideband_bits[4*RXSIDEBANDWIDTH-1:3*RXSIDEBANDWIDTH];
        else if (num_dout_words_valid==4'h6) rx8l_sideband_aligned <= rx8l_sideband_bits[3*RXSIDEBANDWIDTH-1:2*RXSIDEBANDWIDTH];
        else if (num_dout_words_valid==4'h7) rx8l_sideband_aligned <= rx8l_sideband_bits[2*RXSIDEBANDWIDTH-1:1*RXSIDEBANDWIDTH];
        else if (num_dout_words_valid==4'h8) rx8l_sideband_aligned <= rx8l_sideband_bits[1*RXSIDEBANDWIDTH-1:0*RXSIDEBANDWIDTH];
        else                                 rx8l_sideband_aligned <= 0;
end

wire [RXSIDEBANDWIDTH-1:0] rx8l_sideband;
wire rx8l_fcs_valid;

// align fcs error with eop
generate
   if (SYNOPT_ALIGN_FCSEOP==1) begin
      assign rx8l_sideband     = rx8l_sideband_aligned;
      assign rx8l_fcs_error = rx8l_sideband_aligned[5];
      assign rx8l_fcs_valid = rx8l_eop;
   end
   else if (SYNOPT_ALIGN_FCSEOP==2) begin

      wire [RXSIDEBANDWIDTH-1:0] rdata;
      wire [4:0] used;
      wire       full;
      wire       empty;

      scfifo_mlab #(

        .WIDTH(RXSIDEBANDWIDTH) , // typical 20,40,60,80
        .PREVENT_OVERFLOW (0),      // ignore requests that would cause overflow
        .PREVENT_UNDERFLOW(0),     // ignore requests that would cause underflow
        .ADDR_WIDTH(5),
        .TARGET_CHIP(TARGET_CHIP)

      ) statusff(
        .sclr(srst_r[4]),
        .clk(clk_rxmac),
        .wdata(rx4l_sideband),
        .wreq(rx4l_fcs_valid),
        .full(),
        .rdata(rdata),
        .rreq(dout_eopbits[3]),
        .empty(empty),
        .used(used)
      );
      assign rx8l_sideband  = rdata;
      assign rx8l_fcs_error = rdata[5];
      assign rx8l_fcs_valid = rx8l_eop;
   end
   else begin
      assign rx8l_sideband  = rx4l_sideband;
      assign rx8l_fcs_error = rx4l_sideband[5];
      assign rx8l_fcs_valid = rx4l_fcs_valid;
   end
endgenerate


endmodule
