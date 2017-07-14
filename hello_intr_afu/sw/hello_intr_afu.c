#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <uuid/uuid.h>
#include <opae/enum.h>
#include <opae/access.h>
#include <opae/utils.h>
#include <poll.h>
#include <errno.h>

#define HELLO_AFU_ID              "850ADCC2-6CEB-4B22-9722-D43375B61C66"
#define INTR_REG                 0XA0 //0x28

static int s_error_count = 0;

/*
 * macro to check return codes, print error message, and goto cleanup label
 * NOTE: this changes the program flow (uses goto)!
 */
#define ON_ERR_GOTO(res, label, desc) \
   do { \
      if ((res) != FPGA_OK) { \
         print_err((desc), (res));  \
         s_error_count += 1; \
         goto label; \
      } \
   } while (0)

/*
 * macro to check return codes, print error message, and goto cleanup label
 * NOTE: this changes the program flow (uses goto)!
 */
#define ASSERT_GOTO(condition, label, desc) \
   do { \
      if (condition == 0) { \
         fprintf(stderr, "Error %s\n", desc); \
         s_error_count += 1; \
         goto label; \
      } \
   } while (0)
      
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
   ON_ERR_GOTO(res, out_unmap, "resetting AFC");
      
   struct pollfd pfd;
   
   /* Create event */
   fpga_event_handle ehandle;
   res = fpgaCreateEventHandle(&ehandle);
   ON_ERR_GOTO(res, out_unmap, "error creating event handle`");

   /* Register user interrupt with event handle */
   res = fpgaRegisterEvent(afc_handle, FPGA_EVENT_INTERRUPT, ehandle, 0);
   ON_ERR_GOTO(res, out_unmap, "error registering event");

   /* Trigger interrupt by writing to INTR_REG */
   printf("Setting Interrupt register (Byte Offset=%08x) = %08lx\n", INTR_REG, 1);
   res = fpgaWriteMMIO64(afc_handle, 0, INTR_REG, 1);
   ON_ERR_GOTO(res, out_unmap, "writing to INTR_REG MMIO");
   
   /* Poll event handle*/
   pfd.fd = (int)ehandle;
   pfd.events = POLLIN;
   res = poll(&pfd, 1, -1);
   if(res < 0) {
      fprintf( stderr, "Poll error errno = %s\n",strerror(errno));
      s_error_count += 1;
   } 
   else if(res == 0) {
      fprintf( stderr, "Poll timeout \n");
      s_error_count += 1;
   } else {
      printf("Poll success. Return = %d\n",res);
   }
   
   /* cleanup */
   res = fpgaUnregisterEvent(afc_handle, FPGA_EVENT_INTERRUPT);   
   ON_ERR_GOTO(res, out_unmap, "error fpgaUnregisterEvent");   

   res = fpgaDestroyEventHandle(&ehandle);
   ON_ERR_GOTO(res, out_unmap, "error fpgaDestroyEventHandle");

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