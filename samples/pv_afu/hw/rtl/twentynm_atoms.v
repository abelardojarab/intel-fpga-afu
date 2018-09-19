// Copyright (C) 2017 Intel Corporation. All rights reserved.
// This simulation model contains highly confidential and
// proprietary information of Intel and is being provided
// in accordance with and subject to the protections of the
// applicable Intel Program License Subscription Agreement
// which governs its use and disclosure. Your use of Intel
// Corporation's design tools, logic functions and other
// software and tools, and its AMPP partner logic functions,
// and any output files any of the foregoing (including device
// programming or simulation files), and any associated
// documentation or information are expressly subject to the
// terms and conditions of the Intel Program License Subscription
// Agreement, the Intel Quartus Prime License Agreement, the
// Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is 
// for the sole purpose of simulating designs for use exclusively
// in logic devices manufactured by Intel and sold by Intel or 
// its authorized distributors. Please refer to the applicable
// agreement for further details. Intel products and services
// are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.
// Intel assumes no responsibility or liability arising out of the
// application or use of this simulation model.
// Quartus Prime 17.1.0 Build 234 09/13/2017

// ********** PRIMITIVE DEFINITIONS **********

`timescale 1 ps/1 ps

// ***** DFFE

primitive TWENTYNM_PRIM_DFFE (Q, ENA, D, CLK, CLRN, PRN, notifier);
   input D;   
   input CLRN;
   input PRN;
   input CLK;
   input ENA;
   input notifier;
   output Q; reg Q;

   initial Q = 1'b0;

    table

    //  ENA  D   CLK   CLRN  PRN  notifier  :   Qt  :   Qt+1

        (??) ?    ?      1    1      ?      :   ?   :   -;  // pessimism
         x   ?    ?      1    1      ?      :   ?   :   -;  // pessimism
         1   1   (01)    1    1      ?      :   ?   :   1;  // clocked data
         1   1   (01)    1    x      ?      :   ?   :   1;  // pessimism
 
         1   1    ?      1    x      ?      :   1   :   1;  // pessimism
 
         1   0    0      1    x      ?      :   1   :   1;  // pessimism
         1   0    x      1  (?x)     ?      :   1   :   1;  // pessimism
         1   0    1      1  (?x)     ?      :   1   :   1;  // pessimism
 
         1   x    0      1    x      ?      :   1   :   1;  // pessimism
         1   x    x      1  (?x)     ?      :   1   :   1;  // pessimism
         1   x    1      1  (?x)     ?      :   1   :   1;  // pessimism
 
         1   0   (01)    1    1      ?      :   ?   :   0;  // clocked data

         1   0   (01)    x    1      ?      :   ?   :   0;  // pessimism

         1   0    ?      x    1      ?      :   0   :   0;  // pessimism
         0   ?    ?      x    1      ?      :   ?   :   -;

         1   1    0      x    1      ?      :   0   :   0;  // pessimism
         1   1    x    (?x)   1      ?      :   0   :   0;  // pessimism
         1   1    1    (?x)   1      ?      :   0   :   0;  // pessimism

         1   x    0      x    1      ?      :   0   :   0;  // pessimism
         1   x    x    (?x)   1      ?      :   0   :   0;  // pessimism
         1   x    1    (?x)   1      ?      :   0   :   0;  // pessimism

//       1   1   (x1)    1    1      ?      :   1   :   1;  // reducing pessimism
//       1   0   (x1)    1    1      ?      :   0   :   0;
         1   ?   (x1)    1    1      ?      :   ?   :   -;  // spr 80166-ignore
                                                            // x->1 edge
         1   1   (0x)    1    1      ?      :   1   :   1;
         1   0   (0x)    1    1      ?      :   0   :   0;

         ?   ?   ?       0    0      ?      :   ?   :   0;  // clear wins preset
         ?   ?   ?       0    1      ?      :   ?   :   0;  // asynch clear

         ?   ?   ?       1    0      ?      :   ?   :   1;  // asynch set

         1   ?   (?0)    1    1      ?      :   ?   :   -;  // ignore falling clock
         1   ?   (1x)    1    1      ?      :   ?   :   -;  // ignore falling clock
         1   *    ?      ?    ?      ?      :   ?   :   -; // ignore data edges

         1   ?   ?     (?1)   ?      ?      :   ?   :   -;  // ignore edges on
         1   ?   ?       ?  (?1)     ?      :   ?   :   -;  //  set and clear

         0   ?   ?       1    1      ?      :   ?   :   -;  //  set and clear

	 ?   ?   ?       1    1      *      :   ?   :   x; // spr 36954 - at any
							   // notifier event,
							   // output 'x'
    endtable

endprimitive

primitive TWENTYNM_PRIM_DFFEAS (q, d, clk, ena, clr, pre, ald, adt, sclr, sload, notifier  );
    input d,clk,ena,clr,pre,ald,adt,sclr,sload, notifier;
    output q;
    reg q;
    initial
    q = 1'b0;

    table
    ////d,clk, ena,clr,pre,ald,adt,sclr,sload,notifier: q : q'
        ? ?    ?   1   ?   ?   ?   ?    ?     ?       : ? : 0; // aclr
        ? ?    ?   0   1   ?   ?   ?    ?     ?       : ? : 1; // apre
        ? ?    ?   0   0   1   0   ?    ?     ?       : ? : 0; // aload 0
        ? ?    ?   0   0   1   1   ?    ?     ?       : ? : 1; // aload 1

        0 (01) 1   0   0   0   ?   0    0     ?       : ? : 0; // din 0
        1 (01) 1   0   0   0   ?   0    0     ?       : ? : 1; // din 1
        ? (01) 1   0   0   0   ?   1    ?     ?       : ? : 0; // sclr
        ? (01) 1   0   0   0   0   0    1     ?       : ? : 0; // sload 0
        ? (01) 1   0   0   0   1   0    1     ?       : ? : 1; // sload 1

        ? ?    0   0   0   0   ?   ?    ?     ?       : ? : -; // no asy no ena
        * ?    ?   ?   ?   ?   ?   ?    ?     ?       : ? : -; // data edges
        ? (?0) ?   ?   ?   ?   ?   ?    ?     ?       : ? : -; // ignore falling clk
        ? ?    *   ?   ?   ?   ?   ?    ?     ?       : ? : -; // enable edges
        ? ?    ?   (?0)?   ?   ?   ?    ?     ?       : ? : -; // falling asynchs
        ? ?    ?   ?  (?0) ?   ?   ?    ?     ?       : ? : -;
        ? ?    ?   ?   ?  (?0) ?   ?    ?     ?       : ? : -;
        ? ?    ?   ?   ?   0   *   ?    ?     ?       : ? : -; // ignore adata edges when not aloading
        ? ?    ?   ?   ?   ?   ?   *    ?     ?       : ? : -; // sclr edges
        ? ?    ?   ?   ?   ?   ?   ?    *     ?       : ? : -; // sload edges

        ? (x1) 1   0   0   0   ?   0    0     ?        : ? : -; // ignore x->1 transition of clock
        ? ?    1   0   0   x   ?   0    0     ?        : ? : -; // ignore x input of aload
        ? ?    ?   1   1   ?   ?   ?    ?     *       : ? : x; // at any notifier event, output x

    endtable
endprimitive

primitive TWENTYNM_PRIM_DFFEAS_HIGH (q, d, clk, ena, clr, pre, ald, adt, sclr, sload, notifier  );
    input d,clk,ena,clr,pre,ald,adt,sclr,sload, notifier;
    output q;
    reg q;
    initial
    q = 1'b1;

    table
    ////d,clk, ena,clr,pre,ald,adt,sclr,sload,notifier : q : q'
        ? ?    ?   1   ?   ?   ?   ?    ?     ?        : ? : 0; // aclr
        ? ?    ?   0   1   ?   ?   ?    ?     ?        : ? : 1; // apre
        ? ?    ?   0   0   1   0   ?    ?     ?        : ? : 0; // aload 0
        ? ?    ?   0   0   1   1   ?    ?     ?        : ? : 1; // aload 1

        0 (01) 1   0   0   0   ?   0    0     ?        : ? : 0; // din 0
        1 (01) 1   0   0   0   ?   0    0     ?        : ? : 1; // din 1
        ? (01) 1   0   0   0   ?   1    ?     ?        : ? : 0; // sclr
        ? (01) 1   0   0   0   0   0    1     ?        : ? : 0; // sload 0
        ? (01) 1   0   0   0   1   0    1     ?        : ? : 1; // sload 1

        ? ?    0   0   0   0   ?   ?    ?     ?        : ? : -; // no asy no ena
        * ?    ?   ?   ?   ?   ?   ?    ?     ?        : ? : -; // data edges
        ? (?0) ?   ?   ?   ?   ?   ?    ?     ?        : ? : -; // ignore falling clk
        ? ?    *   ?   ?   ?   ?   ?    ?     ?        : ? : -; // enable edges
        ? ?    ?   (?0)?   ?   ?   ?    ?     ?        : ? : -; // falling asynchs
        ? ?    ?   ?  (?0) ?   ?   ?    ?     ?        : ? : -;
        ? ?    ?   ?   ?  (?0) ?   ?    ?     ?        : ? : -;
        ? ?    ?   ?   ?   0   *   ?    ?     ?        : ? : -; // ignore adata edges when not aloading
        ? ?    ?   ?   ?   ?   ?   *    ?     ?        : ? : -; // sclr edges
        ? ?    ?   ?   ?   ?   ?   ?    *     ?        : ? : -; // sload edges

        ? (x1) 1   0   0   0   ?   0    0     ?        : ? : -; // ignore x->1 transition of clock
        ? ?    1   0   0   x   ?   0    0     ?        : ? : -; // ignore x input of aload
        ? ?    ?   1   1   ?   ?   ?    ?     *        : ? : x; // at any notifier event, output x

    endtable
endprimitive

module twentynm_dffe ( Q, CLK, ENA, D, CLRN, PRN );
   input D;
   input CLK;
   input CLRN;
   input PRN;
   input ENA;
   output Q;
   
   wire D_ipd;
   wire ENA_ipd;
   wire CLK_ipd;
   wire PRN_ipd;
   wire CLRN_ipd;
   
   buf (D_ipd, D);
   buf (ENA_ipd, ENA);
   buf (CLK_ipd, CLK);
   buf (PRN_ipd, PRN);
   buf (CLRN_ipd, CLRN);
   
   wire   legal;
   reg 	  viol_notifier;
   
   TWENTYNM_PRIM_DFFE ( Q, ENA_ipd, D_ipd, CLK_ipd, CLRN_ipd, PRN_ipd, viol_notifier );
   
   and(legal, ENA_ipd, CLRN_ipd, PRN_ipd);
   specify
      
      specparam TREG = 0;
      specparam TREN = 0;
      specparam TRSU = 0;
      specparam TRH  = 0;
      specparam TRPR = 0;
      specparam TRCL = 0;
      
      $setup  (  D, posedge CLK &&& legal, TRSU, viol_notifier  ) ;
      $hold   (  posedge CLK &&& legal, D, TRH, viol_notifier   ) ;
      $setup  (  ENA, posedge CLK &&& legal, TREN, viol_notifier  ) ;
      $hold   (  posedge CLK &&& legal, ENA, 0, viol_notifier   ) ;
 
      ( negedge CLRN => (Q  +: 1'b0)) = ( TRCL, TRCL) ;
      ( negedge PRN  => (Q  +: 1'b1)) = ( TRPR, TRPR) ;
      ( posedge CLK  => (Q  +: D)) = ( TREG, TREG) ;
      
   endspecify
endmodule     


// ***** twentynm_mux21

module twentynm_mux21 (MO, A, B, S);
   input A, B, S;
   output MO;
   
   wire A_in;
   wire B_in;
   wire S_in;

   buf(A_in, A);
   buf(B_in, B);
   buf(S_in, S);

   wire   tmp_MO;
   
   specify
      (A => MO) = (0, 0);
      (B => MO) = (0, 0);
      (S => MO) = (0, 0);
   endspecify

   assign tmp_MO = (S_in == 1) ? B_in : A_in;
   
   buf (MO, tmp_MO);
endmodule

// ***** twentynm_mux41

module twentynm_mux41 (MO, IN0, IN1, IN2, IN3, S);
   input IN0;
   input IN1;
   input IN2;
   input IN3;
   input [1:0] S;
   output MO;
   
   wire IN0_in;
   wire IN1_in;
   wire IN2_in;
   wire IN3_in;
   wire S1_in;
   wire S0_in;

   buf(IN0_in, IN0);
   buf(IN1_in, IN1);
   buf(IN2_in, IN2);
   buf(IN3_in, IN3);
   buf(S1_in, S[1]);
   buf(S0_in, S[0]);

   wire   tmp_MO;
   
   specify
      (IN0 => MO) = (0, 0);
      (IN1 => MO) = (0, 0);
      (IN2 => MO) = (0, 0);
      (IN3 => MO) = (0, 0);
      (S[1] => MO) = (0, 0);
      (S[0] => MO) = (0, 0);
   endspecify

   assign tmp_MO = S1_in ? (S0_in ? IN3_in : IN2_in) : (S0_in ? IN1_in : IN0_in);

   buf (MO, tmp_MO);

endmodule

// ***** twentynm_and1

module twentynm_and1 (Y, IN1);
   input IN1;
   output Y;
   
   specify
      (IN1 => Y) = (0, 0);
   endspecify
   
   buf (Y, IN1);
endmodule

// ***** twentynm_and16

module twentynm_and16 (Y, IN1);
   input [15:0] IN1;
   output [15:0] Y;
   
   specify
      (IN1 => Y) = (0, 0);
   endspecify
   
   buf (Y[0], IN1[0]);
   buf (Y[1], IN1[1]);
   buf (Y[2], IN1[2]);
   buf (Y[3], IN1[3]);
   buf (Y[4], IN1[4]);
   buf (Y[5], IN1[5]);
   buf (Y[6], IN1[6]);
   buf (Y[7], IN1[7]);
   buf (Y[8], IN1[8]);
   buf (Y[9], IN1[9]);
   buf (Y[10], IN1[10]);
   buf (Y[11], IN1[11]);
   buf (Y[12], IN1[12]);
   buf (Y[13], IN1[13]);
   buf (Y[14], IN1[14]);
   buf (Y[15], IN1[15]);
   
endmodule

// ***** twentynm_bmux21

module twentynm_bmux21 (MO, A, B, S);
   input [15:0] A, B;
   input 	S;
   output [15:0] MO; 
   
   assign MO = (S == 1) ? B : A; 
   
endmodule

// ***** twentynm_b17mux21

module twentynm_b17mux21 (MO, A, B, S);
   input [16:0] A, B;
   input 	S;
   output [16:0] MO; 
   
   assign MO = (S == 1) ? B : A; 
   
endmodule

// ***** twentynm_nmux21

module twentynm_nmux21 (MO, A, B, S);
   input A, B, S; 
   output MO; 
   
   assign MO = (S == 1) ? ~B : ~A; 
   
endmodule

// ***** twentynm_b5mux21

module twentynm_b5mux21 (MO, A, B, S);
   input [4:0] A, B;
   input       S;
   output [4:0] MO; 
   
   assign MO = (S == 1) ? B : A; 
   
endmodule

// ********** END PRIMITIVE DEFINITIONS **********


//------------------------------------------------------------------
//
// Module Name : twentynm_ff
//
// Description : Twentynm FF Verilog simulation model 
//
//------------------------------------------------------------------
`timescale 1 ps/1 ps
  
module twentynm_ff (
    d, 
    clk, 
    clrn, 
    aload, 
    sclr, 
    sload, 
    asdata, 
    ena, 
    devclrn, 
    devpor, 
    q
    );
   
parameter power_up = "low";
parameter x_on_violation = "on";
parameter lpm_type = "twentynm_ff";

input d;
input clk;
input clrn;
input aload; 
input sclr; 
input sload; 
input asdata; 
input ena; 
input devclrn; 
input devpor; 

output q;

tri1 devclrn;
tri1 devpor;

reg q_tmp;
wire reset;
   
reg d_viol;
reg sclr_viol;
reg sload_viol;
reg asdata_viol;
reg ena_viol; 
reg violation;

reg clk_last_value;
   
reg ix_on_violation;

wire d_in;
wire clk_in;
wire clrn_in;
wire aload_in;
wire sclr_in;
wire sload_in;
wire asdata_in;
wire ena_in;
   
wire nosloadsclr;
wire sloaddata;

buf (d_in, d);
buf (clk_in, clk);
buf (clrn_in, clrn);
buf (aload_in, aload);
buf (sclr_in, sclr);
buf (sload_in, sload);
buf (asdata_in, asdata);
buf (ena_in, ena);
   
assign reset = devpor && devclrn && clrn_in && ena_in;
assign nosloadsclr = reset && (!sload_in && !sclr_in);
assign sloaddata = reset && sload_in;
   
