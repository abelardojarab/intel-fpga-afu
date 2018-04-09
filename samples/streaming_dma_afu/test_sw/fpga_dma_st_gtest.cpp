#include <string.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>
extern "C" {
#include "fpga_dma_st_internal.h"
#include "fpga_dma.h"
}
#include "gtest/gtest.h"
#define DMA_AFU_ID				"EB59BF9D-B211-4A4E-B3E3-753CE68634BA"
#define TEST_BUF_SIZE (20*1024*1024)
#define ASE_TEST_BUF_SIZE (4*1024)

#define RAND() (rand() % 0x7fffffff)
#define RAND_CNT() (rand() % 0x7fffff)
#define random_test_cnt 5
sem_t cb_status;
// Uncomment to enable bandwidth measurement
#define FPGA_DMA_BANDWIDTH_TEST 1
#define DMA_DEBUG 0

// Convenience macros
#ifdef DMA_DEBUG
	#define debug_printk(fmt, ...) \
	do { if (DMA_DEBUG) fprintf(stderr, fmt, ##__VA_ARGS__); } while (0)
#else
	#define debug_printk(...)
#endif

struct timeval start, stop;
double secs = 0;

static int err_cnt=0;
#define ON_ERR(res,label, desc)\
	do {\
		if ((res) != FPGA_OK) {\
			err_cnt++;\
			fprintf(stderr, "Error %s: %s\n", (desc), fpgaErrStr(res));\
			goto label;\
		}\
	} while (0)

/*

TEST CASES:

Sync	Length				Alignment		Test
Async Deterministic(D) 		4CL			async_deterministic_len
Async Non Determistic(ND)	4CL			async_non_deterministic_len
Async Deterministic(D)		4CL			async_deterministic_len_bandwidth
Async Non Determistic(ND)  4CL			async_non_deterministic_len_bandwidth
Async D->ND->ND->D			4CL			random_tf_1
Async ND->D->D->ND->D		4CL			random_tf_2

*/

//class DmaAfuTest : public ::testing::TestWithParam<test_param> {
class DmaAfuTest : public ::testing::Test {
 public:
	fpga_result InitRoutine(){
		int i;
		if(uuid_parse(DMA_AFU_ID, guid) < 0) {
			return (fpga_result)1;
		}
		sem_init(&cb_status, 0, 0);
		res = fpgaGetProperties(NULL, &filter);
		ON_ERR(res, out, "fpgaGetProperties");
		res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
		ON_ERR(res, out, "fpgaPropertiesSetObjectType");
		res = fpgaPropertiesSetGUID(filter, guid);
		ON_ERR(res, out, "fpgaPropertiesSetGUID");
		res = fpgaEnumerate(&filter, 1, &afc_token, 1, &num_matches);
		ON_ERR(res, out, "fpgaEnumerate");
		if(num_matches < 1) {
			ON_ERR(FPGA_INVALID_PARAM, out, "num_matches<1");
			return (fpga_result)err_cnt;
		}
		res = fpgaOpen(afc_token, &afc_h, 0);
		ON_ERR(res, out, "fpgaOpen");

		if(!use_ase) {
			res = fpgaMapMMIO(afc_h, 0, (uint64_t**)&mmio_ptr);
			ON_ERR(res, out, "fpgaMapMMIO");
		}

		// reset AFC
		res = fpgaReset(afc_h);
		ON_ERR(res, out,"fpgaReset");

		// Enumerate DMA handles
		res = fpgaCountDMAChannels(afc_h, &ch_count);
		ON_ERR(res, out, "fpgaGetDMAChannels");

		if(ch_count < 1) {
			printf("Error: DMA channels not found\n");
			ON_ERR(FPGA_INVALID_PARAM, out, "count<1");
		}
		printf("No of DMA channels = %08lx\n", ch_count);

		dma_h = (fpga_dma_handle_t*)malloc(sizeof(fpga_dma_handle_t)*ch_count);

		for(i=0; i<ch_count; i++) {
			res = fpgaDMAOpen(afc_h, i, &dma_h[i]);
			ON_ERR(res, out, "fpgaDMAOpen");
		}

		fpgaDMATransferInit(&rx_transfer);
		fpgaDMATransferInit(&tx_transfer);
	out:
		return (fpga_result)err_cnt;
	}

	virtual void SetUp() {
		ASSERT_EQ(0,InitRoutine());
	}

	fpga_result exitRoutine(){
		int i;
		for(i=0; i<2; i++){
			if(dma_h[i]) {
				res = fpgaDMAClose(dma_h[i]);
				ON_ERR(res, out, "fpgaDmaClose");
			}
		}
		free(dma_h);
		if(!use_ase) {
			res = fpgaUnmapMMIO(afc_h, 0);
			ON_ERR(res, out, "fpgaUnmapMMIO");
		}
		res = fpgaClose(afc_h);
		ON_ERR(res, out, "fpgaClose");
		res = fpgaDestroyToken(&afc_token);
		ON_ERR(res, out, "fpgaDestroyToken");
		res = fpgaDestroyProperties(&filter);
		ON_ERR(res, out, "fpgaDestroyProperties");
	out:
		return (fpga_result)err_cnt;
	}

	virtual void TearDown() {
		ASSERT_EQ(0,exitRoutine());
	}

	void fill_buffer(char *buf, uint32_t size) {
		uint32_t i=0;
		// use a deterministic seed to generate pseudo-random numbers
		srand(99);

		for(i=0; i<size; i++) {
			*buf = rand()%256;
			buf++;
		}
	}

	fpga_result verify_buffer(char *buf, uint32_t size) {
		uint32_t i, rnum=0;
		srand(99);

		for(i=0; i<size; i++) {
			rnum = rand()%256;
			if((*buf&0xFF) != rnum) {
				debug_printk("Invalid data at %d Expected = %x Actual = %x\n",i,rnum,(*buf&0xFF));
				return FPGA_INVALID_PARAM;
			}
			buf++;
		}
		debug_printk("Buffer Verification Success!\n");
		return FPGA_OK;
	}

	void clear_buffer(char *buf, uint32_t size) {
		memset(buf, 0, size);
	}

	fpga_result sendrxTransfer(fpga_dma_handle_t dma_h, fpga_dma_transfer_t rx_transfer, uint64_t src, uint64_t dst, uint64_t tf_len,fpga_dma_transfer_type_t tf_type, fpga_dma_rx_ctrl_t rx_ctrl, fpga_dma_transfer_cb cb) {
		fpga_result res = FPGA_OK;

		fpgaDMATransferSetSrc(rx_transfer, src);
		fpgaDMATransferSetDst(rx_transfer, dst);
		fpgaDMATransferSetLen(rx_transfer, tf_len);
		fpgaDMATransferSetTransferType(rx_transfer, tf_type);
		fpgaDMATransferSetRxControl(rx_transfer, rx_ctrl);
		fpgaDMATransferSetTransferCallback(rx_transfer, cb);
		res = fpgaDMATransfer(dma_h, rx_transfer, (fpga_dma_transfer_cb)&cb, NULL);
		return res;
	}

	fpga_result sendtxTransfer(fpga_dma_handle_t dma_h, fpga_dma_transfer_t tx_transfer, uint64_t src, uint64_t dst, uint64_t tf_len,fpga_dma_transfer_type_t tf_type, fpga_dma_tx_ctrl_t tx_ctrl, fpga_dma_transfer_cb cb) {
		fpga_result res = FPGA_OK;

		fpgaDMATransferSetSrc(tx_transfer, src);
		fpgaDMATransferSetDst(tx_transfer, dst);
		fpgaDMATransferSetLen(tx_transfer, tf_len);
		fpgaDMATransferSetTransferType(tx_transfer, tf_type);
		fpgaDMATransferSetTxControl(tx_transfer, tx_ctrl);
		fpgaDMATransferSetTransferCallback(tx_transfer, cb);
		res = fpgaDMATransfer(dma_h, tx_transfer, (fpga_dma_transfer_cb)&cb, NULL);
		return res;
	}

	// Callback
	static void rxtransferComplete(void *ctx) {
		sem_post(&cb_status);
	}

	static void txtransferComplete(void *ctx) {
		return;
	}

	fpga_result H2F_F2H_NO_PKT(fpga_dma_handle_t dma_h1, fpga_dma_handle_t dma_h2, uint64_t transfer_len){
		uint64_t *dma_tx_buf_ptr = NULL;
		uint64_t *dma_rx_buf_ptr = NULL;

		dma_tx_buf_ptr = (uint64_t*)malloc(transfer_len);
		dma_rx_buf_ptr = (uint64_t*)malloc(transfer_len);
		if(!dma_tx_buf_ptr || !dma_rx_buf_ptr) {
			res = FPGA_NO_MEMORY;
			ON_ERR(res, out, "Error allocating memory");
		}
		fill_buffer((char*)dma_tx_buf_ptr, count);

		// copy from host to fpga
		gettimeofday(&start, NULL);
		// deterministic length transfer
		res = sendrxTransfer(dma_h2, rx_transfer, 0, (uint64_t)dma_rx_buf_ptr, transfer_len, FPGA_ST_TO_HOST_MM, RX_NO_PACKET, rxtransferComplete);
		ON_ERR(res, out, "fpgaDMATransfer");

		res = sendtxTransfer(dma_h1, tx_transfer, (uint64_t)dma_tx_buf_ptr, 0, transfer_len, HOST_MM_TO_FPGA_ST, TX_NO_PACKET, txtransferComplete);
		ON_ERR(res, out, "fpgaDMATransfer");

		sem_wait(&cb_status);
		gettimeofday(&stop, NULL);
		secs = ((double)(stop.tv_usec - start.tv_usec) / 1000000) + (double)(stop.tv_sec - start.tv_sec);
		if(secs>0){
			if(transfer_len == 4*1023*1024*1024l)
			debug_printk("Time taken Host To FPGA - %f s, BandWidth = %f MB/s \n",secs, ((unsigned long long)count/(float)secs/1000000));
		}
		res = verify_buffer((char*)dma_rx_buf_ptr, transfer_len);
		ON_ERR(res, out, "verify_buffer");
		clear_buffer((char*)dma_rx_buf_ptr, transfer_len);

	out:
		free(dma_tx_buf_ptr);
		free(dma_rx_buf_ptr);
		return (fpga_result)err_cnt;
	}

	fpga_result H2F_F2H_EOP(fpga_dma_handle_t dma_h1, fpga_dma_handle_t dma_h2, uint64_t transfer_len){
		uint64_t *dma_tx_buf_ptr = NULL;
		uint64_t *dma_rx_buf_ptr = NULL;

		dma_tx_buf_ptr = (uint64_t*)malloc(transfer_len);
		dma_rx_buf_ptr = (uint64_t*)malloc(transfer_len);
		if(!dma_tx_buf_ptr || !dma_rx_buf_ptr) {
			res = FPGA_NO_MEMORY;
			ON_ERR(res, out, "Error allocating memory");
		}
		fill_buffer((char*)dma_tx_buf_ptr, count);

		// copy from host to fpga
		gettimeofday(&start, NULL);
		// non- deterministic length transfer
		res = sendtxTransfer(dma_h1, tx_transfer, (uint64_t)dma_tx_buf_ptr, 0, transfer_len, HOST_MM_TO_FPGA_ST, GENERATE_EOP, txtransferComplete);
		ON_ERR(res, out, "fpgaDMATransfer");

		res = sendrxTransfer(dma_h2, rx_transfer, 0, (uint64_t)dma_rx_buf_ptr, transfer_len, FPGA_ST_TO_HOST_MM, END_ON_EOP, rxtransferComplete);
		ON_ERR(res, out, "fpgaDMATransfer");

		sem_wait(&cb_status);
		gettimeofday(&stop, NULL);
		secs = ((double)(stop.tv_usec - start.tv_usec) / 1000000) + (double)(stop.tv_sec - start.tv_sec);
		if(secs>0){
			if(transfer_len == 4*1023*1024*1024l)
			debug_printk("Time taken Host To FPGA - %f s, BandWidth = %f MB/s \n",secs, ((unsigned long long)count/(float)secs/1000000));
		}
		res = verify_buffer((char*)dma_rx_buf_ptr, transfer_len);
		ON_ERR(res, out, "verify_buffer");
		clear_buffer((char*)dma_rx_buf_ptr, transfer_len);

	out:
		free(dma_tx_buf_ptr);
		free(dma_rx_buf_ptr);
		return (fpga_result)err_cnt;
	}


	fpga_result res = FPGA_OK;
	fpga_dma_handle_t *dma_h;
	fpga_properties filter = NULL;
	fpga_token afc_token;
	fpga_handle afc_h;
	fpga_guid guid;
	uint32_t num_matches;
	volatile uint64_t *mmio_ptr = NULL;
	uint32_t use_ase=0;
	uint64_t dev_addr1;
	uint64_t dev_addr2;
	uint64_t count;
	uint64_t ch_count=0;
	bool pass;
	fpga_dma_transfer_t rx_transfer;
	fpga_dma_transfer_t tx_transfer;

};


// Async Deterministic Len
TEST_F(DmaAfuTest, async_deterministic_len)
{
	count = 512;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_NO_PKT(dma_h[0], dma_h[1], count));
	err_cnt = 0;
}
//Async Non Deterministic Len
TEST_F(DmaAfuTest, async_non_deterministic_len)
{
	count = 1023*1024*2;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_EOP(dma_h[0], dma_h[1], count));
	err_cnt = 0;
}

