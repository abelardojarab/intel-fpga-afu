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
#include <math.h>
#include <safe_string/safe_string.h>
#include "fpga_dma_st_internal.h"
#include "fpga_dma.h"
#include "tbb/concurrent_queue.h"

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

#define ON_ERR_RETURN(res, desc)\
do {\
	if ((res) != FPGA_OK) {\
		error_print("Error %s: %s\n", (desc), fpgaErrStr(res));\
		return(res);\
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

/**
* local_memcpy
*
* @brief                memcpy using SSE2 or REP MOVSB
* @param[in] dst        Pointer to the destination memory
* @param[in] src        Pointer to the source memory
* @param[in] n          Size in bytes
* @return dst
*
*/
void *local_memcpy(void *dst, void *src, size_t n)
{
#ifdef USE_MEMCPY
	return memcpy(dst, src, n);
#else
	void *ldst = dst;
	void *lsrc = (void *)src;
	if (n >= MIN_SSE2_SIZE) // Arbitrary crossover performance point
	{
		debug_print("copying 0x%lx bytes with SSE2 (src=%p, dst=%p)\n", (uint64_t) ALIGN_TO_CL(n), src, dst);
		aligned_block_copy_sse2((int64_t * __restrict) dst, (int64_t * __restrict) src, ALIGN_TO_CL(n));
		ldst = (void *)((uint64_t) dst + ALIGN_TO_CL(n));
		lsrc = (void *)((uint64_t) src + ALIGN_TO_CL(n));
		n -= ALIGN_TO_CL(n);
	}

	if (n)
	{
		register unsigned long int dummy;
		debug_print("copying 0x%lx bytes with REP MOVSB\n", n);
		__asm__ __volatile__("rep movsb\n":"=&D"(ldst), "=&S"(lsrc), "=&c"(dummy):"0"(ldst), "1"(lsrc), "2"(n):"memory");
	}

	return dst;
#endif
}

/**
* MMIOWrite64Blk
*
* @brief                Writes a block of 64-bit values to FPGA MMIO space
* @param[in] dma        Handle to the FPGA DMA object
* @param[in] device     FPGA address
* @param[in] host       Host buffer address
* @param[in] count      Size in bytes
* @return fpga_result FPGA_OK on success, return code otherwise
*
*/
static fpga_result MMIOWrite64Blk(fpga_dma_handle_t dma_h, uint64_t device,
				uint64_t host, uint64_t bytes)
{
	assert(IS_ALIGNED_QWORD(device));
	assert(IS_ALIGNED_QWORD(bytes));

	uint64_t *haddr = (uint64_t *) host;
	uint64_t i;
	fpga_result res = FPGA_OK;

#ifndef USE_ASE
	volatile uint64_t *dev_addr = HOST_MMIO_64_ADDR(dma_h, device);
#endif

	//debug_print("copying %lld bytes from 0x%p to 0x%p\n",(long long int)bytes, haddr, (void *)device);
	for (i = 0; i < bytes / sizeof(uint64_t); i++) {
#ifdef USE_ASE
		res = fpgaWriteMMIO64(dma_h->fpga_h, dma_h->mmio_num, device, *haddr);
		ON_ERR_RETURN(res, "fpgaWriteMMIO64");
		haddr++;
		device += sizeof(uint64_t);
#else
		*dev_addr++ = *haddr++;
#endif
	}
	return res;
}


/**
* MMIORead64Blk
*
* @brief                Reads a block of 64-bit values from FPGA MMIO space
* @param[in] dma        Handle to the FPGA DMA object
* @param[in] device     FPGA address
* @param[in] host       Host buffer address
* @param[in] count      Size in bytes
* @return fpga_result FPGA_OK on success, return code otherwise
*
*/
static fpga_result MMIORead64Blk(fpga_dma_handle_t dma_h, uint64_t device,
					uint64_t host, uint64_t bytes)
{
	assert(IS_ALIGNED_QWORD(device));
	assert(IS_ALIGNED_QWORD(bytes));

	uint64_t *haddr = (uint64_t *) host;
	uint64_t i;
	fpga_result res = FPGA_OK;

#ifndef USE_ASE
	volatile uint64_t *dev_addr = HOST_MMIO_64_ADDR(dma_h, device);
#endif

	//debug_print("copying %lld bytes from 0x%p to 0x%p\n",(long long int)bytes, (void *)device, haddr);
	for (i = 0; i < bytes / sizeof(uint64_t); i++) {
#ifdef USE_ASE
		res = fpgaReadMMIO64(dma_h->fpga_h, dma_h->mmio_num, device, haddr);
		ON_ERR_RETURN(res, "fpgaReadMMIO64");
		haddr++;
		device += sizeof(uint64_t);
#else
		*haddr++ = *dev_addr++;
#endif
	}
	return res;
}


// Public APIs
fpga_result fpgaCountDMAChannels(fpga_handle fpga, size_t *count) {
	// Discover total# DMA channels by traversing the device feature list
	// We may encounter one or more BBBs during discovery
	// Populate the count
	fpga_result res = FPGA_OK;
	uint64_t offset = 0;
	bool end_of_list = false;
	uint64_t dfh = 0;
	uint64_t feature_uuid_lo, feature_uuid_hi;

	if(!fpga) {
		FPGA_DMA_ST_ERR("Invalid FPGA handle");
		return FPGA_INVALID_PARAM;
	}

	if(!count) {
		FPGA_DMA_ST_ERR("Invalid pointer to count");
		return FPGA_INVALID_PARAM;
	}

#ifndef USE_ASE
	uint64_t mmio_va;

	res = fpgaMapMMIO(fpga, 0, (uint64_t **)&mmio_va);
	ON_ERR_GOTO(res, out, "fpgaMapMMIO");
#endif
	// Discover DMA BBB channels by traversing the device feature list
	do {
#ifndef USE_ASE
		// Read the next feature header
		dfh = *((volatile uint64_t *)((uint64_t)mmio_va + (uint64_t)(offset)));

		// Read the current feature's UUID
		feature_uuid_lo = *((volatile uint64_t *)((uint64_t)mmio_va + (uint64_t)(offset + 8)));
		feature_uuid_hi = *((volatile uint64_t *)((uint64_t)mmio_va + (uint64_t)(offset + 16)));
#else
		uint32_t mmio_no = 0;
		// Read the next feature header
		res = fpgaReadMMIO64(fpga, mmio_no, offset, &dfh);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");

		// Read the current feature's UUID
		res = fpgaReadMMIO64(fpga, mmio_no, offset + 8, &feature_uuid_lo);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");

		res = fpgaReadMMIO64(fpga, mmio_no, offset + 16, &feature_uuid_hi);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");
#endif
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

typedef struct _open_channels {
	struct _open_channels *next;
	uint32_t ch_num;
} open_channels;

open_channels *head;

void assign_hw_desc(msgdma_sw_desc_t *sw_desc, msgdma_hw_descp_t *hw_descp) {
	// update descriptor parameters
	hw_descp->hw_desc->src = sw_desc->transfer->src;
	hw_descp->hw_desc->dst = sw_desc->transfer->dst;
	hw_descp->hw_desc->len = sw_desc->transfer->len;
	hw_descp->hw_desc->wr_stride = 1;
	hw_descp->hw_desc->rd_stride = 1;

	if (sw_desc->transfer->tx_ctrl == GENERATE_SOP) {
		hw_descp->hw_desc->ctrl.generate_sop = 1;
		hw_descp->hw_desc->ctrl.generate_eop = 0;
	}
	else if (sw_desc->transfer->tx_ctrl == GENERATE_EOP) {
		hw_descp->hw_desc->ctrl.generate_sop = 0;
		hw_descp->hw_desc->ctrl.generate_eop = 1;
	}
	else if (sw_desc->transfer->tx_ctrl == GENERATE_SOP_AND_EOP) {
		hw_descp->hw_desc->ctrl.generate_sop = 1;
		hw_descp->hw_desc->ctrl.generate_eop = 1;
	} else {
		hw_descp->hw_desc->ctrl.generate_sop = 0;
		hw_descp->hw_desc->ctrl.generate_eop = 0;
	}

	hw_descp->hw_desc->ctrl.go = 1;
	hw_descp->hw_desc->owned_by_hw = 1;
	// hack - push just 1 descriptor
	hw_descp->hw_desc->block_size = 0;
	hw_descp->hw_desc->format = 0x3; //2'b11
	sw_desc->hw_descp = hw_descp;
}

static msgdma_sw_desc* init_sw_desc(fpga_dma_transfer_t transfer) {
	msgdma_sw_desc_t *sw_desc = (msgdma_sw_desc_t*)malloc(sizeof(msgdma_sw_desc_t));
	if(!sw_desc)
		return NULL;

	sem_init(&sw_desc->tf_status, 1, TRANSFER_PENDING);
	sw_desc->transfer = (struct fpga_dma_transfer*)malloc(sizeof(struct fpga_dma_transfer));
	if(!sw_desc->transfer) {
		sem_destroy(&sw_desc->tf_status);
		free(sw_desc);
	}
		
 	memcpy(sw_desc->transfer, transfer, sizeof(struct fpga_dma_transfer));
	sw_desc->kill_worker = false;
	return sw_desc;
}

static void destroy_sw_desc(msgdma_sw_desc *sw_desc) {
	sem_destroy(&sw_desc->tf_status);
	free(sw_desc->transfer);
	free(sw_desc);	
}

static void dump_hw_desc(int i, msgdma_hw_desc_t *desc)
{
	debug_print("desc id = %d\n", i);
	// word 0 
	debug_print("format = %d\n", desc->format);
	debug_print("block size = %d\n", desc->block_size);
	debug_print("owned by hw = %d\n", desc->owned_by_hw);

	// word 1
	debug_print("src = %lx\n", desc->src);

	// word 2
	debug_print("dst = %lx\n", desc->dst);

	// word 3
	debug_print("len = %ld\n", desc->len);

	// word 7
	debug_print("next_desc = %lx\n", desc->next_desc);
	
}



static void *dispatcherWorker(void* dma_handle) {
	fpga_dma_handle_t dma_h = (fpga_dma_handle_t )dma_handle;

	while(!dma_h->init)
		usleep(10);

	debug_print("started dispatcher worker\n");
	while (1) {
		while(dma_h->ingress_queue.empty());
		msgdma_sw_desc_t *sw_desc;
		msgdma_hw_descp_t *hw_descp;	
		if(dma_h->ingress_queue.try_pop(sw_desc)) {
			// assign a free hardware descriptor to this transfer
			while(dma_h->free_desc.empty());
			dma_h->free_desc.try_pop(hw_descp);
			
			assign_hw_desc(sw_desc, hw_descp);

			// dump hardware descriptor for debug
			dump_hw_desc(0, sw_desc->hw_descp->hw_desc);

			// push to pending queue
			dma_h->pending_queue.push(sw_desc);
			if(sw_desc->kill_worker)
				break;
		}
	}
	return dma_h;
}

static void *completionWorker(void* dma_handle) {
	fpga_dma_handle_t dma_h = (fpga_dma_handle_t )dma_handle;

	while(!dma_h->init)
		usleep(10);

	debug_print("started completion worker\n");
	while (1) {
		msgdma_sw_desc_t *sw_desc;
		while(dma_h->pending_queue.empty());
		if(dma_h->pending_queue.try_pop(sw_desc)) {
			//printf("Got transfer = %ld\n", sw_desc->transfer->src);
			if(sw_desc->kill_worker)
				break;

			debug_print("owned by hw is %d\n", sw_desc->hw_descp->hw_desc->owned_by_hw);
			int timeout = 5;
			while((sw_desc->hw_descp->hw_desc->owned_by_hw == 1) && --timeout) {
				debug_print("waiting hw\n");
				sleep(1);
			}
			if(timeout == 0)
				printf("hw timeout :(\n");	
			sw_desc->hw_descp->hw_desc->owned_by_hw = 0;
			// return hw_descp to free pool
			dma_h->free_desc.push(sw_desc->hw_descp);

			// mark transfer complete
			sem_post(&sw_desc->tf_status);
			if(sw_desc->transfer->cb) {
				sw_desc->transfer->cb(NULL, NULL);
				destroy_sw_desc(sw_desc);
			}			
		}
	}
	return dma_h;
}


fpga_result fpgaDMAOpen(fpga_handle fpga, uint64_t dma_channel_index, fpga_dma_handle_t *dma) {
	fpga_result res = FPGA_OK;
	fpga_dma_handle_t dma_h;
	uint64_t channel_index = 0;
	int i = 0;
	bool end_of_list = false;
	bool dma_found = false;

	if(!fpga) {
		FPGA_DMA_ST_ERR("Invalid FPGA handle");
		return FPGA_INVALID_PARAM;
	}

	if(!dma) {
		FPGA_DMA_ST_ERR("Invalid pointer to DMA handle");
		return FPGA_INVALID_PARAM;
	}

	open_channels *nxt = head;
	while(NULL != nxt) {
		if(nxt->ch_num == dma_channel_index) {
			FPGA_DMA_ST_ERR("Attempt to open a channel that is already open");
			return FPGA_BUSY;
		}
		nxt = nxt->next;
	}

	// init the dma handle
	dma_h = new fpga_dma_handle();
	if(!dma_h) {
		return FPGA_NO_MEMORY;
	}
	
	dma_h->fpga_h = fpga;
	dma_h->mmio_num = 0;
	dma_h->mmio_offset = 0;
	dma_h->init = false;

#ifndef USE_ASE
	res = fpgaMapMMIO(dma_h->fpga_h, 0, (uint64_t **)&dma_h->mmio_va);
	ON_ERR_GOTO(res, out, "fpgaMapMMIO");
#endif

	dfh_feature_t dfh;
	uint64_t offset;
	offset = dma_h->mmio_offset;
	do {
		// Read the next feature header
		res = MMIORead64Blk(dma_h, offset, (uint64_t)&dfh, sizeof(dfh));
		ON_ERR_GOTO(res, out, "MMIORead64Blk");

		if (_fpga_dma_feature_is_bbb(dfh.dfh) &&
			(((dfh.feature_uuid_lo == M2S_DMA_UUID_L) && (dfh.feature_uuid_hi == M2S_DMA_UUID_H)) ||
			((dfh.feature_uuid_lo == S2M_DMA_UUID_L) && (dfh.feature_uuid_hi == S2M_DMA_UUID_H))) ) {

			// Found one. Record it.
			if(channel_index == dma_channel_index) {
				dma_h->dma_base = offset;
				if ((dfh.feature_uuid_lo == M2S_DMA_UUID_L) && (dfh.feature_uuid_hi == M2S_DMA_UUID_H))
					dma_h->ch_type=TX_ST;
				else if ((dfh.feature_uuid_lo == S2M_DMA_UUID_L) && (dfh.feature_uuid_hi == S2M_DMA_UUID_H)) {
					dma_h->ch_type=RX_ST;
				}
				dma_h->dma_csr_base = dma_h->dma_base + FPGA_DMA_CSR;
				dma_h->dma_desc_base = dma_h->dma_base + FPGA_DMA_DESC;
				dma_h->dma_prefetcher_base = dma_h->dma_base + FPGA_DMA_PREFETCHER;
				dma_found = true;
				dma_h->dma_channel = dma_channel_index;
				debug_print("DMA Base Addr = %08lx\n", dma_h->dma_base);
				break;
			} else {
				channel_index += 1;
			}
		}

		// End of the list?
		end_of_list = _fpga_dma_feature_eol(dfh.dfh);
		// Move to the next feature header
		offset = offset + _fpga_dma_feature_next(dfh.dfh);
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

	if(pthread_mutex_init(&dma_h->dma_mutex, NULL)) {
		ON_ERR_GOTO(FPGA_EXCEPTION, out, "pthread mutex init failed");
	}

	// Allocate descriptor block memory
	dma_h->block_mem = (msgdma_block_mem_t*)malloc(sizeof(msgdma_block_mem_t) * FPGA_DMA_MAX_BLOCKS);
	if(!dma_h->block_mem)
		ON_ERR_GOTO(FPGA_NO_MEMORY, out, "allocating hw desc block memory");
	
	int psize;
	psize = getpagesize();
	uint64_t block_size;
	block_size = (uint64_t)(psize / sizeof(msgdma_hw_desc_t));
	debug_print("pagesize = %d, block size = %ld\n", psize, block_size);
	for(i = 0; i < FPGA_DMA_MAX_BLOCKS; i++) {
		res = fpgaPrepareBuffer(dma_h->fpga_h, psize, (void **)&(dma_h->block_mem[i].block_va), &dma_h->block_mem[i].block_wsid, 0);
		ON_ERR_GOTO(res, out, "fpgaPrepareBuffer");

		res = fpgaGetIOAddress(dma_h->fpga_h, dma_h->block_mem[i].block_wsid, &dma_h->block_mem[i].block_iova);
		ON_ERR_GOTO(res, rel_buf, "fpgaGetIOAddress");
		debug_print("allocated block %d va = %p, wsid=%lx, iova=%lx\n", i, dma_h->block_mem[i].block_va, dma_h->block_mem[i].block_wsid, dma_h->block_mem[i].block_iova);
	}

	// populate hardware descriptor chain
	uint64_t next_block_iova;
	for(i = 0; i < FPGA_DMA_MAX_BLOCKS; i++) {
		// link blocks
		msgdma_hw_desc_t *cur_block = (msgdma_hw_desc_t*)dma_h->block_mem[i].block_va;
		if(i == (FPGA_DMA_MAX_BLOCKS - 1)) // loop last block to first
			next_block_iova = dma_h->block_mem[0].block_iova;
		else
			next_block_iova = dma_h->block_mem[i+1].block_iova;
		
		// initalize all descriptors in block
		memset(dma_h->block_mem[i].block_va, 0, block_size);

		cur_block->next_desc = next_block_iova;
		msgdma_hw_desc_t *first = (msgdma_hw_desc_t*)(dma_h->block_mem[i].block_va);
		msgdma_hw_desc_t *last = first + (FPGA_DMA_MAX_BLOCKS - 1);

		//if(FPGA_DMA_MAX_BLOCKS == 1) {
		//	first->format = 0x3;
		//} else {
		//	first->format = 0x1;
		//	last->format = 0x2;
		//}	

		// dump descriptor for debug		
		//dump_hw_desc(i, cur_block);
	}

	// populate free descriptor pool
	msgdma_hw_descp_t *tmp;
	uint64_t block_id, desc_id;
	for(block_id = 0; block_id < FPGA_DMA_MAX_BLOCKS; block_id++) {
		for(desc_id = 0; desc_id < block_size; desc_id++) {
			tmp = (msgdma_hw_descp_t*) malloc(sizeof(struct msgdma_hw_descp));
			if(!tmp) {
				ON_ERR_GOTO(FPGA_NO_MEMORY, out, "Pool alloc: No memory");
			}
			tmp->hw_block_id = block_id;
			tmp->hw_desc_id = desc_id;
			tmp->hw_desc = (msgdma_hw_desc_t*)dma_h->block_mem[block_id].block_va + desc_id;
			dma_h->free_desc.push(tmp);
		}
	}

	if(pthread_create(&dma_h->ingress_id, NULL, dispatcherWorker, (void*)dma_h) != 0) {
		res = FPGA_EXCEPTION;
		ON_ERR_GOTO(res, rel_buf, "pthread_create dispatcherWorker");
	}

	if(pthread_create(&dma_h->pending_id, NULL, completionWorker, (void*)dma_h) != 0) {
		res = FPGA_EXCEPTION;
		ON_ERR_GOTO(res, rel_buf, "pthread_create completionWorker");
	}
	#if EMU_MODE
	// kick dma emulation thread
	//if(pthread_create(&dma_h->emu_work_id, NULL, emulationWorker, (void*)dma_h) != 0) {
	//	res = FPGA_EXCEPTION;
	//	ON_ERR_GOTO(res, rel_buf, "emulationWorker pthread_create");
	//}
	#else
	// write start address the fetch engine reads from
	uint64_t start_loc;
	start_loc = dma_h->block_mem[0].block_iova;
	res = MMIOWrite64Blk(dma_h, PREFETCHER_START(dma_h), (uint64_t)&start_loc, sizeof(start_loc));
	ON_ERR_GOTO(res, rel_buf, "setting start_loc");

	// enable fetch engine (read-modify-write?)
	msgdma_prefetcher_ctrl_t prefetcher_ctrl;
	prefetcher_ctrl = {0};
	prefetcher_ctrl.ct.fetch_en = 1;
	res = MMIOWrite64Blk(dma_h, PREFETCHER_CTRL(dma_h), (uint64_t)&prefetcher_ctrl.reg, sizeof(prefetcher_ctrl.reg));
	ON_ERR_GOTO(res, out, "enabling fetch engine");
	#endif

	// Mark this channel as in-use
	open_channels *chan;
	chan = (open_channels *)calloc(1, sizeof(open_channels));
	if (!chan) {
		ON_ERR_GOTO(FPGA_NO_MEMORY, rel_buf, "allocating open_channels memory");
	}
	chan->ch_num = dma_h->dma_channel;
	if(NULL == head) {
		head = chan;
	} else {
		open_channels *nxt = head;
		while(NULL != nxt->next) {
			nxt = nxt->next;
		}
		nxt->next = chan;
	}
	dma_h->init = true;
	return FPGA_OK;

rel_buf:
	for(i=0; i< FPGA_DMA_MAX_BLOCKS; i++) {
		res = fpgaReleaseBuffer(dma_h->fpga_h, dma_h->block_mem[i].block_wsid);
		ON_ERR_GOTO(res, out, "fpgaReleaseBuffer");
	}
out:
	if(dma_h->block_mem)
		free(dma_h->block_mem);

	if(!dma_found)
		delete dma_h;
	return res;
}

fpga_result fpgaDMAClose(fpga_dma_handle_t dma_h) {
	fpga_result res = FPGA_OK;
	int i = 0;
	if(!dma_h) {
		FPGA_DMA_ST_ERR("Invalid DMA handle");
		return FPGA_INVALID_PARAM;
	}

	if(!dma_h->fpga_h) {
		FPGA_DMA_ST_ERR("Invalid FPGA handle");
		res = FPGA_INVALID_PARAM;
		goto out;
	}
	if(NULL == head) {
		FPGA_DMA_ST_ERR("Attempt to close DMA channel that was not open");
		return FPGA_INVALID_PARAM;
	}
	
	// Mark channel as no longer in use
	open_channels *tmp;
	tmp = head;
	open_channels *prev;
	prev = NULL;
	while(NULL != tmp) {
		if(tmp->ch_num == dma_h->dma_channel) {
			break;
		}
		prev = tmp;
		tmp = tmp->next;
	}

	if(NULL == tmp) {
		FPGA_DMA_ST_ERR("Attempt to close DMA channel that was not open");
		return FPGA_INVALID_PARAM;
	}

	if(NULL == prev) {
		head = tmp->next;
	} else {
		prev->next = tmp->next;
	}
	free(tmp);

	void *th_retval;

	fpga_dma_transfer_t transfer;
	fpgaDMATransferInit(&transfer);
	static msgdma_sw_desc* sw_desc = init_sw_desc(transfer);
	sw_desc->kill_worker = true;
	dma_h->ingress_queue.push(sw_desc);
	pthread_join(dma_h->ingress_id, &th_retval);
	pthread_join(dma_h->pending_id, &th_retval);

	// Free buffers
	for(i=0; i<FPGA_DMA_MAX_BLOCKS; i++) {
		res = fpgaReleaseBuffer(dma_h->fpga_h, dma_h->block_mem[i].block_wsid);
		ON_ERR_GOTO(res, out, "fpgaReleaseBuffer failed");
	}

	// Free circular buffer pool
	#if 0
	if(dma_h->sw_desc_head) {
		msgdma_sw_desc_t *tmp = dma_h->sw_desc_head->next;
		// break chain
		dma_h->sw_desc_head->next = NULL;
		// free remaining list
		dma_h->sw_desc_head = tmp;
		while(dma_h->sw_desc_head) {
			tmp = dma_h->sw_desc_head->next;
			free(dma_h->sw_desc_head);
			dma_h->sw_desc_head = tmp;
		}
	}
	#endif
out:
	// Make sure double-close fails
	dma_h->dma_channel = INVALID_CHANNEL;
	free((void*)dma_h);
	return res;
}

fpga_result fpgaGetDMAChannelType(fpga_dma_handle_t dma, fpga_dma_channel_type_t *ch_type) {
	if(!dma) {
		FPGA_DMA_ST_ERR("Invalid DMA handle");
		return FPGA_INVALID_PARAM;
	}

	if(!ch_type) {
		FPGA_DMA_ST_ERR("Invalid pointer to channel type");
		return FPGA_INVALID_PARAM;
	}

	*ch_type = dma->ch_type;
	return FPGA_OK;
}

fpga_result fpgaDMATransferInit(fpga_dma_transfer_t *transfer) {
	fpga_result res = FPGA_OK;
	fpga_dma_transfer_t tmp;
	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid pointer to DMA transfer");
		return FPGA_INVALID_PARAM;
	}

	tmp = (fpga_dma_transfer_t)malloc(sizeof(struct fpga_dma_transfer));
	if(!tmp) {
		res = FPGA_NO_MEMORY;
		return res;
	}

	// Initialize default transfer attributes
	tmp->src = 0;
	tmp->dst = 0;
	tmp->len = 0;
	tmp->transfer_type = HOST_MM_TO_FPGA_ST;
	tmp->tx_ctrl = TX_NO_PACKET; // deterministic length
	tmp->rx_ctrl = RX_NO_PACKET; // deterministic length
	tmp->cb = NULL;
	tmp->context = NULL;
	tmp->rx_bytes = 0;
	tmp->eop_status = 0;

	if(pthread_mutex_init(&tmp->tf_mutex, NULL)) {
		//sem_destroy(&tmp->tf_status);
		free(tmp);
		return FPGA_EXCEPTION;
	}

	*transfer = tmp;
	return res;
}

fpga_result fpgaDMATransferReset(fpga_dma_transfer_t transfer) {
	fpga_result res = FPGA_OK;

	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer");
		return FPGA_INVALID_PARAM;
	}

	if(pthread_mutex_lock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_lock failed");
		return FPGA_EXCEPTION;
	}

	transfer->src = 0;
	transfer->dst = 0;
	transfer->len = 0;
	transfer->transfer_type = HOST_MM_TO_FPGA_ST;
	transfer->tx_ctrl = TX_NO_PACKET; // deterministic length
	transfer->rx_ctrl = RX_NO_PACKET; // deterministic length
	transfer->cb = NULL;
	transfer->context = NULL;
	transfer->rx_bytes = 0;
	transfer->eop_status = 0;

	if(pthread_mutex_unlock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_unlock failed");
		return FPGA_EXCEPTION;
	}

	return res;
}

fpga_result fpgaDMATransferDestroy(fpga_dma_transfer_t transfer) {
	fpga_result res = FPGA_OK;

	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer");
		return FPGA_INVALID_PARAM;
	}
	
	if(pthread_mutex_lock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_destroy");
		return FPGA_EXCEPTION;
	}

	if(pthread_mutex_unlock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_destroy");
		return FPGA_EXCEPTION;
	}

	if(pthread_mutex_destroy(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_destroy");
		return FPGA_EXCEPTION;
	}
	free(transfer);

	return res;
}

fpga_result fpgaDMATransferSetSrc(fpga_dma_transfer_t transfer, uint64_t src) {
	fpga_result res = FPGA_OK;

	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer");
		return FPGA_INVALID_PARAM;
	}

	if(pthread_mutex_lock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_lock failed");
		return FPGA_EXCEPTION;
	}
	transfer->src = src;
	if(pthread_mutex_unlock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_unlock failed");
		return FPGA_EXCEPTION;
	}
	return res;
}

fpga_result fpgaDMATransferSetDst(fpga_dma_transfer_t transfer, uint64_t dst) {
	fpga_result res = FPGA_OK;

	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer");
		return FPGA_INVALID_PARAM;
	}

	if(pthread_mutex_lock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_lock failed");
		return FPGA_EXCEPTION;
	}
	transfer->dst = dst;
	if(pthread_mutex_unlock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_unlock failed");
		return FPGA_EXCEPTION;
	}
	return res;
}

fpga_result fpgaDMATransferSetLen(fpga_dma_transfer_t transfer, uint64_t len) {
	fpga_result res = FPGA_OK;

	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer");
		return FPGA_INVALID_PARAM;
	}

	if(pthread_mutex_lock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_lock failed");
		return FPGA_EXCEPTION;
	}
	transfer->len = len;
	if(pthread_mutex_unlock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_unlock failed");
		return FPGA_EXCEPTION;
	}
	return res;
}

