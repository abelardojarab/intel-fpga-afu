#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <uuid/uuid.h>
#include <fpga/enum.h>
#include <fpga/access.h>
#include <fpga/common.h>

int usleep(unsigned);

#define HELLO_AFU_ID              "850ADCC2-6CEB-4B22-9722-D43375B61C66"
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

int main(int argc, char *argv[])
{
	fpga_properties    filter = NULL;
	fpga_token         afc_token;
	fpga_handle        afc_handle;
	fpga_guid          guid;
	uint32_t           num_matches;

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

	volatile uint64_t *mmio_ptr   = NULL;
	res = fpgaMapMMIO(afc_handle, 0, &mmio_ptr);
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
	
	// Set Scratch Register to 0
	printf("Setting Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, SCRATCH_RESET);
	res = fpgaWriteMMIO64(afc_handle, 0, SCRATCH_REG, SCRATCH_RESET);
	ON_ERR_GOTO(res, out_close, "writing to MMIO");
	res = fpgaReadMMIO64(afc_handle, 0, SCRATCH_REG, &data);
	ON_ERR_GOTO(res, out_close, "reading from MMIO");
	printf("Reading Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, data);
	ASSERT_GOTO(data == SCRATCH_RESET, out_close, "MMIO mismatched expected result");

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