
module write_dc_fifo (
	data,
	wrreq,
	rdreq,
	wrclk,
	rdclk,
	aclr,
	q,
	rdempty,
	wrfull);	

	input	[108:0]	data;
	input		wrreq;
	input		rdreq;
	input		wrclk;
	input		rdclk;
	input		aclr;
	output	[108:0]	q;
	output		rdempty;
	output		wrfull;
endmodule