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


`timescale 1ps/1ps

module alt_e100s10_am #(
    parameter   SIM_EMULATE = 1'b0,
    parameter   SIM_SHORT_AM = 1'b0,
    parameter   SYNOPT_C4_RSFEC = 0,
    parameter   SYNOPT_LINK_FAULT = 0
)(

    input           clk,
    input           sclr,
    input           tx_crc_ins_en,
    input           enable_rsfec,
    output          tx_am_mac,
    output  reg     tx_am_pcs

);

wire    insert_am, tx_pulse4;
wire    insert_am_rsfec, insert_am_no_rsfec;

generate
    if (SIM_SHORT_AM) begin
            if (SYNOPT_C4_RSFEC==0) begin
	       alt_e100s10_metronome2560 mt0 (
	            .clk    (clk),
	            .sclr   (sclr),
	            .dout   (insert_am)
	        );
	        defparam mt0 .SIM_EMULATE = SIM_EMULATE;
            end
            else begin

            reg [10:0] cnt_319;

            alt_e100s10_metronome2560 mt0 (
	            .clk    (clk),
	            .sclr   (sclr),
	            .dout   (insert_am_no_rsfec)
	    );
	    defparam mt0 .SIM_EMULATE = SIM_EMULATE;

            always @(posedge clk or posedge sclr) begin
                if (sclr) begin 
                  cnt_319 <= 0;
                end
                else begin
                  cnt_319 <= (cnt_319!=11'd319) ? (cnt_319 + 1): 0;
                end
            end
            assign insert_am_rsfec = (cnt_319==11'd319);

            assign insert_am = (enable_rsfec == 1) ? insert_am_rsfec : insert_am_no_rsfec;
            end
    end 
    else begin
	wire	insert_am_org;
        alt_e100s10_metronome81920 mt0 (
            .clk    (clk),
            .sclr   (sclr),
            .dout   (insert_am_org)
        );
        defparam mt0 .SIM_EMULATE = SIM_EMULATE;

	if (SYNOPT_C4_RSFEC==1) begin
		reg sclr_r;
		always @(posedge clk) sclr_r <= sclr;
		assign insert_am = (enable_rsfec == 1) ? insert_am_org & !sclr_r : insert_am_org;
	end else begin
		assign insert_am = insert_am_org;
	end

    end
endgenerate


alt_e100s10_pulse4 p1 (
    .clk        (clk),
    .din        (insert_am),
    .dout       (tx_pulse4)

);
defparam p1 .SIM_EMULATE = SIM_EMULATE;


reg tx_am;
always @(posedge clk)   tx_am   <=  insert_am | tx_pulse4;

assign  tx_am_mac = tx_am;
wire    delay_reg_out;

reg [17:0]  delay_reg ;
generate 
if (SYNOPT_LINK_FAULT==0) begin : LINK_FAULT_0
   always @(posedge clk) delay_reg <=  {delay_reg[14:0], tx_am};
   assign delay_reg_out = delay_reg[14];
   end
else begin : LINK_FAULT_1
   always @(posedge clk) delay_reg <=  {delay_reg[16:0], tx_am};
   assign delay_reg_out = delay_reg[17];
   end
endgenerate


always @(posedge clk) begin
    if (tx_crc_ins_en) 
        //tx_am_pcs   <= delay_reg[14];     
        tx_am_pcs   <= delay_reg_out;     
    else
        tx_am_pcs   <= delay_reg[3];
end

endmodule
