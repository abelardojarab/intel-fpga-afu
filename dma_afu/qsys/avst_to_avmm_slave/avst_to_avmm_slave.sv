module avst_to_avmm_slave #(
	parameter AVMM_ADDR_WIDTH = 18,
	parameter AVMM_DATA_WIDTH = 64
	)
	(
	input clk,
	input reset,

	input [AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+2-1:0] in_data,
    input in_valid,
    output logic in_ready,

    output logic 	[AVMM_DATA_WIDTH-1:0] out_data,
    output logic out_valid,
    input out_ready,

	input		avmm_waitrequest,
	input	[AVMM_DATA_WIDTH-1:0]	avmm_readdata,
	input		avmm_readdatavalid,
	output logic 	[0:0]	avmm_burstcount,
	output logic 	[AVMM_DATA_WIDTH-1:0]	avmm_writedata,
	output logic 	[AVMM_ADDR_WIDTH-1:0]	avmm_address,
	output logic 		avmm_write,
	output logic 		avmm_read,
	output logic 	[(AVMM_DATA_WIDTH/8)-1:0]	avmm_byteenable
);

	localparam INPUT_AVST_WIDTH = AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+2;
	localparam AVMM_BYTE_ENABLE_WIDTH=(AVMM_DATA_WIDTH/8);

	typedef struct packed { 
		logic is_read;
		logic is_32bit;
		logic [AVMM_ADDR_WIDTH-1:0] addr;
		logic [AVMM_DATA_WIDTH-1:0] write_data;
    } t_avst_input; 

    t_avst_input avst_input_data;
    assign avst_input_data = in_data;

    assign avmm_byteenable = avst_input_data.is_32bit ? 
    	(avst_input_data.addr[2] ? 8'b11110000 : 8'b00001111) : 8'b11111111;

	//read/write request
    assign avmm_address = avst_input_data.addr;
    assign avmm_writedata = avst_input_data.write_data;
	assign avmm_burstcount = 1'b1;

	assign in_ready = !reset & !avmm_waitrequest;	
    wire avmm_ready = !reset & (!avmm_waitrequest && in_valid);
    assign avmm_write = avmm_ready & !avst_input_data.is_read;
    assign avmm_read = avmm_ready & avst_input_data.is_read;

	//handle read response
	assign out_data = avmm_readdata;
	assign out_valid = reset ? 1'b0 : avmm_readdatavalid;
	
endmodule