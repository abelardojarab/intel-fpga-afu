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
// ARE DISCLAIMEdesc.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS BE
// LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

/**
 * \fpga_dma.c
 * \brief FPGA DMA User-mode driver
 */

#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <opae/fpga.h>
#include "fpga_dma_internal.h"
#include "fpga_dma.h"

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

// copy bytes to MMIO
static fpga_result _copy_to_mmio(fpga_handle afc_handle, uint64_t mmio_dst, uint64_t *host_src, int len)
{
   int i=0;
   fpga_result res;
   //mmio requires 8 byte alignment
   if(len % 8 != 0) return FPGA_INVALID_PARAM;
   if(mmio_dst % 8 != 0) return FPGA_INVALID_PARAM;

   uint64_t dev_addr = mmio_dst;
   uint64_t *host_addr = host_src;

   for(i = 0; i < len/8; i++)
   {
      res = fpgaWriteMMIO64(afc_handle, 0, dev_addr, *host_addr);
      if(res != FPGA_OK)
         return res;

      host_addr += 1;
      dev_addr += 8;
   }
   
   return FPGA_OK;
}

static fpga_result _do_dma(fpga_dma_handle dma_h, uint64_t dst, uint64_t src, int count)
{
   msgdma_ext_descriptor_t desc;
   uint64_t data;
   fpga_result res;

   // src, dst and count must be 64-byte aligned
   if(dst%FPGA_DMA_ALIGN_BYTES  !=0 ||
      src%FPGA_DMA_ALIGN_BYTES  !=0 ||
      count%FPGA_DMA_ALIGN_BYTES!=0) {      
      return FPGA_INVALID_PARAM;
   }

   desc.rd_address = src & FPGA_DMA_MASK_32_BIT;
   desc.wr_address = dst & FPGA_DMA_MASK_32_BIT;
   desc.len = count;
   desc.wr_burst_count = 1;
   desc.rd_burst_count = 1;
   desc.seq_num = 0;
   desc.wr_stride = 1;
   desc.rd_stride = 1;
   desc.rd_address_ext = (src >> 32) & FPGA_DMA_MASK_32_BIT;
   desc.wr_address_ext = (dst >> 32) & FPGA_DMA_MASK_32_BIT;
   desc.control = 0x80000000;

   debug_print("desc.rd_address = %lx\n",desc.rd_address);
   debug_print("desc.wr_address = %lx\n",desc.wr_address);
   debug_print("desc.len = %lx\n",desc.len);
   debug_print("desc.wr_burst_count = %lx\n",desc.wr_burst_count);
   debug_print("desc.rd_burst_count = %lx\n",desc.rd_burst_count);
   debug_print("desc.wr_stride %lx\n",desc.wr_stride);
   debug_print("desc.rd_stride %lx\n",desc.rd_stride);
   debug_print("desc.rd_address_ext %lx\n",desc.rd_address_ext);
   debug_print("desc.wr_address_ext %lx\n",desc.wr_address_ext);
   debug_print("desc.control %lx\n",desc.control);

   debug_print("SGDMA_CSR_BASE = %lx SGDMA_DESC_BASE=%lx\n",dma_h->dma_base+FPGA_DMA_CSR, dma_h->dma_base+FPGA_DMA_DESC);

   res = _copy_to_mmio(dma_h->fpga_h, dma_h->dma_base+FPGA_DMA_DESC, (uint64_t *)&desc, sizeof(desc));

   fpgaReadMMIO64(dma_h->fpga_h, dma_h->mmio_num, dma_h->dma_base+FPGA_DMA_CSR, &data);
   // TODO: change to bitmasks
   while(data != FPGA_DMA_DESC_BUFFER_EMPTY) {
      fpgaReadMMIO64(dma_h->fpga_h, dma_h->mmio_num, dma_h->dma_base+FPGA_DMA_CSR, &data);      
   }   
   return FPGA_OK;
}

