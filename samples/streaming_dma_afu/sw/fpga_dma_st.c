// Copyright(c) 2018, Intel Corporation
//
// Redistribution  and	use  in source	and  binary  forms,  with  or  without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of  source code  must retain the  above copyright notice,
//	 this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//	 this list of conditions and the following disclaimer in the documentation
//	 and/or other materials provided with the distribution.
// * Neither the name  of Intel Corporation  nor the names of its contributors
//	 may be used to  endorse or promote  products derived  from this  software
//	 without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO,  THE
// IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMEdesc.  IN NO EVENT	SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS BE
// LIABLE  FOR	ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,	EXEMPLARY,	OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,	BUT  NOT LIMITED  TO,  PROCUREMENT	OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,	DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,	WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,	EVEN IF ADVISED OF THE
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

// Internal Functions
// End of feature list
static bool _fpga_dma_feature_eol(uint64_t dfh) {
	return ((dfh >> AFU_DFH_EOL_OFFSET) & 1) == 1;
}

// Feature type is BBB
static bool _fpga_dma_feature_is_bbb(uint64_t dfh) {
	// BBB is type 2
	return ((dfh >> AFU_DFH_TYPE_OFFSET) & 0xf) == FPGA_DMA_BBB;
}

// Offset to the next feature header
static uint64_t _fpga_dma_feature_next(uint64_t dfh) {
	return (dfh >> AFU_DFH_NEXT_OFFSET) & 0xffffff;
}

// Public APIs
fpga_result fpgaCountDMAChannels(fpga_handle fpga, size_t *count) {
	// Discover total# DMA channels by traversing the device feature list
	// We may encounter one or more BBBs during discovery
	// Populate the count
	fpga_result res = FPGA_OK;
	if(!fpga) {
		return FPGA_INVALID_PARAM;
	}
	uint32_t mmio_no = 0;
	uint64_t offset = 0;

	// Discover DMA BBB channels by traversing the device feature list
	bool end_of_list = false;
	uint64_t dfh = 0;
	do {
		// Read the next feature header
		res = fpgaReadMMIO64(fpga, mmio_no, offset, &dfh);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");

		// Read the current feature's UUID
		uint64_t feature_uuid_lo, feature_uuid_hi;
		res = fpgaReadMMIO64(fpga, mmio_no, offset + 8, &feature_uuid_lo);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");

		res = fpgaReadMMIO64(fpga, mmio_no, offset + 16,
						&feature_uuid_hi);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");

		if (_fpga_dma_feature_is_bbb(dfh) &&
			(((feature_uuid_lo == M2S_DMA_UUID_L) && (feature_uuid_hi == M2S_DMA_UUID_H)) ||
			((feature_uuid_lo == S2M_DMA_UUID_L) && (feature_uuid_hi == S2M_DMA_UUID_H)))) {
			// Found one. Record it.
			*count = *count+1;
		}

		// End of the list?
		end_of_list = _fpga_dma_feature_eol(dfh);
		// Move to the next feature header
		offset = offset + _fpga_dma_feature_next(dfh);
	} while(!end_of_list);

out:
	return res;
}

// Transaction worker thread (one per DMA channel)
// Worker processes each transaction in the order
// it gets submitted to the dma->queue
// while dma->queue not empty
// atomically dequeue transaction
// break and dispatch descriptors
// invoke callback for completed asynchronous transfers
// atomically mark transfer->transf_status = TRANSFER_COMPLETE
void *m2sTransactionWorker(void* dma_handle) {
	while(1) {};
}

void *s2mTransactionWorker(void* dma_handle) {
	while(1) {};
}

