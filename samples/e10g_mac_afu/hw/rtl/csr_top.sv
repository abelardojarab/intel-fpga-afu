import ccip_avmm_pkg::*;
`include "platform_if.vh"
`include "afu_json_info.vh"

module csr_top 
#(
    // Widths
    parameter MAC_AVMM_DATA_WIDTH       = 32,
    parameter CLIENT_AVMM_DATA_WIDTH    = 512,
    parameter MAC_AVMM_ADDR_WIDTH       = 16,
    parameter CLIENT_AVMM_ADDR_WIDTH    = 16,

    // DFH Offsets
    parameter AFU_DFH           = 18'h00000,
    parameter MAC_DFH           = 18'h00400,
    parameter CLIENT_DFH        = 18'h01000,
    parameter NULL_DFH          = 18'h01100,

    // Register Offsets
    parameter ID_L              = 18'h00002,
    parameter ID_H              = 18'h00004,
    parameter DFH_RSVD          = 18'h00006,
    parameter AFU_CTRL          = 18'h00008,
    parameter AFU_ERROR         = 18'h0000A,
    parameter AFU_SCRATCH       = 18'h0000C

)(
    input clk,
    input reset,

    // CCIP/AVMM interface to host
    output logic avmm_waitrequest,
    output logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0] avmm_readdata,     // 64-bit
    output logic avmm_readdatavalid,

    // CCIP/AVMM interface from host
    input logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0] avmm_writedata,     // 64-bit
    input logic [CCIP_AVMM_MMIO_ADDR_WIDTH-1:0] avmm_address,       // 18-bit
    input logic avmm_write,
    input logic avmm_read,
    input logic [(CCIP_AVMM_MMIO_DATA_WIDTH/8)-1:0] avmm_byteenable,// 8-bit

    // AVMM interface to MAC
    output logic [MAC_AVMM_DATA_WIDTH-1:0] mac_csr_writedata,
    output logic [MAC_AVMM_ADDR_WIDTH-1:0] mac_csr_address,
    output logic mac_csr_write,
    output logic mac_csr_read,

    // AVMM interface from MAC
    input logic [MAC_AVMM_DATA_WIDTH-1:0] mac_csr_readdata,
    input logic mac_csr_readdatavalid,
    input logic mac_csr_waitrequest,    
    
    // AVMM interface to Client
    output logic [CLIENT_AVMM_DATA_WIDTH-1:0] client_csr_writedata,
    output logic [CLIENT_AVMM_ADDR_WIDTH-1:0] client_csr_address,
    output logic client_csr_write,
    output logic client_csr_read,

    // AVMM interface from Client
    input logic [CLIENT_AVMM_DATA_WIDTH-1:0] client_csr_readdata,
    input logic client_csr_readdatavalid,
    input logic client_csr_waitrequest
);

logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0] avmm_readdata_out;
logic avmm_readdatavalid_out;

