// Copyright(c) 2017, Intel Corporation
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
// ARE DISCLAIMED.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS BE
// LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#include <string.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>
#include <time.h>
#include <sys/mman.h>
#include <stdbool.h>
#include "fpga_dma.h"
/**
 * \fpga_dma_test.c
 * \brief User-mode DMA test
 */

#include <stdlib.h>
#include <assert.h>

#define HELLO_AFU_ID              "331DB30C-9885-41EA-9081-F88B8F655CAA"
#define TEST_BUF_SIZE (10*1024*1024)
#define ASE_TEST_BUF_SIZE (4*1024)

#ifdef CHECK_DELAYS
extern double poll_wait_count;
extern double buf_full_count;
char cbuf[2048];
#endif

static int err_cnt = 0;

// Options determining various optimization attempts
bool use_malloc = true;
bool use_memcpy = true;
bool use_advise = false;
bool do_not_verify = false;

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


// Aligned malloc
static inline void *malloc_aligned(uint64_t align, size_t size)
{
	assert(align && ((align & (align - 1)) == 0));      // Must be power of 2 and not 0
	assert(align >= 2 * sizeof(void *));
	void *blk = NULL;
	if (use_malloc)
	{
		blk = malloc(size + align + 2 * sizeof(void *));
	}
	else
	{
		align = getpagesize();
		blk = mmap(NULL, size + align + 2 * sizeof(void *), PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANONYMOUS | MAP_POPULATE, 0, 0);
	}
	void **aptr =
		(void **)(((uint64_t)blk + 2 * sizeof(void *) + (align - 1)) &
			~(align - 1));
	aptr[-1] = blk;
	aptr[-2] = (void *)(size + align + 2 * sizeof(void *));
	return aptr;
}

// Aligned free
static inline void free_aligned(void *ptr)
{
	void **aptr = (void **)ptr;
	if (use_malloc)
	{
		free(aptr[-1]);
	}
	else
	{
		munmap(aptr[-1], (size_t)aptr[-2]);
	}
	return;
}


static inline void fill_buffer(char *buf, size_t size) {
   if(do_not_verify) return;
   size_t i=0;
   // use a deterministic seed to generate pseudo-random numbers
   srand(99);

   for(i=0; i<size; i++) {
      *buf = rand()%256;
      buf++;
   }
}

