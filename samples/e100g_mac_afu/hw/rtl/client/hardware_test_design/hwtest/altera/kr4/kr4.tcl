# (C) 2001-2018 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


set ver 1.6a10

set ADDR_KR4_BASECTRL    0xb0
set ADDR_KR4_BASESTAT    0xb1
set ADDR_KR4_FECCTRL0    0xb2
set ADDR_KR4_FECCTRL1    0xb5
set ADDR_KR4_FECCTRL2    0xb8
set ADDR_KR4_FECCTRL3    0xbb
set ADDR_KR4_ANCTRL      0xc0
set ADDR_KR4_ANSTAT      0xc2
set ADDR_KR4_ANOVRD      0xcc
set ADDR_KR4_LTCTRL      0xd0
set ADDR_KR4_LTCTL2      0xd1
set ADDR_KR4_LTSTAT      0xd2
set ADDR_KR4_LTBERT      0xd3
set ADDR_KR4_LTSET0      0xd5
set ADDR_KR4_LTSET1      0xe2
set ADDR_KR4_LTSET2      0xe6
set ADDR_KR4_LTSET3      0xea

proc Get_value_in_variable {uservar} {
    global $uservar
    set userval [set $uservar]
    return $userval
}

proc rst_pcs {} {
    global BASE_RXPHY
    global ADDR_PHY_PMACFG

    reg_write   $BASE_RXPHY $ADDR_PHY_PMACFG 1
    reg_write   $BASE_RXPHY $ADDR_PHY_PMACFG 0
}

proc kr_restart {} {
    global BASE_KR4
    global ADDR_KR4_BASECTRL

    set reg [reg_read   $BASE_KR4 $ADDR_KR4_BASECTRL]
    reg_write $BASE_KR4 $ADDR_KR4_BASECTRL [expr $reg | 0x1007]
}

proc an_disable {} {
  global BASE_KR4
  global ADDR_KR4_ANCTRL

  reg_write   $BASE_KR4 $ADDR_KR4_ANCTRL 0
}

proc an_enable {} {
  global BASE_KR4
  global ADDR_KR4_ANCTRL

  reg_write   $BASE_KR4 $ADDR_KR4_ANCTRL 1
}

proc rd_testmux {ch add} {
 set offset [expr $ch<< 12]	
    reconfig_write $ch 0x14c $add
    return [reconfig_read $ch 0x177]
}

proc freeze_dfe {ch} {
    set val [reconfig_read $ch 0x15b]
    set val [expr $val | 0x10]
    reconfig_write $ch 0x15b $val
}

proc unfreeze_dfe {ch} {
    set val [reconfig_read $ch 0x15b]
    set val [expr $val & 0xEF]
    reconfig_write $ch 0x15b $val
}

proc dfe_mode {ch mode} {
    set val [reconfig_read $ch 0x14d]
    set val [expr ($val & 0xF8) | ($mode & 0x07)]
    reconfig_write $ch 0x14d $val
}

proc en_dfe {ch} {
    set val [reconfig_read $ch 0x15b]
    set val [expr $val & 0xFE]
    reconfig_write $ch 0x15b $val
}

proc dis_dfe {ch} {
    set val [reconfig_read $ch 0x15b]
    set val [expr $val | 0x01]
    reconfig_write $ch 0x15b $val
}

# a10
set ADDR_A10_PST1   0x105
set ADDR_A10_PST1_M 0x7f
set ADDR_A10_PST2   0x106
set ADDR_A10_PST2_M 0x3f
set ADDR_A10_PRE1   0x107
set ADDR_A10_PRE1_M 0x3f
set ADDR_A10_PRE2   0x108
set ADDR_A10_PRE2_M 0x1f
set ADDR_A10_VOD    0x109
set ADDR_A10_VOD_M  0x1f

# burst error insertion
set ADDR_FEC_ERRI   0x0bd
set ADDR_FEC_TRNS_M 0x01
set ADDR_FEC_BRST_M 0x02
#offset and mask for burst_err_len
set ADDR_FEC_BLEN_O 4
set ADDR_FEC_BLEN_M 0xf0

