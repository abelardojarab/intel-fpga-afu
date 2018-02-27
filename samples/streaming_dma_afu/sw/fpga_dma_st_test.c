// Copyright(c) 2017, Intel Corporation
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
// ARE DISCLAIMED.	IN NO EVENT  SHALL THE COPYRIGHT OWNER	OR CONTRIBUTORS BE
// LIABLE  FOR	ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,	EXEMPLARY,	OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,	BUT  NOT LIMITED  TO,  PROCUREMENT	OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,	DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,	WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,	EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#include <string.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>
#include <time.h>
#include "fpga_dma.h"
/**
 * \fpga_dma_st_test.c
 * \brief Streaming DMA test
 */

#include <stdlib.h>
#include <assert.h>

#define DMA_AFU_ID				"EB59BF9D-B211-4A4E-B3E3-753CE68634BA"
#define TEST_BUF_SIZE (10*1024*1024)
#define ASE_TEST_BUF_SIZE (4*1024)

static uint64_t count=0;

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

// Callback 
static void transferComplete(void *ctx) {
	return;
}

static void fill_buffer(char *buf, size_t size) {
	size_t i=0;
	// use a deterministic seed to generate pseudo-random numbers
	srand(99);

	for(i=0; i<size; i++) {
		*buf = rand()%256;
		buf++;
	}
}

int main(int argc, char *argv[]) {
	fpga_result res = FPGA_OK;
	fpga_dma_handle_t *dma_h;
	int i;
	uint64_t transfer_len = 0;
	fpga_properties filter = NULL;
	fpga_token afc_token;
	fpga_handle afc_h;
	fpga_guid guid;
	uint32_t num_matches;
	volatile uint64_t *mmio_ptr = NULL;
	uint64_t *dma_tx_buf_ptr = NULL;
	uint64_t *dma_rx_buf_ptr = NULL;
	uint32_t use_ase;

	if(argc < 2) {
		printf("Usage: fpga_dma_test <use_ase = 1 (simulation only), 0 (hardware)>");
		return 1;
	}
	use_ase = atoi(argv[1]);
	if(use_ase) {
		printf("Running test in ASE mode\n");
		transfer_len = ASE_TEST_BUF_SIZE;
	} else {
		printf("Running test in HW mode\n");
		transfer_len = TEST_BUF_SIZE;
	}

	// enumerate the afc
	if(uuid_parse(DMA_AFU_ID, guid) < 0) {
		return 1;
	}

	res = fpgaGetProperties(NULL, &filter);
	ON_ERR_GOTO(res, out, "fpgaGetProperties");

	res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesSetObjectType");

	res = fpgaPropertiesSetGUID(filter, guid);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesSetGUID");

	res = fpgaEnumerate(&filter, 1, &afc_token, 1, &num_matches);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaEnumerate");

	if(num_matches < 1) {
		printf("Error: Number of matches < 1");
		ON_ERR_GOTO(FPGA_INVALID_PARAM, out_destroy_prop, "num_matches<1");
	}

	// open the AFC
	res = fpgaOpen(afc_token, &afc_h, 0);
	ON_ERR_GOTO(res, out_destroy_tok, "fpgaOpen");

	if(!use_ase) {
		res = fpgaMapMMIO(afc_h, 0, (uint64_t**)&mmio_ptr);
		ON_ERR_GOTO(res, out_close, "fpgaMapMMIO");
	}

	// reset AFC
	res = fpgaReset(afc_h);
	ON_ERR_GOTO(res, out_unmap, "fpgaReset");

	// Enumerate DMA handles
	res = fpgaCountDMAChannels(afc_h, &count);
	ON_ERR_GOTO(res, out_unmap, "fpgaGetDMAChannels");
	
	if(count < 1) {
		printf("Error: DMA channels not found\n");
		ON_ERR_GOTO(FPGA_INVALID_PARAM, out_unmap, "count<1");
	}
	printf("No of DMA channels = %08lx\n", count);

	dma_h = (fpga_dma_handle_t*)malloc(sizeof(fpga_dma_handle_t)*count);

	res = fpgaDMAOpen(afc_h, 0, &dma_h[0]);
	ON_ERR_GOTO(res, out_unmap, "fpgaDMAOpen");

	res = fpgaDMAOpen(afc_h, 1, &dma_h[1]);
	ON_ERR_GOTO(res, out_unmap, "fpgaDMAOpen");

	dma_tx_buf_ptr = (uint64_t*)malloc(transfer_len);
	dma_rx_buf_ptr = (uint64_t*)malloc(transfer_len);
	if(!dma_tx_buf_ptr || !dma_rx_buf_ptr) {
		res = FPGA_NO_MEMORY;
		ON_ERR_GOTO(res, out_dma_close, "Error allocating memory");
	}

	fill_buffer((char*)dma_tx_buf_ptr, transfer_len);
	// Example DMA transfer (host to fpga, asynchronous)
	fpga_dma_transfer_t transfer;
	fpgaDMATransferInit(&transfer);
	fpgaDMATransferSetSrc(transfer, (uint64_t)dma_tx_buf_ptr);
	fpgaDMATransferSetDst(transfer, 0x0);
	fpgaDMATransferSetLen(transfer, transfer_len);
	fpgaDMATransferSetTransferType(transfer, HOST_MM_TO_FPGA_ST);
	fpgaDMATransferSetTxControl(transfer, TX_NO_PACKET);
	fpgaDMATransferSetTransferCallback(transfer, NULL);
	fpgaDMATransfer(dma_h[0], transfer, (fpga_dma_transfer_cb)&transferComplete, NULL);
	fpgaDMATransferDestroy(transfer);

out_dma_close:
	free(dma_tx_buf_ptr);
	free(dma_rx_buf_ptr);
	for(i=0; i<count; i++){
		if(dma_h[i]) {
			res = fpgaDMAClose(dma_h[i]);
			ON_ERR_GOTO(res, out_unmap, "fpgaDmaClose");
		}
	}

out_unmap:
	if(!use_ase) {
		res = fpgaUnmapMMIO(afc_h, 0);
		ON_ERR_GOTO(res, out_close, "fpgaUnmapMMIO");
	}

out_close:
	res = fpgaClose(afc_h);
	ON_ERR_GOTO(res, out_destroy_tok, "fpgaClose");

out_destroy_tok:
	res = fpgaDestroyToken(&afc_token);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaDestroyToken");

out_destroy_prop:
	res = fpgaDestroyProperties(&filter);
	ON_ERR_GOTO(res, out, "fpgaDestroyProperties");

out:
	return err_cnt;
}