// Bandwidth test
#ifdef FPGA_DMA_BANDWIDTH_TEST
TEST_F(DmaAfuTest, async_deterministic_len_bandwidth)
{
	count = 4l*1023l*1024l*1024l;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_NO_PKT(dma_h[0], dma_h[1], count));
	err_cnt = 0;
}

TEST_F(DmaAfuTest, async_non_deterministic_len_bandwidth)
{
	count = 4l*1023l*1024l*1024l;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_EOP(dma_h[0], dma_h[1], count));
	err_cnt = 0;
}

#endif

// Random Test
TEST_F(DmaAfuTest, ramdom_tf_1)
{
	count = 512;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_NO_PKT(dma_h[0], dma_h[1], count));
	count = 1024*1000*35;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_EOP(dma_h[0], dma_h[1], count));
	count = 1023*1024*3;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_EOP(dma_h[0], dma_h[1], count));
	count = 1023*512*13;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_NO_PKT(dma_h[0], dma_h[1], count));
	err_cnt = 0;
}

TEST_F(DmaAfuTest, ramdom_tf_2)
{
	count = 1024*512*15;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_EOP(dma_h[0], dma_h[1], count));
	count = 40*512*4096;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_NO_PKT(dma_h[0], dma_h[1], count));
	count = 1023*512*5;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_NO_PKT(dma_h[0], dma_h[1], count));
	count = 1023*1024*1;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_EOP(dma_h[0], dma_h[1], count));
	count = 1024*512*13;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_EOP(dma_h[0], dma_h[1], count));
	count = 1023*512*5;
	debug_printk("count = %08lx \n", count);
	EXPECT_EQ(0,H2F_F2H_NO_PKT(dma_h[0], dma_h[1], count));
	err_cnt = 0;
}


int main(int argc, char** argv)
{
	testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}
