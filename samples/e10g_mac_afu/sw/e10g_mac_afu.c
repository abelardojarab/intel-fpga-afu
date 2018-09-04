// Copyright(c) 2014-2018, Intel Corporation
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

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <uuid/uuid.h>
#include <opae/enum.h>
#include <opae/access.h>
#include <opae/mmio.h>
#include <opae/properties.h>
#include <opae/utils.h>

// State from the AFU's JSON file, extracted using OPAE's afu_json_mgr script
#include "afu_json_info.h"

#define UNUSED_PARAM(x) (void) x

int usleep(unsigned);

#define E10G_MAC_AFU_ID             AFU_ACCEL_UUID  // Defined in afu_json_info.h

#define AFU_DFH             	0x0
#define AFU_ID_L                0x8
#define AFU_ID_H                0x10
#define AFU_DFH_RSVD            0x18
#define AFU_CTRL 				0x20
#define AFU_ERROR 				0x28
#define SCRATCH_REG             0X30
#define SCRATCH_VALUE           0x0123456789ABCDEF
#define SCRATCH_RESET           0
#define BYTE_OFFSET             8

#define MAC_ID_L 				0xafb157de7ccc0d42
#define MAC_ID_H 				0x2134dca06beb4cdd

#define CLIENT_ID_L 			0xae4118efda07589d
#define CLIENT_ID_H 			0xdf834523d43446bd

#define NULL_ID_L 				0x56722e4e1a5e4b0f
#define NULL_ID_H 				0xaf744f15130ab6c1

#define FPGA_DMA_BBB 0x2
#define AFU_DFH_NEXT_OFFSET 16
#define AFU_DFH_EOL_OFFSET 40
#define AFU_DFH_TYPE_OFFSET 60

static int s_error_count = 0;
static uint64_t count=0;

/**
* fpgaEnumerateDFH
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
fpga_result fpgaEnumerateDFH(fpga_handle fpga, size_t *count);
static bool _fpga_dma_feature_eol(uint64_t dfh);
static bool _fpga_dma_feature_is_bbb(uint64_t dfh);
static uint64_t _fpga_dma_feature_next(uint64_t dfh);

/*
 * macro to check return codes, print error message, and goto cleanup label
 * NOTE: this changes the program flow (uses goto)!
 */
#define ON_ERR_GOTO(res, label, desc)                    \
	do {                                       \
		if ((res) != FPGA_OK) {            \
			print_err((desc), (res));  \
			s_error_count += 1; \
			goto label;                \
		}                                  \
	} while (0)

/*
 * macro to check return codes, print error message, and goto cleanup label
 * NOTE: this changes the program flow (uses goto)!
 */
#define ASSERT_GOTO(condition, label, desc)                    \
	do {                                       \
		if ((condition) == 0) {            \
			fprintf(stderr, "Error %s\n", desc); \
			s_error_count += 1; \
			goto label;                \
		}                                  \
	} while (0)

/* Type definitions */
typedef struct {
	uint32_t uint[16];
} cache_line;

void print_err(const char *s, fpga_result res)
{
	fprintf(stderr, "Error %s: %s\n", s, fpgaErrStr(res));
}

