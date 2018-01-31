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
// $Id: //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/mac/e100_hproc_4.v#15 $
// $Revision: #15 $
// $Date: 2013/08/30 $
// $Author: adubey $
// ___________________________________________________________________________
// altera message_off 10036 
// ajay dubey 07.22.2013

 module alt_aeu_dform #
	(parameter WORDS  = 2
        ,parameter DEPTH = (WORDS == 4)? 2: (WORDS == 2)? 3:0
       )(
	 input wire clk
	,input wire reset	  

   	,input wire in_valid
   	,input wire in_phyready
   	,input wire [WORDS*8-1:0] in_ctrl
    	,input wire [WORDS-1:0] in_idle
    	,input wire [WORDS-1:0] in_sop
    	,input wire [WORDS-1:0] in_eop
   	,input wire [WORDS*64-1:0] in_data
    	,input wire [WORDS*3-1:0] in_eop_empty
 
   	,input wire in_phy_error
	,input wire in_fcs_error 		
	,input wire in_fcs_valid 

   	,output wire out_valid
   	,output wire [WORDS*8-1:0] out_ctrl
    	,output wire [WORDS-1:0] out_idle
    	,output wire [WORDS-1:0] out_sop
    	,output wire [WORDS-1:0] out_eop
   	,output wire [DEPTH*WORDS*64-1:0] out_data
    	,output wire [WORDS*3-1:0] out_eop_empty
    	,output wire [2:0] out_valid_words // just for SOP cycles for now

   	,output wire out_phy_error
	,output wire out_fcs_error 		
	,output wire out_fcs_valid 
	,output wire [4:0] out_valid_cycle
	,output wire [4:0] out_valid_start
	,output wire       out_valid_idle
	,output wire       out_valid_end
 );

 // ___________________________________________________________________________________________
 //
     localparam WORDS_PERCYCLE = (WORDS == 2)? 3'd2: (WORDS ==4)? 3'd4: 3'd0;

 // ____________________________________________________________________________________________
 //	input pipelines and basic signal generation
 // ____________________________________________________________________________________________
   reg inp0_valid = 0 ; 	    	always@ (posedge clk)  inp0_valid 	<= (in_phyready)& ~(&in_idle) & in_valid;
   reg [WORDS-1:0] inp0_sop = 0 ;  	always@ (posedge clk)  inp0_sop 	<= (in_phyready & ~(&in_idle) & in_valid)? in_sop: {WORDS{1'b0}}; 
   reg [WORDS-1:0] inp0_eop = 0 ;  	always@ (posedge clk)  inp0_eop 	<= (in_phyready & ~(&in_idle) & in_valid)? in_eop: {WORDS{1'b0}}; 
   reg [WORDS-1:0] inp0_idle = 0 ; 	always@ (posedge clk)  inp0_idle 	<= (in_phyready & ~(&in_idle) & in_valid)? in_idle: {WORDS{1'b0}}; 
   reg [WORDS*8-1:0] inp0_ctrl = 0 ;    always@ (posedge clk)  inp0_ctrl 	<= (in_phyready & ~(&in_idle) & in_valid)? in_ctrl: {8*WORDS{1'b0}}; 
   reg [WORDS*64-1:0] inp0_data = 0 ;   always@ (posedge clk)  inp0_data 	<= (in_phyready & ~(&in_idle) & in_valid)? in_data: {64*WORDS{1'b0}}; 
   reg [WORDS*3-1:0] inp0_empty = 0;	always@ (posedge clk)  inp0_empty 	<= (in_phyready & ~(&in_idle) & in_valid)? in_eop_empty: {3*WORDS{1'b0}}; 
   reg inp0_phyerr = 0 ;  		always@ (posedge clk)  inp0_phyerr 	<= (in_phyready & ~(&in_idle) & in_valid)? in_phy_error: 1'b0; 
   reg inp0_fcserr = 0 ;  		always@ (posedge clk)  inp0_fcserr 	<= (in_phyready & ~(&in_idle) & in_valid)? in_fcs_error: 1'b0; 
   reg inp0_fcsval = 0 ;  		always@ (posedge clk)  inp0_fcsval 	<= (in_phyready & ~(&in_idle) & in_valid)? in_fcs_valid: 1'b0; 
   reg inp0_valid_idle = 0 ; 	    	always@ (posedge clk)  inp0_valid_idle	<= (in_phyready & ~(&in_idle) & in_valid)& (&in_idle) & in_valid;
   reg inp0_valid_cycle = 1'd0; 	always@ (posedge clk)  inp0_valid_cycle	<= (in_phyready & ~(&in_idle) & in_valid)? in_valid: 1'b0; 


   wire end_no_start	=  |inp0_eop & ~(|inp0_sop);
   wire start_no_end	=  |inp0_sop & ~(|inp0_eop);
   wire start_then_end  = (|inp0_sop &   |inp0_eop) && (inp0_sop > inp0_eop);
   wire end_then_start  = (|inp0_sop &   |inp0_eop) && (inp0_sop < inp0_eop);

   wire inp0_valid_start = start_no_end | start_then_end | end_then_start; 
   wire inp0_valid_end   = end_no_start | end_then_start | start_then_end; 
 //____________________________________________________________________________

   reg inp1_valid = 0 ; 		always@ (posedge clk) inp1_valid 	<= inp0_valid;
   reg [WORDS-1:0] inp1_sop = 0 ; 	always@ (posedge clk) inp1_sop 		<=~inp0_idle & inp0_sop; 
   reg [WORDS-1:0] inp1_eop = 0 ; 	always@ (posedge clk) inp1_eop 		<=~inp0_idle & inp0_eop; 
   reg [WORDS-1:0] inp1_idle = 0 ; 	always@ (posedge clk) inp1_idle 	<= inp0_idle; 
   reg [WORDS*8-1:0] inp1_ctrl = 0 ; 	always@ (posedge clk) inp1_ctrl 	<= inp0_ctrl; 
   reg [WORDS*64-1:0] inp1_data = 0 ; 	always@ (posedge clk) inp1_data 	<= inp0_data; 
   reg [WORDS*3-1:0] inp1_empty= 0;	always@ (posedge clk) inp1_empty 	<= inp0_empty; 
   reg inp1_phyerr= 0;			always@ (posedge clk) inp1_phyerr 	<= inp0_phyerr; 
   reg inp1_fcserr= 0;			always@ (posedge clk) inp1_fcserr 	<= inp0_fcserr; 
   reg inp1_fcsval= 0;			always@ (posedge clk) inp1_fcsval 	<= inp0_fcsval; 
   reg inp1_valid_idle = 0 ; 	    	always@ (posedge clk) inp1_valid_idle	<= inp0_valid_idle;
   reg inp1_valid_end   = 1'd0; 	always@ (posedge clk) inp1_valid_end	<= inp0_valid_end;
   reg [3:0] inp1_valid_cycle = 4'd0; 	always@ (posedge clk) inp1_valid_cycle	<= {4{inp0_valid_cycle}};
   reg [3:0] inp1_valid_start = 4'd0; 	always@ (posedge clk) inp1_valid_start	<= {4{inp0_valid_start}};
 //____________________________________________________________________________

   reg inp2_valid = 0 ; 		always@ (posedge clk) inp2_valid 	<= inp1_valid;
   reg [WORDS-1:0] inp2_sop = 0 ; 	always@ (posedge clk) inp2_sop 		<= inp1_sop; 
   reg [WORDS-1:0] inp2_eop = 0 ; 	always@ (posedge clk) inp2_eop 		<= inp1_eop; 
   reg [WORDS-1:0] inp2_idle = 0 ; 	always@ (posedge clk) inp2_idle 	<= inp1_idle; 
   reg [WORDS*8-1:0] inp2_ctrl = 0 ; 	always@ (posedge clk) inp2_ctrl 	<= inp1_ctrl; 
   reg [WORDS*64-1:0] inp2_data = 0 ; 	always@ (posedge clk) inp2_data 	<= inp1_data; 
   reg [WORDS*3-1:0] inp2_empty= 0;	always@ (posedge clk) inp2_empty 	<= inp1_empty; 
   reg inp2_phyerr= 0;			always@ (posedge clk) inp2_phyerr 	<= inp1_phyerr; 
   reg inp2_fcserr= 0;			always@ (posedge clk) inp2_fcserr 	<= inp1_fcserr; 
   reg inp2_fcsval= 0;			always@ (posedge clk) inp2_fcsval 	<= inp1_fcsval; 
   reg inp2_valid_idle = 0 ; 	    	always@ (posedge clk) inp2_valid_idle	<= inp1_valid_idle;
   reg inp2_valid_end   = 1'd0; 	always@ (posedge clk) inp2_valid_end	<= inp1_valid_end;
   reg [3:0] inp2_valid_cycle = 4'd0; 	always@ (posedge clk) inp2_valid_cycle	<= inp1_valid_cycle;
   reg [3:0] inp2_valid_start = 4'd0; 	always@ (posedge clk) inp2_valid_start	<= inp1_valid_start;
 //____________________________________________________________________________

   reg inp3_valid = 0 ; 		always@ (posedge clk) inp3_valid 	<= inp2_valid;
   reg [WORDS-1:0] inp3_sop = 0 ; 	always@ (posedge clk) inp3_sop 		<= inp2_sop; 
   reg [WORDS-1:0] inp3_eop = 0 ; 	always@ (posedge clk) inp3_eop 		<= inp2_eop; 
   reg [WORDS-1:0] inp3_idle = 0 ; 	always@ (posedge clk) inp3_idle 	<= inp2_idle; 
   reg [WORDS*8-1:0] inp3_ctrl = 0 ; 	always@ (posedge clk) inp3_ctrl 	<= inp2_ctrl; 
   reg [WORDS*64-1:0] inp3_data = 0 ; 	always@ (posedge clk) inp3_data 	<= inp2_data; 
   reg [WORDS*3-1:0] inp3_empty= 0;	always@ (posedge clk) inp3_empty 	<= inp2_empty; 
   reg inp3_phyerr= 0;			always@ (posedge clk) inp3_phyerr 	<= inp2_phyerr; 
   reg inp3_fcserr= 0;			always@ (posedge clk) inp3_fcserr 	<= inp2_fcserr; 
   reg inp3_fcsval= 0;			always@ (posedge clk) inp3_fcsval 	<= inp2_fcsval; 
   reg inp3_valid_idle = 0 ; 	    	always@ (posedge clk) inp3_valid_idle	<= inp2_valid_idle;
   reg inp3_valid_end   = 1'd0; 	always@ (posedge clk) inp3_valid_end	<= inp2_valid_end;
   reg [3:0] inp3_valid_cycle = 4'd0; 	always@ (posedge clk) inp3_valid_cycle	<= inp2_valid_cycle;
   reg [3:0] inp3_valid_start = 4'd0; 	always@ (posedge clk) inp3_valid_start	<= inp2_valid_start;

 // _________________________________________________________________________________________________________________
 //	inputs required by the state machine
 // _________________________________________________________________________________________________________________
   wire start 		  = ( inp2_valid) && (|inp2_sop);
   wire end_start 	  = ( inp2_valid) && (|inp2_sop) && (|inp1_eop);
   wire one_hdr_valid	  = ( inp1_valid) && (!inp0_valid); 	// unused TBD remove or just leave for debug
   wire none_hdr_valid	  = (!inp1_valid)&&  (!inp0_valid); 	// unused TBD remove or just leave for debug
   wire inp2_st0h 	  =   start && (none_hdr_valid); 	// unused TBD remove or just leave for debug
   wire inp2_st1h 	  =   start && (one_hdr_valid); 	// unused TBD remove or just leave for debug
   wire inp2_less_hdrs	  =   start && (!inp0_valid); 	


 // _________________________________________________________________________________________________________________
 //	FSM to manage headers
 // _________________________________________________________________________________________________________________

   localparam NORM = 3'd0, STRT = 3'd1, HDR1 = 3'd2, HDR2 = 3'd3;
   reg[2:0] state = NORM;

   always @(posedge clk or posedge reset)
       begin
	  if (reset) state <= NORM;
	  else begin
	       case (state)
	            NORM: if (inp2_less_hdrs)	state <= STRT; 
	            STRT: if (inp2_valid)	state <= HDR1;
	            HDR1: if (inp2_valid)	state <= HDR2;
	            HDR2: if (inp2_less_hdrs) 	state <= STRT;  // rare case of next pkt short header 
		    else  if (inp2_valid)	state <= NORM; 
	            default: state <= state;
	       endcase
	  end
       end

 // _________________________________________________________________________________________________________________
 //    bufer to hold partial headers
 // _________________________________________________________________________________________________________________

   reg buf0_valid = 0 ; 		
   reg [WORDS-1:0] buf0_sop = 0 ; 	
   reg [WORDS-1:0] buf0_eop = 0 ; 	
   reg [WORDS*64-1:0] buf0_data = 0 ;  
   reg [WORDS*3-1:0] buf0_empty = 0;	
   reg [WORDS-1:0] buf0_idle = 0 ; 	
   reg [WORDS*8-1:0] buf0_ctrl = 0 ;   
   reg buf0_phyerr 	= 1'b0;
   reg buf0_fcserr 	= 1'b0;
   reg buf0_fcsval 	= 1'b0;
   reg buf0_valid_idle = 0 ; 	    	
   reg buf0_valid_end   = 1'd0; 	
   reg [3:0] buf0_valid_cycle = 4'd0; 	
   reg [3:0] buf0_valid_start = 4'd0; 	

   reg buf1_valid = 0 ; 		
   reg [WORDS-1:0] buf1_sop = 0 ; 	
   reg [WORDS-1:0] buf1_eop = 0 ; 	
   reg [WORDS*64-1:0] buf1_data = 0 ;  
   reg [WORDS*3-1:0] buf1_empty = 0;	 
   reg [WORDS-1:0] buf1_idle = 0 ; 	
   reg [WORDS*8-1:0] buf1_ctrl = 0 ;   
   reg buf1_phyerr 	= 1'b0;
   reg buf1_fcserr 	= 1'b0;
   reg buf1_fcsval 	= 1'b0;
   reg buf1_valid_idle = 0 ; 	    	
   reg buf1_valid_end   = 1'd0; 	
   reg [3:0] buf1_valid_cycle = 4'd0; 	
   reg [3:0] buf1_valid_start = 4'd0; 	

   reg               outp_valid		= 1'b0;
   reg [WORDS-1:0]   outp_sop  		= 1'b0;
   reg [WORDS-1:0]   outp_eop  		= 1'b0;
   reg [WORDS-1:0]   outp_idle 		= 1'b0;
   reg [WORDS*8-1:0] outp_ctrl 		= 1'b0;
   reg [WORDS*3-1:0] outp_empty		= 1'b0;
   reg [DEPTH*WORDS*64-1:0] outp_data 	= {DEPTH*WORDS*64{1'b0}};
   reg               outp_valid_idle 	= 1'b0;
   reg               outp_valid_end 	= 1'b0;
   reg [4:0]         outp_valid_cycle 	= {4{1'b0}};
   reg [4:0]         outp_valid_start 	= {4{1'b0}};
   reg [2:0]         outp_valid_words 	= 3'd0;
   reg 	      	     outp_phyerr 	= 1'b0;
   reg 	      	     outp_fcserr 	= 1'b0;
   reg 	      	     outp_fcsval 	= 1'b0;

   always @(posedge clk)
       begin
	  case (state)
	       NORM: 
		   begin
		   //   both buffers remain empty
		   //	outputs provided by inpipe
   			buf0_valid 	<={1'b0} ;
   			buf0_sop  	<={WORDS{1'b0}} ;
   			buf0_eop  	<={WORDS{1'b0}} ;
   			buf0_idle 	<={WORDS{1'b0}} ;
   			buf0_ctrl 	<={WORDS{1'b0}} ;
   			buf0_empty	<={WORDS*03{1'b0}} ;
   			buf0_data 	<={WORDS*64{1'b0}} ;
   			buf0_phyerr 	<= 1'b0 ;
   			buf0_fcserr 	<= 1'b0 ;
   			buf0_fcsval 	<= 1'b0 ;
			buf0_valid_idle	<= 1'b0;
			buf0_valid_end	<= 1'b0;
			buf0_valid_cycle<= {4{1'b0}};
			buf0_valid_start<= {4{1'b0}};

   			buf1_valid 	<={1'b0};
   			buf1_sop  	<={WORDS{1'b0}};
   			buf1_eop  	<={WORDS{1'b0}};
   			buf1_idle 	<={WORDS{1'b0}};
   			buf1_ctrl 	<={WORDS{1'b0}};
   			buf1_empty	<={WORDS*03{1'b0}} ;
   			buf1_data 	<={WORDS*64{1'b0}} ;
   			buf1_phyerr 	<= 1'b0 ;
   			buf1_fcserr 	<= 1'b0 ;
   			buf1_fcsval 	<= 1'b0 ;
			buf1_valid_idle	<= 1'b0;
			buf1_valid_end	<= 1'b0;
			buf1_valid_cycle<= {4{1'b0}};
			buf1_valid_start<= {4{1'b0}};

   			outp_valid 	<= inp3_valid 	; 
   			outp_sop  	<= inp3_sop  	; 
   			outp_eop  	<= inp3_eop  	; 
   			outp_idle 	<= inp3_idle 	; 
   			outp_ctrl 	<= inp3_ctrl 	; 
   			outp_empty	<= inp3_empty	; 
   			outp_data 	<={inp3_data,inp2_data, inp1_data}; 
   			outp_phyerr 	<= inp3_phyerr ; 
   			outp_fcserr 	<= inp3_fcserr ; 
   			outp_fcsval 	<= inp3_fcsval ; 
   			outp_valid_cycle<= inp3_valid_cycle;
   			outp_valid_idle <= inp3_valid_idle ;
   			outp_valid_start<= inp3_valid_start;
   			outp_valid_words<= 3'd0;
   			outp_valid_end  <= inp3_valid_end  ;
		   end
	       STRT: 
		   begin
		   if (inp3_valid && (|inp3_eop))
		   // if this cycle bears any EOP, flush it out
		   // instead of pushing it further because the
		   // assumption for the eop-fcs latency is fixed
		      begin
   			outp_valid_words<= 3'd0; // this is not any additional cycle - its always there 
			outp_phyerr 	<= inp3_phyerr	;
			outp_fcsval 	<= inp3_fcsval	;
			outp_fcserr 	<= inp3_fcserr	;
			outp_idle 	<= inp3_idle	;
			outp_ctrl 	<= inp3_ctrl	;
			outp_valid_idle	<= inp3_valid_idle;
			outp_valid_cycle<= inp3_valid_cycle;
			outp_valid 	<= inp3_valid 	; 
			outp_data 	<= inp3_data	;
			outp_sop  	<= {WORDS{1'b0}};  // trailing end only, but no start-of-pkt
   			outp_valid_start<= {4{1'b0}} ;
			outp_eop  	<= inp3_eop	;
			outp_empty	<= inp3_empty	;
			outp_valid_end	<= inp3_valid_end;

		   // 	capture valid headers only in their resp
		   // 	buffers now to used to get full header
			buf0_phyerr 	<= inp3_phyerr	;
			buf0_fcserr 	<= inp3_fcserr	;
			buf0_fcsval 	<= inp3_fcsval	;
			buf0_idle 	<= inp3_idle	;
			buf0_ctrl 	<= inp3_ctrl	;
			buf0_valid_idle	<= inp3_valid_idle;
			buf0_valid_cycle<= inp3_valid_cycle;
			buf0_valid 	<= inp3_valid 	; 
			buf0_data 	<= inp3_data	;
			buf0_sop  	<= inp3_sop  	; 
			buf0_valid_start<= inp3_valid_start;
			buf0_eop  	<= {WORDS{1'b0}}; // trailing end is out this cycle, don't buffer
			buf0_empty	<= {WORDS{3'd0}}; // trailing end is out this cycle, don't buffer
			buf0_valid_end	<= 1'b0;
		      end
		   else if (inp3_valid)
		   // shun the eop controls and the output
		   // buffer the packet header sop controls 
		      begin
   			outp_valid 	<= 1'b0; 
   			outp_sop  	<= {WORDS{1'b0}}; 
   			outp_eop  	<= {WORDS{1'b0}}; 
   			outp_idle 	<= {WORDS{1'b0}}; 
   			outp_ctrl 	<= {WORDS{1'b0}}; 
   			outp_empty	<= {WORDS*03{1'b0}} ;
   			outp_data 	<= {DEPTH*WORDS*64{1'b0}};
   			outp_phyerr 	<= 1'b0 ;
   			outp_fcserr 	<= 1'b0 ;
   			outp_fcsval 	<= 1'b0 ;
   			outp_valid_idle	<= 1'b0 ;
   			outp_valid_end 	<= 1'b0 ;
   			outp_valid_cycle<= {4{1'b0}} ;
   			outp_valid_start<= {4{1'b0}} ;
   			outp_valid_words<= 3'd0; // this is not any additional cycle - its always there 

			buf0_idle 	<= inp3_idle	;
			buf0_ctrl 	<= inp3_ctrl	;
			buf0_phyerr 	<= inp3_phyerr	;
			buf0_fcserr 	<= inp3_fcserr	;
			buf0_fcsval 	<= inp3_fcsval	;
			buf0_valid_idle	<= inp3_valid_idle;
			buf0_valid_cycle<= inp3_valid_cycle;
			buf0_valid 	<= inp3_valid 	; 
			buf0_valid_start<= inp3_valid_start;
			buf0_data 	<= inp3_data	;
			buf0_sop  	<= inp3_sop  	; 
			buf0_eop  	<= {WORDS{1'b0}}; // trailing end is out this cycle, don't buffer
			buf0_empty	<= {WORDS{3'd0}}; // trailing end is out this cycle, don't buffer
			buf0_valid_end	<= 1'b0;
		      end
		   else // if (!inp3_val)
		   // this is a dead cycle, make sure EOP flushed in previous cycle
		   // is deasserted to avoid wider EOP control (regtest 876830)
		      begin
   			outp_sop  	<= {WORDS{1'b0}}; 
   			outp_eop  	<= {WORDS{1'b0}}; 
   			outp_valid 	<= 1'b0; 
   			outp_valid_cycle<= {4{1'b0}} ;
   			outp_empty	<= {WORDS*03{1'b0}} ;
		      end
		   end
	       HDR1: 
		   begin
		   // output remains invalid in
		   // all buffering states (STRT,HDR1)
   			outp_valid 	<= 1'b0	; 
   			outp_sop  	<= {WORDS{1'b0}}; 
   			outp_eop  	<= {WORDS{1'b0}}; 
   			outp_idle 	<= {WORDS{1'b0}}; 
   			outp_ctrl 	<= {WORDS{1'b0}}; 
   			outp_empty	<= {WORDS*03{1'b0}} ;
   			outp_data 	<= {DEPTH*WORDS*64{1'b0}};
   			outp_phyerr 	<= 1'b0 ;
   			outp_fcserr 	<= 1'b0 ;
   			outp_fcsval 	<= 1'b0 ;
   			outp_valid_idle	<= 1'b0 ;
   			outp_valid_end	<= 1'b0 ;
   			outp_valid_cycle<= {4{1'b0}} ;
   			outp_valid_start<= {4{1'b0}} ;
			
		        if (inp3_valid)
		        // first buffered headers to stay unchanged
			// ground eop controls signals
			  begin
   				outp_valid_words<= outp_valid_words + WORDS_PERCYCLE;
			      //capture the second cycle of headers
				buf1_idle 	<= inp3_idle 	; 
				buf1_ctrl 	<= inp3_ctrl 	; 
				buf1_phyerr 	<= inp3_phyerr 	; 
				buf1_fcserr 	<= inp3_fcserr 	; 
				buf1_fcsval 	<= inp3_fcsval 	; 
				buf1_valid_idle	<= inp3_valid_idle; 
				buf1_valid_cycle<= inp3_valid_cycle; 
				buf1_valid_start<= inp3_valid_start;
				buf1_valid 	<= inp3_valid 	; 
				buf1_sop  	<= inp3_sop  	; 
				buf1_data 	<= inp3_data	;
				buf1_eop  	<= {WORDS{1'd0}}; 
				buf1_empty	<= {WORDS{3'd0}}; 
				buf1_valid_end	<= 1'd0; 
			  end
		   end
	       HDR2: 
		   begin
		   // all three cycles worth of headers are
		   // available in buffers and on inp2 stage
		   // send out the output and move back to NORM
		        if (inp3_valid)
			  begin
				outp_valid 	<= buf0_valid 	; 
				outp_sop  	<= buf0_sop  	; 
				outp_eop  	<= buf0_eop  	; 
				outp_idle 	<= buf0_idle 	; 
				outp_ctrl 	<= buf0_ctrl 	; 
				outp_empty	<= buf0_empty	; 
				outp_data 	<={buf0_data, buf1_data, inp3_data}; 
				outp_phyerr 	<= buf0_phyerr ; 
				outp_fcserr 	<= buf0_fcserr ; 
				outp_fcsval 	<= buf0_fcsval ; 
				outp_valid_idle	<= buf0_valid_idle; 
				outp_valid_end	<= buf0_valid_end	;
				outp_valid_cycle<= buf0_valid_cycle; 
				outp_valid_start<= buf0_valid_start;
   				outp_valid_words<= outp_valid_words + WORDS_PERCYCLE;
			  end
   			buf0_valid 	<= 1'b0 ;
   			buf0_sop  	<= {WORDS{1'b0}};
   			buf0_eop  	<= {WORDS{1'b0}};
   			buf0_idle 	<= {WORDS{1'b0}};
   			buf0_ctrl 	<= {WORDS{1'b0}};
   			buf0_empty	<= {WORDS*03{1'b0}} ;
   			buf0_data 	<= {WORDS*64{1'b0}} ;
   			buf0_phyerr 	<= 1'b0 ;
   			buf0_fcserr 	<= 1'b0 ;
   			buf0_fcsval 	<= 1'b0 ;
			buf0_valid_idle	<= 1'b0;
			buf0_valid_end	<= 1'b0;
			buf0_valid_cycle<= {4{1'b0}};
			buf0_valid_start<= {4{1'b0}};

   			buf1_valid 	<= 1'b0 ;
   			buf1_sop  	<={WORDS{1'b0}};
   			buf1_eop  	<={WORDS{1'b0}};
   			buf1_idle 	<={WORDS{1'b0}};
   			buf1_ctrl 	<={WORDS{1'b0}};
   			buf1_empty	<={WORDS*03{1'b0}} ;
   			buf1_data 	<={WORDS*64{1'b0}} ;
   			buf1_phyerr 	<= 1'b0 ;
   			buf1_fcserr 	<= 1'b0 ;
   			buf1_fcsval 	<= 1'b0 ;
			buf1_valid_idle	<= 1'b0;
			buf1_valid_end	<= 1'b0;
			buf1_valid_cycle<= {4{1'b0}};
			buf1_valid_start<= {4{1'b0}};
		   end
	       default: begin buf0_valid <= 1'b0; end
	  endcase
       end
 // _____________________________________________________________________________________________
 // verification assertions
 // _____________________________________________________________________________________________
 // synthesis translate_off
 // always @(*)
 //   begin
 // 	     if (start & one_hdr_valid)     $display ("%m\t at %t: Found Packet with one less header \n",$time); 
 // 	else if (start & one_hdr_valid)     $display ("%m\t at %t: Found Packet with two less header \n",$time); 
 // 	else if (end_start & one_hdr_valid) $display ("%m\t at %t: Found Packet with one less header preceeded by an End \n",$time); 
 // 	else if (end_start & one_hdr_valid) $display ("%m\t at %t: Found Packet with two less header preceeded by an End \n",$time); 
 //      case (state)
 //         STRT: if (inp3_valid) $display ("%m\t at %t: Collected Start  of unaligned Headers: %h\n",$time, inp3_data); 
 //         HDR1: if (inp3_valid) $display ("%m\t at %t: Collected First  of unaligned Headers: %h\n",$time, inp3_data); 
 //         HDR1: if (inp3_valid) $display ("%m\t at %t: Collected Second of unaligned Headers: %h\n",$time, inp3_data); 
 //      endcase
 //   end
// synthesis translate_on
// _____________________________________________________________________________________________

  assign out_valid	 = outp_valid;
  assign out_ctrl        = outp_ctrl;
  assign out_idle        = outp_idle;
  assign out_sop         = outp_sop;
  assign out_eop         = outp_eop;
  assign out_data        = outp_data;
  assign out_eop_empty   = outp_empty;
  assign out_valid_words = outp_valid_words;
                         
  assign out_phy_error   = outp_phyerr;
  assign out_fcs_error 	 = outp_fcserr;
  assign out_fcs_valid   = outp_fcsval;
  assign out_valid_cycle = outp_valid_cycle;
  assign out_valid_start = outp_valid_start;
  assign out_valid_idle  = outp_valid_idle;
  assign out_valid_end   = outp_valid_end;

 endmodule

// BENCHMARK INFO : Date : Tue Sep 16 14:09:58 2014
// BENCHMARK INFO : Quartus version : /tools/altera/14.1/150/linux64/quartus/bin
// BENCHMARK INFO : benchmark P4 version: 14 
// BENCHMARK INFO : benchmark path: /tools/ipd_tools/1.14/linux64/bin
// BENCHMARK INFO : Total registers : 1357
// BENCHMARK INFO : Total pins : 0
// BENCHMARK INFO : Total virtual pins : 595
// BENCHMARK INFO : Total block memory bits : 0
// BENCHMARK INFO : Number of Fitter seeds : 9
// BENCHMARK INFO : Device: 10AX115K4F36I3SG
// BENCHMARK INFO : ALM usage: 435 (compensated 1/2 ALM per virtual pin)
// BENCHMARK INFO : Combinational ALUT usage: 302
// BENCHMARK INFO : Fitter seed 1000: Worst setup slack @ 500 MHz : 0.115 ns, From inp3_valid, To buf1_data[48] 
// BENCHMARK INFO : Fitter seed 2234: Worst setup slack @ 500 MHz : 0.065 ns, From state.HDR1, To buf1_data[90] 
// BENCHMARK INFO : Fitter seed 3468: Worst setup slack @ 500 MHz : 0.134 ns, From state.HDR1, To buf1_data[74] 
// BENCHMARK INFO : Fitter seed 4702: Worst setup slack @ 500 MHz : 0.114 ns, From state.HDR1, To buf0_data[46] 
// BENCHMARK INFO : Max logic levels = 1 ; fanout = 407 ; slack = 0.162 ; from : state.STRT~DUPLICATE ; to : outp_data[266] 
// BENCHMARK INFO : Number of paths with max logic levels = 573 
// BENCHMARK INFO : Elapsed benchmark time: 2348.5 seconds
