#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>
#include <opae/properties.h>
#include <assert.h>

#include "RC4memtest.h"

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

#define ACL_DMA_INST_ACL_DMA_AFU_ID_AVMM_SLAVE_0_BASE 0x0
#define ACL_DMA_INST_DMA_MODULAR_SGDMA_DISPATCHER_0_CSR_BASE 0x40
#define ACL_DMA_INST_DMA_MODULAR_SGDMA_DISPATCHER_0_DESCRIPTOR_SLAVE_BASE 0x60
#define ACL_DMA_INST_ADDRESS_SPAN_EXTENDER_0_CNTL_BASE 0x200
#define ACL_DMA_INST_ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE 0x1000

#define MSGDMA_BBB_GUID		"d79c094c-7cf9-4cc1-94eb-7d79c7c01ca3"
#define MSGDMA_BBB_SIZE		8192
#define MSGDMA_BBB_MEM_WINDOW_SPAN (4*1024)
#define MSGDMA_BBB_MEM_WINDOW_SPAN_MASK ((uint64_t)(MSGDMA_BBB_MEM_WINDOW_SPAN-1))

#define MEM_WINDOW_CRTL(dfh) (ACL_DMA_INST_ADDRESS_SPAN_EXTENDER_0_CNTL_BASE+dfh)
#define MEM_WINDOW_MEM(dfh) (ACL_DMA_INST_ADDRESS_SPAN_EXTENDER_0_WINDOWED_SLAVE_BASE+dfh)

static uint64_t msgdma_bbb_dfh_offset = -256*1024;

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

void mmio_read32(fpga_handle afc_handle, uint64_t addr, uint32_t *data, const char *reg_name)
{
	fpgaReadMMIO32(afc_handle, 0, addr, data);
	printf("Reading %s (Byte Offset=%08lx) = %08lx\n", reg_name, addr, *data);
}

void mmio_read32_silent(fpga_handle afc_handle, uint64_t addr, uint32_t *data)
{
	fpgaReadMMIO32(afc_handle, 0, addr, data);
}

void mmio_write32(fpga_handle afc_handle, uint64_t addr, uint32_t data, const char *reg_name)
{
	fpgaWriteMMIO32(afc_handle, 0, addr, data);
	printf("MMIO Write to %s (Byte Offset=%08lx) = %08lx\n", reg_name, addr, data);
}

void mmio_read64(fpga_handle afc_handle, uint64_t addr, uint64_t *data, const char *reg_name)
{
	fpgaReadMMIO64(afc_handle, 0, addr, data);
	printf("Reading %s (Byte Offset=%08lx) = %08lx\n", reg_name, addr, *data);
}

void mmio_read64_silent(fpga_handle afc_handle, uint64_t addr, uint64_t *data)
{
	fpgaReadMMIO64(afc_handle, 0, addr, data);
}

void mmio_write64(fpga_handle afc_handle, uint64_t addr, uint64_t data, const char *reg_name)
{
	fpgaWriteMMIO64(afc_handle, 0, addr, data);
	printf("MMIO Write to %s (Byte Offset=%08lx) = %08lx\n", reg_name, addr, data);
}

void copy_to_mmio(fpga_handle afc_handle, uint64_t mmio_dst, uint64_t *host_src, int len)
{
	//mmio requires 8 byte alignment
	assert(len % 8 == 0);
	assert(mmio_dst % 8 == 0);
	
	uint64_t dev_addr = mmio_dst;
	uint64_t *host_addr = host_src;
	
	for(int i = 0; i < len/8; i++)
	{
		fpgaWriteMMIO64(afc_handle, 0, dev_addr, *host_addr);
		
		host_addr += 1;
		dev_addr += 8;
	}
}

