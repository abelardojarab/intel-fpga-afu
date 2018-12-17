#!/bin/bash

src_mac='12:34:56:78:9a:bc'
dst_mac='ab:cd:ef:12:34:55'
pkts='0x100'
len='0x400'

./pac_hssi_e10 -a loopback_enable
./pac_hssi_e10 -a stat_clear
./pac_hssi_e10 -s $src_mac -m $dst_mac -p $pkts -l $len -a pkt_send
./pac_hssi_e10 -a stat
