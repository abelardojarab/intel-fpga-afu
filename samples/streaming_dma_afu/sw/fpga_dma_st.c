// Copyright(c) 2017, Intel Corporation
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
// ARE DISCLAIMEdesc.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS BE
// LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

/**
 * \fpga_dma_st.c
 * \brief FPGA Streaming DMA User-mode driver (Stub)
 */

#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <opae/fpga.h>
#include <stddef.h>
#include <poll.h>
#include <errno.h>
#include <unistd.h>
#include <assert.h>
#include <safe_string/safe_string.h>
#include "fpga_dma_st_internal.h"
#include "fpga_dma.h"

#if 0
static int err_cnt = 0;

/*
 * macro for checking return codes
 */

#define ON_ERR_GOTO(res, label, desc)\
do {\
	if ((res) != FPGA_OK) {\
		err_cnt++;\
		fprintf(stderr, "Error %s: %s\n", (desc), fpgaErrStr(res));\
		goto label;\
	}\
} while (0)
#endif

// Transaction worker thread (one per DMA channel)
// Worker processes each transaction in the order
// it gets submitted to the dma->queue
static fpga_result transactionWorker(fpga_dma_handle_t dma) {	
	// TODO
	// while dma->queue not empty	
	// 		atomically dequeue transaction
	//		break and dispatch descriptors
	// 		invoke callback for completed asynchronous transfers
	// 		atomically mark transfer->transf_status = TRANSFER_COMPLETE
	return FPGA_OK;
}

// Public APIs
fpga_result fpgaGetDMAChannels(fpga_handle fpga, size_t *count) {
	// TODO:
	// Discover total# DMA channels by traversing the device feature list
	// We may encounter one or more BBBs during discovery
	// Populate the count	
	return FPGA_OK;
}

fpga_result fpgaOpenDMA(fpga_handle fpga, int dma_channel, fpga_dma_handle_t *dma) {
	// TODO
	// Make a channel available for use
	// 
	// - Walk the DFH list to the index of the DMA channel
	// - Allocate the DMA handle object
	// - Populate channel properties
	// - Initialize channel buffers
	// - Turn on interrupts when necessary
	// - register event handles
	// - Initialize worker thread transaction queue
	// - Spawn worker thread
	fpga_dma_handle_t d;
	transactionWorker(d); //mock
	return FPGA_OK;
}

fpga_result fpgaCloseDMA(fpga_dma_handle_t dma) {
	// TODO
	//
	// Release a used channel
	// unregister event handles
	// turn off interrupts
	// release channel properties
	// free DMA handle object
	// Terminate worker thread
	return FPGA_OK;
}

fpga_result fpgaGetDMAChannelType(fpga_dma_handle_t dma, fpga_dma_channel_type_t *ch_type) {
	fpga_result res = FPGA_OK;
	if(!dma) {
		res = FPGA_INVALID_PARAM;
		return res;
	}

	*ch_type = dma->ch_type;	
	return FPGA_OK;
}

fpga_result fpgaDMATransferInit(fpga_dma_transfer_t *transfer) {
	fpga_result res = FPGA_OK;

	if(!transfer) {
		res = FPGA_INVALID_PARAM;
		return res;
	}

	*transfer = (fpga_dma_transfer_t)malloc(sizeof(struct fpga_dma_transfer));
	if(!transfer) {
		res = FPGA_NO_MEMORY;
		return res;
	}

	return res;
}

fpga_result fpgaDMATransferDestroy(fpga_dma_transfer_t transfer) {
	fpga_result res = FPGA_OK;

	if(!transfer) {
		res = FPGA_INVALID_PARAM;
		return res;
	}

	free(transfer);
	return res;
}

fpga_result fpgaDMATransferSetSrc(fpga_dma_transfer_t transfer, uint64_t src) {
	fpga_result res = FPGA_OK;
	if(!transfer) {
		res = FPGA_INVALID_PARAM;
		return res;
	}

	transfer->src = src;
	return res;
}

fpga_result fpgaDMATransferSetDst(fpga_dma_transfer_t transfer, uint64_t dst) {
	fpga_result res = FPGA_OK;
	if(!transfer) {
		res = FPGA_INVALID_PARAM;
		return res;
	}

	transfer->dst = dst;
	return res;
}

fpga_result fpgaDMATransferSetLen(fpga_dma_transfer_t transfer, uint64_t len) {
	fpga_result res = FPGA_OK;
	if(!transfer) {
		res = FPGA_INVALID_PARAM;
		return res;
	}

	transfer->len = len;
	return res;
}

fpga_result fpgaDMATransferSetTransferType(fpga_dma_transfer_t transfer, fpga_dma_transfer_type_t type) {
	fpga_result res = FPGA_OK;
	if(!transfer) {
		res = FPGA_INVALID_PARAM;
		return res;
	}

	transfer->transfer_type = type;
	return res;
}

fpga_result fpgaDMATransferSetTxControl(fpga_dma_transfer_t transfer, fpga_dma_tx_ctrl_t tx_ctrl) {
	fpga_result res = FPGA_OK;
	if(!transfer) {
		res = FPGA_INVALID_PARAM;
		return res;
	}

	transfer->tx_ctrl = tx_ctrl;
	return res;
}

fpga_result fpgaDMATransferSetRxControl(fpga_dma_transfer_t transfer, fpga_dma_rx_ctrl_t rx_ctrl) {
	fpga_result res = FPGA_OK;
	if(!transfer) {
		res = FPGA_INVALID_PARAM;
		return res;
	}

	transfer->rx_ctrl = rx_ctrl;
	return res;
}

fpga_result fpgaDMATransferSetTransferCallback(fpga_dma_transfer_t transfer, fpga_dma_transfer_cb cb) {
	fpga_result res = FPGA_OK;
	if(!transfer) {
		res = FPGA_INVALID_PARAM;
		return res;
	}

	transfer->cb = cb;
	return res;
}

fpga_result fpgaDMATransferGetBytesTransferred(fpga_dma_transfer_t transfer, size_t *rx_bytes) {
	fpga_result res = FPGA_OK;
	if(!transfer) {
		res = FPGA_INVALID_PARAM;
		return res;
	}
	
	return transfer->rx_bytes;
}

fpga_result fpgaDmaTransfer(fpga_dma_handle_t dma, const fpga_dma_transfer_t transfer, 
                            fpga_dma_transfer_cb cb, void *context) {

	// TODO:
	// Validate transfer attributes
	// atomically mark transfer->transf_status to TRANSFER_IN_PROGRESS
	// atomically enqueue transfer to dma->queue
	// 
	// for synchronous transfer, block till transfer->transf_status is marked TRANSFER_COMPLETE
	// for asynchronous transfer, return immediately	
	return FPGA_OK;
}
