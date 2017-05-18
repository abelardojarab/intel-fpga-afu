//
// Copyright (c) 2017, Intel Corporation
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// Neither the name of the Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#ifndef __FPGA_SVC_WRAPPER_H__
#define __FPGA_SVC_WRAPPER_H__ 1

extern "C"
{
#include <fpga/fpga.h>
}

#include <fpga/mpf/mpf.h>

typedef class FPGA_SVC_WRAPPER SVC_WRAPPER;

class FPGA_SVC_WRAPPER
{
  public:
    // Pass true in use_hw to use FPGA or false to use ASE.
    FPGA_SVC_WRAPPER(bool use_hw);
    ~FPGA_SVC_WRAPPER();

    int initialize(const char* afuID);    //< Return 0 if success
    int terminate();                      //< Return 0 if success

    bool hwIsSimulated(void) const { return ! use_hw; }

    //
    // Expose MMIO read/write interfaces so the FPGA functions aren't
    // exposed directly to the application.
    //
    fpga_result mmioWrite64(uint32_t idx, uint64_t v)
    {
        return fpgaWriteMMIO64(afc_handle, 0, idx, v);
    }

    uint64_t mmioRead64(uint32_t idx)
    {
        fpga_result r;
        uint64_t v;

        r = fpgaReadMMIO64(afc_handle, 0, idx, &v);
        if (r != FPGA_OK) return -1;

        return v;
    }

    //
    // Expose malloc/free interfaces to avoid exposing VTP directly.
    //
    void* malloc(size_t nBytes)
    {
        fpga_result r;
        void* va;

        r = mpfVtpBufferAllocate(mpf_handle, nBytes, &va);
        if (FPGA_OK != r) return NULL;
        return va;
    }

    void free(void* va)
    {
        mpfVtpBufferFree(mpf_handle, va);
    }

    // Used during testing to force large or small pages
    void forceSmallPageAlloc(bool small)
    {
        mpfVtpSetMaxPhysPageSize(mpf_handle, (small ? MPF_VTP_PAGE_4KB :
                                                      MPF_VTP_PAGE_2MB));
    }

    bool isOK()  {return is_ok;}

    mpf_handle_t mpf_handle;

  protected:
    fpga_handle afc_handle;

    bool use_hw;
    bool is_ok;
};

#endif //  __FPGA_SVC_WRAPPER_H__
