// Copyright(c) 2018, Intel Corporation
//
// Redistribution  and	use  in source	and  binary  forms,  with  or  without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of  source code  must retain the  above copyright notice,
//	 this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//	 this list of conditions and the following disclaimer in the documentation
//	 and/or other materials provided with the distribution.
// * Neither the name  of Intel Corporation  nor the names of its contributors
//	 may be used to  endorse or promote  products derived  from this  software
//	 without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO,  THE
// IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.	IN NO EVENT  SHALL THE COPYRIGHT OWNER	OR CONTRIBUTORS BE
// LIABLE  FOR	ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,	EXEMPLARY,	OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,	BUT  NOT LIMITED  TO,  PROCUREMENT	OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,	DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,	WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,	EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
/**
 * \fpga_dma_st_test.c
 * \brief Streaming DMA test
 */

#include <getopt.h>
#include <unistd.h>
#include "fpga_dma_st_test_utils.h"
#include "fpga_dma_st_internal.h"

static int err_cnt = 0;

#define ON_ERR_GOTO(res, label, desc)\
	do {\
		if ((res) != FPGA_OK) {\
			err_cnt++;\
			fprintf(stderr, "Error %s: %s\n", (desc), fpgaErrStr(res));\
			goto label;\
		}\
	} while (0)

static void printUsage()
{
	printf(
"Usage:\n"
"     fpga_dma_st_test [-h] [-B <bus>] [-D <device>] [-F <function>] [-S <segment>]\n"
"                       -l <loopback on/off> -s <data size (bytes)> -p <payload size (bytes)>\n"
"                       -r <transfer direction> -t <transfer type> [-f <decimation factor>]\n\n"
"         -h,--help           Print this help\n"
"         -B,--bus            Set target bus number\n"
"         -D,--device         Set target device number\n"
"         -F,--function       Set target function number\n"
"         -S,--segment        Set PCIe segment\n"
"         -l,--loopback       Loopback mode\n"
"            on               Turn on channel loopback\n" 
"            off              Turn off channel loopback (must specify channel using -r/--direction)\n"
"         -s,--data_size      Total data size\n"
"         -p,--payload_size   Payload size (per DMA transaction)\n"
"         -r,--direction      Transfer direction\n"
"            mtos             Memory to stream\n"
"            stom             Stream to memory\n"
"         -t,--type           Transfer type\n"
"            fixed            Deterministic length transfer\n"
"            packet           Packet transfer (uses SOP and EOP markers)\n"
"         -f,--decim_factor   Optional decimation factor\n"
);

	exit(1);
}

