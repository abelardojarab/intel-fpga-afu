//*****************************************************************************
//                      Intel. Corp.
//  File Name   :   trans_bit.v
//  Project     :   ethernet
//  Owner       :   Jinbo Yan
//  Create Date :   4/12/2016
//  Description :   Parallel data convert to serial data
//  
//*****************************************************************************
//
module trans_bit(
    ////////////////////////////////////////////////////////////////////////////////////////
    //                       Clock and Reset
    ////////////////////////////////////////////////////////////////////////////////////////
	input 					clk,
	input 					reset_n,
    ////////////////////////////////////////////////////////////////////////////////////////
    //                       input signal interface
    ////////////////////////////////////////////////////////////////////////////////////////				
	input 					ack_err_clr,
	input 					st_trigger,
	input 					ctrl_sclk,
	input   				ctrl_sclk_en,
	input [15:0]		    wr_data_in,
    ////////////////////////////////////////////////////////////////////////////////////////
    //                         I2C interface
    ////////////////////////////////////////////////////////////////////////////////////////			
	output 					i2c_sclk,
	input 					i2c_sda_i,
	output 					i2c_sda_o,
	output 					i2c_sda_e,
    ////////////////////////////////////////////////////////////////////////////////////////
    //                       input signal interface
    ////////////////////////////////////////////////////////////////////////////////////////				
	output 					ack_err,
	output 					trans_done,
    output                  busy_flag,
	output reg 			    rd_data_out_en,
	output reg [7:0]        rd_data_out
	);
////////////////////////////////////////////////////////////////////////////////////////
//                            Reg & Wire 
////////////////////////////////////////////////////////////////////////////////////////
reg [5:0]    r_op_cnt;
reg [7:0]    r_wr_data_in;
reg [7:0]    r_rd_dat;
reg 		 r_i2c_sclk;
reg 		 r_i2c_sda;
reg 		 r_finish;
reg 		 r1_finish;
reg 		 r_i2c_ack;
reg 		 r_st_trigger;
reg          r_rd_wr_flag;
reg 		 r_start_flag;
reg 		 r_ack_flag;
reg 		 r_stop_flag;
reg 		 r_ack_err;

wire 		 w_sdo_wr;
wire  	     w_sdo_rd;
wire  	     w_sdo;
wire  	     w_pos_finish;
/*---------------------------- body ----------------------*/
always @(posedge clk or negedge reset_n)
  if(!reset_n)begin
	r_wr_data_in	<=8'd0;
	r1_finish		<=1'b0;
	r_rd_wr_flag	<=1'b1;//default:1:wr 0:rd
	r_start_flag	<=1'b1;//default:start
	r_ack_flag		<=1'b1;//default:ack
	r_stop_flag		<=1'b1;//default:stop
	r_st_trigger	<=1'b0;
  end
  else begin
	r_wr_data_in    <=wr_data_in[15:8];
	r1_finish		<=r_finish;
	r_st_trigger    <=st_trigger;
	r_rd_wr_flag    <=wr_data_in[1];//1'd1
	r_start_flag    <=wr_data_in[2];//1'b1
	r_ack_flag	    <=wr_data_in[3];//1'b1
	r_stop_flag	    <=wr_data_in[4];//1'b1
  end
		
