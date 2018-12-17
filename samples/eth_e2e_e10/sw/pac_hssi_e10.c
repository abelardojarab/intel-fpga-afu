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
#include <ctype.h>
#include <safe_string/safe_string.h>
#include <sys/types.h>
#include <net/ethernet.h>
#include <netinet/ether.h>
#include "fpga_hssi.h"

/**
 * \pac_hssi_e10.c
 * \brief E10 HSSI Configuration and Test Utility
 */

#include <stdlib.h>
#include <assert.h>

#define MAX_STR_LEN 256

static int err_cnt;

enum eth_action {
	ETH_ACT_NONE,
	ETH_ACT_STAT,
	ETH_ACT_STAT_CLR,
	ETH_ACT_LOOP_ENABLE,
	ETH_ACT_LOOP_DISABLE,
	ETH_ACT_PKT_SEND,
};

#define CONFIG_UNINIT (-1)
#define MAC_STR_LEN 17 //bytes

static struct config {
	int bus;
	int device;
	int function;
	int instance;
	int channel;
	struct ether_addr src_mac;
	struct ether_addr dst_mac;
	uint64_t packets;
	uint64_t pkt_len;
	enum eth_action action;
} config = {
	.bus = CONFIG_UNINIT,
	.device = CONFIG_UNINIT,
	.function = CONFIG_UNINIT,
	.instance = CONFIG_UNINIT,
	.channel = 0,
	.packets = 0x10000,
	.pkt_len = 0x40,
	.action = ETH_ACT_NONE,
};

static void printUsage(char *prog)
{
	printf(
"%s\n"
"PAC HSSI configuration utility\n"
"Usage:\n" 
"     pac_hssi_e10 [-h] [-b <bus>] [-d <device>] [-f <function>] [-s Src. MAC]\n"
"                  [-m Dest. MAC] [-p Number of packets] [-l Packet length] -a action\n\n"
"         -h,--help           Print this help\n"
"         -b,--bus            Set target bus number\n"
"         -d,--device         Set target device number\n"
"         -f,--function       Set target function number\n"
"         -c,--channel        Set HSSI channel (0 - 3)\n"
"         -s,--src_mac        Set Source MAC (in the format AA:BB:CC:DD:EE:FF)\n"
"         -m,--dest_mac       Set Destination MAC (in the format AA:BB:CC:DD:EE:FF)\n"
"         -p,--packets        Total number of packets (in hex format e.g. 0x100)\n"
"         -l,--pkt_len        Packet length bytes (in hex format e.g. 0x100)\n"
"         -a,--action         Perform action:\n\n"
"           stat              Print channel statistics\n"
"           stat_clear        Clear channel statistics\n"
"           loopback_enable   Enable internal channel loopback\n"
"           loopback_disable  Disable internal channel loopback\n"
"           pkt_send          Send packets\n"
, prog);

	exit(1);
}

