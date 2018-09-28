if {0} {
   unset fpll_ip_params
}

set fpll_ip_params [dict create]

dict set fpll_ip_params profile_cnt "1"
set ::GLOBAL_corename pll_altera_xcvr_fpll_s10_htile_181_3xznj3i

# -------------------------------- #
# --- Default Profile settings --- #
# -------------------------------- #
dict set fpll_ip_params set_refclk_cnt_profile0 "1"
dict set fpll_ip_params final_reference_clock_frequency_profile0 "322.265625"
dict set fpll_ip_params set_output_clock_frequency_profile0 "312.5"
dict set fpll_ip_params set_x1_core_clock_profile0 "true"
dict set fpll_ip_params set_x2_core_clock_profile0 "true"
dict set fpll_ip_params set_x4_core_clock_profile0 "false"