static void parse_args(struct config *config, int argc, char *argv[])
{
	int c;
	if(argc <= 1) {
		printUsage();
		return;
	}
	do {
		static const struct option options[] = {
			{"help", no_argument, 0, 'h'},
			{"bus", required_argument, NULL, 'B'},
			{"device", required_argument, NULL, 'D'},
			{"function", required_argument, NULL, 'F'},
			{"segment", optional_argument, NULL, 'S'},
			{"data_size", required_argument, 0, 's'},
			{"payload_size", required_argument, 0, 'p'},
			{"direction", required_argument, 0, 'r'},
			{"type", required_argument, 0, 't'},
			{"loopback", required_argument, 0, 'l'},
			{"decim_factor", required_argument, 0, 'f'},
			{0, 0, 0, 0}
		};
		char *endptr;
		const char *tmp_optarg;

		c = getopt_long(argc, argv, "hB:D:F:S:s:p:r:l:f:t:", options, NULL);
		if (c == -1) {
			break;
		}

		endptr = NULL;
		tmp_optarg = optarg;
		if ((optarg) && ('=' == *tmp_optarg)) {
			++tmp_optarg;
		}

		switch (c) {
		case 'h':
			printUsage();
			break;

		case 'B':    /* bus */
			if (NULL == tmp_optarg)
				break;
			config->bus = (int) strtoul(tmp_optarg, &endptr, 0);
			debug_print("bus = %x\n", config->bus);
			break;

		case 'D':    /* device */
			if (NULL == tmp_optarg)
				break;
			config->device = (int) strtoul(tmp_optarg, &endptr, 0);
			debug_print("device = %x\n", config->device);
			break;

		case 'F':    /* function */
			if (NULL == tmp_optarg)
				break;
			config->function = (int)strtoul(tmp_optarg, &endptr, 0);
			debug_print("function = %x\n", config->function);
			break;

		case 'S':    /* pcie segment */
			if (NULL == tmp_optarg)
				break;
			config->segment = (int)strtoul(tmp_optarg, &endptr, 0);
			debug_print("pcie segment = %x\n", config->segment);
			break;

		case 's':    /* total data size */
			if (NULL == tmp_optarg)
				break;
			config->data_size = (uint64_t) strtoull(tmp_optarg, &endptr, 0);
			if(config->data_size < MIN_PAYLOAD_LEN) {
				fprintf(stderr, "Minimum data size must be %d bytes\n", MIN_PAYLOAD_LEN);
				printUsage();
			}
			debug_print("data_size = %ld bytes\n", config->data_size);
			break;

		case 'p':    /* payload size */
			if (NULL == tmp_optarg)
				break;
			config->payload_size = (uint64_t) strtoull(tmp_optarg, &endptr, 0);
			if(config->payload_size < MIN_PAYLOAD_LEN) {
				fprintf(stderr, "Minimum payload size must be %d bytes\n", MIN_PAYLOAD_LEN);
				printUsage();
			}
			debug_print("payload = %ld bytes\n", config->payload_size);
			break;

		case 'r':    /* direction */
			if (NULL == tmp_optarg)
				break;
			if (!STR_CONST_CMP(tmp_optarg, "mtos")) {
				config->direction = STDMA_MTOS;
				debug_print("direction = memory to stream\n");
			}
			else if (!STR_CONST_CMP(tmp_optarg, "stom")) {
				config->direction = STDMA_STOM;
				debug_print("direction = stream to memory\n");
			}
			else {
				config->direction = STDMA_INVAL_DIRECTION;
				fprintf(stderr, "Invalid direction\n");
				printUsage();
			}
			break;

		case 't':    /* transfer type */
			if (NULL == tmp_optarg)
				break;
			if (!STR_CONST_CMP(tmp_optarg, "fixed")) {
				config->transfer_type = STDMA_TRANSFER_FIXED;
				debug_print("transfer = fixed size\n");
			}
			else if (!STR_CONST_CMP(tmp_optarg, "packet")) {
				config->transfer_type = STDMA_TRANSFER_PACKET;
				debug_print("transfer = packet\n");
			}
			else {
				config->transfer_type = STDMA_INVAL_TRANSFER_TYPE;
				fprintf(stderr, "invalid transfer: %s\n",
					tmp_optarg);
				printUsage();
			}
			break;

		case 'l':    /* loopback mode */
			if (NULL == tmp_optarg)
				break;
			if (!STR_CONST_CMP(tmp_optarg, "on")) {
				config->loopback = STDMA_LOOPBACK_ON;
				debug_print("loopback = on\n");
			}
			else if (!STR_CONST_CMP(tmp_optarg, "off")) {
				config->loopback = STDMA_LOOPBACK_OFF;
				debug_print("loopback = off\n");
			}
			else {
				config->loopback = STDMA_INVAL_LOOPBACK;
				fprintf(stderr, "Invalid loopback mode\n");
				printUsage();
			}
			break;

		case 'f':    /* decimation factor */
			if (NULL == tmp_optarg)
				break;
			config->decim_factor = (uint64_t) strtoull(tmp_optarg, &endptr, 0);
			if(config->decim_factor > 65536) {
				fprintf(stderr, "Maximum decimation factor = %d bytes\n", 65536);
				printUsage();
			}
			debug_print("decimation factor = %ld bytes\n", (uint64_t)config->decim_factor);
			break;

		default:
			fprintf(stderr, "unknown op %c\n", c);
			printUsage();
			break;
		} //end case
	} while(1);
}

int main(int argc, char *argv[]) {
	fpga_result res = FPGA_OK;
	fpga_token afc_tok;

	struct config config = {
		.bus = CONFIG_UNINIT,
		.device = CONFIG_UNINIT,
		.function = CONFIG_UNINIT,
		.segment = CONFIG_UNINIT,
		.data_size = CONFIG_UNINIT,
		.payload_size = CONFIG_UNINIT,
	 	.direction = STDMA_INVAL_DIRECTION,
	 	.transfer_type = STDMA_INVAL_TRANSFER_TYPE,
	 	.loopback = STDMA_INVAL_LOOPBACK
	};

	parse_args(&config, argc, argv);
	if(config.data_size == CONFIG_UNINIT ||
		config.loopback == STDMA_INVAL_LOOPBACK ||
		config.payload_size == CONFIG_UNINIT ||
		config.transfer_type == STDMA_INVAL_TRANSFER_TYPE) {
		printUsage();
		exit(1);
	}

	// must specify direction when loopback is turned off
	if(config.loopback == STDMA_LOOPBACK_OFF && config.direction == STDMA_INVAL_DIRECTION) {
		printUsage();
		exit(1);
	}
	
	int ret = find_accelerator(DMA_AFU_ID, &config, &afc_tok);
	if (ret < 0) {
		fprintf(stderr, "failed to find accelerator\n");
		exit(1);
	} else if (ret > 1) {
		fprintf(stderr, "Found more than one suitable slot, "
			"please be more specific.\n");
	} else {
		bool cpu_affinity = true;
		bool memory_affinity = true;
		debug_print("found %d accelerator(s)\n", ret);
		res = configure_numa(afc_tok, cpu_affinity, memory_affinity);
		ON_ERR_GOTO(res, out, "configuring NUMA affinity");

		res = do_action(&config, afc_tok);
		ON_ERR_GOTO(res, out, "error do_action");
	}

out:
	fpgaDestroyToken(&afc_tok);
	return ret;
}