void copy_to_dev_with_mmio(fpga_handle afc_handle, uint64_t *host_src, uint64_t dev_dest, int len)
{
	//mmio requires 8 byte alignment
	assert(len % 8 == 0);
	assert(dev_dest % 8 == 0);
	
	uint64_t dev_addr = dev_dest;
	uint64_t *host_addr = host_src;
	
	uint64_t cur_mem_page = dev_addr & ~MSGDMA_BBB_MEM_WINDOW_SPAN_MASK;
	fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), cur_mem_page);
	
	for(int i = 0; i < len/8; i++)
	{
		uint64_t mem_page = dev_addr & ~MSGDMA_BBB_MEM_WINDOW_SPAN_MASK;
		if(mem_page != cur_mem_page)
		{
			cur_mem_page = mem_page;
			fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), cur_mem_page);
		}
		fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+(dev_addr&MSGDMA_BBB_MEM_WINDOW_SPAN_MASK), *host_addr);
		
		host_addr += 1;
		dev_addr += 8;
	}
}

void copy_to_dev_with_mmio32(fpga_handle afc_handle, uint32_t *host_src, uint64_t dev_dest, int len)
{
	//mmio requires 8 byte alignment
	assert(len % 4 == 0);
	assert(dev_dest % 4 == 0);
	
	uint64_t dev_addr = dev_dest;
	uint32_t *host_addr = host_src;
	
	uint64_t cur_mem_page = dev_addr & ~MSGDMA_BBB_MEM_WINDOW_SPAN_MASK;
	fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), cur_mem_page);
	
	for(int i = 0; i < len/4; i++)
	{
		uint64_t mem_page = dev_addr & ~MSGDMA_BBB_MEM_WINDOW_SPAN_MASK;
		if(mem_page != cur_mem_page)
		{
			cur_mem_page = mem_page;
			fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), cur_mem_page);
		}
		fpgaWriteMMIO32(afc_handle, 0, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+(dev_addr&MSGDMA_BBB_MEM_WINDOW_SPAN_MASK), *host_addr);
		
		host_addr += 1;
		dev_addr += 4;
	}
}

void copy_from_dev_with_mmio(fpga_handle afc_handle, uint64_t *host_dst, uint64_t dev_src, int len)
{
	//mmio requires 8 byte alignment
	assert(len % 8 == 0);
	assert(dev_src % 8 == 0);
	
	uint64_t dev_addr = dev_src;
	uint64_t *host_addr = host_dst;
	
	uint64_t cur_mem_page = dev_addr & ~MSGDMA_BBB_MEM_WINDOW_SPAN_MASK;
	fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), cur_mem_page);
	
	for(int i = 0; i < len/8; i++)
	{
		uint64_t mem_page = dev_addr & ~MSGDMA_BBB_MEM_WINDOW_SPAN_MASK;
		if(mem_page != cur_mem_page)
		{
			cur_mem_page = mem_page;
			fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), cur_mem_page);
		}
		fpgaReadMMIO64(afc_handle, 0, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+(dev_addr&MSGDMA_BBB_MEM_WINDOW_SPAN_MASK), host_addr);
		
		host_addr += 1;
		dev_addr += 8;
	}
}

void copy_from_dev_with_mmio32(fpga_handle afc_handle, uint32_t *host_dst, uint64_t dev_src, int len)
{
	//mmio requires 8 byte alignment
	assert(len % 4 == 0);
	assert(dev_src % 4 == 0);
	
	uint64_t dev_addr = dev_src;
	uint32_t *host_addr = host_dst;
	
	uint64_t cur_mem_page = dev_addr & ~MSGDMA_BBB_MEM_WINDOW_SPAN_MASK;
	fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), cur_mem_page);
	
	for(int i = 0; i < len/4; i++)
	{
		uint64_t mem_page = dev_addr & ~MSGDMA_BBB_MEM_WINDOW_SPAN_MASK;
		if(mem_page != cur_mem_page)
		{
			cur_mem_page = mem_page;
			fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), cur_mem_page);
		}
		fpgaReadMMIO32(afc_handle, 0, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+(dev_addr&MSGDMA_BBB_MEM_WINDOW_SPAN_MASK), host_addr);
		
		host_addr += 1;
		dev_addr += 4;
	}
}

