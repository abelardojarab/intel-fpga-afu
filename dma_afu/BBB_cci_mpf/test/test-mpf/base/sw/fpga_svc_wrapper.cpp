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

#include <uuid/uuid.h>
#include <iostream>
#include <algorithm>

#include "fpga_svc_wrapper.h"

using namespace std;


FPGA_SVC_WRAPPER::FPGA_SVC_WRAPPER(bool use_hw) :
    afc_handle(NULL),
    mpf_handle(NULL),
    use_hw(use_hw),
    is_ok(true)
{
}


FPGA_SVC_WRAPPER::~FPGA_SVC_WRAPPER()
{
}


int FPGA_SVC_WRAPPER::initialize(const char *afuID)
{
    fpga_properties filterp = NULL;
    fpga_token afc_token;
   
    fpga_guid guid;
    uuid_parse(afuID, guid);

    // Look for AFC with requested ID
	fpgaGetProperties(NULL, &filterp);
    fpgaPropertiesSetObjectType(filterp, FPGA_AFC);
    fpgaPropertiesSetGuid(filterp, guid);
    /* TODO: Add selection via BDF / device ID */

    uint32_t num_matches = 1;
    fpgaEnumerate(&filterp, 1, &afc_token,1, &num_matches);

    // Not needed anymore
    fpgaDestroyProperties(&filterp);

    if (num_matches < 1)
    {
        cerr << "AFC " << afuID << " not found!" << endl;
        return 1;
    }

    // Open AFC
    fpga_result r;
    r = fpgaOpen(afc_token, &afc_handle, 0);
    if (FPGA_OK != r) return 1;

    // Map MMIO
    volatile uint64_t *mmio_ptr = NULL;
    fpgaMapMMIO(afc_handle, 0, (uint64_t**)&mmio_ptr);

    // Connect to MPF
    r = mpfConnect(afc_handle, 0, 0, &mpf_handle, 0/*MPF_FLAG_DEBUG*/);
    if (FPGA_OK != r) return 1;
    
    return 0;
}


int FPGA_SVC_WRAPPER::terminate()
{
    mpfDisconnect(mpf_handle);
    fpgaClose(afc_handle);

    return 0;
}
