#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>

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
#define READY_FOR_SW_CMD         0X198

#define SCRATCH_VALUE            ((uint64_t)0xdeadbeef)
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

uint64_t expected_value(uint64_t burst_count, uint64_t write_data)
{
    // The burst count overwrites the high 10 bits of write data
    return (burst_count << (uint64_t)53) | (write_data & 0x3fffffffffffff);
}

int main(int argc, char *argv[])
{
   fpga_properties    filter = NULL;
   fpga_token         afc_token;
   fpga_handle        afc_handle;
   fpga_guid          guid;
   uint32_t           num_matches;
   uint32_t           bank, use_ase;
   struct timespec    sleep_time;
   // Access mandatory AFU registers
   uint64_t data = 0;
   fpga_result     res = FPGA_OK;
   int                pass;
   
   if(argc < 3) {
      printf("Usage: hello_mem_afu <bank #> <use_ase = 1 (simulation only), use_ase=0 (hardware)>");
      return 1;
   }
   bank = atoi(argv[1]);
   use_ase = atoi(argv[2]);

   if (use_ase) {
      sleep_time.tv_sec = 1;
      sleep_time.tv_nsec = 0;
   }
   else {
      sleep_time.tv_sec = 0;
      sleep_time.tv_nsec = 1000000;
   }

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
   if(!use_ase) {
      res = fpgaMapMMIO(afc_handle, 0, (uint64_t**)&mmio_ptr);
      ON_ERR_GOTO(res, out_close, "mapping MMIO space");
   }

   printf("Running Test\n");

   /* Reset AFC */
   res = fpgaReset(afc_handle);
   ON_ERR_GOTO(res, out_close, "resetting AFC");

   do {
      res = fpgaReadMMIO64(afc_handle, 0, READY_FOR_SW_CMD, &data);
      ON_ERR_GOTO(res, out_close, "reading from MMIO");
   }while(data!=0x1);


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
   printf("Reading Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, data);
   
   printf("MMIO Write to Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, SCRATCH_VALUE);
   res = fpgaWriteMMIO64(afc_handle, 0, SCRATCH_REG, SCRATCH_VALUE);
   ON_ERR_GOTO(res, out_close, "writing to MMIO");
   
   res = fpgaReadMMIO64(afc_handle, 0, SCRATCH_REG, &data);
   ON_ERR_GOTO(res, out_close, "reading from MMIO");
   printf("Reading Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, data);
   ASSERT_GOTO((data == SCRATCH_VALUE), out_close, "MMIO mismatched expected result");
   
   // Set Scratch Register to 0
   printf("Setting Scratch Register (Byte Offset=%08x) = %08x\n", SCRATCH_REG, SCRATCH_RESET);
   res = fpgaWriteMMIO64(afc_handle, 0, SCRATCH_REG, SCRATCH_RESET);
   ON_ERR_GOTO(res, out_close, "writing to MMIO");
   res = fpgaReadMMIO64(afc_handle, 0, SCRATCH_REG, &data);
   ON_ERR_GOTO(res, out_close, "reading from MMIO");
   printf("Reading Scratch Register (Byte Offset=%08x) = %08lx\n", SCRATCH_REG, data);
   ASSERT_GOTO((data == SCRATCH_RESET), out_close, "MMIO mismatched expected result");

   // Perform memory test for each bank
   printf("Testing memory bank %d\n",bank);
   res = fpgaWriteMMIO64(afc_handle, 0, MEM_BANK_SELECT, bank);
   ON_ERR_GOTO(res, out_close, "writing to MEM_BANK_SELECT");   
   
   /******************** Memory Test Starts Here *****************************/

   do {
      res = fpgaReadMMIO64(afc_handle, 0, READY_FOR_SW_CMD, &data);
      ON_ERR_GOTO(res, out_close, "reading from MMIO");
      nanosleep(&sleep_time, NULL);
   }while(data!=0x1);

   // Testmode Sweep
   printf("Setting memory test sweep mode\n");   
   fpgaWriteMMIO64(afc_handle, 0, AVM_WRITEDATA_REG, SCRATCH_VALUE);
   fpgaWriteMMIO64(afc_handle, 0, TESTMODE_CONTROL_REG, 1);

   do {
      res = fpgaReadMMIO64(afc_handle, 0, READY_FOR_SW_CMD, &data);
      ON_ERR_GOTO(res, out_close, "reading from MMIO");
      nanosleep(&sleep_time, NULL);
   }while(data!=0x1);

   //Setting up AVMM Master Write
   // # Current MXU supports Address from [14:0]
   res = fpgaWriteMMIO32(afc_handle, 0, AVM_ADDRESS_REG, 0x11);
   ON_ERR_GOTO(res, out_close, "error writing to AVM_ADDRESS_REG");
   
   for (pass = 1; pass <= 2; pass += 1) {
       uint64_t burst_cnt = ((pass == 1) ? 1 : 32);
       uint64_t write_data = 0xcab0cafd + pass;

       printf("Running Test%d - Burst of %ld Write and Read from DDR\n", pass, burst_cnt);
      
      // Setup for burst AVL Write 
      fpgaWriteMMIO64(afc_handle, 0, AVM_WRITEDATA_REG, write_data);
      fpgaWriteMMIO64(afc_handle, 0, AVM_BURSTCOUNT_REG, burst_cnt);
      fpgaWriteMMIO64(afc_handle, 0, AVM_RDWR_REG, 1);
      // need to sleep for ASE to catcup

      do {
         res = fpgaReadMMIO64(afc_handle, 0, READY_FOR_SW_CMD, &data);
         ON_ERR_GOTO(res, out_close, "reading from MMIO");
         nanosleep(&sleep_time, NULL);
      }while(data!=0x1);

      do {
         res = fpgaReadMMIO64(afc_handle, 0, AVM_RDWR_STATUS_REG, &data);
         ON_ERR_GOTO(res, out_close, "error reading from AVM_RDWR_STATUS_REG");
         nanosleep(&sleep_time, NULL);
      } while(0x4 != (data & 0x4));

      // Setup for 32 burst AVL READ 
      fpgaWriteMMIO64(afc_handle, 0, AVM_RDWR_REG, 3);
      
      do {
         res = fpgaReadMMIO64(afc_handle, 0, READY_FOR_SW_CMD, &data);
         ON_ERR_GOTO(res, out_close, "reading from MMIO");
         nanosleep(&sleep_time, NULL);
      }while(data!=0x1);

      printf("READDATA for test register: %lx\n",data);
      
      do {
         res = fpgaReadMMIO64(afc_handle, 0, AVM_RDWR_STATUS_REG, &data);
         ON_ERR_GOTO(res, out_close, "error reading from AVM_RDWR_STATUS_REG");
         nanosleep(&sleep_time, NULL);
      } while(0x40 != (data&0x40));

      res = fpgaReadMMIO64(afc_handle, 0, AVM_READDATA_REG, &data);
      ON_ERR_GOTO(res, out_close, "error writing to AVM_READDATA_REG");
      
      if (data != expected_value(burst_cnt, write_data)) {
         printf("Write Data does NOT Match Read Data exp_data:%lx, res_data: %lx\n",
                expected_value(burst_cnt, write_data), data);
      } else {
         printf("Write Data MATCHES READ_DATA %lx\n",data);
      }

      printf("Done Running Test\n");
   }

   /* Unmap MMIO space */
   if(!use_ase) {
      res = fpgaUnmapMMIO(afc_handle, 0);
      ON_ERR_GOTO(res, out_close, "unmapping MMIO space");
   }
   
   /* Release accelerator */
out_close:
   res = fpgaClose(afc_handle);
   ON_ERR_GOTO(res, out_destroy_tok, "closing AFC");

   /* Destroy token */
out_destroy_tok:
   if(!use_ase) {
      res = fpgaDestroyToken(&afc_token);
      ON_ERR_GOTO(res, out_destroy_prop, "destroying token");
   }

   /* Destroy properties object */
out_destroy_prop:
   res = fpgaDestroyProperties(&filter);
   ON_ERR_GOTO(res, out_exit, "destroying properties object");

out_exit:
   if(s_error_count > 0)
      printf("Test FAILED!\n");

   return s_error_count;

}
