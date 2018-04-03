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

#define NUM_PKT_TO_SEND 10000
#define MAX_STR_LEN 256

static int err_cnt;


// Enumerate all HSSI instances
static fpga_result enumerateInstances(uint64_t *instances, fpga_token *tokens)
{
	fpga_result res = FPGA_OK;
	fpga_properties filter = NULL;
	fpga_guid guid;
	uint32_t num_matches;
	*instances = 0;

	if (uuid_parse(E10_AFU_ID, guid) < 0)
		return FPGA_EXCEPTION;

	res = fpgaGetProperties(NULL, &filter);
	ON_ERR_GOTO(res, out, "fpgaGetProperties");

	res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesSetObjectType");

	res = fpgaPropertiesSetGUID(filter, guid);
	ON_ERR_GOTO(res, out_destroy_prop, "fpgaPropertiesSetGUID");

	if (!tokens)
		res = fpgaEnumerate(&filter, 1, NULL, 0, &num_matches);
	else
		res = fpgaEnumerate(&filter, 1, tokens, UINT_MAX, &num_matches);

	ON_ERR_GOTO(res, out_destroy_prop, "fpgaEnumerate");

out_destroy_prop:
	res = fpgaDestroyProperties(&filter);
	ON_ERR_GOTO(res, out, "fpgaDestroyProperties");

out:
	*instances = num_matches;

	return err_cnt;
}

static void printUsage(void)
{
	printf("Usage: pac_hssi_config [--help] [--list]\
		[--instance <instance #>] [--channel <channel #>]\
		[--channel_action <stat|stat_clear|loopback_enable|\
		loopback_disable|pkt_send]\n");
}

static int loc_strcmp_s(const char *dest, rsize_t dmax, const char *src) {
	int indicator;
	strcmp_s(dest, dmax, src, &indicator);
	return indicator;
}

int main(int argc, char *argv[])
{
	fpga_result res = FPGA_OK;
	fpga_hssi_handle hssi_h;
	fpga_handle afc_h;
	int instance_id = 0;
	int channel_id = 0;

	int help_f = 0;
	int list_f = 0;
	int instance_f = 0;
	int channel_f = 0;
	int channel_action_f = 0;
	char action[MAX_STR_LEN];
	fpga_token *afc_tokens = NULL;

	strcpy_s(action, MAX_STR_LEN, "none");
	// parse args
	int c;

	err_cnt = 0;
	do {
		static struct option options[] = {
			{"help", no_argument, 0, 'h'},
			{"list", no_argument, 0, 'l'},
			{"instance", required_argument, 0, 'i'},
			{"channel", required_argument, 0, 'c'},
			{"channel_action", required_argument, 0, 'a'},
			{0, 0, 0, 0}
		};

		c = getopt_long(argc, argv, "l:i:p:a", options, NULL);
		if (c == -1)
			break;

		switch (c) {
		case 'h':
			help_f = 1;
			printUsage();
			break;

		case 'l':
			list_f = 1;
			break;

		case 'i':
			instance_f = 1;
			instance_id = atoi(optarg);
			break;

		case 'c':
			channel_f = 1;
			channel_id = atoi(optarg);
			break;

		case 'a':
			if (loc_strcmp_s(optarg, MAX_STR_LEN, "stat") == 0 ||
			loc_strcmp_s(optarg, MAX_STR_LEN, "stat_clear") == 0 ||
			loc_strcmp_s(optarg, MAX_STR_LEN, "loopback_enable") == 0 ||
			loc_strcmp_s(optarg, MAX_STR_LEN, "loopback_disable") == 0 ||
			loc_strcmp_s(optarg, MAX_STR_LEN, "pkt_send") == 0) {
				channel_action_f = 1;
				strcpy_s(action, MAX_STR_LEN, optarg);
				break;
			}
			printf("Invalid channel_action specified\n");
			printUsage();
			return 1;

		default:
			printf("Aborting\n");
			return 1;
		}
	} while(1);

	if (help_f)
		return 0;

	uint64_t instances = 0;

	if (list_f) {
		enumerateInstances(&instances, NULL);
		printf("Found %ld instances\n", instances);
		return 0;
	}

	if (channel_action_f) {
		if (!instance_f) {
			fprintf(stderr, "No instance specified. Select an \
				instance using --instance\n");
			printUsage();
			return 1;
		}

		if (!channel_f) {
			fprintf(stderr, "No channel specified. Select a \
				channel using --channel\n");
			printUsage();
			return 1;
		}

		enumerateInstances(&instances, NULL);
		if (instances == 0) {
			fprintf(stderr, "No valid instances available\n");
			return 1;
		}

		afc_tokens = (fpga_token *)malloc(instances *
			sizeof(fpga_token));
		if (!afc_tokens) {
			fprintf(stderr, "Unable to alloc tokens\n");
			return 1;
		}
		if (enumerateInstances(&instances, afc_tokens) != FPGA_OK) {
			fprintf(stderr, "Unable to enumerate instances\n");
			return 1;
		}

		if (instance_id >= instances) {
			fprintf(stderr, "Specified instance (--instance=%d) \
				not available\n", instance_id);
			return 1;
		}

		if (channel_id >= NUM_ETH_CHANNELS) {
			fprintf(stderr, "Specified channel \
				(--channel=%d) not available\n",
				channel_id);
			return 1;
		}

		// open the AFC
		res = fpgaOpen(afc_tokens[instance_id], &afc_h, 0);
		if (res != FPGA_OK) {
			fprintf(stderr, "Unable to open instance %d error=%s\n",
				instance_id, fpgaErrStr(res));
			return 1;
		}

		res = fpgaHssiOpen(afc_h, &hssi_h);
		ON_ERR_GOTO(res, out_hssi_close, "fpgaHssiOpen");
		if (!hssi_h) {
			res = FPGA_EXCEPTION;
			ON_ERR_GOTO(res, out_hssi_close, "Invaid HSSI Handle");
		}

		if (strcmp(action, "stat") == 0) {
			fpgaHssiPrintChannelStats(hssi_h, TX, channel_id);
			fpgaHssiPrintChannelStats(hssi_h, RX, channel_id);
			goto out_hssi_close;
		}
		if (strcmp(action, "stat_clear") == 0) {
			fpgaHssiClearChannelStats(hssi_h, TX, channel_id);
			printf("Cleared TX stats on channel %d\n", channel_id);
			fpgaHssiClearChannelStats(hssi_h, RX, channel_id);
			printf("Cleared RX stats on channel %d\n", channel_id);
			goto out_hssi_close;
		}
		if (strcmp(action, "loopback_enable") == 0) {
			fpgaHssiCtrlLoopback(hssi_h, channel_id, true);
			printf("Enabled loopback on channel %d\n", channel_id);
			goto out_hssi_close;
		}
		if (strcmp(action, "loopback_disable") == 0) {
			fpgaHssiCtrlLoopback(hssi_h, channel_id, false);
			printf("Disabled loopback on channel %d\n", channel_id);
			goto out_hssi_close;
		}
		if (strcmp(action, "pkt_send") == 0) {
			printf("Sent %d packets on channel %d\n",
				NUM_PKT_TO_SEND, channel_id);
			fpgaHssiSendPacket(hssi_h, channel_id, NUM_PKT_TO_SEND);
		}
	}

out_hssi_close:
	if (afc_tokens) {
		for (int i = 0; i < instances; i++)
			fpgaDestroyToken(&afc_tokens[i]);

		free(afc_tokens);
	}

	if (hssi_h)
		fpgaHssiClose(hssi_h);

	if (afc_h)
		fpgaClose(afc_h);

	return err_cnt;
}