int compare_dev_and_host(fpga_handle afc_handle, uint64_t *host_dst, uint64_t dev_src, int len)
{
	//mmio requires 8 byte alignment
	assert(len % 8 == 0);
	assert(dev_src % 8 == 0);
	
	uint64_t dev_addr = dev_src;
	uint64_t *host_addr = host_dst;
	
	uint64_t cur_mem_page = dev_addr & ~MSGDMA_BBB_MEM_WINDOW_SPAN_MASK;
	fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), cur_mem_page);
	
	int num_errors = 0;
	uint64_t cmp_data;
	for(int i = 0; i < len/8; i++)
	{
		uint64_t mem_page = dev_addr & ~MSGDMA_BBB_MEM_WINDOW_SPAN_MASK;
		if(mem_page != cur_mem_page)
		{
			cur_mem_page = mem_page;
			fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), cur_mem_page);
		}
		fpgaReadMMIO64(afc_handle, 0, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+(dev_addr&MSGDMA_BBB_MEM_WINDOW_SPAN_MASK), &cmp_data);
		if(*host_addr != cmp_data)
			num_errors++;
		
		host_addr += 1;
		dev_addr += 8;
	}
	
	return num_errors;
}


int compare_dev_and_host_and_dump(fpga_handle afc_handle, uint64_t *host_dst, uint64_t dev_src, int len)
{
	//mmio requires 8 byte alignment
	assert(len % 8 == 0);
	assert(dev_src % 8 == 0);
	
	uint64_t dev_addr = dev_src;
	uint64_t *host_addr = host_dst;
	
	uint64_t cur_mem_page = dev_addr & ~MSGDMA_BBB_MEM_WINDOW_SPAN_MASK;
	fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), cur_mem_page);
	
	int num_errors = 0;
	uint64_t cmp_data;
	for(int i = 0; i < len/8; i++)
	{
		uint64_t mem_page = dev_addr & ~MSGDMA_BBB_MEM_WINDOW_SPAN_MASK;
		if(mem_page != cur_mem_page)
		{
			cur_mem_page = mem_page;
			fpgaWriteMMIO64(afc_handle, 0, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), cur_mem_page);
		}
		fpgaReadMMIO64(afc_handle, 0, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+(dev_addr&MSGDMA_BBB_MEM_WINDOW_SPAN_MASK), &cmp_data);
		if(*host_addr != cmp_data)
			num_errors++;
		
		host_addr += 1;
		dev_addr += 8;
		
		printf("%ld ", cmp_data);
	}
	
	return num_errors;
}

typedef struct __attribute__((__packed__)) 
{
	//0x0
	uint32_t rd_address;
	//0x4
	uint32_t wr_address;
	//0x8
	uint32_t len;
	//0xC
	uint8_t wr_burst_count;
	uint8_t rd_burst_count;
	uint16_t seq_num;
	//0x10
	uint16_t wr_stride;
	uint16_t rd_stride;
	//0x14
	uint32_t rd_address_ext;
	//0x18
	uint32_t wr_address_ext;
	//0x1c
	uint32_t control;
} msgdma_ext_descriptor_t;

void copy_dev_to_dev_with_mmio(fpga_handle afc_handle, uint64_t dev_src, uint64_t dev_dest, int len)
{
	//dma requires 64 byte alignment
	assert(len % 64 == 0);
	assert(dev_src % 64 == 0);
	assert(dev_dest % 64 == 0);
	
	uint64_t *tmp = (uint64_t *)malloc(len);
	assert(tmp);
	
	copy_from_dev_with_mmio(afc_handle, tmp, dev_src, len);
	copy_to_dev_with_mmio(afc_handle, tmp, dev_dest, len);
	
	free(tmp);
}

