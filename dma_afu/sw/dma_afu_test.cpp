#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <uuid/uuid.h>
#include <fpga/enum.h>
#include <fpga/access.h>
#include <fpga/common.h>

#include "RC4memtest.h"

int usleep(unsigned);

#define HELLO_AFU_ID              "331DB30C-9885-41EA-9081-F88B8F655CAA"
#define SCRATCH_REG              0X80
#define SCRATCH_VALUE            0x0123456789ABCDEF
#define SCRATCH_RESET            0
#define BYTE_OFFSET              8

#define AFU_DFH_REG              0x0
#define AFU_ID_LO                0x8 
#define AFU_ID_HI                0x10
#define AFU_NEXT                 0x18
#define AFU_RESERVED             0x20

static int s_error_count = 0;

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

void mmio_read64(fpga_handle afc_handle, uint64_t addr, uint64_t *data, const char *reg_name)
{
	fpgaReadMMIO64(afc_handle, 0, addr, data);
	printf("Reading %s (Byte Offset=%08lx) = %08lx\n", reg_name, addr, *data);
}

void mmio_write64(fpga_handle afc_handle, uint64_t addr, uint64_t data, const char *reg_name)
{
	fpgaWriteMMIO64(afc_handle, 0, addr, data);
	printf("MMIO Write to %s (Byte Offset=%08lx) = %08lx\n", reg_name, addr, data);
}

int run_dma_afu_test(fpga_handle afc_handle)
{
	uint64_t data = 0;
	
	// Access AFU user scratch-pad register
	mmio_read64(afc_handle, SCRATCH_REG, &data, "scratch_reg");
	//
	mmio_write64(afc_handle, SCRATCH_REG, SCRATCH_VALUE, "scratch_reg");
	mmio_read64(afc_handle, SCRATCH_REG, &data, "scratch_reg");
	//
	//// Set Scratch Register to 0
	mmio_write64(afc_handle, SCRATCH_REG, SCRATCH_RESET, "scratch_reg");
	mmio_read64(afc_handle, SCRATCH_REG, &data, "scratch_reg");
	
	//sleep(1);
	mmio_read64(afc_handle, 0x500, &data, "qsys_sys_id");
	//sleep(1);
	mmio_read64(afc_handle, 0x500, &data, "qsys_sys_id");
	mmio_read64(afc_handle, 0x1000, &data, "qsys_sys_id2");
	
	#define ADDR_SPAN_START 0x20070
	#define MEM_START 0x30000
	#define MEM_OFFSET 0x1000
	//#define MEM_OFFSET 16
	
	mmio_write64(afc_handle, MEM_START, 0x12345678abcdef09, "memaddr0");
	mmio_write64(afc_handle, MEM_START+8, 0xa1b2c3d4e5f60798, "memaddr1");
	mmio_read64(afc_handle, MEM_START, &data, "memaddr0");
	mmio_read64(afc_handle, MEM_START+8, &data, "memaddr1");
	
	mmio_read64(afc_handle, ADDR_SPAN_START, &data, "addr_span");
	mmio_write64(afc_handle, ADDR_SPAN_START, 0x10000, "addr_span");
	mmio_read64(afc_handle, ADDR_SPAN_START, &data, "addr_span");
	
	mmio_read64(afc_handle, MEM_START, &data, "memaddr0");
	mmio_read64(afc_handle, MEM_START+8, &data, "memaddr1");
	
	
	
	for(int i = 0; i < 10; i++)
	{
		//usleep(1000*1000);
		mmio_write64(afc_handle, MEM_START+MEM_OFFSET+i*8, i, "memaddr_i");
	}
	for(int i = 0; i < 10; i++)
	{
		//usleep(1000*1000);
		mmio_read64(afc_handle, MEM_START+MEM_OFFSET+i*8, &data, "memaddr_i");
	}
	
	mmio_write64(afc_handle, ADDR_SPAN_START, 0x0000, "addr_span");
	mmio_read64(afc_handle, ADDR_SPAN_START, &data, "addr_span");
	
	for(int i = 0; i < 10; i++)
	{
		//usleep(1000*1000);
		mmio_read64(afc_handle, MEM_START+MEM_OFFSET+i*8, &data, "memaddr_i");
	}
	
	mmio_read64(afc_handle, MEM_START, &data, "memaddr0");
	mmio_read64(afc_handle, MEM_START+8, &data, "memaddr1");

	const long ASE_MEM_PAGE_SIZE = (64*1024);
	const long NEXT_MEMORY_OFFSET = ((long)4096*(long)(1024*1024));
#ifdef USE_ASE
	const long PAGE_SIZE	 = (128);
	const long NUM_PAGES	 = (8);
	char test_buffer[PAGE_SIZE];
	const long NUM_MEMS	 = 2;
#else
	const long PAGE_SIZE	 = (1024*64);
	const long NUM_PAGES	 = (1024);
	char test_buffer[PAGE_SIZE];
	const long NUM_MEMS	 = 2;
#endif
	
	RC4Memtest rc4_obj;
	long byte_errors = 0;
	long page_errors = 0;
	const char *RC4_KEY = "mytestkey";
	
	rc4_obj.setup_key(RC4_KEY);
	
	for(long m = 0; m < NUM_MEMS; m++)
	{
		for(long p = 0; p < NUM_PAGES; p++)
		{
			fpgaWriteMMIO64(afc_handle, 0, ADDR_SPAN_START, m*NEXT_MEMORY_OFFSET+ASE_MEM_PAGE_SIZE*p);
			rc4_obj.write_bytes(test_buffer, PAGE_SIZE);
			for(long i = 0; i < PAGE_SIZE/8; i++)
				fpgaWriteMMIO64(afc_handle, 0, MEM_START+i*8, *(((uint64_t*)test_buffer)+i));
		}
	}
	
	//reload rc4 state to begining
	rc4_obj.setup_key(RC4_KEY);
	
	for(long m = 0; m < NUM_MEMS; m++)
	{
		for(long p = 0; p < NUM_PAGES; p++)
		{
			fpgaWriteMMIO64(afc_handle, 0, ADDR_SPAN_START, m*NEXT_MEMORY_OFFSET+ASE_MEM_PAGE_SIZE*p);
			for(long i = 0; i < PAGE_SIZE/8; i++)
			  fpgaReadMMIO64(afc_handle, 0, MEM_START+i*8, (((uint64_t*)test_buffer)+i));
			long errors = rc4_obj.check_bytes(test_buffer, PAGE_SIZE);
			if(errors)
				page_errors++;
			byte_errors += page_errors;
		}
	}
	
	printf("num_pages=%ld page_size=%ld num_mems=%ld total_mem_span=%ld\n", NUM_PAGES, PAGE_SIZE, NUM_MEMS, NUM_MEMS*NUM_PAGES*ASE_MEM_PAGE_SIZE);
	printf("byte_errors=%ld, page_errors=%ld\n", byte_errors, page_errors);
	if(byte_errors)
	{
		printf("ERROR: memtest FAILED!\n");
		return 0;
	}
	
	return 1;
}