fpga_result fpgaDMATransferSetTransferType(fpga_dma_transfer_t transfer, fpga_dma_transfer_type_t type) {
	fpga_result res = FPGA_OK;

	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer");
		return FPGA_INVALID_PARAM;
	}

	if(type >= FPGA_MAX_TRANSFER_TYPE) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer type");
		return FPGA_INVALID_PARAM;
	}

	if(!(type == HOST_MM_TO_FPGA_ST || type == FPGA_ST_TO_HOST_MM)) {
		FPGA_DMA_ST_ERR("Transfer unsupported");
		return FPGA_NOT_SUPPORTED;
	}

	if(pthread_mutex_lock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_lock failed");
		return FPGA_EXCEPTION;
	}
	transfer->transfer_type = type;
	if(pthread_mutex_unlock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_unlock failed");
		return FPGA_EXCEPTION;
	}
	return res;
}

fpga_result fpgaDMATransferSetTxControl(fpga_dma_transfer_t transfer, fpga_dma_tx_ctrl_t tx_ctrl) {
	fpga_result res = FPGA_OK;

	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer");
		return FPGA_INVALID_PARAM;
	}

	if(tx_ctrl >= FPGA_MAX_TX_CTRL) {
		FPGA_DMA_ST_ERR("Invalid TX Ctrl");
		return FPGA_INVALID_PARAM;
	}

	if(pthread_mutex_lock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_lock failed");
		return FPGA_EXCEPTION;
	}
	transfer->tx_ctrl = tx_ctrl;
	if(pthread_mutex_unlock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_unlock failed");
		return FPGA_EXCEPTION;
	}
	return res;
}