# error marking enable
set ADDR_FEC_EMRK   0x0c2
set ADDR_FEC_EMRK_M 0x20

# fec error counts
set ADDR_FEC_CORR0  0x0dc
set ADDR_FEC_CORR1  0x0dd
set ADDR_FEC_CORR2  0x0de
set ADDR_FEC_CORR3  0x0df

set ADDR_FEC_UCRR0  0x0e0
set ADDR_FEC_UCRR1  0x0e1
set ADDR_FEC_UCRR2  0x0e2
set ADDR_FEC_UCRR3  0x0e3

proc reconfig_read {chan addr} {
    global BASE_A10RECO

    set chanoffs [expr $BASE_A10RECO + (0x400 * $chan)]
    return [reg_read $chanoffs $addr]
}

proc reconfig_write {chan addr val} {
    global BASE_A10RECO

    set chanoffs [expr $BASE_A10RECO + (0x400 * $chan)]
    return [reg_write $chanoffs $addr $val]
}

proc reconfig_rmw {chan addr mask val} {
    set value [reconfig_read $chan $addr]
    set value [expr $value & [expr 0xffffffff & ~$mask]] 
    set value [expr $value | $val] 
    reconfig_write $chan $addr $value
}

proc a10dprio_read {chan type} {
    global ADDR_A10_$type
    global ADDR_A10_${type}_M
    set reg [reconfig_read $chan [set ADDR_A10_$type]]
    return [expr $reg & [set ADDR_A10_${type}_M]]
}

proc fec_err_corr {chan} {
    global BASE_A10RECO
    global ADDR_FEC_CORR0
    global ADDR_FEC_CORR1
    global ADDR_FEC_CORR2
    global ADDR_FEC_CORR3

    set chanoffs [expr $BASE_A10RECO + (0x400 * $chan)]
    set val [reg_read $chanoffs $ADDR_FEC_CORR0]
    set val [expr $val + [reg_read $chanoffs $ADDR_FEC_CORR1] * 0x100]
    set val [expr $val + [reg_read $chanoffs $ADDR_FEC_CORR2] * 0x10000]
    set val [expr $val + [reg_read $chanoffs $ADDR_FEC_CORR3] * 0x1000000]

    return $val
}

proc fec_err_uncorr {chan} {
    global BASE_A10RECO
    global ADDR_FEC_UCRR0
    global ADDR_FEC_UCRR1
    global ADDR_FEC_UCRR2
    global ADDR_FEC_UCRR3

    set chanoffs [expr $BASE_A10RECO + (0x400 * $chan)]
    set val [reg_read $chanoffs $ADDR_FEC_UCRR0]
    set val [expr $val + [reg_read $chanoffs $ADDR_FEC_UCRR1] * 0x100]
    set val [expr $val + [reg_read $chanoffs $ADDR_FEC_UCRR2] * 0x10000]
    set val [expr $val + [reg_read $chanoffs $ADDR_FEC_UCRR3] * 0x1000000]
    return $val
}

proc fec_errs {} {
    puts -nonewline "[fec_err_corr 0] [fec_err_uncorr 0] | "
    puts -nonewline "[fec_err_corr 1] [fec_err_uncorr 1] | "
    puts -nonewline "[fec_err_corr 2] [fec_err_uncorr 2] | "
    puts            "[fec_err_corr 3] [fec_err_uncorr 3]"
}

proc clear_fec_err {chan} {
    global BASE_KR4
    global ADDR_KR4_FECCTRL$chan

    reg_write $BASE_KR4 [set ADDR_KR4_FECCTRL$chan] 0x1000
    reg_write $BASE_KR4 [set ADDR_KR4_FECCTRL$chan] 0x0000
}

proc clear_all_fec_err {} {
    for {set idx 0} {$idx < 4} {incr idx} { 
      clear_fec_err $idx
    }
}

