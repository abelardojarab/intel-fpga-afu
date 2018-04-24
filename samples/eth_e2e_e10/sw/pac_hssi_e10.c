// Copyright(c) 2018, Intel Corporation
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

#include <string.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>
#include <time.h>
#include <unistd.h>
#include <getopt.h>
#include <limits.h>
#include <safe_string/safe_string.h>
#include "fpga_hssi.h"

/**
 * \pac_hssi_e10.c
 * \brief E10 HSSI Configuration and Test Utility
 */

#include <stdlib.h>
#include <assert.h>

#define NUM_PKT_TO_SEND 0x10000
#define MAX_STR_LEN 256

static int err_cnt;

#define CONFIG_UNINIT (-1)
static struct config {
	int bus;
	int device;
	int function;
	int instance;
	int channel;
	char action[MAX_STR_LEN];
} config = {
	.bus = CONFIG_UNINIT,
	.device = CONFIG_UNINIT,
	.function = CONFIG_UNINIT,
	.instance = CONFIG_UNINIT,
	.channel = 0,
	.action = {0},
};

static void printUsage(char *prog)
{
	printf(
"%s\n"
"PAC HSSI configuration utility\n"
"Usage:\n" 
"     pac_hssi_e10 [-h] [-b <bus>] [-d <device>] [-f <function>] "
"-c channel -a action\n\n"
"         -h,--help           Print this help\n"
"         -b,--bus            Set target bus number\n"
"         -d,--device         Set target device number\n"
"         -f,--function       Set target function number\n"
"         -c,--channel        Set HSSI channel (0 - 3)\n"
"         -a,--action         Perform action:\n\n"
"           stat              Print channel statistics\n"
"           stat_clear        Clear channel statistics\n"
"           loopback_enable   Enable internal channel loopback\n"
"           loopback_disable  Disable internal channel loopback\n"
"           pkt_send          Send 0x%x packets\n"
, prog, NUM_PKT_TO_SEND);

	exit(1);


}

static int loc_strcmp_s(const char *dest, rsize_t dmax, const char *src) {
	int indicator;
	strcmp_s(dest, dmax, src, &indicator);
	return indicator;
}

static void parse_args(struct config *config, int argc, char *argv[])
{
	int c;
	do {
		static const struct option options[] = {
			{"help", no_argument, 0, 'h'},
			{"bus",           required_argument, NULL, 'b'},
			{"device",        required_argument, NULL, 'd'},
			{"function",      required_argument, NULL, 'f'},
			{"channel", required_argument, 0, 'c'},
			{"action", required_argument, 0, 'a'},
			{0, 0, 0, 0}
		};
		char *endptr;
		const char *tmp_optarg;

		c = getopt_long(argc, argv, "hlb:d:f:c:a:", options, NULL);
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
			printUsage(argv[0]);
			break;

		case 'b':    /* bus */
			if (NULL == tmp_optarg)
				break;
			endptr = NULL;
			config->bus = (int) strtoul(tmp_optarg, &endptr, 0);
			if (endptr != tmp_optarg + strlen(tmp_optarg)) {
				fprintf(stderr, "invalid bus: %s\n",
					tmp_optarg);
				printUsage(argv[0]);
			}
			break;

		case 'd':    /* device */
			if (NULL == tmp_optarg)
				break;
			endptr = NULL;
			config->device = (int) strtoul(tmp_optarg, &endptr, 0);
			if (endptr != tmp_optarg + strlen(tmp_optarg)) {
				fprintf(stderr, "invalid device: %s\n",
					tmp_optarg);
				printUsage(argv[0]);
			}
			break;

		case 'f':    /* function */
			if (NULL == tmp_optarg)
				break;
			endptr = NULL;
			config->function = (int) strtoul(tmp_optarg, &endptr, 0);
			if (endptr != tmp_optarg + strlen(tmp_optarg)) {
				fprintf(stderr, "invalid function: %s\n",
					tmp_optarg);
				printUsage(argv[0]);
			}
			break;


		case 'c':    /* channel */
			if (NULL == tmp_optarg)
				break;
			endptr = NULL;
			config->channel = (int) strtoul(tmp_optarg, &endptr, 0);
			if ((endptr != tmp_optarg + strlen(tmp_optarg) ||
			    (config->channel < 0) || (config->channel > 3))) {
				fprintf(stderr, "invalid channel: %s\n",
					tmp_optarg);
				printUsage(argv[0]);
			}
			break;

		case 'a':
			if (!loc_strcmp_s(optarg, MAX_STR_LEN, "stat") ||
			!loc_strcmp_s(optarg, MAX_STR_LEN, "stat_clear") ||
			!loc_strcmp_s(optarg, MAX_STR_LEN, "loopback_enable") ||
			!loc_strcmp_s(optarg, MAX_STR_LEN, "loopback_disable")||
			!loc_strcmp_s(optarg, MAX_STR_LEN, "pkt_send")) {
				strcpy_s(config->action, MAX_STR_LEN, optarg);
				break;
			}
			printf("Invalid action specified\n");
			printUsage(argv[0]);
			break;

		default:
			fprintf(stderr, "unknown op %c\n", c);
			printUsage(argv[0]);
			break;
		} //end case
	} while(1);

	if (!strlen(config->action)) {
		fprintf(stderr, "no action specified\n");
		printUsage(argv[0]);
	}
}

