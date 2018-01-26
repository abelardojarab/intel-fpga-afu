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


// ___________________________________________________________________________
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/mac/alt_aeu_40_hproc_2.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
// ___________________________________________________________________________
// altera message_off 10036 
// ajay dubey 07.22.2013

 module alt_aeu_40_hproc_2 
        #(
         parameter SYNOPT_PREAMBLE_PASS  = 1  
        ,parameter WORDS  = 4  
        ,parameter DPW = (WORDS == 4)? 2*WORDS: (WORDS == 2)? 3*WORDS:0
        ,parameter NUMCOUNTS  = 1  
        ,parameter ERRORBITWIDTH  = 11  
        ,parameter STATSBITWIDTH  = 32  // combined error & stats
         )(
         input wire clk
        ,input wire reset         

        ,input wire cfg_crc_included 
        ,input wire [15:0] cfg_max_frm_length 
        ,input wire cfg_pld_length_chk
        ,input wire cfg_pld_length_include_vlan   
        ,input wire cfg_cntena_phylink_error 
        ,input wire cfg_cntena_oversize_error 
        ,input wire cfg_cntena_undersize_error 
        ,input wire cfg_cntena_pldlength_error 
        ,input wire cfg_cntena_fcs_error 

        ,input wire in_dp_phyerror
        ,input wire in_dp_phyready
        ,input wire in_dp_valid
        ,input wire [WORDS*8-1:0] in_dp_ctrl
        ,input wire [WORDS-1:0] in_dp_idle
        ,input wire [WORDS-1:0] in_dp_sop
        ,input wire [WORDS-1:0] in_dp_eop
        ,input wire [WORDS*64-1:0] in_dp_data
        ,input wire [WORDS*3-1:0] in_dp_eop_empty
 
     // crc inputs are +10 cycles w.r.t in_dp_ signals
        ,input wire in_dpfcs_error              
        ,input wire in_dpfcs_valid 

        ,output reg out_dpfcs_valid 
        ,output reg out_dpfcs_error  
        ,output wire[ERRORBITWIDTH-1:0] out_dp_error
        ,output wire[STATSBITWIDTH-1:0] out_dp_stats
        ,output wire[NUMCOUNTS*16-1:0] out_counts 
        ,output wire[NUMCOUNTS*01-1:0] out_counts_valid

        //Rx control frame indication 
        ,output reg out_rx_ctrl_sfc
        ,output reg out_rx_ctrl_pfc
        ,output reg out_rx_ctrl_other
           
         );

 // ___________________________________________________________________________________________
 //
   localparam 
      TYPCTRL = 16'h8808
     ,TYPJMBO = 16'h8870
     ,VLANTAG = 16'h8100
     ,MINSIZE = 16'd64
     ;
   localparam MIN_FRAME_SIZE= 16'd64;
   localparam FULL_RACK_BYTES = (WORDS == 4)? 16'd32: (WORDS == 2)? 16'd16: 16'd0;

 //
 // ____________________________________________________________________________________________
 //  retiming config signals - relaxed timig
 // ____________________________________________________________________________________________
 //reg chkena_pldlength_rxgttl  = 1'b0;   always@(posedge clk) chkena_pldlength_rxgttl  <= cfg_pld_length_chk[17];
 //reg[15:0] chkena_pldlen_lim  =16'h600; always@(posedge clk) chkena_pldlen_lim        <= cfg_pld_length_chk[15:0]; 
 reg chkena_pldlength_enable    = 1'b1;   always@(posedge clk) chkena_pldlength_enable  <= cfg_pld_length_chk; //[16];
 reg[15:0] chkena_frmsize_max   =16'd9600;always@(posedge clk) chkena_frmsize_max       <= cfg_max_frm_length;


 reg cntena_fcs_error           = 1;       always@(posedge clk) cntena_fcs_error        <= cfg_cntena_fcs_error;
 reg cntena_oversize_error      = 1;       always@(posedge clk) cntena_oversize_error   <= cfg_cntena_oversize_error;
 reg cntena_undersize_error     = 1;       always@(posedge clk) cntena_undersize_error  <= cfg_cntena_undersize_error;
 reg cntena_pldlength_error     = 0;       always@(posedge clk) cntena_pldlength_error  <= cfg_cntena_pldlength_error;
 reg cntena_phyerror            = 0;       always@(posedge clk) cntena_phyerror         <= cfg_cntena_phylink_error;


 // ____________________________________________________________________________________________
 //     pipelining and basic signal generation
 // ____________________________________________________________________________________________

   wire in_valid;
   wire [WORDS*64-1:0] in_data_pre;
   wire [WORDS-1:0] in_sop;
   wire [WORDS-1:0] in_eop;
   wire [WORDS-1:0] in_idle;
   wire [WORDS*8-1:0] in_ctrl;
   wire [WORDS*64-1:0] in_data;
   wire [WORDS*3-1:0] in_eop_empty;

   wire [WORDS*3-1:0] valid_eop_empty ;
   wire [WORDS-1:0]   valid_sop ;
   wire [WORDS-1:0]   valid_eop ;
   wire [4:0]         valid_cycle ;
   wire               valid_idle ;
   wire [4:0]         valid_start ;
   wire               valid_end ;
   wire [2:0]         valid_words ;
   wire [DPW*64-1:0] valid_data; 
   wire in_fcs_error;
   wire in_fcs_valid;

  alt_aeu_dform #(.WORDS (WORDS)
  ) dformat (
         .clk           (clk)
        ,.reset         (reset)

        ,.in_phyready   (in_dp_phyready)
        ,.in_ctrl       (in_dp_ctrl)
        ,.in_idle       (in_dp_idle)
        ,.in_valid      (in_dp_valid     )
        ,.in_sop        (in_dp_sop       )
        ,.in_eop        (in_dp_eop       )
        ,.in_data       (in_dp_data      )
        ,.in_eop_empty  (in_dp_eop_empty )
                         
        ,.in_phy_error  (in_dp_phyerror )
        ,.in_fcs_error  (in_dpfcs_error )
        ,.in_fcs_valid  (in_dpfcs_valid )
        ,.out_phy_error ()
        ,.out_valid     ()
        ,.out_ctrl      ()
        ,.out_idle      (                ) // WORDS wide idle bus
        ,.out_sop       (valid_sop       )
        ,.out_eop       (valid_eop       )
        ,.out_data      (valid_data      )
        ,.out_eop_empty (valid_eop_empty )
        ,.out_valid_start(valid_start    )
        ,.out_valid_end (valid_end       )
        ,.out_valid_cycle(valid_cycle    )
        ,.out_valid_words(valid_words    ) // just for SOP cycles for now
        ,.out_valid_idle(valid_idle    )
 
        ,.out_fcs_error (in_fcs_error )
        ,.out_fcs_valid (in_fcs_valid )
        );

 // _________________________________________________________________________________________________________________
 //     VLAN indication
 // _________________________________________________________________________________________________________________

   wire pkt_type_ctrl; 
   wire pkt_type_data;
   wire pkt_type_rvln;
   wire pkt_type_svln;

 // _________________________________________________________________________________________________________________
 //     Status
 // _________________________________________________________________________________________________________________
    
   reg dphp_p3_size_runt =0;
   reg dphp_p3_size_064  =0;
   reg dphp_p3_size_127  =0;
   reg dphp_p3_size_255  =0;
   reg dphp_p3_size_511  =0;
   reg dphp_p3_size_1023 =0;
   reg dphp_p3_size_1517 =0;
   reg dphp_p3_size_max  =0;
   reg dphp_p3_good_size =0;
   reg dphp_p3_over_size =0;
   reg dphp_p3_under_size=0;
   
   reg lt64 =1'b0;
   reg eq64 =1'b0;
   reg gt64 =1'b0;
   reg gt127 = 1'b0;
   reg gt255 = 1'b0;
   reg gt511 = 1'b0;
   reg gt1023 = 1'b0;
   reg gt1518 = 1'b0;
   reg gtmax = 1'b0;
   reg len_valid_d = 1'b0;
   reg len_valid_pd = 1'b0;

   reg payload_valid = 1'h0;                 
   reg dphp_p1_length_valid = 1'h0;          
   reg dphp_p2_length_valid = 1'b0;          
   reg dphp_p3_length_valid = 1'b0;          

   reg  pkt_cont = 1'b0;         

   reg temp_type_ctrl = 1'b0;    
   reg temp_type_data = 1'b0;    
   reg temp_type_rvln = 1'b0;    
   reg temp_type_svln = 1'b0;    
                                 
   reg[15:0] temp_tlen = 16'd0;  
   reg[15:0] temp_hlen = 16'd0;  
                                 
   reg dp_type_ctrl = 1'b0;      
   reg dp_type_data = 1'b0;      
   reg dp_type_rvln = 1'b0;      
   reg dp_type_svln = 1'b0;      
                                 
   reg dp_opcd_pause = 1'b0;     
   reg dp_ctrl_sfc   = 1'b0;     
   reg dp_ctrl_pfc   = 1'b0;     
   reg dp_ctrl_other = 1'b0;     
                                 
   reg[15:0] dp_hlen = 16'd0;    
   reg dphp_type_ctrl = 1'b0;    
   reg dphp_type_data = 1'b0;    
   reg dphp_type_rvln = 1'b0;    
   reg dphp_type_svln = 1'b0;    
                                 
   reg dphp_ctrl_ucast = 1'b0;   
   reg dphp_ctrl_mcast = 1'b0;   
   reg dphp_ctrl_bcast = 1'b0;   
   reg dphp_ctrl_pause = 1'b0;   
                                 
   reg dphp_ctrl_sfc   = 1'b0;   
   reg dphp_ctrl_pfc   = 1'b0;   
   reg dphp_ctrl_other = 1'b0;   
                                 
   reg dphp_data_ucast = 1'b0;   
   reg dphp_data_mcast = 1'b0;   
   reg dphp_data_bcast = 1'b0;   

 // _________________________________________________________________________________________________________________
 //     packet validator 
 // _________________________________________________________________________________________________________________

   reg pipe_fcs_error = 0;              
   reg pipe_fcs_valid = 0; 
   reg pipe_phyerror = 1'b0; // TBD
   
   always @(posedge clk) 
      begin
           pipe_fcs_error <= in_dpfcs_error; //in_fcs_error;
           pipe_fcs_valid <= in_dpfcs_valid; //n_fcs_valid;
      end


 // _____________________________________________________________________________________________________________________
 // 
 //     collect necessary packet information
 // _____________________________________________________________________________________________________________________

 // valid_* : pipestage = 1 + in_*
 // pkt_*   : pipestage = 1 + valid_* (02 + in_*)
  reg pkt_start =1'b0, pkt_end =1'b0;
  always@(posedge clk) begin pkt_start <= valid_cycle[0] & valid_start[0]; end // duplicated signals per Gregg for depth reduction
  always@(posedge clk) begin pkt_end <=  valid_cycle[1] & valid_end; end
  reg pkt_valid; always@(posedge clk) pkt_valid <= valid_cycle[2]; 
  reg pkt_idle; always@(posedge clk) pkt_idle <= valid_idle; 

  // end of packet words 
   reg[5:0] full_word_ebytes = 6'd0, empty_word_ebytes = 6'd0;// just for eop case 

   generate if (WORDS == 4) 
        begin //_____________________________________________________
             always@(posedge clk) 
                begin
                  if (valid_end) 
                     begin
                        case(valid_eop)
                        4'b1000: begin full_word_ebytes <= 6'd8; empty_word_ebytes <= {3'd0,valid_eop_empty[11:9]};end
                        4'b0100: begin full_word_ebytes <= 6'd16;empty_word_ebytes <= {3'd0,valid_eop_empty[8:6]}; end
                        4'b0010: begin full_word_ebytes <= 6'd24;empty_word_ebytes <= {3'd0,valid_eop_empty[5:3]}; end
                        4'b0001: begin full_word_ebytes <= 6'd32;empty_word_ebytes <= {3'd0,valid_eop_empty[2:0]}; end
                        default: begin full_word_ebytes <= 6'd0; empty_word_ebytes <= {6'd0}; end
                        endcase
                     end
                  else full_word_ebytes <= 6'd00;
                end
        end 
   else if (WORDS == 2) 
        begin //_____________________________________________________
             always@(posedge clk) 
                begin
                  if (valid_end) 
                     begin
                        case(valid_eop)
                        2'b10: begin full_word_ebytes <= 6'd08;empty_word_ebytes <= {3'd0,valid_eop_empty[5:3]}; end
                        2'b01: begin full_word_ebytes <= 6'd16;empty_word_ebytes <= {3'd0,valid_eop_empty[2:0]}; end
                        default: begin full_word_ebytes <= 6'd0; empty_word_ebytes <= {6'd0}; end
                        endcase
                     end
                  else full_word_ebytes <= 6'd00;
                end
        end //_____________________________________________________
   endgenerate

  // start of packet words 
   reg[2:0] full_swords = 3'd0;
   wire[5:0] full_word_sbytes = {full_swords[2:0],3'd0}; // << 3;
   localparam FULL_WORDS_SOP3 = SYNOPT_PREAMBLE_PASS? 3'd3: 3'd4;
   localparam FULL_WORDS_SOP2 = SYNOPT_PREAMBLE_PASS? 3'd2: 3'd3;
   localparam FULL_WORDS_SOP1 = SYNOPT_PREAMBLE_PASS? 3'd1: 3'd2;
   localparam FULL_WORDS_SOP0 = SYNOPT_PREAMBLE_PASS? 3'd0: 3'd1;

   generate if (WORDS == 4) 
        begin //_____________________________________________________
                always@(posedge clk) 
                   begin
                     if (valid_start[1]) 
                        begin
                                case(valid_sop)
                                4'b1000: begin full_swords <= FULL_WORDS_SOP3; end
                                4'b0100: begin full_swords <= FULL_WORDS_SOP2; end
                                4'b0010: begin full_swords <= FULL_WORDS_SOP1; end
                                4'b0001: begin full_swords <= FULL_WORDS_SOP0; end
                                default: begin full_swords <= 3'd0; end 
                                endcase
                        end
                     else full_swords <= 3'd0;
                   end
        end
   else if (WORDS == 2) 
        begin 
                always@(posedge clk) 
                   begin
                     if (valid_start[1]) 
                        begin
                                case(valid_sop)
                                2'b10: begin full_swords <= FULL_WORDS_SOP1; end
                                2'b01: begin full_swords <= FULL_WORDS_SOP0; end
                                default: begin full_swords <= 3'd0; end 
                                endcase
                        end
                     else full_swords <= 3'd0;
                   end
        end //_____________________________________________________
   endgenerate


 // __________________________________________________________________________________________________
 //
 //     generate received frame length
 // __________________________________________________________________________________________________
 // valid_* : pipestage = 1 + in_*
 // pkt_*   : pipestage = 1 + valid_* (02 + in_*)
   reg[15:0] combined_sbytes = 16'd0; 
   always@(posedge clk) combined_sbytes <= {valid_words, 3'd0} ;

   reg[15:0] valid_pkt_bytes = 16'd0; //=0 ;  // excluding eop bytes
   always@(posedge clk) 
     begin
        if (pkt_idle) valid_pkt_bytes <= 16'd0; 
        else if (pkt_start) valid_pkt_bytes <= full_word_sbytes + combined_sbytes; 
        else if (pkt_valid) valid_pkt_bytes <= valid_pkt_bytes + FULL_RACK_BYTES; // 6'd32; 
     end

   reg fwd_dp_crc = 1'b0; always@(posedge clk) fwd_dp_crc <= cfg_crc_included;

 // pipeline intermediate results hre 
 // valid_* : pipestage = 1 + in_*
 // pkt_*   : pipestage = 1 + valid_* (02 + in_*)
 // temp_*  : pipestage = 1 + pkt_*   (03 + in_*)
   reg temp_valid = 1'b0;               always@(posedge clk) temp_valid <= pkt_valid; 
   reg temp_end = 1'b0;                 always@(posedge clk) temp_end <= pkt_end; 
   reg[15:0] temp_pld_bytes = 16'h0;    always@(posedge clk) temp_pld_bytes <= valid_pkt_bytes; 
   reg[5:0] temp_eop_bytes = 6'h0;      always@(posedge clk) if (pkt_end) temp_eop_bytes <= full_word_ebytes - empty_word_ebytes;

 // valid_* : pipestage = 1 + in_*
 // pkt_*   : pipestage = 1 + valid_* (02 + in_*)
 // temp_*  : pipestage = 1 + pkt_*   (03 + in_*)
 // dp_*    : pipestage = 1 + temp_*  (04 + in_*)
   reg dp_end = 1'h0;                   always@(posedge clk) dp_end <= temp_end; 
   reg[15:0] dp_pld_bytes = 16'h0;      always@(posedge clk) dp_pld_bytes <= temp_pld_bytes; 
   reg[5:0] dp_eop_bytes = 6'h0; 
   always@(posedge clk) if (temp_end & fwd_dp_crc) dp_eop_bytes <= temp_eop_bytes; else if (temp_end) dp_eop_bytes <= temp_eop_bytes + 6'd4;


 // valid_* : pipestage = 1 + in_*
 // pkt_*   : pipestage = 1 + valid_* (02 + in_*)
 // temp_*  : pipestage = 1 + pkt_*   (03 + in_*)
 // dp_*    : pipestage = 1 + temp_*  (04 + in_*)
 // dphp_*: pipestage = 1 + temp_*  (05 + dp_*)
   reg dphp_length_valid = 1'h0; 
   reg[15:0] dphp_length = 16'h0;
   always@(posedge clk) 
     begin 
        dphp_length_valid <= dp_end; 
        if (dphp_length_valid) dphp_length <= 0;
        else if (dp_end) dphp_length <= dp_pld_bytes + dp_eop_bytes;
     end
   wire dphp_pkt_end = dphp_length_valid;

  reg[15:0] dphp_hlen= 16'd0; 
  reg[15:0] dphp_tlen= 16'd0; 

 // ________________________________________________________________________________________________________
 //     break wide comparators into small ones
 // ________________________________________________________________________________________________________
 reg[15:0] dp_tlen = 16'd0;  
 reg[15:0] dphp_p1_tlen   = 16'd0; 
 reg[15:0] dphp_p1_payload_length = 16'h0; 
 reg dphp_p2_check_length = 1'b0; 
 reg dphp_p3_check_length = 1'b0; 

 wire dphp_p1_tlen_length  ;       agtb_8  plim_gt_tl (.clk(clk), .inpa(8'h06), .inpb(dp_tlen[15:8]), .out_agtb(dphp_p1_tlen_length));
 wire dphp_p3_payload_nelen_comp;  aneb_18 len_ne_pld (.clk(clk), .inpa({2'd0,dphp_p1_tlen}), .inpb({2'd0,dphp_p1_payload_length}), .out_aneb(dphp_p3_payload_nelen_comp));

 // _________________________________________________________________________________________________________________
 //     PAD handling for length calculation
 // _________________________________________________________________________________________________________________
 //
 reg lvl_p2_minsize_chk = 1'b0;   
 reg lvl_p3_len_neq64   = 1'b0;
   
 reg dphp_pkt_end_type_data_only = 1'b0;   
 reg dphp_pkt_end_type_rvln      = 1'b0;   
 reg dphp_pkt_end_type_svln      = 1'b0;   
                                     
 reg dphp_p1_type_data_only = 1'b0;  
 reg dphp_p1_type_rvln      = 1'b0;  
 reg dphp_p1_type_svln      = 1'b0;  

 // latch signals 
 always@(posedge clk) dphp_pkt_end_type_data_only<= dphp_type_data & (~(dphp_type_rvln | dphp_type_svln));
 always@(posedge clk) dphp_pkt_end_type_rvln     <= dphp_type_rvln ; 
 always@(posedge clk) dphp_pkt_end_type_svln     <= dphp_type_svln ; 

 always@(posedge clk) dphp_p1_type_data_only <= dphp_pkt_end_type_data_only;
 always@(posedge clk) dphp_p1_type_rvln      <= dphp_pkt_end_type_rvln     ;
 always@(posedge clk) dphp_p1_type_svln      <= dphp_pkt_end_type_svln     ;          


 //level signal, change to valid value @dphp_p2_length_valid
 always@(posedge clk) begin
  if(dphp_p1_length_valid) begin
       if(  (dphp_p1_type_data_only &  dphp_p1_tlen <= 16'd46)  
           |(dphp_p1_type_rvln      &  dphp_p1_tlen <= 16'd42)   
           |(dphp_p1_type_svln      &  dphp_p1_tlen <= 16'd38)  
          )  lvl_p2_minsize_chk <= 1'b1;
        else lvl_p2_minsize_chk <= 1'b0; 
     end    
  end  
 //level signal, only change value @dphp_p3_length_valid pulse 
 always @(posedge clk) begin
     if(dphp_p2_length_valid) lvl_p3_len_neq64 <= ~eq64;
  end
   
 reg dphp_p3_payload_nelen   = 1'b0;
 reg dphp_p3_payload_nelen_r = 1'b0;
   
   
 always @(posedge clk) begin
       dphp_p3_payload_nelen_r <= dphp_p3_payload_nelen;
 end
    
 //checking @dphp_p3_length_valid pulse 
 always@(*) begin
    dphp_p3_payload_nelen = dphp_p3_payload_nelen_r;
    if(dphp_p3_length_valid) begin
      dphp_p3_payload_nelen = (lvl_p2_minsize_chk)? lvl_p3_len_neq64 : dphp_p3_payload_nelen_comp;
    end   
 end    

 // ________________________________________________________________________________________________________

  always@(posedge clk) payload_valid <= dphp_length_valid;
  always@(posedge clk) dphp_p1_length_valid <= dphp_length_valid;
  always@(posedge clk) dphp_p2_length_valid <= dphp_p1_length_valid; 
  always@(posedge clk) dphp_p3_length_valid <= dphp_p2_length_valid; 
  always@(posedge clk) if (dphp_length_valid) dphp_p1_payload_length <= dphp_length - dphp_hlen; else dphp_p1_payload_length <= 16'd0;

  reg[15:0] dphp_p2_payload_length = 16'h0; always@(posedge clk) dphp_p2_payload_length <= dphp_p1_payload_length;
  reg[15:0] dphp_p3_payload_length = 16'h0; always@(posedge clk) dphp_p3_payload_length <= dphp_p2_payload_length;
  
  always@(posedge clk) dphp_p1_tlen          <= dphp_tlen;
  always@(posedge clk) dphp_p2_check_length  <= dphp_p1_length_valid && chkena_pldlength_enable && dphp_p1_tlen_length;
  always@(posedge clk) dphp_p3_check_length  <= dphp_p2_check_length;
  wire dphp_p3_pld_lenerr                     = dphp_p3_check_length && (dphp_p3_payload_nelen); // || (chkena_pldlength_rxgttl && dphp_p3_payload_gtlen));

 // ________________________________________________________________________________________________
 // generate error and status information       
 // ________________________________________________________________________________________________
 // valid_* : pipestage = 1 + in_*
 // pkt_*   : pipestage = 1 + valid_* (02 + in_*)
 // temp_*  : pipestage = 1 + pkt_*   (03 + in_*)
 // dp_*    : pipestage = 1 + temp_*  (04 + in_*)
 // dphp_*  : pipestage = 1 + dp_*  (05 + in_*)

 reg [15:0] dphp_length_d = 16'h0;

// break this troublesome compare in half
 wire [7:0] dphp_length_hi, dphp_length_lo;
 wire [7:0] max_frm_length_hi, max_frm_length_lo;

 assign {dphp_length_hi, dphp_length_lo} = dphp_length;
 assign {max_frm_length_hi, max_frm_length_lo} = chkena_frmsize_max;

 reg len_gt_max_a = 1'b0;
 reg len_gt_max_b = 1'b0;
 reg len_gt_max_c = 1'b0;
 always @(posedge clk) 
    begin
        len_gt_max_a <= dphp_length_hi > max_frm_length_hi;
        len_gt_max_b <= dphp_length_hi == max_frm_length_hi;
        len_gt_max_c <= dphp_length_lo > max_frm_length_lo;     
    end

always @(posedge clk) 
   begin
        dphp_length_d <= dphp_length;
        lt64 <= (dphp_length_d <  16'd64);
        eq64 <= (dphp_length_d ==  16'd64);
        gt64 <= (dphp_length_d >  16'd64);
        gt127 <= (dphp_length_d >  16'd127);
        gt255 <= (dphp_length_d >  16'd255);
        gt511 <= (dphp_length_d >  16'd511);
        gt1023 <= (dphp_length_d >  16'd1023);
        gt1518 <= (dphp_length_d >  16'd1518);
        
        gtmax <= len_gt_max_a || (len_gt_max_b && len_gt_max_c);
        
        len_valid_pd <= dphp_length_valid; 
        len_valid_d <= len_valid_pd; 
   end

 always @(posedge clk) dphp_p3_size_runt <= len_valid_d && lt64;
 always @(posedge clk) dphp_p3_size_064  <= len_valid_d && eq64;
 always @(posedge clk) dphp_p3_size_127  <= len_valid_d && gt64   && !gt127;
 always @(posedge clk) dphp_p3_size_255  <= len_valid_d && gt127  && !gt255;
 always @(posedge clk) dphp_p3_size_511  <= len_valid_d && gt255  && !gt511;
 always @(posedge clk) dphp_p3_size_1023 <= len_valid_d && gt511  && !gt1023;
 always @(posedge clk) dphp_p3_size_1517 <= len_valid_d && gt1023 && !gt1518;
 always @(posedge clk) dphp_p3_size_max  <= len_valid_d && gt1518 && !gtmax;
 always @(posedge clk) dphp_p3_good_size <= len_valid_d && !lt64  && !gtmax;
 
 always @(posedge clk) dphp_p3_over_size  <= len_valid_d && gtmax;
 always @(posedge clk) dphp_p3_under_size <= len_valid_d && lt64;

 localparam OPIPE = (WORDS == 4)? 6: (WORDS == 2)? 5: 0; // WORDS other than 2 or 4 are not valid 
 localparam LEN_DLY = (WORDS == 4)? OPIPE - 2: (WORDS == 2)? OPIPE-2:0;

 reg[LEN_DLY-1:0] opipe_size_runt = {LEN_DLY{1'b0}}; 
 reg[LEN_DLY-1:0] opipe_size_064 = {LEN_DLY{1'b0}};  
 reg[LEN_DLY-1:0] opipe_size_127 = {LEN_DLY{1'b0}};  
 reg[LEN_DLY-1:0] opipe_size_255 = {LEN_DLY{1'b0}};  
 reg[LEN_DLY-1:0] opipe_size_511 = {LEN_DLY{1'b0}};   
 reg[LEN_DLY-1:0] opipe_size_1023 = {LEN_DLY{1'b0}};    
 reg[LEN_DLY-1:0] opipe_size_1517  = {LEN_DLY{1'b0}};    
 reg[LEN_DLY-1:0] opipe_size_max = {LEN_DLY{1'b0}};     
 
 reg[LEN_DLY-1:0] opipe_good_size = {LEN_DLY{1'b0}};    
 reg[LEN_DLY-1:0] opipe_over_size = {LEN_DLY{1'b0}};    
 reg[LEN_DLY-1:0] opipe_under_size = {LEN_DLY{1'b0}};   
 reg[LEN_DLY-1:0] opipe_pld_lenerr = {LEN_DLY{1'b0}};   
 reg[LEN_DLY*16-1:0] opipe_pld_len = {LEN_DLY{16'd0}}; 
 
 always @(posedge clk) opipe_size_runt  <= {opipe_size_runt  [LEN_DLY-2:0], dphp_p3_size_runt}; 
 always @(posedge clk) opipe_size_064   <= {opipe_size_064   [LEN_DLY-2:0], dphp_p3_size_064};  
 always @(posedge clk) opipe_size_127   <= {opipe_size_127   [LEN_DLY-2:0], dphp_p3_size_127};  
 always @(posedge clk) opipe_size_255   <= {opipe_size_255   [LEN_DLY-2:0], dphp_p3_size_255};  
 always @(posedge clk) opipe_size_511   <= {opipe_size_511   [LEN_DLY-2:0], dphp_p3_size_511};  
 always @(posedge clk) opipe_size_1023  <= {opipe_size_1023  [LEN_DLY-2:0], dphp_p3_size_1023}; 
 always @(posedge clk) opipe_size_1517  <= {opipe_size_1517  [LEN_DLY-2:0], dphp_p3_size_1517}; 
 always @(posedge clk) opipe_size_max   <= {opipe_size_max   [LEN_DLY-2:0], dphp_p3_size_max};  
 
 always @(posedge clk) opipe_good_size  <= {opipe_good_size  [LEN_DLY-2:0], dphp_p3_good_size};   
 always @(posedge clk) opipe_over_size  <= {opipe_over_size  [LEN_DLY-2:0], dphp_p3_over_size}; 
 always @(posedge clk) opipe_under_size <= {opipe_under_size [LEN_DLY-2:0], dphp_p3_under_size};
 always @(posedge clk) opipe_pld_lenerr <= {opipe_pld_lenerr [LEN_DLY-2:0], dphp_p3_pld_lenerr}; 
 always @(posedge clk) opipe_pld_len    <= {opipe_pld_len    [16*(LEN_DLY-2)-1:0], dphp_p3_payload_length};
 
 
 wire out_size_runt;    
 wire out_size_064 ;     
 wire out_size_127 ;     
 wire out_size_255 ;     
 wire out_size_511 ;     
 wire out_size_1023;    
 wire out_size_1517;    
 wire out_size_max ;     
 wire out_over_size;    
 wire out_plen_error;    

 reg out_err_fcs_oksize=0;
 reg out_err_frgmt_frm=0;
 reg out_err_jbbr_frm=0; 

 always @(posedge clk) out_err_fcs_oksize <= pipe_fcs_valid & pipe_fcs_error & dphp_p3_good_size ; //opipe_good_size  [LEN_DLY-3];   
 always @(posedge clk) out_err_frgmt_frm  <= pipe_fcs_valid & pipe_fcs_error & dphp_p3_under_size; //opipe_under_size [LEN_DLY-3];
 always @(posedge clk) out_err_jbbr_frm   <= pipe_fcs_valid & pipe_fcs_error & dphp_p3_over_size ; //opipe_over_size  [LEN_DLY-3]; 
                                                
 wire fcs_aligned_error = 
                        | (cntena_oversize_error  &  dphp_p3_over_size)                         // opipe_over_size [LEN_DLY-3])
                        | (cntena_undersize_error &  dphp_p3_under_size)                        // opipe_under_size[LEN_DLY-3])
                        | (cntena_fcs_error       &  pipe_fcs_valid & pipe_fcs_error)
                        | (cntena_pldlength_error &  dphp_p3_pld_lenerr)                        // opipe_pld_lenerr[LEN_DLY-3])
                        | (cntena_phyerror        &  pipe_phyerror); 

 reg payload_length_valid = 1'd0; 
 reg[15:0] payload_length = 16'd0; 

 always@(posedge clk) payload_length <= fcs_aligned_error? 16'd0: dphp_p3_payload_length; // opipe_pld_len[16*(LEN_DLY-2)-1:16*(LEN_DLY-3)];
 always@(posedge clk) payload_length_valid <= fcs_aligned_error? 1'd0: dphp_p3_length_valid; // opipe_pld_len[16*(LEN_DLY-2)-1:16*(LEN_DLY-3)];


 // _________________________________________________________________________________________________________________
 //
 //     VLAN payload length count including VLAN TAG       
 // _________________________________________________________________________________________________________________
 //
 reg [15:0] payload_length_vlan   = 16'h0;
 reg dphp_p2_type_rvln      = 1'b0;  
 reg dphp_p2_type_svln      = 1'b0;  
 reg dphp_p3_type_rvln      = 1'b0;  
 reg dphp_p3_type_svln      = 1'b0;  

 // latch signals 
 always@(posedge clk) dphp_p2_type_rvln      <= dphp_p1_type_rvln;
 always@(posedge clk) dphp_p2_type_svln      <= dphp_p1_type_svln;     
 always@(posedge clk) dphp_p3_type_rvln      <= dphp_p2_type_rvln;
 always@(posedge clk) dphp_p3_type_svln      <= dphp_p2_type_svln;     

 always@(posedge clk) begin
    if ((~cfg_pld_length_include_vlan) | fcs_aligned_error) begin 
      payload_length_vlan <= 16'd0;
    end   
    else begin
      if( dphp_p3_type_rvln)       payload_length_vlan <= dphp_p3_payload_length + 16'd4; //regular vlan
      else if (dphp_p3_type_svln)  payload_length_vlan <= dphp_p3_payload_length + 16'd8; //stacked vlan
      else                         payload_length_vlan <= dphp_p3_payload_length;         //no vlan   
    end    
 end   
   
 // _____________________________________________________________________________
 // synthesis translate_off
 // _____________________________________________________________________________

 reg[63:0] packet_count = 64'h0; always@(posedge clk) if (dphp_p3_length_valid) packet_count <= packet_count + 1; // for debug only
 reg[63:0] payload_count = 64'h0;always@(posedge clk) payload_count  <= payload_count + payload_length ;
 reg[63:0] payload_count2= 64'h0;always@(posedge clk) payload_count2 <= payload_count + valid_pkt_bytes ;
 // always@(posedge dphp_p3_length_valid) $display ("%m: Pkt# %3d, Payload_byte=%6d\n",packet_count, payload_count); 
 // always@(posedge (fcs_aligned_error&dphp_p3_length_valid)) $display ("%m: Pkt# %3d, AN ERROR WAS GENERATED with Length_error = %1b",packet_count,fcs_aligned_error ); 
 // _____________________________________________________________________________
 // synthesis translate_on
 // _____________________________________________________________________________
 
 assign out_size_runt  = opipe_size_runt [LEN_DLY-3]; // dphp_p3_size_runt; // opipe_size_runt [LEN_DLY-2]; 
 assign out_size_064   = opipe_size_064  [LEN_DLY-3]; // dphp_p3_size_064 ; // opipe_size_064  [LEN_DLY-2]; 
 assign out_size_127   = opipe_size_127  [LEN_DLY-3]; // dphp_p3_size_127 ; // opipe_size_127  [LEN_DLY-2];     
 assign out_size_255   = opipe_size_255  [LEN_DLY-3]; // dphp_p3_size_255 ; // opipe_size_255  [LEN_DLY-2];     
 assign out_size_511   = opipe_size_511  [LEN_DLY-3]; // dphp_p3_size_511 ; // opipe_size_511  [LEN_DLY-2];     
 assign out_size_1023  = opipe_size_1023 [LEN_DLY-3]; // dphp_p3_size_1023; // opipe_size_1023 [LEN_DLY-2]; 
 assign out_size_1517  = opipe_size_1517 [LEN_DLY-3]; // dphp_p3_size_1517; // opipe_size_1517 [LEN_DLY-2]; 
 assign out_size_max   = opipe_size_max  [LEN_DLY-3]; // dphp_p3_size_max ; // opipe_size_max  [LEN_DLY-2];  
 assign out_over_size  = opipe_over_size [LEN_DLY-3]; // dphp_p3_over_size; // opipe_over_size [LEN_DLY-2]; 
 assign out_plen_error = opipe_pld_lenerr [LEN_DLY-3]; // dphp_p3_pld_lenerr;// opipe_over_size [LEN_DLY-2]; 
 
 // ________________________________________________________________________________________________
 // 
 //     packet address processing
 // ________________________________________________________________________________________________
  localparam SBYTE_DEST_ADDR = 01, EBYTE_DEST_ADDR = 06;

  localparam SBYTE_NORM_TLEN = 13, EBYTE_NORM_TLEN = 14; 
  localparam SBYTE_CTRL_TLEN = 15, EBYTE_CTRL_TLEN = 16;
  localparam SBYTE_VLAN_TLEN = 17, EBYTE_VLAN_TLEN = 18; 
  localparam SBYTE_SVLAN_TLEN = 21, EBYTE_SVLAN_TLEN = 22; 
  //    regular packet headers 
  //            : EthTyp = Bytes[13,14], 
  //            : OpCode = Bytes[15,16]
  //    vlan tagged packet headers 
  //            : VlanTag = Bytes[13,14] 
  //            : EthType = Bytes[17,18]

  //    svlan tagged packet headers 
  //            : VLanTag = Bytes[13,14] 
  //            : SVLanTag= Bytes[17,18] 
  //            : EthType = Bytes[21,22]

  localparam PP = SYNOPT_PREAMBLE_PASS;
 // _______________________________________________________________________________________
 //
 // valid_* : pipestage = 1 + in_*
 // pkt_*   : pipestage = 1 + valid_* (02 + in_*)
   reg[47:0] pkt_da = 48'h0 ; 
   reg[15:0] pkt_norm_tlen = 16'h0 ; 
   reg[15:0] pkt_opcd = 16'h0 ; 

   reg[15:0] pkt_rvln_tlen= 16'h0 ; 
   reg[15:0] pkt_svln_tlen= 16'h0 ; 

   reg pkt_type_ctrl_hi = 1'b0;
   reg pkt_type_ctrl_lo = 1'b0;
   reg pkt_type_rvln_hi = 1'b0; // regular vlan 
   reg pkt_type_rvln_lo = 1'b0;                 
   reg pkt_type_svln_hi = 1'b0; // stacked vlan 
   reg pkt_type_svln_lo = 1'b0;
  
   generate if (WORDS == 4)
      begin
           wire[47:0] valid_dest_addr_3 = valid_data [8*(8*(DPW-0 -PP)-(SBYTE_DEST_ADDR -1))-1 : 8*(8*(DPW-0 -PP)-EBYTE_DEST_ADDR )];
           wire[47:0] valid_dest_addr_2 = valid_data [8*(8*(DPW-1 -PP)-(SBYTE_DEST_ADDR -1))-1 : 8*(8*(DPW-1 -PP)-EBYTE_DEST_ADDR )];
           wire[47:0] valid_dest_addr_1 = valid_data [8*(8*(DPW-2 -PP)-(SBYTE_DEST_ADDR -1))-1 : 8*(8*(DPW-2 -PP)-EBYTE_DEST_ADDR )];
           wire[47:0] valid_dest_addr_0 = valid_data [8*(8*(DPW-3 -PP)-(SBYTE_DEST_ADDR -1))-1 : 8*(8*(DPW-3 -PP)-EBYTE_DEST_ADDR )];
           
           wire[15:0] valid_norm_tlen_3 = valid_data [8*(8*(DPW-0 -PP)-(SBYTE_NORM_TLEN -1))-1 : 8*(8*(DPW-0 -PP)-EBYTE_VLAN_TLEN )];
           wire[15:0] valid_norm_tlen_2 = valid_data [8*(8*(DPW-1 -PP)-(SBYTE_NORM_TLEN -1))-1 : 8*(8*(DPW-1 -PP)-EBYTE_VLAN_TLEN )];
           wire[15:0] valid_norm_tlen_1 = valid_data [8*(8*(DPW-2 -PP)-(SBYTE_NORM_TLEN -1))-1 : 8*(8*(DPW-2 -PP)-EBYTE_VLAN_TLEN )];
           wire[15:0] valid_norm_tlen_0 = valid_data [8*(8*(DPW-3 -PP)-(SBYTE_NORM_TLEN -1))-1 : 8*(8*(DPW-3 -PP)-EBYTE_VLAN_TLEN )];
           
           wire[15:0] valid_ctrl_tlen_3 = valid_data [8*(8*(DPW-0 -PP)-(SBYTE_CTRL_TLEN -1))-1 : 8*(8*(DPW-0 -PP)-EBYTE_CTRL_TLEN )];
           wire[15:0] valid_ctrl_tlen_2 = valid_data [8*(8*(DPW-1 -PP)-(SBYTE_CTRL_TLEN -1))-1 : 8*(8*(DPW-1 -PP)-EBYTE_CTRL_TLEN )];
           wire[15:0] valid_ctrl_tlen_1 = valid_data [8*(8*(DPW-2 -PP)-(SBYTE_CTRL_TLEN -1))-1 : 8*(8*(DPW-2 -PP)-EBYTE_CTRL_TLEN )];
           wire[15:0] valid_ctrl_tlen_0 = valid_data [8*(8*(DPW-3 -PP)-(SBYTE_CTRL_TLEN -1))-1 : 8*(8*(DPW-3 -PP)-EBYTE_CTRL_TLEN )];
           
           
           wire[15:0] valid_rvln_tlen_3 = valid_data [8*(8*(DPW-0 -PP)-(SBYTE_VLAN_TLEN -1))-1 : 8*(8*(DPW-0 -PP)-EBYTE_VLAN_TLEN )];
           wire[15:0] valid_rvln_tlen_2 = valid_data [8*(8*(DPW-1 -PP)-(SBYTE_VLAN_TLEN -1))-1 : 8*(8*(DPW-1 -PP)-EBYTE_VLAN_TLEN )];
           wire[15:0] valid_rvln_tlen_1 = valid_data [8*(8*(DPW-2 -PP)-(SBYTE_VLAN_TLEN -1))-1 : 8*(8*(DPW-2 -PP)-EBYTE_VLAN_TLEN )];
           wire[15:0] valid_rvln_tlen_0 = valid_data [8*(8*(DPW-3 -PP)-(SBYTE_VLAN_TLEN -1))-1 : 8*(8*(DPW-3 -PP)-EBYTE_VLAN_TLEN )];
           
           wire[15:0] valid_svln_tlen_3 = valid_data [8*(8*(DPW-0 -PP)-(SBYTE_SVLAN_TLEN-1))-1 : 8*(8*(DPW-0 -PP)-EBYTE_SVLAN_TLEN)];
           wire[15:0] valid_svln_tlen_2 = valid_data [8*(8*(DPW-1 -PP)-(SBYTE_SVLAN_TLEN-1))-1 : 8*(8*(DPW-1 -PP)-EBYTE_SVLAN_TLEN)];
           wire[15:0] valid_svln_tlen_1 = valid_data [8*(8*(DPW-2 -PP)-(SBYTE_SVLAN_TLEN-1))-1 : 8*(8*(DPW-2 -PP)-EBYTE_SVLAN_TLEN)];
           wire[15:0] valid_svln_tlen_0 = valid_data [8*(8*(DPW-3 -PP)-(SBYTE_SVLAN_TLEN-1))-1 : 8*(8*(DPW-3 -PP)-EBYTE_SVLAN_TLEN)];
           
           wire valid_type_ctrl_hi_3    = (valid_norm_tlen_3[15:8] == 8'h88);
           wire valid_type_ctrl_lo_3    = (valid_norm_tlen_3[07:0] == 8'h08);
           wire valid_type_rvln_hi_3    = (valid_norm_tlen_3[15:8] == 8'h81);
           wire valid_type_rvln_lo_3    = (valid_norm_tlen_3[07:0] == 8'h00);
           wire valid_type_svln_hi_3    = (valid_rvln_tlen_3[15:8] == 8'h81);
           wire valid_type_svln_lo_3    = (valid_rvln_tlen_3[07:0] == 8'h00);

           wire valid_type_ctrl_hi_2    = (valid_norm_tlen_2[15:8] == 8'h88);
           wire valid_type_ctrl_lo_2    = (valid_norm_tlen_2[07:0] == 8'h08);
           wire valid_type_rvln_hi_2    = (valid_norm_tlen_2[15:8] == 8'h81);
           wire valid_type_rvln_lo_2    = (valid_norm_tlen_2[07:0] == 8'h00);
           wire valid_type_svln_hi_2    = (valid_rvln_tlen_2[15:8] == 8'h81);
           wire valid_type_svln_lo_2    = (valid_rvln_tlen_2[07:0] == 8'h00);

           wire valid_type_ctrl_hi_1    = (valid_norm_tlen_1[15:8] == 8'h88);
           wire valid_type_ctrl_lo_1    = (valid_norm_tlen_1[07:0] == 8'h08);
           wire valid_type_rvln_hi_1    = (valid_norm_tlen_1[15:8] == 8'h81);
           wire valid_type_rvln_lo_1    = (valid_norm_tlen_1[07:0] == 8'h00);
           wire valid_type_svln_hi_1    = (valid_rvln_tlen_1[15:8] == 8'h81);
           wire valid_type_svln_lo_1    = (valid_rvln_tlen_1[07:0] == 8'h00);

           wire valid_type_ctrl_hi_0    = (valid_norm_tlen_0[15:8] == 8'h88);
           wire valid_type_ctrl_lo_0    = (valid_norm_tlen_0[07:0] == 8'h08);
           wire valid_type_rvln_hi_0    = (valid_norm_tlen_0[15:8] == 8'h81);
           wire valid_type_rvln_lo_0    = (valid_norm_tlen_0[07:0] == 8'h00);
           wire valid_type_svln_hi_0    = (valid_rvln_tlen_0[15:8] == 8'h81);
           wire valid_type_svln_lo_0    = (valid_rvln_tlen_0[07:0] == 8'h00);

  // _______________________________________________________________________________________
         always@(posedge clk) 
            begin
              if (valid_start[2]) 
                 begin
                 case(valid_sop)
                 4'b1000: 
                        begin 
                           pkt_da           <= valid_dest_addr_3;
                           pkt_opcd         <= valid_ctrl_tlen_3; 
                           pkt_norm_tlen    <= valid_norm_tlen_3;
                           pkt_rvln_tlen    <= valid_rvln_tlen_3;
                           pkt_svln_tlen    <= valid_svln_tlen_3;
           
                           pkt_type_ctrl_hi <= valid_type_ctrl_hi_3;
                           pkt_type_ctrl_lo <= valid_type_ctrl_lo_3;
                           pkt_type_rvln_hi <= valid_type_rvln_hi_3;
                           pkt_type_rvln_lo <= valid_type_rvln_lo_3;
                           pkt_type_svln_hi <= valid_type_svln_hi_3;
                           pkt_type_svln_lo <= valid_type_svln_lo_3;
                        end
                 4'b0100: 
                        begin 
                           pkt_da           <= valid_dest_addr_2;
                           pkt_opcd         <= valid_ctrl_tlen_2; 
                           pkt_norm_tlen    <= valid_norm_tlen_2;
                           pkt_rvln_tlen    <= valid_rvln_tlen_2;
                           pkt_svln_tlen    <= valid_svln_tlen_2;
           
                           pkt_type_ctrl_hi <= valid_type_ctrl_hi_2;
                           pkt_type_ctrl_lo <= valid_type_ctrl_lo_2;
                           pkt_type_rvln_hi <= valid_type_rvln_hi_2;
                           pkt_type_rvln_lo <= valid_type_rvln_lo_2;
                           pkt_type_svln_hi <= valid_type_svln_hi_2;
                           pkt_type_svln_lo <= valid_type_svln_lo_2;
                        end
                 4'b0010: 
                        begin 
                           pkt_da           <= valid_dest_addr_1;
                           pkt_opcd         <= valid_ctrl_tlen_1; 
                           pkt_norm_tlen    <= valid_norm_tlen_1;
                           pkt_rvln_tlen    <=  valid_rvln_tlen_1;
                           pkt_svln_tlen    <=  valid_svln_tlen_1;
           
                           pkt_type_ctrl_hi <= valid_type_ctrl_hi_1;
                           pkt_type_ctrl_lo <= valid_type_ctrl_lo_1;
                           pkt_type_rvln_hi <= valid_type_rvln_hi_1;
                           pkt_type_rvln_lo <= valid_type_rvln_lo_1;
                           pkt_type_svln_hi <= valid_type_svln_hi_1;
                           pkt_type_svln_lo <= valid_type_svln_lo_1;
                        end
                 4'b0001: 
                        // 6B daddr and 2B saddr in current cycle
                        // 4B saddr 2B tlen and 2B opcode in next valid cycle
                        // if (valid_cycle_0)
                        begin 
                           pkt_da           <= valid_dest_addr_0;
                           pkt_opcd         <= valid_ctrl_tlen_0; 
                           pkt_norm_tlen    <= valid_norm_tlen_0;
                           pkt_rvln_tlen    <= valid_rvln_tlen_0;
                           pkt_svln_tlen    <= valid_svln_tlen_0;
           
                           pkt_type_ctrl_hi <= valid_type_ctrl_hi_0;
                           pkt_type_ctrl_lo <= valid_type_ctrl_lo_0;
                           pkt_type_rvln_hi <= valid_type_rvln_hi_0;
                           pkt_type_rvln_lo <= valid_type_rvln_lo_0;
                           pkt_type_svln_hi <= valid_type_svln_hi_0;
                           pkt_type_svln_lo <= valid_type_svln_lo_0;
                        end
                 default: 
                        begin 
                           pkt_da       <= pkt_da;
                           pkt_opcd     <= pkt_opcd; 
                           pkt_norm_tlen<= pkt_norm_tlen;
                           pkt_rvln_tlen<= pkt_rvln_tlen;
                           pkt_svln_tlen<= pkt_svln_tlen;
           
                           pkt_type_ctrl_hi <= 1'b0;
                           pkt_type_ctrl_lo <= 1'b0;
                           pkt_type_rvln_hi <= 1'b0;
                           pkt_type_rvln_lo <= 1'b0;
                           pkt_type_svln_hi <= 1'b0;
                           pkt_type_svln_lo <= 1'b0;
                        end //
                 endcase
                 end
              end
      end // 4W_slices
// _______________________________________________________________
   else if (WORDS == 2)
      begin
// _______________________________________________________________
           wire[47:0] valid_dest_addr_3 = valid_data [8*(8*(DPW-0 -PP)-(SBYTE_DEST_ADDR -1))-1 : 8*(8*(DPW-0 -PP)-EBYTE_DEST_ADDR )];
           wire[47:0] valid_dest_addr_2 = valid_data [8*(8*(DPW-1 -PP)-(SBYTE_DEST_ADDR -1))-1 : 8*(8*(DPW-1 -PP)-EBYTE_DEST_ADDR )];
           
           wire[15:0] valid_norm_tlen_3 = valid_data [8*(8*(DPW-0 -PP)-(SBYTE_NORM_TLEN -1))-1 : 8*(8*(DPW-0 -PP)-EBYTE_NORM_TLEN )];
           wire[15:0] valid_norm_tlen_2 = valid_data [8*(8*(DPW-1 -PP)-(SBYTE_NORM_TLEN -1))-1 : 8*(8*(DPW-1 -PP)-EBYTE_NORM_TLEN )];
           
           wire[15:0] valid_rvln_tlen_3 = valid_data [8*(8*(DPW-0 -PP)-(SBYTE_VLAN_TLEN -1))-1 : 8*(8*(DPW-0 -PP)-EBYTE_VLAN_TLEN )];
           wire[15:0] valid_rvln_tlen_2 = valid_data [8*(8*(DPW-1 -PP)-(SBYTE_VLAN_TLEN -1))-1 : 8*(8*(DPW-1 -PP)-EBYTE_VLAN_TLEN )];
           
           wire[15:0] valid_svln_tlen_3 = valid_data [8*(8*(DPW-0 -PP)-(SBYTE_SVLAN_TLEN-1))-1 : 8*(8*(DPW-0 -PP)-EBYTE_SVLAN_TLEN)];
           wire[15:0] valid_svln_tlen_2 = valid_data [8*(8*(DPW-1 -PP)-(SBYTE_SVLAN_TLEN-1))-1 : 8*(8*(DPW-1 -PP)-EBYTE_SVLAN_TLEN)];
           
           wire[15:0] valid_ctrl_tlen_3 = valid_data [8*(8*(DPW-0 -PP)-(SBYTE_CTRL_TLEN -1))-1 : 8*(8*(DPW-0 -PP)-EBYTE_CTRL_TLEN )];
           wire[15:0] valid_ctrl_tlen_2 = valid_data [8*(8*(DPW-1 -PP)-(SBYTE_CTRL_TLEN -1))-1 : 8*(8*(DPW-1 -PP)-EBYTE_CTRL_TLEN )];
           
           wire valid_type_ctrl_hi_3    = (valid_norm_tlen_3[15:8] == 8'h88);
           wire valid_type_ctrl_lo_3    = (valid_norm_tlen_3[07:0] == 8'h08);
           wire valid_type_rvln_hi_3    = (valid_norm_tlen_3[15:8] == 8'h81);
           wire valid_type_rvln_lo_3    = (valid_norm_tlen_3[07:0] == 8'h00);
           wire valid_type_svln_hi_3    = (valid_rvln_tlen_3[15:8] == 8'h81);
           wire valid_type_svln_lo_3    = (valid_rvln_tlen_3[07:0] == 8'h00);

           wire valid_type_ctrl_hi_2    = (valid_norm_tlen_2[15:8] == 8'h88);
           wire valid_type_ctrl_lo_2    = (valid_norm_tlen_2[07:0] == 8'h08);
           wire valid_type_rvln_hi_2    = (valid_norm_tlen_2[15:8] == 8'h81);
           wire valid_type_rvln_lo_2    = (valid_norm_tlen_2[07:0] == 8'h00);
           wire valid_type_svln_hi_2    = (valid_rvln_tlen_2[15:8] == 8'h81);
           wire valid_type_svln_lo_2    = (valid_rvln_tlen_2[07:0] == 8'h00);

           always@(posedge clk) 
            begin
              if (valid_start[2]) 
                 begin
                 case(valid_sop)
                 2'b10: 
                        begin 
                           pkt_da           <= valid_dest_addr_3;
                           pkt_opcd         <= valid_ctrl_tlen_3; 
                           pkt_norm_tlen    <= valid_norm_tlen_3;
                           pkt_rvln_tlen    <= valid_rvln_tlen_3;
                           pkt_svln_tlen    <= valid_svln_tlen_3;
           
                           pkt_type_ctrl_hi <= valid_type_ctrl_hi_3;
                           pkt_type_ctrl_lo <= valid_type_ctrl_lo_3;
                           pkt_type_rvln_hi <= valid_type_rvln_hi_3;
                           pkt_type_rvln_lo <= valid_type_rvln_lo_3;
                           pkt_type_svln_hi <= valid_type_svln_hi_3;
                           pkt_type_svln_lo <= valid_type_svln_lo_3;
                        end
                 2'b01: 
                        begin 
                           pkt_da           <= valid_dest_addr_2;
                           pkt_opcd         <= valid_ctrl_tlen_2; 
                           pkt_norm_tlen    <= valid_norm_tlen_2;
                           pkt_rvln_tlen    <= valid_rvln_tlen_2;
                           pkt_svln_tlen    <= valid_svln_tlen_2;
           
                           pkt_type_ctrl_hi <= valid_type_ctrl_hi_2;
                           pkt_type_ctrl_lo <= valid_type_ctrl_lo_2;
                           pkt_type_rvln_hi <= valid_type_rvln_hi_2;
                           pkt_type_rvln_lo <= valid_type_rvln_lo_2;
                           pkt_type_svln_hi <= valid_type_svln_hi_2;
                           pkt_type_svln_lo <= valid_type_svln_lo_2;
                        end
                 default: 
                        begin 
                           pkt_da       <= pkt_da;
                           pkt_opcd     <= pkt_opcd; 
                           pkt_norm_tlen<= pkt_norm_tlen;
                           pkt_rvln_tlen<= pkt_rvln_tlen;
                           pkt_svln_tlen<= pkt_svln_tlen;
           
                           pkt_type_ctrl_hi <= 1'b0;
                           pkt_type_ctrl_lo <= 1'b0;
                           pkt_type_rvln_hi <= 1'b0;
                           pkt_type_rvln_lo <= 1'b0;
                           pkt_type_svln_hi <= 1'b0;
                           pkt_type_svln_lo <= 1'b0;
                        end //
                 endcase
                 end
            end
// _______________________________________________________________
      end // 2w 
// _______________________________________________________________
   endgenerate

 // valid_* : pipestage = 1 + in_*
 // pkt_*   : pipestage = 1 + valid_* (02 + in_*)
 // temp_*  : pipestage = 1 + pkt_*   (03 + in_*)
 // dp_*    : pipestage = 1 + temp_*  (04 + in_*)

   reg pkt_singlecycle= 0; always@(posedge clk) pkt_singlecycle  <= pkt_valid & pkt_start & pkt_end;
   wire [23:0] pkt_da_hi, pkt_da_lo;
   assign {pkt_da_hi, pkt_da_lo} = pkt_da;

   reg temp_last_40 = 1'b0;       always @(posedge clk) temp_last_40 <= pkt_da[40];
   reg temp_addr_bcast_hi = 1'b0; always @(posedge clk) temp_addr_bcast_hi <= &pkt_da_hi;
   reg temp_addr_bcast_lo = 1'b0; always @(posedge clk) temp_addr_bcast_lo <= &pkt_da_lo;

   reg dp_addr_mcast = 0;
   reg dp_addr_bcast = 0;
   reg dp_addr_ucast = 0;

   always @(posedge clk) dp_addr_mcast <= pkt_valid && (pkt_end|pkt_singlecycle) && temp_last_40 && !(temp_addr_bcast_hi && temp_addr_bcast_lo);
   always @(posedge clk) dp_addr_bcast <= pkt_valid && (pkt_end|pkt_singlecycle) && temp_addr_bcast_hi && temp_addr_bcast_lo;
   always @(posedge clk) dp_addr_ucast <= pkt_valid && (pkt_end|pkt_singlecycle) && !temp_last_40;

   reg dphp_addr_mcast = 0; always@(posedge clk) dphp_addr_mcast <= dp_addr_mcast; 
   reg dphp_addr_bcast = 0; always@(posedge clk) dphp_addr_bcast <= dp_addr_bcast; 
   reg dphp_addr_ucast = 0; always@(posedge clk) dphp_addr_ucast <= dp_addr_ucast; 


 
 // ________________________________________________________________________________________________
 // 
 //     packet type & length processing
 // ________________________________________________________________________________________________
 
 // valid_* : pipestage = 1 + in_*
 // pkt_*   : pipestage = 1 + valid_* (02 + in_*)
 // temp_*  : pipestage = 1 + pkt_*   (03 + in_*)
 // dp_*    : pipestage = 1 + temp_*  (04 + in_*)
 // decode pkt types
 // valid_* : pipestage = 1 + in_*
 // pkt_*   : pipestage = 1 + valid_* (02 + in_*)
 // temp_*  : pipestage = 1 + pkt_*   (03 + in_*)
 // dp_*    : pipestage = 1 + temp_*  (04 + in_*)
 // dphp_*  : pipestage = 1 + temp_*  (05 + dp_*)

  reg temp_opcd_sfc = 1'b0;   always@(posedge clk)  temp_opcd_sfc   <=(pkt_opcd == 16'h0001); // TBD: change to valid_data for generic code like length and type processing 
  reg temp_opcd_pfc = 1'b0;   always@(posedge clk)  temp_opcd_pfc   <=(pkt_opcd == 16'h0101); // TBD: change to valid_data for generic code like length and type processing 

  assign  pkt_type_ctrl =   pkt_type_ctrl_hi && pkt_type_ctrl_lo;
  assign  pkt_type_data = ~(pkt_type_ctrl_hi && pkt_type_ctrl_lo);
  assign  pkt_type_rvln =  (pkt_type_rvln_hi && pkt_type_rvln_lo) && !(pkt_type_svln_hi && pkt_type_svln_lo);
  assign  pkt_type_svln =  (pkt_type_rvln_hi && pkt_type_rvln_lo) &&  (pkt_type_svln_hi && pkt_type_svln_lo);

  always@(posedge clk) if (pkt_valid & pkt_start) pkt_cont <= 1'b1; else if (pkt_valid & pkt_end) pkt_cont <= 1'b0;


  always@(posedge clk)  temp_type_ctrl      <=  pkt_type_ctrl;
  always@(posedge clk)  temp_type_data      <=  pkt_type_data;
  always@(posedge clk)  temp_type_rvln      <=  pkt_type_rvln; //pad handling
  always@(posedge clk)  temp_type_svln      <=  pkt_type_svln; //pad handling
  
  always@(posedge clk)  temp_tlen           <= (pkt_start & pkt_cont)? temp_tlen : pkt_type_svln? pkt_svln_tlen: pkt_type_rvln? pkt_rvln_tlen: pkt_norm_tlen;
  always@(posedge clk)  temp_hlen           <= (pkt_start & pkt_cont)? temp_hlen : pkt_type_svln? 16'd26: pkt_type_rvln? 16'd22: pkt_type_ctrl? 16'd20 : 16'd18;

  always@(posedge clk) dp_type_ctrl         <= pkt_valid & pkt_end & temp_type_ctrl;    
  always@(posedge clk) dp_type_data         <= pkt_valid & pkt_end & temp_type_data;    
  always@(posedge clk) dp_type_rvln         <= pkt_valid & pkt_end & temp_type_rvln; //pad handling  
  always@(posedge clk) dp_type_svln         <= pkt_valid & pkt_end & temp_type_svln; //pad handling
 
  always@(posedge clk) dp_opcd_pause        <= pkt_valid & pkt_end & (temp_opcd_sfc | temp_opcd_pfc);  
  always@(posedge clk) dp_ctrl_sfc          <= pkt_valid & pkt_end & temp_type_ctrl & temp_opcd_sfc;                     
  always@(posedge clk) dp_ctrl_pfc          <= pkt_valid & pkt_end & temp_type_ctrl & temp_opcd_pfc;                     
  always@(posedge clk) dp_ctrl_other        <= pkt_valid & pkt_end & temp_type_ctrl & (~(temp_opcd_sfc | temp_opcd_pfc));  

  always@(posedge clk) dp_hlen              <= temp_hlen; 
  always@(posedge clk) dp_tlen              <= temp_tlen; //actual length filed for either normal data, regular vlan or stacked vlan  

 
  always@(posedge clk) dphp_hlen            <= dp_hlen; 
  always@(posedge clk) dphp_tlen            <= dp_tlen;
  always@(posedge clk) dphp_type_ctrl       <= dp_type_ctrl;
  always@(posedge clk) dphp_type_data       <= dp_type_data;
  always@(posedge clk) dphp_type_rvln       <= dp_type_rvln; //pad handling
  always@(posedge clk) dphp_type_svln       <= dp_type_svln; //pad handling   

  always@(posedge clk) dphp_ctrl_ucast <= dp_type_ctrl & dp_addr_ucast;
  always@(posedge clk) dphp_ctrl_mcast <= dp_type_ctrl & dp_addr_mcast;
  always@(posedge clk) dphp_ctrl_bcast <= dp_type_ctrl & dp_addr_bcast;
  always@(posedge clk) dphp_ctrl_pause <= dp_type_ctrl & dp_opcd_pause;

  always@(posedge clk) dphp_ctrl_sfc   <= dp_ctrl_sfc   ;
  always@(posedge clk) dphp_ctrl_pfc   <= dp_ctrl_pfc   ;  
  always@(posedge clk) dphp_ctrl_other <= dp_ctrl_other ;
  
  always@(posedge clk) dphp_data_ucast <= dp_type_data & dp_addr_ucast;
  always@(posedge clk) dphp_data_mcast <= dp_type_data & dp_addr_mcast;
  always@(posedge clk) dphp_data_bcast <= dp_type_data & dp_addr_bcast;

 // ____________________________________________________________________________________________________________
 //     output pipelining to align with fcs_error
 //     -- dphp_ signals are output of the header processor block and take 07 cycles w.r.t. inputs
 //     -- in_dpfcs_error and in_dpfcs_valid are 11 cycles behind the input signals
 //     -- we need additional 6 cycles to delay dphp_ signals
 //     -- these pipe-stages can be used to additional logic in between if needed
 // ____________________________________________________________________________________________________________
 // 
  reg[OPIPE-1:0] opipe_ctrl_ucast = {OPIPE{1'b0}}; always@(posedge clk) opipe_ctrl_ucast  <= {opipe_ctrl_ucast[OPIPE-2:0], dphp_ctrl_ucast};
  reg[OPIPE-1:0] opipe_ctrl_mcast = {OPIPE{1'b0}}; always@(posedge clk) opipe_ctrl_mcast  <= {opipe_ctrl_mcast[OPIPE-2:0], dphp_ctrl_mcast};
  reg[OPIPE-1:0] opipe_ctrl_bcast = {OPIPE{1'b0}}; always@(posedge clk) opipe_ctrl_bcast  <= {opipe_ctrl_bcast[OPIPE-2:0], dphp_ctrl_bcast};
  reg[OPIPE-1:0] opipe_ctrl_pause = {OPIPE{1'b0}}; always@(posedge clk) opipe_ctrl_pause  <= {opipe_ctrl_pause[OPIPE-2:0], dphp_ctrl_pause};

  reg[OPIPE-1:0] opipe_ctrl_sfc   = {OPIPE{1'b0}}; always@(posedge clk) opipe_ctrl_sfc    <= {opipe_ctrl_sfc  [OPIPE-2:0], dphp_ctrl_sfc  };
  reg[OPIPE-1:0] opipe_ctrl_pfc   = {OPIPE{1'b0}}; always@(posedge clk) opipe_ctrl_pfc    <= {opipe_ctrl_pfc  [OPIPE-2:0], dphp_ctrl_pfc  };
  reg[OPIPE-1:0] opipe_ctrl_other = {OPIPE{1'b0}}; always@(posedge clk) opipe_ctrl_other  <= {opipe_ctrl_other[OPIPE-2:0], dphp_ctrl_other};
   
  reg[OPIPE-1:0] opipe_data_ucast = {OPIPE{1'b0}}; always@(posedge clk) opipe_data_ucast  <= {opipe_data_ucast[OPIPE-2:0], dphp_data_ucast};
  reg[OPIPE-1:0] opipe_data_mcast = {OPIPE{1'b0}}; always@(posedge clk) opipe_data_mcast  <= {opipe_data_mcast[OPIPE-2:0], dphp_data_mcast};
  reg[OPIPE-1:0] opipe_data_bcast = {OPIPE{1'b0}}; always@(posedge clk) opipe_data_bcast  <= {opipe_data_bcast[OPIPE-2:0], dphp_data_bcast};

  reg[OPIPE-1:0] opipe_pkt_end = {OPIPE{1'b0}};    always@(posedge clk) opipe_pkt_end    <= {opipe_pkt_end    [OPIPE-2:0], dphp_pkt_end};
 
 // ____________________________________________________________________________________________________________
 //     final outputs 
 // ____________________________________________________________________________________________________________
 wire out_pkt_start = valid_cycle[3] & valid_start[3]; 
  
 always@(posedge clk) out_dpfcs_valid    <= opipe_pkt_end[OPIPE-3] & pipe_fcs_valid ;
 always@(posedge clk) out_dpfcs_error    <= opipe_pkt_end[OPIPE-3] & pipe_fcs_valid & pipe_fcs_error ;

 // Rx Control frame indication does not check aginst length (opipe_size_064  [LEN_DLY-3])
 always @(posedge clk) begin
      out_rx_ctrl_sfc   <= pipe_fcs_valid & ~pipe_fcs_error & opipe_ctrl_sfc  [OPIPE-2];  
      out_rx_ctrl_pfc   <= pipe_fcs_valid & ~pipe_fcs_error & opipe_ctrl_pfc  [OPIPE-2];
      out_rx_ctrl_other <= pipe_fcs_valid & ~pipe_fcs_error & opipe_ctrl_other[OPIPE-2];
 end 
   
 reg out_type_ctrl_pause=0;always@(posedge clk) out_type_ctrl_pause <= pipe_fcs_valid & ~pipe_fcs_error & opipe_ctrl_pause[OPIPE-2];
 reg out_type_ctrl_ucast=0;always@(posedge clk) out_type_ctrl_ucast <= pipe_fcs_valid & ~pipe_fcs_error & opipe_ctrl_ucast[OPIPE-2];
 reg out_type_ctrl_mcast=0;always@(posedge clk) out_type_ctrl_mcast <= pipe_fcs_valid & ~pipe_fcs_error & opipe_ctrl_mcast[OPIPE-2];
 reg out_type_ctrl_bcast=0;always@(posedge clk) out_type_ctrl_bcast <= pipe_fcs_valid & ~pipe_fcs_error & opipe_ctrl_bcast[OPIPE-2];
 reg out_type_data_ucast=0;always@(posedge clk) out_type_data_ucast <= pipe_fcs_valid & ~pipe_fcs_error & opipe_data_ucast[OPIPE-2];
 reg out_type_data_mcast=0;always@(posedge clk) out_type_data_mcast <= pipe_fcs_valid & ~pipe_fcs_error & opipe_data_mcast[OPIPE-2];
 reg out_type_data_bcast=0;always@(posedge clk) out_type_data_bcast <= pipe_fcs_valid & ~pipe_fcs_error & opipe_data_bcast[OPIPE-2];
 
 reg out_err_ctrl_ucast=0;always@(posedge clk) out_err_ctrl_ucast <= pipe_fcs_valid & pipe_fcs_error & opipe_ctrl_ucast[OPIPE-2];
 reg out_err_ctrl_mcast=0;always@(posedge clk) out_err_ctrl_mcast <= pipe_fcs_valid & pipe_fcs_error & opipe_ctrl_mcast[OPIPE-2];
 reg out_err_ctrl_bcast=0;always@(posedge clk) out_err_ctrl_bcast <= pipe_fcs_valid & pipe_fcs_error & opipe_ctrl_bcast[OPIPE-2];
 reg out_err_ctrl_pause=0;always@(posedge clk) out_err_ctrl_pause <= pipe_fcs_valid & pipe_fcs_error & opipe_ctrl_pause[OPIPE-2];
 reg out_err_data_ucast=0;always@(posedge clk) out_err_data_ucast <= pipe_fcs_valid & pipe_fcs_error & opipe_data_ucast[OPIPE-2];
 reg out_err_data_mcast=0;always@(posedge clk) out_err_data_mcast <= pipe_fcs_valid & pipe_fcs_error & opipe_data_mcast[OPIPE-2];
 reg out_err_data_bcast=0;always@(posedge clk) out_err_data_bcast <= pipe_fcs_valid & pipe_fcs_error & opipe_data_bcast[OPIPE-2];
  
 // ____________________________________________________________________________________________________________
 //     output wiring
 // ____________________________________________________________________________________________________________

  localparam BIT_FRAGMENTS              = 00; 
  localparam BIT_JABBERS                = 01; 
  localparam BIT_CRCERR                 = 02; 
  localparam BIT_FCSERR_OKPKT           = 03; 
  localparam BIT_MCAST_DATA_ERR         = 04; 
  localparam BIT_BCAST_DATA_ERR         = 05; 
  localparam BIT_UCAST_DATA_ERR         = 06; 
  localparam BIT_MCAST_CTRL_ERR         = 07; 
  localparam BIT_BCAST_CTRL_ERR         = 08; 
  localparam BIT_UCAST_CTRL_ERR         = 09; 
  localparam BIT_PAUSE_ERR              = 10; 
  localparam BIT_64B                    = 11; 
  localparam BIT_65to127B               = 12; 
  localparam BIT_128to255B              = 13; 
  localparam BIT_256to511B              = 14; 
  localparam BIT_512to1023B             = 15; 
  localparam BIT_1024to1518B            = 16; 
  localparam BIT_1519toMAXB             = 17; 
  localparam BIT_OVERSIZE               = 18; 
  localparam BIT_MCAST_DATA_OK          = 19; 
  localparam BIT_BCAST_DATA_OK          = 20; 
  localparam BIT_UCAST_DATA_OK          = 21; 
  localparam BIT_MCAST_CTRL_OK          = 22; 
  localparam BIT_BCAST_CTRL_OK          = 23; 
  localparam BIT_UCAST_CTRL_OK          = 24; 
  localparam BIT_PAUSE                  = 25; 
  localparam BIT_RNT                    = 26; 
  localparam BIT_ST                     = 27; 
  localparam BIT_DB                     = 28; 
  localparam BIT_EBLK                   = 29; 
  localparam BIT_PLERR                  = 30; 
  localparam BIT_FLONG                  = 31; 

  assign out_dp_error[BIT_FRAGMENTS     ] = out_err_frgmt_frm;  
  assign out_dp_error[BIT_JABBERS       ] = out_err_jbbr_frm;  
  assign out_dp_error[BIT_CRCERR        ] = out_dpfcs_error ; 
  assign out_dp_error[BIT_FCSERR_OKPKT  ] = out_err_fcs_oksize; 
  assign out_dp_error[BIT_MCAST_DATA_ERR] = out_err_data_mcast;
  assign out_dp_error[BIT_BCAST_DATA_ERR] = out_err_data_bcast;
  assign out_dp_error[BIT_UCAST_DATA_ERR] = out_err_data_ucast;
  assign out_dp_error[BIT_MCAST_CTRL_ERR] = out_err_ctrl_mcast;
  assign out_dp_error[BIT_BCAST_CTRL_ERR] = out_err_ctrl_bcast;
  assign out_dp_error[BIT_UCAST_CTRL_ERR] = out_err_ctrl_ucast;
  assign out_dp_error[BIT_PAUSE_ERR     ] = out_err_ctrl_pause;
  
  assign out_dp_stats[BIT_FRAGMENTS     ] = out_err_frgmt_frm;  
  assign out_dp_stats[BIT_JABBERS       ] = out_err_jbbr_frm;  
  assign out_dp_stats[BIT_CRCERR        ] = out_dpfcs_error ; 
  assign out_dp_stats[BIT_FCSERR_OKPKT  ] = out_err_fcs_oksize; 
  assign out_dp_stats[BIT_MCAST_DATA_ERR] = out_err_data_mcast;
  assign out_dp_stats[BIT_BCAST_DATA_ERR] = out_err_data_bcast;
  assign out_dp_stats[BIT_UCAST_DATA_ERR] = out_err_data_ucast;
  assign out_dp_stats[BIT_MCAST_CTRL_ERR] = out_err_ctrl_mcast;
  assign out_dp_stats[BIT_BCAST_CTRL_ERR] = out_err_ctrl_bcast;
  assign out_dp_stats[BIT_UCAST_CTRL_ERR] = out_err_ctrl_ucast;
  assign out_dp_stats[BIT_PAUSE_ERR     ] = out_err_ctrl_pause;
  assign out_dp_stats[BIT_64B           ] = out_size_064;          
  assign out_dp_stats[BIT_65to127B      ] = out_size_127;          
  assign out_dp_stats[BIT_128to255B     ] = out_size_255;          
  assign out_dp_stats[BIT_256to511B     ] = out_size_511;          
  assign out_dp_stats[BIT_512to1023B    ] = out_size_1023;         
  assign out_dp_stats[BIT_1024to1518B   ] = out_size_1517;         
  assign out_dp_stats[BIT_1519toMAXB    ] = out_size_max;          
  assign out_dp_stats[BIT_OVERSIZE      ] = out_over_size;         
  assign out_dp_stats[BIT_MCAST_DATA_OK ] = out_type_data_mcast;    
  assign out_dp_stats[BIT_BCAST_DATA_OK ] = out_type_data_bcast;    
  assign out_dp_stats[BIT_UCAST_DATA_OK ] = out_type_data_ucast;    
  assign out_dp_stats[BIT_MCAST_CTRL_OK ] = out_type_ctrl_mcast;    
  assign out_dp_stats[BIT_BCAST_CTRL_OK ] = out_type_ctrl_bcast;    
  assign out_dp_stats[BIT_UCAST_CTRL_OK ] = out_type_ctrl_ucast;    
  assign out_dp_stats[BIT_PAUSE         ] = out_type_ctrl_pause;    
  assign out_dp_stats[BIT_RNT           ] = out_size_runt;         
  assign out_dp_stats[BIT_ST            ] = out_pkt_start;
  assign out_dp_stats[BIT_PLERR         ] = out_plen_error;     
  assign out_dp_stats[BIT_DB            ] = 1'b0;               // unused 
  assign out_dp_stats[BIT_FLONG         ] = 1'b0;               // unused 
  assign out_dp_stats[BIT_EBLK          ] = 1'b0;               // unused 
  //assign out_counts[15:0]                 = payload_length;
  assign out_counts[15:0]                 = (cfg_pld_length_include_vlan) ? payload_length_vlan : payload_length;     
  assign out_counts_valid[0]              = payload_length_valid;
 // ____________________________________________________________________________________________________________
 //

endmodule