void copy_dev_to_dev_with_dma(fpga_handle afc_handle, uint64_t dev_src, uint64_t dev_dest, int len)
{
	//dma requires 64 byte alignment
	assert(len % 64 == 0);
	assert(dev_src % 64 == 0);
	assert(dev_dest % 64 == 0);
	
	//only 32bit for now
	const uint64_t MASK_FOR_32BIT_ADDR = 0xFFFFFFFF;
	
	msgdma_ext_descriptor_t d;
	
	d.rd_address = dev_src & MASK_FOR_32BIT_ADDR;
	d.wr_address = dev_dest & MASK_FOR_32BIT_ADDR;  
	d.len = len;
	d.wr_burst_count = 1;
	d.rd_burst_count = 1;
	d.seq_num = 0;
	d.wr_stride = 1;
	d.rd_stride = 1;
	d.rd_address_ext = (dev_src >> 32) & MASK_FOR_32BIT_ADDR;
	d.wr_address_ext = (dev_dest >> 32)& MASK_FOR_32BIT_ADDR;  
	d.control = 0x80000000;
	
	const uint64_t SGDMA_CSR_BASE = msgdma_bbb_dfh_offset+ACL_DMA_INST_DMA_MODULAR_SGDMA_DISPATCHER_0_CSR_BASE;
	const uint64_t SGDMA_DESC_BASE = msgdma_bbb_dfh_offset+ACL_DMA_INST_DMA_MODULAR_SGDMA_DISPATCHER_0_DESCRIPTOR_SLAVE_BASE;
	uint64_t mmio_data;
	
	copy_to_mmio(afc_handle, SGDMA_DESC_BASE, (uint64_t *)&d, sizeof(d));
	mmio_read64_silent(afc_handle, SGDMA_CSR_BASE, &mmio_data);
	while(mmio_data !=0x2)
	{
#ifdef USE_ASE
		sleep(1);
		mmio_read64(afc_handle, SGDMA_CSR_BASE, &mmio_data, "sgdma_csr_base");
#else
		mmio_read64_silent(afc_handle, SGDMA_CSR_BASE, &mmio_data);
#endif
	}
}

int run_basic_ddr_dma_test(fpga_handle afc_handle)
{
	volatile uint64_t *dma_buf_ptr  = NULL;
	uint64_t        dma_buf_wsid;
	uint64_t dma_buf_iova;
	
	uint64_t data = 0;
	fpga_result     res = FPGA_OK;

#ifdef USE_ASE
	const int TEST_BUFFER_SIZE = 256;
	//const int TEST_BUFFER_SIZE = 256*128;
#else
	const int TEST_BUFFER_SIZE = 1024*1024-64;
#endif

	const int TEST_BUFFER_WORD_SIZE = TEST_BUFFER_SIZE/8;
	char test_buffer[TEST_BUFFER_SIZE];
	uint64_t *test_buffer_word_ptr = (uint64_t *)test_buffer;
	char test_buffer_zero[TEST_BUFFER_SIZE];
	int num_errors = 0;
	const uint64_t DEST_PTR = 1024*1024;


	res = fpgaPrepareBuffer(afc_handle, DMA_BUFFER_SIZE,
		(void **)&dma_buf_ptr, &dma_buf_wsid, 0);
	ON_ERR_GOTO(res, release_buf, "allocating dma buffer");
	memset((void *)dma_buf_ptr,  0x0, DMA_BUFFER_SIZE);
	
	res = fpgaGetIOAddress(afc_handle, dma_buf_wsid, &dma_buf_iova);
	ON_ERR_GOTO(res, release_buf, "getting dma DMA_BUF_IOVA");
	
	printf("TEST_BUFFER_SIZE = %d\n", TEST_BUFFER_SIZE);
	printf("DMA_BUFFER_SIZE = %d\n", DMA_BUFFER_SIZE);
	
	memset(test_buffer_zero, 0, TEST_BUFFER_SIZE);
	
	
	for(int i = 0; i < TEST_BUFFER_WORD_SIZE; i++)
		test_buffer_word_ptr[i] = i;
	
	copy_to_dev_with_mmio(afc_handle, test_buffer_word_ptr, 0, TEST_BUFFER_SIZE);
	copy_to_dev_with_mmio(afc_handle, (uint64_t *)test_buffer_zero, DEST_PTR, TEST_BUFFER_SIZE);
	
	//test ddr to ddr transfers
	copy_dev_to_dev_with_dma(afc_handle, 0, DEST_PTR, TEST_BUFFER_SIZE);
	num_errors += compare_dev_and_host(afc_handle, test_buffer_word_ptr, DEST_PTR, TEST_BUFFER_SIZE);
	
	//test ddr to host transfers
	//basic host ddr test
	copy_to_dev_with_mmio(afc_handle, test_buffer_word_ptr, 0, TEST_BUFFER_SIZE);
	copy_dev_to_dev_with_dma(afc_handle, 0, dma_buf_iova | 0x1000000000000, TEST_BUFFER_SIZE);
	/*for(int i = 0; i < TEST_BUFFER_WORD_SIZE; i++)
		printf("%ld ", ((uint64_t *)dma_buf_ptr)[i]);
	printf("\n");*/
	if(memcmp((void *)dma_buf_ptr, (void *)test_buffer_word_ptr, TEST_BUFFER_SIZE) != 0)
	{
		printf("ERROR: memcmp failed!\n");
		num_errors++;
	}
	num_errors += compare_dev_and_host(afc_handle, (uint64_t *)dma_buf_ptr, DEST_PTR, TEST_BUFFER_SIZE);
	
	//test host to ddr transfers
	copy_to_dev_with_mmio(afc_handle, (uint64_t *)test_buffer_zero, DEST_PTR, TEST_BUFFER_SIZE);
	copy_dev_to_dev_with_dma(afc_handle, dma_buf_iova | 0x1000000000000, DEST_PTR, TEST_BUFFER_SIZE);
	num_errors += compare_dev_and_host(afc_handle, test_buffer_word_ptr, DEST_PTR, TEST_BUFFER_SIZE);
	
	printf("num_errors = %d\n", num_errors);
	s_error_count += num_errors;
	
release_buf:
	res = fpgaReleaseBuffer(afc_handle, dma_buf_wsid);
}

