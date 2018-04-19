# E10 Library


# pac_hssi_e10

## Compiling pac_hssi_e10

* Configure the transceiver in 10G mode
```
sudo sh -c "echo 10 > /sys/class/fpga/intel-fpga-dev.0/intel-fpga-fme.0/intel-pac-hssi.2.auto/hssi_mgmt/config
```
* Configure read+write privileges on the port
```
sudo chmod 666 /dev/intel-fpga-port.0
```
* List HSSI AFU instances in the system
```
pac_hssi_e10 --list
```
* Enable internal loopback on AFU instance 0, channel 0
```
pac_hssi_e10 --instance=0 --channel=0 --channel_action=loopback_enable
```
* Transmit 0x1000 packets from AFU instance 0, channel 0
```
pac_hssi_e10 --instance=0 --channel=0 --channel_action=pkt_send
```
* Print transmit and receive statistics from MAC CSRs on AFU instance 0, channel 0
```
pac_hssi_e10 --instance=0 --channel=0 --channel_action=stat
```
* Clear transmit and receive statistics on MAC CSRs on AFU instance 0, channel 0
```
pac_hssi_e10 --instance=0 --channel=0 --channel_action=stat_clear
```

# ASE Simulation
ASE Simulation is not supported
