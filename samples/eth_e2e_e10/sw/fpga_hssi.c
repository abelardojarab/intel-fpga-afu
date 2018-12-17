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
// ARE DISCLAIMEdesc.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS
// BE
// LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

/**
 * \fpga_hssi.c
 * \brief HSSI E10 User-space APIs
 */
#include <stdlib.h>
#include <opae/fpga.h>
#include <time.h>
#include <string.h>
#include <safe_string/safe_string.h>
#include "fpga_hssi.h"
#include "fpga_hssi_e10.h"

static int err_cnt;

static void byte_reverse(fpga_guid guid)
{
	int i;
	char t;

	for (i = 0; i < sizeof(fpga_guid)/2; i++) {
		t = guid[sizeof(fpga_guid)-i-1];
		guid[sizeof(fpga_guid)-i-1] = guid[i];
		guid[i] = t;
	}
}

static void repeat(char c, int cnt)
{
	while (cnt-- > 0)
		printf("%c", c);
	printf("\n");
}

static void prMgmtWrite(volatile struct afu_dfl *const dfl, pr_mgmt_cmd_t cmd,
	pr_mgmt_data_t data)
{
	dfl->eth_wr_data = (uint64_t)data.reg;
	dfl->eth_ctrl_addr = PR_WRITE_CMD | cmd;
	dfl->eth_ctrl_addr = 0;
}

static void prMgmtRead(volatile struct afu_dfl *const dfl, pr_mgmt_cmd_t cmd,
	pr_mgmt_data_t *data)
{
	struct timespec time;
	time.tv_sec = 0;
	time.tv_nsec = 10000;
	data->reg = 0;
	dfl->eth_ctrl_addr = PR_READ_CMD | cmd;
	nanosleep(&time, &time);
	data->reg = (uint64_t)dfl->eth_rd_data;
	dfl->eth_ctrl_addr = 0;
}

// Public
fpga_result fpgaHssiOpen(fpga_handle fpga, fpga_hssi_handle *hssi)
{
	fpga_result res = FPGA_OK;
	fpga_guid guid;
	int i;

	err_cnt = 0;

	if (!fpga)
		return FPGA_INVALID_PARAM;

	if (!hssi)
		return FPGA_INVALID_PARAM;

	if (uuid_parse(E10_AFU_ID, guid) < 0)
		return FPGA_EXCEPTION;

	struct _fpga_hssi_handle_t *h;

	h = (fpga_hssi_handle)malloc(sizeof(struct _fpga_hssi_handle_t));
	if (!h)
		return FPGA_NO_MEMORY;

	h->csr_cnt = sizeof(e10_csrs)/sizeof(struct _hssi_csr);
	h->csrs = malloc(sizeof(struct _hssi_csr *) * h->csr_cnt);
	if(!h->csrs) {
		res = FPGA_NO_MEMORY;
		ON_ERR_GOTO(res, out_h,
			    "Unable to allocate CSR memory in handle");
	}

	for (i = 0; i < h->csr_cnt; i++)
		h->csrs[i] = &e10_csrs[i];

	res = fpgaMapMMIO(fpga, 0, (uint64_t **)&h->mmio_ptr);
	ON_ERR_GOTO(res, out_csr, "fpgaMapMMIO");

	h->dfl = (struct afu_dfl *)h->mmio_ptr;

	// guid string is big-endian, switch to little-endian before comparison
	byte_reverse(guid);
	if (memcmp(guid, &(h->dfl->afu_id_lo), sizeof(h->dfl->afu_id_lo)) ||
		memcmp(&guid[sizeof(h->dfl->afu_id_lo)], &(h->dfl->afu_id_hi),
			sizeof(h->dfl->afu_id_hi))
	) {
		res = FPGA_EXCEPTION;
		fpgaUnmapMMIO(fpga, 0);
		ON_ERR_GOTO(res, out_csr, "Invalid UUID");
	}
	h->fpga_h = fpga;

	*hssi = h;
	return FPGA_OK;

out_csr:
	if (h->csrs)
		free(h->csrs);
out_h:
	if (h)
		free(h);

	return res;
}

fpga_result fpgaHssiClose(fpga_hssi_handle hssi)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	fpgaUnmapMMIO(hssi->fpga_h, 0);

	if (hssi->csrs)
		free(hssi->csrs);

	free(hssi);
	return FPGA_OK;
}