int dma_memory_checker(
	fpga_handle afc_handle,
	uint64_t dma_buf_iova,
	volatile uint64_t *dma_buf_ptr
)
{
	int num_errors = 0;
	
#ifdef USE_ASE
	const long DMA_TEST_MEM_SIZE	 = 1024;
	const long DMA_BUF_SIZE = 256;
#else
	const long DMA_TEST_MEM_SIZE	 = 8l*1024l*1024l*1024l;
	const long DMA_BUF_SIZE = 512*1024;
#endif

	RC4Memtest rc4_obj;
	long byte_errors = 0;
	long page_errors = 0;
	const char *RC4_KEY = "mytestkey";
	
	rc4_obj.setup_key(RC4_KEY);
	
	assert(DMA_TEST_MEM_SIZE % DMA_BUF_SIZE == 0);
	
	const long NUM_DMA_TRANSFERS = DMA_TEST_MEM_SIZE/DMA_BUF_SIZE;
	
	for(long i = 0; i < NUM_DMA_TRANSFERS; i++)
	{
		rc4_obj.write_bytes((char *)dma_buf_ptr, (int)DMA_BUF_SIZE);
		uint64_t dev_addr = i*DMA_BUF_SIZE;
		
		//TODO: currently broken due to read response out of order
		#ifdef USE_ASE
		copy_to_dev_with_mmio(afc_handle, (uint64_t*)dma_buf_ptr, dev_addr, DMA_BUF_SIZE);
		#else
		copy_dev_to_dev_with_dma(afc_handle, dma_buf_iova | 0x1000000000000, dev_addr, DMA_BUF_SIZE);
		#endif
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
	
	printf("mem_size=%ld dma_buf_size=%ld num_dma_buf=%ld\n", DMA_TEST_MEM_SIZE, DMA_BUF_SIZE, NUM_DMA_TRANSFERS);
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

int dma_memory_checker(fpga_handle afc_handle)
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
	
	dma_memory_checker(afc_handle, dma_buf_iova, dma_buf_ptr);

release_buf:
	res = fpgaReleaseBuffer(afc_handle, dma_buf_wsid);
}

int check_host_read_from_mmio(fpga_handle afc_handle)
{
	uint64_t data = 0;
	
	//using this address will crash ASE/host until we cut this path on the
	//address span extender
	uint64_t address = 0x1000 | 0x1000000000000;
	
	mmio_write64(afc_handle, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), address, "addr_span");
	mmio_read64(afc_handle, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), &data, "addr_span");
	
	for(int i = 0; i < 10; i++)
	{
		mmio_read64(afc_handle, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+i*8, &data, "memaddr_i");
	}
}

