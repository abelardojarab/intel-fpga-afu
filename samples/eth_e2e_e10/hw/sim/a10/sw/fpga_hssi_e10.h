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

/**
 * \fpga_hssi_e10.h
 * \brief HSSI E10 Internal Header
 *
 */
#ifndef __FPGA_HSSI_E10_H__
#define __FPGA_HSSI_E10_H__

#include "fpga_hssi.h"

#define HSSI_BIT(n) (UINT32_C(1) << (n))
#define PR_READ_CMD  HSSI_BIT(17)
#define PR_WRITE_CMD HSSI_BIT(16)

const struct _hssi_csr e10_csrs[] = {
	// Decribe E10 MAC CSRs
	{0x0C00,
	RX,
	32,
	"rx_stats_clr",
	0,
	RWC,
	"Clear RX stats"},

	{0x1C00,
	TX,
	32,
	"tx_stats_clr",
	0,
	RWC,
	"Clear TX stats"},

	{0x0C01,
	NA,
	32,
	"reserved",
	0,
	RSVD,
	"Reserved"},

	{0x1C01,
	NA,
	32,
	"reserved",
	0,
	RSVD,
	"Reserved"},

	{0x0C02,
	RX,
	36,
	"rx_stats_framesOK",
	0,
	RO,
	"Frames that are successfully recieved"},

	{0x1C02,
	TX,
	36,
	"tx_stats_framesOK",
	0,
	RO,
	"Frames that are successfully transmitted"},

	{0x0C04,
	RX,
	36,
	"rx_stats_framesErr",
	0,
	RO,
	"Frames that are successfully recieved"},

	{0x1C04,
	TX,
	36,
	"tx_stats_framesErr",
	0,
	RO,
	"Frames that are successfully transmitted"},

	{0x0C06,
	RX,
	36,
	"rx_stats_framesCRCErr",
	0,
	RO,
	"RX frames with CRC error"},

	{0x1C06,
	TX,
	36,
	"tx_stats_framesCRCErr",
	0,
	RO,
	"TX frames with CRC error"},

	{0x0C08,
	RX,
	36,
	"rx_stats_octetsOK",
	0,
	RO,
	"Data and padding octets that are successfully received"},

	{0x1C08,
	TX,
	36,
	"tx_stats_octetsOK",
	0,
	RO,
	"Data and padding octets that are successfully transmitted"},

	{0x0C0A,
	RX,
	36,
	"rx_stats_pauseMACCtrl",
	0,
	RO,
	"Number of valid pause frames received"},

	{0x1C0A,
	TX,
	36,
	"tx_stats_pauseMACCtrl",
	0,
	RO,
	"Number of valid pause frames transmitted"},

	{0x0C0C,
	RX,
	36,
	"rx_stats_ifErrors",
	0,
	RO,
	"Number of errored and invalid frames received"},

	{0x1C0C,
	TX,
	36,
	"tx_stats_ifErrors",
	0,
	RO,
	"Number of errored and invalid frames transmitted"},

	{0x0C0E,
	RX,
	36,
	"rx_stats_unicast FramesOK",
	0,
	RO,
	"Number of good unicast frames that are successfully received"},

	{0x1C0E,
	TX,
	36,
	"tx_stats_unicast FramesOK",
	0,
	RO,
	"Number of good unicast frames that are successfully transmitted"},

	{0x0C10,
	RX,
	36,
	"rx_stats_unicast FramesErr",
	0,
	RO,
	"Number of errored unicast frames received"},

	{0x1C10,
	TX,
	36,
	"tx_stats_unicast FramesErr",
	0,
	RO,
	"Number of errored unicast frames transmitted"},

	{0x0C12,
	RX,
	36,
	"rx_stats_multicast FramesOK",
	0,
	RO,
	"Number of good multicast frames received"},

	{0x1C12,
	TX,
	36,
	"tx_stats_multicast FramesOK",
	0,
	RO,
	"Number of good multicast frames transmitted"},

	{0x0C14,
	RX,
	36,
	"rx_stats_multicast FramesErr",
	0,
	RO,
	"Number of errored multicast frames received"},

	{0x1C14,
	TX,
	36,
	"rx_stats_multicast FramesErr",
	0,
	RO,
	"Number of errored multicast frames transmitted"},

	{0x0C16,
	RX,
	36,
	"rx_stats_broadcast FramesOK",
	0,
	RO,
	"Number of good broadcast frames received"},

	{0x1C16,
	TX,
	36,
	"tx_stats_broadcast FramesOK",
	0,
	RO,
	"Number of good broadcast frames transmitted"},

	{0x0C18,
	RX,
	36,
	"rx_stats_broadcast FramesErr",
	0,
	RO,
	"Number of errored broadcast frames received"},

	{0x1C18,
	TX,
	36,
	"tx_stats_broadcast FramesErr",
	0,
	RO,
	"Number of errored broadcast frames transmitted"},

	{0x0C1A,
	RX,
	36,
	"rx_stats_etherStats Octets",
	0,
	RO,
	"Total number of octets received"},

	{0x1C1A,
	TX,
	36,
	"tx_stats_etherStats Octets",
	0,
	RO,
	"Total number of octets transmitted"},

	{0x0C1C,
	RX,
	36,
	"rx_stats_etherStatsPkts",
	0,
	RO,
	"Total number of good, errored, and invalid frames received"},

	{0x1C1C,
	TX,
	36,
	"rx_stats_etherStatsPkts",
	0,
	RO,
	"Total number of good, errored, and invalid frames transmitted"},

	{0x0C1E,
	RX,
	36,
	"rx_stats_etherStats UndersizePkts",
	0,
	RO,
	"Number of undersized frames recieved"},

	{0x1C1E,
	TX,
	36,
	"tx_stats_etherStats UndersizePkts",
	0,
	RO,
	"Number of undersized frames transmitted"},

	{0x0C20,
	RX,
	36,
	"rx_stats_etherStats OversizePkts",
	0,
	RO,
	"Number of oversized frames recieved"},

	{0x1C20,
	TX,
	36,
	"tx_stats_etherStats OversizePkts",
	0,
	RO,
	"Number of oversized frames transmitted"},

	{0x0C22,
	RX,
	36,
	"rx_stats_etherStats Pkts64Octets",
	0,
	RO,
	"Number of 64-byte received frames"},
	{0x1C22,
	TX,
	36,
	"tx_stats_etherStats Pkts64Octets",
	0,
	RO,
	"Number of 64-byte transmitted frames"},

	{0x0C24,
	RX,
	36,
	"rx_stats_etherStats Pkts65to127Octets",
	0,
	RO,
	"Number of receive frames between the length of 65 and 127 bytes"},

	{0x1C24,
	TX,
	36,
	"tx_stats_etherStats Pkts65to127Octets",
	0,
	RO,
	"Number of transmitted frames between the length of 65 and 127 bytes"},

	{0x0C26,
	RX,
	36,
	"rx_stats_etherStats Pkts128to255Octets",
	0,
	RO,
	"Number of receive frames between the length of 128 and 255 bytes"},

	{0x1C26,
	TX,
	36,
	"tx_stats_etherStats Pkts128to255Octets",
	0,
	RO,
	"Number of transmitted frames between the length of 128 and 255 bytes"},

	{0x0C28,
	RX,
	36,
	"rx_stats_etherStats Pkts256to511Octets",
	0,
	RO,
	"Number of receive frames between the length of 256 and 511 bytes"},

	{0x1C28,
	TX,
	36,
	"tx_stats_etherStats Pkts256to511Octets",
	0,
	RO,
	"Number of transmitted frames between the length of 256 and 511 bytes"},

	{0x0C2A,
	RX,
	36,
	"rx_stats_etherStats Pkts512to1023Octets",
	0,
	RO,
	"Number of receive frames between the length of 512 and 1023 bytes"},

	{0x1C2A,
	TX,
	36,
	"tx_stats_etherStats Pkts512to1023Octets",
	0,
	RO,
	"Number of transmitted frames between the "
	"length of 512 and 1023 bytes"},

	{0x0C2C,
	RX,
	36,
	"rx_stats_etherStats Pkts1024to1518Octets",
	0,
	RO,
	"Number of receive frames between the length of 1024 and 1518 bytes"},

	{0x1C2C,
	TX,
	36,
	"tx_stats_etherStats Pkts1024to1518Octets",
	0,
	RO,
	"Number of transmitted frames between "
	"the length of 1024 and 1518 bytes"},

	{0x0C2E,
	RX,
	36,
	"rx_stats_etherStats Pkts1519toXOctets",
	0,
	RO,
	"Number of receive or transmit frames >= 1,519 bytes"},

	{0x1C2E,
	TX,
	36,
	"tx_stats_etherStats Pkts1519toXOctets",
	0,
	RO,
	"Number of receive or receive frames >= 1,519 bytes"},

	{0x0C2E,
	RX,
	36,
	"rx_stats_etherStats Pkts1519toXOctets",
	0,
	RO,
	"Number of receive or transmit frames >= 1,519 bytes"},

	{0x1C2E,
	TX,
	36,
	"tx_stats_etherStats Pkts1519toXOctets",
	0,
	RO,
	"Number of receive or receive frames >= 1,519 bytes"},

	{0x0C30,
	RX,
	36,
	"rx_stats_etherStats Fragments",
	0,
	RO,
	"Number of receive or transmit frames >= 1,519 bytes"},

	{0x1C30,
	TX,
	36,
	"tx_stats_etherStats Fragments",
	0,
	RO,
	"Number of receive or receive frames >= 1,519 bytes"},

	{0x0C32,
	RX,
	36,
	"rx_stats_etherStats Jabbers",
	0,
	RO,
	"Number of oversized receive frames"},

	{0x1C32,
	TX,
	36,
	"tx_stats_etherStats Jabbers",
	0,
	RO,
	"Number of oversized transmit frames"},

	{0x0C34,
	RX,
	36,
	"rx_stats_etherStats CRCErr",
	0,
	RO,
	"Number of receive frames between the length of 64 and "
	"the value configured in the "
	"rx_frame_maxlength register with CRC error"},

	{0x1C34,
	TX,
	36,
	"tx_stats_etherStats CRCErr",
	0,
	RO,
	"Number of transmit frames between the length of 64 and the "
	"value configured in the rx_frame_maxlength register with CRC error"},

	{0x0C36,
	RX,
	36,
	"rx_stats_unicastMAC CtrlFrames",
	0,
	RO,
	"Number of valid unicast control frames received"},

	{0x1C36,
	TX,
	36,
	"tx_stats_unicastMAC CtrlFrames",
	0,
	RO,
	"Number of valid unicast control frames transmitted"},

	{0x0C38,
	RX,
	36,
	"rx_stats_multicastMAC CtrlFrames",
	0,
	RO,
	"Number of valid multicast control frames received"},

	{0x1C38,
	TX,
	36,
	"tx_stats_multicastMAC CtrlFrames",
	0,
	RO,
	"Number of valid multicast control frames transmitted"},

	{0x0C3A,
	RX,
	36,
	"rx_stats_broadcastMAC CtrlFrames",
	0,
	RO,
	"rx_stats_PFCMACCtrlFrames"},

	{0x1C3A,
	TX,
	36,
	"tx_stats_broadcastMAC CtrlFrames",
	0,
	RO,
	"tx_stats_PFCMACCtrlFrames"},

	{0x0C3C,
	RX,
	36,
	"rx_stats_PFCMACCtrlFrames",
	0,
	RO,
	"Number of valid PFC frames received"},

	{0x1C3C,
	TX,
	36,
	"tx_stats_PFCMACCtrlFrames",
	0,
	RO,
	"Number of valid PFC frames transmitted"},

	// Decribe traffic generator CSRs
	{0x03c00,
	NA,
	32,
	"number_of_packets",
	0,
	RW,
	"Number of packets to be transmitted"},

	{0x03c01,
	NA,
	32,
	"random_length",
	0,
	RW,
	"Select what type of packet length:0=fixed, 1=random"},

	{0x03c02,
	NA,
	32,
	"random_payload",
	0,
	RW,
	"Select what type of data pattern:0=incremental, 1=random"},

	{0x03c03,
	NA,
	32,
	"start",
	0,
	RW,
	"Start traffic generation"},

	{0x03c04,
	NA,
	32,
	"stop",
	0,
	RW,
	"Stop traffic generation"},

	{0x03c05,
	NA,
	32,
	"source_addr0",
	0,
	RW,
	"MAC source address 31:0"},

	{0x03c06,
	NA,
	32,
	"source_addr1",
	0,
	RW,
	"MAC source address 47:32"},

	{0x03c07,
	NA,
	32,
	"destination_addr0",
	0,
	RW,
	"MAC destination address 31:0"},

	{0x03c08,
	NA,
	32,
	"destination_addr1",
	0,
	RW,
	"MAC destination address 47:32"},

	{0x03c09,
	NA,
	32,
	"packet_tx_count",
	0,
	RW,
	"Number of transmitted packets"},

	{0x03c0a,
	NA,
	32,
	"rnd_seed0",
	0,
	RW,
	"Seed number for prbs generator [31:0]"},

	{0x03c0b,
	NA,
	32,
	"rnd_seed1",
	0,
	RW,
	"Seed number for prbs generator [63:32]"},

	{0x03c0c,
	NA,
	32,
	"rnd_seed2",
	0,
	RW,
	"Seed number for prbs generator [91:64]"},

	{0x03c0d,
	NA,
	32,
	"pkt_length",
	0,
	RW,
	"Number of succesfully transmitted packets"},

	// Decribe traffic monitor CSRs (TBD mapping address)
	{0x03d00,
	NA,
	32,
	"mac_da0",
	0,
	RW,
	"MAC destination address [31:0]"},

	{0x03d01,
	NA,
	32,
	"mac_da1",
	0,
	RW,
	"MAC destination address [47:32]"},

	{0x03d02,
	NA,
	32,
	"mac_sa0",
	0,
	RW,
	"MAC source address [31:0]"},

	{0x03d03,
	NA,
	32,
	"mac_sa1",
	0,
	RW,
	"MAC destination address [47:32]"},

	{0x03d04,
	NA,
	32,
	"pkt_numb",
	0,
	RW,
	"Number of packets received"},

	{0x03d05,
	NA,
	32,
	"mon_ctrl",
	0,
	RW,
	"Monitor control - continuous (bit 2), \
	stop_reg (bit 1), init_reg (bit 0)"},

	{0x03d06,
	NA,
	32,
	"mon_stat",
	0,
	RW,
	"Monitor status [0] Monitoring completed (Received \
	number of packets), [1] - Destination Address error, \
	[2] - Source Address error, [3] - Packet Length error, \
	[4] - Packet CRC payload error"},

	{0x03d07,
	NA,
	32,
	"pkt_good",
	0,
	RW,
	"Good packets"},

	{0x03d08,
	NA,
	32,
	"pkt_bad",
	0,
	RW,
	"Bad packets"},
};

