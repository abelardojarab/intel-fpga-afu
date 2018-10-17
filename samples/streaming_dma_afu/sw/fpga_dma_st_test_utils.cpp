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
/**
 * \fpga_dma_st_test_utils.c
 * \brief Streaming DMA test utils
 */
#include <math.h>
#include "fpga_dma_st_test_utils.h"
#include "fpga_dma_st_common.h"

static sem_t transfer_done;

static int err_cnt = 0;
#define ON_ERR_GOTO(res, label, desc)\
	do {\
		if ((res) != FPGA_OK) {\
			err_cnt++;\
			fprintf(stderr, "Error %s: %s\n", (desc), fpgaErrStr(res));\
			goto label;\
		}\
	} while (0)

static void transferComplete(void *ctx, void* status_ctx) {
	//tf_status status = (tf_status)status_ctx;
	//context.rcvd_bytes = status->rcvd_bytes;
	//context.eop_arrived = status->eop_arrived;
	//printf("Callback recieved\n");
	////sem_post(&transfer_done);
}

static fpga_result rxTransfer(fpga_dma_handle_t dma_h, fpga_dma_transfer_t rx_transfer,
	uint64_t src, uint64_t dst, uint64_t length, fpga_dma_transfer_type_t tf_type,
	fpga_dma_rx_ctrl_t rx_ctrl, fpga_dma_transfer_cb cb)
{
	fpga_result res = FPGA_OK;
	fpgaDMATransferSetSrc(rx_transfer, src);
	fpgaDMATransferSetDst(rx_transfer, dst);
	fpgaDMATransferSetLen(rx_transfer, length);
	fpgaDMATransferSetTransferType(rx_transfer, tf_type);
	fpgaDMATransferSetRxControl(rx_transfer, rx_ctrl);
	fpgaDMATransferSetTransferCallback(rx_transfer, cb, NULL);

	res = fpgaDMATransfer(dma_h, rx_transfer);
	ON_ERR_GOTO(res, out, "transfer failed\n");

	sem_wait(&transfer_done);
	sem_post(&transfer_done);
out:
	return res;
}

//Verify repeating pattern 0x00...0xFF of payload_size
static fpga_result verify_buffer(unsigned char *buf, size_t payload_size) {
	size_t i,j;
	unsigned char test_word = 0;
	while(payload_size) {
		test_word = 0x00;
		for (i = 0; i < PATTERN_LENGTH; i++) {
			for (j = 0; j < (PATTERN_WIDTH/sizeof(test_word)); j++) {
				if(!payload_size)
					goto out;
				if((*buf) != test_word) {
					printf("Invalid data at %zx Expected = %x Actual = %x\n",i,test_word,(*buf));
					return FPGA_EXCEPTION;
				}
				payload_size -= sizeof(test_word);
				buf++;
				test_word += 0x01;
			}
		}
	}
out:
	printf("S2M: Data Verification Success!\n");
	return FPGA_OK;
}


//Populate repeating pattern 0x00...0xFF of payload size
static void fill_buffer(unsigned char *buf, size_t payload_size) {
	size_t i,j;
	unsigned char test_word = 0;
	while(payload_size) {
		test_word = 0x00;
		for (i = 0; i < PATTERN_LENGTH; i++) {
			for (j = 0; j < (PATTERN_WIDTH/sizeof(test_word)); j++) {
				if(!payload_size)
					return;
				*buf = test_word;
				payload_size -= sizeof(test_word);
				buf++;
				test_word += 0x01;
			}
		}
	}
}

static void report_bandwidth(size_t size, double seconds) {
	double throughput = (double)size/((double)seconds*1000*1000);
	printf("\rBandwidth = %lf MB/s\n", throughput);
}

// return elapsed time
static double getTime(struct timespec start, struct timespec end) {
	uint64_t diff = 1000000000L * (end.tv_sec - start.tv_sec) + end.tv_nsec - start.tv_nsec;
	return (double) diff/(double)1000000000L;
}