fpga_result fpgaHssiReset(fpga_hssi_handle hssi)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_t wr_data = {0};

	// Asssert reset
	wr_data.rst.tx_rst = 1;
	wr_data.rst.rx_rst = 1;
	wr_data.rst.csr_rst = 1;
	prMgmtWrite(hssi->dfl, PR_MGMT_RST, wr_data);

	// Reset release sequence
	// reset TX and RX
	wr_data.rst.tx_rst = 1;
	wr_data.rst.rx_rst = 1;
	prMgmtWrite(hssi->dfl, PR_MGMT_RST, wr_data);

	// release RX reset
	wr_data.rst.rx_rst = 0;
	prMgmtWrite(hssi->dfl, PR_MGMT_RST, wr_data);

	// release TX reset
	wr_data.rst.tx_rst = 0;
	prMgmtWrite(hssi->dfl, PR_MGMT_RST, wr_data);

	return FPGA_OK;
}

fpga_result fpgaHssiEnumerateCsr(fpga_hssi_handle hssi, hssi_csr **csrs_p,
	size_t *count)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	if (!count)
		return FPGA_INVALID_PARAM;

	if (!csrs_p)
		return FPGA_INVALID_PARAM;

	*csrs_p = hssi->csrs;
	*count = hssi->csr_cnt;
	return FPGA_OK;
}

fpga_result fpgaHssiFilterCsrByName(fpga_hssi_handle hssi,
	const char *name, hssi_csr *csr_p)
{
	int indicator;
	if (!hssi || !csr_p)
		return FPGA_INVALID_PARAM;

	int i = 0;

	for (i = 0; i < hssi->csr_cnt; i++) {
		strcmp_s(name, MAX_NAME_LEN, hssi->csrs[i]->name, &indicator);
		if(indicator == 0) {
			*csr_p = hssi->csrs[i];
			return FPGA_OK;
		}
	}
	*csr_p = NULL;
	return FPGA_NOT_FOUND;
}

fpga_result fpgaHssiFilterCsrByOffset(fpga_hssi_handle hssi,
	uint64_t offset, hssi_csr *csr_p)
{
	if (!hssi || !csr_p)
		return FPGA_INVALID_PARAM;

	int i = 0;

	for (i = 0; i < hssi->csr_cnt; i++) {
		if (offset == hssi->csrs[i]->offset) {
			*csr_p = hssi->csrs[i];
			return FPGA_OK;
		}
	}
	*csr_p = NULL;
	return FPGA_NOT_FOUND;
}

fpga_result fpgaHssiWriteCsr64(fpga_hssi_handle hssi, hssi_csr csr,
	uint64_t val)
{
	if (!hssi || !csr)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_t wr_data = {0};

	wr_data.reg = val;
	wr_data.status_wr_data = val;
	prMgmtWrite(hssi->dfl, PR_MGMT_STATUS_WR_DATA, wr_data);

	wr_data.reg = 0;
	wr_data.status.status_addr = csr->offset;
	wr_data.status.status_wr = 1;
	prMgmtWrite(hssi->dfl, PR_MGMT_STATUS, wr_data);
	return FPGA_OK;
}

fpga_result fpgaHssiReadCsr64(fpga_hssi_handle hssi,
	hssi_csr csr, uint64_t *val)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_t wr_data = {0};
	pr_mgmt_data_t rd_data = {0};

	wr_data.status.status_addr = csr->offset;
	wr_data.status.status_rd = 1;
	prMgmtWrite(hssi->dfl, PR_MGMT_STATUS, wr_data);
	prMgmtRead(hssi->dfl, PR_MGMT_STATUS_RD_DATA, &rd_data);
	*val = rd_data.reg;
	return FPGA_OK;
}

fpga_result fpgaHssiWriteCsr32(fpga_hssi_handle hssi, hssi_csr csr,
	uint32_t val)
{
	if (!hssi || !csr)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_t wr_data = {0};

	wr_data.status_wr_data = val;
	prMgmtWrite(hssi->dfl, PR_MGMT_STATUS_WR_DATA, wr_data);

	wr_data.reg = 0;
	wr_data.status.status_addr = csr->offset;
	wr_data.status.status_wr = 1;
	prMgmtWrite(hssi->dfl, PR_MGMT_STATUS, wr_data);
	return FPGA_OK;
}

fpga_result fpgaHssiReadCsr32(fpga_hssi_handle hssi,
	hssi_csr csr, uint32_t *val)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_t wr_data = {0};
	pr_mgmt_data_t rd_data = {0};

	wr_data.status.status_addr = csr->offset;
	wr_data.status.status_rd = 1;
	prMgmtWrite(hssi->dfl, PR_MGMT_STATUS, wr_data);
	prMgmtRead(hssi->dfl, PR_MGMT_STATUS_RD_DATA, &rd_data);
	*val = (uint32_t)rd_data.reg;
	return FPGA_OK;
}


