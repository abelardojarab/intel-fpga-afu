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

static void queueInit (struct qinfo_t *q) {
	q->read_index = q->write_index = -1;
}

static bool enqueue(struct qinfo_t *q, fpga_dma_transfer_t *tf) {
	// Check to see if the Queue is full
	int value=0;
	pthread_mutex_lock(&q->qmutex);
	sem_getvalue(&q->qsem, &value);
	if(value == FPGA_DMA_MAX_INFLIGHT_TRANSACTIONS) {
		pthread_mutex_unlock(&q->qmutex);
		return false;
	}
	else {
		// Increment tail index
		q->write_index++;
		// Add the item to the Queue
		q->queue[q->write_index % FPGA_DMA_MAX_INFLIGHT_TRANSACTIONS]= *tf;
		sem_post(&q->qsem);
		pthread_mutex_unlock(&q->qmutex);
		return true;
	}
}

static void dequeue(struct qinfo_t *q, fpga_dma_transfer_t *tf) {
	// Check for empty Queue
	sem_wait(&q->qsem);
	pthread_mutex_lock(&q->qmutex);
	q->read_index++;
	*tf = q->queue[q->read_index % FPGA_DMA_MAX_INFLIGHT_TRANSACTIONS];
	pthread_mutex_unlock(&q->qmutex);
}

// copy bytes to MMIO
static fpga_result _copy_to_mmio(fpga_handle afc_handle, uint64_t mmio_dst, uint64_t *host_src, int len) {
	int i=0;
	fpga_result res = FPGA_OK;
	//mmio requires 8 byte alignment
	if(len % QWORD_BYTES != 0) return FPGA_INVALID_PARAM;
	if(mmio_dst % QWORD_BYTES != 0) return FPGA_INVALID_PARAM;

	uint64_t dev_addr = mmio_dst;
	uint64_t *host_addr = host_src;

	for(i = 0; i < len/QWORD_BYTES; i++) {
		res = fpgaWriteMMIO64(afc_handle, 0, dev_addr, *host_addr);
		if(res != FPGA_OK)
			return res;

		host_addr += 1;
		dev_addr += QWORD_BYTES;
	}

	return FPGA_OK;
}

static fpga_result _dma_desc_status(fpga_dma_handle_t dma_h)
{
	fpga_result res = FPGA_OK;
	msgdma_status_t status = {0};
	res = fpgaReadMMIO32(dma_h->fpga_h, dma_h->mmio_num, dma_h->dma_csr_base+offsetof(msgdma_csr_t, status), &status.reg);
	ON_ERR_GOTO(res, out, "fpgaReadMMIO64");
	
	while((status.st.busy) != 0) {
		res = fpgaReadMMIO32(dma_h->fpga_h, dma_h->mmio_num, dma_h->dma_csr_base+offsetof(msgdma_csr_t, status), &status.reg);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");		 
	}
out:
	return res;
}

static fpga_result _send_descriptor(fpga_dma_handle_t dma_h, msgdma_ext_desc_t desc) {
	fpga_result res = FPGA_OK;
	msgdma_status_t status = {0};

	debug_print("desc.rd_address = %x\n",desc.rd_address);
	debug_print("desc.wr_address = %x\n",desc.wr_address);
	debug_print("desc.len = %x\n",desc.len);
	debug_print("desc.wr_burst_count = %x\n",desc.wr_burst_count);
	debug_print("desc.rd_burst_count = %x\n",desc.rd_burst_count);
	debug_print("desc.wr_stride %x\n",desc.wr_stride);
	debug_print("desc.rd_stride %x\n",desc.rd_stride);
	debug_print("desc.rd_address_ext %x\n",desc.rd_address_ext);
	debug_print("desc.wr_address_ext %x\n",desc.wr_address_ext);

	debug_print("SGDMA_CSR_BASE = %lx SGDMA_DESC_BASE=%lx\n",dma_h->dma_csr_base, dma_h->dma_desc_base);

	do {
		res = fpgaReadMMIO32(dma_h->fpga_h, dma_h->mmio_num, dma_h->dma_csr_base+offsetof(msgdma_csr_t, status), &status.reg);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");
	} while(status.st.desc_buf_full);

	res = _copy_to_mmio(dma_h->fpga_h, dma_h->dma_desc_base, (uint64_t *)&desc, sizeof(desc));
	ON_ERR_GOTO(res, out, "_copy_to_mmio");

out:
	return res;
}

