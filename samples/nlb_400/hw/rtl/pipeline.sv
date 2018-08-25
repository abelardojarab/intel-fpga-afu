module pipeline #(
   parameter WIDTH = 1,
	parameter STAGE = 1
) (
   input logic clk,
   input logic [WIDTH-1:0] din,
	output logic [WIDTH-1:0] dout
);

genvar ig;
generate
   if (STAGE > 1) begin    
	   logic [WIDTH-1:0] q[STAGE-1:0];		
		
		for (ig=0;ig<STAGE-1;ig=ig+1) begin : pipe
		   always_ff @(posedge clk) begin
			   if (ig == 0) begin
				   q[ig] <= din;
				end
		      q[ig+1] <= q[ig];					
         end	
		end
		
		always_comb begin
		   dout = q[STAGE-1];
      end	
	end else begin 
      logic [WIDTH-1:0] q;
      always_ff @(posedge clk) begin
		   q <= din;
		end
		always_comb begin
   		dout = q;	
		end
	end
endgenerate

endmodule