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
 * \fpga_dma_st_test_utils.h
 * \brief Streaming DMA test utils
 */

#ifndef __FPGA_DMA_ST_TEST_UTILS_H__
#define __FPGA_DMA_ST_TEST_UTILS_H__

#include <string.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>
#include <time.h>
#include <stdlib.h>
#include <assert.h>
#include <semaphore.h>
#include <hwloc.h>
#include "fpga_dma.h"
#include "fpga_pattern_gen.h"
#include "fpga_pattern_checker.h"
#include "fpga_dma_st_common.h"

#define DMA_AFU_ID				"EB59BF9D-B211-4A4E-B3E3-753CE68634BA"
// Single pattern is represented as 64Bytes
#define PATTERN_WIDTH 64
// No. of Patterns
#define PATTERN_LENGTH 32
#define MIN_PAYLOAD_LEN 64
#define CONFIG_UNINIT (0)

#ifndef USE_ASE
//#include <hwloc.h>
#endif

#define STR_CONST_CMP(str, str_const) strncmp(str, str_const, sizeof(str_const))

enum stdma_test_direction {
	STDMA_INVAL_DIRECTION = 0,
	STDMA_MTOS,
	STDMA_STOM
};

enum stdma_test_transfer_type {
	STDMA_INVAL_TRANSFER_TYPE = 0,
	STDMA_TRANSFER_FIXED,
	STDMA_TRANSFER_PACKET
};

struct config {
	int bus;
	int device;
	int function;
	int segment;
	uint64_t data_size;
	uint64_t payload_size;
	enum stdma_test_direction direction;
	enum stdma_test_transfer_type transfer_type;
};

int find_accelerator(const char *afu_id, struct config *config, fpga_token *afu_tok);
fpga_result configure_numa(fpga_token afc_token, bool cpu_affinity, bool memory_affinity);
fpga_result do_action(struct config *config, fpga_token afc_tok);

#endif
