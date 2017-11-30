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

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <uuid/uuid.h>
#include <opae/enum.h>
#include <opae/access.h>
#include <opae/utils.h>
#include <opae/fpga.h>

int usleep(unsigned);

#define AFU_ID                   "D8424DC4-A4A3-C413-F89E-433683F9040B"
#define AFU_DFH_REG              0x0
#define AFU_ID_LO                0x8 
#define AFU_ID_HI                0x10
#define AFU_NEXT                 0x18
#define AFU_RESERVED             0x20
#define CSR_DDR4_WD                  0x0180
#define CSR_DDR4_RD                  0x0188
#define CSR_DDR4_ADDR                0x0190
#define CSR_DDR4_CTRL                0x0198
#define CSR_DDR4_STATUS              0x0200

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

typedef enum {
    DDRA = 0,
    DDRB
} ddr_type;

fpga_result ddr_write
(
  fpga_handle* afc_handle,
  ddr_type ddr,
  uint64_t address,
  uint64_t data,
  uint32_t byte_enable,
  uint32_t burst_count
)
{
  fpga_result res = FPGA_OK;
  uint32_t write_cmd = (byte_enable<<4) | (burst_count<<20);
  if (ddr == DDRA) 
  {
    write_cmd |= 0x1;
  }
  else
  {
    write_cmd |= 0x4;
  }

  printf("MMIO Write to DDR Write Data Register\n");
  res = fpgaWriteMMIO64(*afc_handle, 0, CSR_DDR4_WD, data);
  ON_ERR_GOTO(res, out_exit, "writing to MMIO");
 
  printf("MMIO Write to DDR Address Register\n");
  res = fpgaWriteMMIO32(*afc_handle, 0, CSR_DDR4_ADDR, address);
  ON_ERR_GOTO(res, out_exit, "writing to MMIO");

  
  printf("MMIO Write to DDR Control Register : DDR write\n");
  res = fpgaWriteMMIO32(*afc_handle, 0, CSR_DDR4_CTRL, write_cmd);
  ON_ERR_GOTO(res, out_exit, "writing to MMIO");

  out_exit:
    return res;
}

fpga_result ddr_read
(
  fpga_handle* afc_handle,
  ddr_type ddr,
  uint64_t address,
  uint64_t data,
  uint32_t data_sel,
  uint32_t byte_enable,
  uint32_t burst_count
)
{
  fpga_result res = FPGA_OK;
  uint64_t read_data = 0;
  // Although byte_enable is not used for reading from EMIF, we still set it for consistency purpose
  uint32_t read_cmd = (byte_enable << 4) | (data_sel<<16) | (burst_count<<20);
  
  if (ddr == DDRA)
  {
    read_cmd |= 0x2;
  }
  else
  {
    read_cmd |= 0x8;
  }

  printf("MMIO Write to DDR Address Register\n");
  res = fpgaWriteMMIO64(*afc_handle, 0, CSR_DDR4_ADDR, address);
  ON_ERR_GOTO(res, out_exit, "writing to MMIO");


  usleep(100);

  printf("MMIO Write to DDR Control Register : DDR read\n");
  res = fpgaWriteMMIO32(*afc_handle, 0, CSR_DDR4_CTRL, read_cmd);
  ON_ERR_GOTO(res, out_exit, "writing to MMIO");
       
  printf("MMIO Read from DDR Read Data Register\n");
  while ( !(read_data & 0x4) && !(read_data & 0x1)) {
    usleep(100);
    res = fpgaReadMMIO64(*afc_handle, 0, CSR_DDR4_STATUS, &read_data);
    ON_ERR_GOTO(res, out_exit, "Reading from MMIO");
  }
        
  if (read_data & 0x1)
  {
     res = fpgaReadMMIO64(*afc_handle, 0, CSR_DDR4_RD, &read_data);
     ON_ERR_GOTO(res, out_exit, "Reading from MMIO");

     if (read_data != data) 
     {
        const char* ddr_str = (ddr == DDRA) ? "DDRA" : "DDRB";
        fprintf(stderr, "%s data mismatch at ADDR=%08lx, %08lx != %08lx\n", ddr_str, address, read_data, data);
     }
     else
     {
        printf("Successfully read back %08lx from ADDR=%08lx\n", read_data, address);
     }
  }
  else
  {
    fprintf(stderr, "DDR read timeout reading ADDR=%08lx\n", address);
  }

  out_exit:
     return res;
}