fpga_result fpgaHssiCtrlLoopback(fpga_hssi_handle hssi,
	uint32_t channel_num, bool loopback_en)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_t wr_data = {0};
	pr_mgmt_data_t rd_data = {0};

	prMgmtRead(hssi->dfl, PR_MGMT_SLOOP, &rd_data);

	if (loopback_en) {
		wr_data.sloop.loop = (1<<channel_num) | rd_data.sloop.loop;
		prMgmtWrite(hssi->dfl, PR_MGMT_SLOOP, wr_data);
	} else {
		wr_data.sloop.loop = rd_data.sloop.loop & ~(1<<channel_num);
		prMgmtWrite(hssi->dfl, PR_MGMT_SLOOP, wr_data);
	}

	rd_data.reg = 0;
	prMgmtRead(hssi->dfl, PR_MGMT_LOCK_STATUS, &rd_data);
	return FPGA_OK;
}

fpga_result fpgaHssiGetLoopbackStatus(fpga_hssi_handle hssi,
	uint32_t channel_num, bool *loopback_en)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_t rd_data = {0};

	rd_data.reg = 0;
	prMgmtRead(hssi->dfl, PR_MGMT_SLOOP, &rd_data);
	if ((rd_data.sloop.loop >> channel_num) & 0x1)
		*loopback_en = true;
	else
		*loopback_en = false;

	return FPGA_OK;
}

fpga_result fpgaHssiGetFreqLockStatus(fpga_hssi_handle hssi,
	uint32_t channel_num, bool *freq_locked)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_t rd_data = {0};

	rd_data.reg = 0;
	prMgmtRead(hssi->dfl, PR_MGMT_LOCK_STATUS, &rd_data);
	if ((rd_data.lock.blk_lock >> channel_num) & 0x1)
		*freq_locked = true;
	else
		*freq_locked = false;

	return FPGA_OK;
}

fpga_result fpgaHssiGetWordLockStatus(fpga_hssi_handle hssi,
	uint32_t channel_num, bool *word_locked)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_t rd_data = {0};

	rd_data.reg = 0;
	prMgmtRead(hssi->dfl, PR_MGMT_LOCK_STATUS, &rd_data);
	if ((rd_data.lock.lockedtodata >> channel_num) & 0x1)
		*word_locked = true;
	else
		*word_locked = false;

	return FPGA_OK;
}

fpga_result fpgaHssiSendPacket(fpga_hssi_handle hssi,
	uint32_t channel_num, uint64_t num_packets, struct ether_addr *src_mac, struct ether_addr *dst_mac, uint64_t pkt_len)
{
	uint32_t dst_lo_mac, dst_hi_mac, src_lo_mac, src_hi_mac;

	if (!hssi)
		return FPGA_INVALID_PARAM;

	if (channel_num > NUM_ETH_CHANNELS)
		return FPGA_INVALID_PARAM;

	if (!dst_mac)
		return FPGA_INVALID_PARAM;

	// configure source mac address
	src_lo_mac = src_mac->ether_addr_octet[5] |
		(src_mac->ether_addr_octet[4] << 8) |
		(src_mac->ether_addr_octet[3] << 16) |
		(src_mac->ether_addr_octet[2] << 24);

	src_hi_mac = src_mac->ether_addr_octet[1] |
		(src_mac->ether_addr_octet[0] << 8);

	// configure destination mac address
	dst_lo_mac = dst_mac->ether_addr_octet[5] |
		(dst_mac->ether_addr_octet[4] << 8) |
		(dst_mac->ether_addr_octet[3] << 16) |
		(dst_mac->ether_addr_octet[2] << 24);

	dst_hi_mac = dst_mac->ether_addr_octet[1] |
		(dst_mac->ether_addr_octet[0] << 8);

	// Select channel
	pr_mgmt_data_t wr_data = {0};
	wr_data.port_sel.port = channel_num;
	prMgmtWrite(hssi->dfl, PR_MGMT_PORT_SEL, wr_data);

	// Configure total #packets
	hssi_csr pkt_csr;
	fpgaHssiFilterCsrByName(hssi, "number_of_packets", &pkt_csr);
	if (!pkt_csr)
		return FPGA_INVALID_PARAM;
	fpgaHssiWriteCsr64(hssi, pkt_csr, num_packets);

	// configure packet length
	hssi_csr pkt_len_csr;
	fpgaHssiFilterCsrByName(hssi, "pkt_length", &pkt_len_csr);
	if (!pkt_len_csr)
		return FPGA_INVALID_PARAM;
	fpgaHssiWriteCsr64(hssi, pkt_len_csr, pkt_len);

	// configure source mac address
	hssi_csr src_mac_hi_csr, src_mac_lo_csr;
	fpgaHssiFilterCsrByName(hssi, "source_addr0", &src_mac_lo_csr);
	if (!src_mac_lo_csr)
		return FPGA_INVALID_PARAM;
	fpgaHssiWriteCsr32(hssi, src_mac_lo_csr, src_lo_mac);
	fpgaHssiFilterCsrByName(hssi, "source_addr1", &src_mac_hi_csr);
	if (!src_mac_hi_csr)
		return FPGA_INVALID_PARAM;
	fpgaHssiWriteCsr32(hssi, src_mac_hi_csr, src_hi_mac);

	// configure destination mac address
	hssi_csr dst_mac_hi_csr, dst_mac_lo_csr;
	fpgaHssiFilterCsrByName(hssi, "destination_addr0", &dst_mac_lo_csr);
	if (!dst_mac_lo_csr)
		return FPGA_INVALID_PARAM;
	fpgaHssiWriteCsr32(hssi, dst_mac_lo_csr, dst_lo_mac);
	fpgaHssiFilterCsrByName(hssi, "destination_addr1", &dst_mac_hi_csr);
	if (!dst_mac_hi_csr)
		return FPGA_INVALID_PARAM;
	fpgaHssiWriteCsr32(hssi, dst_mac_hi_csr, dst_hi_mac);


	hssi_csr start_csr;
	fpgaHssiFilterCsrByName(hssi, "start", &start_csr);
	if (!start_csr)
		return FPGA_INVALID_PARAM;

	fpgaHssiWriteCsr64(hssi, start_csr, (uint64_t)1);
	return FPGA_OK;
}

