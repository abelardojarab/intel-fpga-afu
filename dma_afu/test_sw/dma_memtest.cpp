#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>
#include <opae/properties.h>
#include <assert.h>

#include "RC4memtest.h"
#include "dma_test_common.h"

int usleep(unsigned);

#define DMA_TEST_AFU_ID              "331DB30C-9885-41EA-9081-F88B8F655CAA"
#define SCRATCH_REG              0X80
#define SCRATCH_VALUE            0x0123456789ABCDEF
#define SCRATCH_RESET            0
#define BYTE_OFFSET              8

#define DMA_BUFFER_SIZE (1024*1024)

#define AFU_DFH_REG              0x0
#define AFU_ID_LO                0x8 
#define AFU_ID_HI                0x10
#define AFU_NEXT                 0x18
#define AFU_RESERVED             0x20

static int s_error_count = 0;
static uint64_t msgdma_bbb_dfh_offset = -256*1024;

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
		if (condition == 0) {            \
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

int dma_memory_checker(
	fpga_handle afc_handle,
	uint64_t dma_buf_iova,
	volatile uint64_t *dma_buf_ptr,
	long mem_size
)
{
	int num_errors = 0;
	
#ifdef USE_ASE
	const long DMA_BUF_SIZE = 256;
#else
	const long DMA_BUF_SIZE = 512*1024;
#endif

	RC4Memtest rc4_obj;
	long byte_errors = 0;
	long page_errors = 0;
	const char *RC4_KEY = "mytestkey";
	
	rc4_obj.setup_key(RC4_KEY);
	
	assert(mem_size % DMA_BUF_SIZE == 0);
	
	const long NUM_DMA_TRANSFERS = mem_size/DMA_BUF_SIZE;
	
	for(long i = 0; i < NUM_DMA_TRANSFERS; i++)
	{
		rc4_obj.write_bytes((char *)dma_buf_ptr, (int)DMA_BUF_SIZE);
		uint64_t dev_addr = i*DMA_BUF_SIZE;
		
		copy_dev_to_dev_with_dma(afc_handle, dma_buf_iova | 0x1000000000000, dev_addr, DMA_BUF_SIZE);
	}
	
	//reload rc4 state to begining
	rc4_obj.setup_key(RC4_KEY);
	
	for(long i = 0; i < NUM_DMA_TRANSFERS; i++)
	{
		uint64_t dev_addr = i*DMA_BUF_SIZE;
		copy_dev_to_dev_with_dma(afc_handle, dev_addr, dma_buf_iova | 0x1000000000000, DMA_BUF_SIZE);
		long errors = rc4_obj.check_bytes((char *)dma_buf_ptr, (int)DMA_BUF_SIZE);
		if(errors)
			page_errors++;
		byte_errors += errors;
	}
	
	printf("mem_size=%ld dma_buf_size=%ld num_dma_buf=%ld\n", mem_size, DMA_BUF_SIZE, NUM_DMA_TRANSFERS);
	printf("byte_errors=%ld, page_errors=%ld\n", byte_errors, page_errors);
	if(byte_errors)
	{
		printf("ERROR: memtest FAILED!\n");
		s_error_count += 1;
		return 0;
	}

	printf("num_errors = %d\n", num_errors);
	s_error_count += num_errors;
}

int dma_memory_checker(fpga_handle afc_handle, long mem_size)
{
	volatile uint64_t *dma_buf_ptr  = NULL;
	uint64_t        dma_buf_wsid;
	uint64_t dma_buf_iova;
	
	fpga_result     res = FPGA_OK;

	res = fpgaPrepareBuffer(afc_handle, DMA_BUFFER_SIZE,
		(void **)&dma_buf_ptr, &dma_buf_wsid, 0);
	ON_ERR_GOTO(res, release_buf, "allocating dma buffer");
	memset((void *)dma_buf_ptr,  0x0, DMA_BUFFER_SIZE);
	
	res = fpgaGetIOAddress(afc_handle, dma_buf_wsid, &dma_buf_iova);
	ON_ERR_GOTO(res, release_buf, "getting dma DMA_BUF_IOVA");
	
	printf("DMA_BUFFER_SIZE = %d\n", DMA_BUFFER_SIZE);
	
	dma_memory_checker(afc_handle, dma_buf_iova, dma_buf_ptr, mem_size);

release_buf:
	res = fpgaReleaseBuffer(afc_handle, dma_buf_wsid);
}

int main(int argc, char *argv[])
{
	fpga_properties    filter = NULL;
	fpga_token         afc_token;
	fpga_handle        afc_handle;
	fpga_guid          guid;
	uint32_t           num_matches;
	uint64_t data = 0;
	uint64_t dfh_size = 0;
	bool found_dfh = 0;

	fpga_result     res = FPGA_OK;

	if (uuid_parse(DMA_TEST_AFU_ID, guid) < 0) {
		fprintf(stderr, "Error parsing guid '%s'\n", DMA_TEST_AFU_ID);
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
	res = fpgaReadMMIO64(afc_handle, 0, AFU_DFH_REG, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("AFU DFH REG = %08lx\n", data);
	
	res = fpgaReadMMIO64(afc_handle, 0, AFU_ID_LO, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("AFU ID LO = %08lx\n", data);
	
	res = fpgaReadMMIO64(afc_handle, 0, AFU_ID_HI, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("AFU ID HI = %08lx\n", data);
	
	res = fpgaReadMMIO64(afc_handle, 0, AFU_NEXT, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("AFU NEXT = %08lx\n", data);
	
	res = fpgaReadMMIO64(afc_handle, 0, AFU_RESERVED, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("AFU RESERVED = %08lx\n", data);
	
	found_dfh = find_dfh_by_guid(afc_handle, MSGDMA_BBB_GUID, &msgdma_bbb_dfh_offset, &dfh_size);
	set_msgdma_bbb_dfh_offset(msgdma_bbb_dfh_offset);
	assert(found_dfh);
	assert(dfh_size == MSGDMA_BBB_SIZE);

	{
		long mem_mult = 0;
		if(argc >= 2)
			mem_mult = (long)atoi(argv[1]);
		else
			mem_mult = 8;
		#ifdef USE_ASE
			const long mem_size	 = 128*mem_mult;
		#else
			const long mem_size	 = mem_mult*1024l*1024l*1024l;
		#endif
		dma_memory_checker(afc_handle, mem_size);
	}

	printf("Done Running Test\n");

	/* Unmap MMIO space */
out_unmap:
	res = fpgaUnmapMMIO(afc_handle, 0);
	ON_ERR_GOTO(res, out_close, "unmapping MMIO space");
	
	/* Release accelerator */
out_close:
	res = fpgaClose(afc_handle);
	ON_ERR_GOTO(res, out_destroy_tok, "closing AFC");

	/* Destroy token */
out_destroy_tok:
	res = fpgaDestroyToken(&afc_token);
	ON_ERR_GOTO(res, out_destroy_prop, "destroying token");

	/* Destroy properties object */
out_destroy_prop:
	res = fpgaDestroyProperties(&filter);
	ON_ERR_GOTO(res, out_exit, "destroying properties object");

out_exit:
	if(s_error_count > 0)
		printf("Test FAILED!\n");

	return s_error_count;

}
