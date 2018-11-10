# README

## Installation Instructions
* Download and install Intel Threading Building Blocks (TBB) from https://software.intel.com/en-us/intel-tbb
* Export install path under TBB_HOME
```
$ export TBB_HOME=/opt/intel/tbb/
```
* Compile the driver
```
$ make
```
* Set LD_LIBRARY_PATH
```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD:$TBB_HOME/lib/intel64_lin/gcc4.7
```
* Reserve hugepages if required.
If test data size is less than 4KB, hugepages need not be reserved.
If test data size is greater than 4KB, less than 2MB, at-least 1 2MB hugepage needs to be reserved.
```
echo 2 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
```
If test data size is greater than 2MB, less than 1GB, at-least 1 1GB hugepage needs to be set.
```
echo 2 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
```

* Run a simple bandwidth test. This example transfers a single 10MB data packet 
from host memory to FPGA stream using 4KB DMA payload.
```
$ ./fpga_dma_st_test -s 10485760 -p 4096 -r mtos -t fixed
PASS! Bandwidth = 2584 MB/s

Usage:
     fpga_dma_st_test [-h] [-B <bus>] [-D <device>] [-F <function>] [-S <segment>]
                       -l <loopback on/off> -s <data size (bytes)> -p <payload size (bytes)>
                       -r <transfer direction> -t <transfer type> [-f <decimation factor>]

         -h,--help           Print this help
         -B,--bus            Set target bus number
         -D,--device         Set target device number
         -F,--function       Set target function number
         -S,--segment        Set PCIe segment
         -l,--loopback       Loopback mode
            on               Turn on channel loopback
            off              Turn off channel loopback (must specify channel using -r/--direction)
         -s,--data_size      Total data size
         -p,--payload_size   Payload size (per DMA transaction)
         -r,--direction      Transfer direction
            mtos             Memory to stream
            stom             Stream to memory
         -t,--type           Transfer type
            fixed            Deterministic length transfer
            packet           Packet transfer (uses SOP and EOP markers)
         -f,--decim_factor   Optional decimation factor
```
* Sweep payloads and profile the driver
```
$ chmod 777 ./profile
$ ./profile
-----------------------------
payload         mtos    stom
-----------------------------
128B            140     180
1.375KB         1230    1939
4KB             2625    4434
8KB             3821    5455
16KB            4825    6107
32KB            5575    6503
64KB            6073    6709
128KB           6330    6814
256KB           6478    6876
512KB           6547    6908
1024KB          6584    6916
```
* View bandwidth results in gnuplot (optional)
```
$ gnuplot -p plot.gnu
```

## Streaming DMA AFU
The streaming DMA AFU implements read-master and
write-master DMA channels.
The read-master DMA issues reads on the Avalon-MM port and
writes on the Avalon-ST port. The write-master DMA issues
reads on the Avalon-MM port and writes on the Avalon-ST port.
In the reference configuration provided, Avalon-ST port of the read
master DMA drives a pattern checker and Avalon-ST port of the 
write master DMA is driven from a pattern generator. Refer to the
Streaming DMA user guide for a detailed description of the
hardware architecture.

The reference AFU is wired in the topology shown below.
```
                            /|------> Pattern checker
Memory to Stream DMA ----> | |
                            \|----
                                 |
                                Decimator
                                 |
                            /|<--- 
Stream to Memory DMA <---- | |
                            \|<----- Pattern generator


```
The loopback between memory to stream and stream to memory
channels can be turned on/off from the test application
by setting the -l/--loopback flag to on/off. When
the loopback is turned on, traffic runs through 
a decimator between the channels. This module 
recieves a stream of data and removes a 
programmable number of beats before forwarding the data.
The number of beats to remove is called the decimation factor so
a value of 0 means no removal, 1 means every
other beat is removed, 2 means one beat out of three is removed, etc....
The module *always* forwards beats with SOP 
or EOP set so that packet boundaries do notice
get filtered out. Decimation factor can be specified
using -f/--decim_factor flag. Default is 0 (all traffic
is forwarded).

## Software Driver Use Model