fpga_result fpgaDMATransferSetRxControl(fpga_dma_transfer_t transfer, fpga_dma_rx_ctrl_t rx_ctrl) {
	fpga_result res = FPGA_OK;

	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer");
		return FPGA_INVALID_PARAM;
	}

	if(rx_ctrl >= FPGA_MAX_RX_CTRL) {
		FPGA_DMA_ST_ERR("Invalid RX Ctrl");
		return FPGA_INVALID_PARAM;
	}

	if(pthread_mutex_lock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_lock failed");
		return FPGA_EXCEPTION;
	}
	transfer->rx_ctrl = rx_ctrl;
	if(pthread_mutex_unlock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_unlock failed");
		return FPGA_EXCEPTION;
	}

	return res;
}

fpga_result fpgaDMATransferSetTransferCallback(fpga_dma_transfer_t transfer, fpga_dma_transfer_cb cb, void *ctxt) {
	fpga_result res = FPGA_OK;

	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer");
		return FPGA_INVALID_PARAM;
	}

	if(pthread_mutex_lock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_lock failed");
		return FPGA_EXCEPTION;
	}
	transfer->cb = cb;
	transfer->context = ctxt;
	if(pthread_mutex_unlock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_unlock failed");
		return FPGA_EXCEPTION;
	}
	return res;
}