int run_basic_tests_with_mmio(fpga_handle afc_handle)
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
	
	const int MEM_OFFSET = 0x100;
	
	mmio_write64(afc_handle, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset), 0x12345678abcdef09, "memaddr0");
	mmio_write64(afc_handle, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+8, 0xa1b2c3d4e5f60798, "memaddr1");
	mmio_read64(afc_handle, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset), &data, "memaddr0");
	mmio_read64(afc_handle, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+8, &data, "memaddr1");
	
	mmio_read64(afc_handle, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), &data, "addr_span");
	mmio_write64(afc_handle, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), 0x10000, "addr_span");
	mmio_read64(afc_handle, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), &data, "addr_span");
	
	mmio_read64(afc_handle, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset), &data, "memaddr0");
	mmio_read64(afc_handle, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+8, &data, "memaddr1");
	
	for(int i = 0; i < 10; i++)
	{
		//usleep(1000*1000);
		mmio_write64(afc_handle, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+MEM_OFFSET+i*8, i, "memaddr_i");
	}
	for(int i = 0; i < 10; i++)
	{
		//usleep(1000*1000);
		mmio_read64(afc_handle, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+MEM_OFFSET+i*8, &data, "memaddr_i");
	}
	
	mmio_write64(afc_handle, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), 0x0000, "addr_span");
	mmio_read64(afc_handle, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), &data, "addr_span");
	
	for(int i = 0; i < 10; i++)
	{
		//usleep(1000*1000);
		mmio_read64(afc_handle, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+MEM_OFFSET+i*8, &data, "memaddr_i");
	}
	
	mmio_read64(afc_handle, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset), &data, "memaddr0");
	mmio_read64(afc_handle, MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+8, &data, "memaddr1");

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
			rc4_obj.write_bytes(test_buffer, PAGE_SIZE);
			uint64_t dev_addr = m*NEXT_MEMORY_OFFSET+ASE_MEM_PAGE_SIZE*p;
			copy_to_dev_with_mmio(afc_handle, (uint64_t*)test_buffer, dev_addr, PAGE_SIZE);
		}
	}
	
	//reload rc4 state to begining
	rc4_obj.setup_key(RC4_KEY);
	
	for(long m = 0; m < NUM_MEMS; m++)
	{
		for(long p = 0; p < NUM_PAGES; p++)
		{
			uint64_t dev_addr = m*NEXT_MEMORY_OFFSET+ASE_MEM_PAGE_SIZE*p;
			copy_from_dev_with_mmio(afc_handle, (uint64_t*)test_buffer, dev_addr, PAGE_SIZE);
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
		s_error_count += 1;
		return 0;
	}
	
	return 1;
}

