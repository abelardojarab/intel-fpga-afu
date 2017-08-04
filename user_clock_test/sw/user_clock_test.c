#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <uuid/uuid.h>
#include <opae/enum.h>
#include <opae/mmio.h>
#include <opae/utils.h>
#include <opae/properties.h>
#include <opae/access.h>

int usleep(unsigned);

#define USER_CLOCK_TEST_AFU_ID  "BD9CCEF3-0B2C-4BB2-901F-6C7486821188"
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

void mmio_read64(fpga_handle afc_handle, uint64_t addr, uint64_t *data, const char *reg_name)
{
	fpgaReadMMIO64(afc_handle, 0, addr, data);
	printf("Reading %s (Byte Offset=%08lx) = %08lx\n", reg_name, addr, *data);
}

void mmio_write64(fpga_handle afc_handle, uint64_t addr, uint64_t data, const char *reg_name)
{
	fpgaWriteMMIO64(afc_handle, 0, addr, data);
	printf("MMIO Write to %s (Byte Offset=%08lx) = %08lx\n", reg_name, addr, data);
}

void read_counters(fpga_handle afc_handle)
{
	uint64_t data = 0;
	mmio_read64(afc_handle, 0x28*4, &data, "counter_400_value");
	mmio_read64(afc_handle, 0x2a*4, &data, "counter_pclk_div2_value");
	mmio_read64(afc_handle, 0x2c*4, &data, "counter_pclk_div4_value");
	mmio_read64(afc_handle, 0x2e*4, &data, "counter_clkusr_value");
	mmio_read64(afc_handle, 0x30*4, &data, "counter_clkusr_div2_value");
}

void read_final_counters(fpga_handle afc_handle)
{
	uint64_t counter_400_value = 0;
	mmio_read64(afc_handle, 0x28*4, &counter_400_value, "counter_400_value");
	uint64_t counter_pclk_div2_value = 0;
	mmio_read64(afc_handle, 0x2a*4, &counter_pclk_div2_value, "counter_pclk_div2_value");
	uint64_t counter_pclk_div4_value = 0;
	mmio_read64(afc_handle, 0x2c*4, &counter_pclk_div4_value, "counter_pclk_div4_value");
	uint64_t counter_clkusr_value = 0;
	mmio_read64(afc_handle, 0x2e*4, &counter_clkusr_value, "counter_clkusr_value");
	uint64_t counter_clkusr_div2_value = 0;
	mmio_read64(afc_handle, 0x30*4, &counter_clkusr_div2_value, "counter_clkusr_div2_value");

	float PCLK_FREQUENCY = 400.0;

	printf("Pclk frequency: %f\n", PCLK_FREQUENCY);
	printf("Pclk div2 frequency: %f\n", PCLK_FREQUENCY*(float)counter_pclk_div2_value/(float)counter_400_value);
	printf("Pclk div4 frequency: %f\n", PCLK_FREQUENCY*(float)counter_pclk_div4_value/(float)counter_400_value);
	printf("user clk frequency: %f\n", PCLK_FREQUENCY*(float)counter_clkusr_value/(float)counter_400_value);
	printf("user clk div2 frequency: %f\n", PCLK_FREQUENCY*(float)counter_clkusr_div2_value/(float)counter_400_value);
}

int main(int argc, char *argv[])
{
	fpga_properties    filter = NULL;
	fpga_token         afc_token;
	fpga_handle        afc_handle;
	fpga_guid          guid;
	uint32_t           num_matches;
	uint64_t *mmio_ptr   = NULL;
	uint64_t data = 0;

	fpga_result     res = FPGA_OK;

	if (uuid_parse(USER_CLOCK_TEST_AFU_ID, guid) < 0) {
		fprintf(stderr, "Error parsing guid '%s'\n", USER_CLOCK_TEST_AFU_ID);
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
	res = fpgaOpen(afc_token, &afc_handle, 0);
	ON_ERR_GOTO(res, out_destroy_tok, "opening AFC");

	res = fpgaMapMMIO(afc_handle, 0, &mmio_ptr);
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
	
	mmio_read64(afc_handle, 0x20*4, &data, "scratch_reg");	//scratch_reg
	mmio_read64(afc_handle, 0x22*4, &data, "reset_counter");	//reset_counter
	mmio_read64(afc_handle, 0x24*4, &data, "enable_counter");	//enable_counter
	mmio_read64(afc_handle, 0x26*4, &data, "counter_max");	//counter_max
	mmio_read64(afc_handle, 0x28*4, &data, "counter_400_value");	//counter_400_value
	
	mmio_write64(afc_handle, 0x26*4, 0x1000, "counter_max");	//counter_max
	mmio_write64(afc_handle, 0x24*4, 1, "enable_counter");	//enable_counter
	mmio_write64(afc_handle, 0x22*4, 0, "reset_counter");	//reset_counter
	
	
	mmio_read64(afc_handle, 0x20*4, &data, "scratch_reg");	//scratch_reg
	mmio_read64(afc_handle, 0x22*4, &data, "reset_counter");	//reset_counter
	mmio_read64(afc_handle, 0x24*4, &data, "enable_counter");	//enable_counter
	mmio_read64(afc_handle, 0x26*4, &data, "counter_max");	//counter_max
	read_counters(afc_handle);
	
	read_counters(afc_handle);
	sleep(1);
	read_counters(afc_handle);
	sleep(1);
	read_counters(afc_handle);
	
	read_final_counters(afc_handle);

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