static fpga_result _do_dma(fpga_dma_handle_t dma_h, uint64_t dst, uint64_t src, int count, int is_last_desc, fpga_dma_transfer_type_t type, bool intr_en) {
	msgdma_ext_desc_t desc = {0};
	fpga_result res = FPGA_OK;

	// src, dst and count must be 64-byte aligned
	if(dst%FPGA_DMA_ALIGN_BYTES	!=0 ||
		src%FPGA_DMA_ALIGN_BYTES  !=0 ||
		count%FPGA_DMA_ALIGN_BYTES!=0) {
		return FPGA_INVALID_PARAM;
	}

	// these fields are fixed for all DMA transfers
	desc.seq_num = 0;
	desc.wr_stride = 1;
	desc.rd_stride = 1;

	desc.control.go = 1;
	if(intr_en)
		desc.control.transfer_irq_en = 1;
	else
		desc.control.transfer_irq_en = 0;

	// Enable "earlyreaddone" in the control field of the descriptor except the last.
	// Setting early done causes the read logic to move to the next descriptor
	// before the previous descriptor completes.
	// This elminates a few hundred clock cycles of waiting between transfers.
	if(!is_last_desc)
		desc.control.early_done_en = 1;
	else
		desc.control.early_done_en = 0;

	desc.rd_address = src & FPGA_DMA_MASK_32_BIT;
	desc.wr_address = dst & FPGA_DMA_MASK_32_BIT;
	desc.len = count;
	desc.rd_address_ext = (src >> 32) & FPGA_DMA_MASK_32_BIT;
	desc.wr_address_ext = (dst >> 32) & FPGA_DMA_MASK_32_BIT;

	res = _send_descriptor(dma_h, desc);
	ON_ERR_GOTO(res, out, "_send_descriptor");

out:
	return res;
}


void *m2sTransactionWorker(void* dma_handle) {
	fpga_result res = FPGA_OK;
	fpga_dma_handle_t dma_h = (fpga_dma_handle_t )dma_handle;
	uint64_t count;
	int i;
	while (1) {
		fpga_dma_transfer_t m2s_transfer = (fpga_dma_transfer_t)malloc(sizeof(struct fpga_dma_transfer));
		debug_print("No entry in H2F DMA Queue; Going into wait state\n");
		dequeue(&dma_h->qinfo, &m2s_transfer);
		debug_print("Entry in H2F queue found; wake up\n");
		debug_print("HOST to FPGA --- src_addr = %08lx, dst_addr = %08lx\n", m2s_transfer->src, m2s_transfer->dst);
		count = m2s_transfer->len;
		uint32_t dma_chunks = count/FPGA_DMA_BUF_SIZE;
		count -= (dma_chunks*FPGA_DMA_BUF_SIZE);
		for(i=0; i<dma_chunks; i++) {
			debug_print("h2f memcpy %d\n", i);
			memcpy(dma_h->dma_buf_ptr[0], (void*)(m2s_transfer->src+i*FPGA_DMA_BUF_SIZE), FPGA_DMA_BUF_SIZE);
			debug_print("h2f do_dma %d\n", i);
			res = _do_dma(dma_h, 0, dma_h->dma_buf_iova[0] | 0x1000000000000, FPGA_DMA_BUF_SIZE, 1, m2s_transfer->transfer_type, 0);
			ON_ERR_GOTO(res, out, "HOST_TO_FPGA_ST Transfer failed\n");
			debug_print("h2f done do_dma %d\n", i);
			res = _dma_desc_status(dma_h);
			ON_ERR_GOTO(res, out, "DMA DESC BUFFER Empty polling failed");
			debug_print("h2f desc status non-busy %d\n", i);
		}
		if(count > 0) {
			debug_print("h2f memcpy: leftover\n");
			memcpy(dma_h->dma_buf_ptr[0], (void*)(m2s_transfer->src+dma_chunks*FPGA_DMA_BUF_SIZE), count);
			debug_print("h2f do_dma: leftover\n");
			res = _do_dma(dma_h, 0, dma_h->dma_buf_iova[0] | 0x1000000000000, count, 1, m2s_transfer->transfer_type, 0);
			ON_ERR_GOTO(res, out, "HOST_TO_FPGA_ST Transfer failed");
			debug_print("h2f done do_dma: leftover\n");
			res = _dma_desc_status(dma_h);
			ON_ERR_GOTO(res, out, "DMA DESC BUFFER Empty polling failed");
			debug_print("h2f desc status non-busy %d\n", i);
		}
		//transfer_complete
		if(m2s_transfer->cb)
			m2s_transfer->cb(NULL);
		else
			sem_post(&m2s_transfer->tf_status);
	}
out:
	pthread_exit((void *)1);
}