#define STR_CONST_CMP(str, str_const) strncmp(str, str_const, sizeof(str_const))

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
			{"src_mac",       optional_argument, 0,    's'},
			{"dest_mac", optional_argument, 0, 'm'},
			{"packets",       optional_argument, 0,    'p'},
			{"pkt_len",       optional_argument, 0,    'l'},
			{"action", required_argument, 0, 'a'},
			{0, 0, 0, 0}
		};
		char *endptr;
		const char *tmp_optarg;

		c = getopt_long(argc, argv, "hb:d:f:c:s:m:p:l:a:", options, NULL);
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
			config->function = (int)strtoul(tmp_optarg, &endptr, 0);
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

		case 's':    /* Set Source MAC */
			if (NULL == tmp_optarg)
				break;

			struct ether_addr *saddr = ether_aton_r((char*)tmp_optarg, &config->src_mac);
			if(!saddr) {
				fprintf(stderr, "invalid mac: %s\n",
					tmp_optarg);
				printUsage(argv[0]);
			}
			break;


		case 'm':    /* Set Destination MAC */
			if (NULL == tmp_optarg)
				break;

			struct ether_addr *daddr = ether_aton_r((char*)tmp_optarg, &config->dst_mac);
			if(!daddr) {
				fprintf(stderr, "invalid mac: %s\n",
					tmp_optarg);
				printUsage(argv[0]);
			}
			break;

		case 'p':    /* Total number of packets */
			if (NULL == tmp_optarg)
				break;
			endptr = NULL;
			config->packets = (int)strtoul(tmp_optarg, &endptr, 0);
			if (endptr != tmp_optarg + strlen(tmp_optarg)) {
				fprintf(stderr, "invalid number of packets: %s\n",
					tmp_optarg);
				printUsage(argv[0]);
			}
			break;

		case 'l':    /* Packet length */
			if (NULL == tmp_optarg)
				break;
			endptr = NULL;
			config->pkt_len = (int)strtoul(tmp_optarg, &endptr, 0);
			if (endptr != tmp_optarg + strlen(tmp_optarg)) {
				fprintf(stderr, "invalid packet length: %s\n",
					tmp_optarg);
				printUsage(argv[0]);
			}
			break;

		case 'a':
			if (NULL == optarg) {
				printf("unexpected NULL action\n");
				printUsage(argv[0]);
			} else if (!STR_CONST_CMP(optarg, "stat"))
				config->action = ETH_ACT_STAT;
			else if (!STR_CONST_CMP(optarg, "stat_clear"))
				config->action = ETH_ACT_STAT_CLR;
			else if (!STR_CONST_CMP(optarg, "loopback_enable"))
				config->action = ETH_ACT_LOOP_ENABLE;
			else if (!STR_CONST_CMP(optarg, "loopback_disable"))
				config->action = ETH_ACT_LOOP_DISABLE;
			else if (!STR_CONST_CMP(optarg, "pkt_send"))
				config->action = ETH_ACT_PKT_SEND;
			else {
				printf("Invalid action specified\n");
				printUsage(argv[0]);
			}
			break;

		default:
			fprintf(stderr, "unknown op %c\n", c);
			printUsage(argv[0]);
			break;
		} //end case
	} while(1);

	if (config->action == ETH_ACT_NONE) {
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

	switch (config->action) {
	case ETH_ACT_STAT:
		fpgaHssiPrintChannelStats(hssi_h, TX, config->channel);
		fpgaHssiPrintChannelStats(hssi_h, RX, config->channel);
		break;
	case ETH_ACT_STAT_CLR:
		fpgaHssiClearChannelStats(hssi_h, TX, config->channel);
		printf("Cleared TX stats on channel %d\n", config->channel);
		fpgaHssiClearChannelStats(hssi_h, RX, config->channel);
		printf("Cleared RX stats on channel %d\n", config->channel);
		break;
	case ETH_ACT_LOOP_ENABLE:
		fpgaHssiCtrlLoopback(hssi_h, config->channel, true);
		printf("Enabled loopback on channel %d\n", config->channel);
		break;
	case ETH_ACT_LOOP_DISABLE:
		fpgaHssiCtrlLoopback(hssi_h, config->channel, false);
		printf("Disabled loopback on channel %d\n", config->channel);
		break;
	case ETH_ACT_PKT_SEND:
		fpgaHssiSendPacket(hssi_h, config->channel, config->packets, &config->src_mac, &config->dst_mac, config->pkt_len);
		char src_str[18];
		char dst_str[18];
		ether_ntoa_r(&config->src_mac, src_str);
		ether_ntoa_r(&config->dst_mac, dst_str);
		printf("Sent 0x%lx packets on channel %d from src=[%s] to dst=[%s]\n",
			config->packets, config->channel, src_str, dst_str);
		break;
	default:
		fprintf(stderr, "unknown action, %d\n", config->action);
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