static fpga_result prepare_checker(fpga_handle afc_h, uint64_t size)
{
	fpga_result res;

	res = populate_pattern_checker(afc_h);
	ON_ERR_GOTO(res, out, "populate_pattern_checker");
	debug_print("populated checker\n");

	res = stop_checker(afc_h);
	ON_ERR_GOTO(res, out, "stop_checker");
	debug_print("stopped checker\n");

	res = start_checker(afc_h, size);
	ON_ERR_GOTO(res, out, "start checker");
	debug_print("started checker\n");

out:
	return res;
}

static fpga_result wait_checker(fpga_handle afc_h)
{
	fpga_result res;

	debug_print("waiting checker\n");
	res = wait_for_checker_complete(afc_h);
	ON_ERR_GOTO(res, out, "wait checker complete");

	debug_print("stopping checker\n");
	res = stop_checker(afc_h);
out:
	return res;
}


static fpga_result prepare_generator(fpga_handle afc_h, uint64_t size)
{
	fpga_result res;
	res = populate_pattern_generator(afc_h);
	ON_ERR_GOTO(res, out, "populating pattern generator");
	debug_print("populated generator\n");

	res = stop_generator(afc_h);
	ON_ERR_GOTO(res, out, "stopping generator");
	debug_print("stopped generator\n");

	res = start_generator(afc_h, size, 0);
	ON_ERR_GOTO(res, out, "starting generator");
	debug_print("started generator\n");

out:
	return res;
}

static fpga_result wait_generator(fpga_handle afc_h)
{
	fpga_result res;
	res = wait_for_generator_complete(afc_h);
	ON_ERR_GOTO(res, out, "waiting generator");
	debug_print("generator complete\n");

	res = stop_generator(afc_h);
	ON_ERR_GOTO(res, out, "stopping generator");
	debug_print("generator stopped\n");

out:
	return res;
}

struct buf_attrs {
	void *va;
	uint64_t iova;
	uint64_t wsid;
	uint64_t size;
};


static fpga_result allocate_buffer(fpga_handle afc_h, struct buf_attrs *attrs)
{
	fpga_result res;
	if(!attrs)
		return FPGA_INVALID_PARAM;

	res = fpgaPrepareBuffer(afc_h, attrs->size, (void **)&(attrs->va), &attrs->wsid, 0);
	if(res != FPGA_OK)
		return res;

	res = fpgaGetIOAddress(afc_h, attrs->wsid, &attrs->iova);
	if(res != FPGA_OK) {
		res = fpgaReleaseBuffer(afc_h, attrs->wsid);
		return res;
	}
	debug_print("Allocated test buffer of size = %ld bytes\n", attrs->size);
	return FPGA_OK;
}

static fpga_result free_buffer(fpga_handle afc_h, struct buf_attrs *attrs)
{
	if(!attrs)
		return FPGA_INVALID_PARAM;

	return fpgaReleaseBuffer(afc_h, attrs->wsid);
}