int main(int argc, char *argv[])
{

	UNUSED_PARAM(argc);
	UNUSED_PARAM(argv);

	fpga_properties    filter = NULL;
	fpga_token         afc_token;
	fpga_handle        afc_handle;
	fpga_guid          guid;
	uint32_t           num_matches;

	fpga_result     res = FPGA_OK;

	if (uuid_parse(E10G_MAC_AFU_ID, guid) < 0) {
		fprintf(stderr, "Error parsing guid '%s'\n", E10G_MAC_AFU_ID);
		goto out_exit;
	}

	/* Look for AFC with MY_AFC_ID */
	res = fpgaGetProperties(NULL, &filter);
	ON_ERR_GOTO(res, out_exit, "creating properties object");

	res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
	ON_ERR_GOTO(res, out_destroy_prop, "setting object type");

	res = fpgaPropertiesSetGUID(filter, guid);
	ON_ERR_GOTO(res, out_destroy_prop, "setting GUID");

	/* TODO: Add selection via BDF / device ID */

	res = fpgaEnumerate(&filter, 1, &afc_token, 1, &num_matches);
	ON_ERR_GOTO(res, out_destroy_prop, "enumerating AFCs");

	if (num_matches < 1) {
		fprintf(stderr, "AFC not found.\n");
		res = fpgaDestroyProperties(&filter);
		return FPGA_INVALID_PARAM;
	}

	/* Open AFC and map MMIO */
	res = fpgaOpen(afc_token, &afc_handle, 0);
	ON_ERR_GOTO(res, out_destroy_tok, "opening AFC");

	res = fpgaMapMMIO(afc_handle, 0, NULL);
	ON_ERR_GOTO(res, out_close, "mapping MMIO space");

	printf("Running Test\n");

	/* Reset AFC */
	res = fpgaReset(afc_handle);
	ON_ERR_GOTO(res, out_close, "resetting AFC");

	// Access mandatory AFU registers
	/*
	uint64_t data = 0;
	
	res = fpgaReadMMIO64(afc_handle, 0, AFU_DFH, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("AFU DFH REG = %08lx\n", data);

	res = fpgaReadMMIO64(afc_handle, 0, AFU_ID_L, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("AFU ID LO = %08lx\n", data);

	res = fpgaReadMMIO64(afc_handle, 0, AFU_ID_H, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("AFU ID HI = %08lx\n", data);

	res = fpgaReadMMIO64(afc_handle, 0, AFU_DFH_RSVD, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("AFU RESERVED = %08lx\n", data);

	// Access AFU user scratch-pad register
	res = fpgaReadMMIO64(afc_handle, 0, SCRATCH_REG, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("Reading Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, data);

	printf("MMIO Write to Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, SCRATCH_VALUE);
	res = fpgaWriteMMIO64(afc_handle, 0, SCRATCH_REG, SCRATCH_VALUE);
	ON_ERR_GOTO(res, out_close, "writing to MMIO");

	res = fpgaReadMMIO64(afc_handle, 0, SCRATCH_REG, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("Reading Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, data);
	ASSERT_GOTO(data == SCRATCH_VALUE, out_close, "MMIO mismatched expected result");

	// Set Scratch Register to 0
	printf("Setting Scratch Register (Byte Offset=%08x) = %08x\n", SCRATCH_REG, SCRATCH_RESET);
	res = fpgaWriteMMIO64(afc_handle, 0, SCRATCH_REG, SCRATCH_RESET);
	ON_ERR_GOTO(res, out_close, "writing to MMIO");
	res = fpgaReadMMIO64(afc_handle, 0, SCRATCH_REG, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("Reading Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, data);
	ASSERT_GOTO(data == SCRATCH_RESET, out_close, "MMIO mismatched expected result");

	// Read/write AFU ERROR
	res = fpgaReadMMIO64(afc_handle, 0, AFU_ERROR, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("AFU ERROR = %08lx\n", data);

	printf("MMIO Write to AFU Error (Byte Offset=%08x) = %08lx\n", AFU_ERROR, SCRATCH_VALUE);
	res = fpgaWriteMMIO64(afc_handle, 0, AFU_ERROR, SCRATCH_VALUE);
	ON_ERR_GOTO(res, out_close, "writing to MMIO");

	res = fpgaReadMMIO64(afc_handle, 0, AFU_ERROR, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("Reading AFU Error Register (Byte Offset=%08x) = %08lx\n", AFU_ERROR, data);
	ASSERT_GOTO(data == SCRATCH_VALUE, out_close, "MMIO mismatched expected result");

	// Read/write AFU CTRL
	res = fpgaReadMMIO64(afc_handle, 0, AFU_CTRL, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("AFU CTRL = %08lx\n", data);

	printf("MMIO Write to AFU Control (Byte Offset=%08x) = %08lx\n", AFU_CTRL, SCRATCH_VALUE);
	res = fpgaWriteMMIO64(afc_handle, 0, AFU_CTRL, SCRATCH_VALUE);
	ON_ERR_GOTO(res, out_close, "writing to MMIO");

	res = fpgaReadMMIO64(afc_handle, 0, AFU_CTRL, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("Reading AFU Control Register (Byte Offset=%08x) = %08lx\n", AFU_CTRL, data);
	ASSERT_GOTO(data == SCRATCH_VALUE, out_close, "MMIO mismatched expected result");
	*/

	// Enumerate DFH 
	res = fpgaEnumerateDFH(afc_handle, &count);
	ON_ERR_GOTO(res, out_close, "fpgaEnumerateDFH");

	if(count < 1) {
		printf("Error: DFH not found\n");
		ON_ERR_GOTO(FPGA_INVALID_PARAM, out_close, "count<1");
	}
	printf("No of DFHs = %08lx\n", count);

	printf("Done Running Test\n");

	/* Unmap MMIO space */
	res = fpgaUnmapMMIO(afc_handle, 0);
	ON_ERR_GOTO(res, out_close, "unmapping MMIO space");

	/* Release accelerator */
out_close:
	res = fpgaClose(afc_handle);
	ON_ERR_GOTO(res, out_destroy_tok, "closing AFC");

	/* Destroy token */
out_destroy_tok:
#ifndef USE_ASE
	res = fpgaDestroyToken(&afc_token);
	ON_ERR_GOTO(res, out_destroy_prop, "destroying token");
#endif

	/* Destroy properties object */
out_destroy_prop:
	res = fpgaDestroyProperties(&filter);
	ON_ERR_GOTO(res, out_exit, "destroying properties object");

out_exit:
	if(s_error_count > 0)
		printf("Test FAILED!\n");

	return s_error_count;
}