void *s2mTransactionWorker(void* dma_handle) {
	fpga_result res = FPGA_OK;
	fpga_dma_handle_t dma_h = (fpga_dma_handle_t )dma_handle;
	uint64_t count;
	int i;
	while (1) {
		fpga_dma_transfer_t s2m_transfer = (fpga_dma_transfer_t)malloc(sizeof(struct fpga_dma_transfer));
		debug_print("No entry in F2H DMA Queue; Going into wait state\n");
		dequeue(&dma_h->qinfo, &s2m_transfer);
		debug_print("Entry in F2H DMA Queue found; wake up\n");
		debug_print("FPGA to HOST --- src_addr = %08lx, dst_addr = %08lx\n", s2m_transfer->src, s2m_transfer->dst);
		count = s2m_transfer->len;
		uint32_t dma_chunks = count/FPGA_DMA_BUF_SIZE;
		count -= (dma_chunks*FPGA_DMA_BUF_SIZE);
		for(i=0; i<dma_chunks; i++) {
			debug_print("f2h do_dma %d\n", i);
			res = _do_dma(dma_h, dma_h->dma_buf_iova[0] | 0x1000000000000, 0, FPGA_DMA_BUF_SIZE, 1, s2m_transfer->transfer_type, 0);
			ON_ERR_GOTO(res, out, "FPGA_ST_TO_HOST_MM Transfer failed");
			debug_print("f2h do_dma done %d\n", i);
			debug_print("f2h desc status %d\n", i);
			res = _dma_desc_status(dma_h);
			ON_ERR_GOTO(res, out, "DMA DESC BUFFER Empty polling failed");
			debug_print("f2h desc status done%d\n", i);
			debug_print("f2h memcpy %d\n", i);
			memcpy((void*)(s2m_transfer->dst+i*FPGA_DMA_BUF_SIZE), dma_h->dma_buf_ptr[0], FPGA_DMA_BUF_SIZE);
			debug_print("f2h memcpy done %d\n", i);
		}
		if(count > 0) {
			debug_print("f2h do_dma: leftover\n");
			res = _do_dma(dma_h, dma_h->dma_buf_iova[0] | 0x1000000000000, 0, count, 1, s2m_transfer->transfer_type, 0);
			ON_ERR_GOTO(res, out, "FPGA_TO_HOST_ST Transfer failed");
			debug_print("f2h do_dma done: leftover\n");
			debug_print("f2h desc status: leftover\n");
			res = _dma_desc_status(dma_h);
			ON_ERR_GOTO(res, out, "DMA DESC BUFFER Empty polling failed");
			debug_print("f2h desc status done:leftover\n");
			debug_print("f2h memcpy: leftover\n");
			memcpy((void*)(s2m_transfer->dst+dma_chunks*FPGA_DMA_BUF_SIZE), dma_h->dma_buf_ptr[0], count);
			debug_print("f2h memcpy done: leftover\n");
		}
		//transfer complete
		if(s2m_transfer->cb)
			s2m_transfer->cb(NULL);
		else
			sem_post(&s2m_transfer->tf_status);
	}
out:
	pthread_exit((void *)1);
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
	queueInit(&dma_h->qinfo);
	sem_init(&dma_h->qinfo.qsem, 0, 0);
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

	sem_destroy(&dma->qinfo.qsem);
	if(pthread_cancel(dma->thread_id) != 0) {
		res = FPGA_EXCEPTION;
		ON_ERR_GOTO(res, out, "pthread_cancel");
	}

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

fpga_result fpgaDMATransfer(fpga_dma_handle_t dma, fpga_dma_transfer_t transfer,
							fpga_dma_transfer_cb cb, void *context) {
	fpga_result res = FPGA_OK;
	fpga_dma_transfer_type_t type;
	type = transfer->transfer_type;
	bool ret;
	if(!dma)
		return FPGA_INVALID_PARAM;
	if(type >= FPGA_MAX_TRANSFER_TYPE)
		return FPGA_INVALID_PARAM;
	if(!( type == HOST_MM_TO_FPGA_ST || type == FPGA_ST_TO_HOST_MM))
		return FPGA_NOT_SUPPORTED;
	if(!dma->fpga_h)
		return FPGA_INVALID_PARAM;
	if(cb)
		sem_init(&transfer->tf_status,0,0);

	if(type == HOST_MM_TO_FPGA_ST) {
		if(IS_DMA_ALIGNED(transfer->dst)) {
			do {
				ret = enqueue(&dma->qinfo, &transfer);
			} while(ret != true);
			debug_print("m2s enqueue successful\n");
			if(!cb) {
				sem_wait(&transfer->tf_status);
				sem_destroy(&transfer->tf_status);
			}
		}
	}
	else if (type == FPGA_ST_TO_HOST_MM) {
		if(IS_DMA_ALIGNED(transfer->src)) {
			do {
				ret = enqueue(&dma->qinfo, &transfer);
			} while(ret != true);
			debug_print("s2m enqueue successful\n");
			if(!cb) {
				sem_wait(&transfer->tf_status);
				sem_destroy(&transfer->tf_status);
			}
		}
	}
return res;
}