### Streams, Packets and Buffers
The application transmits or recieves streams of packetized data
from a streaming port. A *stream* is a series of packets. 
A packet consists of one or more *buffers*. The beginning and end of a packet 
is specified using markers on the first and last buffer.

The DMA driver exposes APIs for transferring *buffers*.
A buffer is a physically contiguous region of memory where
the DMA engine can transfer data. This means that the maximum
size amount of data that can be 
transferred using a buffer (referred to as *payload*)
is either a page (4KB) or a hugepage (2MB or 1GB).
If the application wishes to transfer more data, it must
do so using a series of buffers. The DMA engine can support
a maximum payload of 1GB. The buffer must be
pinned (page-locked) in host memory. 
Application may allocate or pin a buffer
using fpgaPrepareBuffer().

### Describing a DMA Transfer
Application uses a *DMA transfer atttribute object* to describe a data transfer
from/into the buffer. The DMA transfer attribute describes 
physical address of the buffer where the application data is located,
direction of DMA transfer, packet markers (if any) and application
notification callback on completion of buffer transfer.
Application creates a DMA transfer object using fpgaDMATransferInit()
and sets transfer attributes using fpgaDMATransferSet\*() APIs.
Application submits a buffer for DMA transfer using
fpgaDMATransfer(). Once fpgaDMATransfer() returns, 
the transfer attribute object may be reused for issuing subsequent transfers.
The transfer attribute object is destroyed using fpgaDMATransferDestroy().

The driver supports synchronous (blocking) and asynchronous
(non-blocking) transfers. Asynchronous transfers
return immediately to the caller. Application is notified using
a callback mechanism. The callback informs
the actual number of bytes transferred and whether an 
*end of packet* marker was signaled by hardware. 
Synchronous transfers return to 
the application after the DMA transfer is complete. 
Application queries actual number of transferred bytes
and end of packet marker for the buffer using fpgaDMAGet\*() APIs.
If no callback was specified in the DMA transfer 
attribute object, a synchronous transfer is inferred.

### Deterministic and Non-deterministic Transfers
The driver supports deterministic and non-determinstic
length transfers. In deterministic length transfers, the application
exactly knows the total number of bytes that will be transferred. 
The application calculates the exact number of buffers required
to perform the transfer and provides them to the driver.
In other applications however, the amount of data recieved
from the accelerator cannot be predetermined. In this scenario,
the application may constantly send empty buffers, which will be filled
by the accelerator. For each buffer written to host memory,
the driver notifies the actual number of bytes transferred
and *end of packet* status. The application may accumulate
bytes transferred in each buffer to obtain the total number of 
bytes transferred.

Normally, the application sends a never ending stream of
packets. When the packet ends early, leftover empty buffers
that remain in the driver are used for the following
packet. However, if the application wishes to discard any
pending buffers, the driver provides a mechanism. See 
fpgaDMAInvalidate() in fpga_dma.h.

### Transfer Ordering
The driver processes DMA transfers issued on a channel in the issue order.
It does not offer any ordering guarantee on transfers issued across 
independent channels.

### DMA Channel Discovery
Each master appears to the software application as a DMA channel.
The application enumerates total available channels in the AFU using
fpgaCountDMAChannels(). The desired channel referenced by its
index (starting at index 0) must be opened using fpgaDMAOpen() 
before use. The application may query the channel type (
memory to stream/TX or stream to memory/RX) using 
fpgaGetDMAChannelType(). The application closes a
channel using fpgaDMAClose().
Every channel can be independently opened and operated upon.

### Thread Safety
Operations on DMA transfer attribute object are guaranteed to be thread-safe.

### Optimizing Packet Transfers
Latency of fetching a descriptor over PCI Express link
affects DMA throughput. the driver amortizes the 
latency of descriptor fetch by
reading a group of descriptors together. 
Group size is configurable using the compile parameter (-DBLOCK_SIZE).
Typically, DMA fetches a group of descriptors when the block is filled
with valid transfers. However, there may be a situation
where application cannot issue enough transfers to fill a block.
In this case, the application may want to force flush the block
to DMA as soon as the last buffer is issued to the driver.
The application can do so by marking the buffer as the last buffer
in the packet (see fpgaDMASetLast in fpga_dma.h).