#insert FEC burst error, up to length 15
# FEC should correct anything length 11 or lower
proc ins_burst_err {chan len} {
    global BASE_A10RECO
    global ADDR_FEC_ERRI
    global ADDR_FEC_TRNS_M
    global ADDR_FEC_BRST_M
    global ADDR_FEC_BLEN_O
    global ADDR_FEC_BLEN_M
    global BASE_KR4
    global ADDR_KR4_FECCTRL$chan

    set chanoffs [expr $BASE_A10RECO + (0x400 * $chan)]
    set reg [reg_read $chanoffs $ADDR_FEC_ERRI]

    # clear transcode error, set burst error
    set reg [expr ~$ADDR_FEC_TRNS_M & $reg]
    set reg [expr $ADDR_FEC_BRST_M | $reg]

    # set burst error length
    set reg [expr ~$ADDR_FEC_BLEN_M & $reg]
    set reg [expr $reg | (($len << $ADDR_FEC_BLEN_O) & $ADDR_FEC_BLEN_M)]

    reg_write $chanoffs $ADDR_FEC_ERRI $reg

    # trigger error (self clearing)
    reg_write $BASE_KR4 [set ADDR_KR4_FECCTRL$chan] 0x800
}

proc fec_block_lock {chan} {
    global BASE_KR4
    global ADDR_KR4_BASESTAT

    set reg [reg_read $BASE_KR4 $ADDR_KR4_BASESTAT]
    return [expr ($reg & (0x100000 << $chan)) != 0]
}

proc force_fec {{on 1}} {
    global BASE_KR4
    global ADDR_KR4_BASECTRL

    set reg [reg_read $BASE_KR4 $ADDR_KR4_BASECTRL]
    if {$on} {
        set reg [expr $reg | 0x80]
    } else {
        set reg [expr $reg & (~0x80)]
    }

    reg_write $BASE_KR4 $ADDR_KR4_BASECTRL $reg
}

proc trig_adp {channel} {
    #disable bypass ctle, vga, dfe
    reconfig_rmw $channel 0x167 0x1 0x0
    reconfig_rmw $channel 0x160 0x1 0x0
    reconfig_rmw $channel 0x15b 0x1 0x0

    reconfig_rmw $channel 0x149 0x20 0x00
    #### xfer control to DPRIO (not core signals) 0x149[4]=1
    reconfig_rmw $channel 0x149 0x10 0x10
    ####Reset the adp ckt --> rstn= 149[6]=0 
    reconfig_rmw $channel 0x149 0x40 0x00
    after 10
    ####Everything is set, now remove reset 149[6]=1 and trigger/toggle adp engine start 149[5]
    reconfig_rmw $channel 0x149 0x40 0x40
    after 5
    reconfig_rmw $channel 0x149 0x20 0x20
}

proc trig_adp_all {} {
    trig_adp 0
    trig_adp 1
    trig_adp 2
    trig_adp 3
}

proc bypass_adp {channel} {
    #enable bypass ctle, vga, dfe
    reconfig_rmw $channel 0x167 0x1 0x1
    reconfig_rmw $channel 0x160 0x1 0x1
    reconfig_rmw $channel 0x15b 0x1 0x1
}

proc ipd_rpd {channel ipd rpd} {
    reconfig_rmw $channel 0x139 0x38 [expr ($ipd & 0x7) << 3]
    reconfig_rmw $channel 0x135 0x0c [expr ($rpd & 0x3) << 2]
}

proc ipd_rpd_all {ipd rpd} {
    ipd_rpd 0 $ipd $rpd
    ipd_rpd 1 $ipd $rpd
    ipd_rpd 2 $ipd $rpd
    ipd_rpd 3 $ipd $rpd
}

proc bypass_adp_all {} {
    bypass_adp 0
    bypass_adp 1
    bypass_adp 2
    bypass_adp 3
}

#time in milliseconds
proc set_bertime {{t 0.425115}} {
    global BASE_KR4
    global ADDR_KR4_LTBERT
    set t [expr round($t*2.3523) & 0x3ff]
    reg_write $BASE_KR4 $ADDR_KR4_LTBERT [expr $t << 10]
    puts "ber_time_k_frames set to $t"
}