//I2C Transfer
always @(posedge clk or negedge reset_n) 
  if(!reset_n) begin 
	r_i2c_sclk  <=1'b1;
	r_i2c_sda	<=1'b1; 
	r_rd_dat	<=8'd0;
	r_i2c_ack	<=1'b1;
	r_op_cnt	<=6'd0;
	r_finish	<=1'b0;
	r_rd_dat	<=8'd0;
  end
  else if(ctrl_sclk_en)	begin	//data change enable	
	if(r_rd_wr_flag)begin //1:write 0:read 
		case(r_op_cnt)
				//IDLE
				6'd0 :begin
							r_i2c_ack	<=1'b1;
							r_finish	<=1'b0;
							r_rd_dat	<=8'd0;
							if(r_start_flag && r_st_trigger)
								r_op_cnt<=6'd1;//START
							else if((!r_start_flag) && r_st_trigger)
								r_op_cnt<=6'd4;//TRANS_BIT							
					  end
				//Start
				6'd1 :begin 
							r_i2c_sclk<=1'b1;
							r_i2c_sda	<=1'b1;
							r_op_cnt	<=6'd2;
					    end
				6'd2 :begin 
							r_i2c_sda <=0;		//i2c_sdat = 0
							r_op_cnt	<=6'd3;	
						end
				6'd3 :begin
							r_i2c_sclk<= 0;			//i2c_sclk = 0
							r_op_cnt	<=6'd4;
						end
				//DATA TRANSFE
				6'd4 :begin
							r_i2c_sda <= r_wr_data_in[7];	//Bit8
							r_i2c_sclk <= 0;
							r_op_cnt<=6'd5;
						end	
				6'd5 :begin
							r_i2c_sda <= r_wr_data_in[6];	//Bit7
							r_op_cnt<=6'd6;
						end
				6'd6  :begin
							r_i2c_sda <= r_wr_data_in[5];	//Bit6
							r_op_cnt<=6'd7;		
						end		
				6'd7  :begin
							r_i2c_sda <= r_wr_data_in[4];	//Bit5
							r_op_cnt<=6'd8;	
						end								
				6'd8 :begin
							r_i2c_sda <= r_wr_data_in[3];	//Bit4
							r_op_cnt<=6'd9;
						end
				6'd9  :begin
							r_i2c_sda <= r_wr_data_in[2];	//Bit3
							r_op_cnt<=6'd10;	
						end	
				6'd10 :begin
							r_i2c_sda <= r_wr_data_in[1];	//Bit2
							r_op_cnt<=6'd11;	
						end	
				6'd11 :begin
							r_i2c_sda <= r_wr_data_in[0];	//Bit1
							r_op_cnt<=6'd12;	//r_state<=ACK;
						end
				//ACK
				6'd12 :begin
							 r_i2c_sda <= 0;				//High-Z, Input
							 r_op_cnt<=6'd13;
						end
				6'd13 :begin
							r_i2c_ack<= i2c_sda_i;
							r_op_cnt<=6'd14;	
						end
				6'd14 :begin
							r_i2c_sda <= 0;				//Delay
							if(r_stop_flag | r_i2c_ack) 
								r_op_cnt<=6'd15;//r_state<=STOP;
							else if(!r_stop_flag)begin
								r_op_cnt<=6'd0;//r_state<=IDLE;
								r_finish<=1'b1;
							end
						end
				//Stop
				6'd15 : begin	
							r_i2c_sclk <=0; 
							r_i2c_sda <= 0; 
							r_op_cnt<=6'd16;
						end
				6'd16 : begin
							r_i2c_sclk <= 1;
							r_op_cnt<=6'd17;	
						end	
				6'd17 : begin
							r_i2c_sda <= 1;
							r_finish<=1'b1;
							r_op_cnt<=6'd0;
						end
				default : begin 
							r_i2c_sda <= 1; 
							r_i2c_sclk<= 1;
							r_finish<=1'b0;
							r_op_cnt<=6'd0;										
						end
				endcase
			end				
	else begin //read data
		case(r_op_cnt)
				//IDLE
				6'd0 :begin
							r_finish	<=1'b0;
							r_rd_dat	<=8'd0;
							if(r_start_flag && r_st_trigger)
								r_op_cnt<=6'd1;//START
							else if((!r_start_flag) && r_st_trigger)
								r_op_cnt<=6'd4;//TRANS						
						end
				//Start
				6'd1 :begin 
							r_i2c_sclk<=1'b1;
							r_i2c_sda <=1'b1;
							r_op_cnt  <=6'd2;
						end
				6'd2 :begin 
							r_i2c_sda <=0;		//i2c_sdat = 0
							r_op_cnt  <=6'd3;	
						end
				6'd3 :begin
							r_i2c_sclk <= 0;	//i2c_sclk = 0
							r_op_cnt   <=6'd4;
						end				
				//DATA TRANSFE
				6'd4 :begin
							 r_i2c_sda <= 0;
							 r_i2c_sclk <=0;
							 r_op_cnt<=6'd5;
						end
				6'd5 :begin
							r_rd_dat[7]<=i2c_sda_i;//Bit7
							r_op_cnt<=6'd6;
						end
				6'd6 :begin
							r_rd_dat[6]<=i2c_sda_i;	
							r_op_cnt<=6'd7;
						end
				6'd7 :begin
							r_rd_dat[5]<=i2c_sda_i;
							r_op_cnt<=6'd8;
						end
				6'd8 :begin
							r_rd_dat[4]<=i2c_sda_i;
							r_op_cnt<=6'd9;
						end
				6'd9 :begin
							r_rd_dat[3]<=i2c_sda_i;
							r_op_cnt<=6'd10;
						end
				6'd10 : begin
							r_rd_dat[2]<=i2c_sda_i;
							r_op_cnt<=6'd11;
						end
				6'd11 : begin
							r_rd_dat[1]<=i2c_sda_i;
							r_op_cnt<=6'd12;
						end
				6'd12 : begin
							r_rd_dat[0]<=i2c_sda_i;
							r_op_cnt<=6'd13;
						end
				//ACK							
				6'd13 : begin
							r_op_cnt<=6'd14;
                            if(r_ack_flag)
							    r_i2c_sda <=1'b0;
                            else
                                r_i2c_sda <=1'b1;
						end
				6'd14 : begin
							r_i2c_sda <= 0;				//Delay
							if(r_stop_flag)
							    r_op_cnt<=6'd15;
							else begin
								r_op_cnt<=6'd0;//r_state<=IDLE;
								r_finish<=1'b1;
								end
						end
				//Stop
				6'd15 : begin	
							r_i2c_sclk <= 0;
							r_i2c_sda <= 0; 
							r_op_cnt<=6'd16;
						end
				6'd16 : begin
							r_i2c_sclk <= 1;
							r_op_cnt<=6'd17;
						end
				6'd17 : begin
							r_i2c_sda <= 1;
							r_finish<=1'b1;
							r_op_cnt<=6'd0;									
						end	
				default : begin 
							r_i2c_sda <= 1; 
							r_i2c_sclk <=1;
							r_finish<=1'b0;
							r_op_cnt<=6'd0;										
							end
		endcase			
		end
  end	
