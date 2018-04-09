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
#include <unistd.h>
/**
 * \fpga_dma_st_test.c
 * \brief Streaming DMA test
 */

#include <stdlib.h>
#include <assert.h>
#include<semaphore.h>

#define DMA_AFU_ID				"EB59BF9D-B211-4A4E-B3E3-753CE68634BA"
#define TEST_BUF_SIZE (20*1024*1024)
#define ASE_TEST_BUF_SIZE (4*1024)

static uint64_t count=0;
sem_t cb_status;
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

int sendrxTransfer(fpga_dma_handle_t dma_h, fpga_dma_transfer_t rx_transfer, uint64_t src, uint64_t dst, uint64_t tf_len,fpga_dma_transfer_type_t tf_type, fpga_dma_rx_ctrl_t rx_ctrl, fpga_dma_transfer_cb cb) {
	fpga_result res = FPGA_OK;

	fpgaDMATransferSetSrc(rx_transfer, src);
	fpgaDMATransferSetDst(rx_transfer, dst);
	fpgaDMATransferSetLen(rx_transfer, tf_len);
	fpgaDMATransferSetTransferType(rx_transfer, tf_type);
	fpgaDMATransferSetRxControl(rx_transfer, rx_ctrl);
	fpgaDMATransferSetTransferCallback(rx_transfer, cb);
	res = fpgaDMATransfer(dma_h, rx_transfer, (fpga_dma_transfer_cb)&cb, NULL);
	return res;
}

int sendtxTransfer(fpga_dma_handle_t dma_h, fpga_dma_transfer_t tx_transfer, uint64_t src, uint64_t dst, uint64_t tf_len,fpga_dma_transfer_type_t tf_type, fpga_dma_tx_ctrl_t tx_ctrl, fpga_dma_transfer_cb cb) {
	fpga_result res = FPGA_OK;

	fpgaDMATransferSetSrc(tx_transfer, src);
	fpgaDMATransferSetDst(tx_transfer, dst);
	fpgaDMATransferSetLen(tx_transfer, tf_len);
	fpgaDMATransferSetTransferType(tx_transfer, tf_type);
	fpgaDMATransferSetTxControl(tx_transfer, tx_ctrl);
	fpgaDMATransferSetTransferCallback(tx_transfer, cb);
	res = fpgaDMATransfer(dma_h, tx_transfer, (fpga_dma_transfer_cb)&cb, NULL);
	return res;
}
fpga_result verify_buffer(char *buf, size_t size) {
	size_t i, rnum=0;
	srand(99);
	for(i=0; i<size; i++) {
		rnum = rand()%256;
		if((*buf&0xFF) != rnum) {
			printf("Invalid data at %zx Expected = %zx Actual = %x\n",i,rnum,(*buf&0xFF));
			return FPGA_INVALID_PARAM;
		}
		buf++;
	}
	printf("Buffer Verification Success!\n");
	return FPGA_OK;
}

void clear_buffer(char *buf, size_t size) {
	memset(buf, 0, size);
}

// Callback
static void rxtransferComplete(void *ctx) {
	sem_post(&cb_status);
}

static void txtransferComplete(void *ctx) {
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
	sem_init(&cb_status, 0, 0);
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
	fpga_dma_transfer_t rx_transfer;
	fpgaDMATransferInit(&rx_transfer);
	fpga_dma_transfer_t tx_transfer;
	fpgaDMATransferInit(&tx_transfer);

	// deterministic length transfer
	res = sendrxTransfer(dma_h[1], rx_transfer, 0, (uint64_t)dma_rx_buf_ptr, transfer_len, FPGA_ST_TO_HOST_MM, RX_NO_PACKET, rxtransferComplete);
	ON_ERR_GOTO(res, out_dma_close, "fpgaDMATransfer");

	res = sendtxTransfer(dma_h[0], tx_transfer, (uint64_t)dma_tx_buf_ptr, 0, transfer_len, HOST_MM_TO_FPGA_ST, TX_NO_PACKET, txtransferComplete);
	ON_ERR_GOTO(res, out_dma_close, "fpgaDMATransfer");

	sem_wait(&cb_status);
	verify_buffer((char*)dma_rx_buf_ptr, transfer_len);
	clear_buffer((char*)dma_rx_buf_ptr, transfer_len);

	// nondeterministic length transfer
	res = sendrxTransfer(dma_h[1], rx_transfer, 0, (uint64_t)dma_rx_buf_ptr, transfer_len, FPGA_ST_TO_HOST_MM, END_ON_EOP, rxtransferComplete);
	ON_ERR_GOTO(res, out_dma_close, "fpgaDMATransfer");

	res = sendtxTransfer(dma_h[0], tx_transfer, (uint64_t)dma_tx_buf_ptr, 0, transfer_len, HOST_MM_TO_FPGA_ST, GENERATE_EOP, txtransferComplete);
	ON_ERR_GOTO(res, out_dma_close, "fpgaDMATransfer");
	
	sem_wait(&cb_status);
	verify_buffer((char*)dma_rx_buf_ptr, transfer_len);
	clear_buffer((char*)dma_rx_buf_ptr, transfer_len);

	// non deterministic length transfer 2
	res = sendtxTransfer(dma_h[0], tx_transfer, (uint64_t)dma_tx_buf_ptr, 0, transfer_len, HOST_MM_TO_FPGA_ST, GENERATE_EOP, txtransferComplete);
	ON_ERR_GOTO(res, out_dma_close, "fpgaDMATransfer");

	res = sendrxTransfer(dma_h[1], rx_transfer, 0, (uint64_t)dma_rx_buf_ptr, transfer_len, FPGA_ST_TO_HOST_MM, END_ON_EOP, rxtransferComplete);
	ON_ERR_GOTO(res, out_dma_close, "fpgaDMATransfer");

	sem_wait(&cb_status);
	verify_buffer((char*)dma_rx_buf_ptr, transfer_len);
	clear_buffer((char*)dma_rx_buf_ptr, transfer_len);		

	// deterministic length transfer 
	res = sendrxTransfer(dma_h[1], rx_transfer, 0, (uint64_t)dma_rx_buf_ptr, transfer_len, FPGA_ST_TO_HOST_MM, RX_NO_PACKET, rxtransferComplete);
	ON_ERR_GOTO(res, out_dma_close, "fpgaDMATransfer");

	res = sendtxTransfer(dma_h[0], tx_transfer, (uint64_t)dma_tx_buf_ptr, 0, transfer_len, HOST_MM_TO_FPGA_ST, TX_NO_PACKET, txtransferComplete);
	ON_ERR_GOTO(res, out_dma_close, "fpgaDMATransfer");

	sem_wait(&cb_status);
	verify_buffer((char*)dma_rx_buf_ptr, transfer_len);
	clear_buffer((char*)dma_rx_buf_ptr, transfer_len);

	fpgaDMATransferDestroy(rx_transfer);
	fpgaDMATransferDestroy(tx_transfer);

out_dma_close:
	free(dma_tx_buf_ptr);
	free(dma_rx_buf_ptr);
	for(i=0; i<count; i++){
		if(dma_h[i]) {
			res = fpgaDMAClose(dma_h[i]);
			ON_ERR_GOTO(res, out_unmap, "fpgaDmaClose");
		}
	}
	free(dma_h);

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