fpga_result fpgaDMATransferGetBytesTransferred(fpga_dma_transfer_t transfer, size_t *rx_bytes) {

	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer");
		return FPGA_INVALID_PARAM;
	}

	if(!rx_bytes) {
		FPGA_DMA_ST_ERR("Invalid pointer to transferred bytes");
		return FPGA_INVALID_PARAM;
	}

	if(pthread_mutex_lock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_lock failed");
		return FPGA_EXCEPTION;
	}

	*rx_bytes = transfer->rx_bytes;

	if(pthread_mutex_unlock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_unlock failed");
		return FPGA_EXCEPTION;
	}

	return FPGA_OK;
}

fpga_result fpgaDMATransferCheckEopArrived(fpga_dma_transfer_t transfer, bool *eop_arrived) {

	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer");
		return FPGA_INVALID_PARAM;
	}

	if(!eop_arrived) {
		FPGA_DMA_ST_ERR("Invalid pointer to eop status");
		return FPGA_INVALID_PARAM;
	}

	if(pthread_mutex_lock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_lock failed");
		return FPGA_EXCEPTION;
	}
	
	*eop_arrived = transfer->eop_status;

	if(pthread_mutex_unlock(&transfer->tf_mutex)) {
		FPGA_DMA_ST_ERR("pthread_mutex_unlock failed");
		return FPGA_EXCEPTION;
	}

	return FPGA_OK;
}

