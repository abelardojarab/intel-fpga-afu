import ccip_avmm_pkg::*;
`include "platform_if.vh"
`include "afu_json_info.vh"

module csr_afu 
#(
    // DFH Offset
    parameter AFU_DFH           = 18'h00000,
    
    // Register Offsets
    parameter ID_L              = 18'h00002,
    parameter ID_H              = 18'h00004,
    parameter DFH_RSVD          = 18'h00006,
    parameter ETH_CTRL          = 18'h00008,
    parameter ERROR             = 18'h0000A,
    parameter SCRATCH           = 18'h0000C

)(
    input clk,
    input reset,

    input logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0] avmm_writedata,     // 64-bit
    input logic [CCIP_AVMM_MMIO_ADDR_WIDTH-1:0] avmm_address,       // 18-bit
    input logic avmm_write,
    input logic avmm_read,
    input logic [(CCIP_AVMM_MMIO_DATA_WIDTH/8)-1:0] avmm_byteenable,

    output logic avmm_waitrequest,
    output logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0] avmm_readdata,
    output logic avmm_readdatavalid
);
    
logic [127:0] afu_id = `AFU_ACCEL_UUID;
logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0] scratch_reg;
logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0] error;


always_ff @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            avmm_waitrequest    <= '0;
            avmm_readdata       <= '0;
            avmm_readdatavalid  <= '0;
            scratch_reg         <= '0;
            error               <= '0;
        end 
    else
    begin
        avmm_readdatavalid <= 1'b0;

        // Handle MMIO Reads
        if (avmm_read)
        begin
            case (avmm_address) inside
                AFU_DFH: begin
                    avmm_readdata <= {
                        4'b0001, // Feature type = AFU
                        8'b0,    // reserved
                        4'b0,    // afu minor revision = 0
                        7'b0,    // reserved
                        1'b0,    // end of DFH list = 0
                        24'h3FA,   // next DFH offset = 0
                        4'b0,    // afu major revision = 0
                        12'b0    // feature ID = 0
                    };
                    avmm_readdatavalid <= 1'b1;
                end
                AFU_DFH+ID_L: begin
                    avmm_readdata <= afu_id[63:0];
                    avmm_readdatavalid <= 1'b1;
                end

                AFU_DFH+ID_H: begin
                    avmm_readdata <= afu_id[127:64];
                    avmm_readdatavalid <= 1'b1;
                end

                AFU_DFH+DFH_RSVD: begin
                    avmm_readdata <= 64'h0;
                    avmm_readdatavalid <= 1'b1;
                end

                AFU_DFH+ERROR: begin
                    avmm_readdata <= error[63:0];
                    avmm_readdatavalid <= 1'b1;
                end

                // Scratch Register.  Return the last value written
                // to this MMIO address.
                AFU_DFH+SCRATCH: begin
                    avmm_readdata <= scratch_reg;
                    avmm_readdatavalid <= 1'b1;
                end

                default: begin
                    avmm_readdata  <= 64'h0;
                    avmm_readdatavalid <= 1'b1;
                end
            endcase
    
        // Handle MMIO Writes
        end else if (avmm_write)
        begin
            case (avmm_address) inside
                SCRATCH: begin
                    scratch_reg <= avmm_writedata;
                end
            endcase
        end
    end
end    
endmodule