fpga_result fpgaHssiPrintChannelStats(fpga_hssi_handle hssi_h,
	hssi_csr_type_t type, uint32_t channel_num)
{
	size_t count;
	hssi_csr *csrs;
	int i = 0;
	uint64_t val;
	bool loopback_en, freq_locked, word_locked;
	const char *type_str = (type == TX)?"TX":"RX";
	pr_mgmt_data_t wr_data = {0};
	
	// Select channel
	wr_data.port_sel.port = channel_num;
	prMgmtWrite(hssi_h->dfl, PR_MGMT_PORT_SEL, wr_data);
	
	fpgaHssiEnumerateCsr(hssi_h, &csrs, &count);
	fpgaHssiGetLoopbackStatus(hssi_h, channel_num, &loopback_en);
	fpgaHssiGetFreqLockStatus(hssi_h, channel_num, &freq_locked);
	fpgaHssiGetWordLockStatus(hssi_h, channel_num, &word_locked);

	repeat('-', 100);
	printf("%50s\n", "CHANNEL STATISTICS");
	repeat('-', 100);
	printf("%-8s|%-50s|%-20s|%-10s|%-2s\n", "CHANNEL", "LOOPBACK",
		"FREQ LOCK", "WORD LOCK", "TYPE");
	repeat('-', 100);
	printf("%#-8x|%-50d|%-20d|%-10d|%-2s\n", channel_num, loopback_en,
		freq_locked, word_locked, type_str);
	repeat('-', 100);
	printf("%-8s|%-50s|%-20s|%-50s\n", "OFFSET", "NAME", "VALUE",
		"DESCRIPTION");
	repeat('-', 100);
	for (i = 0; i < count; i++) {
		if (csrs[i]->type == type) {
			fpgaHssiReadCsr64(hssi_h, csrs[i], &val);
			printf("%#-8x|%-50s|%#-16lx|%-50s\n", csrs[i]->offset,
				csrs[i]->name, val, csrs[i]->desc);
		}
	}
	return FPGA_OK;
}

fpga_result fpgaHssiClearChannelStats(fpga_hssi_handle hssi,
	hssi_csr_type_t type, uint32_t channel_num)
{
	if (!hssi)
		return FPGA_INVALID_PARAM;

	pr_mgmt_data_t wr_data = {0};
	hssi_csr csr;

	// Select channel
	wr_data.port_sel.port = channel_num;
	prMgmtWrite(hssi->dfl, PR_MGMT_PORT_SEL, wr_data);

	if (type == TX) {
		fpgaHssiFilterCsrByName(hssi, "tx_stats_clr", &csr);

		if (!csr)
			return FPGA_INVALID_PARAM;

		fpgaHssiWriteCsr64(hssi, csr, (uint64_t)1);
	} else if (type == RX) {
		fpgaHssiFilterCsrByName(hssi, "rx_stats_clr", &csr);

		if (!csr)
			return FPGA_INVALID_PARAM;

		fpgaHssiWriteCsr64(hssi, csr, (uint64_t)1);
	} else
		return FPGA_INVALID_PARAM;

	return FPGA_OK;
}
