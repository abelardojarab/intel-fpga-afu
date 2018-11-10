//*****************************************************************************
//                      Intel. Corp.
//  File Name   :   i2c_contrl.v
//  Project     :   ethernet
//  Owner       :   Jinbo Yan
//  Create Date :   4/12/2016
//  Description :   loader the regs data and convert to bit
//  
//*****************************************************************************
//
module i2c_contrl(
////////////////////////////////////////////////////////////////////////////////////////
//                       Clock and Reset
////////////////////////////////////////////////////////////////////////////////////////
input 				clk,
input 				reset_n,
////////////////////////////////////////////////////////////////////////////////////////
//                       input regs interface
////////////////////////////////////////////////////////////////////////////////////////		
input [7:0]		    i2c_wdata,
input [7:0]		    i2c_control,
input 				cfg_trigger,
////////////////////////////////////////////////////////////////////////////////////////
//                         I2C interface
////////////////////////////////////////////////////////////////////////////////////////
input  				i2c_sda_i,
output  			i2c_sda_o,
output  			i2c_sda_e,
output 				i2c_sclk,
////////////////////////////////////////////////////////////////////////////////////////
//                        output  read data regs
////////////////////////////////////////////////////////////////////////////////////////		
output 	   [7:0]    i2c_status,
output reg [7:0]    i2c_rdata
);

////////////////////////////////////////////////////////////////////////////////////////
//                            Parameters 
////////////////////////////////////////////////////////////////////////////////////////
localparam	CLK_Freq	=	100_000000;	//100 MHz
localparam	I2C_Freq	=	400_000;	//100 KHz
////////////////////////////////////////////////////////////////////////////////////////
//                            Reg & Wire 
////////////////////////////////////////////////////////////////////////////////////////
reg [7:0] 	r_i2c_wdata;
reg [7:0] 	r_i2c_control;
reg 		r_st_trigger;
reg [15:0] 	r_wr_data_in;
reg	[15:0]	r_i2c_clk_div;	
reg			r_i2c_ctrl_clk;			
reg			r0_i2c_en;
reg 		r1_i2c_en;
reg			r_cfg_trigger;
reg 		r1_busy_flag;
reg 		r2_busy_flag;
reg         r_status_busy;

wire 		w_pos_busy_flag;
wire        w_neg_busy_flag;
wire 		w_ctrl_sclk_en;
wire 		w_trans_done;
wire 		w_rd_data_out_en;
wire [7:0]	w_rd_data_out;
wire 		w_busy_flag;
wire		w_ack_err;
/*---------------------------- body ----------------------*/
always@ (posedge clk or negedge reset_n)
  if(!reset_n)begin
	r_i2c_wdata	    <='d0;
	r_i2c_control   <='h0;
	r_cfg_trigger	<=1'b0;
  end
  else begin
	r_i2c_wdata     <=i2c_wdata;
	r_i2c_control   <=i2c_control;
	r_cfg_trigger   <=cfg_trigger;
  end

always @ (posedge clk or negedge reset_n)
  if(!reset_n)begin
	r_st_trigger<=1'b0;
	r_wr_data_in<=16'h10;	
  end
  else if(r_cfg_trigger &(!r_status_busy))begin
	r_st_trigger<=1'b1;
	r_wr_data_in<={r_i2c_wdata,r_i2c_control};		
  end
  else if(w_pos_busy_flag)begin
	r_st_trigger<=1'b0;	
  end
////////////generate busy flag///////////////////////////////////
always @ (posedge clk or negedge reset_n)
  if(!reset_n)begin
    r_status_busy<=1'b0;
  end
  else if(r_cfg_trigger & (!r_status_busy))begin
    r_status_busy<=1'b1;
  end
  else if(w_neg_busy_flag)begin
    r_status_busy<=1'b0;
  end


///////////generate	I2C Control Clock	//////////////////////////
always@(posedge clk or negedge reset_n)
  if(!reset_n)begin
	r_i2c_clk_div	<=	0;
	r_i2c_ctrl_clk	<=	0;
  end
  else begin
  if( r_i2c_clk_div	< (CLK_Freq/I2C_Freq)/2)
	r_i2c_clk_div	<=	r_i2c_clk_div + 1'd1;
  else begin
	r_i2c_clk_div	<=	0;
	r_i2c_ctrl_clk	<=	~r_i2c_ctrl_clk;
    end
  end

///////negedge i2c_sclk transfer data///////////////////////////
always@(posedge clk or negedge reset_n)
  if(!reset_n)begin
    r0_i2c_en <= 0;
    r1_i2c_en <= 0;
  end
  else begin
    r0_i2c_en <= r_i2c_ctrl_clk;
	r1_i2c_en <= r0_i2c_en;
  end

///////////////////////////output read data///////////////////////////////
always @ (posedge clk or negedge reset_n)
  if(!reset_n)begin
	i2c_rdata   <='h0;
  end
  else if(w_rd_data_out_en)begin
	i2c_rdata	<= w_rd_data_out;
  end

always @ (posedge clk or negedge reset_n)
  if(!reset_n)begin
	r1_busy_flag<=1'b0;
	r2_busy_flag<=1'b0;
  end
  else begin
	r1_busy_flag<=w_busy_flag;
	r2_busy_flag<=r1_busy_flag;	
  end

assign w_neg_busy_flag  =r1_busy_flag & ~w_busy_flag;	
assign w_pos_busy_flag  =~r2_busy_flag & r1_busy_flag;
assign w_ctrl_sclk_en   =(r1_i2c_en & ~r0_i2c_en) ? 1'b1 : 1'b0;	
assign i2c_status   	={6'b0,w_ack_err,r_status_busy}; 

trans_bit u_trans_bit
(
    .clk				(clk),				  //input 					
    .reset_n			(reset_n),			  //input 
    .ctrl_sclk			(r_i2c_ctrl_clk),	  //input			
    .ctrl_sclk_en		(w_ctrl_sclk_en),	  //input   				
    .wr_data_in			(r_wr_data_in),		  //input [15:0]	
    .ack_err_clr		(cfg_trigger),		  //input
    .st_trigger			(r_st_trigger),		  //input  					
    .i2c_sclk 			(i2c_sclk),			  //output 					
    .i2c_sda_i 			(i2c_sda_i),		  //input
    .i2c_sda_o 			(i2c_sda_o),		  //output
    .i2c_sda_e 			(i2c_sda_e),		  //output
    .ack_err			(w_ack_err),		  //output 
    .trans_done			(w_trans_done),		  //output 
    .busy_flag			(w_busy_flag),		  //output  				
    .rd_data_out_en	    (w_rd_data_out_en),   //output reg 			
    .rd_data_out		(w_rd_data_out)		  //output reg [7:0]
); 

endmodule

