
import ccip_if_pkg::*;
import cci_mpf_csrs_pkg::*;

module ccip_avmm_mmio #(
	parameter AVMM_ADDR_WIDTH = 16,
	parameter AVMM_DATA_WIDTH = 64
	)
	
	(
	input clk,
	input	SoftReset,

	output logic [AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+2-1:0] in_data,
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
	localparam INPUT_AVST_WIDTH = AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+2;
	localparam TID_FIFO_WIDTH = CCIP_TID_WIDTH+1;

	typedef struct packed { 
		logic is_read;
		logic is_32bit;
		logic [AVMM_ADDR_WIDTH-1:0] addr;
		logic [AVMM_DATA_WIDTH-1:0] write_data;
    } t_avst_input;
    
    t_avst_input avst_input_data;
    assign in_data = avst_input_data;

	// cast c0 header into ReqMmioHdr
	t_ccip_c0_ReqMmioHdr mmioHdr;
	assign mmioHdr = t_ccip_c0_ReqMmioHdr'(ccip_c0_Rx_port.hdr);
	wire mmio32_req = (mmioHdr.length == 2'b00);
	wire mmio32_highword_req = mmio32_req & mmioHdr.address[0];
	
	logic tid_fifo_wrreq;
	logic tid_fifo_rdreq;
	logic [TID_FIFO_WIDTH-1:0] tid_fifo_input;
	wire [TID_FIFO_WIDTH-1:0] tid_fifo_output;
	
	wire fifo_mmio32_highword_req = tid_fifo_output[TID_FIFO_WIDTH-1];
	
	wire mmio_address_valid = !(mmioHdr.address >= 16'h800 && mmioHdr.address < (16'h800+CCI_MPF_MMIO_SIZE/4));
	
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
        tid_fifo_inst.lpm_width  = TID_FIFO_WIDTH,
        tid_fifo_inst.lpm_widthu  = 6,
        tid_fifo_inst.overflow_checking  = "ON",
        tid_fifo_inst.underflow_checking  = "ON",
        tid_fifo_inst.use_eab  = "ON";
	
	always_ff @(posedge clk)
	begin
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
			if(ccip_c0_Rx_port.mmioWrValid && mmio_address_valid) begin
				avst_input_data.addr <= {mmioHdr.address, 2'b00};
				avst_input_data.write_data[31:0] <= ccip_c0_Rx_port.data[31:0];
				avst_input_data.write_data[63:32] <= mmio32_highword_req ? ccip_c0_Rx_port.data[31:0] : ccip_c0_Rx_port.data[63:32];
				avst_input_data.is_read <= 1'b0;
				avst_input_data.is_32bit <= mmio32_req;
				in_valid <= 1'b1;
			end
			// serve MMIO read requests
			if(ccip_c0_Rx_port.mmioRdValid && mmio_address_valid) begin
				tid_fifo_input <= {mmio32_highword_req, mmioHdr.tid}; // copy TID
				tid_fifo_wrreq <= '1;
				avst_input_data.addr <= {mmioHdr.address, 2'b00};
				avst_input_data.is_read <= 1'b1;
				avst_input_data.is_32bit <= mmio32_req;
				in_valid <= 1'b1;
			end
		  
			if(out_valid == 1'b1) begin
				tid_fifo_rdreq <= '1;
				ccip_c2_Tx_port.hdr.tid <= tid_fifo_output[CCIP_TID_WIDTH-1:0];
				ccip_c2_Tx_port.data[31:0] <= fifo_mmio32_highword_req ? out_data[63:32] : out_data[31:0];
				ccip_c2_Tx_port.data[63:32] <= out_data[63:32];
				ccip_c2_Tx_port.mmioRdValid <= 1; // post response
			end
		end
	end

endmodule