fpga_result fpgaDMATransfer(fpga_dma_handle_t dma, fpga_dma_transfer_t transfer) {
	if(!dma) {
		FPGA_DMA_ST_ERR("Invalid DMA handle");
		return FPGA_INVALID_PARAM;
	}

	if(!transfer) {
		FPGA_DMA_ST_ERR("Invalid DMA transfer");
		return FPGA_INVALID_PARAM;
	}

	if(!(transfer->transfer_type == HOST_MM_TO_FPGA_ST || transfer->transfer_type == FPGA_ST_TO_HOST_MM)) {
		FPGA_DMA_ST_ERR("Transfer unsupported");
		return FPGA_NOT_SUPPORTED;
	}

	if(dma->ch_type == RX_ST && transfer->transfer_type == HOST_MM_TO_FPGA_ST) {
		FPGA_DMA_ST_ERR("Incompatible transfer on stream to memory DMA channel");
		return FPGA_INVALID_PARAM;
	}

	if(dma->ch_type == TX_ST && transfer->transfer_type == FPGA_ST_TO_HOST_MM) {
		FPGA_DMA_ST_ERR("Incompatible transfer on memory to stream DMA channel");
		return FPGA_INVALID_PARAM;
	}

	// Avalon ST does not allow signalling of partial data for non-packet transfers (transfers without SOP/EOP).
	if(((transfer->tx_ctrl == TX_NO_PACKET && dma->ch_type == TX_ST) || 
		(transfer->rx_ctrl == RX_NO_PACKET && dma->ch_type == RX_ST)) && ((transfer->len % 64) != 0)) {
		FPGA_DMA_ST_ERR("Incompatible transfer length for transfer type NO_PKT");
		return FPGA_INVALID_PARAM;
	}

	// create a copy of the buffer and enqueue to ingress queue
	msgdma_sw_desc *sw_desc = init_sw_desc(transfer);
	dma->ingress_queue.push(sw_desc);

	// Blocking transfer
	if(!sw_desc->transfer->cb) {
		//printf("waiting transfer completion on sw_desc = %p, sem = %p\n", sw_desc, &sw_desc->tf_status);
		sem_wait(&sw_desc->tf_status);
		destroy_sw_desc(sw_desc);
		return FPGA_OK;
	} else {
		//printf("returning tf = %ld\n", sw_desc->transfer->src);
		return FPGA_OK;
	}
}