/////////////////////output read data/////////////////////////////////////////			
always @ (posedge clk or negedge reset_n)
  if(!reset_n)begin
	rd_data_out<=8'd0;
	rd_data_out_en<=1'b0;
  end 
  else if(w_pos_finish & (!r_rd_wr_flag))begin
	rd_data_out<=r_rd_dat;
	rd_data_out_en<=1'b1;
  end
  else begin
	rd_data_out<=8'd0;
	rd_data_out_en<=1'b0;
  end

always @ (posedge clk or negedge reset_n)
  if(!reset_n)begin
	r_ack_err<=1'b0;
  end
  else if(ack_err_clr)begin
	r_ack_err<=1'b0;
  end
  else if(ctrl_sclk_en && (r_rd_wr_flag) && (r_i2c_ack!=1'b0) && r_finish)begin
    r_ack_err<=1'b1;
  end

		
assign  ack_err         =r_ack_err;
assign  trans_done      =r_finish;	
assign  w_pos_finish    =~r1_finish & r_finish;	
assign 	i2c_sclk        =((r_op_cnt>=5 && r_op_cnt<=12) || (r_op_cnt==14)) ? ctrl_sclk : r_i2c_sclk;
assign  w_sdo_wr        =(r_op_cnt==13|| r_op_cnt==14) ? 1'b0 :1'b1;
assign  w_sdo_rd        =(r_op_cnt>=4 && r_op_cnt<=12) ? 1'b0 :1'b1;
assign  w_sdo           =(r_rd_wr_flag) ? w_sdo_wr : w_sdo_rd;
assign  i2c_sda_o       =r_i2c_sda;
assign  i2c_sda_e       =w_sdo; 
assign  busy_flag       =((r_op_cnt>=1 && r_op_cnt<=17)||r_finish) ? 1'b1 :1'b0;
endmodule