logic [127:0] afu_uuid = `AFU_ACCEL_UUID;
logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0] scratch_reg;
logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0] error;
logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0] afu_ctrl;

logic [127:0] mac_uuid = 128'h2134dca06beb4cddafb157de7ccc0d42; 
logic [127:0] client_uuid = 128'hdf834523d43446bdae4118efda07589d; 
logic [127:0] null_uuid = 128'haf744f15130ab6c156722e4e1a5e4b0f; 
logic [17:0] afu_len = '0;
logic [17:0] mac_len = '0;
logic [17:0] client_len = '0;

always_comb begin
    // Calculate byte address length
    afu_len = 4*MAC_DFH-4*AFU_DFH;
    mac_len = 4*CLIENT_DFH-4*MAC_DFH;
    client_len = 4*NULL_DFH-4*CLIENT_DFH;
end

always_ff @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            avmm_waitrequest        <= '0;
            avmm_readdata           <= '0;
            avmm_readdatavalid      <= '0;
            mac_csr_writedata       <= '0;
            mac_csr_address         <= '0;
            mac_csr_write           <= '0;
            mac_csr_read            <= '0;
            client_csr_writedata    <= '0;
            client_csr_address      <= '0;
            client_csr_write        <= '0;
            client_csr_read         <= '0;

            avmm_readdata_out       <= '0;
            avmm_readdatavalid_out  <= '0;
            scratch_reg             <= '0;
            error                   <= '0;
            afu_ctrl                <= '0;
        end 
    else
    begin
        // set readvalid back to 0
        avmm_readdatavalid_out <= '0;

        // Select CSR space
        case (avmm_address) inside
            // AFU CSR
            [AFU_DFH : MAC_DFH-1'b1]: begin
                if (avmm_read)
                begin
                    case (avmm_address) inside
                        AFU_DFH: begin
                            avmm_readdata_out <= {
                                4'b0001, // Feature type = AFU
                                8'b0,    // reserved
                                4'b0,    // afu minor revision = 0
                                7'b0,    // reserved
                                1'b0,    // end of DFH list = 0
                                {6'b0, afu_len},   // next DFH offset = MAC
                                4'b0,    // afu major revision = 0
                                12'b0    // feature ID = 0
                            };
                            avmm_readdatavalid_out <= 1'b1;
                        end
                        AFU_DFH+ID_L: begin
                            avmm_readdata_out <= afu_uuid[63:0];
                            avmm_readdatavalid_out <= 1'b1;
                        end

                        AFU_DFH+ID_H: begin
                            avmm_readdata_out <= afu_uuid[127:64];
                            avmm_readdatavalid_out <= 1'b1;
                        end

                        AFU_DFH+DFH_RSVD: begin
                            avmm_readdata_out <= 64'h0;
                            avmm_readdatavalid_out <= 1'b1;
                        end

                        AFU_DFH+AFU_CTRL: begin
                            avmm_readdata_out <= afu_ctrl;
                            avmm_readdatavalid_out <= 1'b1;
                            // TODO: add logic to control MAC
                        end

                        AFU_DFH+AFU_ERROR: begin
                            avmm_readdata_out <= error;
                            avmm_readdatavalid_out <= 1'b1;
                        end

                        // Scratch Register.  Return the last value written
                        // to this MMIO address.
                        AFU_DFH+AFU_SCRATCH: begin
                            avmm_readdata_out <= scratch_reg;
                            avmm_readdatavalid_out <= 1'b1;
                        end

                        default: begin
                            avmm_readdata_out  <= 64'h0;
                            avmm_readdatavalid_out <= 1'b1;
                        end
                    endcase
            
                // Handle MMIO Writes
                end else if (avmm_write)
                begin
                    case (avmm_address) 
                        AFU_DFH+AFU_SCRATCH: begin
                            scratch_reg <= avmm_writedata;
                        end
                        AFU_DFH+AFU_CTRL: begin
                            afu_ctrl <= avmm_writedata;
                        end
                        AFU_DFH+AFU_ERROR: begin
                            error <= avmm_writedata;
                        end
                    endcase
                end
            end
            
            // MAC CSR
            [MAC_DFH : CLIENT_DFH-1'b1]: begin
                if (avmm_read)
                begin
                    case (avmm_address) inside
                        MAC_DFH: begin
                            avmm_readdata_out <= {
                                4'b0010, // Feature type = BBB
                                8'b0,    // reserved
                                4'b0,    // afu minor revision = 0
                                7'b0,    // reserved
                                1'b0,    // end of DFH list = 0
                                {6'b0, mac_len},   // next DFH offset = CLIENT
                                4'b0,    // afu major revision = 0
                                12'b1    // feature ID = 10G
                            };
                            avmm_readdatavalid_out <= 1'b1;
                        end
                        MAC_DFH+ID_L: begin
                            avmm_readdata_out <= mac_uuid[63:0];
                            avmm_readdatavalid_out <= 1'b1;
                        end

                        MAC_DFH+ID_H: begin
                            avmm_readdata_out <= mac_uuid[127:64];
                            avmm_readdatavalid_out <= 1'b1;
                        end

                        MAC_DFH+DFH_RSVD: begin
                            avmm_readdata_out <= 64'h0;
                            avmm_readdatavalid_out <= 1'b1;
                        end
                    endcase
                end
                // Otherwise, connect MAC AVMM interface
                mac_csr_address <= avmm_address[15:0];
                mac_csr_read <= avmm_read;
                mac_csr_write <= avmm_write;
                mac_csr_writedata <= avmm_writedata; // TODO: avmm_writedata is 64 but mac is 32
            end

            // Client CSR
            [CLIENT_DFH : NULL_DFH-1'b1]: begin
                if (avmm_read)
                begin
                    case (avmm_address) inside
                        CLIENT_DFH: begin
                            avmm_readdata_out <= {
                                4'b0010, // Feature type = BBB
                                8'b0,    // reserved
                                4'b0,    // afu minor revision = 0
                                7'b0,    // reserved
                                1'b0,    // end of DFH list = 0
                                {6'b0, client_len},   // next DFH offset = MAC
                                4'b0,    // afu major revision = 0
                                12'b0    // feature ID = 0
                            };
                            avmm_readdatavalid_out <= 1'b1;
                        end
                        CLIENT_DFH+ID_L: begin
                            avmm_readdata_out <= client_uuid[63:0];
                            avmm_readdatavalid_out <= 1'b1;
                        end

                        CLIENT_DFH+ID_H: begin
                            avmm_readdata_out <= client_uuid[127:64];
                            avmm_readdatavalid_out <= 1'b1;
                        end

                        CLIENT_DFH+DFH_RSVD: begin
                            avmm_readdata_out <= 64'h0;
                            avmm_readdatavalid_out <= 1'b1;
                        end
                    endcase
                end
                // Otherwise, connect Client AVMM interface
                client_csr_address <= avmm_address[15:0];
                client_csr_read <= avmm_read;
                client_csr_write <= avmm_write;
                client_csr_writedata <= avmm_writedata;
            end

            // Null CSR
            [NULL_DFH : NULL_DFH+ID_H]: begin
                if (avmm_read) begin
                    if (avmm_address == NULL_DFH) begin
                        // Return NULL_DFH
                        avmm_readdata_out <= {
                            4'b0010, // Feature type = BBB
                            8'b0,    // reserved
                            4'b0,    // reserved
                            7'b0,    // reserved
                            1'b1,    // end of DFH list = 1
                            24'h0,   // next DFH offset = 0
                            4'b0,    // feature revision = 0
                            12'b0    // feature ID = 0
                        };
                        avmm_readdatavalid_out <= 1'b1;
                        
                    end else if (avmm_address == NULL_DFH+ID_L) begin
                        // Return NULL_ID_LO
                        avmm_readdata_out <= null_uuid[63:0];
                        avmm_readdatavalid_out <= 1'b1;

                    end else if (avmm_address == NULL_DFH+ID_H) begin
                        // Return NULL_ID_HI
                        avmm_readdata_out <= null_uuid[127:64];
                        avmm_readdatavalid_out <= 1'b1;
                    end
                end
            end

            // Otherwise, return 0
            default: begin
                avmm_waitrequest        <= '0;
                avmm_readdata           <= '0;
                avmm_readdatavalid      <= '0;
                mac_csr_writedata       <= '0;
                mac_csr_address         <= '0;
                mac_csr_write           <= '0;
                mac_csr_read            <= '0;
                client_csr_writedata    <= '0;
                client_csr_address      <= '0;
                client_csr_write        <= '0;
                client_csr_read         <= '0;
            end
        endcase

        // TODO: Connect avmm_readdata to FIFO
        avmm_readdata <= avmm_readdata_out;
        avmm_readdatavalid <= avmm_readdatavalid_out;
    end
end    
endmodule
