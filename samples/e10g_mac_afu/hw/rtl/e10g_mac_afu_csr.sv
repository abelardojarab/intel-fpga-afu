import ccip_avmm_pkg::*;
`include "platform_if.vh"
`include "afu_json_info.vh"

module e10g_mac_afu_csr 
#(
    parameter AFU_DFH   = 18'h00000,
    parameter AFU_ID_L  = 18'h00002,
    parameter AFU_ID_H  = 18'h00004,
    parameter DFH_RSVD  = 18'h00006,
    parameter ETH_CTRL  = 18'h00008,
    parameter PKT_GEN   = 18'h0000A,
    parameter PKT_MON   = 18'h0000C,
    parameter ERROR     = 18'h0000F,
    parameter SCRATCH   = 18'h00020,      // Return the last value written to this MMIO address.
    parameter MAC_CSR_L = 18'h00400,
    parameter MAC_CSR_H = 18'h009FF

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
    output logic avmm_readdatavalid,

    output logic [31:0] mac_csr_writedata,
    output logic [15:0] mac_csr_address,
    output logic mac_csr_write,
    output logic mac_csr_read,
    input logic [31:0] mac_csr_readdata,
    input logic mac_csr_readdatavalid,
    input logic mac_csr_waitrequest
);
    
logic [127:0] afu_id = `AFU_ACCEL_UUID;
logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0] scratch_reg;

always_ff @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            avmm_waitrequest    <= '0;
            avmm_readdata       <= '0;
            avmm_readdatavalid  <= '0;
            scratch_reg         <= '0;
            mac_csr_writedata   <= '0;
            mac_csr_address     <= '0;
            mac_csr_write       <= '0;
            mac_csr_read        <= '0;
        end 
    else
    begin
        // TODO: this is fishy
        avmm_waitrequest <= mac_csr_waitrequest;
        avmm_readdata    <= {32'b0, mac_csr_readdata};

        if (avmm_readdatavalid)
            avmm_readdatavalid <= 1'b0;
        else 
            avmm_readdatavalid <= mac_csr_readdatavalid;

        mac_csr_read <= 1'b0;

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
                        1'b1,    // end of DFH list = 1
                        24'b0,   // next DFH offset = 0
                        4'b0,    // afu major revision = 0
                        12'b0    // feature ID = 0
                    };
                    avmm_readdatavalid <= 1'b1;
                end
                AFU_ID_L: begin
                    avmm_readdata <= afu_id[63:0];
                    avmm_readdatavalid <= 1'b1;
                end

                AFU_ID_H: begin
                    avmm_readdata <= afu_id[127:64];
                    avmm_readdatavalid <= 1'b1;
                end

                DFH_RSVD: begin
                    avmm_readdata <= 64'h0;
                    avmm_readdatavalid <= 1'b1;
                end

                // Scratch Register.  Return the last value written
                // to this MMIO address.
                SCRATCH: begin
                    avmm_readdata <= scratch_reg;
                    avmm_readdatavalid <= 1'b1;
                end

                [MAC_CSR_L : MAC_CSR_H]: begin
                    mac_csr_address <= avmm_address[15:0];
                    mac_csr_read <= 1'b1;
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

                [MAC_CSR_L : MAC_CSR_H]: begin
                    mac_csr_write <= 1'b1;
                    mac_csr_writedata <= avmm_writedata[31:0];
                end
            endcase
        end
    end
end    
endmodule