int main(int argc, char *argv[])
{
	fpga_properties    filter = NULL;
	fpga_token         afc_token;
	fpga_handle        afc_handle;
	fpga_guid          guid;
	uint32_t           num_matches;
	uint64_t data = 0;
	uint64_t *mmio_ptr   = NULL;

	fpga_result     res = FPGA_OK;

	if (uuid_parse(HELLO_AFU_ID, guid) < 0) {
		fprintf(stderr, "Error parsing guid '%s'\n", HELLO_AFU_ID);
		goto out_exit;
	}

	/* Look for AFC with MY_AFC_ID */
	res = fpgaGetProperties(NULL, &filter);
	ON_ERR_GOTO(res, out_exit, "creating properties object");

	res = fpgaPropertiesSetObjectType(filter, FPGA_AFC);
	ON_ERR_GOTO(res, out_destroy_prop, "setting object type");

	res = fpgaPropertiesSetGuid(filter, guid);
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

	res = fpgaMapMMIO(afc_handle, 0, &mmio_ptr);
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
/*
	// Access AFU user scratch-pad register
	res = fpgaReadMMIO64(afc_handle, 0, SCRATCH_REG, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("Reading Scratch Register (Byte Offset=%08lx) = %08lx\n", SCRATCH_REG, data);
	
	printf("MMIO Write to Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, SCRATCH_VALUE);
	res = fpgaWriteMMIO64(afc_handle, 0, SCRATCH_REG, SCRATCH_VALUE);
	ON_ERR_GOTO(res, out_close, "writing to MMIO");
	
	res = fpgaReadMMIO64(afc_handle, 0, SCRATCH_REG, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("Reading Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, data);
	ASSERT_GOTO(data == SCRATCH_VALUE, out_close, "MMIO mismatched expected result");
	
	// Set Scratch Register to 0
	printf("Setting Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, SCRATCH_RESET);
	res = fpgaWriteMMIO64(afc_handle, 0, SCRATCH_REG, SCRATCH_RESET);
	ON_ERR_GOTO(res, out_close, "writing to MMIO");
	res = fpgaReadMMIO64(afc_handle, 0, SCRATCH_REG, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("Reading Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, data);
	ASSERT_GOTO(data == SCRATCH_RESET, out_close, "MMIO mismatched expected result");
*/
	
	run_dma_afu_test(afc_handle);

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