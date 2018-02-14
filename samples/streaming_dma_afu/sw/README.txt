DMA BBB README
**************
This folder provides a generic DMA BBB driver header and a stub implementation
for the streaming DMA AFU. I expect that APIs in the BBB driver header will remain
consistent across various DMA implementations (Streaming/Memory Mapped/Multi-channel
or even RDMA potentially across hosts). At-least that should be our goal. 
The DMA driver stub implementation specifically targets the Streaming DMA AFU. 
We will use this implementation to flush out the APIs.

Generic DMA BBB Driver Header
****************************
 - fpga_dma.h
 - fpga_dma_types.h

Streaming DMA Stub Implementation and Test
******************************************
 - fpga_dma_st_internal.h
 - fpga_dma_st.c
 - fpga_dma_test.c


Notes
*****
- The driver represents DMA handle and DMA transfer as opaque types, allowing
  flexible definitions for those types.
- The stub implementation is not functional yet.


Compiling the driver
******************
$ make prefix=<path to OPAE install>