static inline fpga_result verify_buffer(char *buf, size_t size) {
   if(do_not_verify) return FPGA_OK;
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

static inline void clear_buffer(char *buf, size_t size) {
   if(do_not_verify) return;
   memset(buf, 0, size);
}

static inline char *showDelays(char *buf)
{
#ifdef CHECK_DELAYS
	sprintf(buf, "Avg per iteration: Poll delays: %g, Descriptor buffer full delays: %g", poll_wait_count, buf_full_count);
#else
	buf[0] = '\0';
#endif
	return buf;
}

static inline void report_bandwidth(size_t size, double seconds) {
	char buf[2048];
   double throughput = (double)size/((double)seconds*1000*1000);
   printf("\rMeasured bandwidth = %lf Megabytes/sec %s\n", throughput, showDelays(buf));

#ifdef CHECK_DELAYS
   poll_wait_count = 0;
   buf_full_count = 0;
#endif
}

// return elapsed time
static inline double getTime(struct timespec start, struct timespec end) {
   uint64_t diff = 1000000000L * (end.tv_sec - start.tv_sec) + end.tv_nsec - start.tv_nsec;
   return (double) diff/(double)1000000000L;
}


fpga_result ddr_sweep(fpga_dma_handle dma_h) {
   int res;
	struct timespec start, end;
   
   ssize_t total_mem_size = (uint64_t)(4*1024)*(uint64_t)(1024*1024);
   
   uint64_t *dma_buf_ptr = malloc_aligned(getpagesize(), total_mem_size);
   if(dma_buf_ptr == NULL) {
      printf("Unable to allocate %ld bytes of memory", total_mem_size);
      return FPGA_NO_MEMORY;
   }
   printf("Allocated test buffer\n");
   if (use_advise)
   {
	   if (0 != madvise(dma_buf_ptr, total_mem_size, MADV_SEQUENTIAL))
		   perror("Warning: madvise returned error");
   }
   printf("Fill test buffer\n");
   fill_buffer((char*)dma_buf_ptr, total_mem_size);

   uint64_t src = (uint64_t)dma_buf_ptr;
   uint64_t dst = 0x0;

   double tot_time = 0.0;
   int i;
   
   printf("DDR Sweep Host to FPGA\n");   

#define ITERS 32

#ifdef CHECK_DELAYS
   poll_wait_count = 0;
   buf_full_count = 0;
#endif

   for(i = 0; i < ITERS; i++)
   {
	clock_gettime(CLOCK_MONOTONIC, &start);
      res = fpgaDmaTransferSync(dma_h, dst, src, total_mem_size, HOST_TO_FPGA_MM);
	clock_gettime(CLOCK_MONOTONIC, &end);
      if(res != FPGA_OK) {
         printf(" fpgaDmaTransferSync Host to FPGA failed with error %s", fpgaErrStr(res));
         free_aligned(dma_buf_ptr);
         return FPGA_EXCEPTION;
      }
      tot_time += getTime(start,end);
   }

#ifdef CHECK_DELAYS
   poll_wait_count /= (double)ITERS;
   buf_full_count /= (double)ITERS;
#endif

   report_bandwidth(total_mem_size * ITERS, tot_time);
   tot_time = 0.0;

   printf("\rClear buffer\n");
   clear_buffer((char*)dma_buf_ptr, total_mem_size);

   src = 0x0;
   dst = (uint64_t)dma_buf_ptr;
	
   printf("DDR Sweep FPGA to Host\n");   

#ifdef CHECK_DELAYS
   poll_wait_count = 0;
   buf_full_count = 0;
#endif

   for(i = 0; i < ITERS; i++)
   {
	clock_gettime(CLOCK_MONOTONIC, &start);
      res = fpgaDmaTransferSync(dma_h, dst, src, total_mem_size, FPGA_TO_HOST_MM);
	clock_gettime(CLOCK_MONOTONIC, &end);

      if(res != FPGA_OK) {
         printf(" fpgaDmaTransferSync FPGA to Host failed with error %s", fpgaErrStr(res));
         free_aligned(dma_buf_ptr);
         return FPGA_EXCEPTION;
      }
      tot_time += getTime(start,end);
   }

#ifdef CHECK_DELAYS
   poll_wait_count /= (double)ITERS;
   buf_full_count /= (double)ITERS;
#endif

   report_bandwidth(total_mem_size * ITERS, tot_time);
   tot_time = 0.0;
   
   printf("Verifying buffer..\n");   
   verify_buffer((char*)dma_buf_ptr, total_mem_size);

   free_aligned(dma_buf_ptr);
   return FPGA_OK;
}

static void usage(void)
{
	printf("Usage: fpga_dma_test <use_ase = 1 (simulation only), 0 (hardware)> [options]\n");
	printf("Options are:\n");
	printf("\t-m\tUse malloc (default)\n");
	printf("\t-p\tUse mmap (Incompatible with -m)\n");
	printf("\t-c\tUse builtin memcpy (default)\n");
	printf("\t-2\tUse SSE2 memcpy (Incompatible with -c)\n");
	printf("\t-n\tDo not provide OS advice (default)\n");
	printf("\t-a\tUse madvise (Incompatible with -n)\n");
	printf("\t-y\tDo not verify buffer contents - faster (default is to verify)\n");
}

int main(int argc, char *argv[]) {
   fpga_result res = FPGA_OK;
   fpga_dma_handle dma_h;
   uint64_t count;
   fpga_properties filter = NULL;
   fpga_token afc_token;
   fpga_handle afc_h;
   fpga_guid guid;
   uint32_t num_matches;
   volatile uint64_t *mmio_ptr = NULL;
   uint64_t *dma_buf_ptr  = NULL;   
   uint32_t use_ase;

   if(argc < 2) {
	usage();
	return 1;
   }

   if (!isdigit(*argv[1])) {
	   usage();
	   return 1;
   }

   use_ase = atoi(argv[1]);
   if(use_ase) {
      printf("Running test in ASE mode\n");
   } else {
      printf("Running test in HW mode\n");
   }

   int x;
   for (x = 2; x < argc; x++)
   {
	   char *str = argv[x];
	   if (str[0] != '-')
	   {
		   usage();
		   return 1;
	   }

	   switch (str[1])
	   {
	   case 'm':
		   use_malloc = true;
		   break;
	   case 'p':
		   use_malloc = false;
		   break;
	   case 'c':
		   use_memcpy = true;
		   break;
	   case '2':
		   use_memcpy = false;
		   break;
	   case 'n':
		   use_advise = false;
		   break;
	   case 'a':
		   use_advise = true;
		   break;
	   case 'y':
		   do_not_verify = true;
		   break;
	   default:
		   return 1;
	   }
   }

   // enumerate the afc
   if(uuid_parse(HELLO_AFU_ID, guid) < 0) {
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

   res = fpgaDmaOpen(afc_h, &dma_h);
   ON_ERR_GOTO(res, out_dma_close, "fpgaDmaOpen");
   if(!dma_h) {
      res = FPGA_EXCEPTION;
      ON_ERR_GOTO(res, out_dma_close, "Invaid DMA Handle");
   }

   if(use_ase)
      count = ASE_TEST_BUF_SIZE;
   else
      count = TEST_BUF_SIZE;

   dma_buf_ptr = (uint64_t*)malloc_aligned(getpagesize(), count);
   if(!dma_buf_ptr) {
      res = FPGA_NO_MEMORY;
      ON_ERR_GOTO(res, out_dma_close, "Error allocating memory");
   }

   if (use_advise)
   {
	   int rr = madvise(dma_buf_ptr, count, MADV_SEQUENTIAL);
	   ON_ERR_GOTO((rr == 0) ? FPGA_OK : FPGA_EXCEPTION, out_dma_close, "Error madvise");
   }

   fill_buffer((char*)dma_buf_ptr, count);

   // Test procedure
   // - Fill host buffer with pseudo-random data
   // - Copy from host buffer to FPGA buffer at address 0x0
   // - Clear host buffer
   // - Copy from FPGA buffer to host buffer
   // - Verify host buffer data
   // - Clear host buffer
   // - Copy FPGA buffer at address 0x0 to FPGA buffer at addr "count"
   // - Copy data from FPGA buffer at addr "count" to host buffer
   // - Verify host buffer data

   // copy from host to fpga

#ifdef CHECK_DELAYS
   poll_wait_count = 0;
   buf_full_count = 0;
#endif

   res = fpgaDmaTransferSync(dma_h, 0x0 /*dst*/, (uint64_t)dma_buf_ptr /*src*/, count, HOST_TO_FPGA_MM);
   ON_ERR_GOTO(res, out_dma_close, "fpgaDmaTransferSync HOST_TO_FPGA_MM");
   clear_buffer((char*)dma_buf_ptr, count);

#ifdef CHECK_DELAYS
   printf("H->F size 0x%lx, %s\n", count, showDelays(cbuf));
   poll_wait_count = 0;
   buf_full_count = 0;
#endif

   // copy from fpga to host
   res = fpgaDmaTransferSync(dma_h, (uint64_t)dma_buf_ptr /*dst*/, 0x0 /*src*/, count, FPGA_TO_HOST_MM);
   ON_ERR_GOTO(res, out_dma_close, "fpgaDmaTransferSync FPGA_TO_HOST_MM");
   res = verify_buffer((char*)dma_buf_ptr, count);
   ON_ERR_GOTO(res, out_dma_close, "verify_buffer");

   clear_buffer((char*)dma_buf_ptr, count);

#ifdef CHECK_DELAYS
   printf("F->H size 0x%lx, %s\n", count, showDelays(cbuf));
   poll_wait_count = 0;
   buf_full_count = 0;
#endif

   // copy from fpga to fpga
   res = fpgaDmaTransferSync(dma_h, count /*dst*/, 0x0 /*src*/, count, FPGA_TO_FPGA_MM);
   ON_ERR_GOTO(res, out_dma_close, "fpgaDmaTransferSync FPGA_TO_FPGA_MM");

#ifdef CHECK_DELAYS
   printf("F->F size 0x%lx, %s\n", count, showDelays(cbuf));
   poll_wait_count = 0;
   buf_full_count = 0;
#endif

   // copy from fpga to host
   res = fpgaDmaTransferSync(dma_h, (uint64_t)dma_buf_ptr /*dst*/, count /*src*/, count, FPGA_TO_HOST_MM);
   ON_ERR_GOTO(res, out_dma_close, "fpgaDmaTransferSync FPGA_TO_HOST_MM");

#ifdef CHECK_DELAYS
   printf("F->H size 0x%lx, %s\n", count, showDelays(cbuf));
   poll_wait_count = 0;
   buf_full_count = 0;
#endif

   res = verify_buffer((char*)dma_buf_ptr, count);
   ON_ERR_GOTO(res, out_dma_close, "verify_buffer");

   if(!use_ase) {
      printf("Running DDR sweep test\n");
      res = ddr_sweep(dma_h);
      ON_ERR_GOTO(res, out_dma_close, "ddr_sweep");
   }

out_dma_close:
   free_aligned(dma_buf_ptr);
   if(dma_h)
      res = fpgaDmaClose(dma_h);
   ON_ERR_GOTO(res, out_unmap, "fpgaDmaClose");

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