int run_basic_32bit_mmio(fpga_handle afc_handle)
{
	uint64_t data64 = 0;
	uint32_t data = 0;

	const int NUM_64BIT_ACCESSES = 16;	
	const int NUM_32BIT_ACCESSES = 16;
	//const int NUM_64BIT_ACCESSES = 16*32;	
	//const int NUM_32BIT_ACCESSES = 16*32;
	
	const int MEM_OFFSET = 0x100;

	//make sure we are on the right ddr page
	mmio_write64(afc_handle, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), 0x0000, "addr_span");
	mmio_read64(afc_handle, MEM_WINDOW_CRTL(msgdma_bbb_dfh_offset), &data64, "addr_span");
	
	//64bit
	int error_count64 = 0;
	for(int i = 0; i < NUM_64BIT_ACCESSES; i++)
	{
		uint64_t addr = MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+MEM_OFFSET+i*8;
		mmio_write64(afc_handle, addr, i, "memaddr_i");
	}
	for(int i = 0; i < NUM_64BIT_ACCESSES; i++)
	{
		uint64_t addr = MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+MEM_OFFSET+i*8;
		mmio_read64(afc_handle, addr, &data64, "memaddr_i");
		if(data64 != i)
		{
			error_count64++;
			printf("ERROR: 64bit MMIO addr %lx - data %ld != %d(expected)\n", addr, data64, i);
		}
	}
	
	//32bit
	int error_count32 = 0;
	for(int i = 0; i < NUM_32BIT_ACCESSES; i++)
	{
		uint64_t addr = MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+MEM_OFFSET+i*4;
		mmio_write32(afc_handle, addr, i, "memaddr_i");
	}
	for(int i = 0; i < NUM_32BIT_ACCESSES; i++)
	{
		uint64_t addr = MEM_WINDOW_MEM(msgdma_bbb_dfh_offset)+MEM_OFFSET+i*4;
		mmio_read32(afc_handle, addr, &data, "memaddr_i");
		if(data != i)
		{
			error_count32++;
			printf("ERROR: 32bit MMIO addr %lx - data %d != %d(expected)\n", addr, data, i);
		}
	}

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
			rc4_obj.write_bytes(test_buffer, PAGE_SIZE);
			uint64_t dev_addr = m*NEXT_MEMORY_OFFSET+ASE_MEM_PAGE_SIZE*p;
			copy_to_dev_with_mmio32(afc_handle, (uint32_t*)test_buffer, dev_addr, PAGE_SIZE);
		}
	}
	
	//reload rc4 state to begining
	rc4_obj.setup_key(RC4_KEY);
	
	for(long m = 0; m < NUM_MEMS; m++)
	{
		for(long p = 0; p < NUM_PAGES; p++)
		{
			uint64_t dev_addr = m*NEXT_MEMORY_OFFSET+ASE_MEM_PAGE_SIZE*p;
			copy_from_dev_with_mmio32(afc_handle, (uint32_t*)test_buffer, dev_addr, PAGE_SIZE);
			long errors = rc4_obj.check_bytes(test_buffer, PAGE_SIZE);
			if(errors)
				page_errors++;
			byte_errors += page_errors;
		}
	}
	
	printf("num_pages=%ld page_size=%ld num_mems=%ld total_mem_span=%ld\n", NUM_PAGES, PAGE_SIZE, NUM_MEMS, NUM_MEMS*NUM_PAGES*ASE_MEM_PAGE_SIZE);
	printf("byte_errors=%ld, page_errors=%ld\n", byte_errors, page_errors);
	
	s_error_count += error_count32;
	s_error_count += error_count64;
	
	printf("MMIO 64bit errors=%d, MMIO 32bit errors=%d\n", error_count64,
		error_count32);
	
	if(byte_errors)
	{
		printf("ERROR: memtest FAILED!\n");
		s_error_count += 1;
		return 0;
	}
	
	return 1;
}

#define DFH_FEATURE_EOL(dfh) (((dfh >> 40) & 1) == 1)
#define DFH_FEATURE(dfh) ((dfh >> 60) & 0xf)
#define DFH_FEATURE_IS_PRIVATE(dfh) (DFH_FEATURE(dfh) == 3)
#define DFH_FEATURE_IS_BBB(dfh) (DFH_FEATURE(dfh) == 2)
#define DFH_FEATURE_IS_AFU(dfh) (DFH_FEATURE(dfh) == 1)
#define DFH_FEATURE_NEXT(dfh) ((dfh >> 16) & 0xffffff)

int dump_dfh_list(fpga_handle afc_handle)
{
	uint64_t offset = 0;
	uint64_t dfh = 0;
	
	do
	{
		mmio_read64_silent(afc_handle, offset, &dfh);
		int is_bbb = DFH_FEATURE_IS_BBB(dfh);
		int is_afu = DFH_FEATURE_IS_AFU(dfh);
		int is_private = DFH_FEATURE_IS_PRIVATE(dfh);
		uint64_t id_l = 0;
		uint64_t id_h = 0;
		
		if(is_afu || is_bbb)
		{
			mmio_read64_silent(afc_handle, offset+8, &id_l);
			mmio_read64_silent(afc_handle, offset+16, &id_h);
		}
		
		printf("DFH=0x%08lx offset=%lx next_offset=%lx ", dfh, offset, DFH_FEATURE_NEXT(dfh));

		if(is_afu)
			printf("type=afu ");
		else if(is_bbb)
			printf("type=bbb ");
		else if(is_private)
			printf("type=private ");
		else
			printf("type=unknown ");			
		if(is_afu || is_bbb)
			printf("id_l=0x%08lx id_h=0x%08lx", id_l, id_h);
		
		offset += DFH_FEATURE_NEXT(dfh);
		printf("\n");
	} while(!DFH_FEATURE_EOL(dfh));
	
	return 1;
}

