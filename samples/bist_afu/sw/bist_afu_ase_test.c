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
#include "bist_afu_ase.h"
/**
 * \bist_afu_ase_test.c
 * \brief User-mode DMA test
 */

#include <stdlib.h>
#include <assert.h>

#define HELLO_AFU_ID              "331DB30C-9885-41EA-9081-F88B8F655CAA"
#define NLB0_AFUID "9caef53d-2fcf-43ea-84b9-aad98993fe41"
#define TEST_BUF_SIZE (10*1024*1024)
#define ASE_TEST_BUF_SIZE (4*1024)

/**************** BIST #defines ***************/
#define ENABLE_DDRA_BIST              0x08000000
#define ENABLE_DDRB_BIST              0x10000000
#define DDR_BIST_CTRL_ADDR           0x198
#define DDR_BIST_STATUS_ADDR         0x200
#define CHECK_BIT(var,pos) ((var) & (1<<(pos)))
#define MAX_COUNT       5000
#define DDRA_BIST_PASS 0x200
#define DDRA_BIST_FAIL 0x100
#define DDRA_BIST_TIMEOUT 0x80
#define DDRA_BIST_FATAL_ERROR 0x40
#define DDRB_BIST_PASS 0x1000
#define DDRB_BIST_FAIL 0x800
#define DDRB_BIST_TIMEOUT 0x400
#define DDRB_BIST_FATAL_ERROR 0x20
#define TRUE 1 
#define FALSE 0 

#define DDR_INIT 0x0
#define DDR_SINGLE_RW 0x1
#define DDR_BLOCK_RW 0x2
#define DDR_AVL_STAGE 0x3
#define DDR_TEMPLATE_STAGE 0x4
#define DDR_REREAD_STAGE 0x5
#define DDR_DONE 0x6
#define DDR_TEST_COMPLETE 0x7
#define DDR_TIMEOUT 0x8
/**************** BIST #defines *****************/




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