static fpga_result bandwidth_test(fpga_handle afc_h, fpga_dma_handle_t dma_h, struct config *config) {
	fpga_result res = FPGA_OK;
	struct timespec start, end;

	// TODO: specify alloc. policy
	struct buf_attrs battrs = {
		.va = NULL,
		.iova = 0,
		.wsid = 0,
		.size = 0
	};

	battrs.size = config->data_size;
	res = allocate_buffer(afc_h, &battrs);	
	ON_ERR_GOTO(res, out, "allocating buffer");
	debug_print("allocated test buffer va = %lx, iova = %lx, wsid = %lx\n", battrs.va, battrs.iova, battrs.wsid, battrs.size);

	fpga_dma_transfer_t transfer;
	res = fpgaDMATransferInit(&transfer);
	ON_ERR_GOTO(res, out, "allocating transfer");
	debug_print("init transfer\n");

	if(config->direction == STDMA_MTOS) {
		fill_buffer((unsigned char *)battrs.va, config->data_size);
		debug_print("filled test buffer\n");
		
		fpga_dma_tx_ctrl_t tx_ctrl;
		if(config->transfer_type == STDMA_TRANSFER_FIXED)
			tx_ctrl = TX_NO_PACKET;
		else
			tx_ctrl = GENERATE_SOP_AND_EOP;

		#if !EMU_MODE
		//res = prepare_checker(afc_h, config->data_size);
		//ON_ERR_GOTO(res, free_transfer, "preparing checker");
		//debug_print("checker prepared\n");
		#endif

		clock_gettime(CLOCK_MONOTONIC, &start);
		uint64_t total_size = config->data_size;
		int64_t tid = ceil(config->data_size / config->payload_size);
		int64_t transfers = tid;
		uint64_t src = battrs.iova;
		while(total_size > 0) {
			uint64_t transfer_bytes = MIN(total_size, config->payload_size);
			debug_print("Transfer src=%lx, dst=%lx, bytes=%ld\n", (uint64_t)src, (uint64_t)0, transfer_bytes);

			fpgaDMATransferSetSrc(transfer, src);
			fpgaDMATransferSetDst(transfer, (uint64_t)0);
			fpgaDMATransferSetLen(transfer, transfer_bytes);
			fpgaDMATransferSetTransferType(transfer, HOST_MM_TO_FPGA_ST);
			fpgaDMATransferSetTxControl(transfer, tx_ctrl);
			// perform non-blocking transfers, except for the very last
			debug_print("transfer id = %ld\n", tid);
			if(tid == 1)
				fpgaDMATransferSetTransferCallback(transfer, NULL, NULL);
			else
				fpgaDMATransferSetTransferCallback(transfer, transferComplete, NULL);

			res = fpgaDMATransfer(dma_h, transfer);
			ON_ERR_GOTO(res, free_transfer, "transfer error");
			total_size -= transfer_bytes;
			src += transfer_bytes;
			tid--;
		}
		clock_gettime(CLOCK_MONOTONIC, &end);
		printf("%lf transfers/sec\n", (double)transfers/getTime(start,end));
		
		#if !EMU_MODE
		//res = wait_checker(afc_h);
		//ON_ERR_GOTO(res, free_transfer, "checker verify failed");
		//printf("Transfer pass!\n");
		#endif

	} else {
		fpga_dma_rx_ctrl_t rx_ctrl;
		if(config->transfer_type == STDMA_TRANSFER_FIXED)
			rx_ctrl = RX_NO_PACKET;
		else
			rx_ctrl = END_ON_EOP;

		res = prepare_generator(afc_h, config->data_size);
		ON_ERR_GOTO(res, free_transfer, "preparing generator");
		debug_print("generator prepared\n");

		memset(battrs.va, 0, config->data_size);
		clock_gettime(CLOCK_MONOTONIC, &start);
		uint64_t total_size = config->data_size;
		char *dst_p = (char*)battrs.va;
		while(total_size > 0) {
			uint64_t transfer_bytes = MIN(total_size, config->payload_size);
			debug_print("Transfer src=%lx, dst=%lx, bytes=%ld\n", (uint64_t)0, (uint64_t)dst_p, transfer_bytes);
			res = rxTransfer(dma_h, transfer, 0, (uint64_t)dst_p,
					transfer_bytes,
					FPGA_ST_TO_HOST_MM, rx_ctrl,
					transferComplete);
			ON_ERR_GOTO(res, free_transfer, "transfer error");
			total_size -= transfer_bytes;
			dst_p += transfer_bytes;
		}
		ON_ERR_GOTO(res, free_transfer, "transfer error");
		clock_gettime(CLOCK_MONOTONIC, &end);

		res = wait_generator(afc_h);
		ON_ERR_GOTO(res, free_transfer, "wait generator");
		debug_print("generator complete\n");

		res = verify_buffer((unsigned char *)battrs.va, config->data_size);
		ON_ERR_GOTO(res, free_transfer, "buffer verify failed");
		printf("Transfer pass!\n");
	}
	report_bandwidth(config->data_size, getTime(start,end));

free_transfer:
	if(battrs.va) {
		debug_print("destroying transfer\n");
		res = fpgaDMATransferDestroy(transfer);
		ON_ERR_GOTO(res, out, "destroy transfer");
		debug_print("destroyed transfer\n");
	}
out:
	if(battrs.va)
		free_buffer(afc_h, &battrs);

	return res;
}