struct afu_dfl {
	uint64_t afu_dfh_reg;
	uint64_t afu_id_lo;
	uint64_t afu_id_hi;
	uint64_t afu_next;
	uint64_t afu_rsvd;
	uint64_t afu_init;
	uint64_t eth_ctrl_addr;
	uint64_t eth_wr_data;
	uint64_t eth_rd_data;
	uint64_t afu_scratch;
};

struct _fpga_hssi_handle_t {
	fpga_handle fpga_h;
	hssi_csr *csrs;
	size_t csr_cnt;
	struct afu_dfl *dfl;
	volatile uint64_t *mmio_ptr;
};

// PR Managment commands
typedef enum pr_mgmt_cmd {
	PR_MGMT_SCRATCH          = 0x0,
	PR_MGMT_RST              = 0x1,
	PR_MGMT_STATUS           = 0x2,
	PR_MGMT_STATUS_WR_DATA   = 0x3,
	PR_MGMT_STATUS_RD_DATA   = 0x4,
	PR_MGMT_PORT_SEL         = 0x5,
	PR_MGMT_SLOOP            = 0x6,
	PR_MGMT_LOCK_STATUS      = 0x7,
	PR_MGMT_I2C_SEL_WDATA    = 0x8,
	PR_MGMT_I2C_SEL_RDATA    = 0x9,
	PR_MGMT_ETH_CTRL         = 0xa,
	PR_MGMT_ETH_WR_DATA      = 0xb,
	PR_MGMT_ETH_RD_DATA      = 0xc,
	PR_MGMT_ERR_INIT_DONE    = 0xd
} pr_mgmt_cmd_t;

// PR Management Data
// Data is interpreted in HW according to pr_mgmt_cmd
typedef union pr_mgmt_data {
	uint64_t reg;

	uint64_t scratch;

	struct rst {
		uint64_t tx_rst:1;
		uint64_t rx_rst:1;
		uint64_t csr_rst:1;
	} rst;

	struct status {
		uint64_t status_addr:16;
		uint64_t status_wr:1;
		uint64_t status_rd:1;
	} status;

	uint64_t status_wr_data;
	uint64_t status_rd_data;

	struct port_sel {
		uint64_t port:2;
	} port_sel;

	struct lock {
		uint64_t lockedtodata:NUM_ETH_CHANNELS;
		uint64_t blk_lock:NUM_ETH_CHANNELS;
	} lock;

	struct sloop {
		uint64_t loop:NUM_ETH_CHANNELS;
	} sloop;

	struct i2c {
		uint64_t i2c_ctrl_wdata_r:16;
		uint64_t i2c_inst_sel_r:2;
	} i2c;

	uint64_t i2c_rdata;

	struct fatal_err {
		uint64_t f2a_init_done:1;
		uint64_t a2f_fatal_err:1;
	} fatal_err;

} pr_mgmt_data_t;

#endif // __FPGA_HSSI_E10_H__
