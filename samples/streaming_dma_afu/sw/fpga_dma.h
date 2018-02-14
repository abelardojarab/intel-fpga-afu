// Copyright(c) 2018, Intel Corporation
//
// Redistribution  and  use  in source  and  binary  forms,  with  or  without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of  source code  must retain the  above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name  of Intel Corporation  nor the names of its contributors
//   may be used to  endorse or promote  products derived  from this  software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO,  THE
// IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS BE
// LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

/**
 * \fpga_dma.h
 * \brief FPGA DMA BBB API Header
 */

#ifndef __FPGA_DMA_H__
#define __FPGA_DMA_H__

#include <opae/fpga.h>
#include "fpga_dma_types.h"

#ifdef __cplusplus
extern "C" {
#endif




/**
* fpgaCountDMAChannels
*
* @brief           Count available DMA channels
*                    
*                  Scan the device feature chain for DMA BBBs and count
*                  all available channels. Total number of available channels 
*                  are populated in count on successfull return.
*
* @param[in]    fpga   Handle to the FPGA AFU object obtained via fpgaOpen()
* @param[out]   count  Total number of DMA channels in the FPGA AFU object
* @returns             FPGA_OK on success, return code otherwise
*/
fpga_result fpgaCountDMAChannels(fpga_handle fpga, size_t *count);

/**
* fpgaDMAOpen
*
* @brief                      Open DMA channel handle
*
* @param[in]  fpga            Handle to the FPGA AFU object obtained via fpgaOpen()
* @param[in]  dma_channel_idx Index of the DMA channel that must be opened
* @param[out] dma             DMA object handle
* @returns                    FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMAOpen(fpga_handle fpga, int dma_channel_idx, fpga_dma_handle_t *dma);

/**
* fpgaDMAClose
*
* @brief                  Close DMA channel handle
*
* @param[in]  fpga        Handle to the FPGA AFU object obtained via fpgaOpen()
* @param[in]  dma         DMA channel handle
* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMAClose(fpga_dma_handle_t dma);

/**
* fpgaGetDMAChannelType
*
* @brief                  Query DMA channel type
*
*                         Possible type of channels are TX streaming (TX_ST),
*                         RX streaming (RX_ST), Memory-mapped (MM). 
*                         
* @param[in]  dma         DMA channel handle
* @param[out] props       Pointer to channel type

* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaGetDMAChannelType(fpga_dma_handle_t dma,  fpga_dma_channel_type_t *ch_type);

/**
* fpgaDMATransferInit
*
* @brief                  Initialize an object that represents the DMA transfer. 
*
*                         The driver will reset all transfer attributes to their default 
*                         values upon successful initialization
*
* @param[out]  transfer   Pointer to transfer attribute struct
* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMATransferInit(fpga_dma_transfer_t *transfer);


/**
* fpgaDMATransferDestroy
*
* @brief                  Destroy DMA transfer attribute object. 
*
*                         The driver will reset all transfer attributes to their default 
*                         values upon successful initialization
*
* @param[out]  transfer   Pointer to transfer attribute struct
* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMATransferDestroy(fpga_dma_transfer_t transfer);


/**
* fpgaDMATransferSetSrc
*
* @brief                  Set source address of the transfer
* 
*                         For Host to FPGA transfer, source address is 
*                         the host virtual address. For FPGA to host 
*                         transfer and FPGA to FPGA transfer, source 
*                         address is the FPGA physical address
*
* @param[in]  transfer    Pointer to transfer attribute struct
* @param[in]  src         Source address

* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMATransferSetSrc(fpga_dma_transfer_t transfer, uint64_t src);

/**
* fpgaDMATransferSetDst
*
* @brief                  Set destination address of the transfer
*
*                         For Host to FPGA and FPGA to FPGA transfer, 
*                         destination address is the FPGA physical 
*                         address. For FPGA to host transfer, 
*                         destination address is the host virtual 
*                         address
*
* @param[in]  transfer    Pointer to transfer attribute struct
* @param[in]  dst         Destination address

* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMATransferSetDst(fpga_dma_transfer_t transfer, uint64_t dst);

/**
* fpgaDMATransferSetLen
*
* @brief                  Set transfer length in bytes
*
* @param[in]  transfer    Pointer to transfer attribute struct
* @param[in]  len         Length of the transfer in bytes

* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMATransferSetLen(fpga_dma_transfer_t transfer, uint64_t len);

/**
* fpgaDMATransferSetTransferType
*
* @brief                  Set transfer type
*
*                         Supported values are
*                         HOST_MM_TO_FPGA_ST (host to AFU sreaming)
*                         FPGA_ST_TO_HOST_MM (AFU to host streaming)
*                         FPGA_MM_TO_FPGA_ST (local mem to AFU streaming)
*                         FPGA_ST_TO_FPGA_MM (AFU to local mem streaming)
*
* @param[in]  transfer    Pointer to transfer attribute struct
* @param[out] type        Type of transfer

* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMATransferSetTransferType(fpga_dma_transfer_t transfer, fpga_dma_transfer_type_t type);

/**
* fpgaDMATransferSetTxControl
*
* @brief                  Set TX control
*
*                         TX Control allows the driver to optionally generate
*                         in-band start and end of packet (SOP/EOP) in the data
*                         stream sent from the TX DMA.
*
*                         TX Control is valid only for HOST_MM_TO_FPGA_ST and
*                         FPGA_MM_TO_FPGA_ST transfers. 
*
*                         Valid values are:
* 
*                         TX_NO_PACKET (deterministic length transfer)
*                         GENERATE_SOP
*                         GENERATE_EOP
*                         GENERATE_SOP_AND_EOP
*
* @param[in]  transfer    Pointer to transfer attribute struct
* @param[out] tx_ctrl     TX Control value

* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMATransferSetTxControl(fpga_dma_transfer_t transfer, fpga_dma_tx_ctrl_t tx_ctrl);

/**
* fpgaDMATransferSetRxControl
*
* @brief                  Set RX control
*
*                         RX control allows the driver to handle an unknown 
*                         amount of receive data from the FPGA.  When END_ON_EOP 
*                         is set, the RX DMA will end the transfer when EOP arrives
*                         in the receive stream or when rx_count bytes have been 
*                         received (whichever occurs first)
*
*                         RX Control is valid only for FPGA_ST_TO_HOST_MM and 
*                         FPGA_MM_TO_FPGA_ST transfers.
*                         The rx chave one of the following values:
*
*                         Valid values are:
* 
*                         RX_NO_PACKET (deterministic length transfer)
•                         END_ON_EOP
*
* @param[in]  transfer    Pointer to transfer attribute struct
* @param[out] rx_ctrl     RX Control value

* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMATransferSetRxControl(fpga_dma_transfer_t transfer, fpga_dma_rx_ctrl_t rx_ctrl);

/**
* fpgaDMATransferSetTransferCallback
*
* @brief                  Register callback for notification on asynchronous 
*                         transfer completion
*
* @param[in]  transfer    Pointer to transfer attribute struct
* @param[in]  cb          Notification callback

* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMATransferSetTransferCallback(fpga_dma_transfer_t transfer, fpga_dma_transfer_cb cb);

/**
* fpgaDMATransferGetBytesTransferred
*
* @brief                  Retrieve number of bytes completed by RX DMA
*
*                         Pointer to the number of bytes the RX DMA transferred
*                         to memory. RX transfer from streaming sources will 
*                         have an unknown amount of data to transfer when 
*                         rx_control is set to END_ON_EOP.  
*
* @param[in]  transfer    Pointer to transfer attribute struct
* @param[out] rx_bytes    Pointer to the number of bytes RX DMA has
*                         transferred to memory
*
* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMATransferGetBytesTransferred(fpga_dma_transfer_t transfer, size_t *rx_bytes);

/**
* fpgaDMATransfer
*
* @brief                  Perform a DMA transfer
*                         
*                         If a callback is specified, fpgaDMATransfer
*                         returns immediately (asynchronous transfer).
*
*                         If a callback is not specified, fpgaDMATransfer
*                         returns after the transfer is complete (synchronous/
*                         blocking transfer). 
*
*                         TODO: Is there a use-case for asynchronous transfer
*                               without callback?
*
* @param[dma] dma         DMA handle
* @param[in]  transfer    Transfer attribute object
* @param[in]  cb          Callback
* @param[in]  context     
*
* @returns                FPGA_OK on success, return code otherwise
*/
fpga_result fpgaDMATransfer(fpga_dma_handle_t dma, const fpga_dma_transfer_t transfer, 
                            fpga_dma_transfer_cb cb, void *context);


#ifdef __cplusplus
}
#endif

#endif // __FPGA_DMA_H__