void print_err(const char *s, fpga_result res)
{
	fprintf(stderr, "Error %s: %s\n", s, fpgaErrStr(res));
}

int main(int argc, char *argv[])
{
	fpga_properties    filter = NULL;
	fpga_token         afc_token;
	fpga_handle        afc_handle;
	fpga_guid          guid;
	uint32_t           num_matches;

	fpga_result     res = FPGA_OK;

	if (uuid_parse(AFU_ID, guid) < 0) {
		fprintf(stderr, "Error parsing guid '%s'\n", AFU_ID);
		goto out_exit;
	}

	/* Look for AFC with MY_AFC_ID */
	res = fpgaGetProperties(NULL, &filter);
	ON_ERR_GOTO(res, out_exit, "creating properties object");

	res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
	ON_ERR_GOTO(res, out_destroy_prop, "setting object type");

	res = fpgaPropertiesSetGUID(filter, guid);
	ON_ERR_GOTO(res, out_destroy_prop, "setting GUID");

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
	uint64_t data = 0;
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
        
        // Start DDR write/read test
        uint64_t read_data;
      
        printf("Start DDR testing\n"); 
        
        printf("\n********************************************\n"); 
        printf("  Testing single write followed by single  read\n"); 
        printf("********************************************\n"); 
        // DDRA 1 write & 1 read, same address
        res = ddr_write(&afc_handle, DDRA, 0x0, 0xccccddddaaaabbbb, 0xff, 0x1);
        res = ddr_read(&afc_handle, DDRA, 0x0, 0xccccddddaaaabbbb, 0x0, 0xff, 0x1);  
        // DDRB 1 write & 1 read, same address
        res = ddr_write(&afc_handle, DDRB, 0x1, 0xccccddddaaaabbbb, 0xff, 0x1);
        res = ddr_read(&afc_handle, DDRB, 0x1, 0xccccddddaaaabbbb, 0x0, 0xff, 0x1);  

        printf("\n********************************************\n"); 
        printf("  Testing 2 writes followed by 2 reads\n"); 
        printf("********************************************\n"); 
        // DDRA 2 writes on different addresses
        res = ddr_write(&afc_handle, DDRA, 0x50, 0xabba2016abba2017, 0xff, 0x1);
        res = ddr_write(&afc_handle, DDRA, 0x6f, 0xcafe8888face0000, 0xff, 0x1);
        
        // DDRB 2 writes on different addresses
        res = ddr_write(&afc_handle, DDRB, 0x6f, 0xabba2016abba2017, 0xff, 0x1);
        res = ddr_write(&afc_handle, DDRB, 0x50, 0xcafe8888face0000, 0xff, 0x1);
        
        // DDRA 2 reads from previously written addresses
        res = ddr_read(&afc_handle, DDRA, 0x50, 0xabba2016abba2017, 0x0, 0xff, 0x1);  
        res = ddr_read(&afc_handle, DDRA, 0x6f, 0xcafe8888face0000, 0x0, 0xff, 0x1);  

        // DDRB 2 reads from previously written addresses
        res = ddr_read(&afc_handle, DDRB, 0x50, 0xcafe8888face0000, 0x0, 0xff, 0x1);  
        res = ddr_read(&afc_handle, DDRB, 0x6f, 0xabba2016abba2017, 0x0, 0xff, 0x1);  

        printf("\n********************************************\n"); 
        printf("  Testing byte-enable\n"); 
        printf("********************************************\n"); 
        // DDRA first write with byteenable=0xcc and second write with byteenable=0x33 to the same address
        //      read the same address
        res = ddr_write(&afc_handle, DDRA, 0x50, 0xbabe1980babe1982, 0xcc, 0x1);
        res = ddr_write(&afc_handle, DDRA, 0x50, 0xabba2016abba2017, 0x33, 0x1);
        res = ddr_read(&afc_handle, DDRA, 0x50, 0xbabe2016babe2017, 0x0, 0xff, 0x1);
	
	printf("\nDone Running Test\n");

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