fpga_result fpgaDMAOpen(fpga_handle fpga, int dma_channel, fpga_dma_handle_t *dma) {
	fpga_result res = FPGA_OK;
	fpga_dma_handle_t dma_h;
	int channel_index = 0;
	int i = 0;
	if(!fpga) {
		return FPGA_INVALID_PARAM;
	}
	if(!dma) {
		return FPGA_INVALID_PARAM;
	}

	// init the dma handle
	dma_h = (fpga_dma_handle_t)malloc(sizeof(struct fpga_dma_handle));
	if(!dma_h) {
		return FPGA_NO_MEMORY;
	}
	dma_h->fpga_h = fpga;
	for(i=0; i < FPGA_DMA_MAX_BUF; i++)
		dma_h->dma_buf_ptr[i] = NULL;

	dma_h->mmio_num = 0;
	dma_h->mmio_offset = 0;
	bool end_of_list = false;
	bool dma_found = false;
	uint64_t dfh = 0;
	uint64_t offset = dma_h->mmio_offset;
	do {
		// Read the next feature header
		res = fpgaReadMMIO64(dma_h->fpga_h, dma_h->mmio_num, offset, &dfh);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");
		// Read the current feature's UUID
		uint64_t feature_uuid_lo, feature_uuid_hi;
		res = fpgaReadMMIO64(dma_h->fpga_h, dma_h->mmio_num, offset + 8,
					&feature_uuid_lo);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");

		res = fpgaReadMMIO64(dma_h->fpga_h, dma_h->mmio_num, offset + 16,
						&feature_uuid_hi);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");

		if (_fpga_dma_feature_is_bbb(dfh) &&
			(((feature_uuid_lo == M2S_DMA_UUID_L) && (feature_uuid_hi == M2S_DMA_UUID_H)) ||
			((feature_uuid_lo == S2M_DMA_UUID_L) && (feature_uuid_hi == S2M_DMA_UUID_H))) ) {

			// Found one. Record it.
			if(channel_index == dma_channel) {
				if ((feature_uuid_lo == M2S_DMA_UUID_L) && (feature_uuid_hi == M2S_DMA_UUID_H))
					dma_h->ch_type=TX_ST;
				else if ((feature_uuid_lo == S2M_DMA_UUID_L) && (feature_uuid_hi == S2M_DMA_UUID_H))
					dma_h->ch_type=RX_ST;
				dma_h->dma_base = offset;
				dma_h->dma_csr_base = dma_h->dma_base+FPGA_DMA_CSR;
				dma_h->dma_desc_base = dma_h->dma_base+FPGA_DMA_DESC;
				dma_found = true;
				printf("DMA Base Addr = %08lx\n", dma_h->dma_base);
				break;
			} else {
				channel_index += 1;
			}
		}

		// End of the list?
		end_of_list = _fpga_dma_feature_eol(dfh);

		// Move to the next feature header
		offset = offset + _fpga_dma_feature_next(dfh);
	} while(!end_of_list);

	if(dma_found) {
		*dma = dma_h;
		res = FPGA_OK;
	}
	else {
		*dma = NULL;
		res = FPGA_NOT_FOUND;
		ON_ERR_GOTO(res, out, "DMA not found");
	}

	// Buffer size must be page aligned for prepareBuffer
	for(i=0; i< FPGA_DMA_MAX_BUF; i++) {
		res = fpgaPrepareBuffer(dma_h->fpga_h, FPGA_DMA_BUF_SIZE, (void **)&(dma_h->dma_buf_ptr[i]), &dma_h->dma_buf_wsid[i], 0);
		ON_ERR_GOTO(res, out, "fpgaPrepareBuffer");

		res = fpgaGetIOAddress(dma_h->fpga_h, dma_h->dma_buf_wsid[i], &dma_h->dma_buf_iova[i]);
		ON_ERR_GOTO(res, rel_buf, "fpgaGetIOAddress");
	}

	if(dma_h->ch_type == TX_ST) {
		if(pthread_create(&dma_h->thread_id, NULL, m2sTransactionWorker, (void*)dma_h) != 0) {
			res = FPGA_EXCEPTION;
			ON_ERR_GOTO(res, rel_buf, "pthread_create");		
		}
	} else if(dma_h->ch_type == RX_ST) {
		if(pthread_create(&dma_h->thread_id, NULL, s2mTransactionWorker, (void*)dma_h) != 0) {
			res = FPGA_EXCEPTION;
			ON_ERR_GOTO(res, rel_buf, "pthread_create");	
		}
	}

	return FPGA_OK;

rel_buf:
	for(i=0; i< FPGA_DMA_MAX_BUF; i++) {
		res = fpgaReleaseBuffer(dma_h->fpga_h, dma_h->dma_buf_wsid[i]);
		ON_ERR_GOTO(res, out, "fpgaReleaseBuffer");
	}
out:
	if(!dma_found)
		free(dma_h);
	return res;
}

fpga_result fpgaDMAClose(fpga_dma_handle_t dma) {
	fpga_result res = FPGA_OK;
	int i = 0;
	if(!dma) {
		res = FPGA_INVALID_PARAM;
		goto out;
	}

	if(!dma->fpga_h) {
		res = FPGA_INVALID_PARAM;
		goto out;
	}

	for(i=0; i<FPGA_DMA_MAX_BUF; i++) {
		res = fpgaReleaseBuffer(dma->fpga_h, dma->dma_buf_wsid[i]);
		ON_ERR_GOTO(res, out, "fpgaReleaseBuffer failed");
	}

	pthread_cancel(dma->thread_id);
out:
	free((void*)dma);
	return res;
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

fpga_result fpgaDMATransfer(fpga_dma_handle_t dma, const fpga_dma_transfer_t transfer,
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