#if 0
fpga_result configure_numa(fpga_token afc_token, bool cpu_affinity, bool memory_affinity)
{
	fpga_result res = FPGA_OK;
	fpga_properties props;
	// Set up proper affinity if requested
	if (cpu_affinity || memory_affinity) {
		unsigned dom = 0, bus = 0, dev = 0, func = 0;
		int retval;
		#if(FPGA_DMA_DEBUG)
				char str[4096];
		#endif
		res = fpgaGetProperties(afc_token, &props);
		ON_ERR_GOTO(res, out, "fpgaGetProperties");
		res = fpgaPropertiesGetBus(props, (uint8_t *) & bus);
		ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesGetBus");
		res = fpgaPropertiesGetDevice(props, (uint8_t *) & dev);
		ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesGetDevice");
		res = fpgaPropertiesGetFunction(props, (uint8_t *) & func);
		ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesGetFunction");

		// Find the device from the topology
		hwloc_topology_t topology;
		hwloc_topology_init(&topology);
		hwloc_topology_set_flags(topology,
					HWLOC_TOPOLOGY_FLAG_IO_DEVICES);
		hwloc_topology_load(topology);
		hwloc_obj_t obj = hwloc_get_pcidev_by_busid(topology, dom, bus, dev, func);
		hwloc_obj_t obj2 = hwloc_get_non_io_ancestor_obj(topology, obj);
		#if (FPGA_DMA_DEBUG)
			hwloc_obj_type_snprintf(str, 4096, obj2, 1);
			printf("%s\n", str);
			hwloc_obj_attr_snprintf(str, 4096, obj2, " :: ", 1);
			printf("%s\n", str);
			hwloc_bitmap_taskset_snprintf(str, 4096, obj2->cpuset);
			printf("CPUSET is %s\n", str);
			hwloc_bitmap_taskset_snprintf(str, 4096, obj2->nodeset);
			printf("NODESET is %s\n", str);
		#endif
		if (memory_affinity) {
			#if HWLOC_API_VERSION > 0x00020000
				// hack
				//retval = hwloc_set_membind(topology, obj2->nodeset,
				//				HWLOC_MEMBIND_THREAD, HWLOC_MEMBIND_MIGRATE | HWLOC_MEMBIND_BYNODESET);
			#else
				//retval =
				//hwloc_set_membind_nodeset(topology, obj2->nodeset,
				//				HWLOC_MEMBIND_THREAD,
				//				HWLOC_MEMBIND_MIGRATE);
			#endif
			//ON_ERR_GOTO(retval, out_destroy_prop, "hwloc_set_membind");
		}
		if (cpu_affinity) {
			retval = hwloc_set_cpubind(topology, obj2->cpuset,	HWLOC_CPUBIND_STRICT);
			ON_ERR_GOTO(retval, out_destroy_prop, "hwloc_set_cpubind");
		}

	}

out_destroy_prop:
	res = fpgaDestroyProperties(&props);

out:
	return res;
}
#endif