fpga_result fpgaEnumerateDFH(fpga_handle fpga, size_t *count) {
	// Discover total# DMA channels by traversing the device feature list
	// We may encounter one or more BBBs during discovery
	// Populate the count
	fpga_result res = FPGA_OK;

	if(!fpga) {
		printf("Invalid FPGA Handle\n");
		goto out;
	}

	if(!count) {
		printf("Invalid pointer to count\n");
		goto out;
	}

	uint64_t offset = 0;
#ifndef USE_ASE
	uint64_t mmio_va;

	res = fpgaMapMMIO(fpga, 0, (uint64_t **)&mmio_va);
	ON_ERR_GOTO(res, out, "fpgaMapMMIO");
#endif
	// Discover BBBs by traversing the device feature list
	bool end_of_list = false;
	uint64_t dfh = 0;
	do {
		uint64_t feature_uuid_lo, feature_uuid_hi;
#ifndef USE_ASE
		// Read the next feature header
		dfh = *((volatile uint64_t *)((uint64_t)mmio_va + (uint64_t)(offset)));

		// Read the current feature's UUID
		feature_uuid_lo = *((volatile uint64_t *)((uint64_t)mmio_va + (uint64_t)(offset + 8)));
		feature_uuid_hi = *((volatile uint64_t *)((uint64_t)mmio_va + (uint64_t)(offset + 16)));
#else
		uint32_t mmio_no = 0;
		// Read the next feature header

		printf("Reading from offset = %08lx\n", offset);

		res = fpgaReadMMIO64(fpga, mmio_no, offset, &dfh);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");
		printf("Found DFH = %08lx\n", dfh);

		// Read the current feature's UUID
		res = fpgaReadMMIO64(fpga, mmio_no, offset + 8, &feature_uuid_lo);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");
		printf("Found UUID_L = %08lx\n", feature_uuid_lo);

		res = fpgaReadMMIO64(fpga, mmio_no, offset + 16, &feature_uuid_hi);
		ON_ERR_GOTO(res, out, "fpgaReadMMIO64");
		printf("Found UUID_H = %08lx\n", feature_uuid_hi);

#endif
		if (_fpga_dma_feature_is_bbb(dfh) &&
			(((feature_uuid_lo == MAC_ID_L) && (feature_uuid_hi == MAC_ID_H)) ||
			((feature_uuid_lo == CLIENT_ID_L) && (feature_uuid_hi == CLIENT_ID_H)) ||
			((feature_uuid_lo == NULL_ID_L) && (feature_uuid_hi == NULL_ID_H)))) {
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