specify

    $setuphold (posedge clk &&& nosloadsclr, d, 0, 0, d_viol) ;
    $setuphold (posedge clk &&& reset, sclr, 0, 0, sclr_viol) ;
    $setuphold (posedge clk &&& reset, sload, 0, 0, sload_viol) ;
    $setuphold (posedge clk &&& sloaddata, asdata, 0, 0, asdata_viol) ;
    $setuphold (posedge clk &&& reset, ena, 0, 0, ena_viol) ;
      
    (posedge clk => (q +: q_tmp)) = 0 ;
    (posedge clrn => (q +: 1'b0)) = (0, 0) ;
    (posedge aload => (q +: q_tmp)) = (0, 0) ;
    (asdata => q) = (0, 0) ;
      
endspecify
   
initial
begin
    violation = 'b0;
    clk_last_value = 'b0;

    if (power_up == "low")
        q_tmp = 'b0;
    else if (power_up == "high")
        q_tmp = 'b1;

    if (x_on_violation == "on")
        ix_on_violation = 1;
    else
        ix_on_violation = 0;
end
   
always @ (d_viol or sclr_viol or sload_viol or ena_viol or asdata_viol)
begin
    if (ix_on_violation == 1)
        violation = 'b1;
end
   
always @ (asdata_in or clrn_in or posedge aload_in or 
          devclrn or devpor)
begin
    if (devpor == 'b0)
        q_tmp <= 'b0;
    else if (devclrn == 'b0)
        q_tmp <= 'b0;
    else if (clrn_in == 'b0) 
        q_tmp <= 'b0;
    else if (aload_in == 'b1) 
        q_tmp <= asdata_in;
end
   
always @ (clk_in or posedge clrn_in or posedge aload_in or 
          devclrn or devpor or posedge violation)
begin
    if (violation == 1'b1)
    begin
        violation = 'b0;
        q_tmp <= 'bX;
    end
    else
    begin
        if (devpor == 'b0 || devclrn == 'b0 || clrn_in === 'b0)
            q_tmp <= 'b0;
        else if (aload_in === 'b1) 
            q_tmp <= asdata_in;
        else if (ena_in === 'b1 && clk_in === 'b1 && clk_last_value === 'b0)
        begin
            if (sclr_in === 'b1)
                q_tmp <= 'b0 ;
            else if (sload_in === 'b1)
                q_tmp <= asdata_in;
            else 
                q_tmp <= d_in;
        end
    end

    clk_last_value = clk_in;
end

and (q, q_tmp, 1'b1);

endmodule

//------------------------------------------------------------------
//
// Module Name : twentynm_lcell_comb
//
// Description : Stratix II LCELL_COMB Verilog simulation model 
//
//------------------------------------------------------------------

// Deactivate the following LEDA rules for twentynm_lcell_comb.v
// G_521_3B: Use uppercase letters for all parameter names
// B_3417: Use non-blocking assignments in sequential block
// B_3419: Missing signal iextended_lut in sensitivity list
// leda G_521_3_B off
// leda B_3417 off
// leda B_3419 off

`timescale 1 ps/1 ps
  
module twentynm_lcell_comb (
                             dataa, 
                             datab, 
                             datac, 
                             datad, 
                             datae, 
                             dataf, 
                             datag, 
                             cin,
                             sharein, 
                             combout, 
                             sumout,
                             cout, 
                             shareout 
                            );

input dataa;
input datab;
input datac;
input datad;
input datae;
input dataf;
input datag;
input cin;
input sharein;

output combout;
output sumout;
output cout;
output shareout;

parameter lut_mask = 64'hFFFFFFFFFFFFFFFF;
parameter shared_arith = "off";
parameter extended_lut = "off";
parameter dont_touch = "off";
parameter lpm_type = "twentynm_lcell_comb";

// sub masks
wire [15:0] f0_mask;
wire [15:0] f1_mask;
wire [15:0] f2_mask;
wire [15:0] f3_mask;

// sub lut outputs
reg f0_out;
reg f1_out;
reg f2_out;
reg f3_out;

// mux output for extended mode
reg g0_out;
reg g1_out;

// either datac or datag
reg f2_input3;

// F2 output using dataf
reg f2_f;

// second input to the adder
reg adder_input2;

// tmp output variables
reg combout_tmp;
reg sumout_tmp;
reg cout_tmp;

// integer representations for string parameters
reg ishared_arith;
reg iextended_lut;

// 4-input LUT function
function lut4;
input [15:0] mask;
input dataa;
input datab;
input datac;
input datad;
      
begin

    lut4 = datad ? ( datac ? ( datab ? ( dataa ? mask[15] : mask[14])
                                     : ( dataa ? mask[13] : mask[12]))
                           : ( datab ? ( dataa ? mask[11] : mask[10]) 
                                     : ( dataa ? mask[ 9] : mask[ 8])))
                 : ( datac ? ( datab ? ( dataa ? mask[ 7] : mask[ 6]) 
                                     : ( dataa ? mask[ 5] : mask[ 4]))
                           : ( datab ? ( dataa ? mask[ 3] : mask[ 2]) 
                                     : ( dataa ? mask[ 1] : mask[ 0])));

end
endfunction

// 5-input LUT function
function lut5;
input [31:0] mask;
input dataa;
input datab;
input datac;
input datad;
input datae;
reg e0_lut;
reg e1_lut;
reg [15:0] e0_mask;
reg [31:16] e1_mask;

      
begin

    e0_mask = mask[15:0];
    e1_mask = mask[31:16];

	 begin
        e0_lut = lut4(e0_mask, dataa, datab, datac, datad);
        e1_lut = lut4(e1_mask, dataa, datab, datac, datad);

        if (datae === 1'bX) // X propogation
        begin
            if (e0_lut == e1_lut)
            begin
                lut5 = e0_lut;
            end
            else
            begin
                lut5 = 1'bX;
            end
        end
        else
        begin
            lut5 = (datae == 1'b1) ? e1_lut : e0_lut;
        end
    end
end
endfunction

// 6-input LUT function
function lut6;
input [63:0] mask;
input dataa;
input datab;
input datac;
input datad;
input datae;
input dataf;
reg f0_lut;
reg f1_lut;
reg [31:0] f0_mask;
reg [63:32] f1_mask ;
      
begin

    f0_mask = mask[31:0];
    f1_mask = mask[63:32];

	 begin

        lut6 = mask[{dataf, datae, datad, datac, datab, dataa}];

        if (lut6 === 1'bX)
        begin
            f0_lut = lut5(f0_mask, dataa, datab, datac, datad, datae);
            f1_lut = lut5(f1_mask, dataa, datab, datac, datad, datae);
    
            if (dataf === 1'bX) // X propogation
            begin
                if (f0_lut == f1_lut)
                begin
                    lut6 = f0_lut;
                end
                else
                begin
                    lut6 = 1'bX;
                end
            end
            else
            begin
                lut6 = (dataf == 1'b1) ? f1_lut : f0_lut;
            end
        end
    end
end
endfunction

wire dataa_in;
wire datab_in;
wire datac_in;
wire datad_in;
wire datae_in;
wire dataf_in;
wire datag_in;
wire cin_in;
wire sharein_in;

buf(dataa_in, dataa);
buf(datab_in, datab);
buf(datac_in, datac);
buf(datad_in, datad);
buf(datae_in, datae);
buf(dataf_in, dataf);
buf(datag_in, datag);
buf(cin_in, cin);
buf(sharein_in, sharein);

specify

    (dataa => combout) = (0, 0);
    (datab => combout) = (0, 0);
    (datac => combout) = (0, 0);
    (datad => combout) = (0, 0);
    (datae => combout) = (0, 0);
    (dataf => combout) = (0, 0);
    (datag => combout) = (0, 0);

    (dataa => sumout) = (0, 0);
    (datab => sumout) = (0, 0);
    (datac => sumout) = (0, 0);
    (datad => sumout) = (0, 0);
    (dataf => sumout) = (0, 0);
    (cin => sumout) = (0, 0);
    (sharein => sumout) = (0, 0);

    (dataa => cout) = (0, 0);
    (datab => cout) = (0, 0);
    (datac => cout) = (0, 0);
    (datad => cout) = (0, 0);
    (dataf => cout) = (0, 0);
    (cin => cout) = (0, 0);
    (sharein => cout) = (0, 0);

    (dataa => shareout) = (0, 0);
    (datab => shareout) = (0, 0);
    (datac => shareout) = (0, 0);
    (datad => shareout) = (0, 0);

endspecify

initial
begin
    if (shared_arith == "on")
        ishared_arith = 1;
    else
        ishared_arith = 0;

    if (extended_lut == "on")
        iextended_lut = 1;
    else
        iextended_lut = 0;

    f0_out = 1'b0;
    f1_out = 1'b0;
    f2_out = 1'b0;
    f3_out = 1'b0;
    g0_out = 1'b0;
    g1_out = 1'b0;
    f2_input3 = 1'b0;
    adder_input2 = 1'b0;
    f2_f = 1'b0;
    combout_tmp = 1'b0;
    sumout_tmp = 1'b0;
    cout_tmp = 1'b0;
end

// sub masks and outputs
assign f0_mask = lut_mask[15:0];
assign f1_mask = lut_mask[31:16];
assign f2_mask = lut_mask[47:32];
assign f3_mask = lut_mask[63:48];

always @(datag_in or dataf_in or datae_in or datad_in or datac_in or 
         datab_in or dataa_in or cin_in or sharein_in)
begin

    // check for extended LUT mode
    if (iextended_lut == 1) 
        f2_input3 = datag_in;
    else
        f2_input3 = datac_in;

    f0_out = lut4(f0_mask, dataa_in, datab_in, datac_in, datad_in);
    f1_out = lut4(f1_mask, dataa_in, datab_in, f2_input3, datad_in);
    f2_out = lut4(f2_mask, dataa_in, datab_in, datac_in, datad_in);
    f3_out = lut4(f3_mask, dataa_in, datab_in, f2_input3, datad_in);

    // combout is the 6-input LUT
    if (iextended_lut == 1)
    begin
        if (datae_in == 1'b0)
        begin
            g0_out = f0_out;
            g1_out = f2_out;
        end
        else if (datae_in == 1'b1)
        begin
            g0_out = f1_out;
            g1_out = f3_out;
        end
        else
        begin
            if (f0_out == f1_out)
                g0_out = f0_out;
            else
                g0_out = 1'bX;

            if (f2_out == f3_out)
                g1_out = f2_out;
            else
                g1_out = 1'bX;
        end
    
        if (dataf_in == 1'b0)
            combout_tmp = g0_out;
        else if ((dataf_in == 1'b1) || (g0_out == g1_out))
            combout_tmp = g1_out;
        else
            combout_tmp = 1'bX;
    end
    else
        combout_tmp = lut6(lut_mask, dataa_in, datab_in, datac_in, 
                           datad_in, datae_in, dataf_in);

    // check for shareed arithmetic mode
    if (ishared_arith == 1) 
        adder_input2 = sharein_in;
    else
    begin
        f2_f = lut4(f2_mask, dataa_in, datab_in, datac_in, dataf_in);
        adder_input2 = !f2_f;
    end

    // sumout & cout
    sumout_tmp = cin_in ^ f0_out ^ adder_input2;
    cout_tmp = (cin_in & f0_out) | (cin_in & adder_input2) | 
               (f0_out & adder_input2);

end

and (combout, combout_tmp, 1'b1);
and (sumout, sumout_tmp, 1'b1);
and (cout, cout_tmp, 1'b1);
and (shareout, f2_out, 1'b1);

endmodule

// Re-activate the LEDA rules
// leda G_521_3_B on
// leda B_3417 on
// leda B_3419 on
//------------------------------------------------------------------
//
// Module Name : twentynm_routing_wire
//
// Description : Simulation model for a simple routing wire
//
//------------------------------------------------------------------

`timescale 1ps / 1ps

module twentynm_routing_wire (
                               datain,
                               dataout
                               );

    // INPUT PORTS
    input datain;

    // OUTPUT PORTS
    output dataout;

    // INTERNAL VARIABLES
    wire dataout_tmp;

    specify

        (datain => dataout) = (0, 0) ;

    endspecify

    assign dataout_tmp = datain;

    and (dataout, dataout_tmp, 1'b1);

endmodule // twentynm_routing_wire
// Deactivate the following LEDA rules for twentynm_ram_block.v
// G_521_3B: Use uppercase letters for all parameter names
// leda G_521_3_B off

`timescale 1 ps/1 ps

//--------------------------------------------------------------------------
// Module Name     : twentynm_ram_block
// Description     : Main RAM module
//--------------------------------------------------------------------------

module twentynm_ram_block
    (
     portadatain,
     portaaddr,
     portawe,
     portare,
     portbdatain,
     portbaddr,
     portbwe,
     portbre,
     clk0, clk1,
     ena0, ena1,
     ena2, ena3,
     clr0, clr1,
     nerror,
     portabyteenamasks,
     portbbyteenamasks,
     portaaddrstall,
     portbaddrstall,
     devclrn,
     devpor,
     eccstatus,
     portadataout,
     portbdataout
      ,dftout
     );
// -------- GLOBAL PARAMETERS ---------
parameter operation_mode = "single_port";
parameter mixed_port_feed_through_mode = "dont_care";
parameter ram_block_type = "auto";
parameter logical_ram_name = "ram_name";

parameter init_file = "init_file.hex";
parameter init_file_layout = "none";

parameter ecc_pipeline_stage_enabled = "false";
parameter enable_ecc = "false";
parameter width_eccstatus = 2;
parameter data_interleave_width_in_bits = 1;
parameter data_interleave_offset_in_bits = 1;
parameter port_a_logical_ram_depth = 0;
parameter port_a_logical_ram_width = 0;
parameter port_a_first_address = 0;
parameter port_a_last_address = 0;
parameter port_a_first_bit_number = 0;

parameter port_a_data_out_clear = "none";

parameter port_a_data_out_clock = "none";

parameter port_a_data_width = 1;
parameter port_a_address_width = 1;
parameter port_a_byte_enable_mask_width = 1;

parameter port_b_logical_ram_depth = 0;
parameter port_b_logical_ram_width = 0;
parameter port_b_first_address = 0;
parameter port_b_last_address = 0;
parameter port_b_first_bit_number = 0;

parameter port_b_address_clear = "none";
parameter port_b_data_out_clear = "none";

parameter port_b_data_in_clock = "clock1";
parameter port_b_address_clock = "clock1";
parameter port_b_write_enable_clock = "clock1";
parameter port_b_read_enable_clock  = "clock1";
parameter port_b_byte_enable_clock = "clock1";
parameter port_b_data_out_clock = "none";

parameter port_b_data_width = 1;
parameter port_b_address_width = 1;
parameter port_b_byte_enable_mask_width = 1;

parameter port_a_read_during_write_mode = "new_data_no_nbe_read";
parameter port_b_read_during_write_mode = "new_data_no_nbe_read";
parameter power_up_uninitialized = "false";
parameter lpm_type = "twentynm_ram_block";
parameter lpm_hint = "true";
parameter connectivity_checking = "off";

parameter mem_init0 = "";
parameter mem_init1 = "";
parameter mem_init2 = "";
parameter mem_init3 = "";
parameter mem_init4 = "";
parameter mem_init5 = "";
parameter mem_init6 = "";
parameter mem_init7 = "";
parameter mem_init8 = "";
parameter mem_init9 = "";

parameter port_a_byte_size = 0;
parameter port_b_byte_size = 0;

parameter clk0_input_clock_enable  = "none"; // ena0,ena2,none
parameter clk0_core_clock_enable   = "none"; // ena0,ena2,none
parameter clk0_output_clock_enable = "none"; // ena0,none
parameter clk1_input_clock_enable  = "none"; // ena1,ena3,none
parameter clk1_core_clock_enable   = "none"; // ena1,ena3,none
parameter clk1_output_clock_enable = "none"; // ena1,none

parameter bist_ena = "false"; //false, true 

// SIMULATION_ONLY_PARAMETERS_BEGIN

parameter port_a_address_clear = "none";

parameter port_a_data_in_clock = "clock0";
parameter port_a_address_clock = "clock0";
parameter port_a_write_enable_clock = "clock0";
parameter port_a_byte_enable_clock = "clock0";
parameter port_a_read_enable_clock = "clock0";

// SIMULATION_ONLY_PARAMETERS_END

// -------- PORT DECLARATIONS ---------
input portawe;
input portare;
input [port_a_data_width - 1:0] portadatain;
input [port_a_address_width - 1:0] portaaddr;
input [port_a_byte_enable_mask_width - 1:0] portabyteenamasks;

input portbwe, portbre;
input [port_b_data_width - 1:0] portbdatain;
input [port_b_address_width - 1:0] portbaddr;
input [port_b_byte_enable_mask_width - 1:0] portbbyteenamasks;

input clr0,clr1;
input clk0,clk1;
input ena0,ena1;
input ena2,ena3;
input nerror;

input devclrn,devpor;
input portaaddrstall;
input portbaddrstall;
output [port_a_data_width - 1:0] portadataout;
output [port_b_data_width - 1:0] portbdataout;
output [width_eccstatus - 1:0] eccstatus;
output [8:0] dftout;

// -------- RAM BLOCK INSTANTIATION ---
generic_m20k ram_core0
(
	.portawe(portawe),
	.portare(portare),
	.portadatain(portadatain),
	.portaaddr(portaaddr),
	.portabyteenamasks(portabyteenamasks),
	.portbwe(portbwe),
	.portbre(portbre),
	.portbdatain(portbdatain),
	.portbaddr(portbaddr),
	.portbbyteenamasks(portbbyteenamasks),
	.clr0(clr0),
	.clr1(clr1),
	.clk0(clk0),
	.clk1(clk1),
	.ena0(ena0),
	.ena1(ena1),
	.ena2(ena2),
	.ena3(ena3),
	.nerror(nerror),
	.devclrn(devclrn),
	.devpor(devpor),
	.portaaddrstall(portaaddrstall),
	.portbaddrstall(portbaddrstall),
	.portadataout(portadataout),
	.portbdataout(portbdataout),
	.eccstatus(eccstatus),
	.dftout(dftout)
);
defparam ram_core0.operation_mode = operation_mode;
defparam ram_core0.mixed_port_feed_through_mode = mixed_port_feed_through_mode;
defparam ram_core0.ram_block_type = ram_block_type;
defparam ram_core0.logical_ram_name = logical_ram_name;
defparam ram_core0.init_file = init_file;
defparam ram_core0.init_file_layout = init_file_layout;
defparam ram_core0.ecc_pipeline_stage_enabled = ecc_pipeline_stage_enabled;
defparam ram_core0.enable_ecc = enable_ecc;
defparam ram_core0.width_eccstatus = width_eccstatus;
defparam ram_core0.data_interleave_width_in_bits = data_interleave_width_in_bits;
defparam ram_core0.data_interleave_offset_in_bits = data_interleave_offset_in_bits;
defparam ram_core0.port_a_logical_ram_depth = port_a_logical_ram_depth;
defparam ram_core0.port_a_logical_ram_width = port_a_logical_ram_width;
defparam ram_core0.port_a_first_address = port_a_first_address;
defparam ram_core0.port_a_last_address = port_a_last_address;
defparam ram_core0.port_a_first_bit_number = port_a_first_bit_number;
defparam ram_core0.port_a_data_out_clear = port_a_data_out_clear;
defparam ram_core0.port_a_data_out_clock = port_a_data_out_clock;
defparam ram_core0.port_a_data_width = port_a_data_width;
defparam ram_core0.port_a_address_width = port_a_address_width;
defparam ram_core0.port_a_byte_enable_mask_width = port_a_byte_enable_mask_width;
defparam ram_core0.port_b_logical_ram_depth = port_b_logical_ram_depth;
defparam ram_core0.port_b_logical_ram_width = port_b_logical_ram_width;
defparam ram_core0.port_b_first_address = port_b_first_address;
defparam ram_core0.port_b_last_address = port_b_last_address;
defparam ram_core0.port_b_first_bit_number = port_b_first_bit_number;
defparam ram_core0.port_b_address_clear = port_b_address_clear;
defparam ram_core0.port_b_data_out_clear = port_b_data_out_clear;
defparam ram_core0.port_b_data_in_clock = port_b_data_in_clock;
defparam ram_core0.port_b_address_clock = port_b_address_clock;
defparam ram_core0.port_b_write_enable_clock = port_b_write_enable_clock;
defparam ram_core0.port_b_read_enable_clock = port_b_read_enable_clock;
defparam ram_core0.port_b_byte_enable_clock = port_b_byte_enable_clock;
defparam ram_core0.port_b_data_out_clock = port_b_data_out_clock;
defparam ram_core0.port_b_data_width = port_b_data_width;
defparam ram_core0.port_b_address_width = port_b_address_width;
defparam ram_core0.port_b_byte_enable_mask_width = port_b_byte_enable_mask_width;
defparam ram_core0.port_a_read_during_write_mode = port_a_read_during_write_mode;
defparam ram_core0.port_b_read_during_write_mode = port_b_read_during_write_mode;
defparam ram_core0.power_up_uninitialized = power_up_uninitialized;
defparam ram_core0.lpm_type = lpm_type;
defparam ram_core0.lpm_hint = lpm_hint;
defparam ram_core0.connectivity_checking = connectivity_checking;
defparam ram_core0.mem_init0 = mem_init0;
defparam ram_core0.mem_init1 = mem_init1;
defparam ram_core0.mem_init2 = mem_init2;
defparam ram_core0.mem_init3 = mem_init3;
defparam ram_core0.mem_init4 = mem_init4;
defparam ram_core0.mem_init5 = mem_init5;
defparam ram_core0.mem_init6 = mem_init6;
defparam ram_core0.mem_init7 = mem_init7;
defparam ram_core0.mem_init8 = mem_init8;
defparam ram_core0.mem_init9 = mem_init9;
defparam ram_core0.port_a_byte_size = port_a_byte_size;
defparam ram_core0.port_b_byte_size = port_b_byte_size;
defparam ram_core0.clk0_input_clock_enable = clk0_input_clock_enable;
defparam ram_core0.clk0_core_clock_enable = clk0_core_clock_enable ;
defparam ram_core0.clk0_output_clock_enable = clk0_output_clock_enable;
defparam ram_core0.clk1_input_clock_enable = clk1_input_clock_enable;
defparam ram_core0.clk1_core_clock_enable = clk1_core_clock_enable;
defparam ram_core0.clk1_output_clock_enable = clk1_output_clock_enable;
defparam ram_core0.bist_ena = bist_ena;
defparam ram_core0.port_a_address_clear = port_a_address_clear;
defparam ram_core0.port_a_data_in_clock = port_a_data_in_clock;
defparam ram_core0.port_a_address_clock = port_a_address_clock;
defparam ram_core0.port_a_write_enable_clock = port_a_write_enable_clock;
defparam ram_core0.port_a_byte_enable_clock = port_a_byte_enable_clock;
defparam ram_core0.port_a_read_enable_clock = port_a_read_enable_clock;

endmodule // twentynm_ram_block

// Re-activate the LEDA rules
// leda G_521_3_B on



//--------------------------------------------------------------------------
// Module Name     : twentynm_mlab_cell
// Description     : Main RAM module
//--------------------------------------------------------------------------

`timescale 1 ps/1 ps

module twentynm_mlab_cell
    (
     portadatain,
     portaaddr, 
     portabyteenamasks, 
     portbaddr,
     clk0, clk1,
     ena0, ena1,
   	 ena2,
   	 clr,
	 devclrn,
     devpor,
     portbdataout
     );
// -------- GLOBAL PARAMETERS ---------

parameter logical_ram_name = "lutram";

parameter logical_ram_depth = 0;
parameter logical_ram_width = 0;
parameter first_address = 0;
parameter last_address = 0;
parameter first_bit_number = 0;

parameter mixed_port_feed_through_mode = "new";
parameter init_file = "NONE";

parameter data_width = 20;
parameter address_width = 5;
parameter byte_enable_mask_width = 1;
parameter byte_size = 1;
parameter port_b_data_out_clock = "none";
parameter port_b_data_out_clear = "none";

parameter lpm_type = "twentynm_mlab_cell";
parameter lpm_hint = "true";

parameter mem_init0 = ""; 

// -------- PORT DECLARATIONS ---------
input [data_width - 1:0] portadatain;
input [address_width - 1:0] portaaddr;
input [byte_enable_mask_width - 1:0] portabyteenamasks;
input [address_width - 1:0] portbaddr;

input clk0;
input clk1;

input ena0;
input ena1;
input ena2;

input clr;

input devclrn;
input devpor;

output [data_width - 1:0] portbdataout;

generic_28nm_lc_mlab_cell_impl my_lutram0
(
	.portadatain(portadatain),
	.portaaddr(portaaddr),
	.portabyteenamasks(portabyteenamasks),
	.portbaddr(portbaddr),
	.clk0(clk0),
	.clk1(clk1),
	.ena0(ena0),
	.ena1(ena1),
	.ena2(ena2),
	.clr(clr),
	.devclrn(devclrn),
	.devpor(devpor),
	.portbdataout(portbdataout)
);
defparam my_lutram0.logical_ram_name = logical_ram_name;
defparam my_lutram0.logical_ram_depth = logical_ram_depth;
defparam my_lutram0.logical_ram_width = logical_ram_width;
defparam my_lutram0.first_address = first_address;
defparam my_lutram0.last_address = last_address;
defparam my_lutram0.first_bit_number = first_bit_number;
defparam my_lutram0.mixed_port_feed_through_mode = mixed_port_feed_through_mode;
defparam my_lutram0.init_file = init_file;
defparam my_lutram0.data_width = data_width;
defparam my_lutram0.address_width = address_width;
defparam my_lutram0.byte_enable_mask_width = byte_enable_mask_width;
defparam my_lutram0.byte_size = byte_size;
defparam my_lutram0.port_b_data_out_clock = port_b_data_out_clock;
defparam my_lutram0.port_b_data_out_clear = port_b_data_out_clear;
defparam my_lutram0.lpm_type = lpm_type;
defparam my_lutram0.lpm_hint = lpm_hint;
defparam my_lutram0.mem_init0 = mem_init0;

endmodule // twentynm_mlab_cell
///////////////////////////////////////////////////////////////////////////////////////////
//Module Name:                    twentynm_io_ibuf                                          //                              
//Description:                    Simulation model for Twentynm IO Input Buffer         //
//                                                                                       //                                
///////////////////////////////////////////////////////////////////////////////////////////

// Deactivate the following LEDA rules for twentynm_iobuf_atom.v
// G_521_3B: Use uppercase letters for all parameter names
// B_3416: Use blocking assignments in combinatorial block
// B_3417: Use non-blocking assignments in sequential block
// B_3418: Redundant signal in sensitivity list
// B_3419: Missing signal in sensitivity list
// leda G_521_3_B off
// leda B_3416 off
// leda B_3417 off
// leda B_3418 off
// leda B_3419 off

module twentynm_io_ibuf (
                      i,
                      ibar,
                      seriesterminationcontrol,
                      parallelterminationcontrol,     
                     dynamicterminationcontrol,      
                      o
                     );

// SIMULATION_ONLY_PARAMETERS_BEGIN

parameter differential_mode = "false";
parameter bus_hold = "false";
parameter simulate_z_as = "Z";
parameter lpm_type = "twentynm_io_ibuf";

// SIMULATION_ONLY_PARAMETERS_END

//Input Ports Declaration
input i;
input ibar;
input dynamicterminationcontrol; 
input [15:0] seriesterminationcontrol;
input [15:0] parallelterminationcontrol;

//Output Ports Declaration
output o;

// Internal signals
reg out_tmp;
reg o_tmp;
wire out_val ;
reg prev_value;

specify
    (i => o)    = (0, 0);
    (ibar => o) = (0, 0);
endspecify

initial
    begin
        prev_value = 1'b0;
    end

always@(i or ibar)
    begin
        if(differential_mode == "false")
            begin
                if(i == 1'b1)
                    begin
                        o_tmp = 1'b1;
                        prev_value = 1'b1;
                    end
                else if(i == 1'b0)
                    begin
                        o_tmp = 1'b0;
                        prev_value = 1'b0;
                    end
                else if( i === 1'bz)
                    o_tmp = out_val;
                else
                    o_tmp = i;
                    
                if( bus_hold == "true")
                    out_tmp = prev_value;
                else
                    out_tmp = o_tmp;
            end
        else
            begin
                case({i,ibar})
                    2'b00: out_tmp = 1'bX;
                    2'b01: out_tmp = 1'b0;
                    2'b10: out_tmp = 1'b1;
                    2'b11: out_tmp = 1'bX;
                    default: out_tmp = 1'bX;
                endcase

        end
    end
    
assign out_val = (simulate_z_as == "Z") ? 1'bz :
                 (simulate_z_as == "X") ? 1'bx :
                 (simulate_z_as == "vcc")? 1'b1 :
                 (simulate_z_as == "gnd") ? 1'b0 : 1'bz;

pmos (o, out_tmp, 1'b0);

endmodule

/////////////////////////////////////////////////////////////////////////////////////////
//Module Name:                    twentynm_io_obuf                                        //
//Description:                    Simulation model for Twentynm IO Output Buffer     //
//                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////

module twentynm_io_obuf (
                      i,
                      oe,
                      dynamicterminationcontrol,      
                      seriesterminationcontrol,
                      parallelterminationcontrol,     
                      devoe,
                      o,
                      obar
                    );

//Parameter Declaration
parameter open_drain_output = "false";
parameter bus_hold = "false";
parameter shift_series_termination_control = "false";  
parameter sim_dynamic_termination_control_is_connected = "false"; 
parameter lpm_type = "twentynm_io_obuf";

//Input Ports Declaration
input i;
input oe;
input devoe;
input dynamicterminationcontrol; 
input [15:0] seriesterminationcontrol;
input [15:0] parallelterminationcontrol;

//Outout Ports Declaration
output o;
output obar;

//INTERNAL Signals
reg out_tmp;
reg out_tmp_bar;
reg prev_value;
wire tmp;
wire tmp_bar;
wire tmp1;
wire tmp1_bar;

tri1 devoe;
tri1 oe;

specify
    (i => o)    = (0, 0);
    (i => obar) = (0, 0);
    (oe => o)   = (0, 0);
    (oe => obar)   = (0, 0);
endspecify

initial
    begin
        prev_value = 'b0;
        out_tmp = 'bz;
    end

always@(i or oe)
    begin
        if(oe == 1'b1)
            begin
                if(open_drain_output == "true")
                    begin
                        if(i == 'b0)
                             begin
                                 out_tmp = 'b0;
                                 out_tmp_bar = 'b1;
                                 prev_value = 'b0;
                             end
                        else
                             begin
                                 out_tmp = 'bz;
                                 out_tmp_bar = 'bz;
                             end
                    end
                else
                    begin
                        if( i == 'b0)
                            begin
                                out_tmp = 'b0;
                                out_tmp_bar = 'b1;
                                prev_value = 'b0;
                            end
                        else if( i == 'b1)
                            begin
                                out_tmp = 'b1;
                                out_tmp_bar = 'b0;
                                prev_value = 'b1;
                            end
                        else
                            begin
                                out_tmp = i;
                                out_tmp_bar = i;
                            end
                    end
            end
        else if(oe == 1'b0)
            begin
                out_tmp = 'bz;
                out_tmp_bar = 'bz;
            end
        else
            begin
                out_tmp = 'bx;
                out_tmp_bar = 'bx;
            end
    end

assign tmp = (bus_hold == "true") ? prev_value : out_tmp;
assign tmp_bar = (bus_hold == "true") ? !prev_value : out_tmp_bar;
assign tmp1 = ((oe == 1'b1) && (dynamicterminationcontrol == 1'b1) && (sim_dynamic_termination_control_is_connected == "true")) ? 1'bx :(devoe == 1'b1) ? tmp : 1'bz; 
assign tmp1_bar =((oe == 1'b1) && (dynamicterminationcontrol == 1'b1)&& (sim_dynamic_termination_control_is_connected == "true")) ? 1'bx : (devoe == 1'b1) ? tmp_bar : 1'bz; 

pmos (o, tmp1, 1'b0);
pmos (obar, tmp1_bar, 1'b0);

endmodule


// Re-activate the following LEDA rules
// leda G_521_3_B off
// leda B_3416 off
// leda B_3417 off
// leda B_3418 off
// leda B_3419 off
//////////////////////////////////////////////////////////////////////////////////
//Module Name:                    twentynm_pseudo_diff_out                          //
//Description:                    Simulation model for Twentynm Pseudo Differential //
//                                Output Buffer                                  //
//////////////////////////////////////////////////////////////////////////////////

module twentynm_pseudo_diff_out(
	i,
	ibar,
	oein,
	oebin,
	dtcin,
	dtcbarin,
	o,
	obar,
	oeout,
	oebout,
	dtc,
	dtcbar
);

parameter lpm_type = "twentynm_pseudo_diff_out";
parameter feedthrough = "false";

input i, ibar, oein, oebin, dtcin, dtcbarin;
output o, obar, oeout, oebout, dtc, dtcbar;

assign o = i;
assign obar = (feedthrough == "true") ? ibar : ~i;
assign oeout = oein;
assign oebout = (feedthrough == "true") ? oebin : oein;
assign dtc = dtcin;
assign dtcbar = (feedthrough == "true") ? dtcbarin : dtcin;

endmodule

//--------------------------------------------------------------------------
// Module Name     : twentynm_io_pad
// Description     : Simulation model for stratixiii IO pad
//--------------------------------------------------------------------------

`timescale 1 ps/1 ps

module twentynm_io_pad ( 
		      padin, 
                      padout
	            );

parameter lpm_type = "twentynm_io_pad";
//INPUT PORTS
input padin; //Input Pad

//OUTPUT PORTS
output padout;//Output Pad

//INTERNAL SIGNALS
wire padin_ipd;
wire padout_opd;

//INPUT BUFFER INSERTION FOR VERILOG-XL
buf padin_buf  (padin_ipd,padin);


assign padout_opd = padin_ipd;

//OUTPUT BUFFER INSERTION FOR VERILOG-XL
buf padout_buf (padout, padout_opd);

endmodule

// -----------------------------------------------------------
//
// Module Name : twentynm_bias_logic
//
// Description : STRATIXIII Bias Block's Logic Block
//               Verilog simulation model
//
// -----------------------------------------------------------

`timescale 1 ps/1 ps

module twentynm_bias_logic (
    clk,
    shiftnld,
    captnupdt,
    mainclk,
    updateclk,
    capture,
    update
    );

// INPUT PORTS
input  clk;
input  shiftnld;
input  captnupdt;
    
// OUTPUTPUT PORTS
output mainclk;
output updateclk;
output capture;
output update;

// INTERNAL VARIABLES
reg mainclk_tmp;
reg updateclk_tmp;
reg capture_tmp;
reg update_tmp;

initial
begin
    mainclk_tmp <= 'b0;
    updateclk_tmp <= 'b0;
    capture_tmp <= 'b0;
    update_tmp <= 'b0;
end

    always @(captnupdt or shiftnld or clk)
    begin
        case ({captnupdt, shiftnld})
        2'b10, 2'b11 :
            begin
                mainclk_tmp <= 'b0;
                updateclk_tmp <= clk;
                capture_tmp <= 'b1;
                update_tmp <= 'b0;
            end
        2'b01 :
            begin
                mainclk_tmp <= 'b0;
                updateclk_tmp <= clk;
                capture_tmp <= 'b0;
                update_tmp <= 'b0;
            end
        2'b00 :
            begin
                mainclk_tmp <= clk;
                updateclk_tmp <= 'b0;
                capture_tmp <= 'b0;
                update_tmp <= 'b1;
            end
        default :
            begin
                mainclk_tmp <= 'b0;
                updateclk_tmp <= 'b0;
                capture_tmp <= 'b0;
                update_tmp <= 'b0;
            end
        endcase
    end

and (mainclk, mainclk_tmp, 1'b1);
and (updateclk, updateclk_tmp, 1'b1);
and (capture, capture_tmp, 1'b1);
and (update, update_tmp, 1'b1);

endmodule // twentynm_bias_logic

// -----------------------------------------------------------
//
// Module Name : twentynm_bias_generator
//
// Description : STRATIXIII Bias Generator Verilog simulation model
//
// -----------------------------------------------------------

`timescale 1 ps/1 ps

module twentynm_bias_generator (
    din,
    mainclk,
    updateclk,
    capture,
    update,
    dout 
    );

// INPUT PORTS
input  din;
input  mainclk;
input  updateclk;
input  capture;
input  update;
    
// OUTPUTPUT PORTS
output dout;
    
parameter TOTAL_REG = 202;

// INTERNAL VARIABLES
reg dout_tmp;
reg generator_reg [TOTAL_REG - 1:0];
reg update_reg [TOTAL_REG - 1:0];
integer i;

initial
begin
    dout_tmp <= 'b0;
    for (i = 0; i < TOTAL_REG; i = i + 1)
    begin
        generator_reg [i] <= 'b0;
        update_reg [i] <= 'b0;
    end
end

// main generator registers
always @(posedge mainclk)
begin
    if ((capture == 'b0) && (update == 'b1)) //update main registers
    begin
        for (i = 0; i < TOTAL_REG; i = i + 1)
        begin
            generator_reg[i] <= update_reg[i];
        end
    end
end

// update registers
always @(posedge updateclk)
begin
    dout_tmp <= update_reg[TOTAL_REG - 1];

    if ((capture == 'b0) && (update == 'b0)) //shift update registers
    begin
        for (i = (TOTAL_REG - 1); i > 0; i = i - 1)
        begin
            update_reg[i] <= update_reg[i - 1];
        end
        update_reg[0] <= din; 
    end
    else if ((capture == 'b1) && (update == 'b0)) //load update registers
    begin
        for (i = 0; i < TOTAL_REG; i = i + 1)
        begin
            update_reg[i] <= generator_reg[i];
        end
    end

end

and (dout, dout_tmp, 1'b1);

endmodule // twentynm_bias_generator

// -----------------------------------------------------------
//
// Module Name : twentynm_bias_block
//
// Description : STRATIXIII Bias Block Verilog simulation model
//
// -----------------------------------------------------------

`timescale 1 ps/1 ps

module twentynm_bias_block(
			clk,
			shiftnld,
			captnupdt,
			din,
			dout 
			);

// INPUT PORTS
input  clk;
input  shiftnld;
input  captnupdt;
input  din;
    
// OUTPUTPUT PORTS
output dout;
    
parameter lpm_type = "twentynm_bias_block";
    
// INTERNAL VARIABLES
reg din_viol;
reg shiftnld_viol;
reg captnupdt_viol;

wire mainclk_wire;
wire updateclk_wire;
wire capture_wire;
wire update_wire;
wire dout_tmp;

specify

    $setuphold (posedge clk, din, 0, 0, din_viol) ;
    $setuphold (posedge clk, shiftnld, 0, 0, shiftnld_viol) ;
    $setuphold (posedge clk, captnupdt, 0, 0, captnupdt_viol) ;

    (posedge clk => (dout +: dout_tmp)) = 0 ;

endspecify

twentynm_bias_logic logic_block (
                             .clk(clk),
                             .shiftnld(shiftnld),
                             .captnupdt(captnupdt),
                             .mainclk(mainclk_wire),
                             .updateclk(updateclk_wire),
                             .capture(capture_wire),
                             .update(update_wire)
                             );

twentynm_bias_generator bias_generator (
                                    .din(din),
                                    .mainclk(mainclk_wire),
                                    .updateclk(updateclk_wire),
                                    .capture(capture_wire),
                                    .update(update_wire),
                                    .dout(dout_tmp) 
                                    );

and (dout, dout_tmp, 1'b1);

endmodule // twentynm_bias_block

`timescale 1 ps/1 ps

module twentynm_clk_phase_select (    
    clkin,
    phasectrlin,
    phaseinvertctrl,
    dqsin,
    clkout);

    parameter use_phasectrlin = "true";
    parameter phase_setting = 0;
    parameter invert_phase = "dynamic";
    parameter use_dqs_input = "false";
    parameter physical_clock_source = "dqs_2x_clk";

    input  [3:0] clkin;
    input  [1:0] phasectrlin;
    input  phaseinvertctrl;
    input  dqsin;
    output clkout;

    twentynm_clk_phase_select_encrypted inst (
        .clkin(clkin),
        .phasectrlin(phasectrlin),
        .phaseinvertctrl(phaseinvertctrl),
        .dqsin(dqsin),
        .clkout(clkout) );
    defparam inst.use_phasectrlin = use_phasectrlin;
    defparam inst.phase_setting = phase_setting;
    defparam inst.invert_phase = invert_phase;
    defparam inst.use_dqs_input = use_dqs_input;
    defparam inst.physical_clock_source = physical_clock_source;
    

endmodule //twentynm_clk_phase_select

`timescale 1 ps/1 ps

module twentynm_clkena    (
    inclk,
    ena,
    enaout,
    outclk);

// leda G_521_3_B off
    parameter    clock_type    =    "auto";
    parameter    ena_register_mode    =    "always enabled";
    parameter    lpm_type    =    "twentynm_clkena";
    parameter    ena_register_power_up    =    "high";
    parameter    disable_mode    =    "low";
    parameter    test_syn    =    "high";
// leda G_521_3_B on

    input    inclk;
    input    ena;
    output    enaout;
    output    outclk;

    twentynm_clkena_encrypted inst (
        .inclk(inclk),
        .ena(ena),
        .enaout(enaout),
        .outclk(outclk) );
    defparam inst.clock_type = clock_type;
    defparam inst.ena_register_mode = ena_register_mode;
    defparam inst.lpm_type = lpm_type;
    defparam inst.ena_register_power_up = ena_register_power_up;
    defparam inst.disable_mode = disable_mode;
    defparam inst.test_syn = test_syn;

endmodule //twentynm_clkena

`timescale 1 ps/1 ps

module twentynm_clkselect    (
    inclk,
    clkselect,
    outclk);

// leda G_521_3_B off
    parameter    lpm_type    =    "twentynm_clkselect";
    parameter    test_cff    =    "low";
// leda G_521_3_B on

    input    [3:0]    inclk;
    input    [1:0]    clkselect;
    output   outclk;

    twentynm_clkselect_encrypted inst (
        .inclk(inclk),
        .clkselect(clkselect),
        .outclk(outclk) );
    defparam inst.lpm_type = lpm_type;
    defparam inst.test_cff = test_cff;

endmodule //twentynm_clkselect

`timescale 1 ps/1 ps

module twentynm_delay_chain (
    datain,
    delayctrlin,
    dataout);

    parameter  sim_intrinsic_rising_delay  = 50;
    parameter  sim_intrinsic_falling_delay = 50;
    parameter  sim_rising_delay_increment  = 25;
    parameter  sim_falling_delay_increment = 25;
    parameter  lpm_type = "twentynm_delay_chain";
    parameter delay_chain_ctrl = 0;

    input [4:0] delayctrlin;
    input  datain;
    output dataout;

    twentynm_delay_chain_encrypted inst (
        .datain(datain),
	.delayctrlin(delayctrlin),
        .dataout(dataout) );
    defparam inst.sim_intrinsic_rising_delay = sim_intrinsic_rising_delay;
    defparam inst.sim_intrinsic_falling_delay = sim_intrinsic_falling_delay;
    defparam inst.sim_rising_delay_increment = sim_rising_delay_increment;
    defparam inst.sim_falling_delay_increment = sim_falling_delay_increment;
    defparam inst.lpm_type = lpm_type;
    defparam inst.delay_chain_ctrl=delay_chain_ctrl;

endmodule //twentynm_delay_chain

`timescale 1 ps/1 ps

module    twentynm_dll_offset_ctrl    (
    clk,
    offsetdelayctrlin,
    offset,
    addnsub,
    aload,
    offsetctrlout,
    offsettestout);

    parameter    use_offset    =    "false";
    parameter    static_offset    =    0;
    parameter    use_pvt_compensation    =    "false";


    input    clk;
    input    [6:0]    offsetdelayctrlin;
    input    [6:0]    offset;
    input    addnsub;
    input    aload;
    output    [6:0]    offsetctrlout;
    output    [6:0]    offsettestout;

    twentynm_dll_offset_ctrl_encrypted inst (
        .clk(clk),
        .offsetdelayctrlin(offsetdelayctrlin),
        .offset(offset),
        .addnsub(addnsub),
        .aload(aload),
        .offsetctrlout(offsetctrlout),
        .offsettestout(offsettestout) );
    defparam inst.use_offset = use_offset;
    defparam inst.static_offset = static_offset;
    defparam inst.use_pvt_compensation = use_pvt_compensation;

endmodule //twentynm_dll_offset_ctrl

`timescale 1 ps/1 ps

module twentynm_dll (
    clk,  
    upndnin, 
    upndninclkena,     
    delayctrlout, 
    dqsupdate,
    dftcore,
	aload,
	upndnout,
	locked,
    dffin
);

    parameter input_frequency    = "0 MHz";
    parameter delayctrlout_mode  = "normal";
    parameter jitter_reduction   = "false";
    parameter use_upndnin        = "false";
    parameter use_upndninclkena  = "false";
    parameter dtf_core_mode      = "clock";
    parameter sim_valid_lock     = 16;
    parameter sim_valid_lockcount        = 0;  
    parameter sim_buffer_intrinsic_delay = 175;
    parameter sim_buffer_delay_increment = 10;
    parameter static_delay_ctrl  = 0;
    parameter lpm_type           = "twentynm_dll";
    parameter delay_chain_length = 8;
	parameter upndnout_mode      = "clock";


    input        clk;
    input        upndnin;
    input        upndninclkena;
	input        aload;
    output [6:0] delayctrlout;
    output       dqsupdate;
    output       dftcore;
    output       dffin;
	output       upndnout;
	output       locked;


    twentynm_dll_encrypted inst (
        .clk(clk),
        .upndnin(upndnin),
        .upndninclkena(upndninclkena),
        .delayctrlout(delayctrlout),
        .dqsupdate(dqsupdate),
        .dftcore(dftcore),
		.aload(aload),
		.upndnout(upndnout),
		.locked(locked),
        .dffin(dffin) );
    defparam inst.input_frequency = input_frequency;
    defparam inst.delayctrlout_mode = delayctrlout_mode;
    defparam inst.jitter_reduction = jitter_reduction;
    defparam inst.use_upndnin = use_upndnin;
    defparam inst.use_upndninclkena = use_upndninclkena;
    defparam inst.dtf_core_mode = dtf_core_mode;
    defparam inst.sim_valid_lock = sim_valid_lock;
    defparam inst.sim_valid_lockcount = sim_valid_lockcount;
    defparam inst.sim_buffer_intrinsic_delay = sim_buffer_intrinsic_delay;
    defparam inst.sim_buffer_delay_increment = sim_buffer_delay_increment;
    defparam inst.static_delay_ctrl = static_delay_ctrl;
    defparam inst.lpm_type = lpm_type;
    defparam inst.delay_chain_length = delay_chain_length;
	defparam inst.upndnout_mode = upndnout_mode;

endmodule //twentynm_dll

`timescale 1 ps/1 ps

module twentynm_dqs_config (
    datain,
    clk,
    ena,
    update,
    postamblephasesetting,
    postamblephaseinvert,
    dqsbusoutdelaysetting,
    dqshalfratebypass,
    octdelaysetting,
    enadqsenablephasetransferreg,
    dqsenablegatingdelaysetting,
    dqsenableungatingdelaysetting,
    dataout);

    parameter    lpm_type    =    "twentynm_dqs_config";


    input    datain;
    input    clk;
    input    ena;
    input    update;
    output [1:0] postamblephasesetting;
    output       postamblephaseinvert;
    output [4:0] dqsbusoutdelaysetting;
    output       dqshalfratebypass;
    output [4:0] octdelaysetting;
    output       enadqsenablephasetransferreg;
    output [4:0] dqsenablegatingdelaysetting;
    output [4:0] dqsenableungatingdelaysetting;
    output       dataout;

    twentynm_dqs_config_encrypted inst (
        .datain(datain),
        .clk(clk),
        .ena(ena),
        .update(update),
        .postamblephasesetting(postamblephasesetting),
        .postamblephaseinvert(postamblephaseinvert),
        .dqsbusoutdelaysetting(dqsbusoutdelaysetting),
        .dqshalfratebypass(dqshalfratebypass),
        .octdelaysetting(octdelaysetting),
        .enadqsenablephasetransferreg(enadqsenablephasetransferreg),
        .dqsenablegatingdelaysetting(dqsenablegatingdelaysetting),
        .dqsenableungatingdelaysetting(dqsenableungatingdelaysetting),
        .dataout(dataout) );
        
    defparam inst.lpm_type = lpm_type;

endmodule //twentynm_dqs_config

`timescale 1 ps/1 ps

module twentynm_dqs_delay_chain (
    dqsin,
    dqsenable, 
    dqsdisablen, 
    delayctrlin,
    dqsupdateen,
    testin,
    dffin,
    dqsbusout);

    parameter    dqs_input_frequency = "unused";
    parameter    dqs_ctrl_latches_enable = "false";
    parameter    dqs_delay_chain_bypass = "false";
    parameter    dqs_delay_chain_test_mode = "OFF";
    parameter    dqs_network_width = "unused";
    parameter    dqs_period = "unused";
    parameter    dqs_phase_shift = "unused";
    parameter    sim_buffer_intrinsic_delay = 175;
    parameter    sim_buffer_delay_increment = 10;

    input    dqsin;
    input    dqsenable;
    input    dqsdisablen;
    input    [6:0] delayctrlin;
    input    dqsupdateen;
    input    testin;
    output   dffin;
    output   dqsbusout;

    twentynm_dqs_delay_chain_encrypted inst (
        .dqsin(dqsin),
        .dqsenable(dqsenable),
        .dqsdisablen(dqsdisablen),
        .delayctrlin(delayctrlin),
        .dqsupdateen(dqsupdateen),
        .testin(testin),
        .dffin(dffin),
        .dqsbusout(dqsbusout));
    defparam inst.dqs_input_frequency = dqs_input_frequency;
    defparam inst.dqs_ctrl_latches_enable = dqs_ctrl_latches_enable;
    defparam inst.dqs_delay_chain_bypass = dqs_delay_chain_bypass;
    defparam inst.dqs_delay_chain_test_mode = dqs_delay_chain_test_mode;
    defparam inst.dqs_network_width = dqs_network_width;
    defparam inst.dqs_period = dqs_period;
    defparam inst.dqs_phase_shift = dqs_phase_shift;
    defparam inst.sim_buffer_intrinsic_delay = sim_buffer_intrinsic_delay;
    defparam inst.sim_buffer_delay_increment = sim_buffer_delay_increment;

endmodule //twentynm_dqs_delay_chain

`timescale 1 ps/1 ps

module twentynm_dqs_enable_ctrl (
    rstn,
    dqsenablein,
    zerophaseclk,
    enaphasetransferreg,
    levelingclk,
    dqsenableout,
    dffin);

    parameter    delay_dqs_enable = "onecycle";
    parameter    add_phase_transfer_reg = "false";

    input    rstn;
    input    dqsenablein;
    input    zerophaseclk;
    input    enaphasetransferreg;
    input    levelingclk;
    output   dqsenableout;
    output   dffin;

    twentynm_dqs_enable_ctrl_encrypted inst (
        .rstn(rstn),
        .dqsenablein(dqsenablein),
        .zerophaseclk(zerophaseclk),
        .enaphasetransferreg(enaphasetransferreg),
        .levelingclk(levelingclk),
        .dqsenableout(dqsenableout),
        .dffin(dffin));
    defparam inst.delay_dqs_enable = delay_dqs_enable;
    defparam inst.add_phase_transfer_reg = add_phase_transfer_reg;

endmodule //twentynm_dqs_enable_ctrl

`timescale 1 ps/1 ps

module    twentynm_duty_cycle_adjustment    (
    clkin,
    delaymode,
    delayctrlin,
    clkout);

    parameter    duty_cycle_delay_mode    =    "none";
    parameter    lpm_type    =    "twentynm_duty_cycle_adjustment";
    parameter    dca_config_mode    =    0;

    input    clkin;
    input    [1:0]delaymode;
    input    [3:0]    delayctrlin;
    output    clkout;

    twentynm_duty_cycle_adjustment_encrypted inst (
        .clkin(clkin),
        .delaymode(delaymode),
        .delayctrlin(delayctrlin),
        .clkout(clkout) );
    defparam inst.duty_cycle_delay_mode = duty_cycle_delay_mode;
    defparam inst.dca_config_mode    =    dca_config_mode;
    defparam inst.lpm_type = lpm_type;

endmodule //twentynm_duty_cycle_adjustment


`timescale 1 ps/1 ps

module    twentynm_half_rate_input    (
    datain,
    directin,
    clk,
    areset,
    dataoutbypass,
    dataout,
    dffin);

    parameter    power_up    =    "low";
    parameter    async_mode    =    "no_reset";
    parameter    use_dataoutbypass    =    "false";


    input    [1:0]    datain;
    input    directin;
    input    clk;
    input    areset;
    input    dataoutbypass;
    output    [3:0]    dataout;
    output    [1:0]    dffin;

    twentynm_half_rate_input_encrypted inst (
        .datain(datain),
        .directin(directin),
        .clk(clk),
        .areset(areset),
        .dataoutbypass(dataoutbypass),
        .dataout(dataout),
        .dffin(dffin) );
    defparam inst.power_up = power_up;
    defparam inst.async_mode = async_mode;
    defparam inst.use_dataoutbypass = use_dataoutbypass;

endmodule //twentynm_half_rate_input

`timescale 1 ps/1 ps

module    twentynm_input_phase_alignment    (
    datain,
    levelingclk,
    zerophaseclk,
    areset,
    enainputcycledelay,
    enaphasetransferreg,
    dataout,
    dffin,
    dff1t,
    dffphasetransfer);

    parameter    power_up    =    "low";
    parameter    async_mode    =    "no_reset";
    parameter    add_input_cycle_delay    =    "false";
    parameter    bypass_output_register    =    "false";
    parameter    add_phase_transfer_reg    =    "false";
    parameter    lpm_type    =    "twentynm_input_phase_alignment";


    input    datain;
    input    levelingclk;
    input    zerophaseclk;
    input    areset;
    input    enainputcycledelay;
    input    enaphasetransferreg;
    output    dataout;
    output    dffin;
    output    dff1t;
    output    dffphasetransfer;

    twentynm_input_phase_alignment_encrypted inst (
        .datain(datain),
        .levelingclk(levelingclk),
        .zerophaseclk(zerophaseclk),
        .areset(areset),
        .enainputcycledelay(enainputcycledelay),
        .enaphasetransferreg(enaphasetransferreg),
        .dataout(dataout),
        .dffin(dffin),
        .dff1t(dff1t),
        .dffphasetransfer(dffphasetransfer) );
    defparam inst.power_up = power_up;
    defparam inst.async_mode = async_mode;
    defparam inst.add_input_cycle_delay = add_input_cycle_delay;
    defparam inst.bypass_output_register = bypass_output_register;
    defparam inst.add_phase_transfer_reg = add_phase_transfer_reg;
    defparam inst.lpm_type = lpm_type;

endmodule //twentynm_input_phase_alignment

`timescale 1 ps/1 ps

module    twentynm_io_clock_divider    (
    clk,
    phaseinvertctrl,
    masterin,
    clkout,
    slaveout);

    parameter    power_up    =    "low";
    parameter    invert_phase    =    "false";
    parameter    use_masterin    =    "false";
    parameter    lpm_type    =    "twentynm_io_clock_divider";


    input    clk;
    input    phaseinvertctrl;
    input    masterin;
    output    clkout;
    output    slaveout;

    twentynm_io_clock_divider_encrypted inst (
        .clk(clk),
        .phaseinvertctrl(phaseinvertctrl),
        .masterin(masterin),
        .clkout(clkout),
        .slaveout(slaveout) );
    defparam inst.power_up = power_up;
    defparam inst.invert_phase = invert_phase;
    defparam inst.use_masterin = use_masterin;
    defparam inst.lpm_type = lpm_type;

endmodule //twentynm_io_clock_divider

`timescale 1 ps/1 ps

module twentynm_io_config (
    datain,
    clk,
    ena,
    update,
    outputhalfratebypass,
    readfiforeadclockselect,
    readfifomode,
    outputregdelaysetting,
    outputenabledelaysetting,
    padtoinputregisterdelaysetting,
    dataout);

    parameter    lpm_type    =    "twentynm_io_config";

    input        datain;
    input        clk;
    input        ena;
    input        update;
    output       outputhalfratebypass;
    output [1:0] readfiforeadclockselect;
    output [2:0] readfifomode;
    output [4:0] outputregdelaysetting;
    output [4:0] outputenabledelaysetting;
    output [4:0] padtoinputregisterdelaysetting;
    output dataout;

    twentynm_io_config_encrypted inst (
        .datain(datain),
        .clk(clk),
        .ena(ena),
        .update(update),
        .outputhalfratebypass(outputhalfratebypass),
        .readfiforeadclockselect(readfiforeadclockselect),
        .readfifomode(readfifomode),
        .outputregdelaysetting(outputregdelaysetting),
        .outputenabledelaysetting(outputenabledelaysetting),
        .padtoinputregisterdelaysetting(padtoinputregisterdelaysetting),
        .dataout(dataout));
    defparam inst.lpm_type = lpm_type;

endmodule //twentynm_io_config

`timescale 1 ps/1 ps

module twentynm_leveling_delay_chain (
    clkin,
    delayctrlin,
    clkout);

    parameter    physical_clock_source = "dqs";
    parameter    sim_buffer_intrinsic_delay = 175;
    parameter    sim_buffer_delay_increment = 10;


    input  clkin;
    input  [6:0] delayctrlin;
    output [3:0] clkout;

    twentynm_leveling_delay_chain_encrypted inst (
        .clkin(clkin),
        .delayctrlin(delayctrlin),
        .clkout(clkout) );
    defparam inst.physical_clock_source = physical_clock_source;
    defparam inst.sim_buffer_intrinsic_delay = sim_buffer_intrinsic_delay;
    defparam inst.sim_buffer_delay_increment = sim_buffer_delay_increment;

endmodule //twentynm_leveling_delay_chain


`timescale 1 ps/1 ps

module twentynm_termination_logic (
	s2pload,
	serdata,
	scan_in,
	scan_shift_n,
	scan_out,
	seriesterminationcontrol,
	parallelterminationcontrol
);

parameter lpm_type = "twentynm_termination_logic";
parameter a_iob_oct_block = "A_IOB_OCT_BLOCK_NONE";
parameter a_iob_oct_serdata = "A_IOB_OCT_SER_DATA_CA";

input s2pload;
input serdata;
output [15 : 0] seriesterminationcontrol;
output [15 : 0] parallelterminationcontrol;
input scan_in;
input scan_shift_n;
output scan_out;

twentynm_termination_logic_encrypted inst (
	.s2pload(s2pload),
	.serdata(serdata),
	.scan_in(scan_in),
	.scan_shift_n(scan_shift_n),
	.scan_out(scan_out),
	.seriesterminationcontrol(seriesterminationcontrol),
	.parallelterminationcontrol(parallelterminationcontrol)
);
defparam inst.lpm_type = lpm_type;
defparam inst.a_iob_oct_block = a_iob_oct_block;
defparam inst.a_iob_oct_serdata = a_iob_oct_serdata;

endmodule //twentynm_termination_logic

`timescale 1 ps/1 ps

module twentynm_termination (
	rzqin,
	enserusr,
	nclrusr,
	clkenusr,
	clkusr,
	ser_data_dq_to_core,
	ser_data_ca_to_core,
	ser_data_dq_from_core,
	ser_data_ca_from_core,
	serdataout
);

parameter lpm_type = "twentynm_termination";
parameter a_oct_cal_mode = "A_OCT_CAL_MODE_SINGLE";
parameter a_oct_user_oct = "a_oct_user_oct_off";
parameter a_oct_rsmultp1 = "A_OCT_RSMULTP1_1";
parameter a_oct_rsmultp2 = "A_OCT_RSMULTP2_1";
parameter a_oct_rsmultn1 = "A_OCT_RSMULTN1_1";
parameter a_oct_rsmultn2 = "A_OCT_RSMULTN2_1";
parameter a_oct_rsadjust1 = "A_OCT_RSADJUST1_NONE";
parameter a_oct_rsadjust2 = "A_OCT_RSADJUST2_NONE";
parameter a_oct_rtmult1 = "A_OCT_RTMULT1_1";
parameter a_oct_rtmult2 = "A_OCT_RTMULT2_1";
parameter a_oct_rtadjust1 = "A_OCT_RTADJUST1_NONE";
parameter a_oct_rtadjust2 = "A_OCT_RTADJUST2_NONE";

input rzqin;
input enserusr;
input nclrusr;
input clkenusr;
input clkusr;
input ser_data_dq_from_core;
input ser_data_ca_from_core;

output serdataout;
output ser_data_dq_to_core;
output ser_data_ca_to_core;

twentynm_termination_encrypted inst (
	.rzqin(rzqin),
	.enserusr(enserusr),
	.nclrusr(nclrusr),
	.clkenusr(clkenusr),
	.clkusr(clkusr),
	.ser_data_dq_to_core(ser_data_dq_to_core),
	.ser_data_ca_to_core(ser_data_ca_to_core),
	.ser_data_dq_from_core(ser_data_dq_from_core),
	.ser_data_ca_from_core(ser_data_ca_from_core),
	.serdataout(serdataout)
);
defparam inst.lpm_type = lpm_type;
defparam inst.a_oct_cal_mode = a_oct_cal_mode;
defparam inst.a_oct_user_oct = a_oct_user_oct;
defparam inst.a_oct_rsmultp1 = a_oct_rsmultp1;
defparam inst.a_oct_rsmultp2 = a_oct_rsmultp2;
defparam inst.a_oct_rsmultn1 = a_oct_rsmultn1;
defparam inst.a_oct_rsmultn2 = a_oct_rsmultn2;
defparam inst.a_oct_rsadjust1 = a_oct_rsadjust1;
defparam inst.a_oct_rsadjust2 = a_oct_rsadjust2;
defparam inst.a_oct_rtmult1 = a_oct_rtmult1;
defparam inst.a_oct_rtmult2 = a_oct_rtmult2;
defparam inst.a_oct_rtadjust1 = a_oct_rtadjust1;
defparam inst.a_oct_rtadjust2 = a_oct_rtadjust2;

endmodule //twentynm_termination


`timescale 1 ps/1 ps

module    twentynm_asmiblock    (
    dclk,
    sce,
    oe,
    data0out,
    data1out,
    data2out,
    data3out,
    data0oe,
    data1oe,
    data2oe,
    data3oe,
    data0in,
    data1in,
    data2in,
    data3in,
	spidclk,
	spidataout,
	spisce,
	spidatain);

    parameter    lpm_type    =    "twentynm_asmiblock";
    parameter    enable_sim  =    "false";
	
    input    dclk;
    input    [2:0]    sce;
    input    oe;
    input    data0out;
    input    data1out;
    input    data2out;
    input    data3out;
    input    data0oe;
    input    data1oe;
    input    data2oe;
    input    data3oe;
    output   data0in;
    output   data1in;
    output   data2in;
    output   data3in;
	
	output 	spidclk;
	output 	[3:0] spidataout;
	output 	[2:0] spisce;
	input 	[3:0] spidatain;

    twentynm_asmiblock_encrypted inst (
        .dclk(dclk),
        .sce(sce),
        .oe(oe),
        .data0out(data0out),
        .data1out(data1out),
        .data2out(data2out),
        .data3out(data3out),
        .data0oe(data0oe),
        .data1oe(data1oe),
        .data2oe(data2oe),
        .data3oe(data3oe),
        .data0in(data0in),
        .data1in(data1in),
        .data2in(data2in),
        .data3in(data3in),
		.spidclk(spidclk),
		.spidataout(spidataout),
		.spisce(spisce),
		.spidatain(spidatain));
    defparam inst.lpm_type = lpm_type;
    defparam inst.enable_sim = enable_sim;

endmodule //twentynm_asmiblock


`timescale 1 ps/1 ps

module    twentynm_crcblock    (
    clk,
    shiftnld,
    crcerror,
    regout,
	endofedfullchip);

	parameter crc_enable 				= "false";
	parameter oscillator_divider 		= 256;
	parameter error_delay 				= 0;
	parameter disable_col_bits_updated 	= "false";
	parameter crc_deld_disable 			= "false";
	parameter col_chk_bit_update_retry 	= 0;
	parameter edcrc_start_frame 		= 0;
	parameter edcrc_stop_frame 			= 0;
	parameter n_edcrc_colums 			= 0;
	parameter lpm_type = "twentynm_crcblock";

    input   clk;
    input   shiftnld;
    output  crcerror;
    output  regout;
	output	endofedfullchip;

    twentynm_crcblock_encrypted inst (
        .clk(clk),
        .shiftnld(shiftnld),
        .crcerror(crcerror),
        .regout(regout),
		.endofedfullchip(endofedfullchip));
	defparam inst.crc_enable = crc_enable;
    defparam inst.oscillator_divider = oscillator_divider;
	defparam inst.error_delay = error_delay;
	defparam inst.disable_col_bits_updated = disable_col_bits_updated;
	defparam inst.crc_deld_disable = crc_deld_disable;
	defparam inst.col_chk_bit_update_retry = col_chk_bit_update_retry;
	defparam inst.edcrc_start_frame = edcrc_start_frame;
	defparam inst.edcrc_stop_frame = edcrc_stop_frame;
	defparam inst.n_edcrc_colums = n_edcrc_colums;
    defparam inst.lpm_type = lpm_type;

endmodule //twentynm_crcblock


`timescale 1 ps/1 ps

module    twentynm_opregblock    (
    clk,
    shiftnld,
    regout);

    parameter    lpm_type    =    "twentynm_opregblock";

    input   clk;
    input   shiftnld;
    output  regout;
	
endmodule //twentynm_opregblock


`timescale 1 ps/1 ps

module    twentynm_jtag    (
    tms,
    tck,
    tdi,
    ntrst,
    tdoutap,
    tdouser,
    tmscore,
    tckcore,
    tdicore,
    ntrstcore,
    tmscorehps,
    tckcorehps,
    tdicorehps,
    ntrstcorehps,
    tdocorefrwl,
    corectl,
    ntdopinena,

    tdo,
    tmsutap,
    tckutap,
    tdiutap,
    ntrstutap,
    tmsuhps,
    tckuhps,
    tdiuhps,
    ntrstuhps,
    tmscoreout,
    tckcoreout,
    tdocorehps,
    ntrstcoreout,
    tdocore,
    shiftuser,
    clkdruser,
    updateuser,
    runidleuser,
    usr1user
);

    parameter    lpm_type    =    "twentynm_jtag";

	input tms;
	input tck;
	input tdi;
	input ntrst;
	input tdoutap;
	input tdouser;
	input tmscore;
	input tckcore;
	input tdicore;
	input ntrstcore;
	input tmscorehps;
	input tckcorehps;
	input tdicorehps;
	input ntrstcorehps;
	input tdocorefrwl;
	input corectl;
	input ntdopinena;

	output tdo;
	output tmsutap;
	output tckutap;
	output tdiutap;
	output ntrstutap;
	output tmsuhps;
	output tckuhps;
	output tdiuhps;
	output ntrstuhps;
	output tmscoreout;
	output tckcoreout;
	output tdocorehps;
	output ntrstcoreout;
	output tdocore;
	output shiftuser;
	output clkdruser;
	output updateuser;
	output runidleuser;
	output usr1user;

    twentynm_jtag_encrypted inst (
        .tms(tms),
        .tck(tck),
        .tdi(tdi),
        .ntrst(ntrst),
        .tdoutap(tdoutap),
        .tdouser(tdouser),
        .tmscore(tmscore),
        .tckcore(tckcore),
        .tdicore(tdicore),
        .ntrstcore(ntrstcore),
        .tmscorehps(tmscorehps),
        .tckcorehps(tckcorehps),
        .tdicorehps(tdicorehps),
        .ntrstcorehps(ntrstcorehps),
        .tdocorefrwl(tdocorefrwl),
        .corectl(corectl),
        .ntdopinena(ntdopinena),
        .tdo(tdo),
        .tmsutap(tmsutap),
        .tckutap(tckutap),
        .tdiutap(tdiutap),
        .ntrstutap(ntrstutap),
        .tmsuhps(tmsuhps),
        .tckuhps(tckuhps),
        .tdiuhps(tdiuhps),
        .ntrstuhps(ntrstuhps),
        .tmscoreout(tmscoreout),
        .tckcoreout(tckcoreout),
        .tdocorehps(tdocorehps),
        .ntrstcoreout(ntrstcoreout),
        .tdocore(tdocore),
        .shiftuser(shiftuser),
        .clkdruser(clkdruser),
        .updateuser(updateuser),
        .runidleuser(runidleuser),
        .usr1user(usr1user) );
    defparam inst.lpm_type = lpm_type;

endmodule //twentynm_jtag


`timescale 1 ps/1 ps

module    twentynm_jtagblock    (
    tmscore,
    tckcore,
    tdicore,
    ntrstcore,
    tmscorehps,
    tckcorehps,
    tdicorehps,
    ntrstcorehps,
    corectl,

    tdocorehps,
    tdocore
);

    parameter    lpm_type    =    "twentynm_jtagblock";

	input tmscore;
	input tckcore;
	input tdicore;
	input ntrstcore;
	input tmscorehps;
	input tckcorehps;
	input tdicorehps;
	input ntrstcorehps;
	input corectl;
	
	output tdocorehps;
	output tdocore;

endmodule //twentynm_jtagblock



`timescale 1 ps/1 ps

module    twentynm_rublock    (
    clk,
    ctl,
    regin,
    rsttimer,
    rconfig,
    regout);

    parameter    sim_init_watchdog_value    	= 0;
    parameter    sim_init_status    			= 0;
    parameter    sim_init_config_is_application	= "false";
    parameter    sim_init_watchdog_enabled    	= "false";
    parameter    lpm_type    					= "twentynm_rublock";

    input	clk;
    input	[1:0] ctl;
    input	regin;
    input	rsttimer;
    input	rconfig;
    output	regout;

    twentynm_rublock_encrypted inst (
        .clk(clk),
        .ctl(ctl),
        .regin(regin),
        .rsttimer(rsttimer),
        .rconfig(rconfig),
        .regout(regout));
    defparam inst.sim_init_watchdog_value = sim_init_watchdog_value;
    defparam inst.sim_init_status = sim_init_status;
    defparam inst.sim_init_config_is_application = sim_init_config_is_application;
    defparam inst.sim_init_watchdog_enabled = sim_init_watchdog_enabled;
    defparam inst.lpm_type = lpm_type;

endmodule //twentynm_rublock


`timescale 1 ps/1 ps

module    twentynm_tsdblock    (
    corectl,
    reset,
	scanen,
	scanin,
    tempout,
    eoc);

    parameter    lpm_type    =    "twentynm_tsdblock";

    input	corectl;
    input	reset;
	input	scanen;
	input	scanin;
    output	[9:0] tempout;
    output	eoc;

    twentynm_tsdblock_encrypted inst (
        .corectl(corectl),
        .reset(reset),
		.scanen(scanen),
		.scanin(scanin),
        .tempout(tempout),
        .eoc(eoc) );
    defparam inst.lpm_type = lpm_type;

endmodule //twentynm_tsdblock


`timescale 1 ps/1 ps

module    twentynm_vsblock    (
    clk,
    reset,
	corectl,
	coreconfig,
	confin,
	chsel,
    dataout,
    eoc,
	eos,
	muxsel);

    parameter    lpm_type    =    "twentynm_vsblock";

    input	clk;
    input	reset;
	input	corectl;
	input	coreconfig;
	input	confin;
	input	[3:0] chsel;
    output	[11:0] dataout;
    output	eoc;
	output	eos;
	output	[3:0] muxsel;

    twentynm_vsblock_encrypted inst (
        .clk(clk),
        .reset(reset),
		.corectl(corectl),
		.coreconfig(coreconfig),
		.confin(confin),
		.chsel(chsel),
        .dataout(dataout),
		.eoc(eoc),
        .eos(eos),
		.muxsel(muxsel));
    defparam inst.lpm_type = lpm_type;

endmodule //twentynm_vsblock


`timescale 1 ps/1 ps

module twentynm_read_fifo (
                           datain,
                           wclk,
                           we,
                           rclk,
                           re,
                           areset,
                           plus2,
                           dataout
                          );

    parameter use_half_rate_read = "false";


    input [1:0] datain; 
    input wclk;
    input we;
    input rclk;
    input re;
    input areset;
    input plus2;

    output [3:0]dataout;

    twentynm_read_fifo_encrypted inst (
    	.datain(datain),
        .wclk(wclk),
        .we(we),
        .rclk(rclk),
        .re(re),
        .areset(areset),
        .plus2(plus2),
        .dataout(dataout));
    defparam inst.use_half_rate_read = use_half_rate_read;
 
endmodule //twentynm_read_fifo

`timescale 1 ps/1 ps

module twentynm_read_fifo_read_enable (
                           re,
                           rclk,
                           plus2,
                           areset,
                           reout,
                           plus2out
                          );

    parameter use_stalled_read_enable = "false";

    input re;
    input rclk;
    input plus2;
    input areset;

    output reout;
    output plus2out;

    twentynm_read_fifo_read_enable_encrypted inst (
    	.re(re),
    	.rclk(rclk),
    	.plus2(plus2),
    	.areset(areset),
    	.reout(reout),
    	.plus2out(plus2out));
    	
    defparam inst.use_stalled_read_enable = use_stalled_read_enable;
 
endmodule //twentynm_read_fifo_read_enable

module twentynm_phy_clkbuf (	
						inclk,
						outclk
						);

	input [3:0]  inclk;
	output [3:0] outclk;
	
	twentynm_phy_clkbuf_encrypted inst(	
		.inclk(inclk),
		.outclk(outclk));

endmodule //twentynm_phy_clkbuf

module twentynm_io_serdes_dpa (
  bitslipcntl,
  bitslipreset,
  pclkcorein,
  dpahold,
  dpareset,
  dpaswitch,
  fclk,
  dpafiforeset,
  loaden,
  lvdsin,
  txdata,
  pclkioin,
  fclkcorein,
  loadencorein,
  loopbackin,
  dpaclk,
  bitslipmax,
  dpalock,
  lvdsout,
  rxdata,
  pclk,
  loopbackout,
  mdio_dis,
  dprio_clk,
  dprio_rst_n,
  dprio_read,
  dprio_reg_addr,
  dprio_write,
  dprio_writedata,
  dprio_block_select,
  dprio_readdata
);

	parameter mode = "off_mode";
	parameter align_to_rising_edge_only = "false";
	parameter bitslip_rollover = "10";
	parameter data_width = "10";
	parameter lose_lock_on_one_change = "false";
	parameter reset_fifo_at_first_lock = "false";
	parameter enable_clock_pin_mode = "false";
	parameter loopback_mode = "0";
	parameter net_ppm_variation = "0";
	parameter is_negative_ppm_drift = "false";
	parameter bypass_serializer = "false";
	parameter use_falling_clock_edge = "false";
	parameter vco_div_exponent = "0";
	parameter vco_frequency = "0";
	parameter is_tx_outclock = "false";
	parameter silicon_rev = "20nm5es";

	input    [0:0] bitslipcntl;
	input    [0:0] bitslipreset;
	input    [0:0] pclkcorein;
	input    [0:0] dpahold;
	input    [0:0] dpareset;
	input    [0:0] dpaswitch;
	input    [0:0] fclk;
	input    [0:0] dpafiforeset;
	input    [0:0] loaden;
	input    [0:0] lvdsin;
	input    [9:0] txdata;
	input    [0:0] pclkioin;
	input    [0:0] fclkcorein;
	input    [0:0] loadencorein;
	input    [0:0] loopbackin;
	input    [7:0] dpaclk;
    input    [0:0] mdio_dis;
    input    [0:0] dprio_clk;
    input    [0:0] dprio_rst_n;
    input    [0:0] dprio_read;
    input    [8:0] dprio_reg_addr;
    input    [0:0] dprio_write;
    input    [7:0] dprio_writedata;
    output   [0:0] dprio_block_select;
    output   [7:0] dprio_readdata;
	output   [0:0] bitslipmax;
	output   [0:0] dpalock;
	output   [0:0] lvdsout;
	output   [9:0] rxdata;
	output   [0:0] pclk;
	output   [0:0] loopbackout;


twentynm_io_serdes_dpa_encrypted inst(
	.bitslipcntl(bitslipcntl),
	.bitslipreset(bitslipreset),
	.pclkcorein(pclkcorein),
	.dpahold(dpahold),
	.dpareset(dpareset),
	.dpaswitch(dpaswitch),
	.fclk(fclk),
	.dpafiforeset(dpafiforeset),
	.loaden(loaden),
	.lvdsin(lvdsin),
	.txdata(txdata),
	.pclkioin(pclkioin),
	.fclkcorein(fclkcorein),
	.loadencorein(loadencorein),
	.loopbackin(loopbackin),
	.dpaclk(dpaclk),
	.bitslipmax(bitslipmax),
	.dpalock(dpalock),
	.lvdsout(lvdsout),
	.rxdata(rxdata),
	.pclk(pclk),
	.loopbackout(loopbackout),
	.mdio_dis(mdio_dis),
	.dprio_clk(dprio_clk),
	.dprio_rst_n(dprio_rst_n),
    .dprio_read(dprio_read),
    .dprio_reg_addr(dprio_reg_addr),
    .dprio_write(dprio_write),
    .dprio_writedata(dprio_writedata),
    .dprio_block_select(dprio_block_select),
    .dprio_readdata(dprio_readdata)
);

	defparam inst.mode = mode;
	defparam inst.align_to_rising_edge_only = align_to_rising_edge_only;
	defparam inst.bitslip_rollover = bitslip_rollover;
	defparam inst.data_width = data_width;
	defparam inst.lose_lock_on_one_change = lose_lock_on_one_change;
	defparam inst.reset_fifo_at_first_lock = reset_fifo_at_first_lock;
	defparam inst.enable_clock_pin_mode = enable_clock_pin_mode;
	defparam inst.loopback_mode = loopback_mode;
	defparam inst.net_ppm_variation = net_ppm_variation;
	defparam inst.is_negative_ppm_drift = is_negative_ppm_drift;
	defparam inst.bypass_serializer = bypass_serializer;
	defparam inst.use_falling_clock_edge = use_falling_clock_edge;
	defparam inst.vco_div_exponent = vco_div_exponent;
	defparam inst.vco_frequency = vco_frequency;
	defparam inst.is_tx_outclock = is_tx_outclock;
	defparam inst.silicon_rev = silicon_rev;

endmodule //twentynm_io_serdes_dpa

module twentynm_lvds_clock_tree (
	input lvdsfclk_in,
	input loaden_in,
	output lvdsfclk_out,
	output loaden_out,
	output lvdsfclk_top_out,
	output loaden_top_out,
	output lvdsfclk_bot_out,
	output loaden_bot_out
); 

parameter clock_export_compatible = "true";

	twentynm_lvds_clock_tree_encrypted inst(
		.lvdsfclk_in(lvdsfclk_in),
		.loaden_in(loaden_in),
		.lvdsfclk_out(lvdsfclk_out),
		.loaden_out(loaden_out),
		.lvdsfclk_top_out(lvdsfclk_top_out),
		.loaden_top_out(loaden_top_out),
		.lvdsfclk_bot_out(lvdsfclk_bot_out),
		.loaden_bot_out(loaden_bot_out)
	); 
	defparam inst.clock_export_compatible = clock_export_compatible; 

endmodule //twentynm_lvds_clock_tree


module twentynm_ir_fifo_userdes (
      
      input           tstclk,           //test clock
      input           regscanovrd,      //regscan clken override
      input           rstn,             //async nreset - FIFO
      input           writeclk,         //Write Clock 
      input           readclk,          //Read Clock
      input   [1:0]   dinfiforx,        //FIFO DIN
      input           bslipin,          //Bit Slip Input from adjacent IOREG
      input           writeenable,      //FIFO Write Enable 
      input           readenable,       //FIFO Read Enable 
      input   [9:0]   txin,             //Tx Serializer Parallel Input
      input           loaden,           //SerDes LOADEN
      input           bslipctl,         //Bit Slip Control
      input           regscan,          //regscan enable
      input           scanin,           //regscanin    
	  input   [2:0]   dynfifomode,      //Dynamic FIFO Mode (overrides a_rb_fifo_mode when a_use_dynamic_fifo_mode is set to TRUE)
      
      output          lvdsmodeen,       //config - select ireg as LVDS or EMIF
      output          lvdstxsel,        //config - select oreg as Serializer Tx
      output          txout,            //Tx Serial Output
      output  [9:0]   rxout,            //Rx Parallel Output
      output          bslipout,         //Rx Bit Slip Output
      output  [3:0]   dout,             //FIFO Output
      output          bslipmax,         //Bit Slip Maximum
      output          scanout,          //regscanout
      output          observableout,
      output          observablefout1,
      output          observablefout2,
      output          observablefout3,
      output          observablefout4,
      output          observablewaddrcnt,
      output          observableraddrcnt
      
      );

	  parameter a_rb_fifo_mode = "serializer_mode";
	  parameter a_rb_bslipcfg = 0;
	  parameter a_use_dynamic_fifo_mode = "false";
	  parameter a_rb_bypass_serializer = "false";
      parameter a_rb_data_width = 9;
      parameter a_rb_tx_outclk = "false";
      parameter a_enable_soft_cdr = "false";
      parameter a_sim_wclk_pre_delay = 0;
      parameter a_sim_readenable_pre_delay = 0;

	twentynm_ir_fifo_userdes_encrypted inst(
		.tstclk(tstclk),
		.regscanovrd(regscanovrd),
		.rstn(rstn),
		.writeclk(writeclk),
		.readclk(readclk),
		.dinfiforx(dinfiforx),
		.bslipin(bslipin),
		.writeenable(writeenable),
		.readenable(readenable),
		.txin(txin),
		.loaden(loaden),
		.bslipctl(bslipctl),
		.regscan(regscan),
		.scanin(scanin),
		.dynfifomode(dynfifomode),
		.lvdsmodeen(lvdsmodeen),
		.lvdstxsel(lvdstxsel),
		.txout(txout),
		.rxout(rxout),
		.bslipout(bslipout),
		.dout(dout),
		.bslipmax(bslipmax),
		.scanout(scanout),
		.observableout(observableout),
		.observablefout1(observablefout1),
		.observablefout2(observablefout2),
		.observablefout3(observablefout3),
		.observablefout4(observablefout4),
		.observablewaddrcnt(observablewaddrcnt),
		.observableraddrcnt(observableraddrcnt)
	);
	defparam inst.a_rb_fifo_mode = a_rb_fifo_mode;
	defparam inst.a_rb_bslipcfg = a_rb_bslipcfg;
	defparam inst.a_use_dynamic_fifo_mode = a_use_dynamic_fifo_mode;
	defparam inst.a_rb_bypass_serializer = a_rb_bypass_serializer;
	defparam inst.a_rb_data_width = a_rb_data_width;
	defparam inst.a_rb_tx_outclk = a_rb_tx_outclk;
	defparam inst.a_enable_soft_cdr = a_enable_soft_cdr;
	defparam inst.a_sim_wclk_pre_delay = a_sim_wclk_pre_delay;
	defparam inst.a_sim_readenable_pre_delay = a_sim_readenable_pre_delay;

endmodule //twentynm_ir_fifo_userdes

module twentynm_read_fifo_read_clock_select (    
    input [2:0] clkin,
    input [1:0] clksel,
    output      clkout
    );

    twentynm_read_fifo_read_clock_select_encrypted inst (
        .clkin(clkin),
        .clksel(clksel),
        .clkout(clkout));

endmodule //twentynm_read_fifo_read_clock_select

module twentynm_lfifo (
      
      input       clk,           //clock - half-rate
      input       rstn,          //RESET_N
      input       rdataen,       //RDATA_EN from PHY AFI
      input       rdataenfull,   //RDATA_EN_FULL from PHY AFI
      input [4:0] rdlatency,     //READ Latency Value
      
      output rdatavalid,    //RDATA_VALID to PHY
      output rden,          //RDEN to Read FIFO
      output octlfifo       //latency control for OCT
    );

    parameter oct_lfifo_enable = -1;

    twentynm_lfifo_encrypted inst (
        .clk(clk),
        .rstn(rstn),
        .rdataen(rdataen),
        .rdataenfull(rdataenfull),
        .rdlatency(rdlatency),
        .rdatavalid(rdatavalid),
        .rden(rden),
        .octlfifo(octlfifo));
    defparam inst.oct_lfifo_enable = oct_lfifo_enable;

endmodule //twentynm_lfifo

module twentynm_vfifo (
      
      input         wrclk,       //clock - VFIFO Write Clock 
      input         rdclk,       //clock - VFIFO Read Clock
      input         rstn,        //async reset_n
      input         qvldin,      //QVLD/Data Valid
      input         incwrptr,    //Increase Write Address Pointer
   
      output        qvldreg       //Postamble Register Input
      );

      twentynm_vfifo_encrypted inst(
          .wrclk(wrclk),
          .rdclk(rdclk),
          .rstn(rstn),
          .qvldin(qvldin),
          .incwrptr(incwrptr),
          .qvldreg(qvldreg)
      );


endmodule //twentynm_vfifo

module twentynm_fp_mac 
  (
   ax,
   ay,
   az,
   chainin,
   chainin_overflow,
   chainin_underflow,
   chainin_inexact,
   chainin_invalid,
   accumulate,
   clk,
   ena,
   aclr,
   
   resulta,
   chainout,
   overflow,
   underflow,
   inexact,
   invalid,
   chainout_overflow,
   chainout_underflow,
   chainout_inexact,
   chainout_invalid,
   dftout
   );
   parameter operation_mode = "SP_MULT_ADD";
   parameter use_chainin = "false";
   parameter adder_subtract = "false";
   
   parameter ax_clock = "none";
   parameter ay_clock = "none";
   parameter az_clock = "none";
   parameter output_clock = "none";
   parameter accumulate_clock = "none";
   parameter accum_pipeline_clock = "none";
   parameter accum_adder_clock = "none";
   parameter ax_chainin_pl_clock = "none";
   parameter mult_pipeline_clock = "none";
   parameter adder_input_clock = "none";
   parameter lpm_type = "twentynm_fp_mac";

   input [31:0] ax;
   input [31:0] ay;
   input [31:0] az;
   input [31:0] chainin;
   input 		chainin_overflow;
   input 		chainin_underflow;
   input 		chainin_inexact;
   input 		chainin_invalid;
   input 		accumulate;
   input [2:0] 	clk;
   input [2:0] 	ena;
   input [1:0] 	aclr;

   tri0 [31:0] 	ax;
   tri0 [31:0] 	ay;
   tri0 [31:0] 	az;
   tri0 [31:0] 	chainin;
   tri0 		chainin_overflow;
   tri0 		chainin_underflow;
   tri0 		chainin_inexact;
   tri0 		chainin_invalid;
   tri0 		accumulate;
   tri0 [2:0] 	clk;
   tri1 [2:0] 	ena;
   tri0 [1:0] 	aclr;

   output [31:0] resulta;
   output [31:0] chainout;
   output overflow,
		  underflow,
		  inexact,
		  invalid,
		  chainout_overflow,
		  chainout_underflow,
		  chainout_inexact,
		  chainout_invalid,
		dftout;

   twentynm_fp_mac_encrypted inst
	 (
	  .ax(ax),
	  .ay(ay),
	  .az(az),
	  .chainin(chainin),
	  .chainin_overflow(chainin_overflow),
	  .chainin_underflow(chainin_underflow),
	  .chainin_inexact(chainin_inexact),
	  .chainin_invalid(chainin_invalid),
	  .clk(clk),
	  .ena(ena),
	  .aclr(aclr),
	  .accumulate(accumulate),
	  
	  .resulta(resulta),
	  .chainout(chainout),
	  .overflow(overflow),
	  .underflow(underflow),
	  .inexact(inexact),
	  .invalid(invalid),
	  .chainout_overflow(chainout_overflow),
	  .chainout_underflow(chainout_underflow),
	  .chainout_inexact(chainout_inexact),
	  .chainout_invalid(chainout_invalid)
	  );
   defparam inst.operation_mode = operation_mode;
   defparam inst.use_chainin = use_chainin;
   defparam inst.adder_subtract = adder_subtract;
   defparam inst.ax_clock = ax_clock;
   defparam inst.ay_clock = ay_clock;
   defparam inst.az_clock = az_clock;
   defparam inst.output_clock = output_clock;
   defparam inst.accumulate_clock = accumulate_clock;
   defparam inst.accum_pipeline_clock = accum_pipeline_clock;
   defparam inst.accum_adder_clock = accum_adder_clock;
   defparam inst.ax_chainin_pl_clock = ax_chainin_pl_clock;
   defparam inst.mult_pipeline_clock = mult_pipeline_clock;
   defparam inst.adder_input_clock = adder_input_clock;

endmodule //twentynm_fp_mac

module twentynm_mac (
	ax,
	ay,
	az,
	coefsela,
	bx,
	by,
	bz,
	coefselb,
	scanin,
	chainin,
	loadconst,
	accumulate,
	negate,
	sub,
	clk,
	ena,
	aclr,

	resulta,
	resultb,
	scanout,
	chainout,
	dftout
);
parameter ax_width = 16;
parameter ay_scan_in_width = 16;
parameter az_width = 1;
parameter bx_width = 16;
parameter by_width = 16;
parameter bz_width = 1;
parameter scan_out_width = 1;
parameter result_a_width = 33;
parameter result_b_width = 1;

parameter operation_mode = "m18x18_sumof2";
parameter mode_sub_location = 0;
parameter operand_source_max = "input";
parameter operand_source_may = "input";
parameter operand_source_mbx = "input";
parameter operand_source_mby = "input";
parameter preadder_subtract_a = "false";
parameter preadder_subtract_b = "false";
parameter signed_max = "false";
parameter signed_may = "false";
parameter signed_mbx = "false";
parameter signed_mby = "false";

parameter ay_use_scan_in = "false";
parameter by_use_scan_in = "false";
parameter delay_scan_out_ay = "false";
parameter delay_scan_out_by = "false";
parameter use_chainadder = "false";
parameter enable_double_accum = "false";
parameter [5:0] load_const_value = 6'b0;

parameter signed [26:0] coef_a_0 = 0;
parameter signed [26:0] coef_a_1 = 0;
parameter signed [26:0] coef_a_2 = 0;
parameter signed [26:0] coef_a_3 = 0;
parameter signed [26:0] coef_a_4 = 0;
parameter signed [26:0] coef_a_5 = 0;
parameter signed [26:0] coef_a_6 = 0;
parameter signed [26:0] coef_a_7 = 0;
parameter signed [17:0] coef_b_0 = 0;
parameter signed [17:0] coef_b_1 = 0;
parameter signed [17:0] coef_b_2 = 0;
parameter signed [17:0] coef_b_3 = 0;
parameter signed [17:0] coef_b_4 = 0;
parameter signed [17:0] coef_b_5 = 0;
parameter signed [17:0] coef_b_6 = 0;
parameter signed [17:0] coef_b_7 = 0;

parameter ax_clock = "none";
parameter ay_scan_in_clock = "none";
parameter az_clock = "none";
parameter bx_clock = "none";
parameter by_clock = "none";
parameter bz_clock = "none";
parameter coef_sel_a_clock = "none";
parameter coef_sel_b_clock = "none";
parameter sub_clock = "none";
parameter sub_pipeline_clock = "none";
parameter negate_clock = "none";
parameter negate_pipeline_clock = "none";
parameter accumulate_clock = "none";
parameter accum_pipeline_clock = "none";
parameter load_const_clock = "none";
parameter load_const_pipeline_clock = "none";
parameter output_clock = "none";
parameter input_pipeline_clock = "none";

parameter lpm_type = "twentynm_mac";

input	sub;
input	negate;
input	accumulate;
input	loadconst;
input	[ax_width-1 : 0]	ax;
input	[ay_scan_in_width-1 : 0]	ay;
input	[ay_scan_in_width-1 : 0]	scanin;
input	[az_width-1 : 0]	az;
input	[bx_width-1 : 0]	bx;
input	[by_width-1 : 0]	by;
input	[bz_width-1 : 0]	bz;
input	[2:0] coefsela;
input	[2:0] coefselb;
input	[2:0] clk;
input	[2:0] ena;
input	[1:0] aclr;
input	[63 : 0] chainin;

tri0	[ax_width-1 : 0]	ax;
tri0	[ay_scan_in_width-1 : 0]	ay;
tri0	[ay_scan_in_width-1 : 0]	scanin;
tri0	[az_width-1 : 0]	az;
tri0	[bx_width-1 : 0]	bx;
tri0	[by_width-1 : 0]	by;
tri0	[bz_width-1 : 0]	bz;
tri0	sub, negate, accumulate, loadconst;
tri0	[2:0] coefsela;
tri0	[2:0] coefselb;
tri0	[2:0] clk;
tri1	[2:0] ena;
tri0	[1:0] aclr;
tri0	[63 : 0] chainin;

output	[result_a_width-1 : 0] resulta;
output	[result_b_width-1 : 0] resultb;
output	[scan_out_width-1 : 0] scanout;
output	[63 : 0] chainout;
output	dftout;

twentynm_mac_encrypted inst(
		.ax(ax),
		.ay(ay),
		.az(az),
		.coefsela(coefsela),
		.bx(bx),
		.by(by),
		.bz(bz),
		.coefselb(coefselb),
		.scanin(scanin),
		.chainin(chainin),
		.loadconst(loadconst),
		.accumulate(accumulate),
		.negate(negate),
		.sub(sub),
		.clk(clk),
		.ena(ena),
		.aclr(aclr),

		.resulta(resulta),
		.resultb(resultb),
		.scanout(scanout),
		.chainout(chainout),
		.dftout(dftout));
	defparam inst.ax_width = ax_width;
	defparam inst.ay_scan_in_width = ay_scan_in_width;
	defparam inst.az_width = az_width;
	defparam inst.bx_width = bx_width;
	defparam inst.by_width = by_width;
	defparam inst.bz_width = bz_width;
	defparam inst.scan_out_width = scan_out_width;
	defparam inst.result_a_width = result_a_width;
	defparam inst.result_b_width = result_b_width;

	defparam inst.operation_mode = operation_mode;
	defparam inst.mode_sub_location = mode_sub_location;
	defparam inst.operand_source_max = operand_source_max;
	defparam inst.operand_source_may = operand_source_may;
	defparam inst.operand_source_mbx = operand_source_mbx;
	defparam inst.operand_source_mby = operand_source_mby;
	defparam inst.preadder_subtract_a = preadder_subtract_a;
	defparam inst.preadder_subtract_b = preadder_subtract_b;
	defparam inst.signed_max = signed_max;
	defparam inst.signed_may = signed_may;
	defparam inst.signed_mbx = signed_mbx;
	defparam inst.signed_mby = signed_mby;
	
	defparam inst.ay_use_scan_in = ay_use_scan_in;
	defparam inst.by_use_scan_in = by_use_scan_in;
	defparam inst.delay_scan_out_ay = delay_scan_out_ay;
	defparam inst.delay_scan_out_by = delay_scan_out_by;
	defparam inst.use_chainadder = use_chainadder;
	defparam inst.enable_double_accum = enable_double_accum;
	defparam inst.load_const_value = load_const_value;

	defparam inst.coef_a_0 = coef_a_0;
	defparam inst.coef_a_1 = coef_a_1;
	defparam inst.coef_a_2 = coef_a_2;
	defparam inst.coef_a_3 = coef_a_3;
	defparam inst.coef_a_4 = coef_a_4;
	defparam inst.coef_a_5 = coef_a_5;
	defparam inst.coef_a_6 = coef_a_6;
	defparam inst.coef_a_7 = coef_a_7;
	defparam inst.coef_b_0 = coef_b_0;
	defparam inst.coef_b_1 = coef_b_1;
	defparam inst.coef_b_2 = coef_b_2;
	defparam inst.coef_b_3 = coef_b_3;
	defparam inst.coef_b_4 = coef_b_4;
	defparam inst.coef_b_5 = coef_b_5;
	defparam inst.coef_b_6 = coef_b_6;
	defparam inst.coef_b_7 = coef_b_7;

	defparam inst.ax_clock = ax_clock;
	defparam inst.ay_scan_in_clock = ay_scan_in_clock;
	defparam inst.az_clock = az_clock;
	defparam inst.bx_clock = bx_clock;
	defparam inst.by_clock = by_clock;
	defparam inst.bz_clock = bz_clock;
	defparam inst.coef_sel_a_clock = coef_sel_a_clock;
	defparam inst.coef_sel_b_clock = coef_sel_b_clock;
	defparam inst.sub_clock = sub_clock;
	defparam inst.sub_pipeline_clock = sub_pipeline_clock;
	defparam inst.negate_clock = negate_clock;
	defparam inst.negate_pipeline_clock = negate_pipeline_clock;
	defparam inst.accumulate_clock = accumulate_clock;
	defparam inst.accum_pipeline_clock = accum_pipeline_clock;
	defparam inst.load_const_clock = load_const_clock;
	defparam inst.load_const_pipeline_clock = load_const_pipeline_clock;
	defparam inst.output_clock = output_clock;
	defparam inst.input_pipeline_clock = input_pipeline_clock;

endmodule //twentynm_mac

`timescale 1 ps/1 ps

module twentynm_mem_phy (
	aficasn,
	afimemclkdisable,
	afirasn,
	afirstn,
	afiwen,
	avlread,
	avlresetn,
	avlwrite,
	globalresetn,
	plladdrcmdclk,
	pllaficlk,
	pllavlclk,
	plllocked,
	scanen,
	softresetn,
	afiaddr,
	afiba,
	aficke,
	aficsn,
	afidm,
	afidqsburst,
	afiodt,
	afirdataen,
	afirdataenfull,
	afiwdata,
	afiwdatavalid,
	avladdress,
	avlwritedata,
	cfgaddlat,
	cfgbankaddrwidth,
	cfgcaswrlat,
	cfgcoladdrwidth,
	cfgcsaddrwidth,
	cfgdevicewidth,
	cfgdramconfig,
	cfginterfacewidth,
	cfgrowaddrwidth,
	cfgtcl,
	cfgtmrd,
	cfgtrefi,
	cfgtrfc,
	cfgtwr,
	ddiophydqdin,
	ddiophydqslogicrdatavalid,
	iointaddrdout,
	iointbadout,
	iointcasndout,
	iointckdout,
	iointckedout,
	iointckndout,
	iointcsndout,
	iointdmdout,
	iointdqdout,
	iointdqoe,
	iointdqsbdout,
	iointdqsboe,
	iointdqsdout,
	iointdqslogicdqsena,
	iointdqslogicfiforeset,
	iointdqslogicincrdataen,
	iointdqslogicincwrptr,
	iointdqslogicoct,
	iointdqslogicreadlatency,
	iointdqsoe,
	iointodtdout,
	iointrasndout,
	iointresetndout,
	iointwendout,
	aficalfail,
	aficalsuccess,
	afirdatavalid,
	avlwaitrequest,
	ctlresetn,
	iointaficalfail,
	iointaficalsuccess,
	phyresetn,
	afirdata,
	afirlat,
	afiwlat,
	avlreaddata,
	iointafirlat,
	iointafiwlat,
	iointdqdin,
	iointdqslogicrdatavalid,
	phyddioaddrdout,
	phyddiobadout,
	phyddiocasndout,
	phyddiockdout,
	phyddiockedout,
	phyddiockndout,
	phyddiocsndout,
	phyddiodmdout,
	phyddiodqdout,
	phyddiodqoe,
	phyddiodqsbdout,
	phyddiodqsboe,
	phyddiodqsdout,
	phyddiodqslogicaclrpstamble,
	phyddiodqslogicaclrfifoctrl,
	phyddiodqslogicdqsena,
	phyddiodqslogicfiforeset,
	phyddiodqslogicincrdataen,
	phyddiodqslogicincwrptr,
	phyddiodqslogicoct,
	phyddiodqslogicreadlatency,
	phyddiodqsoe,
	phyddioodtdout,
	phyddiorasndout,
	phyddioresetndout,
	phyddiowendout);

parameter hphy_ac_ddr_disable = "true";
parameter hphy_datapath_delay = "zero_cycles";
parameter hphy_reset_delay_en = "false";
parameter m_hphy_ac_rom_init_file = "ac_ROM.hex";
parameter m_hphy_inst_rom_init_file = "inst_ROM.hex";
parameter hphy_wrap_back_en = "false";
parameter hphy_atpg_en = "false";
parameter hphy_use_hphy = "true";
parameter hphy_csr_pipelineglobalenable = "true";
parameter hphy_hhp_hps = "false";

input          aficasn;
input          afimemclkdisable;
input          afirasn;
input          afirstn;
input          afiwen;
input          avlread;
input          avlresetn;
input          avlwrite;
input          globalresetn;
input          plladdrcmdclk;
input          pllaficlk;
input          pllavlclk;
input          plllocked;
input          scanen;
input          softresetn;
input [19 : 0] afiaddr;
input [2 : 0] afiba;
input [1 : 0] aficke;
input [1 : 0] aficsn;
input [9 : 0] afidm;
input [4 : 0] afidqsburst;
input [1 : 0] afiodt;
input [4 : 0] afirdataen;
input [4 : 0] afirdataenfull;
input [79 : 0] afiwdata;
input [4 : 0] afiwdatavalid;
input [15 : 0] avladdress;
input [31 : 0] avlwritedata;
input [7 : 0] cfgaddlat;
input [7 : 0] cfgbankaddrwidth;
input [7 : 0] cfgcaswrlat;
input [7 : 0] cfgcoladdrwidth;
input [7 : 0] cfgcsaddrwidth;
input [7 : 0] cfgdevicewidth;
input [23 : 0] cfgdramconfig;
input [7 : 0] cfginterfacewidth;
input [7 : 0] cfgrowaddrwidth;
input [7 : 0] cfgtcl;
input [7 : 0] cfgtmrd;
input [15 : 0] cfgtrefi;
input [7 : 0] cfgtrfc;
input [7 : 0] cfgtwr;
input [179 : 0] ddiophydqdin;
input [4 : 0] ddiophydqslogicrdatavalid;
input [63 : 0] iointaddrdout;
input [11 : 0] iointbadout;
input [3 : 0] iointcasndout;
input [3 : 0] iointckdout;
input [7 : 0] iointckedout;
input [3 : 0] iointckndout;
input [7 : 0] iointcsndout;
input [19 : 0] iointdmdout;
input [179 : 0] iointdqdout;
input [89 : 0] iointdqoe;
input [19 : 0] iointdqsbdout;
input [9 : 0] iointdqsboe;
input [19 : 0] iointdqsdout;
input [9 : 0] iointdqslogicdqsena;
input [4 : 0] iointdqslogicfiforeset;
input [9 : 0] iointdqslogicincrdataen;
input [9 : 0] iointdqslogicincwrptr;
input [9 : 0] iointdqslogicoct;
input [24 : 0] iointdqslogicreadlatency;
input [9 : 0] iointdqsoe;
input [7 : 0] iointodtdout;
input [3 : 0] iointrasndout;
input [3 : 0] iointresetndout;
input [3 : 0] iointwendout;
output          aficalfail;
output          aficalsuccess;
output          afirdatavalid;
output          avlwaitrequest;
output          ctlresetn;
output          iointaficalfail;
output          iointaficalsuccess;
output          phyresetn;
output [79 : 0] afirdata;
output [4 : 0] afirlat;
output [3 : 0] afiwlat;
output [31 : 0] avlreaddata;
output [4 : 0] iointafirlat;
output [3 : 0] iointafiwlat;
output [179 : 0] iointdqdin;
output [4 : 0] iointdqslogicrdatavalid;
output [63 : 0] phyddioaddrdout;
output [11 : 0] phyddiobadout;
output [3 : 0] phyddiocasndout;
output [3 : 0] phyddiockdout;
output [7 : 0] phyddiockedout;
output [3 : 0] phyddiockndout;
output [7 : 0] phyddiocsndout;
output [19 : 0] phyddiodmdout;
output [179 : 0] phyddiodqdout;
output [89 : 0] phyddiodqoe;
output [19 : 0] phyddiodqsbdout;
output [9 : 0] phyddiodqsboe;
output [19 : 0] phyddiodqsdout;
output [4 : 0] phyddiodqslogicaclrpstamble;
output [4 : 0] phyddiodqslogicaclrfifoctrl;
output [9 : 0] phyddiodqslogicdqsena;
output [4 : 0] phyddiodqslogicfiforeset;
output [9 : 0] phyddiodqslogicincrdataen;
output [9 : 0] phyddiodqslogicincwrptr;
output [9 : 0] phyddiodqslogicoct;
output [24 : 0] phyddiodqslogicreadlatency;
output [9 : 0] phyddiodqsoe;
output [7 : 0] phyddioodtdout;
output [3 : 0] phyddiorasndout;
output [3 : 0] phyddioresetndout;
output [3 : 0] phyddiowendout;

twentynm_mem_phy_encrypted inst(
	.aficasn(aficasn),
	.afimemclkdisable(afimemclkdisable),
	.afirasn(afirasn),
	.afirstn(afirstn),
	.afiwen(afiwen),
	.avlread(avlread),
	.avlresetn(avlresetn),
	.avlwrite(avlwrite),
	.globalresetn(globalresetn),
	.plladdrcmdclk(plladdrcmdclk),
	.pllaficlk(pllaficlk),
	.pllavlclk(pllavlclk),
	.plllocked(plllocked),
	.scanen(scanen),
	.softresetn(softresetn),
	.afiaddr(afiaddr),
	.afiba(afiba),
	.aficke(aficke),
	.aficsn(aficsn),
	.afidm(afidm),
	.afidqsburst(afidqsburst),
	.afiodt(afiodt),
	.afirdataen(afirdataen),
	.afirdataenfull(afirdataenfull),
	.afiwdata(afiwdata),
	.afiwdatavalid(afiwdatavalid),
	.avladdress(avladdress),
	.avlwritedata(avlwritedata),
	.cfgaddlat(cfgaddlat),
	.cfgbankaddrwidth(cfgbankaddrwidth),
	.cfgcaswrlat(cfgcaswrlat),
	.cfgcoladdrwidth(cfgcoladdrwidth),
	.cfgcsaddrwidth(cfgcsaddrwidth),
	.cfgdevicewidth(cfgdevicewidth),
	.cfgdramconfig(cfgdramconfig),
	.cfginterfacewidth(cfginterfacewidth),
	.cfgrowaddrwidth(cfgrowaddrwidth),
	.cfgtcl(cfgtcl),
	.cfgtmrd(cfgtmrd),
	.cfgtrefi(cfgtrefi),
	.cfgtrfc(cfgtrfc),
	.cfgtwr(cfgtwr),
	.ddiophydqdin(ddiophydqdin),
	.ddiophydqslogicrdatavalid(ddiophydqslogicrdatavalid),
	.iointaddrdout(iointaddrdout),
	.iointbadout(iointbadout),
	.iointcasndout(iointcasndout),
	.iointckdout(iointckdout),
	.iointckedout(iointckedout),
	.iointckndout(iointckndout),
	.iointcsndout(iointcsndout),
	.iointdmdout(iointdmdout),
	.iointdqdout(iointdqdout),
	.iointdqoe(iointdqoe),
	.iointdqsbdout(iointdqsbdout),
	.iointdqsboe(iointdqsboe),
	.iointdqsdout(iointdqsdout),
	.iointdqslogicdqsena(iointdqslogicdqsena),
	.iointdqslogicfiforeset(iointdqslogicfiforeset),
	.iointdqslogicincrdataen(iointdqslogicincrdataen),
	.iointdqslogicincwrptr(iointdqslogicincwrptr),
	.iointdqslogicoct(iointdqslogicoct),
	.iointdqslogicreadlatency(iointdqslogicreadlatency),
	.iointdqsoe(iointdqsoe),
	.iointodtdout(iointodtdout),
	.iointrasndout(iointrasndout),
	.iointresetndout(iointresetndout),
	.iointwendout(iointwendout),
	.aficalfail(aficalfail),
	.aficalsuccess(aficalsuccess),
	.afirdatavalid(afirdatavalid),
	.avlwaitrequest(avlwaitrequest),
	.ctlresetn(ctlresetn),
	.iointaficalfail(iointaficalfail),
	.iointaficalsuccess(iointaficalsuccess),
	.phyresetn(phyresetn),
	.afirdata(afirdata),
	.afirlat(afirlat),
	.afiwlat(afiwlat),
	.avlreaddata(avlreaddata),
	.iointafirlat(iointafirlat),
	.iointafiwlat(iointafiwlat),
	.iointdqdin(iointdqdin),
	.iointdqslogicrdatavalid(iointdqslogicrdatavalid),
	.phyddioaddrdout(phyddioaddrdout),
	.phyddiobadout(phyddiobadout),
	.phyddiocasndout(phyddiocasndout),
	.phyddiockdout(phyddiockdout),
	.phyddiockedout(phyddiockedout),
	.phyddiockndout(phyddiockndout),
	.phyddiocsndout(phyddiocsndout),
	.phyddiodmdout(phyddiodmdout),
	.phyddiodqdout(phyddiodqdout),
	.phyddiodqoe(phyddiodqoe),
	.phyddiodqsbdout(phyddiodqsbdout),
	.phyddiodqsboe(phyddiodqsboe),
	.phyddiodqsdout(phyddiodqsdout),
	.phyddiodqslogicaclrpstamble(phyddiodqslogicaclrpstamble),
	.phyddiodqslogicaclrfifoctrl(phyddiodqslogicaclrfifoctrl),
	.phyddiodqslogicdqsena(phyddiodqslogicdqsena),
	.phyddiodqslogicfiforeset(phyddiodqslogicfiforeset),
	.phyddiodqslogicincrdataen(phyddiodqslogicincrdataen),
	.phyddiodqslogicincwrptr(phyddiodqslogicincwrptr),
	.phyddiodqslogicoct(phyddiodqslogicoct),
	.phyddiodqslogicreadlatency(phyddiodqslogicreadlatency),
	.phyddiodqsoe(phyddiodqsoe),
	.phyddioodtdout(phyddioodtdout),
	.phyddiorasndout(phyddiorasndout),
	.phyddioresetndout(phyddioresetndout),
	.phyddiowendout(phyddiowendout));

defparam inst.hphy_ac_ddr_disable = hphy_ac_ddr_disable;
defparam inst.hphy_atpg_en = hphy_atpg_en;
defparam inst.hphy_csr_pipelineglobalenable = hphy_csr_pipelineglobalenable;
defparam inst.hphy_datapath_delay = hphy_datapath_delay;
defparam inst.hphy_reset_delay_en = hphy_reset_delay_en;
defparam inst.hphy_use_hphy = hphy_use_hphy;
defparam inst.hphy_wrap_back_en = hphy_wrap_back_en;
defparam inst.m_hphy_ac_rom_init_file = m_hphy_ac_rom_init_file;
defparam inst.m_hphy_inst_rom_init_file = m_hphy_inst_rom_init_file;
defparam inst.hphy_hhp_hps = hphy_hhp_hps;

endmodule //twentynm_mem_phy


`timescale 1 ps/1 ps

module    twentynm_oscillator    (
    oscena,
    clkout,
    clkout1);
    
	parameter    lpm_type    =    "twentynm_oscillator";
	
    input	oscena;
    output	clkout;
    output	clkout1;
    
    twentynm_oscillator_encrypted inst (
        .oscena(oscena),
        .clkout(clkout),
        .clkout1(clkout1));
	defparam inst.lpm_type = lpm_type;
        
endmodule //twentynm_oscillator


`timescale 1 ps/1 ps
module twentynm_iopll (
	// Input port declarations
	input [ 1:0 ] clken,
	input [ 3:0 ] cnt_sel,
	input core_refclk,
	input csr_clk,
	input csr_en,
	input csr_in,
	input [ 8:0 ] dprio_address,
	input dprio_clk,
	input dprio_rst_n,
	input dps_rst_n,
	input extswitch,
	input fbclk_in,
	input fblvds_in,
	input mdio_dis,
	input [ 2:0 ] num_phase_shifts,
	input pfden,
	input phase_en,
	input pipeline_global_en_n,
	input pll_cascade_in,
	input pma_csr_test_dis,
	input read,
	input [ 3:0 ] refclk,
	input rst_n,
	input scan_mode_n,
	input scan_shift_n,
	input up_dn,
	input user_mode,
	input write,
	input [ 7:0 ] writedata,
	input zdb_in,

	// Output port declarations
	output block_select,
	output clk0_bad,
	output clk1_bad,
	output clksel,
	output csr_out,
	output dll_output,
	output [ 1:0 ] extclk_dft,
	output [ 1:0 ] extclk_output,
	output fbclk_out,
	output fblvds_out,
	output lf_reset,
	output [ 1:0 ] loaden,
	output lock,
	output [ 1:0 ] lvds_clk,
	output [ 8:0 ] outclk,
	output phase_done,
	output pll_pd,
	output pll_cascade_out,
	output [ 7:0 ] readdata,
	output vcop_en,
	output [ 7:0 ] vcoph
); 

// Parameter declarations and default value assignments
parameter reference_clock_frequency = "";
parameter vco_frequency = "";
parameter output_clock_frequency_0 = "";
parameter output_clock_frequency_1 = "";
parameter output_clock_frequency_2 = "";
parameter output_clock_frequency_3 = "";
parameter output_clock_frequency_4 = "";
parameter output_clock_frequency_5 = "";
parameter output_clock_frequency_6 = "";
parameter output_clock_frequency_7 = "";
parameter output_clock_frequency_8 = "";
parameter duty_cycle_0 = 50;
parameter duty_cycle_1 = 50;
parameter duty_cycle_2 = 50;
parameter duty_cycle_3 = 50;
parameter duty_cycle_4 = 50;
parameter duty_cycle_5 = 50;
parameter duty_cycle_6 = 50;
parameter duty_cycle_7 = 50;
parameter duty_cycle_8 = 50;
parameter phase_shift_0 = "0 ps";
parameter phase_shift_1 = "0 ps";
parameter phase_shift_2 = "0 ps";
parameter phase_shift_3 = "0 ps";
parameter phase_shift_4 = "0 ps";
parameter phase_shift_5 = "0 ps";
parameter phase_shift_6 = "0 ps";
parameter phase_shift_7 = "0 ps";
parameter phase_shift_8 = "0 ps";
parameter compensation_mode = "normal";
parameter bw_sel = "auto";
parameter silicon_rev = "reve";
parameter speed_grade = "2";
parameter use_default_base_address = "true";
parameter user_base_address = 0;
parameter is_cascaded_pll = "false";
parameter pll_atb = "atb_selectdisable";
parameter pll_auto_clk_sw_en = "false";
parameter pll_bwctrl = "pll_bw_res_setting4";
parameter pll_c0_extclk_dllout_en = "false";
parameter pll_c0_out_en = "false";
parameter pll_c1_extclk_dllout_en = "false";
parameter pll_c1_out_en = "false";
parameter pll_c2_extclk_dllout_en = "false";
parameter pll_c2_out_en = "false";
parameter pll_c3_extclk_dllout_en = "false";
parameter pll_c3_out_en = "false";
parameter pll_c4_out_en = "false";
parameter pll_c5_out_en = "false";
parameter pll_c6_out_en = "false";
parameter pll_c7_out_en = "false";
parameter pll_c8_out_en = "false";
parameter pll_c_counter_0_bypass_en = "false";
parameter pll_c_counter_0_coarse_dly = "0 ps";
parameter pll_c_counter_0_even_duty_en = "false";
parameter pll_c_counter_0_fine_dly = "0 ps";
parameter pll_c_counter_0_high = 256;
parameter pll_c_counter_0_in_src = "c_m_cnt_in_src_test_clk";
parameter pll_c_counter_0_low = 256;
parameter pll_c_counter_0_ph_mux_prst = 0;
parameter pll_c_counter_0_prst = 1;
parameter pll_c_counter_1_bypass_en = "false";
parameter pll_c_counter_1_coarse_dly = "0 ps";
parameter pll_c_counter_1_even_duty_en = "false";
parameter pll_c_counter_1_fine_dly = "0 ps";
parameter pll_c_counter_1_high = 256;
parameter pll_c_counter_1_in_src = "c_m_cnt_in_src_test_clk";
parameter pll_c_counter_1_low = 256;
parameter pll_c_counter_1_ph_mux_prst = 0;
parameter pll_c_counter_1_prst = 1;
parameter pll_c_counter_2_bypass_en = "false";
parameter pll_c_counter_2_coarse_dly = "0 ps";
parameter pll_c_counter_2_even_duty_en = "false";
parameter pll_c_counter_2_fine_dly = "0 ps";
parameter pll_c_counter_2_high = 256;
parameter pll_c_counter_2_in_src = "c_m_cnt_in_src_test_clk";
parameter pll_c_counter_2_low = 256;
parameter pll_c_counter_2_ph_mux_prst = 0;
parameter pll_c_counter_2_prst = 1;
parameter pll_c_counter_3_bypass_en = "false";
parameter pll_c_counter_3_coarse_dly = "0 ps";
parameter pll_c_counter_3_even_duty_en = "false";
parameter pll_c_counter_3_fine_dly = "0 ps";
parameter pll_c_counter_3_high = 256;
parameter pll_c_counter_3_in_src = "c_m_cnt_in_src_test_clk";
parameter pll_c_counter_3_low = 256;
parameter pll_c_counter_3_ph_mux_prst = 0;
parameter pll_c_counter_3_prst = 1;
parameter pll_c_counter_4_bypass_en = "false";
parameter pll_c_counter_4_coarse_dly = "0 ps";
parameter pll_c_counter_4_even_duty_en = "false";
parameter pll_c_counter_4_fine_dly = "0 ps";
parameter pll_c_counter_4_high = 256;
parameter pll_c_counter_4_in_src = "c_m_cnt_in_src_test_clk";
parameter pll_c_counter_4_low = 256;
parameter pll_c_counter_4_ph_mux_prst = 0;
parameter pll_c_counter_4_prst = 1;
parameter pll_c_counter_5_bypass_en = "false";
parameter pll_c_counter_5_coarse_dly = "0 ps";
parameter pll_c_counter_5_even_duty_en = "false";
parameter pll_c_counter_5_fine_dly = "0 ps";
parameter pll_c_counter_5_high = 256;
parameter pll_c_counter_5_in_src = "c_m_cnt_in_src_test_clk";
parameter pll_c_counter_5_low = 256;
parameter pll_c_counter_5_ph_mux_prst = 0;
parameter pll_c_counter_5_prst = 1;
parameter pll_c_counter_6_bypass_en = "false";
parameter pll_c_counter_6_coarse_dly = "0 ps";
parameter pll_c_counter_6_even_duty_en = "false";
parameter pll_c_counter_6_fine_dly = "0 ps";
parameter pll_c_counter_6_high = 256;
parameter pll_c_counter_6_in_src = "c_m_cnt_in_src_test_clk";
parameter pll_c_counter_6_low = 256;
parameter pll_c_counter_6_ph_mux_prst = 0;
parameter pll_c_counter_6_prst = 1;
parameter pll_c_counter_7_bypass_en = "false";
parameter pll_c_counter_7_coarse_dly = "0 ps";
parameter pll_c_counter_7_even_duty_en = "false";
parameter pll_c_counter_7_fine_dly = "0 ps";
parameter pll_c_counter_7_high = 256;
parameter pll_c_counter_7_in_src = "c_m_cnt_in_src_test_clk";
parameter pll_c_counter_7_low = 256;
parameter pll_c_counter_7_ph_mux_prst = 0;
parameter pll_c_counter_7_prst = 1;
parameter pll_c_counter_8_bypass_en = "false";
parameter pll_c_counter_8_coarse_dly = "0 ps";
parameter pll_c_counter_8_even_duty_en = "false";
parameter pll_c_counter_8_fine_dly = "0 ps";
parameter pll_c_counter_8_high =256;
parameter pll_c_counter_8_in_src = "c_m_cnt_in_src_test_clk";
parameter pll_c_counter_8_low = 256;
parameter pll_c_counter_8_ph_mux_prst = 0;
parameter pll_c_counter_8_prst = 1;
parameter pll_clk_loss_edge = "pll_clk_loss_both_edges";
parameter pll_clk_loss_sw_en = "false";
parameter pll_clk_sw_dly = "0 ps";
parameter pll_clkin_0_src = "pll_clkin_0_src_refclkin";
parameter pll_clkin_1_src = "pll_clkin_1_src_refclkin";
parameter pll_cmp_buf_dly = "0 ps";
parameter pll_coarse_dly_0 = "0 ps";
parameter pll_coarse_dly_1 = "0 ps";
parameter pll_coarse_dly_2 = "0 ps";
parameter pll_coarse_dly_3 = "0 ps";
parameter pll_cp_compensation = "true";
parameter pll_cp_current_setting = "pll_cp_setting0";
parameter pll_ctrl_override_setting = "false";
parameter pll_dft_plniotri_override = "false";
parameter pll_dft_ppmclk = "c_cnt_out";
parameter pll_dll_src = "pll_dll_src_vss";
parameter pll_dly_0_enable = "false";
parameter pll_dly_1_enable = "false";
parameter pll_dly_2_enable = "false";
parameter pll_dly_3_enable = "false";
parameter pll_enable = "false";
parameter pll_extclk_0_cnt_src = "pll_extclk_cnt_src_vss";
parameter pll_extclk_0_enable = "false";
parameter pll_extclk_0_invert = "false";
parameter pll_extclk_1_cnt_src = "pll_extclk_cnt_src_vss";
parameter pll_extclk_1_enable = "false";
parameter pll_extclk_1_invert = "false";
parameter pll_fbclk_mux_1 = "pll_fbclk_mux_1_glb";
parameter pll_fbclk_mux_2 = "pll_fbclk_mux_2_fb_1";
parameter pll_fine_dly_0 = "0 ps";
parameter pll_fine_dly_1 = "0 ps";
parameter pll_fine_dly_2 = "0 ps";
parameter pll_fine_dly_3 = "0 ps";
parameter pll_lock_fltr_cfg = 25;
parameter pll_lock_fltr_test = "pll_lock_fltr_nrm";
parameter pll_m_counter_bypass_en = "true";
parameter pll_m_counter_coarse_dly = "0 ps";
parameter pll_m_counter_even_duty_en = "false";
parameter pll_m_counter_fine_dly = "0 ps";
parameter pll_m_counter_high = 256;
parameter pll_m_counter_in_src = "c_m_cnt_in_src_test_clk";
parameter pll_m_counter_low = 256;
parameter pll_m_counter_ph_mux_prst = 0;
parameter pll_m_counter_prst = 1;
parameter pll_manu_clk_sw_en = "false";
parameter pll_n_counter_bypass_en = "true";
parameter pll_n_counter_coarse_dly = "0 ps";
parameter pll_n_counter_fine_dly = "0 ps";
parameter pll_n_counter_high = 256;
parameter pll_n_counter_low = 256;
parameter pll_n_counter_odd_div_duty_en = "false";
parameter pll_nreset_invert = "false";
parameter pll_phyfb_mux = "m_cnt_phmux_out";
parameter pll_powerdown_mode = "true";
parameter pll_ref_buf_dly = "0 ps";
parameter pll_ripplecap_ctrl = "pll_ripplecap_setting0";
parameter pll_self_reset = "false";
parameter pll_sw_refclk_src = "pll_sw_refclk_src_clk_0";
parameter pll_tclk_mux_en = "false";
parameter pll_tclk_sel = "pll_tclk_m_src";
parameter pll_test_enable = "false";
parameter pll_testdn_enable = "false";
parameter pll_testup_enable = "false";
parameter pll_unlock_fltr_cfg = 2;
parameter pll_dft_vco_ph0_en = "false";
parameter pll_dft_vco_ph1_en = "false";
parameter pll_dft_vco_ph2_en = "false";
parameter pll_dft_vco_ph3_en = "false";
parameter pll_dft_vco_ph4_en = "false";
parameter pll_dft_vco_ph5_en = "false";
parameter pll_dft_vco_ph6_en = "false";
parameter pll_dft_vco_ph7_en = "false";
parameter pll_vccr_pd_en = "false";
parameter pll_vco_ph0_en = "false";
parameter pll_vco_ph1_en = "false";
parameter pll_vco_ph2_en = "false";
parameter pll_vco_ph3_en = "false";
parameter pll_vco_ph4_en = "false";
parameter pll_vco_ph5_en = "false";
parameter pll_vco_ph6_en = "false";
parameter pll_vco_ph7_en = "false";
parameter pll_dprio_base_addr = 0;
parameter pll_dprio_broadcast_en = "true";
parameter pll_dprio_cvp_inter_sel = "true";
parameter pll_dprio_force_inter_sel = "true";
parameter pll_dprio_power_iso_en = "true";
parameter pll_vreg_0p9v1_vreg_cal_en = "false";
parameter pll_vreg_0p9v0_vreg_cal_en = "false";
parameter pll_vreg_0p9v1_vccdreg_cal = "vccdreg_nominal";
parameter pll_vreg_0p9v0_vccdreg_cal = "vccdreg_nominal";
parameter clock_name_0 = "";
parameter clock_name_1 = "";
parameter clock_name_2 = "";
parameter clock_name_3 = "";
parameter clock_name_4 = "";
parameter clock_name_5 = "";
parameter clock_name_6 = "";
parameter clock_name_7 = "";
parameter clock_name_8 = "";
parameter clock_name_global_0 = "false";
parameter clock_name_global_1 = "false";
parameter clock_name_global_2 = "false";
parameter clock_name_global_3 = "false";
parameter clock_name_global_4 = "false";
parameter clock_name_global_5 = "false";
parameter clock_name_global_6 = "false";
parameter clock_name_global_7 = "false";
parameter clock_name_global_8 = "false";

 twentynm_iopll_encrypted inst (
	.clken(clken),
	.cnt_sel(cnt_sel),
	.core_refclk(core_refclk),
	.csr_clk(csr_clk),
	.csr_en(csr_en),
	.csr_in(csr_in),
	.dprio_address(dprio_address),
	.dprio_clk(dprio_clk),
	.dprio_rst_n(dprio_rst_n),
	.dps_rst_n(dps_rst_n),
	.extswitch(extswitch),
	.fbclk_in(fbclk_in),
	.fblvds_in(fblvds_in),
	.mdio_dis(mdio_dis),
	.num_phase_shifts(num_phase_shifts),
	.pfden(pfden),
	.phase_en(phase_en),
	.pipeline_global_en_n(pipeline_global_en_n),
	.pll_cascade_in(pll_cascade_in),
	.pma_csr_test_dis(pma_csr_test_dis),
	.read(read),
	.refclk(refclk),
	.rst_n(rst_n),
	.scan_mode_n(scan_mode_n),
	.scan_shift_n(scan_shift_n),
	.up_dn(up_dn),
	.user_mode(user_mode),
	.write(write),
	.writedata(writedata),
	.zdb_in(zdb_in),
	
	// Output port declarations
	.block_select(block_select),
	.clk0_bad(clk0_bad),
	.clk1_bad(clk1_bad),
	.clksel(clksel),
	.csr_out(csr_out),
	.dll_output(dll_output),
	.extclk_dft(extclk_dft),
	.extclk_output(extclk_output),
	.fbclk_out(fbclk_out),
	.fblvds_out(fblvds_out),
	.lf_reset(lf_reset),
	.loaden(loaden),
	.lock(lock),
	.lvds_clk(lvds_clk),
	.outclk(outclk),
	.phase_done(phase_done),
	.pll_pd(pll_pd),
	.pll_cascade_out(pll_cascade_out),
	.readdata(readdata),
	.vcop_en(vcop_en),
	.vcoph(vcoph)
    );
defparam inst.reference_clock_frequency = reference_clock_frequency;
defparam inst.vco_frequency = vco_frequency;
defparam inst.output_clock_frequency_0 = output_clock_frequency_0;
defparam inst.output_clock_frequency_1 = output_clock_frequency_1;
defparam inst.output_clock_frequency_2 = output_clock_frequency_2;
defparam inst.output_clock_frequency_3 = output_clock_frequency_3;
defparam inst.output_clock_frequency_4 = output_clock_frequency_4;
defparam inst.output_clock_frequency_5 = output_clock_frequency_5;
defparam inst.output_clock_frequency_6 = output_clock_frequency_6;
defparam inst.output_clock_frequency_7 = output_clock_frequency_7;
defparam inst.output_clock_frequency_8 = output_clock_frequency_8;
defparam inst.duty_cycle_0 = duty_cycle_0;
defparam inst.duty_cycle_1 = duty_cycle_1;
defparam inst.duty_cycle_2 = duty_cycle_2;
defparam inst.duty_cycle_3 = duty_cycle_3;
defparam inst.duty_cycle_4 = duty_cycle_4;
defparam inst.duty_cycle_5 = duty_cycle_5;
defparam inst.duty_cycle_6 = duty_cycle_6;
defparam inst.duty_cycle_7 = duty_cycle_7;
defparam inst.duty_cycle_8 = duty_cycle_8;
defparam inst.phase_shift_0 = phase_shift_0;
defparam inst.phase_shift_1 = phase_shift_1;
defparam inst.phase_shift_2 = phase_shift_2;
defparam inst.phase_shift_3 = phase_shift_3;
defparam inst.phase_shift_4 = phase_shift_4;
defparam inst.phase_shift_5 = phase_shift_5;
defparam inst.phase_shift_6 = phase_shift_6;
defparam inst.phase_shift_7 = phase_shift_7;
defparam inst.phase_shift_8 = phase_shift_8;
defparam inst.compensation_mode = compensation_mode;
defparam inst.bw_sel = bw_sel;
defparam inst.silicon_rev = silicon_rev;
defparam inst.speed_grade = speed_grade;
defparam inst.use_default_base_address = use_default_base_address;
defparam inst.user_base_address = user_base_address;
defparam inst.is_cascaded_pll = is_cascaded_pll;
defparam inst.pll_atb = pll_atb;
defparam inst.pll_auto_clk_sw_en = pll_auto_clk_sw_en;
defparam inst.pll_bwctrl = pll_bwctrl;
defparam inst.pll_c0_extclk_dllout_en = pll_c0_extclk_dllout_en;
defparam inst.pll_c0_out_en = pll_c0_out_en;
defparam inst.pll_c1_extclk_dllout_en = pll_c1_extclk_dllout_en;
defparam inst.pll_c1_out_en = pll_c1_out_en;
defparam inst.pll_c2_extclk_dllout_en = pll_c2_extclk_dllout_en;
defparam inst.pll_c2_out_en = pll_c2_out_en;
defparam inst.pll_c3_extclk_dllout_en = pll_c3_extclk_dllout_en;
defparam inst.pll_c3_out_en = pll_c3_out_en;
defparam inst.pll_c4_out_en = pll_c4_out_en;
defparam inst.pll_c5_out_en = pll_c5_out_en;
defparam inst.pll_c6_out_en = pll_c6_out_en;
defparam inst.pll_c7_out_en = pll_c7_out_en;
defparam inst.pll_c8_out_en = pll_c8_out_en;
defparam inst.pll_c_counter_0_bypass_en = pll_c_counter_0_bypass_en;
defparam inst.pll_c_counter_0_coarse_dly = pll_c_counter_0_coarse_dly;
defparam inst.pll_c_counter_0_even_duty_en = pll_c_counter_0_even_duty_en;
defparam inst.pll_c_counter_0_fine_dly = pll_c_counter_0_fine_dly;
defparam inst.pll_c_counter_0_high = pll_c_counter_0_high;
defparam inst.pll_c_counter_0_in_src = pll_c_counter_0_in_src;
defparam inst.pll_c_counter_0_low = pll_c_counter_0_low;
defparam inst.pll_c_counter_0_ph_mux_prst = pll_c_counter_0_ph_mux_prst;
defparam inst.pll_c_counter_0_prst = pll_c_counter_0_prst;
defparam inst.pll_c_counter_1_bypass_en = pll_c_counter_1_bypass_en;
defparam inst.pll_c_counter_1_coarse_dly = pll_c_counter_1_coarse_dly;
defparam inst.pll_c_counter_1_even_duty_en = pll_c_counter_1_even_duty_en;
defparam inst.pll_c_counter_1_fine_dly = pll_c_counter_1_fine_dly;
defparam inst.pll_c_counter_1_high = pll_c_counter_1_high;
defparam inst.pll_c_counter_1_in_src = pll_c_counter_1_in_src;
defparam inst.pll_c_counter_1_low = pll_c_counter_1_low;
defparam inst.pll_c_counter_1_ph_mux_prst = pll_c_counter_1_ph_mux_prst;
defparam inst.pll_c_counter_1_prst = pll_c_counter_1_prst;
defparam inst.pll_c_counter_2_bypass_en = pll_c_counter_2_bypass_en;
defparam inst.pll_c_counter_2_coarse_dly = pll_c_counter_2_coarse_dly;
defparam inst.pll_c_counter_2_even_duty_en = pll_c_counter_2_even_duty_en;
defparam inst.pll_c_counter_2_fine_dly = pll_c_counter_2_fine_dly;
defparam inst.pll_c_counter_2_high = pll_c_counter_2_high;
defparam inst.pll_c_counter_2_in_src = pll_c_counter_2_in_src;
defparam inst.pll_c_counter_2_low = pll_c_counter_2_low;
defparam inst.pll_c_counter_2_ph_mux_prst = pll_c_counter_2_ph_mux_prst;
defparam inst.pll_c_counter_2_prst = pll_c_counter_2_prst;
defparam inst.pll_c_counter_3_bypass_en = pll_c_counter_3_bypass_en;
defparam inst.pll_c_counter_3_coarse_dly = pll_c_counter_3_coarse_dly;
defparam inst.pll_c_counter_3_even_duty_en = pll_c_counter_3_even_duty_en;
defparam inst.pll_c_counter_3_fine_dly = pll_c_counter_3_fine_dly;
defparam inst.pll_c_counter_3_high = pll_c_counter_3_high;
defparam inst.pll_c_counter_3_in_src = pll_c_counter_3_in_src;
defparam inst.pll_c_counter_3_low = pll_c_counter_3_low;
defparam inst.pll_c_counter_3_ph_mux_prst = pll_c_counter_3_ph_mux_prst;
defparam inst.pll_c_counter_3_prst = pll_c_counter_3_prst;
defparam inst.pll_c_counter_4_bypass_en = pll_c_counter_4_bypass_en;
defparam inst.pll_c_counter_4_coarse_dly = pll_c_counter_4_coarse_dly;
defparam inst.pll_c_counter_4_even_duty_en = pll_c_counter_4_even_duty_en;
defparam inst.pll_c_counter_4_fine_dly = pll_c_counter_4_fine_dly;
defparam inst.pll_c_counter_4_high = pll_c_counter_4_high;
defparam inst.pll_c_counter_4_in_src = pll_c_counter_4_in_src;
defparam inst.pll_c_counter_4_low = pll_c_counter_4_low;
defparam inst.pll_c_counter_4_ph_mux_prst = pll_c_counter_4_ph_mux_prst;
defparam inst.pll_c_counter_4_prst = pll_c_counter_4_prst;
defparam inst.pll_c_counter_5_bypass_en = pll_c_counter_5_bypass_en;
defparam inst.pll_c_counter_5_coarse_dly = pll_c_counter_5_coarse_dly;
defparam inst.pll_c_counter_5_even_duty_en = pll_c_counter_5_even_duty_en;
defparam inst.pll_c_counter_5_fine_dly = pll_c_counter_5_fine_dly;
defparam inst.pll_c_counter_5_high = pll_c_counter_5_high;
defparam inst.pll_c_counter_5_in_src = pll_c_counter_5_in_src;
defparam inst.pll_c_counter_5_low = pll_c_counter_5_low;
defparam inst.pll_c_counter_5_ph_mux_prst = pll_c_counter_5_ph_mux_prst;
defparam inst.pll_c_counter_5_prst = pll_c_counter_5_prst;
defparam inst.pll_c_counter_6_bypass_en = pll_c_counter_6_bypass_en;
defparam inst.pll_c_counter_6_coarse_dly = pll_c_counter_6_coarse_dly;
defparam inst.pll_c_counter_6_even_duty_en = pll_c_counter_6_even_duty_en;
defparam inst.pll_c_counter_6_fine_dly = pll_c_counter_6_fine_dly;
defparam inst.pll_c_counter_6_high = pll_c_counter_6_high;
defparam inst.pll_c_counter_6_in_src = pll_c_counter_6_in_src;
defparam inst.pll_c_counter_6_low = pll_c_counter_6_low;
defparam inst.pll_c_counter_6_ph_mux_prst = pll_c_counter_6_ph_mux_prst;
defparam inst.pll_c_counter_6_prst = pll_c_counter_6_prst;
defparam inst.pll_c_counter_7_bypass_en = pll_c_counter_7_bypass_en;
defparam inst.pll_c_counter_7_coarse_dly = pll_c_counter_7_coarse_dly;
defparam inst.pll_c_counter_7_even_duty_en = pll_c_counter_7_even_duty_en;
defparam inst.pll_c_counter_7_fine_dly = pll_c_counter_7_fine_dly;
defparam inst.pll_c_counter_7_high = pll_c_counter_7_high;
defparam inst.pll_c_counter_7_in_src = pll_c_counter_7_in_src;
defparam inst.pll_c_counter_7_low = pll_c_counter_7_low;
defparam inst.pll_c_counter_7_ph_mux_prst = pll_c_counter_7_ph_mux_prst;
defparam inst.pll_c_counter_7_prst = pll_c_counter_7_prst;
defparam inst.pll_c_counter_8_bypass_en = pll_c_counter_8_bypass_en;
defparam inst.pll_c_counter_8_coarse_dly = pll_c_counter_8_coarse_dly;
defparam inst.pll_c_counter_8_even_duty_en = pll_c_counter_8_even_duty_en;
defparam inst.pll_c_counter_8_fine_dly = pll_c_counter_8_fine_dly;
defparam inst.pll_c_counter_8_high = pll_c_counter_8_high;
defparam inst.pll_c_counter_8_in_src = pll_c_counter_8_in_src;
defparam inst.pll_c_counter_8_low = pll_c_counter_8_low;
defparam inst.pll_c_counter_8_ph_mux_prst = pll_c_counter_8_ph_mux_prst;
defparam inst.pll_c_counter_8_prst = pll_c_counter_8_prst;
defparam inst.pll_clk_loss_edge = pll_clk_loss_edge;
defparam inst.pll_clk_loss_sw_en = pll_clk_loss_sw_en;
defparam inst.pll_clk_sw_dly = pll_clk_sw_dly;
defparam inst.pll_clkin_0_src = pll_clkin_0_src;
defparam inst.pll_clkin_1_src = pll_clkin_1_src;
defparam inst.pll_cmp_buf_dly = pll_cmp_buf_dly;
defparam inst.pll_coarse_dly_0 = pll_coarse_dly_0;
defparam inst.pll_coarse_dly_1 = pll_coarse_dly_1;
defparam inst.pll_coarse_dly_2 = pll_coarse_dly_2;
defparam inst.pll_coarse_dly_3 = pll_coarse_dly_3;
defparam inst.pll_cp_compensation = pll_cp_compensation;
defparam inst.pll_cp_current_setting = pll_cp_current_setting;
defparam inst.pll_ctrl_override_setting = pll_ctrl_override_setting;
defparam inst.pll_dft_plniotri_override = pll_dft_plniotri_override;
defparam inst.pll_dft_ppmclk = pll_dft_ppmclk;
defparam inst.pll_dll_src = pll_dll_src;
defparam inst.pll_dly_0_enable = pll_dly_0_enable;
defparam inst.pll_dly_1_enable = pll_dly_1_enable;
defparam inst.pll_dly_2_enable = pll_dly_2_enable;
defparam inst.pll_dly_3_enable = pll_dly_3_enable;
defparam inst.pll_enable = pll_enable;
defparam inst.pll_extclk_0_cnt_src = pll_extclk_0_cnt_src;
defparam inst.pll_extclk_0_enable = pll_extclk_0_enable;
defparam inst.pll_extclk_0_invert = pll_extclk_0_invert;
defparam inst.pll_extclk_1_cnt_src = pll_extclk_1_cnt_src;
defparam inst.pll_extclk_1_enable = pll_extclk_1_enable;
defparam inst.pll_extclk_1_invert = pll_extclk_1_invert;
defparam inst.pll_fbclk_mux_1 = pll_fbclk_mux_1;
defparam inst.pll_fbclk_mux_2 = pll_fbclk_mux_2;
defparam inst.pll_fine_dly_0 = pll_fine_dly_0;
defparam inst.pll_fine_dly_1 = pll_fine_dly_1;
defparam inst.pll_fine_dly_2 = pll_fine_dly_2;
defparam inst.pll_fine_dly_3 = pll_fine_dly_3;
defparam inst.pll_lock_fltr_cfg = pll_lock_fltr_cfg;
defparam inst.pll_lock_fltr_test = pll_lock_fltr_test;
defparam inst.pll_m_counter_bypass_en = pll_m_counter_bypass_en;
defparam inst.pll_m_counter_coarse_dly = pll_m_counter_coarse_dly;
defparam inst.pll_m_counter_even_duty_en = pll_m_counter_even_duty_en;
defparam inst.pll_m_counter_fine_dly = pll_m_counter_fine_dly;
defparam inst.pll_m_counter_high = pll_m_counter_high;
defparam inst.pll_m_counter_in_src = pll_m_counter_in_src;
defparam inst.pll_m_counter_low = pll_m_counter_low;
defparam inst.pll_m_counter_ph_mux_prst = pll_m_counter_ph_mux_prst;
defparam inst.pll_m_counter_prst = pll_m_counter_prst;
defparam inst.pll_manu_clk_sw_en = pll_manu_clk_sw_en;
defparam inst.pll_n_counter_bypass_en = pll_n_counter_bypass_en;
defparam inst.pll_n_counter_coarse_dly = pll_n_counter_coarse_dly;
defparam inst.pll_n_counter_fine_dly = pll_n_counter_fine_dly;
defparam inst.pll_n_counter_high = pll_n_counter_high;
defparam inst.pll_n_counter_low = pll_n_counter_low;
defparam inst.pll_n_counter_odd_div_duty_en = pll_n_counter_odd_div_duty_en;
defparam inst.pll_nreset_invert = pll_nreset_invert;
defparam inst.pll_phyfb_mux = pll_phyfb_mux;
defparam inst.pll_powerdown_mode = pll_powerdown_mode;
defparam inst.pll_ref_buf_dly = pll_ref_buf_dly;
defparam inst.pll_ripplecap_ctrl = pll_ripplecap_ctrl;
defparam inst.pll_self_reset = pll_self_reset;
defparam inst.pll_sw_refclk_src = pll_sw_refclk_src;
defparam inst.pll_tclk_mux_en = pll_tclk_mux_en;
defparam inst.pll_tclk_sel = pll_tclk_sel;
defparam inst.pll_test_enable = pll_test_enable;
defparam inst.pll_testdn_enable = pll_testdn_enable;
defparam inst.pll_testup_enable = pll_testup_enable;
defparam inst.pll_unlock_fltr_cfg = pll_unlock_fltr_cfg;
defparam inst.pll_vccr_pd_en = pll_vccr_pd_en;
defparam inst.pll_dft_vco_ph0_en = pll_dft_vco_ph0_en;
defparam inst.pll_dft_vco_ph1_en = pll_dft_vco_ph1_en;
defparam inst.pll_dft_vco_ph2_en = pll_dft_vco_ph2_en;
defparam inst.pll_dft_vco_ph3_en = pll_dft_vco_ph3_en;
defparam inst.pll_dft_vco_ph4_en = pll_dft_vco_ph4_en;
defparam inst.pll_dft_vco_ph5_en = pll_dft_vco_ph5_en;
defparam inst.pll_dft_vco_ph6_en = pll_dft_vco_ph6_en;
defparam inst.pll_dft_vco_ph7_en = pll_dft_vco_ph7_en;
defparam inst.pll_vco_ph0_en = pll_vco_ph0_en;
defparam inst.pll_vco_ph1_en = pll_vco_ph1_en;
defparam inst.pll_vco_ph2_en = pll_vco_ph2_en;
defparam inst.pll_vco_ph3_en = pll_vco_ph3_en;
defparam inst.pll_vco_ph4_en = pll_vco_ph4_en;
defparam inst.pll_vco_ph5_en = pll_vco_ph5_en;
defparam inst.pll_vco_ph6_en = pll_vco_ph6_en;
defparam inst.pll_vco_ph7_en = pll_vco_ph7_en;
defparam inst.pll_dprio_base_addr = pll_dprio_base_addr;
defparam inst.pll_dprio_broadcast_en = pll_dprio_broadcast_en;
defparam inst.pll_dprio_cvp_inter_sel = pll_dprio_cvp_inter_sel;
defparam inst.pll_dprio_force_inter_sel = pll_dprio_force_inter_sel;
defparam inst.pll_dprio_power_iso_en = pll_dprio_power_iso_en;
defparam inst.pll_vreg_0p9v1_vreg_cal_en = pll_vreg_0p9v1_vreg_cal_en;
defparam inst.pll_vreg_0p9v0_vreg_cal_en = pll_vreg_0p9v0_vreg_cal_en;
defparam inst.pll_vreg_0p9v1_vccdreg_cal = pll_vreg_0p9v1_vccdreg_cal;
defparam inst.pll_vreg_0p9v0_vccdreg_cal = pll_vreg_0p9v0_vccdreg_cal;
defparam inst.clock_name_0 = clock_name_0;
defparam inst.clock_name_1 = clock_name_1;
defparam inst.clock_name_2 = clock_name_2;
defparam inst.clock_name_3 = clock_name_3;
defparam inst.clock_name_4 = clock_name_4;
defparam inst.clock_name_5 = clock_name_5;
defparam inst.clock_name_6 = clock_name_6;
defparam inst.clock_name_7 = clock_name_7;
defparam inst.clock_name_8 = clock_name_8;
defparam inst.clock_name_global_0 = clock_name_global_0;
defparam inst.clock_name_global_1 = clock_name_global_1;
defparam inst.clock_name_global_2 = clock_name_global_2;
defparam inst.clock_name_global_3 = clock_name_global_3;
defparam inst.clock_name_global_4 = clock_name_global_4;
defparam inst.clock_name_global_5 = clock_name_global_5;
defparam inst.clock_name_global_6 = clock_name_global_6;
defparam inst.clock_name_global_7 = clock_name_global_7;
defparam inst.clock_name_global_8 = clock_name_global_8;

endmodule //twentynm_iopll


module twentynm_io_12_lane (
	//clocks and resets
	input  [1:0] phy_clk,
	input  [7:0] phy_clk_phs,
	input        reset_n,
	input        pll_locked,
	input        dll_ref_clk,
	output [5:0] ioereg_locked,

	//core interface
	input  [47:0] oe_from_core,
	input  [95:0] data_from_core,
	output [95:0] data_to_core,
	input  [15:0] mrnk_read_core,
	input  [15:0] mrnk_write_core,
	input   [3:0] rdata_en_full_core,
	output  [3:0] rdata_valid_core,

	//DBC interface
	input         core2dbc_rd_data_rdy,
	input         core2dbc_wr_data_vld0,
	input         core2dbc_wr_data_vld1,
	input  [12:0] core2dbc_wr_ecc_info,
	output        dbc2core_rd_data_vld0,
	output        dbc2core_rd_data_vld1,
	output	      dbc2core_rd_type,
	output [11:0] dbc2core_wb_pointer,
	output	      dbc2core_wr_data_rdy,

	//HMC interface
	input  [95:0] ac_hmc,
	output  [5:0] afi_rlat_core,
	output  [5:0] afi_wlat_core,
	input  [16:0] cfg_dbc,
	input  [50:0] ctl2dbc0,
	input  [50:0] ctl2dbc1,
	output [22:0] dbc2ctl,

	//Avalon interface
	input  [54:0] cal_avl_in,
	output [31:0] cal_avl_readdata_out,
	output [54:0] cal_avl_out,
	input  [31:0] cal_avl_readdata_in,

	//DQS interface
	input [1:0] dqs_in,
	input	    broadcast_in_bot,
	input	    broadcast_in_top,
	output	    broadcast_out_bot,
	output	    broadcast_out_top,

	//IO interface
	input  [11:0] data_in,
	output [11:0] data_out,
	output [11:0] data_oe,
	output [11:0] oct_enable,

	//DLL interface
	input   [2:0] core_dll,
	output [12:0] dll_core,

	//clock phase alignment daisy chain
	input	sync_clk_bot_in,
	output	sync_clk_bot_out,
	input	sync_clk_top_in,
	output	sync_clk_top_out,
	input	sync_data_bot_in,
	output	sync_data_bot_out,
	input	sync_data_top_in,
	output	sync_data_top_out,

	//DFT Outputs
	output [1:0]	dft_phy_clk,

	//Ports added for TE
	input test_clk,
	input dft_prbs_ena_n,
	output dft_prbs_done,
	output dft_prbs_pass

);

//Parameters
parameter phy_clk_phs_freq = 1000;
parameter mode_rate_in     = "in_rate_1_4";
parameter mode_rate_out    = "out_rate_full";
parameter [8-1:0] pipe_latency     = 8'd0; //8-bits
parameter [7-1:0] rd_valid_delay   = 7'd0; //7-bits
parameter [6-1:0] dqs_enable_delay = 6'd0; //6-bits
parameter phy_clk_sel      = 0;
parameter dqs_lgc_dqs_b_en         = "false";

parameter pin_0_initial_out   = "initial_out_z";
parameter pin_0_mode_ddr      = "mode_ddr";
parameter [12-1:0] pin_0_output_phase  = 12'd0; //12-bits
parameter pin_0_oct_mode      = "static_off";
parameter pin_0_data_in_mode  = "disabled";
parameter pin_1_initial_out   = "initial_out_z";
parameter pin_1_mode_ddr      = "mode_ddr";
parameter [12-1:0] pin_1_output_phase  = 12'd0; //12-bits
parameter pin_1_oct_mode      = "static_off";
parameter pin_1_data_in_mode  = "disabled";
parameter pin_2_initial_out   = "initial_out_z";
parameter pin_2_mode_ddr      = "mode_ddr";
parameter [12-1:0] pin_2_output_phase  = 12'd0; //12-bits
parameter pin_2_oct_mode      = "static_off";
parameter pin_2_data_in_mode  = "disabled";
parameter pin_3_initial_out   = "initial_out_z";
parameter pin_3_mode_ddr      = "mode_ddr";
parameter [12-1:0] pin_3_output_phase  = 12'd0; //12-bits
parameter pin_3_oct_mode      = "static_off";
parameter pin_3_data_in_mode  = "disabled";
parameter pin_4_initial_out   = "initial_out_z";
parameter pin_4_mode_ddr      = "mode_ddr";
parameter [12-1:0] pin_4_output_phase  = 12'd0; //12-bits
parameter pin_4_oct_mode      = "static_off";
parameter pin_4_data_in_mode  = "disabled";
parameter pin_5_initial_out   = "initial_out_z";
parameter pin_5_mode_ddr      = "mode_ddr";
parameter [12-1:0] pin_5_output_phase  = 12'd0; //12-bits
parameter pin_5_oct_mode      = "static_off";
parameter pin_5_data_in_mode  = "disabled";
parameter pin_6_initial_out   = "initial_out_z";
parameter pin_6_mode_ddr      = "mode_ddr";
parameter [12-1:0] pin_6_output_phase  = 12'd0; //12-bits
parameter pin_6_oct_mode      = "static_off";
parameter pin_6_data_in_mode  = "disabled";
parameter pin_7_initial_out   = "initial_out_z";
parameter pin_7_mode_ddr      = "mode_ddr";
parameter [12-1:0] pin_7_output_phase  = 12'd0; //12-bits
parameter pin_7_oct_mode      = "static_off";
parameter pin_7_data_in_mode  = "disabled";
parameter pin_8_initial_out   = "initial_out_z";
parameter pin_8_mode_ddr      = "mode_ddr";
parameter [12-1:0] pin_8_output_phase  = 12'd0; //12-bits
parameter pin_8_oct_mode      = "static_off";
parameter pin_8_data_in_mode  = "disabled";
parameter pin_9_initial_out   = "initial_out_z";
parameter pin_9_mode_ddr      = "mode_ddr";
parameter [12-1:0] pin_9_output_phase  = 12'd0; //12-bits
parameter pin_9_oct_mode      = "static_off";
parameter pin_9_data_in_mode  = "disabled";
parameter pin_10_initial_out   = "initial_out_z";
parameter pin_10_mode_ddr      = "mode_ddr";
parameter [12-1:0] pin_10_output_phase  = 12'd0; //12-bits
parameter pin_10_oct_mode      = "static_off";
parameter pin_10_data_in_mode  = "disabled";
parameter pin_11_initial_out   = "initial_out_z";
parameter pin_11_mode_ddr      = "mode_ddr";
parameter [12-1:0] pin_11_output_phase  = 12'd0; //12-bits
parameter pin_11_oct_mode      = "static_off";
parameter pin_11_data_in_mode  = "disabled";

parameter [9-1:0] avl_base_addr = 9'h1FF; //9-bits
parameter avl_ena       = "false";

parameter db_hmc_or_core                = "core";
parameter db_dbi_sel                    = 0;
parameter db_dbi_wr_en                  = "false";
parameter db_dbi_rd_en                  = "false";
parameter db_crc_dq0                    = 0;
parameter db_crc_dq1                    = 0;
parameter db_crc_dq2                    = 0;
parameter db_crc_dq3                    = 0;
parameter db_crc_dq4                    = 0;
parameter db_crc_dq5                    = 0;
parameter db_crc_dq6                    = 0;
parameter db_crc_dq7                    = 0;
parameter db_crc_dq8                    = 0;
parameter db_crc_x4_or_x8_or_x9         = "x8_mode";
parameter db_crc_en                     = "crc_disable";
parameter db_rwlat_mode                 = "csr_vlu";
parameter db_afi_wlat_vlu               = 0; //6-bits
parameter db_afi_rlat_vlu               = 0; //6-bits
parameter db_ptr_pipeline_depth         = 0;
parameter db_preamble_mode              = "preamble_one_cycle";
parameter db_reset_auto_release         = "auto_release";
parameter db_data_alignment_mode        = "align_disable";
parameter db_db2core_registered         = "false";
parameter db_core_or_hmc2db_registered  = "false";
parameter dbc_core_clk_sel              = 0;
parameter db_seq_rd_en_full_pipeline    = 0;
parameter [6:0] dbc_wb_reserved_entry   = 7'h04;

parameter db_pin_0_ac_hmc_data_override_ena = "false";
parameter db_pin_0_in_bypass                = "true";
parameter db_pin_0_mode                     = "dq_mode";
parameter db_pin_0_oe_bypass                = "true";
parameter db_pin_0_oe_invert                = "false";
parameter db_pin_0_out_bypass               = "true";
parameter db_pin_0_wr_invert                = "false";
parameter db_pin_1_ac_hmc_data_override_ena = "false";
parameter db_pin_1_in_bypass                = "true";
parameter db_pin_1_mode                     = "dq_mode";
parameter db_pin_1_oe_bypass                = "true";
parameter db_pin_1_oe_invert                = "false";
parameter db_pin_1_out_bypass               = "true";
parameter db_pin_1_wr_invert                = "false";
parameter db_pin_2_ac_hmc_data_override_ena = "false";
parameter db_pin_2_in_bypass                = "true";
parameter db_pin_2_mode                     = "dq_mode";
parameter db_pin_2_oe_bypass                = "true";
parameter db_pin_2_oe_invert                = "false";
parameter db_pin_2_out_bypass               = "true";
parameter db_pin_2_wr_invert                = "false";
parameter db_pin_3_ac_hmc_data_override_ena = "false";
parameter db_pin_3_in_bypass                = "true";
parameter db_pin_3_mode                     = "dq_mode";
parameter db_pin_3_oe_bypass                = "true";
parameter db_pin_3_oe_invert                = "false";
parameter db_pin_3_out_bypass               = "true";
parameter db_pin_3_wr_invert                = "false";
parameter db_pin_4_ac_hmc_data_override_ena = "false";
parameter db_pin_4_in_bypass                = "true";
parameter db_pin_4_mode                     = "dq_mode";
parameter db_pin_4_oe_bypass                = "true";
parameter db_pin_4_oe_invert                = "false";
parameter db_pin_4_out_bypass               = "true";
parameter db_pin_4_wr_invert                = "false";
parameter db_pin_5_ac_hmc_data_override_ena = "false";
parameter db_pin_5_in_bypass                = "true";
parameter db_pin_5_mode                     = "dq_mode";
parameter db_pin_5_oe_bypass                = "true";
parameter db_pin_5_oe_invert                = "false";
parameter db_pin_5_out_bypass               = "true";
parameter db_pin_5_wr_invert                = "false";
parameter db_pin_6_ac_hmc_data_override_ena = "false";
parameter db_pin_6_in_bypass                = "true";
parameter db_pin_6_mode                     = "dq_mode";
parameter db_pin_6_oe_bypass                = "true";
parameter db_pin_6_oe_invert                = "false";
parameter db_pin_6_out_bypass               = "true";
parameter db_pin_6_wr_invert                = "false";
parameter db_pin_7_ac_hmc_data_override_ena = "false";
parameter db_pin_7_in_bypass                = "true";
parameter db_pin_7_mode                     = "dq_mode";
parameter db_pin_7_oe_bypass                = "true";
parameter db_pin_7_oe_invert                = "false";
parameter db_pin_7_out_bypass               = "true";
parameter db_pin_7_wr_invert                = "false";
parameter db_pin_8_ac_hmc_data_override_ena = "false";
parameter db_pin_8_in_bypass                = "true";
parameter db_pin_8_mode                     = "dq_mode";
parameter db_pin_8_oe_bypass                = "true";
parameter db_pin_8_oe_invert                = "false";
parameter db_pin_8_out_bypass               = "true";
parameter db_pin_8_wr_invert                = "false";
parameter db_pin_9_ac_hmc_data_override_ena = "false";
parameter db_pin_9_in_bypass                = "true";
parameter db_pin_9_mode                     = "dq_mode";
parameter db_pin_9_oe_bypass                = "true";
parameter db_pin_9_oe_invert                = "false";
parameter db_pin_9_out_bypass               = "true";
parameter db_pin_9_wr_invert                = "false";
parameter db_pin_10_ac_hmc_data_override_ena = "false";
parameter db_pin_10_in_bypass                = "true";
parameter db_pin_10_mode                     = "dq_mode";
parameter db_pin_10_oe_bypass                = "true";
parameter db_pin_10_oe_invert                = "false";
parameter db_pin_10_out_bypass               = "true";
parameter db_pin_10_wr_invert                = "false";
parameter db_pin_11_ac_hmc_data_override_ena = "false";
parameter db_pin_11_in_bypass                = "true";
parameter db_pin_11_mode                     = "dq_mode";
parameter db_pin_11_oe_bypass                = "true";
parameter db_pin_11_oe_invert                = "false";
parameter db_pin_11_out_bypass               = "true";
parameter db_pin_11_wr_invert                = "false";

parameter dll_rst_en      = "dll_rst_dis";
parameter dll_en          = "dll_dis";
parameter dll_core_updnen = "core_updn_dis";
parameter dll_ctlsel      = "ctl_dynamic";
parameter [10-1:0] dll_ctl_static = 10'd0; //10-bits

parameter dqs_lgc_swap_dqs_a_b      = "false";
parameter dqs_lgc_dqs_a_interp_en   = "false";
parameter dqs_lgc_dqs_b_interp_en   = "false";
parameter [10-1:0] dqs_lgc_pvt_input_delay_a = 10'd0; //10-bits
parameter [10-1:0] dqs_lgc_pvt_input_delay_b = 10'd0; //10-bits
parameter dqs_lgc_enable_toggler    = "preamble_track_dqs_enable";
parameter [12-1:0] dqs_lgc_phase_shift_b     = 12'd0; //12-bits
parameter [12-1:0] dqs_lgc_phase_shift_a     = 12'd0; //12-bits
parameter dqs_lgc_pack_mode         = "packed";
parameter dqs_lgc_pst_preamble_mode = "ddr3_preamble";
parameter dqs_lgc_pst_en_shrink     = "shrink_1_0";
parameter dqs_lgc_broadcast_enable  = "disable_broadcast";
parameter dqs_lgc_burst_length      = "burst_length_2";
parameter dqs_lgc_ddr4_search       = "ddr3_search";
parameter [7-1:0] dqs_lgc_count_threshold   = 7'd0; //7-bits
parameter oct_size = 1;

parameter hps_ctrl_en = "false";
parameter silicon_rev = "20nm5es";
parameter pingpong_primary = "false";
parameter pingpong_secondary = "false";

parameter pin_0_dqs_x4_mode  = (db_crc_x4_or_x8_or_x9 == "x4_mode") ? "dqs_x4_a" : "dqs_x4_not_used";
parameter pin_1_dqs_x4_mode  = (db_crc_x4_or_x8_or_x9 == "x4_mode") ? "dqs_x4_a" : "dqs_x4_not_used";
parameter pin_2_dqs_x4_mode  = (db_crc_x4_or_x8_or_x9 == "x4_mode") ? "dqs_x4_a" : "dqs_x4_not_used";
parameter pin_3_dqs_x4_mode  = (db_crc_x4_or_x8_or_x9 == "x4_mode") ? "dqs_x4_a" : "dqs_x4_not_used";
parameter pin_4_dqs_x4_mode  = (db_crc_x4_or_x8_or_x9 == "x4_mode") ? "dqs_x4_a" : "dqs_x4_not_used";
parameter pin_5_dqs_x4_mode  = (db_crc_x4_or_x8_or_x9 == "x4_mode") ? "dqs_x4_a" : "dqs_x4_not_used";
parameter pin_6_dqs_x4_mode  = (db_crc_x4_or_x8_or_x9 == "x4_mode") ? "dqs_x4_b" : "dqs_x4_not_used";
parameter pin_7_dqs_x4_mode  = (db_crc_x4_or_x8_or_x9 == "x4_mode") ? "dqs_x4_b" : "dqs_x4_not_used";
parameter pin_8_dqs_x4_mode  = (db_crc_x4_or_x8_or_x9 == "x4_mode") ? "dqs_x4_a" : "dqs_x4_not_used";
parameter pin_9_dqs_x4_mode  = (db_crc_x4_or_x8_or_x9 == "x4_mode") ? "dqs_x4_a" : "dqs_x4_not_used";
parameter pin_10_dqs_x4_mode = (db_crc_x4_or_x8_or_x9 == "x4_mode") ? "dqs_x4_b" : "dqs_x4_not_used";
parameter pin_11_dqs_x4_mode = (db_crc_x4_or_x8_or_x9 == "x4_mode") ? "dqs_x4_b" : "dqs_x4_not_used";

parameter pin_0_gpio_or_ddr = "ddr";
parameter pin_1_gpio_or_ddr = "ddr";
parameter pin_2_gpio_or_ddr = "ddr";
parameter pin_3_gpio_or_ddr = "ddr";
parameter pin_4_gpio_or_ddr = "ddr";
parameter pin_5_gpio_or_ddr = "ddr";
parameter pin_6_gpio_or_ddr = "ddr";
parameter pin_7_gpio_or_ddr = "ddr";
parameter pin_8_gpio_or_ddr = "ddr";
parameter pin_9_gpio_or_ddr = "ddr";
parameter pin_10_gpio_or_ddr = "ddr";
parameter pin_11_gpio_or_ddr = "ddr";

parameter fast_interpolator_sim = 0;

//DQS Capture Debug
wire debug_dqs_gated_a;
wire debug_dqs_enable_a;
wire debug_dqs_gated_b;
wire debug_dqs_enable_b;
wire [11:0] debug_dq_delayed;

twentynm_io_12_lane_encrypted inst (
	//clocks and resets
	.phy_clk       (phy_clk       ),
	.phy_clk_phs   (phy_clk_phs   ),
	.reset_n       (reset_n       ),
	.pll_locked    (pll_locked    ),
	.dll_ref_clk   (dll_ref_clk   ),
	.ioereg_locked (ioereg_locked ),

	//core interface
	.oe_from_core       (oe_from_core       ),
	.data_from_core     (data_from_core     ),
	.data_to_core       (data_to_core       ),
	.mrnk_read_core     (mrnk_read_core     ),
	.mrnk_write_core    (mrnk_write_core    ),
	.rdata_en_full_core (rdata_en_full_core ),
	.rdata_valid_core   (rdata_valid_core   ),

	//DBC interface
	.core2dbc_rd_data_rdy  (core2dbc_rd_data_rdy  ),
	.core2dbc_wr_data_vld0 (core2dbc_wr_data_vld0 ),
	.core2dbc_wr_data_vld1 (core2dbc_wr_data_vld1 ),
	.core2dbc_wr_ecc_info  (core2dbc_wr_ecc_info  ),
	.dbc2core_rd_data_vld0 (dbc2core_rd_data_vld0 ),
	.dbc2core_rd_data_vld1 (dbc2core_rd_data_vld1 ),
	.dbc2core_rd_type      (dbc2core_rd_type      ),
	.dbc2core_wb_pointer   (dbc2core_wb_pointer   ),
	.dbc2core_wr_data_rdy  (dbc2core_wr_data_rdy  ),

	//HMC interface
	.ac_hmc        (ac_hmc        ),
	.afi_rlat_core (afi_rlat_core ),
	.afi_wlat_core (afi_wlat_core ),
	.cfg_dbc       (cfg_dbc       ),
	.ctl2dbc0      (ctl2dbc0      ),
	.ctl2dbc1      (ctl2dbc1      ),
	.dbc2ctl       (dbc2ctl       ),

	//Avalon interface
	.cal_avl_in           (cal_avl_in           ),
	.cal_avl_readdata_out (cal_avl_readdata_out ),
	.cal_avl_out          (cal_avl_out          ),
	.cal_avl_readdata_in  (cal_avl_readdata_in  ),

	//DQS interface
	.dqs_in            (dqs_in            ),
	.broadcast_in_bot  (broadcast_in_bot  ),
	.broadcast_in_top  (broadcast_in_top  ),
	.broadcast_out_bot (broadcast_out_bot ),
	.broadcast_out_top (broadcast_out_top ),

	//IO interface
	.data_in    (data_in    ),
	.data_out   (data_out   ),
	.data_oe    (data_oe    ),
	.oct_enable (oct_enable ),

	//DLL interface
	.core_dll (core_dll ),
	.dll_core (dll_core ),

	//clock phase alignment daisy chain
	.sync_clk_bot_in   (sync_clk_bot_in  ),
	.sync_clk_bot_out  (sync_clk_bot_out ),
	.sync_clk_top_in   (sync_clk_top_in  ),
	.sync_clk_top_out  (sync_clk_top_out ),
	.sync_data_bot_in  (sync_data_bot_in ),
	.sync_data_bot_out (sync_data_bot_out),
	.sync_data_top_in  (sync_data_top_in ),
	.sync_data_top_out (sync_data_top_out),

	//DQS capture debug ports
	.debug_dqs_gated_a  (debug_dqs_gated_a  ),
	.debug_dqs_enable_a (debug_dqs_enable_a ),
	.debug_dqs_gated_b  (debug_dqs_gated_b  ),
	.debug_dqs_enable_b (debug_dqs_enable_b ),
	.debug_dq_delayed   (debug_dq_delayed   ),

	//DFT Outputs
	.dft_phy_clk (dft_phy_clk),
	
	//Ports added for TE
	.test_clk(test_clk),
	.dft_prbs_ena_n(dft_prbs_ena_n),
	.dft_prbs_done(dft_prbs_done),
	.dft_prbs_pass(dft_prbs_pass)
);

//Parameters
defparam inst.phy_clk_phs_freq                       = phy_clk_phs_freq                     ;
defparam inst.mode_rate_in                           = mode_rate_in                         ;
defparam inst.mode_rate_out                          = mode_rate_out                        ;
defparam inst.pipe_latency                           = pipe_latency                         ; //8-bits
defparam inst.rd_valid_delay                         = rd_valid_delay                       ; //7-bits
defparam inst.dqs_enable_delay                       = dqs_enable_delay                     ; //6-bits
defparam inst.phy_clk_sel                            = phy_clk_sel                          ;
defparam inst.dqs_lgc_dqs_b_en                       = dqs_lgc_dqs_b_en                     ;
defparam inst.pin_0_initial_out                      = pin_0_initial_out                    ;
defparam inst.pin_0_mode_ddr                         = pin_0_mode_ddr                       ;
defparam inst.pin_0_output_phase                     = pin_0_output_phase                   ; //12-bits
defparam inst.pin_0_oct_mode                         = pin_0_oct_mode                       ;
defparam inst.pin_0_data_in_mode                     = pin_0_data_in_mode                   ;
defparam inst.pin_1_initial_out                      = pin_1_initial_out                    ;
defparam inst.pin_1_mode_ddr                         = pin_1_mode_ddr                       ;
defparam inst.pin_1_output_phase                     = pin_1_output_phase                   ; //12-bits
defparam inst.pin_1_oct_mode                         = pin_1_oct_mode                       ;
defparam inst.pin_1_data_in_mode                     = pin_1_data_in_mode                   ;
defparam inst.pin_2_initial_out                      = pin_2_initial_out                    ;
defparam inst.pin_2_mode_ddr                         = pin_2_mode_ddr                       ;
defparam inst.pin_2_output_phase                     = pin_2_output_phase                   ; //12-bits
defparam inst.pin_2_oct_mode                         = pin_2_oct_mode                       ;
defparam inst.pin_2_data_in_mode                     = pin_2_data_in_mode                   ;
defparam inst.pin_3_initial_out                      = pin_3_initial_out                    ;
defparam inst.pin_3_mode_ddr                         = pin_3_mode_ddr                       ;
defparam inst.pin_3_output_phase                     = pin_3_output_phase                   ; //12-bits
defparam inst.pin_3_oct_mode                         = pin_3_oct_mode                       ;
defparam inst.pin_3_data_in_mode                     = pin_3_data_in_mode                   ;
defparam inst.pin_4_initial_out                      = pin_4_initial_out                    ;
defparam inst.pin_4_mode_ddr                         = pin_4_mode_ddr                       ;
defparam inst.pin_4_output_phase                     = pin_4_output_phase                   ; //12-bits
defparam inst.pin_4_oct_mode                         = pin_4_oct_mode                       ;
defparam inst.pin_4_data_in_mode                     = pin_4_data_in_mode                   ;
defparam inst.pin_5_initial_out                      = pin_5_initial_out                    ;
defparam inst.pin_5_mode_ddr                         = pin_5_mode_ddr                       ;
defparam inst.pin_5_output_phase                     = pin_5_output_phase                   ; //12-bits
defparam inst.pin_5_oct_mode                         = pin_5_oct_mode                       ;
defparam inst.pin_5_data_in_mode                     = pin_5_data_in_mode                   ;
defparam inst.pin_6_initial_out                      = pin_6_initial_out                    ;
defparam inst.pin_6_mode_ddr                         = pin_6_mode_ddr                       ;
defparam inst.pin_6_output_phase                     = pin_6_output_phase                   ; //12-bits
defparam inst.pin_6_oct_mode                         = pin_6_oct_mode                       ;
defparam inst.pin_6_data_in_mode                     = pin_6_data_in_mode                   ;
defparam inst.pin_7_initial_out                      = pin_7_initial_out                    ;
defparam inst.pin_7_mode_ddr                         = pin_7_mode_ddr                       ;
defparam inst.pin_7_output_phase                     = pin_7_output_phase                   ; //12-bits
defparam inst.pin_7_oct_mode                         = pin_7_oct_mode                       ;
defparam inst.pin_7_data_in_mode                     = pin_7_data_in_mode                   ;
defparam inst.pin_8_initial_out                      = pin_8_initial_out                    ;
defparam inst.pin_8_mode_ddr                         = pin_8_mode_ddr                       ;
defparam inst.pin_8_output_phase                     = pin_8_output_phase                   ; //12-bits
defparam inst.pin_8_oct_mode                         = pin_8_oct_mode                       ;
defparam inst.pin_8_data_in_mode                     = pin_8_data_in_mode                   ;
defparam inst.pin_9_initial_out                      = pin_9_initial_out                    ;
defparam inst.pin_9_mode_ddr                         = pin_9_mode_ddr                       ;
defparam inst.pin_9_output_phase                     = pin_9_output_phase                   ; //12-bits
defparam inst.pin_9_oct_mode                         = pin_9_oct_mode                       ;
defparam inst.pin_9_data_in_mode                     = pin_9_data_in_mode                   ;
defparam inst.pin_10_initial_out                     = pin_10_initial_out                   ;
defparam inst.pin_10_mode_ddr                        = pin_10_mode_ddr                      ;
defparam inst.pin_10_output_phase                    = pin_10_output_phase                  ; //12-bits
defparam inst.pin_10_oct_mode                        = pin_10_oct_mode                      ;
defparam inst.pin_10_data_in_mode                    = pin_10_data_in_mode                  ;
defparam inst.pin_11_initial_out                     = pin_11_initial_out                   ;
defparam inst.pin_11_mode_ddr                        = pin_11_mode_ddr                      ;
defparam inst.pin_11_output_phase                    = pin_11_output_phase                  ; //12-bits
defparam inst.pin_11_oct_mode                        = pin_11_oct_mode                      ;
defparam inst.pin_11_data_in_mode                    = pin_11_data_in_mode                  ;
defparam inst.avl_base_addr                          = avl_base_addr                        ; //9-bits
defparam inst.avl_ena                                = avl_ena                              ;
defparam inst.db_hmc_or_core                         = db_hmc_or_core                       ;
defparam inst.db_dbi_sel                             = db_dbi_sel                           ;
defparam inst.db_dbi_wr_en                           = db_dbi_wr_en                         ;
defparam inst.db_dbi_rd_en                           = db_dbi_rd_en                         ;
defparam inst.db_crc_dq0                             = db_crc_dq0                           ;
defparam inst.db_crc_dq1                             = db_crc_dq1                           ;
defparam inst.db_crc_dq2                             = db_crc_dq2                           ;
defparam inst.db_crc_dq3                             = db_crc_dq3                           ;
defparam inst.db_crc_dq4                             = db_crc_dq4                           ;
defparam inst.db_crc_dq5                             = db_crc_dq5                           ;
defparam inst.db_crc_dq6                             = db_crc_dq6                           ;
defparam inst.db_crc_dq7                             = db_crc_dq7                           ;
defparam inst.db_crc_dq8                             = db_crc_dq8                           ;
defparam inst.db_crc_x4_or_x8_or_x9                  = db_crc_x4_or_x8_or_x9                ;
defparam inst.db_crc_en                              = db_crc_en                            ;
defparam inst.db_rwlat_mode                          = db_rwlat_mode                        ;
defparam inst.db_afi_wlat_vlu                        = db_afi_wlat_vlu                      ; //6-bits
defparam inst.db_afi_rlat_vlu                        = db_afi_rlat_vlu                      ; //6-bits
defparam inst.db_ptr_pipeline_depth                  = db_ptr_pipeline_depth                ;
defparam inst.db_preamble_mode                       = db_preamble_mode                     ;
defparam inst.db_reset_auto_release                  = db_reset_auto_release                ;
defparam inst.db_data_alignment_mode                 = db_data_alignment_mode               ;
defparam inst.db_db2core_registered                  = db_db2core_registered                ;
defparam inst.db_core_or_hmc2db_registered           = db_core_or_hmc2db_registered         ;
defparam inst.dbc_core_clk_sel                       = dbc_core_clk_sel                     ;
defparam inst.db_seq_rd_en_full_pipeline             = db_seq_rd_en_full_pipeline           ;
defparam inst.dbc_wb_reserved_entry                  = dbc_wb_reserved_entry                ;
defparam inst.db_pin_0_ac_hmc_data_override_ena      = db_pin_0_ac_hmc_data_override_ena    ;
defparam inst.db_pin_0_in_bypass                     = db_pin_0_in_bypass                   ;
defparam inst.db_pin_0_mode                          = db_pin_0_mode                        ;
defparam inst.db_pin_0_oe_bypass                     = db_pin_0_oe_bypass                   ;
defparam inst.db_pin_0_oe_invert                     = db_pin_0_oe_invert                   ;
defparam inst.db_pin_0_out_bypass                    = db_pin_0_out_bypass                  ;
defparam inst.db_pin_0_wr_invert                     = db_pin_0_wr_invert                   ;
defparam inst.db_pin_1_ac_hmc_data_override_ena      = db_pin_1_ac_hmc_data_override_ena    ;
defparam inst.db_pin_1_in_bypass                     = db_pin_1_in_bypass                   ;
defparam inst.db_pin_1_mode                          = db_pin_1_mode                        ;
defparam inst.db_pin_1_oe_bypass                     = db_pin_1_oe_bypass                   ;
defparam inst.db_pin_1_oe_invert                     = db_pin_1_oe_invert                   ;
defparam inst.db_pin_1_out_bypass                    = db_pin_1_out_bypass                  ;
defparam inst.db_pin_1_wr_invert                     = db_pin_1_wr_invert                   ;
defparam inst.db_pin_2_ac_hmc_data_override_ena      = db_pin_2_ac_hmc_data_override_ena    ;
defparam inst.db_pin_2_in_bypass                     = db_pin_2_in_bypass                   ;
defparam inst.db_pin_2_mode                          = db_pin_2_mode                        ;
defparam inst.db_pin_2_oe_bypass                     = db_pin_2_oe_bypass                   ;
defparam inst.db_pin_2_oe_invert                     = db_pin_2_oe_invert                   ;
defparam inst.db_pin_2_out_bypass                    = db_pin_2_out_bypass                  ;
defparam inst.db_pin_2_wr_invert                     = db_pin_2_wr_invert                   ;
defparam inst.db_pin_3_ac_hmc_data_override_ena      = db_pin_3_ac_hmc_data_override_ena    ;
defparam inst.db_pin_3_in_bypass                     = db_pin_3_in_bypass                   ;
defparam inst.db_pin_3_mode                          = db_pin_3_mode                        ;
defparam inst.db_pin_3_oe_bypass                     = db_pin_3_oe_bypass                   ;
defparam inst.db_pin_3_oe_invert                     = db_pin_3_oe_invert                   ;
defparam inst.db_pin_3_out_bypass                    = db_pin_3_out_bypass                  ;
defparam inst.db_pin_3_wr_invert                     = db_pin_3_wr_invert                   ;
defparam inst.db_pin_4_ac_hmc_data_override_ena      = db_pin_4_ac_hmc_data_override_ena    ;
defparam inst.db_pin_4_in_bypass                     = db_pin_4_in_bypass                   ;
defparam inst.db_pin_4_mode                          = db_pin_4_mode                        ;
defparam inst.db_pin_4_oe_bypass                     = db_pin_4_oe_bypass                   ;
defparam inst.db_pin_4_oe_invert                     = db_pin_4_oe_invert                   ;
defparam inst.db_pin_4_out_bypass                    = db_pin_4_out_bypass                  ;
defparam inst.db_pin_4_wr_invert                     = db_pin_4_wr_invert                   ;
defparam inst.db_pin_5_ac_hmc_data_override_ena      = db_pin_5_ac_hmc_data_override_ena    ;
defparam inst.db_pin_5_in_bypass                     = db_pin_5_in_bypass                   ;
defparam inst.db_pin_5_mode                          = db_pin_5_mode                        ;
defparam inst.db_pin_5_oe_bypass                     = db_pin_5_oe_bypass                   ;
defparam inst.db_pin_5_oe_invert                     = db_pin_5_oe_invert                   ;
defparam inst.db_pin_5_out_bypass                    = db_pin_5_out_bypass                  ;
defparam inst.db_pin_5_wr_invert                     = db_pin_5_wr_invert                   ;
defparam inst.db_pin_6_ac_hmc_data_override_ena      = db_pin_6_ac_hmc_data_override_ena    ;
defparam inst.db_pin_6_in_bypass                     = db_pin_6_in_bypass                   ;
defparam inst.db_pin_6_mode                          = db_pin_6_mode                        ;
defparam inst.db_pin_6_oe_bypass                     = db_pin_6_oe_bypass                   ;
defparam inst.db_pin_6_oe_invert                     = db_pin_6_oe_invert                   ;
defparam inst.db_pin_6_out_bypass                    = db_pin_6_out_bypass                  ;
defparam inst.db_pin_6_wr_invert                     = db_pin_6_wr_invert                   ;
defparam inst.db_pin_7_ac_hmc_data_override_ena      = db_pin_7_ac_hmc_data_override_ena    ;
defparam inst.db_pin_7_in_bypass                     = db_pin_7_in_bypass                   ;
defparam inst.db_pin_7_mode                          = db_pin_7_mode                        ;
defparam inst.db_pin_7_oe_bypass                     = db_pin_7_oe_bypass                   ;
defparam inst.db_pin_7_oe_invert                     = db_pin_7_oe_invert                   ;
defparam inst.db_pin_7_out_bypass                    = db_pin_7_out_bypass                  ;
defparam inst.db_pin_7_wr_invert                     = db_pin_7_wr_invert                   ;
defparam inst.db_pin_8_ac_hmc_data_override_ena      = db_pin_8_ac_hmc_data_override_ena    ;
defparam inst.db_pin_8_in_bypass                     = db_pin_8_in_bypass                   ;
defparam inst.db_pin_8_mode                          = db_pin_8_mode                        ;
defparam inst.db_pin_8_oe_bypass                     = db_pin_8_oe_bypass                   ;
defparam inst.db_pin_8_oe_invert                     = db_pin_8_oe_invert                   ;
defparam inst.db_pin_8_out_bypass                    = db_pin_8_out_bypass                  ;
defparam inst.db_pin_8_wr_invert                     = db_pin_8_wr_invert                   ;
defparam inst.db_pin_9_ac_hmc_data_override_ena      = db_pin_9_ac_hmc_data_override_ena    ;
defparam inst.db_pin_9_in_bypass                     = db_pin_9_in_bypass                   ;
defparam inst.db_pin_9_mode                          = db_pin_9_mode                        ;
defparam inst.db_pin_9_oe_bypass                     = db_pin_9_oe_bypass                   ;
defparam inst.db_pin_9_oe_invert                     = db_pin_9_oe_invert                   ;
defparam inst.db_pin_9_out_bypass                    = db_pin_9_out_bypass                  ;
defparam inst.db_pin_9_wr_invert                     = db_pin_9_wr_invert                   ;
defparam inst.db_pin_10_ac_hmc_data_override_ena     = db_pin_10_ac_hmc_data_override_ena   ;
defparam inst.db_pin_10_in_bypass                    = db_pin_10_in_bypass                  ;
defparam inst.db_pin_10_mode                         = db_pin_10_mode                       ;
defparam inst.db_pin_10_oe_bypass                    = db_pin_10_oe_bypass                  ;
defparam inst.db_pin_10_oe_invert                    = db_pin_10_oe_invert                  ;
defparam inst.db_pin_10_out_bypass                   = db_pin_10_out_bypass                 ;
defparam inst.db_pin_10_wr_invert                    = db_pin_10_wr_invert                  ;
defparam inst.db_pin_11_ac_hmc_data_override_ena     = db_pin_11_ac_hmc_data_override_ena   ;
defparam inst.db_pin_11_in_bypass                    = db_pin_11_in_bypass                  ;
defparam inst.db_pin_11_mode                         = db_pin_11_mode                       ;
defparam inst.db_pin_11_oe_bypass                    = db_pin_11_oe_bypass                  ;
defparam inst.db_pin_11_oe_invert                    = db_pin_11_oe_invert                  ;
defparam inst.db_pin_11_out_bypass                   = db_pin_11_out_bypass                 ;
defparam inst.db_pin_11_wr_invert                    = db_pin_11_wr_invert                  ;
defparam inst.dll_rst_en                             = dll_rst_en                           ;
defparam inst.dll_en                                 = dll_en                               ;
defparam inst.dll_core_updnen                        = dll_core_updnen                      ;
defparam inst.dll_ctlsel                             = dll_ctlsel                           ;
defparam inst.dll_ctl_static                         = dll_ctl_static                       ; //10-bits
defparam inst.dqs_lgc_swap_dqs_a_b                   = dqs_lgc_swap_dqs_a_b                 ;
defparam inst.dqs_lgc_dqs_a_interp_en                = dqs_lgc_dqs_a_interp_en              ;
defparam inst.dqs_lgc_dqs_b_interp_en                = dqs_lgc_dqs_b_interp_en              ;
defparam inst.dqs_lgc_pvt_input_delay_a              = dqs_lgc_pvt_input_delay_a            ; //10-bits
defparam inst.dqs_lgc_pvt_input_delay_b              = dqs_lgc_pvt_input_delay_b            ; //10-bits
defparam inst.dqs_lgc_enable_toggler                 = dqs_lgc_enable_toggler               ;
defparam inst.dqs_lgc_phase_shift_b                  = dqs_lgc_phase_shift_b                ; //12-bits
defparam inst.dqs_lgc_phase_shift_a                  = dqs_lgc_phase_shift_a                ; //12-bits
defparam inst.dqs_lgc_pack_mode                      = dqs_lgc_pack_mode                    ;
defparam inst.dqs_lgc_pst_preamble_mode              = dqs_lgc_pst_preamble_mode            ;
defparam inst.dqs_lgc_pst_en_shrink                  = dqs_lgc_pst_en_shrink                ;
defparam inst.dqs_lgc_broadcast_enable               = dqs_lgc_broadcast_enable             ;
defparam inst.dqs_lgc_burst_length                   = dqs_lgc_burst_length                 ;
defparam inst.dqs_lgc_ddr4_search                    = dqs_lgc_ddr4_search                  ;
defparam inst.dqs_lgc_count_threshold                = dqs_lgc_count_threshold              ; //7-bits
defparam inst.oct_size                               = oct_size                             ;
defparam inst.hps_ctrl_en                            = hps_ctrl_en                          ;
defparam inst.silicon_rev                            = silicon_rev                          ;
defparam inst.pingpong_primary                       = pingpong_primary                     ;
defparam inst.pingpong_secondary                     = pingpong_secondary                   ;
defparam inst.pin_0_dqs_x4_mode = pin_0_dqs_x4_mode;
defparam inst.pin_1_dqs_x4_mode = pin_1_dqs_x4_mode;
defparam inst.pin_2_dqs_x4_mode = pin_2_dqs_x4_mode;
defparam inst.pin_3_dqs_x4_mode = pin_3_dqs_x4_mode;
defparam inst.pin_4_dqs_x4_mode = pin_4_dqs_x4_mode;
defparam inst.pin_5_dqs_x4_mode = pin_5_dqs_x4_mode;
defparam inst.pin_6_dqs_x4_mode = pin_6_dqs_x4_mode;
defparam inst.pin_7_dqs_x4_mode = pin_7_dqs_x4_mode;
defparam inst.pin_8_dqs_x4_mode = pin_8_dqs_x4_mode;
defparam inst.pin_9_dqs_x4_mode = pin_9_dqs_x4_mode;
defparam inst.pin_10_dqs_x4_mode = pin_10_dqs_x4_mode;
defparam inst.pin_11_dqs_x4_mode = pin_11_dqs_x4_mode;
defparam inst.pin_0_gpio_or_ddr = pin_0_gpio_or_ddr;
defparam inst.pin_1_gpio_or_ddr = pin_1_gpio_or_ddr;
defparam inst.pin_2_gpio_or_ddr = pin_2_gpio_or_ddr;
defparam inst.pin_3_gpio_or_ddr = pin_3_gpio_or_ddr;
defparam inst.pin_4_gpio_or_ddr = pin_4_gpio_or_ddr;
defparam inst.pin_5_gpio_or_ddr = pin_5_gpio_or_ddr;
defparam inst.pin_6_gpio_or_ddr = pin_6_gpio_or_ddr;
defparam inst.pin_7_gpio_or_ddr = pin_7_gpio_or_ddr;
defparam inst.pin_8_gpio_or_ddr = pin_8_gpio_or_ddr;
defparam inst.pin_9_gpio_or_ddr = pin_9_gpio_or_ddr;
defparam inst.pin_10_gpio_or_ddr = pin_10_gpio_or_ddr;
defparam inst.pin_11_gpio_or_ddr = pin_11_gpio_or_ddr;
defparam inst.fast_interpolator_sim                  = fast_interpolator_sim                ;

endmodule //twentynm_io_12_lane


`timescale 1 ps/1 ps
module	twentynm_tile_ctrl (
	input	[11:0]	pa_core_in,
	input	[1:0]	pa_core_clk_in,
	input		pa_fbclk_in,
	input		pa_sync_data_bot_in,
	input		pa_sync_data_top_in,
	input		pa_sync_clk_bot_in,
	input		pa_sync_clk_top_in,
	input		pa_reset_n,
	input	[7:0]	pll_vco_in,
	input	[1:0]	phy_clk_in,
	input		dll_clk_in,
	input 	[0:0]	dqs_in_x4_a_0,
	input 	[0:0]	dqs_in_x4_a_1,
	input 	[0:0]	dqs_in_x4_a_2,
	input 	[0:0]	dqs_in_x4_a_3,
	input 	[0:0]	dqs_in_x4_b_0,
	input 	[0:0]	dqs_in_x4_b_1,
	input 	[0:0]	dqs_in_x4_b_2,
	input 	[0:0]	dqs_in_x4_b_3,
	input	[1:0]	dqs_in_x8_0,
	input	[1:0]	dqs_in_x8_1,
	input	[1:0]	dqs_in_x8_2,
	input	[1:0]	dqs_in_x8_3,
	input	[1:0]	dqs_in_x18_0,
	input	[1:0]	dqs_in_x18_1,
	input	[1:0]	dqs_in_x36,
	input	[50:0]	ctl2dbc_in_up,
	input	[50:0]	ctl2dbc_in_down,
	input	[22:0]	dbc2ctl0,
	input	[22:0]	dbc2ctl1,
	input	[22:0]	dbc2ctl2,
	input	[22:0]	dbc2ctl3,
	input		dbc2core_wr_data_rdy0,
	input		dbc2core_wr_data_rdy1,
	input		dbc2core_wr_data_rdy2,
	input		dbc2core_wr_data_rdy3,
	input	[47:0]	ping_pong_in,
	input	[59:0]	core2ctl_avl0,
	input	[59:0]	core2ctl_avl1,
	input		core2ctl_avl_rd_data_ready,
	input	[41:0]	core2ctl_sideband,
	input	[50:0]	mmr_in,
	input	[54:0]	cal_avl_in,
	input	[31:0]	cal_avl_rdata_in,
	input	[16:0]	afi_core2ctl,
	input	[15:0]	afi_lane0_to_ctl,
	input	[15:0]	afi_lane1_to_ctl,
	input	[15:0]	afi_lane2_to_ctl,
	input	[15:0]	afi_lane3_to_ctl,
	input		pll_locked_in,
	input		global_reset_n,
	input	[3:0]	rdata_en_full_core,
	input	[15:0]	mrnk_read_core,
	output	[1:0]	pa_core_clk_out,
	output	[1:0]	pa_locked,
	output		pa_sync_data_bot_out,
	output		pa_sync_data_top_out,
	output		pa_sync_clk_top_out,
	output		pa_sync_clk_bot_out,
	output		dll_clk_out0,
	output		dll_clk_out1,
	output		dll_clk_out2,
	output		dll_clk_out3,
	output	[9:0]	phy_clk_out0,
	output	[9:0]	phy_clk_out1,
	output	[9:0]	phy_clk_out2,
	output	[9:0]	phy_clk_out3,
	output	[0:0]	dqs_out_x4_a_lane0,
	output	[0:0]	dqs_out_x4_b_lane0,
	output	[0:0]	dqs_out_x4_a_lane1,
	output	[0:0]	dqs_out_x4_b_lane1,
	output	[0:0]	dqs_out_x4_a_lane2,
	output	[0:0]	dqs_out_x4_b_lane2,
	output	[0:0]	dqs_out_x4_a_lane3,
	output	[0:0]	dqs_out_x4_b_lane3,
	output	[1:0]	dqs_out_x8_lane0,
	output	[1:0]	dqs_out_x18_lane0,
	output	[1:0]	dqs_out_x36_lane0,
	output	[1:0]	dqs_out_x8_lane1,
	output	[1:0]	dqs_out_x18_lane1,
	output	[1:0]	dqs_out_x36_lane1,
	output	[1:0]	dqs_out_x8_lane2,
	output	[1:0]	dqs_out_x18_lane2,
	output	[1:0]	dqs_out_x36_lane2,
	output	[1:0]	dqs_out_x8_lane3,
	output	[1:0]	dqs_out_x18_lane3,
	output	[1:0]	dqs_out_x36_lane3,
	output	[50:0]	ctl2dbc0,
	output	[50:0]	ctl2dbc1,
	output	[16:0]	cfg_dbc0,
	output	[16:0]	cfg_dbc1,
	output	[16:0]	cfg_dbc2,
	output	[16:0]	cfg_dbc3,
	output	[47:0]	ping_pong_out,
	output	[12:0]	ctl2core_avl_rdata_id,
	output		ctl2core_avl_cmd_ready,
	output	[13:0]	ctl2core_sideband,
	output	[33:0]	mmr_out,
	output	[54:0]	cal_avl_out,
	output	[31:0]	cal_avl_rdata_out,
	output	[25:0]	afi_ctl2core,
	output	[383:0]	afi_cmd_bus,
	output		seq2core_reset_n,
	output	[1:0]	ctl_mem_clk_disable,
	output		phy_fbclk_out,
	input	[47:0]	test_dbg_in,
	output	[47:0]	test_dbg_out,
	input		pa_dprio_clk,
	input		pa_dprio_read,
	input	[8:0]	pa_dprio_reg_addr,
	input		pa_dprio_rst_n,
	input		pa_dprio_write,
	input	[7:0]	pa_dprio_writedata,
	output		pa_dprio_block_select,
	output	[7:0]	pa_dprio_readdata,
	input dft_scan_clk

);
parameter silicon_rev = "20nm5es";
parameter mode = "tile_ddr";
parameter pa_filter_code = 1600;
parameter [11:0] pa_phase_offset_0 = 12'b0;
parameter [11:0] pa_phase_offset_1 = 12'b0;
parameter [2:0] pa_exponent_0 = 3'b0;
parameter [2:0] pa_exponent_1 = 3'b0;
parameter [4:0] pa_mantissa_0 = 5'b0;
parameter [4:0] pa_mantissa_1 = 5'b0;
parameter pa_sync_control = "no_sync";
parameter [3:0] pa_sync_latency = 4'b0;
parameter [4:0] pa_track_speed = 5'b0;
parameter pa_feedback_mux_sel_0 = "fb0_p_clk_0";
parameter pa_feedback_mux_sel_1 = "fb0_p_clk_1";
parameter pa_feedback_divider_p0 = "div_by_1_p0";
parameter pa_feedback_divider_p1 = "div_by_1_p1";
parameter pa_feedback_divider_c0 = "div_by_1_c0";
parameter pa_feedback_divider_c1 = "div_by_1_c1";
parameter [3:0] pa_freq_track_speed = 4'b0;
parameter hmc_cfg_wdata_driver_sel = "core_w";
parameter hmc_cfg_prbs_ctrl_sel = "hmc";
parameter hmc_cfg_mmr_driver_sel = "core_m";
parameter hmc_cfg_loopback_en = "disable";
parameter hmc_cfg_cmd_driver_sel = "core_c";
parameter hmc_cfg_dbg_mode = "function";
parameter [31:0] hmc_cfg_dbg_ctrl = 32'b0;
parameter [31:0] hmc_cfg_bist_cmd0_u = 32'b0;
parameter [31:0] hmc_cfg_bist_cmd0_l = 32'b0;
parameter [31:0] hmc_cfg_bist_cmd1_u = 32'b0;
parameter [31:0] hmc_cfg_bist_cmd1_l = 32'b0;
parameter [15:0] hmc_cfg_dbg_out_sel = 16'b0;
parameter hmc_ctrl_mem_type = "ddr3";
parameter hmc_ctrl_dimm_type = "component";
parameter hmc_ctrl_ac_pos = "use_0_1_2_lane";
parameter hmc_ctrl_burst_length = "bl_8_ctrl";
parameter hmc_dbc0_burst_length = "bl_8_dbc0";
parameter hmc_dbc1_burst_length = "bl_8_dbc1";
parameter hmc_dbc2_burst_length = "bl_8_dbc2";
parameter hmc_dbc3_burst_length = "bl_8_dbc3";
parameter hmc_addr_order = "chip_bank_row_col";
parameter hmc_ctrl_enable_ecc = "disable";
parameter hmc_dbc0_enable_ecc = "disable";
parameter hmc_dbc1_enable_ecc = "disable";
parameter hmc_dbc2_enable_ecc = "disable";
parameter hmc_dbc3_enable_ecc = "disable";
parameter hmc_reorder_data = "disable";
parameter hmc_ctrl_reorder_rdata = "disable";
parameter hmc_dbc0_reorder_rdata = "disable";
parameter hmc_dbc1_reorder_rdata = "disable";
parameter hmc_dbc2_reorder_rdata = "disable";
parameter hmc_dbc3_reorder_rdata = "disable";
parameter hmc_reorder_read = "disable";
parameter [5:0] hmc_starve_limit = 6'b111111;
parameter hmc_enable_dqs_tracking = "enable";
parameter hmc_ctrl_enable_dm = "enable";
parameter hmc_dbc0_enable_dm = "enable";
parameter hmc_dbc1_enable_dm = "enable";
parameter hmc_dbc2_enable_dm = "enable";
parameter hmc_dbc3_enable_dm = "enable";
parameter hmc_ctrl_output_regd = "disable";
parameter hmc_dbc0_output_regd = "disable";
parameter hmc_dbc1_output_regd = "disable";
parameter hmc_dbc2_output_regd = "disable";
parameter hmc_dbc3_output_regd = "disable";
parameter hmc_ctrl2dbc_switch0 = "local_tile_dbc0";
parameter hmc_ctrl2dbc_switch1 = "local_tile_dbc1";
parameter hmc_dbc0_ctrl_sel = "upper_mux_dbc0";
parameter hmc_dbc1_ctrl_sel = "upper_mux_dbc1";
parameter hmc_dbc2_ctrl_sel = "upper_mux_dbc2";
parameter hmc_dbc3_ctrl_sel = "upper_mux_dbc3";
parameter hmc_dbc2ctrl_sel = "dbc0_to_local";
parameter [2:0] hmc_dbc0_pipe_lat = 3'b0;
parameter [2:0] hmc_dbc1_pipe_lat = 3'b0;
parameter [2:0] hmc_dbc2_pipe_lat = 3'b0;
parameter [2:0] hmc_dbc3_pipe_lat = 3'b0;
parameter hmc_ctrl_cmd_rate = "half_rate";
parameter hmc_dbc0_cmd_rate = "half_rate_dbc0";
parameter hmc_dbc1_cmd_rate = "half_rate_dbc1";
parameter hmc_dbc2_cmd_rate = "half_rate_dbc2";
parameter hmc_dbc3_cmd_rate = "half_rate_dbc3";
parameter hmc_ctrl_in_protocol = "ast_in";
parameter hmc_dbc0_in_protocol = "ast_dbc0";
parameter hmc_dbc1_in_protocol = "ast_dbc1";
parameter hmc_dbc2_in_protocol = "ast_dbc2";
parameter hmc_dbc3_in_protocol = "ast_dbc3";
parameter hmc_ctrl_dualport_en = "disable";
parameter hmc_dbc0_dualport_en = "disable";
parameter hmc_dbc1_dualport_en = "disable";
parameter hmc_dbc2_dualport_en = "disable";
parameter hmc_dbc3_dualport_en = "disable";
parameter hmc_arbiter_type = "twot";
parameter hmc_open_page_en = "disable";
parameter hmc_geardn_en = "disable";
parameter hmc_rld3_multibank_mode = "singlebank";
parameter [4:0] hmc_tile_id = 5'b0;
parameter hmc_cfg_pinpong_mode = "pingpong_off";
parameter [1:0] hmc_ctrl_slot_rotate_en = 2'b0;
parameter [1:0] hmc_dbc0_slot_rotate_en = 2'b0;
parameter [1:0] hmc_dbc1_slot_rotate_en = 2'b0;
parameter [1:0] hmc_dbc2_slot_rotate_en = 2'b0;
parameter [1:0] hmc_dbc3_slot_rotate_en = 2'b0;
parameter [1:0] hmc_ctrl_slot_offset = 2'b0;
parameter [1:0] hmc_dbc0_slot_offset = 2'b0;
parameter [1:0] hmc_dbc1_slot_offset = 2'b0;
parameter [1:0] hmc_dbc2_slot_offset = 2'b0;
parameter [1:0] hmc_dbc3_slot_offset = 2'b0;
parameter [3:0] hmc_col_cmd_slot = 4'b10;
parameter [3:0] hmc_row_cmd_slot = 4'b1;
parameter hmc_ctrl_rc_en = "disable";
parameter hmc_dbc0_rc_en = "disable";
parameter hmc_dbc1_rc_en = "disable";
parameter hmc_dbc2_rc_en = "disable";
parameter hmc_dbc3_rc_en = "disable";
parameter [15:0] hmc_cs_chip = 16'b1000010000100001;
parameter hmc_clkgating_en = "disable";
parameter [6:0] hmc_rb_reserved_entry = 7'b0;
parameter [6:0] hmc_wb_reserved_entry = 7'b0;
parameter hmc_cfg_3ds_en = "disable";
parameter hmc_ck_inv = "disable";
parameter hmc_addr_mplx_en = "disable";
parameter [6:0] hmc_tcl = 7'b110;
parameter [5:0] hmc_power_saving_exit_cycles = 6'b101;
parameter [5:0] hmc_mem_clk_disable_entry_cycles = 6'b1010;
parameter [15:0] hmc_write_odt_chip = 16'b0;
parameter [15:0] hmc_read_odt_chip = 16'b0;
parameter [5:0] hmc_wr_odt_on = 6'b0;
parameter [5:0] hmc_rd_odt_on = 6'b0;
parameter [5:0] hmc_wr_odt_period = 6'b0;
parameter [5:0] hmc_rd_odt_period = 6'b0;
parameter [15:0] hmc_rld3_refresh_seq0 = 16'b0;
parameter [15:0] hmc_rld3_refresh_seq1 = 16'b0;
parameter [15:0] hmc_rld3_refresh_seq2 = 16'b0;
parameter [15:0] hmc_rld3_refresh_seq3 = 16'b0;
parameter hmc_srf_zqcal_disable = "disable";
parameter hmc_mps_zqcal_disable = "disable";
parameter hmc_mps_dqstrk_disable = "disable";
parameter hmc_sb_cg_disable = "disable";
parameter hmc_user_rfsh_en = "disable";
parameter hmc_srf_autoexit_en = "disable";
parameter hmc_srf_entry_exit_block = "presrfenter";
parameter [19:0] hmc_sb_ddr4_mr3 = 20'b0;
parameter [19:0] hmc_sb_ddr4_mr4 = 20'b0;
parameter hmc_short_dqstrk_ctrl_en = "disable";
parameter hmc_period_dqstrk_ctrl_en = "disable";
parameter [15:0] hmc_period_dqstrk_interval = 16'b0;
parameter [7:0] hmc_dqstrk_to_valid_last = 8'b0;
parameter [7:0] hmc_dqstrk_to_valid = 8'b0;
parameter [6:0] hmc_rfsh_warn_threshold = 7'b0;
parameter [5:0] hmc_act_to_rdwr = 6'b0;
parameter [5:0] hmc_act_to_pch = 6'b0;
parameter [5:0] hmc_act_to_act = 6'b0;
parameter [5:0] hmc_act_to_act_diff_bank = 6'b0;
parameter [5:0] hmc_act_to_act_diff_bg = 6'b0;
parameter [5:0] hmc_rd_to_rd = 6'b0;
parameter [5:0] hmc_rd_to_rd_diff_chip = 6'b0;
parameter [5:0] hmc_rd_to_rd_diff_bg = 6'b0;
parameter [5:0] hmc_rd_to_wr = 6'b0;
parameter [5:0] hmc_rd_to_wr_diff_chip = 6'b0;
parameter [5:0] hmc_rd_to_wr_diff_bg = 6'b0;
parameter [5:0] hmc_rd_to_pch = 6'b0;
parameter [5:0] hmc_rd_ap_to_valid = 6'b0;
parameter [5:0] hmc_wr_to_wr = 6'b0;
parameter [5:0] hmc_wr_to_wr_diff_chip = 6'b0;
parameter [5:0] hmc_wr_to_wr_diff_bg = 6'b0;
parameter [5:0] hmc_wr_to_rd = 6'b0;
parameter [5:0] hmc_wr_to_rd_diff_chip = 6'b0;
parameter [5:0] hmc_wr_to_rd_diff_bg = 6'b0;
parameter [5:0] hmc_wr_to_pch = 6'b0;
parameter [5:0] hmc_wr_ap_to_valid = 6'b0;
parameter [5:0] hmc_pch_to_valid = 6'b0;
parameter [5:0] hmc_pch_all_to_valid = 6'b0;
parameter [7:0] hmc_arf_to_valid = 8'b0;
parameter [5:0] hmc_pdn_to_valid = 6'b0;
parameter [9:0] hmc_srf_to_valid = 10'b0;
parameter [9:0] hmc_srf_to_zq_cal = 10'b0;
parameter [12:0] hmc_arf_period = 13'b0;
parameter [15:0] hmc_pdn_period = 16'b0;
parameter [8:0] hmc_zqcl_to_valid = 9'b0;
parameter [6:0] hmc_zqcs_to_valid = 7'b0;
parameter [3:0] hmc_mrs_to_valid = 4'b0;
parameter [9:0] hmc_mps_to_valid = 10'b0;
parameter [3:0] hmc_mrr_to_valid = 4'b0;
parameter [4:0] hmc_mpr_to_valid = 5'b0;
parameter [3:0] hmc_mps_exit_cs_to_cke = 4'b0;
parameter [3:0] hmc_mps_exit_cke_to_cs = 4'b0;
parameter [2:0] hmc_rld3_multibank_ref_delay = 3'b0;
parameter [7:0] hmc_mmr_cmd_to_valid = 8'b0;
parameter [7:0] hmc_4_act_to_act = 8'b0;
parameter [7:0] hmc_16_act_to_act = 8'b0;
parameter hmc_mem_if_coladdr_width = "col_width_12";
parameter hmc_mem_if_rowaddr_width = "row_width_16";
parameter hmc_mem_if_bankaddr_width = "bank_width_3";
parameter hmc_mem_if_bgaddr_width = "bg_width_0";
parameter hmc_local_if_cs_width = "cs_width_2";
parameter [8:0] physeq_tile_id = 9'b0;
parameter physeq_bc_id_ena = "bc_disable";
parameter physeq_avl_ena = "avl_disable";
parameter physeq_hmc_or_core = "core";
parameter physeq_trk_mgr_mrnk_mode = "one_rank";
parameter physeq_trk_mgr_read_monitor_ena = "disable";
parameter [8:0] physeq_hmc_id = 9'b0;
parameter physeq_reset_auto_release = "auto";
parameter physeq_rwlat_mode = "csr_vlu";
parameter [5:0] physeq_afi_rlat_vlu = 6'b0;
parameter [5:0] physeq_afi_wlat_vlu = 6'b0;
parameter hmc_second_clk_src = "clk1";
parameter [20:0] physeq_seq_feature = 21'b0;
parameter [15:0] hmc_sb_ddr4_mr5 = 16'b0;
parameter [0:0] hmc_ddr4_mps_addr_mirror = 1'b0;
parameter hps_ctrl_en = "false";
parameter ioaux_info = "";
parameter ioaux_info_valid = "false";
parameter ioaux_param_table = "";
parameter rewired = "false";

twentynm_tile_ctrl_encrypted inst (
	.pa_core_in(pa_core_in),
	.pa_core_clk_in(pa_core_clk_in),
	.pa_fbclk_in(pa_fbclk_in),
	.pa_sync_data_bot_in(pa_sync_data_bot_in),
	.pa_sync_data_top_in(pa_sync_data_top_in),
	.pa_sync_clk_bot_in(pa_sync_clk_bot_in),
	.pa_sync_clk_top_in(pa_sync_clk_top_in),
	.pa_reset_n(pa_reset_n),
	.pll_vco_in(pll_vco_in),
	.phy_clk_in(phy_clk_in),
	.dll_clk_in(dll_clk_in),
	.dqs_in_x4_a_0(dqs_in_x4_a_0),
	.dqs_in_x4_a_1(dqs_in_x4_a_1),
	.dqs_in_x4_a_2(dqs_in_x4_a_2),
	.dqs_in_x4_a_3(dqs_in_x4_a_3),
	.dqs_in_x4_b_0(dqs_in_x4_b_0),
	.dqs_in_x4_b_1(dqs_in_x4_b_1),
	.dqs_in_x4_b_2(dqs_in_x4_b_2),
	.dqs_in_x4_b_3(dqs_in_x4_b_3),
	.dqs_in_x8_0(dqs_in_x8_0),
	.dqs_in_x8_1(dqs_in_x8_1),
	.dqs_in_x8_2(dqs_in_x8_2),
	.dqs_in_x8_3(dqs_in_x8_3),
	.dqs_in_x18_0(dqs_in_x18_0),
	.dqs_in_x18_1(dqs_in_x18_1),
	.dqs_in_x36(dqs_in_x36),
	.ctl2dbc_in_up(ctl2dbc_in_up),
	.ctl2dbc_in_down(ctl2dbc_in_down),
	.dbc2ctl0(dbc2ctl0),
	.dbc2ctl1(dbc2ctl1),
	.dbc2ctl2(dbc2ctl2),
	.dbc2ctl3(dbc2ctl3),
	.dbc2core_wr_data_rdy0(dbc2core_wr_data_rdy0),
	.dbc2core_wr_data_rdy1(dbc2core_wr_data_rdy1),
	.dbc2core_wr_data_rdy2(dbc2core_wr_data_rdy2),
	.dbc2core_wr_data_rdy3(dbc2core_wr_data_rdy3),
	.ping_pong_in(ping_pong_in),
	.core2ctl_avl0(core2ctl_avl0),
	.core2ctl_avl1(core2ctl_avl1),
	.core2ctl_avl_rd_data_ready(core2ctl_avl_rd_data_ready),
	.core2ctl_sideband(core2ctl_sideband),
	.mmr_in(mmr_in),
	.cal_avl_in(cal_avl_in),
	.cal_avl_rdata_in(cal_avl_rdata_in),
	.afi_core2ctl(afi_core2ctl),
	.afi_lane0_to_ctl(afi_lane0_to_ctl),
	.afi_lane1_to_ctl(afi_lane1_to_ctl),
	.afi_lane2_to_ctl(afi_lane2_to_ctl),
	.afi_lane3_to_ctl(afi_lane3_to_ctl),
	.pll_locked_in(pll_locked_in),
	.global_reset_n(global_reset_n),
	.rdata_en_full_core(rdata_en_full_core),
	.mrnk_read_core(mrnk_read_core),
	.pa_core_clk_out(pa_core_clk_out),
	.pa_locked(pa_locked),
	.pa_sync_data_bot_out(pa_sync_data_bot_out),
	.pa_sync_data_top_out(pa_sync_data_top_out),
	.pa_sync_clk_top_out(pa_sync_clk_top_out),
	.pa_sync_clk_bot_out(pa_sync_clk_bot_out),
	.dll_clk_out0(dll_clk_out0),
	.dll_clk_out1(dll_clk_out1),
	.dll_clk_out2(dll_clk_out2),
	.dll_clk_out3(dll_clk_out3),
	.phy_clk_out0(phy_clk_out0),
	.phy_clk_out1(phy_clk_out1),
	.phy_clk_out2(phy_clk_out2),
	.phy_clk_out3(phy_clk_out3),
	.dqs_out_x4_a_lane0(dqs_out_x4_a_lane0),
	.dqs_out_x4_a_lane1(dqs_out_x4_a_lane1),
	.dqs_out_x4_a_lane2(dqs_out_x4_a_lane2),
	.dqs_out_x4_a_lane3(dqs_out_x4_a_lane3),
	.dqs_out_x4_b_lane0(dqs_out_x4_b_lane0),
	.dqs_out_x4_b_lane1(dqs_out_x4_b_lane1),
	.dqs_out_x4_b_lane2(dqs_out_x4_b_lane2),
	.dqs_out_x4_b_lane3(dqs_out_x4_b_lane3),
	.dqs_out_x8_lane0(dqs_out_x8_lane0),
	.dqs_out_x18_lane0(dqs_out_x18_lane0),
	.dqs_out_x36_lane0(dqs_out_x36_lane0),
	.dqs_out_x8_lane1(dqs_out_x8_lane1),
	.dqs_out_x18_lane1(dqs_out_x18_lane1),
	.dqs_out_x36_lane1(dqs_out_x36_lane1),
	.dqs_out_x8_lane2(dqs_out_x8_lane2),
	.dqs_out_x18_lane2(dqs_out_x18_lane2),
	.dqs_out_x36_lane2(dqs_out_x36_lane2),
	.dqs_out_x8_lane3(dqs_out_x8_lane3),
	.dqs_out_x18_lane3(dqs_out_x18_lane3),
	.dqs_out_x36_lane3(dqs_out_x36_lane3),
	.ctl2dbc0(ctl2dbc0),
	.ctl2dbc1(ctl2dbc1),
	.cfg_dbc0(cfg_dbc0),
	.cfg_dbc1(cfg_dbc1),
	.cfg_dbc2(cfg_dbc2),
	.cfg_dbc3(cfg_dbc3),
	.ping_pong_out(ping_pong_out),
	.ctl2core_avl_rdata_id(ctl2core_avl_rdata_id),
	.ctl2core_avl_cmd_ready(ctl2core_avl_cmd_ready),
	.ctl2core_sideband(ctl2core_sideband),
	.mmr_out(mmr_out),
	.cal_avl_out(cal_avl_out),
	.cal_avl_rdata_out(cal_avl_rdata_out),
	.afi_ctl2core(afi_ctl2core),
	.afi_cmd_bus(afi_cmd_bus),
	.seq2core_reset_n(seq2core_reset_n),
	.ctl_mem_clk_disable(ctl_mem_clk_disable),
	.phy_fbclk_out(phy_fbclk_out),
	.test_dbg_in(test_dbg_in),
	.test_dbg_out(test_dbg_out),
	.pa_dprio_clk(pa_dprio_clk),
	.pa_dprio_read(pa_dprio_read),
	.pa_dprio_reg_addr(pa_dprio_reg_addr),
	.pa_dprio_rst_n(pa_dprio_rst_n),
	.pa_dprio_write(pa_dprio_write),
	.pa_dprio_writedata(pa_dprio_writedata),
	.pa_dprio_block_select(pa_dprio_block_select),
	.pa_dprio_readdata(pa_dprio_readdata),
	.dft_scan_clk(dft_scan_clk)
	);
defparam inst.mode = mode;
defparam inst.pa_filter_code = pa_filter_code;
defparam inst.pa_phase_offset_0 = pa_phase_offset_0;
defparam inst.pa_phase_offset_1 = pa_phase_offset_1;
defparam inst.pa_exponent_0 = pa_exponent_0;
defparam inst.pa_exponent_1 = pa_exponent_1;
defparam inst.pa_mantissa_0 = pa_mantissa_0;
defparam inst.pa_mantissa_1 = pa_mantissa_1;
defparam inst.pa_sync_control = pa_sync_control;
defparam inst.pa_sync_latency = pa_sync_latency;
defparam inst.pa_track_speed = pa_track_speed;
defparam inst.pa_feedback_mux_sel_0 = pa_feedback_mux_sel_0;
defparam inst.pa_feedback_mux_sel_1 = pa_feedback_mux_sel_1;
defparam inst.pa_feedback_divider_p0 = pa_feedback_divider_p0;
defparam inst.pa_feedback_divider_p1 = pa_feedback_divider_p1;
defparam inst.pa_feedback_divider_c0 = pa_feedback_divider_c0;
defparam inst.pa_feedback_divider_c1 = pa_feedback_divider_c1;
defparam inst.pa_freq_track_speed = pa_freq_track_speed;
defparam inst.hmc_cfg_wdata_driver_sel = hmc_cfg_wdata_driver_sel;
defparam inst.hmc_cfg_prbs_ctrl_sel = hmc_cfg_prbs_ctrl_sel;
defparam inst.hmc_cfg_mmr_driver_sel = hmc_cfg_mmr_driver_sel;
defparam inst.hmc_cfg_loopback_en = hmc_cfg_loopback_en;
defparam inst.hmc_cfg_cmd_driver_sel = hmc_cfg_cmd_driver_sel;
defparam inst.hmc_cfg_dbg_mode = hmc_cfg_dbg_mode;
defparam inst.hmc_cfg_dbg_ctrl = hmc_cfg_dbg_ctrl;
defparam inst.hmc_cfg_bist_cmd0_u = hmc_cfg_bist_cmd0_u;
defparam inst.hmc_cfg_bist_cmd0_l = hmc_cfg_bist_cmd0_l;
defparam inst.hmc_cfg_bist_cmd1_u = hmc_cfg_bist_cmd1_u;
defparam inst.hmc_cfg_bist_cmd1_l = hmc_cfg_bist_cmd1_l;
defparam inst.hmc_cfg_dbg_out_sel = hmc_cfg_dbg_out_sel;
defparam inst.hmc_ctrl_mem_type = hmc_ctrl_mem_type;
defparam inst.hmc_ctrl_dimm_type = hmc_ctrl_dimm_type;
defparam inst.hmc_ctrl_ac_pos = hmc_ctrl_ac_pos;
defparam inst.hmc_ctrl_burst_length = hmc_ctrl_burst_length;
defparam inst.hmc_dbc0_burst_length = hmc_dbc0_burst_length;
defparam inst.hmc_dbc1_burst_length = hmc_dbc1_burst_length;
defparam inst.hmc_dbc2_burst_length = hmc_dbc2_burst_length;
defparam inst.hmc_dbc3_burst_length = hmc_dbc3_burst_length;
defparam inst.hmc_addr_order = hmc_addr_order;
defparam inst.hmc_ctrl_enable_ecc = hmc_ctrl_enable_ecc;
defparam inst.hmc_dbc0_enable_ecc = hmc_dbc0_enable_ecc;
defparam inst.hmc_dbc1_enable_ecc = hmc_dbc1_enable_ecc;
defparam inst.hmc_dbc2_enable_ecc = hmc_dbc2_enable_ecc;
defparam inst.hmc_dbc3_enable_ecc = hmc_dbc3_enable_ecc;
defparam inst.hmc_reorder_data = hmc_reorder_data;
defparam inst.hmc_ctrl_reorder_rdata = hmc_ctrl_reorder_rdata;
defparam inst.hmc_dbc0_reorder_rdata = hmc_dbc0_reorder_rdata;
defparam inst.hmc_dbc1_reorder_rdata = hmc_dbc1_reorder_rdata;
defparam inst.hmc_dbc2_reorder_rdata = hmc_dbc2_reorder_rdata;
defparam inst.hmc_dbc3_reorder_rdata = hmc_dbc3_reorder_rdata;
defparam inst.hmc_reorder_read = hmc_reorder_read;
defparam inst.hmc_starve_limit = hmc_starve_limit;
defparam inst.hmc_enable_dqs_tracking = hmc_enable_dqs_tracking;
defparam inst.hmc_ctrl_enable_dm = hmc_ctrl_enable_dm;
defparam inst.hmc_dbc0_enable_dm = hmc_dbc0_enable_dm;
defparam inst.hmc_dbc1_enable_dm = hmc_dbc1_enable_dm;
defparam inst.hmc_dbc2_enable_dm = hmc_dbc2_enable_dm;
defparam inst.hmc_dbc3_enable_dm = hmc_dbc3_enable_dm;
defparam inst.hmc_ctrl_output_regd = hmc_ctrl_output_regd;
defparam inst.hmc_dbc0_output_regd = hmc_dbc0_output_regd;
defparam inst.hmc_dbc1_output_regd = hmc_dbc1_output_regd;
defparam inst.hmc_dbc2_output_regd = hmc_dbc2_output_regd;
defparam inst.hmc_dbc3_output_regd = hmc_dbc3_output_regd;
defparam inst.hmc_ctrl2dbc_switch0 = hmc_ctrl2dbc_switch0;
defparam inst.hmc_ctrl2dbc_switch1 = hmc_ctrl2dbc_switch1;
defparam inst.hmc_dbc0_ctrl_sel = hmc_dbc0_ctrl_sel;
defparam inst.hmc_dbc1_ctrl_sel = hmc_dbc1_ctrl_sel;
defparam inst.hmc_dbc2_ctrl_sel = hmc_dbc2_ctrl_sel;
defparam inst.hmc_dbc3_ctrl_sel = hmc_dbc3_ctrl_sel;
defparam inst.hmc_dbc2ctrl_sel = hmc_dbc2ctrl_sel;
defparam inst.hmc_dbc0_pipe_lat = hmc_dbc0_pipe_lat;
defparam inst.hmc_dbc1_pipe_lat = hmc_dbc1_pipe_lat;
defparam inst.hmc_dbc2_pipe_lat = hmc_dbc2_pipe_lat;
defparam inst.hmc_dbc3_pipe_lat = hmc_dbc3_pipe_lat;
defparam inst.hmc_ctrl_cmd_rate = hmc_ctrl_cmd_rate;
defparam inst.hmc_dbc0_cmd_rate = hmc_dbc0_cmd_rate;
defparam inst.hmc_dbc1_cmd_rate = hmc_dbc1_cmd_rate;
defparam inst.hmc_dbc2_cmd_rate = hmc_dbc2_cmd_rate;
defparam inst.hmc_dbc3_cmd_rate = hmc_dbc3_cmd_rate;
defparam inst.hmc_ctrl_in_protocol = hmc_ctrl_in_protocol;
defparam inst.hmc_dbc0_in_protocol = hmc_dbc0_in_protocol;
defparam inst.hmc_dbc1_in_protocol = hmc_dbc1_in_protocol;
defparam inst.hmc_dbc2_in_protocol = hmc_dbc2_in_protocol;
defparam inst.hmc_dbc3_in_protocol = hmc_dbc3_in_protocol;
defparam inst.hmc_ctrl_dualport_en = hmc_ctrl_dualport_en;
defparam inst.hmc_dbc0_dualport_en = hmc_dbc0_dualport_en;
defparam inst.hmc_dbc1_dualport_en = hmc_dbc1_dualport_en;
defparam inst.hmc_dbc2_dualport_en = hmc_dbc2_dualport_en;
defparam inst.hmc_dbc3_dualport_en = hmc_dbc3_dualport_en;
defparam inst.hmc_arbiter_type = hmc_arbiter_type;
defparam inst.hmc_open_page_en = hmc_open_page_en;
defparam inst.hmc_geardn_en = hmc_geardn_en;
defparam inst.hmc_rld3_multibank_mode = hmc_rld3_multibank_mode;
defparam inst.hmc_tile_id = hmc_tile_id;
defparam inst.hmc_cfg_pinpong_mode = hmc_cfg_pinpong_mode;
defparam inst.hmc_ctrl_slot_rotate_en = hmc_ctrl_slot_rotate_en;
defparam inst.hmc_dbc0_slot_rotate_en = hmc_dbc0_slot_rotate_en;
defparam inst.hmc_dbc1_slot_rotate_en = hmc_dbc1_slot_rotate_en;
defparam inst.hmc_dbc2_slot_rotate_en = hmc_dbc2_slot_rotate_en;
defparam inst.hmc_dbc3_slot_rotate_en = hmc_dbc3_slot_rotate_en;
defparam inst.hmc_ctrl_slot_offset = hmc_ctrl_slot_offset;
defparam inst.hmc_dbc0_slot_offset = hmc_dbc0_slot_offset;
defparam inst.hmc_dbc1_slot_offset = hmc_dbc1_slot_offset;
defparam inst.hmc_dbc2_slot_offset = hmc_dbc2_slot_offset;
defparam inst.hmc_dbc3_slot_offset = hmc_dbc3_slot_offset;
defparam inst.hmc_col_cmd_slot = hmc_col_cmd_slot;
defparam inst.hmc_row_cmd_slot = hmc_row_cmd_slot;
defparam inst.hmc_ctrl_rc_en = hmc_ctrl_rc_en;
defparam inst.hmc_dbc0_rc_en = hmc_dbc0_rc_en;
defparam inst.hmc_dbc1_rc_en = hmc_dbc1_rc_en;
defparam inst.hmc_dbc2_rc_en = hmc_dbc2_rc_en;
defparam inst.hmc_dbc3_rc_en = hmc_dbc3_rc_en;
defparam inst.hmc_cs_chip = hmc_cs_chip;
defparam inst.hmc_clkgating_en = hmc_clkgating_en;
defparam inst.hmc_rb_reserved_entry = hmc_rb_reserved_entry;
defparam inst.hmc_wb_reserved_entry = hmc_wb_reserved_entry;
defparam inst.hmc_cfg_3ds_en = hmc_cfg_3ds_en;
defparam inst.hmc_ck_inv = hmc_ck_inv;
defparam inst.hmc_addr_mplx_en = hmc_addr_mplx_en;
defparam inst.hmc_tcl = hmc_tcl;
defparam inst.hmc_power_saving_exit_cycles = hmc_power_saving_exit_cycles;
defparam inst.hmc_mem_clk_disable_entry_cycles = hmc_mem_clk_disable_entry_cycles;
defparam inst.hmc_write_odt_chip = hmc_write_odt_chip;
defparam inst.hmc_read_odt_chip = hmc_read_odt_chip;
defparam inst.hmc_wr_odt_on = hmc_wr_odt_on;
defparam inst.hmc_rd_odt_on = hmc_rd_odt_on;
defparam inst.hmc_wr_odt_period = hmc_wr_odt_period;
defparam inst.hmc_rd_odt_period = hmc_rd_odt_period;
defparam inst.hmc_rld3_refresh_seq0 = hmc_rld3_refresh_seq0;
defparam inst.hmc_rld3_refresh_seq1 = hmc_rld3_refresh_seq1;
defparam inst.hmc_rld3_refresh_seq2 = hmc_rld3_refresh_seq2;
defparam inst.hmc_rld3_refresh_seq3 = hmc_rld3_refresh_seq3;
defparam inst.hmc_srf_zqcal_disable = hmc_srf_zqcal_disable;
defparam inst.hmc_mps_zqcal_disable = hmc_mps_zqcal_disable;
defparam inst.hmc_mps_dqstrk_disable = hmc_mps_dqstrk_disable;
defparam inst.hmc_sb_cg_disable = hmc_sb_cg_disable;
defparam inst.hmc_user_rfsh_en = hmc_user_rfsh_en;
defparam inst.hmc_srf_autoexit_en = hmc_srf_autoexit_en;
defparam inst.hmc_srf_entry_exit_block = hmc_srf_entry_exit_block;
defparam inst.hmc_sb_ddr4_mr3 = hmc_sb_ddr4_mr3;
defparam inst.hmc_sb_ddr4_mr4 = hmc_sb_ddr4_mr4;
defparam inst.hmc_short_dqstrk_ctrl_en = hmc_short_dqstrk_ctrl_en;
defparam inst.hmc_period_dqstrk_ctrl_en = hmc_period_dqstrk_ctrl_en;
defparam inst.hmc_period_dqstrk_interval = hmc_period_dqstrk_interval;
defparam inst.hmc_dqstrk_to_valid_last = hmc_dqstrk_to_valid_last;
defparam inst.hmc_dqstrk_to_valid = hmc_dqstrk_to_valid;
defparam inst.hmc_rfsh_warn_threshold = hmc_rfsh_warn_threshold;
defparam inst.hmc_act_to_rdwr = hmc_act_to_rdwr;
defparam inst.hmc_act_to_pch = hmc_act_to_pch;
defparam inst.hmc_act_to_act = hmc_act_to_act;
defparam inst.hmc_act_to_act_diff_bank = hmc_act_to_act_diff_bank;
defparam inst.hmc_act_to_act_diff_bg = hmc_act_to_act_diff_bg;
defparam inst.hmc_rd_to_rd = hmc_rd_to_rd;
defparam inst.hmc_rd_to_rd_diff_chip = hmc_rd_to_rd_diff_chip;
defparam inst.hmc_rd_to_rd_diff_bg = hmc_rd_to_rd_diff_bg;
defparam inst.hmc_rd_to_wr = hmc_rd_to_wr;
defparam inst.hmc_rd_to_wr_diff_chip = hmc_rd_to_wr_diff_chip;
defparam inst.hmc_rd_to_wr_diff_bg = hmc_rd_to_wr_diff_bg;
defparam inst.hmc_rd_to_pch = hmc_rd_to_pch;
defparam inst.hmc_rd_ap_to_valid = hmc_rd_ap_to_valid;
defparam inst.hmc_wr_to_wr = hmc_wr_to_wr;
defparam inst.hmc_wr_to_wr_diff_chip = hmc_wr_to_wr_diff_chip;
defparam inst.hmc_wr_to_wr_diff_bg = hmc_wr_to_wr_diff_bg;
defparam inst.hmc_wr_to_rd = hmc_wr_to_rd;
defparam inst.hmc_wr_to_rd_diff_chip = hmc_wr_to_rd_diff_chip;
defparam inst.hmc_wr_to_rd_diff_bg = hmc_wr_to_rd_diff_bg;
defparam inst.hmc_wr_to_pch = hmc_wr_to_pch;
defparam inst.hmc_wr_ap_to_valid = hmc_wr_ap_to_valid;
defparam inst.hmc_pch_to_valid = hmc_pch_to_valid;
defparam inst.hmc_pch_all_to_valid = hmc_pch_all_to_valid;
defparam inst.hmc_arf_to_valid = hmc_arf_to_valid;
defparam inst.hmc_pdn_to_valid = hmc_pdn_to_valid;
defparam inst.hmc_srf_to_valid = hmc_srf_to_valid;
defparam inst.hmc_srf_to_zq_cal = hmc_srf_to_zq_cal;
defparam inst.hmc_arf_period = hmc_arf_period;
defparam inst.hmc_pdn_period = hmc_pdn_period;
defparam inst.hmc_zqcl_to_valid = hmc_zqcl_to_valid;
defparam inst.hmc_zqcs_to_valid = hmc_zqcs_to_valid;
defparam inst.hmc_mrs_to_valid = hmc_mrs_to_valid;
defparam inst.hmc_mps_to_valid = hmc_mps_to_valid;
defparam inst.hmc_mrr_to_valid = hmc_mrr_to_valid;
defparam inst.hmc_mpr_to_valid = hmc_mpr_to_valid;
defparam inst.hmc_mps_exit_cs_to_cke = hmc_mps_exit_cs_to_cke;
defparam inst.hmc_mps_exit_cke_to_cs = hmc_mps_exit_cke_to_cs;
defparam inst.hmc_rld3_multibank_ref_delay = hmc_rld3_multibank_ref_delay;
defparam inst.hmc_mmr_cmd_to_valid = hmc_mmr_cmd_to_valid;
defparam inst.hmc_4_act_to_act = hmc_4_act_to_act;
defparam inst.hmc_16_act_to_act = hmc_16_act_to_act;
defparam inst.hmc_mem_if_coladdr_width = hmc_mem_if_coladdr_width;
defparam inst.hmc_mem_if_rowaddr_width = hmc_mem_if_rowaddr_width;
defparam inst.hmc_mem_if_bankaddr_width = hmc_mem_if_bankaddr_width;
defparam inst.hmc_mem_if_bgaddr_width = hmc_mem_if_bgaddr_width;
defparam inst.hmc_local_if_cs_width = hmc_local_if_cs_width;
defparam inst.physeq_tile_id = physeq_tile_id;
defparam inst.physeq_bc_id_ena = physeq_bc_id_ena;
defparam inst.physeq_avl_ena = physeq_avl_ena;
defparam inst.physeq_hmc_or_core = physeq_hmc_or_core;
defparam inst.physeq_trk_mgr_mrnk_mode = physeq_trk_mgr_mrnk_mode;
defparam inst.physeq_trk_mgr_read_monitor_ena = physeq_trk_mgr_read_monitor_ena;
defparam inst.physeq_hmc_id = physeq_hmc_id;
defparam inst.physeq_reset_auto_release = physeq_reset_auto_release;
defparam inst.physeq_rwlat_mode = physeq_rwlat_mode;
defparam inst.physeq_afi_rlat_vlu = physeq_afi_rlat_vlu;
defparam inst.physeq_afi_wlat_vlu = physeq_afi_wlat_vlu;
defparam inst.hmc_second_clk_src = hmc_second_clk_src;
defparam inst.physeq_seq_feature = physeq_seq_feature;
defparam inst.hmc_sb_ddr4_mr5 = hmc_sb_ddr4_mr5;
defparam inst.hmc_ddr4_mps_addr_mirror = hmc_ddr4_mps_addr_mirror;
defparam inst.hps_ctrl_en = hps_ctrl_en;
defparam inst.silicon_rev = silicon_rev;
defparam inst.ioaux_info = ioaux_info;
defparam inst.ioaux_info_valid = ioaux_info_valid;
defparam inst.ioaux_param_table = ioaux_param_table;
defparam inst.rewired = rewired;
endmodule //twentynm_tile_ctrl


`timescale 1 ps/1 ps
module twentynm_refclk_input (
	input		ref_clk_in,
	input		pll_cascade_in,
	input	[3:0]	up_in,
	input	[3:0]	down_in,
	output	[3:0]	up_out,
	output	[3:0]	down_out,
	output		clk_out
);
parameter pllin_msel = "refclk0_ftop";
parameter refclk0in_msel = "refclk1_0";
parameter refclk1in_msel = "refclk2_1";
parameter refclk2in_msel = "high_2";
parameter refclk3in_msel = "high_3";
parameter refclk1_muxin_en = "disable_muxin_1";
parameter refclk2_muxin_en = "disable_muxin_2";
parameter refclk3_muxin_en = "disable_muxin_3";
parameter refclk1_tp_upen = "disable_tp_up_1";
parameter refclk1_tp_dwnen = "disable_tp_dn_1";
parameter refclk1_btm_upen = "disable_bt_up_1";
parameter refclk1_btm_dwnen = "disable_bt_dn_1";
parameter refclk2_tp_upen = "disable_tp_up_2";
parameter refclk2_tp_dwnen = "disable_tp_dn_2";
parameter refclk2_btm_upen = "disable_bt_up_2";
parameter refclk2_btm_dwnen = "disable_bt_dn_2";
parameter refclk3_tp_upen = "disable_tp_up_3";
parameter refclk3_tp_dwnen = "disable_tp_dn_3";
parameter refclk3_btm_upen = "disable_bt_up_3";
parameter refclk3_btm_dwnen = "disable_bt_dn_3";
parameter ref2to3_en = "disable_2to3";
parameter ref3to2_en = "disable_3to2";
parameter clkpin_select = "select_clkpin_0";
parameter refclk_2_up_n = "no_weak_pullup_2";
parameter refclk_3_up_n = "no_weak_pullup_3";
parameter tnum = "tnum_1";
parameter location = "location_1";
parameter refclk1_dwn = "tri1";
parameter refclk2_dwn = "tri2";
parameter refclk3_dwn = "tri3";
parameter silicon_rev = "20nm5es";

twentynm_refclk_input_encrypted inst (
	.ref_clk_in(ref_clk_in),
	.pll_cascade_in(pll_cascade_in),
	.up_in(up_in),
	.down_in(down_in),
	.up_out(up_out),
	.down_out(down_out),
	.clk_out(clk_out)
);
defparam inst.pllin_msel = pllin_msel;
defparam inst.refclk0in_msel = refclk0in_msel;
defparam inst.refclk1in_msel = refclk1in_msel;
defparam inst.refclk2in_msel = refclk2in_msel;
defparam inst.refclk3in_msel = refclk3in_msel;
defparam inst.refclk1_muxin_en = refclk1_muxin_en;
defparam inst.refclk2_muxin_en = refclk2_muxin_en;
defparam inst.refclk3_muxin_en = refclk3_muxin_en;
defparam inst.refclk1_tp_upen = refclk1_tp_upen;
defparam inst.refclk1_tp_dwnen = refclk1_tp_dwnen;
defparam inst.refclk1_btm_upen = refclk1_btm_upen;
defparam inst.refclk1_btm_dwnen = refclk1_btm_dwnen;
defparam inst.refclk2_tp_upen = refclk2_tp_upen;
defparam inst.refclk2_tp_dwnen = refclk2_tp_dwnen;
defparam inst.refclk2_btm_upen = refclk2_btm_upen;
defparam inst.refclk2_btm_dwnen = refclk2_btm_dwnen;
defparam inst.refclk3_tp_upen = refclk3_tp_upen;
defparam inst.refclk3_tp_dwnen = refclk3_tp_dwnen;
defparam inst.refclk3_btm_upen = refclk3_btm_upen;
defparam inst.refclk3_btm_dwnen = refclk3_btm_dwnen;
defparam inst.ref2to3_en = ref2to3_en;
defparam inst.ref3to2_en = ref3to2_en;
defparam inst.clkpin_select = clkpin_select;
defparam inst.refclk_2_up_n = refclk_2_up_n;
defparam inst.refclk_3_up_n = refclk_3_up_n;

defparam inst.tnum = tnum;
defparam inst.location = location;
defparam inst.refclk1_dwn = refclk1_dwn;
defparam inst.refclk2_dwn = refclk2_dwn;
defparam inst.refclk3_dwn = refclk3_dwn;
defparam inst.silicon_rev = silicon_rev;
endmodule //twentynm_refclk_input


`timescale 1 ps/1 ps
module twentynm_io_aux (
   input             core_clk,
   input             core_usr_reset_n,
   input             debug_clk,
   input    [ 3: 0]  debug_select,
   input             mcu_en,
   input             mode,
   input    [27: 0]  soft_nios_addr,
   input             soft_nios_burstcount,
   input    [ 3: 0]  soft_nios_byteenable,
   input             soft_nios_clk,
   input             soft_nios_read,
   input             soft_nios_reset_n,
   input             soft_nios_write,
   input    [31: 0]  soft_nios_write_data,
   input             soft_ram_clk,
   input             soft_ram_reset_n,
   input    [31: 0]  soft_ram_read_data,
   input             soft_ram_rdata_valid,
   input             soft_ram_waitrequest,
   input    [31: 0]  uc_read_data,
   input             usrmode,
   input             vji_cdr_to_the_hard_nios,
   input    [ 1: 0]  vji_ir_in_to_the_hard_nios,
   input             vji_rti_to_the_hard_nios,
   input             vji_sdr_to_the_hard_nios,
   input             vji_tck_to_the_hard_nios,
   input             vji_tdi_to_the_hard_nios,
   input             vji_udr_to_the_hard_nios,
   input             vji_uir_to_the_hard_nios,
   output   [21: 0]  debug_out,
   output   [31: 0]  soft_nios_read_data,
   output            soft_nios_read_data_valid,
   output            soft_nios_waitrequest,
   output   [15: 0]  soft_ram_addr,
   output            soft_ram_burstcount,
   output   [ 3: 0]  soft_ram_byteenable,
   output            soft_ram_debugaccess,
   output            soft_ram_read,
   output            soft_ram_rst_n,
   output            soft_ram_write,
   output   [31: 0]  soft_ram_write_data,
   output   [19: 0]  uc_address,
   output            uc_av_bus_clk,
   output            uc_read,
   output            uc_write,
   output   [31: 0]  uc_write_data,
   output   [ 1: 0]  vji_ir_out_from_the_hard_nios,
   output            vji_tdo_from_the_hard_nios,
   input    [ 7: 0]  pio_in,
   output   [ 7: 0]  pio_out,
   output   [27: 0]  soft_nios_out_addr,
   output            soft_nios_out_burstcount,
   output   [ 3: 0]  soft_nios_out_byteenable,
   output            soft_nios_out_clk,
   output            soft_nios_out_read,
   output            soft_nios_out_reset_n,
   output            soft_nios_out_write,
   output   [31: 0]  soft_nios_out_write_data,
   input    [31: 0]  soft_nios_out_read_data,
   input             soft_nios_out_read_data_valid,
   input             soft_nios_out_waitrequest
);
   parameter interface_id = 0;
   parameter verbose_ioaux = "false";
   parameter sys_clk_source = "int_osc_clk";
   parameter sys_clk_div = 2;
   parameter cal_clk_div = 6;
   parameter config_hps = "false";
   parameter config_io_aux_bypass = "false";
   parameter config_power_down = "false";
   parameter [37:0] config_ram = 38'b0;
   parameter config_spare = 8'h00;
   parameter nios_code_hex_file = "";
   parameter nios_break_vector_word_addr = 16'h0000;
   parameter nios_exception_vector_word_addr = 16'h0000;
   parameter nios_reset_vector_word_addr = 16'h0000;
   parameter parameter_table_hex_file = "";
   parameter simulation_osc_freq_mhz = 800.0;
   parameter silicon_rev = "20nm5es";
   parameter mem_contents = "";
   parameter mem_contents_valid = "false";
   parameter mem_contents_updated  = "false";

twentynm_io_aux_encrypted inst (
   .core_clk(core_clk),
   .core_usr_reset_n(core_usr_reset_n),
   .debug_clk(debug_clk),
   .debug_select(debug_select),
   .mcu_en(mcu_en),
   .mode(mode),
   .soft_nios_addr(soft_nios_addr),
   .soft_nios_burstcount(soft_nios_burstcount),
   .soft_nios_byteenable(soft_nios_byteenable),
   .soft_nios_clk(soft_nios_clk),
   .soft_nios_read(soft_nios_read),
   .soft_nios_reset_n(soft_nios_reset_n),
   .soft_nios_write(soft_nios_write),
   .soft_nios_write_data(soft_nios_write_data),
   .soft_ram_clk(soft_ram_clk),
   .soft_ram_reset_n(soft_ram_reset_n),
   .soft_ram_read_data(soft_ram_read_data),
   .soft_ram_rdata_valid(soft_ram_rdata_valid),
   .soft_ram_waitrequest(soft_ram_waitrequest),
   .uc_read_data(uc_read_data),
   .usrmode(usrmode),
   .vji_cdr_to_the_hard_nios(vji_cdr_to_the_hard_nios),
   .vji_ir_in_to_the_hard_nios(vji_ir_in_to_the_hard_nios),
   .vji_rti_to_the_hard_nios(vji_rti_to_the_hard_nios),
   .vji_sdr_to_the_hard_nios(vji_sdr_to_the_hard_nios),
   .vji_tck_to_the_hard_nios(vji_tck_to_the_hard_nios),
   .vji_tdi_to_the_hard_nios(vji_tdi_to_the_hard_nios),
   .vji_udr_to_the_hard_nios(vji_udr_to_the_hard_nios),
   .vji_uir_to_the_hard_nios(vji_uir_to_the_hard_nios),
   .debug_out(debug_out),
   .soft_nios_read_data(soft_nios_read_data),
   .soft_nios_read_data_valid(soft_nios_read_data_valid),
   .soft_nios_waitrequest(soft_nios_waitrequest),
   .soft_ram_addr(soft_ram_addr),
   .soft_ram_burstcount(soft_ram_burstcount),
   .soft_ram_byteenable(soft_ram_byteenable),
   .soft_ram_debugaccess(soft_ram_debugaccess),
   .soft_ram_read(soft_ram_read),
   .soft_ram_rst_n(soft_ram_rst_n),
   .soft_ram_write(soft_ram_write),
   .soft_ram_write_data(soft_ram_write_data),
   .uc_address(uc_address),
   .uc_av_bus_clk(uc_av_bus_clk),
   .uc_read(uc_read),
   .uc_write(uc_write),
   .uc_write_data(uc_write_data),
   .vji_ir_out_from_the_hard_nios(vji_ir_out_from_the_hard_nios),
   .vji_tdo_from_the_hard_nios(vji_tdo_from_the_hard_nios),
   .pio_in(pio_in),
   .pio_out(pio_out),
   .soft_nios_out_addr(soft_nios_out_addr),
   .soft_nios_out_burstcount(soft_nios_out_burstcount),
   .soft_nios_out_byteenable(soft_nios_out_byteenable),
   .soft_nios_out_clk(soft_nios_out_clk),
   .soft_nios_out_read(soft_nios_out_read),
   .soft_nios_out_reset_n(soft_nios_out_reset_n),
   .soft_nios_out_write(soft_nios_out_write),
   .soft_nios_out_write_data(soft_nios_out_write_data),
   .soft_nios_out_read_data(soft_nios_out_read_data),
   .soft_nios_out_read_data_valid(soft_nios_out_read_data_valid),
   .soft_nios_out_waitrequest(soft_nios_out_waitrequest)
);
   defparam inst.interface_id = interface_id;
   defparam inst.verbose_ioaux = verbose_ioaux;
   defparam inst.sys_clk_source = sys_clk_source;
   defparam inst.sys_clk_div = sys_clk_div;
   defparam inst.cal_clk_div = cal_clk_div;
   defparam inst.config_hps = config_hps;
   defparam inst.config_io_aux_bypass = config_io_aux_bypass;
   defparam inst.config_power_down = config_power_down;
   defparam inst.config_ram_1 = config_ram[37:16];
   defparam inst.config_ram_0 = config_ram[15:0];
   defparam inst.config_spare = config_spare;
   defparam inst.nios_code_hex_file = nios_code_hex_file;
   defparam inst.nios_break_vector_word_addr = nios_break_vector_word_addr;
   defparam inst.nios_exception_vector_word_addr = nios_exception_vector_word_addr;
   defparam inst.nios_reset_vector_word_addr = nios_reset_vector_word_addr;
   defparam inst.parameter_table_hex_file = parameter_table_hex_file;
   defparam inst.simulation_osc_freq_mhz = simulation_osc_freq_mhz;
   defparam inst.silicon_rev = silicon_rev;
   defparam inst.mem_contents = mem_contents;
   defparam inst.mem_contents_valid = mem_contents_valid;
   defparam inst.mem_contents_updated = mem_contents_updated;

endmodule //twentynm_io_aux



module twentynm_ddio_in (
	input		clk,		// maps to capt_pej_clk, postive edge clock
	input 		areset,		// maps to aclr_n, async nclr
	input 		sreset,		// maps to sclr, synch clear
	input		ena,	// maps to clk_ena, clock enable
	input 		datain,	// maps to din, data in
	output		regoutlo,	// maps to dout, data out	
	output 		regouthi,
	input dfflo,
	input devpor,
	input clkn,
	input devclrn
);

//Parameters Declaration                                                        
parameter power_up = "low";                                                     
parameter async_mode = "none";                                                  
parameter sync_mode = "none";
parameter use_clkn = "false";

twentynm_ddio_in_encrypted inst (
	.clk(clk),
	.areset(areset),
	.sreset(sreset),
	.ena(ena),
	.datain(datain),
	.regoutlo(regoutlo),
	.regouthi(regouthi)
);

defparam inst.power_up = power_up;
defparam inst.async_mode = async_mode;
defparam inst.sync_mode = sync_mode;
defparam inst.use_clkn = use_clkn;

endmodule // twentynm_ddio_in

module twentynm_ddio_out (
      input     areset,		// maps to aclr_n, nreset
      input 	sreset,
      input     ena,       	// clk_enable
      input	clk,
      input     clkhi,           	// clock      
      input 	clklo,
      input	muxsel,
      input  	datainlo,        // maps to din, input data
      input 	datainhi,      
      output    dataout,        // maps to dout, output data
      input 	dfflo,
      input 	dffhi,
      input	devpor,
      input	hrbypass, //ADD_AV
      input	devclrn
);
parameter power_up = "low";
parameter async_mode = "none";
parameter sync_mode = "none";
parameter half_rate_mode = "false"; 

twentynm_ddio_out_encrypted inst (
	.clk(clk),
	.clkhi(clkhi),
	.clklo(clklo),
	.muxsel(muxsel),
	.areset(areset),
	.sreset(sreset),
	.ena(ena),
	.datainhi(datainhi),
	.datainlo(datainlo),
	.dataout(dataout)
);

defparam inst.power_up = power_up;
defparam inst.async_mode = async_mode;
defparam inst.sync_mode = sync_mode;
defparam inst.half_rate_mode = half_rate_mode;

endmodule // twentynm_ddio_out

