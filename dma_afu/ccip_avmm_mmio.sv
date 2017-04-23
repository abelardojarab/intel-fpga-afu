
import ccip_if_pkg::*;

module ccip_avmm_mmio #(
	parameter AVMM_ADDR_WIDTH = 16,
	parameter AVMM_DATA_WIDTH = 64
	)
	
	(
	input clk,
	input	SoftReset,

	output logic [AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+1-1:0] in_data,
    output logic in_valid,
    input in_ready,
             
    input [AVMM_DATA_WIDTH-1:0] out_data,
    input out_valid,
    output logic out_ready,
	
	// ---------------------------IF signals between CCI and AFU  --------------------------------
	//input	t_if_ccip_Rx    cp2af_sRxPort,
	input t_if_ccip_c0_Rx ccip_c0_Rx_port,
	//output	t_if_ccip_Tx	af2cp_sTxPort
	output t_if_ccip_c2_Tx ccip_c2_Tx_port
);
	localparam INPUT_AVST_WIDTH = AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+1;

	typedef struct packed { 
		logic is_read;
		logic [AVMM_ADDR_WIDTH-1:0] addr;
		logic [AVMM_DATA_WIDTH-1:0] write_data;
    } t_avst_input;
    
    t_avst_input avst_input_data;
    assign in_data = avst_input_data;

	// cast c0 header into ReqMmioHdr
	t_ccip_c0_ReqMmioHdr mmioHdr;
	assign mmioHdr = t_ccip_c0_ReqMmioHdr'(ccip_c0_Rx_port.hdr);
	
	
	logic tid_fifo_wrreq;
	logic tid_fifo_rdreq;
	logic [CCIP_TID_WIDTH-1:0] tid_fifo_input;
	wire [CCIP_TID_WIDTH-1:0] tid_fifo_output;
	
	scfifo  tid_fifo_inst (
		.data(tid_fifo_input),
		.q(tid_fifo_output),
		.sclr(SoftReset),
		.clock(clk),
		.wrreq(tid_fifo_wrreq),
		.rdreq(tid_fifo_rdreq),
		.aclr (),
		.almost_empty (),
		.almost_full (),
		.eccstatus (),
		.empty (),
		.full (),
		.usedw ()
	);
    defparam
        tid_fifo_inst.add_ram_output_register  = "OFF",
        tid_fifo_inst.enable_ecc  = "FALSE",
        tid_fifo_inst.intended_device_family  = "Arria 10",
        tid_fifo_inst.lpm_numwords  = 64,
        tid_fifo_inst.lpm_showahead  = "ON",
        tid_fifo_inst.lpm_type  = "scfifo",
        tid_fifo_inst.lpm_width  = CCIP_TID_WIDTH,
        tid_fifo_inst.lpm_widthu  = 6,
        tid_fifo_inst.overflow_checking  = "ON",
        tid_fifo_inst.underflow_checking  = "ON",
        tid_fifo_inst.use_eab  = "ON";
	
	always@(posedge clk) begin
		tid_fifo_wrreq <= '0;
		tid_fifo_rdreq <= '0;
		tid_fifo_input <= '0;
		
		ccip_c2_Tx_port.hdr        <= '0;
		ccip_c2_Tx_port.data       <= '0;
		ccip_c2_Tx_port.mmioRdValid <= '0;
		
		avst_input_data <= '0;
		in_valid <= '0;
		out_ready <= '1;
		avst_input_data <= '0;
		
		if(SoftReset) begin
			tid_fifo_wrreq <= '0;
			tid_fifo_rdreq <= '0;
			tid_fifo_input <= '0;
			
			ccip_c2_Tx_port.hdr        <= '0;
			ccip_c2_Tx_port.data       <= '0;
			ccip_c2_Tx_port.mmioRdValid <= '0;
			
			avst_input_data <= '0;
			in_valid <= '0;
			out_ready <= '0;
		end
		else begin
			ccip_c2_Tx_port.mmioRdValid <= 0;
			// set the registers on MMIO write request
			if(ccip_c0_Rx_port.mmioWrValid == 1) begin
				avst_input_data.addr <= (mmioHdr.address)<<2;
				avst_input_data.write_data <= ccip_c0_Rx_port.data[63:0];
				avst_input_data.is_read <= 1'b0;
				in_valid <= 1'b1;
				$display("DCP_DEBUG: wr avmm=%x ccip=%x\n", (mmioHdr.address)<<2, mmioHdr.address);
			end
			// serve MMIO read requests
			if(ccip_c0_Rx_port.mmioRdValid == 1) begin
				tid_fifo_input <= mmioHdr.tid; // copy TID
				tid_fifo_wrreq <= '1;
				avst_input_data.addr <= (mmioHdr.address)<<2;
				avst_input_data.is_read <= 1'b1;
				in_valid <= 1'b1;
				$display("DCP_DEBUG: rd tid=%d avmm_address=%x ccip=%x\n", mmioHdr.tid, (mmioHdr.address)<<2, mmioHdr.address);
			end
		  
			if(out_valid == 1'b1) begin
				tid_fifo_rdreq <= '1;
				ccip_c2_Tx_port.hdr.tid <= tid_fifo_output;
				ccip_c2_Tx_port.data <= out_data;
				$display("DCP_DEBUG: rd resp tid=%d out_data=%x\n", tid_fifo_output, out_data);
				ccip_c2_Tx_port.mmioRdValid <= 1; // post response
			end
		end
	end

endmodule