proc chan_stat_csv {chan {usefec 0}} {
    global BASE_KR4
    global ADDR_KR4_LTSTAT
    global ADDR_KR4_LTSET$chan
    global BASE_RXPHY
    global ADDR_PHY_TXPLLOCK
    global ADDR_PHY_FREQLOCK
    global ADDR_PHY_FRMERROR

    puts -nonewline "LANE$chan\t"

    set rdreg [reg_read $BASE_KR4 [set ADDR_KR4_LTSET$chan]]
    set vod [expr $rdreg & 0x0000003f]
    set post [expr ($rdreg & 0x00001f00)>>8]
    set pre [expr ($rdreg & 0x000f0000)>>16]
    set vod_rd [a10dprio_read $chan VOD]
    set vod_rd [expr $vod_rd & 0x1f]
    set post_rd [a10dprio_read $chan PST1]
    if {$post_rd & 0x40} {
        set post_rd [expr $post_rd & 0x3f]
    } else {
        set post_rd [expr -($post_rd & 0x3f)]
    }
    set pre_rd [a10dprio_read $chan PRE1]
    if {$pre_rd & 0x20} {
        set pre_rd [expr $pre_rd & 0x1f]
    } else {
        set pre_rd [expr -($pre_rd & 0x1f)]
    }

    set dcg [expr ([reconfig_read $chan 0x11c] & 0xF) >> 1]

    reconfig_write $chan 0x14c 29
    set vref [expr [reconfig_read $chan 0x177] >> 3]

    set ctle [reconfig_read $chan 0x167]
    set ctle_man [expr $ctle & 0x1]
    if {$ctle_man} {
        set ctle [expr ($ctle >> 1) & 0x1f]
        set ctle_man "CTLE_M"
    } else {
        reconfig_write $chan 0x14c 27
        set ctle [reconfig_read $chan 0x177]
        # account for 4S CTLE convergence here well roughly
        # CTLE read values 1110/1111 are [doubled+1]-neglect it for now
        set ctle [expr [expr $ctle & 0xf] << 1]
        set ctle_man "CTLE_A"
    }

    set vga [reconfig_read $chan 0x160]
    set vga_man [expr $vga & 0x1]
    if {$vga_man} {
        set vga [expr ($vga >> 1) & 0x7]
        set vga_man "VGA_M"
    } else {
        reconfig_write $chan 0x14c 27
        set vga [reconfig_read $chan 0x177]
        set vga [expr [expr $vga & 0x70] >> 4]
        set vga_man "VGA_A"
    }

    set dfe_man [expr [reconfig_read $chan 0x15b] & 0x1]
    if {$dfe_man} {
        set tap1 [reconfig_read $chan 0x14f]
        set tap2 [reconfig_read $chan 0x150]
        set tap3 [reconfig_read $chan 0x151]
        set tap4 [reconfig_read $chan 0x152]
        set tap5 [reconfig_read $chan 0x153]
        set tap6 [reconfig_read $chan 0x154]
        set tap7 [reconfig_read $chan 0x155]
        set dfe_man "DFE_M"
    } else {
        reconfig_rmw $chan 0x171 0x1e 0x14
        reconfig_rmw $chan 0x130 0xF 0x1
        set tap1 [reconfig_read $chan 0x176]
        reconfig_rmw $chan 0x130 0xF 0x2
        set tap2 [reconfig_read $chan 0x176]
        reconfig_rmw $chan 0x130 0xF 0x3
        set tap3 [reconfig_read $chan 0x176]
        reconfig_rmw $chan 0x130 0xF 0x4
        set tap4 [reconfig_read $chan 0x176]
        reconfig_rmw $chan 0x130 0xF 0x5
        set tap5 [reconfig_read $chan 0x176]
        reconfig_rmw $chan 0x130 0xF 0x6
        set tap6 [reconfig_read $chan 0x176]
        reconfig_rmw $chan 0x130 0xF 0x7
        set tap7 [reconfig_read $chan 0x176]
        set dfe_man "DFE_A"
    }

    #not sure if tap1 has a sign bit...
    set tap1 [expr ($tap1 & 0x7f) * (($tap1 & 0x80) ? -1 : 1)]
    set tap2 [expr ($tap2 & 0x7f) * (($tap2 & 0x80) ? -1 : 1)]
    set tap3 [expr ($tap3 & 0x7f) * (($tap3 & 0x80) ? -1 : 1)]
    set tap4 [expr ($tap4 & 0x3f) * (($tap4 & 0x40) ? -1 : 1)]
    set tap5 [expr ($tap5 & 0x3f) * (($tap5 & 0x40) ? -1 : 1)]
    set tap6 [expr ($tap6 & 0x1f) * (($tap6 & 0x20) ? -1 : 1)]
    set tap7 [expr ($tap7 & 0x1f) * (($tap7 & 0x20) ? -1 : 1)]

    set fec_corr [fec_err_corr $chan]
    set fec_uncorr [fec_err_uncorr $chan]

    puts -nonewline "$vod, $post, $pre,   \t$vod_rd, $post_rd, $pre_rd,   \t$dcg, $vref, $ctle_man, $ctle, $vga_man, $vga, "
    puts -nonewline "$dfe_man, $tap1, $tap2, $tap3, $tap4, $tap5, $tap6, $tap7, "
    if {$usefec} {puts -nonewline " \t$fec_corr, $fec_uncorr, "}

    set rdreg [reg_read $BASE_RXPHY $ADDR_PHY_TXPLLOCK]
    # TX PLL Not Locked
    if {!($rdreg & (1 << $chan))} {puts -nonewline "X"}

    set rdreg [reg_read $BASE_RXPHY $ADDR_PHY_FREQLOCK]
    # RX CDR Not Locked
    if {!($rdreg & (1 << $chan))} {puts -nonewline "x"}

    set rdreg [reg_read $BASE_RXPHY $ADDR_PHY_FRMERROR]
    # 40G frame error
    if {$rdreg & (1 << $chan)} {puts -nonewline "e"}

    set rdreg [reg_read $BASE_KR4 $ADDR_KR4_LTSTAT]
    # not trained
    if {!($rdreg & (1 << ($chan * 8)))} {puts -nonewline "N"}
    # frame lock
    if {$rdreg & (0x2 << ($chan * 8))} {puts -nonewline "l"}
    # startup
    if {$rdreg & (0x4 << ($chan * 8))} {puts -nonewline "s"}
    # training fail (timeout)
    if {$rdreg & (0x8 << ($chan * 8))} {puts -nonewline "F"}

    # FEC not locked
    if {$usefec & ![fec_block_lock $chan]} {puts -nonewline "L"}
}

