# Discrete FPGA
set_false_path -from u0|dcp_iopll|dcp_iopll|clk1x -to fpga_top|inst_fiu_top|inst_ccip_fabric_top|inst_cvl_top|inst_user_clk|qph_user_clk_fpll_u0|xcvr_fpll_a10_0|outclk0
set_false_path -from u0|dcp_iopll|dcp_iopll|clk1x -to fpga_top|inst_fiu_top|inst_ccip_fabric_top|inst_cvl_top|inst_user_clk|qph_user_clk_fpll_u0|xcvr_fpll_a10_0|outclk1
set_false_path -from fpga_top|inst_fiu_top|inst_ccip_fabric_top|inst_cvl_top|inst_user_clk|qph_user_clk_fpll_u0|xcvr_fpll_a10_0|outclk0 -to u0|dcp_iopll|dcp_iopll|clk1x
set_false_path -from fpga_top|inst_fiu_top|inst_ccip_fabric_top|inst_cvl_top|inst_user_clk|qph_user_clk_fpll_u0|xcvr_fpll_a10_0|outclk1 -to u0|dcp_iopll|dcp_iopll|clk1x
set_false_path -from { u0|dcp_iopll|dcp_iopll|clk1x } -to { u0|dcp_iopll|dcp_iopll|clk1x } -through { *ccip_std_afu* }

# Integrated Xeon+FPGA
set_false_path -from pClk -to uClk_usr
set_false_path -from uClk_usr -to pClk
set_false_path -from pClk -to uClk_usrDiv2
set_false_path -from uClk_usrDiv2 -to pClk
set_false_path -from pClk -to pClkDiv2 -through { *ccip_std_afu* }
set_false_path -from pClk -to pClkDiv4 -through { *ccip_std_afu* }
