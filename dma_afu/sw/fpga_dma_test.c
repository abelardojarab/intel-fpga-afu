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
#include <opae/fpga.h>
#include "fpga_dma.h"
/**
 * \fpga_dma_test.c
 * \brief User-mode DMA test
 */

#include <stdlib.h>
#include <assert.h>

#define HELLO_AFU_ID              "331DB30C-9885-41EA-9081-F88B8F655CAA"
#define TEST_BUF_SIZE (10*1024*1024)

void fill_buffer(char *buf) {
   uint32_t i=0;
   // use a deterministic seed to generate pseudo-random numbers
   srand(99);

   for(i=0; i<TEST_BUF_SIZE; i++) {
      *buf = rand()%256;
      buf++;
   }
}

fpga_result verify_buffer(char *buf) {
   uint32_t i, rnum=0;
   srand(99);

   for(i=0; i<TEST_BUF_SIZE; i++) {
      rnum = rand()%256;
      if((*buf&0xFF) != rnum) {
         printf("Invalid data at %d Expected = %x Actual = %x\n",i,rnum,(*buf&0xFF));
         return FPGA_INVALID_PARAM;
      }
      buf++;
   }
   printf("Buffer Verification Success!\n");
   return FPGA_OK;
}

void clear_buffer(char *buf) {
   memset(buf, 0, TEST_BUF_SIZE);
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
   uint64_t dma_buf_wsid, dma_buf_iova;
   uint32_t i=0;
   uint32_t use_ase;

   if(argc < 2) {
      printf("Usage: fpga_dma_test <use_ase = 1 (simulation only), 0 (hardware)>");
      return 1;
   }
   use_ase = atoi(argv[1]);

   // enumerate the afc
   if(uuid_parse(HELLO_AFU_ID, guid) < 0) {
      return 1;
   }

   res = fpgaGetProperties(NULL, &filter);
   ON_ERR_GOTO(res, out, "fpgaGetProperties");

   res = fpgaPropertiesSetObjectType(filter, FPGA_AFC);
   ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesSetObjectType");

   res = fpgaPropertiesSetGUID(filter, guid);
   ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesSetGUID");

   res = fpgaEnumerate(&filter, 1, &afc_token, 1, &num_matches);
   ON_ERR_GOTO(res, out_destroy_prop, "fpgaEnumerate");

   if(num_matches < 1) {
      fprintf(stderr, "Error %s: %s\n", "Number of matches < 1",FPGA_INVALID_PARAM);
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
   ON_ERR_GOTO(res, out_unmap, "fpgaDmaOpen");

   dma_buf_ptr = (uint64_t*)malloc(TEST_BUF_SIZE);

   fill_buffer((char*)dma_buf_ptr);

   // Test procedure
   // - Fill host buffer with pseudo-random data
   // - Copy from host buffer to FPGA buffer at address 0x0
   // - Clear host buffer
   // - Copy from FPGA buffer to host buffer
   // - Verify host buffer data
   // - Clear host buffer
   // - Copy FPGA buffer at address 0x0 to FPGA buffer at addr TEST_BUF_SIZE
   // - Copy data from FPGA buffer at addr TEST_BUF_SIZE to host buffer
   // - Verify host buffer data

   // copy from host to fpga
   count = TEST_BUF_SIZE;
   res = fpgaDmaTransferSync(dma_h, 0x0 /*dst*/, (uint64_t)dma_buf_ptr /*src*/, count, HOST_TO_FPGA_MM);
   ON_ERR_GOTO(res, out_dma_close, "fpgaDmaTransferSync HOST_TO_FPGA_MM");
   clear_buffer((char*)dma_buf_ptr);

   // copy from fpga to host
   res = fpgaDmaTransferSync(dma_h, (uint64_t)dma_buf_ptr /*dst*/, 0x0 /*src*/, count, FPGA_TO_HOST_MM);
   ON_ERR_GOTO(res, out_dma_close, "fpgaDmaTransferSync FPGA_TO_HOST_MM");
   res = verify_buffer((char*)dma_buf_ptr);
   ON_ERR_GOTO(res, out_dma_close, "verify_buffer");

   clear_buffer((char*)dma_buf_ptr);

   // copy from fpga to fpga
   res = fpgaDmaTransferSync(dma_h, TEST_BUF_SIZE /*dst*/, 0x0 /*src*/, count, FPGA_TO_FPGA_MM);
   ON_ERR_GOTO(res, out_dma_close, "fpgaDmaTransferSync FPGA_TO_FPGA_MM");

   // copy from fpga to host
   res = fpgaDmaTransferSync(dma_h, (uint64_t)dma_buf_ptr /*dst*/, TEST_BUF_SIZE /*src*/, count, FPGA_TO_HOST_MM);
   ON_ERR_GOTO(res, out_dma_close, "fpgaDmaTransferSync FPGA_TO_HOST_MM");

   res = verify_buffer((char*)dma_buf_ptr);
   ON_ERR_GOTO(res, out_dma_close, "verify_buffer");

out_dma_close:
   free(dma_buf_ptr);
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
   return res;
}