proc run_test_meas {t} {
    global CLIENT_BASE
    global REG_TEMP_SENSE
    global BASE_KR4
    global ADDR_KR4_BASECTRL
    global ADDR_KR4_BASESTAT
    global ADDR_KR4_ANSTAT
    global ADDR_KR4_LTCTRL
    global ADDR_KR4_LTCTL2
    global ADDR_KR4_LTSTAT
    global BASE_RXPHY
    global ADDR_PHY_RFCLKHZ
    global ADDR_PHY_CLKMACOK
    global ADDR_PHY_FALIGNED
    global BASE_TXSTATS
    global BASE_RXSTATS
    global REG_ST_LO
    global REG_CRCERR_LO
    global REG_STAT_CFG
    global REG_STAT_STATUS
    global ver

    set degf [expr [reg_read $CLIENT_BASE $REG_TEMP_SENSE]]
    set refclk [ expr [ reg_read $BASE_RXPHY $ADDR_PHY_RFCLKHZ ]]

    puts "---------------------------------------"
    puts "KR4 TEST $ver, TIME $t, $degf F, refclk $refclk"
    wait_for_phy_lock 10
    stop_gen
    setphy_clear_frame_error
    # clear stats
    reg_write $BASE_TXSTATS $REG_STAT_CFG 1
    reg_write $BASE_RXSTATS $REG_STAT_CFG 1
    clear_all_fec_err

    # todo add error counter/global status readout
    start_gen
    after $t

    stop_gen
    after 100

    puts "GLOBAL,reg 0xB0  ,reg 0xB1  ,reg 0xC2  ,reg 0xD0  ,reg 0xD1  ,reg 0xD2  ,\tTX Starts,RX Starts,RX FCS Err,\tFlags"

    set txcnt [expr [stats_read $BASE_TXSTATS $REG_ST_LO]]
    set rxcnt [expr [stats_read $BASE_RXSTATS $REG_ST_LO]]
    set err [expr [stats_read $BASE_RXSTATS $REG_CRCERR_LO]]
    puts -nonewline "GLOBAL,[reg_read $BASE_KR4 $ADDR_KR4_BASECTRL],[reg_read $BASE_KR4 $ADDR_KR4_BASESTAT],[reg_read $BASE_KR4 $ADDR_KR4_ANSTAT],[reg_read $BASE_KR4 $ADDR_KR4_LTCTRL],[reg_read $BASE_KR4 $ADDR_KR4_LTCTL2],[reg_read $BASE_KR4 $ADDR_KR4_LTSTAT],\t$txcnt,$rxcnt,$err,\t"

    set rdreg [reg_read $BASE_RXPHY $ADDR_PHY_FALIGNED]
    # 40G lanes not deskewed
    set lstat "UP"
    if {!($rdreg & 1)} {puts -nonewline "d"; set lstat "DN"}
    # 40G hi BER
    if {$rdreg & 2} {puts -nonewline "H"}

    set rdreg [reg_read $BASE_RXPHY $ADDR_PHY_CLKMACOK]
    # Tx analog not online
    if {!($rdreg & 1)} {puts -nonewline "a"}
    # Tx mac pll not lock
    if {!($rdreg & 2)} {puts -nonewline "P"}
    # Rx mac pll not lock
    if {!($rdreg & 4)} {puts -nonewline "p"}

    set rdreg [reg_read $BASE_KR4 $ADDR_KR4_BASESTAT]
    # link down (not ready)
    if {!($rdreg & 1)} {puts -nonewline "D"}
    #autoneg timeout
    if {$rdreg & 2} {puts -nonewline "A"}
    #link train timeout
    if {$rdreg & 4} {puts -nonewline "T"}

    set fec_mode [expr ($rdreg & 0x2000) != 0]

    set modeline "UNK Mode? "

    if {$rdreg & 0x0100} {set modeline "AN Mode   "}
    if {$rdreg & 0x0200} {set modeline "LT Mode   "}
    if {$rdreg & 0x0400} {set modeline "40G Mode  "}
    if {$rdreg & 0x0800} {set modeline "1G Mode?? "}
    if {$rdreg & 0x1000} {set modeline "XAU Mode? "}
    if {$rdreg & 0x2000} {set modeline "FEC Mode  "}

    set modeline "$modeline LINK $lstat"

    if {$rdreg & 0x2} {set modeline "$modeline -- AN Timeout"}
    if {$rdreg & 0x4} {set modeline "$modeline -- LT Timeout"}

    set rdreg [reg_read $BASE_KR4 $ADDR_KR4_ANSTAT]
    #AN not complete
    if {!($rdreg & 4)} {puts -nonewline "n"}
    #ANSM not idle
    if {!($rdreg & 0x10)} {puts -nonewline "I"}

    set fec_an [expr ($rdreg & 0x100) != 0]

    # fec mode but AN doesn't report it
    if {$fec_mode && !$fec_an} {puts -nonewline "m"}
    # non-fec mode but AN reports it
    if {!$fec_mode && $fec_an} {puts -nonewline "M"}

    set rdreg [reg_read $BASE_RXSTATS $REG_STAT_STATUS]
    # parity error detected somewhere in stats
    if {$rdreg & 1} {puts -nonewline "*"}

    puts ""
    puts $modeline

    puts -nonewline "LANE#\tvod, post, pre,\tvod_rd, post_rd, pre_rd, dcg, VREF, CTLEm, CTLE, VGAm, VGA, DFEm, DFE1, DFE2, DFE3, DFE4, DFE5, DFE6, DFE7, "
    if {$fec_mode} { puts -nonewline "\tFEC Corr, FEC Uncorr,"}
    puts " Flags"

    for {set idx 0} {$idx < 4} {incr idx} {
      chan_stat_csv $idx $fec_mode
      puts ""
    }
}