void fill_buffer(char *buf, size_t size) {
   size_t i=0;
   // use a deterministic seed to generate pseudo-random numbers
   srand(99);

   for(i=0; i<size; i++) {
      *buf = rand()%256;
      buf++;
   }
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

void report_bandwidth(size_t size, double seconds) {
   double throughput = (double)size/((double)seconds*1000*1000);
   printf("\rMeasured bandwidth = %lf Megabytes/sec\n", throughput);
}

fpga_result ddr_sweep(fpga_dma_handle dma_h) {
   int res;
   
   ssize_t total_mem_size = (uint64_t)(4*1024)*(uint64_t)(1024*1024);
   
   uint64_t *dma_buf_ptr = malloc(total_mem_size);
   if(dma_buf_ptr == NULL) {
      printf("Unable to allocate %ld bytes of memory", total_mem_size);
      return FPGA_NO_MEMORY;
   }
   printf("Allocated test buffer\n");
   printf("Fill test buffer\n");
   fill_buffer((char*)dma_buf_ptr, total_mem_size);

   uint64_t src = (uint64_t)dma_buf_ptr;
   uint64_t dst = 0x0;
   
   printf("DDR Sweep Host to FPGA\n");   
   clock_t start, end;
     
   start = clock();
   res = fpgaDmaTransferSync(dma_h, dst, src, total_mem_size, HOST_TO_FPGA_MM);
   if(res != FPGA_OK) {
      printf(" fpgaDmaTransferSync Host to FPGA failed with error %s", fpgaErrStr(res));
      free(dma_buf_ptr);
      return FPGA_EXCEPTION;
   }
   end = clock();
   double seconds = ((double) (end - start)) / CLOCKS_PER_SEC;
   report_bandwidth(total_mem_size, seconds);

   printf("\rClear buffer\n");
   clear_buffer((char*)dma_buf_ptr, total_mem_size);

   src = 0x0;
   dst = (uint64_t)dma_buf_ptr;
   start = clock();
   printf("DDR Sweep FPGA to Host\n");   
   res = fpgaDmaTransferSync(dma_h, dst, src, total_mem_size, FPGA_TO_HOST_MM);
   if(res != FPGA_OK) {
      printf(" fpgaDmaTransferSync FPGA to Host failed with error %s", fpgaErrStr(res));
      free(dma_buf_ptr);
      return FPGA_EXCEPTION;
   }
   end = clock();
   seconds = ((double) (end - start)) / CLOCKS_PER_SEC;
   report_bandwidth(total_mem_size, seconds);
   
   printf("Verifying buffer..\n");   
   verify_buffer((char*)dma_buf_ptr, total_mem_size);

   free(dma_buf_ptr);
   return FPGA_OK;
}

void get_state(unsigned int state, int ddra_check) {
/* DDRA STATE CHECK */
    unsigned int ddr_state;
    if (ddra_check) {
        ddr_state = state>>13;
        ddr_state = ddr_state & 0xF;
    } else {
        ddr_state = state>>17;
        ddr_state = ddr_state & 0xF;
    }
    if (ddr_state == DDR_INIT) {
        //return DDRA_INIT; 
        printf("INIT\n");
    } 
    if (ddr_state == DDR_SINGLE_RW) {
        //return DDRA_SINGLE_RW;
        printf("DDR_SINGLE_RW\n");
    } 
    if (ddr_state == DDR_BLOCK_RW) {
        //return DDR_BLOCK_RW;
        printf("DDR_BLOCK_RW\n");
    } 
    if (ddr_state == DDR_AVL_STAGE) {
        //return DDRA_TEMPLATE_STAGE;
        printf("DDR_AVL_STAGE\n");
    }
    if (ddr_state == DDR_TEMPLATE_STAGE) {
        //return DDRA_TEMPLATE_STAGE;
        printf("DDR_TEMPLATE_STAGE\n");
    } 
    if (ddr_state == DDR_REREAD_STAGE) {
        //return DDRA_REREAD_STAGE;
        printf("DDR_REREAD_STAGE\n");
    }   
    if (ddr_state == DDR_DONE) {
        //return DDRA_DONE;
        printf("DDR_DONE\n");
    } 
    if (ddr_state == DDR_TEST_COMPLETE) {
        //return DDRA_TEST_COMPLETE;
        printf("DDR_TEST_COMPLETE\n");
    } 
    if (ddr_state == DDR_TIMEOUT) {
        //return DDR_TIMEOUT;
        printf("DDR_TIMEOUT\n");
    } 
}

int main(int argc, char *argv[]) {
   fpga_result res = FPGA_OK;
   fpga_dma_handle dma_h = NULL;
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
      printf("Usage: fpga_dma_test <use_ase = 1 (simulation only), 0 (hardware)>");
      return 1;
   }
   use_ase = atoi(argv[1]);
   if(use_ase) {
      printf("Running test in ASE mode\n");
   } else {
      printf("Running test in HW mode\n");
   }

   // enumerate the afc
   if(uuid_parse(NLB0_AFUID, guid) < 0) {
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

   if(use_ase)
      count = ASE_TEST_BUF_SIZE;
   else
      count = TEST_BUF_SIZE;

   dma_buf_ptr = (uint64_t*)malloc(count);
   if(!dma_buf_ptr) {
      res = FPGA_NO_MEMORY;
      ON_ERR_GOTO(res, out_dma_close, "Error allocating memory");
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


/************* Begin BIST *************/
        /* Perform BIST Check */
	printf("Running BIST Test\n");
        uint64_t data = 0;
        uint64_t fpga_res = 0;
        double count_bist = 0;
        unsigned int bist_mask = ENABLE_DDRA_BIST;
        unsigned int ddra_bist_result = 0;
        unsigned int ddra_state;
        unsigned int ddrb_state;


	res = fpgaWriteMMIO32(afc_h, 0, DDR_BIST_CTRL_ADDR, bist_mask);

        fpga_res = fpgaReadMMIO64(afc_h, 0, DDR_BIST_CTRL_ADDR,&data);
	while((CHECK_BIT(data,27) != 0x08000000)){
	  printf("Enable Test: reading result #%lf: %04x\n", count_bist, (unsigned int)data);
	  if (count_bist >= MAX_COUNT){
		printf("BIST not enabled!\n");
                free(dma_buf_ptr);
                return -1;
          }
	  count_bist++;
	}
	printf("BIST is enabled.  Reading status register\n");

	count_bist = 0;
        while ((CHECK_BIT(data,9) != 0x200) && (CHECK_BIT(data,8) != 0x100) && (CHECK_BIT(data,7) != 0x80) && 
            (CHECK_BIT(data,10) != 0x400) && (CHECK_BIT(data,11) != 0x800) && (CHECK_BIT(data,12) != 0x1000)){
          fpga_res = fpgaReadMMIO64(afc_h, 0, DDR_BIST_STATUS_ADDR,
                 &data); 
	  printf("DDRA: Reading result #%lf: %04x\n", count_bist, (unsigned int)data);
          printf("DDRA State: ");
          get_state((unsigned int)data, TRUE);
          if (count_bist >= MAX_COUNT){
		printf("DDRA BIST Timed Out.\n");
                break;
          }
          count_bist++;
	  usleep(100);
        }
        ddra_state = (unsigned int)data;

        if (CHECK_BIT(data,9) == DDRA_BIST_PASS) {
                ddra_bist_result = DDRA_BIST_PASS;
        } else if (CHECK_BIT(data,8) == DDRA_BIST_FAIL) {
                ddra_bist_result = DDRA_BIST_FAIL;
        } else if (CHECK_BIT(data,7) == DDRA_BIST_TIMEOUT) {
                ddra_bist_result = DDRA_BIST_TIMEOUT;
        } else {
                ddra_bist_result = DDRA_BIST_FATAL_ERROR;
        }

        
        bist_mask = ENABLE_DDRB_BIST;
        count_bist = 0;
	res = fpgaWriteMMIO32(afc_h, 0, DDR_BIST_CTRL_ADDR, bist_mask);
        while ((CHECK_BIT(data,10) != 0x400) && (CHECK_BIT(data,11) != 0x800) && (CHECK_BIT(data,12) != 0x1000)){
          fpga_res = fpgaReadMMIO64(afc_h, 0, DDR_BIST_STATUS_ADDR,
                 &data); 
	  printf("DDRB: Reading result #%lf: %04x\n", count_bist, (unsigned int)data);
	  //printf("reading result #%f: %04x\n", count_bist,data);
          printf("DDRB State: ");
          get_state((unsigned int)data, FALSE);
          if (count_bist >= MAX_COUNT){
		printf("DDR Bank B BIST Timed Out.\n");
                break;
          }
          count_bist++;
	  usleep(100);
        }
        ddrb_state = (unsigned int)data;

        //ddra_bist_result = DDRA_BIST_TIMEOUT;

        if (ddra_bist_result == DDRA_BIST_PASS) {
		printf("DDRA BIST Test Passed.\n");
        } else if (ddra_bist_result == DDRA_BIST_FAIL) {
		printf("DDRA BIST Test failed.\n");
        } else if (ddra_bist_result == DDRA_BIST_TIMEOUT) {
		printf("DDRA BIST Test timed out.\n");
        } else {
		printf("DDRA Test encountered a fatal error and cannot continue.\n");
        }
        printf("Final DDRA state was: ");
        get_state(ddra_state, TRUE);

        if (CHECK_BIT(data,12) == DDRB_BIST_PASS) {
		printf("DDR Bank B BIST Test Passed.\n");
        } else if (CHECK_BIT(data,11) == DDRB_BIST_FAIL) {
		printf("DDR Bank BIST Test failed.\n");
        } else if (CHECK_BIT(data,10) == DDRB_BIST_TIMEOUT) {
		printf("DDR Bank B BIST Test timed out.\n");
        } else {
		printf("DDR Bank B Test encountered a fatal error and cannot continue.\n");
        }
        printf("Final DDRB state was: ");
        get_state(ddrb_state, FALSE);
        if (fpga_res == 0) printf("No result from FPGA\n");
/**************** End BIST *****************/

   if(!use_ase) {
      printf("Running DDR sweep test\n");
      res = ddr_sweep(dma_h);
      ON_ERR_GOTO(res, out_dma_close, "ddr_sweep");
   }

out_dma_close:
   free(dma_buf_ptr);
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