int find_accelerator(const char *afu_id, struct config *config,
			    fpga_token *afu_tok) {
	fpga_result res;
	fpga_guid guid;
	uint32_t num_matches = 0;
	fpga_properties filter = NULL;

	if(uuid_parse(DMA_AFU_ID, guid) < 0) {
		return 1;
	}

	res = fpgaGetProperties(NULL, &filter);
	ON_ERR_GOTO(res, out, "fpgaGetProperties");

	res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesSetObjectType");

	res = fpgaPropertiesSetGUID(filter, guid);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesSetGUID");

	if (CONFIG_UNINIT != config->bus) {
		res = fpgaPropertiesSetBus(filter, config->bus);
		ON_ERR_GOTO(res, out_destroy_prop, "setting bus");
	}

	if (CONFIG_UNINIT != config->device) {
		res = fpgaPropertiesSetDevice(filter, config->device);
		ON_ERR_GOTO(res, out_destroy_prop, "setting device");
	}

	if (CONFIG_UNINIT != config->function) {
		res = fpgaPropertiesSetFunction(filter, config->function);
		ON_ERR_GOTO(res, out_destroy_prop, "setting function");
	}

	res = fpgaEnumerate(&filter, 1, afu_tok, 1, &num_matches);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaEnumerate");
	
out_destroy_prop:
	res = fpgaDestroyProperties(&filter);
	ON_ERR_GOTO(res, out, "fpgaDestroyProperties");

out:
	if (num_matches > 0)
		return (int)num_matches;
	else
		return 0;
}

fpga_result do_action(struct config *config, fpga_token afc_tok)
{
	fpga_dma_handle_t dma_h = NULL;
	fpga_handle afc_h = NULL;
	fpga_result res;
	#ifndef USE_ASE
	volatile uint64_t *mmio_ptr = NULL;
	#endif

	sem_init(&transfer_done , 0, 0);
	res = fpgaOpen(afc_tok, &afc_h, 0);
	ON_ERR_GOTO(res, out, "fpgaOpen");
	debug_print("opened afc handle\n");

	#ifndef USE_ASE
	res = fpgaMapMMIO(afc_h, 0, (uint64_t**)&mmio_ptr);
	ON_ERR_GOTO(res, out_afc_close, "fpgaMapMMIO");
	debug_print("mapped mmio\n");
	#endif

	res = fpgaReset(afc_h);
	ON_ERR_GOTO(res, out_unmap, "fpgaReset");
	debug_print("applied afu reset\n");

	// Enumerate DMA handles
	uint64_t ch_count;
	ch_count = 0;
	res = fpgaCountDMAChannels(afc_h, &ch_count);
	ON_ERR_GOTO(res, out_unmap, "fpgaGetDMAChannels");
	if(ch_count < 1) {
		fprintf(stderr, "DMA channels not found (found %ld, expected %d\n",
			ch_count, 2);
		ON_ERR_GOTO(FPGA_INVALID_PARAM, out_unmap, "count<1");
	}

	debug_print("found %ld dma channels\n", ch_count);

	if(config->direction == STDMA_MTOS) {
		// Memory to stream -> Channel 0
		res = fpgaDMAOpen(afc_h, 0, &dma_h);
		ON_ERR_GOTO(res, out_unmap, "fpgaDMAOpen");
		debug_print("opened memory to stream channel\n");
	} else {
		// Stream to memory -> Channel 1
		res = fpgaDMAOpen(afc_h, 1, &dma_h);
		ON_ERR_GOTO(res, out_unmap, "fpgaDMAOpen");
		debug_print("opened stream to memory channel\n");
	}

	// Run a bandwidth test
	res = bandwidth_test(afc_h, dma_h, config);
	ON_ERR_GOTO(res, out_dma_close, "fpgaDMAOpen");
	debug_print("bandwidth test success\n");

out_dma_close:
	//if(dma_h) {
	//	printf("closing DMA\n");
	//	res = fpgaDMAClose(dma_h);
	//	ON_ERR_GOTO(res, out_unmap, "fpgaDMAOpen");
	//	debug_print("closed dma channel\n");
	//}

out_unmap:
	#ifndef USE_ASE
	if(afc_h) {
		res = fpgaUnmapMMIO(afc_h, 0);
		ON_ERR_GOTO(res, out_afc_close, "fpgaUnmapMMIO");
		debug_print("unmapped mmio\n");
	}
	#endif

out_afc_close:
	if (afc_h) {
		res = fpgaClose(afc_h);
		ON_ERR_GOTO(res, out, "fpgaClose");
		debug_print("closed afc\n");
	}

out:
	sem_destroy(&transfer_done);
	return res;
}