// Public APIs
fpga_result fpgaDmaOpen(fpga_handle fpga, fpga_dma_handle *dma_p) {
   fpga_result res = FPGA_OK;
   fpga_dma_handle dma_h;

   if(!fpga) {
      return FPGA_INVALID_PARAM;
   }
   if(!dma_p) {
      return FPGA_INVALID_PARAM;
   }

   // init the dma handle
   dma_h = (fpga_dma_handle)malloc(sizeof(struct _dma_handle_t));
   if(!dma_h) {
      return FPGA_NO_MEMORY;
   }
   dma_h->fpga_h = fpga;
   dma_h->dma_buf_ptr = NULL;
   dma_h->mmio_num = 0;
   dma_h->mmio_offset = 0;

   // Discover DMA BBB by traversing the device feature list
   bool end_of_list = false;
   bool dma_found = false;
   uint64_t dfh = 0;
   uint64_t offset = dma_h->mmio_offset;
   do {
      // Read the next feature header
      res = fpgaReadMMIO64(dma_h->fpga_h, dma_h->mmio_num, offset, &dfh);
      ON_ERR_GOTO(res, out, "fpgaReadMMIO64");

      // Read the current feature's UUID
      uint64_t feature_uuid_lo, feature_uuid_hi;
      res = fpgaReadMMIO64(dma_h->fpga_h, dma_h->mmio_num, offset + 8,
                     &feature_uuid_lo);
      ON_ERR_GOTO(res, out, "fpgaReadMMIO64");

      res = fpgaReadMMIO64(dma_h->fpga_h, dma_h->mmio_num, offset + 16,
                     &feature_uuid_hi);
      ON_ERR_GOTO(res, out, "fpgaReadMMIO64");

      if (_fpga_dma_feature_is_bbb(dfh) &&
          (feature_uuid_lo == FPGA_DMA_UUID_L) &&
          (feature_uuid_hi == FPGA_DMA_UUID_H)
         ) {
            // Found one. Record it.
            dma_h->dma_base = offset;
            dma_found = true;
            break;
      }

      // End of the list?
      end_of_list = _fpga_dma_feature_eol(dfh);

      // Move to the next feature header
      offset = offset + _fpga_dma_feature_next(dfh);
   } while(!end_of_list);

   if(dma_found) {
      *dma_p = dma_h;
      res = FPGA_OK;
   } else {
      *dma_p = NULL;
      res = FPGA_NOT_FOUND;
   }

   // Buffer size must be page aligned for prepareBuffer
   res = fpgaPrepareBuffer(dma_h->fpga_h, FPGA_DMA_BUF_SIZE, (void **)&(dma_h->dma_buf_ptr), &dma_h->dma_buf_wsid, 0);
   ON_ERR_GOTO(res, out, "fpgaPrepareBuffer");

   res = fpgaGetIOAddress(dma_h->fpga_h, dma_h->dma_buf_wsid, &dma_h->dma_buf_iova);
   ON_ERR_GOTO(res, rel_buf, "fpgaGetIOAddress");
   
   return res;

rel_buf:
   res = fpgaReleaseBuffer(dma_h->fpga_h, dma_h->dma_buf_wsid);
   ON_ERR_GOTO(res, out, "fpgaReleaseBuffer");

out:
   return res;
}