bool find_dfh_by_guid(fpga_handle afc_handle, 
	uint64_t find_id_l, uint64_t find_id_h, 
	uint64_t *result_offset = NULL, uint64_t *result_next_offset = NULL)
{
	if(result_offset)
		*result_offset = 0;
	if(result_next_offset)
		*result_next_offset = 0;
	
	if(find_id_l == 0)
		return 0;
	if(find_id_l == 0)
		return 0;

	uint64_t offset = 0;
	uint64_t dfh = 0;
	
	do
	{
		mmio_read64_silent(afc_handle, offset, &dfh);
		int is_bbb = DFH_FEATURE_IS_BBB(dfh);
		int is_afu = DFH_FEATURE_IS_AFU(dfh);
		
		if(is_afu || is_bbb)
		{
			uint64_t id_l = 0;
			uint64_t id_h = 0;
			mmio_read64_silent(afc_handle, offset+8, &id_l);
			mmio_read64_silent(afc_handle, offset+16, &id_h);
			if(find_id_l == id_l && find_id_h == id_h)
			{
				if(result_offset)
					*result_offset = offset;
				if(result_next_offset)
					*result_next_offset = DFH_FEATURE_NEXT(dfh);
				return 1;
			}
		}
		
		offset += DFH_FEATURE_NEXT(dfh);
	} while(!DFH_FEATURE_EOL(dfh));
	
	return 0;
}

bool find_dfh_by_guid(fpga_handle afc_handle, 
	const char *guid_str,
	uint64_t *result_offset = NULL, uint64_t *result_next_offset = NULL)
{
	fpga_guid          guid;

	fpga_result     res = FPGA_OK;

	if (uuid_parse(guid_str, guid) < 0)
		return 0;
	
	uint32_t i;
	uint32_t s;
	
	uint64_t find_id_l = 0;
	uint64_t find_id_h = 0;
	
	// The API expects the MSB of the GUID at [0] and the LSB at [15].
	s = 64;
	for (i = 0; i < 8; ++i) {
		s -= 8;
		find_id_h = ((find_id_h << 8) | (0xff & guid[i]));
	}
	
	s = 64;
	for (i = 0; i < 8; ++i) {
		s -= 8;
		find_id_l = ((find_id_l << 8) | (0xff & guid[8 + i]));
	}
	
	return find_dfh_by_guid(afc_handle, find_id_l, find_id_h, 
		result_offset, result_next_offset);
}

void check_guid(fpga_handle afc_handle, uint64_t id_l, uint64_t id_h, const char *name = NULL)
{
	uint64_t offset = 0;
	uint64_t size = 0;
	int has_guid = find_dfh_by_guid(afc_handle, id_l, id_h, &offset, &size);
	
	const char *has_guid_str = has_guid == 1 ? "found" : "not found";
	
	if(name)
		printf("%s is %s", name, has_guid_str);
	else
		printf("GUID %08lx:%08lx is %s", id_l, id_h, has_guid_str);
	
	if(has_guid)
		printf(" offset=%08lx size=%ld", offset, size);
	
	printf("\n");
}

int run_enumeration_test(fpga_handle afc_handle)
{
	dump_dfh_list(afc_handle);
	check_guid(afc_handle, 1, 2);
	check_guid(afc_handle, 0xb383c70ace57bfe4, 0x4c9c96f465ba4dd8, "mpf_read_rsp_reorder");
	check_guid(afc_handle, 0x94eb7d79c7c01ca3, 0xd79c094c7cf94cc1, "msgdma_bbb");
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

	res = fpgaPropertiesSetObjectType(filter, FPGA_AFC);
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
	assert(found_dfh);
	assert(dfh_size == MSGDMA_BBB_SIZE);

	run_basic_tests_with_mmio(afc_handle);
	run_basic_ddr_dma_test(afc_handle);
	dma_memory_checker(afc_handle);
	run_basic_32bit_mmio(afc_handle);
	run_enumeration_test(afc_handle);
	check_host_read_from_mmio(afc_handle);

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