## Examples

The first example demonstrates channel enumeration, open and close.
Error checking has been omitted for brevity.

```
fpga_dma_handle_t dma_h;

// Enumerate DMA handles
uint64_t ch_count;
fpgaCountDMAChannels(afc_h, &ch_count);
	
// open a DMA channel
fpga_dma_handle_t dma_h;
fpgaDMAOpen(afc_h, 0 /*channel index*/, &dma_h);

// Query channel type (TX/RX)
fpga_dma_channel_type_t ch_type;
fpgaGetDMAChannelType(dma_h, &ch_type);

fpgaDMAClose(dma_h);
```

The second example shows a simple non-blocking deterministic-length memory-to-stream transfer for a 4KB buffer.

```
// callback
void transferCompleteCb(void *ctx, fpga_dma_transfer_status_t status) {
	cout << "eop arrived = " << status.eop_arrived << endl;
	cout << "bytes transferred = " << status.bytes_transferred << endl;	
}

void *buf_va;
uint64_t buf_size = 4*1024; //bytes
uint64_t buf_wsid;
uint64_t buf_ioa;

// allocate and pin buffer
fpgaPrepareBuffer(afc_h, buf_size, (void **)&buf_va, &buf_wsid, 0);

// obtain buffer physical address
fpgaGetIOAddress(afc_h, buf_wsid, &buf_ioa /* physical address */);

// create a transfer attribute object
fpga_dma_transfer_t transfer;
fpgaDMATransferInit(&transfer);

// set transfer attributes
fpgaDMATransferSetSrc(transfer, buf_ioa /* buffer address must be physical address */);
fpgaDMATransferSetDst(transfer, (uint64_t)0); //dst address is don't care for memory to stream transfers
fpgaDMATransferSetLen(transfer, buf_size);
fpgaDMATransferSetTransferType(transfer, HOST_MM_TO_FPGA_ST);
fpgaDMATransferSetRxControl(transfer, RX_NO_PACKET);
fpgaDMATransferSetLast(transfer, true); // mark this buffer as final in this packet
fpgaDMATransferSetTransferCallback(transfer, transferCompleteCb, NULL /* context */);
fpgaDMATransfer(dma_h, transfer);

// destroy transfer
fpgaDMATransferDestroy(&transfer);
```
The third example demonstrates a non-deterministic-length stream-to-memory transfer.
Accelerator signals end of packet on the third buffer. Application discards remaining
buffers.

```
static uint64_t total_bytes = 0;
// callback
void transferCompleteCb(void *ctx, fpga_dma_transfer_status_t status) {
	fpga_dma_handle_t dma_h = (fpga_dma_handle_t*)ctx;

	total_bytes += status.bytes_transferred;
	if (status.eop_arrived) {
		// invalidate leftover buffers
		fpgaDMAInvalidate(dma_h);
	}	
}

#define MAX_BUFS 10
// create a transfer attribute object
fpga_dma_transfer_t transfer;

for(int i = 0; i < MAX_BUFS; i++) {
	fpgaDMATransferInit(&transfer);

	// set transfer attributes
	fpgaDMATransferSetSrc(transfer, (uint64_t)0); //src address is don't care for stream to memory transfers
	fpgaDMATransferSetDst(transfer, buf_ioa /* buffer address must be physical address */);
	fpgaDMATransferSetLen(transfer, buf_size);
	fpgaDMATransferSetTransferType(transfer, FPGA_ST_TO_HOST_MM);
	fpgaDMATransferSetRxControl(transfer, END_ON_EOP);
	if(i == MAX_BUFS - 1)
		fpgaDMATransferSetLast(transfer, true); // mark this buffer as final in this packet
	else 
		fpgaDMATransferSetLast(transfer, false);
	fpgaDMATransferSetTransferCallback(transfer, transferCompleteCb, dma_h /* context */);
	fpgaDMATransfer(dma_h, transfer);
}
fpgaDMATransferDestroy(&transfer);

```

## ASE Simulation
ASE simulation is supported
