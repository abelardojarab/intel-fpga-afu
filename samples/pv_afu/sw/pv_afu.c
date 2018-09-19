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
#include <opae/mmio.h>
#include <opae/properties.h>
#include <opae/utils.h>

int usleep(unsigned);

#define PV_AFU_ID                "16D63FA7-657A-446E-81C0-31E40B08CAE6" 
#define SCRATCH_REG              0X80
#define GW_SEL_REG               0X88
#define GW_ENA_REG               0X90
#define GW_SCLR_REG              0X98
#define GW_SCLR_ERR_REG          0XA0
#define GW_ENA_VALUE             0x1
#define GW_DIS_VALUE             0x0
#define GW_SEL_VALUE		 afu_value
#define GW_SCLR_VALUE		 0x01
#define GW_UCLR_VALUE		 0x00
#define GLITCH_WITCH_OUTPUT      0xC0
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

long afu_value = 0x0;
long sleep_value = 0;
int main(int argc, char *argv[])
{      
        if(argc > 1) {
		afu_value = atoi(argv[1]);
	} else {
		afu_value = 1;
	}
	if(argc > 2) {
		sleep_value = atoi(argv[2]);
	} else {
		sleep_value = 0;
	}

	fpga_properties    filter = NULL;
	fpga_token         afc_token;
	fpga_handle        afc_handle;
	fpga_guid          guid;
	uint32_t           num_matches;

	fpga_result     res = FPGA_OK;


	if (uuid_parse(PV_AFU_ID, guid) < 0) {
		fprintf(stderr, "Error parsing guid '%s'\n", PV_AFU_ID);
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
	res = fpgaOpen(afc_token, &afc_handle, FPGA_OPEN_SHARED);
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

	printf("GW_SEL_VALUE = %d\n",afu_value);

	for(int i=0;i<GW_SEL_VALUE;i++) {
		printf("\nEnabling GW %d\n", i);
        	printf("MMIO Write to GW Select Register (Byte Offset=%08x) = %08lx\n", GW_SEL_REG, i);
        	res = fpgaWriteMMIO64(afc_handle, 0,GW_SEL_REG, i);
        	ON_ERR_GOTO(res, out_close, "writing to MMIO");
/*                // Clear
		printf("MMIO Write to GW SCLR Register (Byte Offset=%08x) = %08lx\n", GW_SCLR_ERR_REG, GW_SCLR_VALUE);
		res = fpgaWriteMMIO64(afc_handle, 0,GW_SCLR_ERR_REG, GW_SCLR_VALUE);
		ON_ERR_GOTO(res, out_close, "writing to MMIO");
		// Remove Clear
		printf("MMIO Write to GW SCLR Register (Byte Offset=%08x) = %08lx\n", GW_SCLR_ERR_REG, GW_UCLR_VALUE);
		 res = fpgaWriteMMIO64(afc_handle, 0,GW_SCLR_ERR_REG, GW_UCLR_VALUE);
		ON_ERR_GOTO(res, out_close, "writing to MMIO");

*/
		// Enable
		printf("MMIO Write to GW Enable  Register (Byte Offset=%08x) = %08lx\n", GW_ENA_REG, GW_ENA_VALUE);
        	res = fpgaWriteMMIO64(afc_handle, 0,GW_ENA_REG, GW_ENA_VALUE);
        	ON_ERR_GOTO(res, out_close, "writing to MMIO");
               

		printf("\nRead status of all GW's\n");
 		for(int j=0; j<=i; j++) {
			printf("\nReading status of GW%d\n", j);
        		printf("MMIO Write to GW Select Register (Byte Offset=%08x) = %08lx\n", GW_SEL_REG, j);
        		res = fpgaWriteMMIO64(afc_handle, 0,GW_SEL_REG, j);
        		ON_ERR_GOTO(res, out_close, "writing to MMIO");

			//GlitchWitch Output Register
			res = fpgaReadMMIO64(afc_handle, 0, GLITCH_WITCH_OUTPUT, &data);
	        	ON_ERR_GOTO(res, out_close, "reading from MMIO");
        		printf("Reading GW Output Register (Byte Offset=%08lx) = %08lx\n", GLITCH_WITCH_OUTPUT, data);

		        //Clear
			printf("MMIO Write to GW SCLR Register (Byte Offset=%08x) = %08lx\n", GW_SCLR_ERR_REG, GW_SCLR_VALUE);
			res = fpgaWriteMMIO64(afc_handle, 0,GW_SCLR_ERR_REG, GW_SCLR_VALUE);
			ON_ERR_GOTO(res, out_close, "writing to MMIO");

			//Remove Clear
			printf("MMIO Write to GW SCLR Register (Byte Offset=%08x) = %08lx\n", GW_SCLR_ERR_REG, GW_UCLR_VALUE);
			res = fpgaWriteMMIO64(afc_handle, 0,GW_SCLR_ERR_REG, GW_UCLR_VALUE);
			ON_ERR_GOTO(res, out_close, "writing to MMIO");

                        //GlitchWitch Output Register
			res = fpgaReadMMIO64(afc_handle, 0, GLITCH_WITCH_OUTPUT, &data);
	        	ON_ERR_GOTO(res, out_close, "reading from MMIO");
        		printf("Reading GW Output Register (Byte Offset=%08lx) = %08lx\n", GLITCH_WITCH_OUTPUT, data);

 


		}

	}

	printf("\n\nGoing to wait for a while ... like %l us\n", sleep_value);
	usleep(sleep_value);
	printf("\nRead status of all GW's\n");
	for(int i=0; i<GW_SEL_VALUE; i++) {
		printf("\nReading status of GW%d\n", i);
		printf("MMIO Write to GW Select Register (Byte Offset=%08x) = %08lx\n", GW_SEL_REG, i);
		res = fpgaWriteMMIO64(afc_handle, 0,GW_SEL_REG, i);
		ON_ERR_GOTO(res, out_close, "writing to MMIO");

		//GlitchWitch Output Register
		res = fpgaReadMMIO64(afc_handle, 0, GLITCH_WITCH_OUTPUT, &data);
        	ON_ERR_GOTO(res, out_close, "reading from MMIO");
		printf("Reading GW Output Register (Byte Offset=%08lx) = %08lx\n", GLITCH_WITCH_OUTPUT, data);
	}

	printf("\n\nCleaning up - Disabling all GW's\n");
	for(int i=0;i<GW_SEL_VALUE;i++) {
		printf("\nCleaning up GW %d\n",i);
        	printf("MMIO Write to GW Select Register (Byte Offset=%08x) = %08lx\n", GW_SEL_REG, i);
        	res = fpgaWriteMMIO64(afc_handle, 0,GW_SEL_REG, i);
        	ON_ERR_GOTO(res, out_close, "writing to MMIO");

		printf("MMIO Write to GW Enable  Register (Byte Offset=%08x) = %08lx\n", GW_ENA_REG, GW_DIS_VALUE);
        	res = fpgaWriteMMIO64(afc_handle, 0,GW_ENA_REG, GW_DIS_VALUE);
        	ON_ERR_GOTO(res, out_close, "writing to MMIO");

         	//Clear
		printf("MMIO Write to GW SCLR Register (Byte Offset=%08x) = %08lx\n", GW_SCLR_ERR_REG, GW_SCLR_VALUE);
		res = fpgaWriteMMIO64(afc_handle, 0,GW_SCLR_ERR_REG, GW_SCLR_VALUE);
		ON_ERR_GOTO(res, out_close, "writing to MMIO");

		//Remove Clear
		printf("MMIO Write to GW SCLR Register (Byte Offset=%08x) = %08lx\n", GW_SCLR_ERR_REG, GW_UCLR_VALUE);
		res = fpgaWriteMMIO64(afc_handle, 0,GW_SCLR_ERR_REG, GW_UCLR_VALUE);
		ON_ERR_GOTO(res, out_close, "writing to MMIO");

	
		//GlitchWitch Output Register
		res = fpgaReadMMIO64(afc_handle, 0, GLITCH_WITCH_OUTPUT, &data);
        	ON_ERR_GOTO(res, out_close, "reading from MMIO");
		printf("Reading GW Output Register (Byte Offset=%08lx) = %08lx\n", GLITCH_WITCH_OUTPUT, data);

 	



//		printf("MMIO Write to GW SCLR Register (Byte Offset=%08x) = %08lx\n", GW_SCLR_REG, GW_SCLR_VALUE);
//		res = fpgaWriteMMIO64(afc_handle, 0,GW_SCLR_REG, GW_SCLR_VALUE);
//		ON_ERR_GOTO(res, out_close, "writing to MMIO");
	}
       
//	// Select Register
//        res = fpgaReadMMIO64(afc_handle, 0, GW_SEL_REG, &data);
//        ON_ERR_GOTO(res, out_close, "reading from MMIO");
//        printf("Reading GW Select Register (Byte Offset=%08lx) = %08lx\n", GW_SEL_REG, data); 
//
//        printf("MMIO Write to GW Select Register (Byte Offset=%08x) = %08lx\n", GW_SEL_REG, GW_SEL_VALUE);
//        res = fpgaWriteMMIO64(afc_handle, 0,GW_SEL_REG, GW_SEL_VALUE);
//        ON_ERR_GOTO(res, out_close, "writing to MMIO");
// 
//      /*  res = fpgaReadMMIO64(afc_handle, 0, GW_SEL_REG, &data);
//        ON_ERR_GOTO(res, out_close, "reading from MMIO");
//        printf("Reading GW Select Register (Byte Offset=%08x) = %08lx\n", GW_SEL_REG, data);
//        ASSERT_GOTO(data ==  GW_SEL_VALUE, out_close, "MMIO mismatched expected result");
//*/
//
//       // Enable Register
//	res = fpgaReadMMIO64(afc_handle, 0, GW_ENA_REG, &data);
//        ON_ERR_GOTO(res, out_close, "reading from MMIO");
//        printf("Reading GW Enable Register (Byte Offset=%08lx) = %08lx\n", GW_ENA_REG, data);
// 
//	printf("MMIO Write to GW Enable  Register (Byte Offset=%08x) = %08lx\n", GW_ENA_REG, GW_ENA_VALUE);
//        res = fpgaWriteMMIO64(afc_handle, 0,GW_ENA_REG, GW_ENA_VALUE);
//        ON_ERR_GOTO(res, out_close, "writing to MMIO");
//         
///*        res = fpgaReadMMIO64(afc_handle, 0, GW_ENA_REG, &data);
//        ON_ERR_GOTO(res, out_close, "reading from MMIO");
//        printf("Reading GW Enable Register (Byte Offset=%08x) = %08lx\n", GW_ENA_REG, data);
//        ASSERT_GOTO(data ==  GW_ENA_VALUE, out_close, "MMIO mismatched expected result");
// */     
//        //SCLR register
//	res = fpgaReadMMIO64(afc_handle, 0, GW_SCLR_REG, &data);
//        ON_ERR_GOTO(res, out_close, "reading from MMIO");
//        printf("Reading GW SCLR Register (Byte Offset=%08lx) = %08lx\n", GW_SCLR_REG, data);
// 	
//	//GlitchWitch Output Register
//	res = fpgaReadMMIO64(afc_handle, 0, GLITCH_WITCH_OUTPUT, &data);
//        ON_ERR_GOTO(res, out_close, "reading from MMIO");
//        printf("Reading GW Output Register (Byte Offset=%08lx) = %08lx\n", GLITCH_WITCH_OUTPUT, data);
//
///*	printf("MMIO Write to GW SCLR Register (Byte Offset=%08x) = %08lx\n", GW_SCLR_REG, GW_SCLR_VALUE);
//        res = fpgaWriteMMIO64(afc_handle, 0,GW_SCLR_REG, GW_SCLR_VALUE);
//        ON_ERR_GOTO(res, out_close, "writing to MMIO");
//         
//        res = fpgaReadMMIO64(afc_handle, 0, GW_SCLR_REG, &data);
//        ON_ERR_GOTO(res, out_close, "reading from MMIO");
//        printf("Reading GW SCLR Register (Byte Offset=%08x) = %08lx\n", GW_SCLR_REG, data);
//        ASSERT_GOTO(data ==  GW_SCLR_VALUE, out_close, "MMIO mismatched expected result");
//*/
//        //SCLR_ERR register
//        res = fpgaReadMMIO64(afc_handle, 0, GW_SCLR_ERR_REG, &data);
//        ON_ERR_GOTO(res, out_close, "reading from MMIO");
//        printf("Reading GW SCLR_ERR Register (Byte Offset=%08lx) = %08lx\n", GW_SCLR_ERR_REG, data);

/*	printf("MMIO Write to GW SCLR_ERR  Register (Byte Offset=%08x) = %08lx\n", GW_SCLR_ERR_REG, GW_SCLR_ERR_VALUE);
	res = fpgaWriteMMIO64(afc_handle, 0,GW_SCLR_ERR_REG, GW_SCLR_ERR_VALUE);
	ON_ERR_GOTO(res, out_close, "writing to MMIO");
	
	res = fpgaReadMMIO64(afc_handle, 0, GW_SCLR_ERR_REG, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("Reading GW SCLR_ERR Register (Byte Offset=%08x) = %08lx\n", GW_SCLR_ERR_REG, data);
	ASSERT_GOTO(data ==  GW_SCLR_ERR_VALUE, out_close, "MMIO mismatched expected result");
*/
	// Set Scratch Register to 0
	printf("Setting Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, SCRATCH_RESET);
	res = fpgaWriteMMIO64(afc_handle, 0, SCRATCH_REG, SCRATCH_RESET);
	ON_ERR_GOTO(res, out_close, "writing to MMIO");
	res = fpgaReadMMIO64(afc_handle, 0, SCRATCH_REG, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("Reading Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, data);
	ASSERT_GOTO(data == SCRATCH_RESET, out_close, "MMIO mismatched expected result");

/*	// Set Glitch Witch Register to 0
	printf("Setting Glitch Witch Register (Byte Offset=%08x) = %08lx\n", GLITCH_WITCH_CTRL_REG, GLITCH_WITCH_RESET);
	res = fpgaWriteMMIO64(afc_handle, 0, GLITCH_WITCH_CTRL_REG, GLITCH_WITCH_RESET);
	ON_ERR_GOTO(res, out_close, "writing to MMIO");
	res = fpgaReadMMIO64(afc_handle, 0, GLITCH_WITCH_CTRL_REG, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("Reading Glitch Witch Register (Byte Offset=%08x) = %08lx\n", GLITCH_WITCH_CTRL_REG, data);
	ASSERT_GOTO(data == GLITCH_WITCH_RESET, out_close, "MMIO mismatched expected result");
*/



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