static int find_accelerator(const char *afu_id, struct config *config,
			    fpga_token *afu_tok)
{
	fpga_guid guid;
	fpga_properties filter = NULL;
	uint32_t num_matches = 0;
        fpga_result res;

	if (uuid_parse(afu_id, guid) < 0)
		return FPGA_EXCEPTION;

	res = fpgaGetProperties(NULL, &filter);
	ON_ERR_GOTO(res, out, "fpgaGetProperties");

	res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesSetObjectType");

	res = fpgaPropertiesSetGUID(filter, guid);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesSetGUID");

	if (CONFIG_UNINIT != config->bus) {
		res = fpgaPropertiesSetBus(filter, config->bus);
		ON_ERR_GOTO(res, out_destroy_prop, "setting bus");
	}

	if (CONFIG_UNINIT != config->device) {
		res = fpgaPropertiesSetDevice(filter, config->device);
		ON_ERR_GOTO(res, out_destroy_prop, "setting device");
	}

	if (CONFIG_UNINIT != config->function) {
		res = fpgaPropertiesSetFunction(filter, config->function);
		ON_ERR_GOTO(res, out_destroy_prop, "setting function");
	}

	res = fpgaEnumerate(&filter, 1, afu_tok, 1, &num_matches);
	ON_ERR_GOTO(res, out_destroy_prop, "enumerating FPGAs");

out_destroy_prop:
	res = fpgaDestroyProperties(&filter);
	ON_ERR_GOTO(res, out, "fpgaDestroyProperties");

out:

	if (num_matches > 0)
		return (int)num_matches;
	else
		return 0;
}

static int do_action(struct config *config, fpga_token afc_tok)
{
	fpga_hssi_handle hssi_h = NULL;
	fpga_handle afc_h = NULL;
	fpga_result res;
	int ret = 0;
	res = fpgaOpen(afc_tok, &afc_h, 0);
	if (res != FPGA_OK) {
		fprintf(stderr, "Unable to open instance error=%s\n",
			fpgaErrStr(res));
		return 1;
	}

	res = fpgaHssiOpen(afc_h, &hssi_h);
	ON_ERR_GOTO(res, out_hssi_close, "fpgaHssiOpen");
	if (!hssi_h) {
		res = FPGA_EXCEPTION;
		ON_ERR_GOTO(res, out_hssi_close, "Invaid HSSI Handle");
	}

	if (strcmp(config->action, "stat") == 0) {
		fpgaHssiPrintChannelStats(hssi_h, TX, config->channel);
		fpgaHssiPrintChannelStats(hssi_h, RX, config->channel);
	} else if (strcmp(config->action, "stat_clear") == 0) {
		fpgaHssiClearChannelStats(hssi_h, TX, config->channel);
		printf("Cleared TX stats on channel %d\n", config->channel);
		fpgaHssiClearChannelStats(hssi_h, RX, config->channel);
		printf("Cleared RX stats on channel %d\n", config->channel);
	} else if (strcmp(config->action, "loopback_enable") == 0) {
		fpgaHssiCtrlLoopback(hssi_h, config->channel, true);
		printf("Enabled loopback on channel %d\n", config->channel);
	} else if (strcmp(config->action, "loopback_disable") == 0) {
		fpgaHssiCtrlLoopback(hssi_h, config->channel, false);
		printf("Disabled loopback on channel %d\n", config->channel);
	} else if (strcmp(config->action, "pkt_send") == 0) {
		fpgaHssiSendPacket(hssi_h, config->channel, NUM_PKT_TO_SEND);
		printf("Sent 0x%x packets on channel %d\n",
			NUM_PKT_TO_SEND, config->channel);
	} else {
		fprintf(stderr, "unknown action, %s\n", config->action);
		ret = 1;
	}

out_hssi_close:
	if (hssi_h)
		fpgaHssiClose(hssi_h);

	if (afc_h)
		fpgaClose(afc_h);

	return ret;
}

int main(int argc, char *argv[])
{
	fpga_token afc_tok;
	int ret;

	parse_args(&config, argc, argv);

	ret = find_accelerator(AFU_ACCEL_UUID, &config, &afc_tok);
	if (ret < 0) {
		fprintf(stderr, "failed to find accelerator\n");
		exit(1);
	} else if (ret == 0) {
		fprintf(stderr, "no suitable accelerators found\n");
		exit(1);
	} else if (ret > 1) {
		fprintf(stderr, "Found more than one suitable slot, "
			"please be more specific.\n");
	} else {
		ret = do_action(&config, afc_tok);
	}
	fpgaDestroyToken(&afc_tok);

	exit(ret);
}