fpga_result fpgaDmaTransferSync(fpga_dma_handle dma_h, uint64_t dst, uint64_t src, size_t count,
                                fpga_dma_transfer_t type) {

   fpga_result res = FPGA_OK;
   uint32_t i;

   if(!dma_h)
      return FPGA_INVALID_PARAM;

   if(type >= FPGA_MAX_TRANSFER_TYPE)
      return FPGA_INVALID_PARAM;

   if(!(type == HOST_TO_FPGA_MM || type == FPGA_TO_HOST_MM || type == FPGA_TO_FPGA_MM))
      return FPGA_NOT_SUPPORTED;

   if(!dma_h->fpga_h)
      return FPGA_INVALID_PARAM;

   // Buffer size must be page aligned for prepareBuffer

   // Break the transfer into one or more descriptors
   // User buffer data is copied into a DMA-able buffer 
   // allocated within the driver. Further performance 
   // optimizations may be implemented in the future.
   uint32_t dma_chunks = count/FPGA_DMA_BUF_SIZE;      
   count -= (dma_chunks*FPGA_DMA_BUF_SIZE);
   if(type == HOST_TO_FPGA_MM) {
      for(i=0; i<dma_chunks; i++) {
         memcpy(dma_h->dma_buf_ptr, (void*)(src+i*FPGA_DMA_BUF_SIZE), FPGA_DMA_BUF_SIZE);         
         res = _do_dma(dma_h, (dst+i*FPGA_DMA_BUF_SIZE), dma_h->dma_buf_iova | 0x1000000000000, FPGA_DMA_BUF_SIZE);
         ON_ERR_GOTO(res, out, "HOST_TO_FPGA_MM Transfer failed\n");
      }
      if(count > 0) {
         memcpy(dma_h->dma_buf_ptr, (void*)(src+dma_chunks*FPGA_DMA_BUF_SIZE), count);
         res = _do_dma(dma_h, (dst+dma_chunks*FPGA_DMA_BUF_SIZE), dma_h->dma_buf_iova | 0x1000000000000, count);
         ON_ERR_GOTO(res, out, "HOST_TO_FPGA_MM Transfer failed");
      }
   }
   else if(type == FPGA_TO_HOST_MM) {
      for(i=0; i<dma_chunks; i++) {
         res = _do_dma(dma_h, dma_h->dma_buf_iova | 0x1000000000000, (src+i*FPGA_DMA_BUF_SIZE), FPGA_DMA_BUF_SIZE);
         ON_ERR_GOTO(res, out, "FPGA_TO_HOST_MM Transfer failed");

         // hack: extra read to fence host memory writes
         res = _do_dma(dma_h, dma_h->dma_buf_iova | 0x1000000000000, dma_h->dma_buf_iova | 0x1000000000000, 64);
         ON_ERR_GOTO(res, out, "FPGA_TO_HOST_MM Transfer failed");

         memcpy((void*)(dst+i*FPGA_DMA_BUF_SIZE), dma_h->dma_buf_ptr, FPGA_DMA_BUF_SIZE);
      }
      if(count > 0) {
         res = _do_dma(dma_h, dma_h->dma_buf_iova | 0x1000000000000, (src+dma_chunks*FPGA_DMA_BUF_SIZE), count);
         ON_ERR_GOTO(res, out, "FPGA_TO_HOST_MM Transfer failed");

         // hack: extra read to fence host memory writes
         res = _do_dma(dma_h, dma_h->dma_buf_iova | 0x1000000000000, dma_h->dma_buf_iova | 0x1000000000000, 64);
         ON_ERR_GOTO(res, out, "FPGA_TO_HOST_MM Transfer failed");

         memcpy((void*)(dst+dma_chunks*FPGA_DMA_BUF_SIZE), dma_h->dma_buf_ptr, count);
      }
   }
   else if(type == FPGA_TO_FPGA_MM) {
      for(i=0; i<dma_chunks; i++) {
         res = _do_dma(dma_h, (dst+i*FPGA_DMA_BUF_SIZE), (src+i*FPGA_DMA_BUF_SIZE), FPGA_DMA_BUF_SIZE);
         ON_ERR_GOTO(res, out, "FPGA_TO_FPGA_MM Transfer failed");
      }
      if(count > 0) {
         res = _do_dma(dma_h, (dst+dma_chunks*FPGA_DMA_BUF_SIZE), (src+dma_chunks*FPGA_DMA_BUF_SIZE), count);
         ON_ERR_GOTO(res, out, "FPGA_TO_FPGA_MM Transfer failed");
      }
   }
   else {
      return FPGA_NOT_SUPPORTED;
   }

out:
   return res;
}

fpga_result fpgaDmaTransferAsync(fpga_dma_handle dma, uint64_t dst, uint64_t src, size_t count,
                                fpga_dma_transfer_t type, fpga_dma_transfer_cb cb, void *context) {
   // TODO
   return FPGA_NOT_SUPPORTED;
}

fpga_result fpgaDmaClose(fpga_dma_handle dma_h) {
   if(!dma_h) {
      free((void*)dma_h);
   }
   return FPGA_OK;
}

