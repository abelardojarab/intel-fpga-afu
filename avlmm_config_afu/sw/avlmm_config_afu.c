#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <uuid/uuid.h>
//#include <fpga/enum.h>
//#include <fpga/access.h>
//#include <fpga/common.h>
#include <opae/fpga.h>

int usleep(unsigned);

#define AVLMM_CONFIG_AFU_ID      "35F9452B-25C2-434C-93D5-6F8C60DB361C"
#define SCRATCH_REG              0X80
#define AVM_ADDRESS_REG          0x100
#define AVM_BURSTCOUNT_REG       0x108
#define AVM_RDWR_REG             0x110
#define AVM_WRITEDATA_REG        0x118
#define AVM_READDATA_REG         0x120
#define TESTMODE_CONTROL_REG     0x128
#define TESTMODE_STATUS_REG      0x180
#define AVM_RDWR_STATUS_REG      0x188
#define MEM_BANK_SELECT          0x190
#define SCRATCH_VALUE            0x0123456789ABCDEF
#define SCRATCH_RESET            0
#define BYTE_OFFSET              8

#define AFU_DFH_REG              0x0
#define AFU_ID_LO                0x8 
#define AFU_ID_HI                0x10
#define AFU_NEXT                 0x18
#define AFU_RESERVED             0x20


//localparam MEM_ADDRESS    = 16'h0040;                // AVMM Master Address
//localparam MEM_BURSTCOUNT = 16'h0042;                // AVMM Master Burst Count
//localparam MEM_RDWR       = 16'h0044;                // AVMM Master Read/Write
//localparam MEM_WRDATA     = 16'h0046;                // AVMM Master Write Data
//localparam MEM_RDDATA     = 16'h0048;                // AVMM Master Read Data
//localparam MEM_ADDR_TESTMODE   = 16'h004A;                // Test Control Register        
//localparam MEM_ADDR_TEST_STATUS  = 16'h0060;                // Test Status Register
//localparam MEM_RDWR_STATUS       = 16'h0062;



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
   uint32_t           bank;

	fpga_result     res = FPGA_OK;

   
   if(argc < 2) {
      printf("Usage: avlmm_config_afu <bank #>");
      return 1;
   }
   bank = atoi(argv[1]);

	if (uuid_parse(AVLMM_CONFIG_AFU_ID, guid) < 0) {
		fprintf(stderr, "Error parsing guid '%s'\n", AVLMM_CONFIG_AFU_ID);
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

	volatile uint64_t *mmio_ptr   = NULL;
	res = fpgaMapMMIO(afc_handle, 0, &mmio_ptr);
	ON_ERR_GOTO(res, out_close, "mapping MMIO space");

	printf("Running Test\n");

	/* Reset AFC */
	res = fpgaReset(afc_handle);
	ON_ERR_GOTO(res, out_close, "resetting AFC");

   sleep(3);
	// Access mandatory AFU registers
	uint64_t data = 0;
   uint32_t data32 = 0;

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

   // Perform memory test for each bank
   printf("Testing memory bank %d\n",bank);
   res = fpgaWriteMMIO64(afc_handle, 0, MEM_BANK_SELECT, bank);
   ON_ERR_GOTO(res, out_close, "writing to MEM_BANK_SELECT");
   
   /******************** Memory Test Starts Here *****************************/
   // Configuring AVM Interface
   printf("Running Test1 - Busrt 1 Write and Read from DDR");
   
   //Setting up AVMM Master Write
   // # Current MXU supports Address from [14:0]
   res = fpgaWriteMMIO32(afc_handle, 0, AVM_ADDRESS_REG, 0x11);
   ON_ERR_GOTO(res, out_close, "error writing to AVM_ADDRESS_REG");
   
   res = fpgaWriteMMIO64(afc_handle, 0, AVM_WRITEDATA_REG, 0x0123456789ABCDEF);
   ON_ERR_GOTO(res, out_close, "error writing to AVM_WRITEDATA_REG");
   
   res = fpgaWriteMMIO32(afc_handle, 0, AVM_RDWR_REG, 1);
   ON_ERR_GOTO(res, out_close, "error writing to AVM_RDWR_REG");
      
   //Setting up AVMM Master Read
   res = fpgaWriteMMIO32(afc_handle, 0, AVM_RDWR_REG, 3);
   ON_ERR_GOTO(res, out_close, "error writing to AVM_RDWR_REG");
      
   res = fpgaReadMMIO32(afc_handle, 0, AVM_RDWR_STATUS_REG, &data32);
   ON_ERR_GOTO(res, out_close, "error reading from AVM_RDWR_STATUS_REG");
      
   sleep(3);
   while(  0x40 != data32&0x40) {
      res = fpgaReadMMIO32(afc_handle, 0, AVM_RDWR_STATUS_REG, &data32);
      ON_ERR_GOTO(res, out_close, "error reading from AVM_RDWR_STATUS_REG");
      sleep(1);
   }
   
   res = fpgaReadMMIO64(afc_handle, 0, AVM_READDATA_REG, &data);
   ON_ERR_GOTO(res, out_close, "error writing to AVM_READDATA_REG");
   
   if (data != SCRATCH_VALUE) {
      printf("Write Data does NOT Match Read Data exp_data:0x1234567089abcdef, res_data: %lx", data);
   } else {
      printf("Write Data MATCHES READ_DATA %lx", data );
   }
   
   // Testmode Sweep
   printf("Running Test2 - DDR Memory Test Sweep!");   
   fpgaWriteMMIO64(afc_handle, 0, TESTMODE_CONTROL_REG, 1);
   sleep(1);
   do {
      res = fpgaReadMMIO64(afc_handle, 0, TESTMODE_STATUS_REG, &data);
      ON_ERR_GOTO(res, out_close, "error reading from TESTMODE_STATUS_REG");
      sleep(1);
   } while(0x100 != (data&0x100));

   printf("Done DDR Test Sweep");
   
   printf("Running Test3 - Burst of 32 Write and Read from DDR");
   
   // Setup for 32 burst AVL Write 
   fpgaWriteMMIO64(afc_handle, 0, AVM_WRITEDATA_REG, 0xcab0cafe);
   fpgaWriteMMIO64(afc_handle, 0, AVM_BURSTCOUNT_REG, 32);
   fpgaWriteMMIO64(afc_handle, 0, AVM_RDWR_REG, 1);
   // need to sleep for ASE to catcup
   sleep(1);
   
   // Setup for 32 burst AVL READ 
   fpgaWriteMMIO64(afc_handle, 0, AVM_RDWR_REG, 3);
   fpgaReadMMIO64(afc_handle, 0, AVM_RDWR_STATUS_REG, &data);
   // need to sleep for ASE to catchup
   sleep(1);
   printf("READDATA for test register: %lx\n",data);
   
   //SleepMicro(1000);   
   do {
      res = fpgaReadMMIO64(afc_handle, 0, AVM_RDWR_STATUS_REG, &data);
      ON_ERR_GOTO(res, out_close, "error reading from AVM_RDWR_STATUS_REG");
      sleep(1);
   } while(0x40 != (data&0x40));

   if ( 0x40 != (data&0x40) ) {
      printf("Write Data does NOT Match Read Data exp_data:0xcab0cafe, res_data: %lx\n",data);
   } else {
      printf("Write Data MATCHES READ_DATA %lx\n",data);
   }
   sleep(3);
   
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
