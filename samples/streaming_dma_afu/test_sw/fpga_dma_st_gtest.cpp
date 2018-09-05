#include <string.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>
extern "C" {
#include "fpga_dma_st_internal.h"
#include "fpga_dma.h"
#include "fpga_pattern_gen.h"
#include "fpga_pattern_checker.h"
}
#include "gtest/gtest.h"

#define DMA_AFU_ID				"EB59BF9D-B211-4A4E-B3E3-753CE68634BA"
#define TEST_BUF_SIZE (20*1024*1024)
#define ASE_TEST_BUF_SIZE (4*1024)
#define MAX_ST_DMA_CHANNELS 2
// Single pattern is represented as 64Bytes
#define PATTERN_WIDTH_BYTES 64
// No. of Patterns
#define PATTERN_LENGTH 32

#define RAND() (rand() % 0x7fffffff)
#define RAND_CNT() (rand() % 0x7fffff)
#define random_test_cnt 5
// Uncomment to enable bandwidth measurement
//#define FPGA_DMA_BANDWIDTH_TEST 1
#define DMA_DEBUG 0

// Convenience macros
#ifdef DMA_DEBUG
	#define debug_printk(fmt, ...) \
	do { if (DMA_DEBUG) fprintf(stderr, fmt, ##__VA_ARGS__); } while (0)
#else
	#define debug_printk(...)
#endif
static int err_cnt=0;
#define ON_ERR(res,label, desc)\
	do {\
		if ((res) != FPGA_OK) {\
			err_cnt++;\
			fprintf(stderr, "Error %s: %s\n", (desc), fpgaErrStr(res));\
			goto label;\
		}\
	} while (0)
sem_t tx_cb_status;
sem_t rx_cb_status;
struct timeval start, stop;
double secs = 0;
//class DmaAfuTest : public ::testing::TestWithParam<test_param> {
class DmaAfuTest : public ::testing::Test {
public:
	fpga_result res = FPGA_OK;
	fpga_dma_handle_t dma_h[2];
	fpga_dma_channel_type_t ch_type[2];
	fpga_dma_transfer_t transfer[2];

	//fpga_dma_handle_t *dma_h;
	fpga_properties filter = NULL;
	fpga_token afc_token;
	fpga_handle afc_h;
	fpga_guid guid;
	uint32_t num_matches;
	volatile uint64_t *mmio_ptr = NULL;
	uint32_t use_ase = 0;
	uint64_t dev_addr1;
	uint64_t dev_addr2;
	uint64_t count;
	uint64_t ch_count=0;
	bool pass;
	int pkt_transfer=0;
	fpga_dma_transfer_t rx_transfer;
	fpga_dma_transfer_t tx_transfer;
	pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
		
	struct tf_info {
		fpga_dma_handle_t tx_dma;
		fpga_dma_handle_t rx_dma;
		fpga_dma_transfer_cb tx_callbk;
		fpga_dma_transfer_cb rx_callbk;
		fpga_dma_transfer_t tx_transfer;
		fpga_dma_transfer_t rx_transfer;
		int tx_ch_no;
		int rx_ch_no;
	};
	tf_info tf;

	fpga_result InitRoutine(){
		int i;
		if(uuid_parse(DMA_AFU_ID, guid) < 0) {
			return (fpga_result)1;
		}
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
	out:
		return (fpga_result)err_cnt;
	}

	virtual void SetUp() {
		ASSERT_EQ(0,InitRoutine());
	}

	fpga_result exitRoutine(){
		int i;
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

	//Populate repeating pattern 0x00...0xFF of payload size
	static void fill_buffer(unsigned char *buf, size_t payload_size) {
		size_t i,j;
		unsigned char test_word = 0;
		while(payload_size) {
			test_word = 0x00;
			for (i = 0; i < PATTERN_LENGTH; i++) {
				for (j = 0; j < (PATTERN_WIDTH/sizeof(test_word)); j++) {
				if(!payload_size)
					return;
					*buf = test_word;
					payload_size -= sizeof(test_word);
					buf++;
					test_word += 0x01;
				}
			}
		}
	}
	
	//Verify repeating pattern 0x00...0xFF of payload size	
	fpga_result verify_buffer(unsigned char *buf, size_t payload_size) {
		size_t i,j;
		unsigned char test_word = 0;
		while(payload_size) {
			test_word = 0x00;
			for (i = 0; i < PATTERN_LENGTH; i++) {
				for (j = 0; j < (PATTERN_WIDTH/sizeof(test_word)); j++) {
					if(!payload_size)
						goto out;
					if((*buf) != test_word) {
						printf("Invalid data at %zx Expected = %x Actual = %x\n",i,test_word,(*buf));
						return FPGA_INVALID_PARAM;
					}
					payload_size -= sizeof(test_word);
					buf++;
					test_word += 0x01;
				}
			}
		}
	out:
		printf("S2M: Data Verification Success!\n");
		return FPGA_OK;
	}
		
	void clear_buffer(char *buf, uint64_t size) {
		memset(buf, 0, size);
	}

	fpga_result sendrxTransfer(fpga_dma_handle_t dma_h, fpga_dma_transfer_t rx_transfer, uint64_t src, uint64_t dst, uint64_t tf_len,fpga_dma_transfer_type_t tf_type, fpga_dma_rx_ctrl_t rx_ctrl, fpga_dma_transfer_cb cb) {
		fpga_result res = FPGA_OK;
		fpgaDMATransferSetSrc(rx_transfer, src);
		fpgaDMATransferSetDst(rx_transfer, dst);
		fpgaDMATransferSetLen(rx_transfer, tf_len);
		fpgaDMATransferSetTransferType(rx_transfer, tf_type);
		fpgaDMATransferSetRxControl(rx_transfer, rx_ctrl);
		fpgaDMATransferSetTransferCallback(rx_transfer, cb, NULL);
		res = fpgaDMATransfer(dma_h, rx_transfer);
		return res;
	}

	fpga_result sendtxTransfer(fpga_dma_handle_t dma_h, fpga_dma_transfer_t tx_transfer, uint64_t src, uint64_t dst, uint64_t tf_len,fpga_dma_transfer_type_t tf_type, fpga_dma_tx_ctrl_t tx_ctrl, fpga_dma_transfer_cb cb) {
		fpga_result res = FPGA_OK;

		fpgaDMATransferSetSrc(tx_transfer, src);
		fpgaDMATransferSetDst(tx_transfer, dst);
		fpgaDMATransferSetLen(tx_transfer, tf_len);
		fpgaDMATransferSetTransferType(tx_transfer, tf_type);
		fpgaDMATransferSetTxControl(tx_transfer, tx_ctrl);
		fpgaDMATransferSetTransferCallback(tx_transfer, cb, NULL);
		res = fpgaDMATransfer(dma_h, tx_transfer);
		return res;
	}

	// Callback
	static void rxtransferComplete(void *ctx) {
		sem_post(&rx_cb_status);
	}

	static void rxtransferComplete_dummy(void *ctx) {
	}

	static void txtransferComplete(void *ctx) {
		sem_post(&tx_cb_status);
	}

	fpga_result M2S_transfer(fpga_dma_handle_t dma_h, fpga_dma_transfer_t tx_transfer, uint64_t transfer_len, int pkt_transfer, fpga_dma_transfer_cb cb){
		pthread_mutex_lock(&mutex);
		uint64_t *dma_tx_buf_ptr = NULL;

		dma_tx_buf_ptr = (uint64_t*)malloc(transfer_len);
		if(!dma_tx_buf_ptr) {
			res = FPGA_NO_MEMORY;
			ON_ERR(res, out, "Error allocating memory");
		}
		fill_buffer((unsigned char *)dma_tx_buf_ptr, transfer_len);

		// copy from host to fpga
		res = populate_pattern_checker(dma_h->fpga_h);
		ON_ERR(res, out, "populate_pattern_checker");

		res = stop_checker(dma_h->fpga_h);
		ON_ERR(res, out, "stop_checker");

		res = start_checker(dma_h->fpga_h, transfer_len);
		ON_ERR(res, out, "start checker");

		gettimeofday(&start, NULL);
		if(pkt_transfer == 1)
			res = sendtxTransfer(dma_h, tx_transfer, (uint64_t)dma_tx_buf_ptr, 0, transfer_len, HOST_MM_TO_FPGA_ST, GENERATE_EOP, cb);
		else
			res = sendtxTransfer(dma_h, tx_transfer, (uint64_t)dma_tx_buf_ptr, 0, transfer_len, HOST_MM_TO_FPGA_ST, TX_NO_PACKET, cb);
		ON_ERR(res, out, "sendtxTransfer");
		if(cb)
			sem_wait(&tx_cb_status);
		res = wait_for_checker_complete(dma_h->fpga_h);
		ON_ERR(res, out, "wait_for_checker_complete");
		gettimeofday(&stop, NULL);
		secs = ((double)(stop.tv_usec - start.tv_usec) / 1000000) + (double)(stop.tv_sec - start.tv_sec);
		if(secs>0){
			if(transfer_len == 4*1023*1024*1024l)
			debug_printk("Time taken Host To FPGA - %f s, BandWidth = %f MB/s \n",secs, ((unsigned long long)transfer_len/(float)secs/1000000));
		}
		res = stop_checker(dma_h->fpga_h);
		ON_ERR(res, out, "stop_checker");
	out:
		free(dma_tx_buf_ptr);
		pthread_mutex_unlock(&mutex);
		return (fpga_result)err_cnt;
	}

	fpga_result S2M_transfer(fpga_dma_handle_t dma_h, fpga_dma_transfer_t rx_transfer, uint64_t transfer_len, int pkt_transfer, fpga_dma_transfer_cb cb){
		pthread_mutex_lock(&mutex);	
		uint64_t *dma_rx_buf_ptr = NULL;

		dma_rx_buf_ptr = (uint64_t*)malloc(transfer_len);
		if(!dma_rx_buf_ptr) {
			res = FPGA_NO_MEMORY;
			ON_ERR(res, out, "Error allocating memory");
		}
		gettimeofday(&start, NULL);
		res = populate_pattern_generator(dma_h->fpga_h);
		ON_ERR(res, out, "populate_pattern_generator");

		res = stop_generator(dma_h->fpga_h);
		ON_ERR(res, out, "stop generator");

		res = start_generator(dma_h->fpga_h, transfer_len, pkt_transfer/*Not PACKET TRANSFER*/);
		ON_ERR(res, out, "start pattern generator");
		if(pkt_transfer == 1){
			res = sendrxTransfer(dma_h, rx_transfer, 0, (uint64_t)dma_rx_buf_ptr, transfer_len, FPGA_ST_TO_HOST_MM, END_ON_EOP, cb);
		} else {
			res = sendrxTransfer(dma_h, rx_transfer, 0, (uint64_t)dma_rx_buf_ptr, transfer_len, FPGA_ST_TO_HOST_MM, RX_NO_PACKET, cb);
		}
		ON_ERR(res, out, "fpgaDMATransfer");

		res = wait_for_generator_complete(dma_h->fpga_h);
		ON_ERR(res, out, "wait_for_generator_complete");
		if(cb)
			sem_wait(&rx_cb_status);
		gettimeofday(&stop, NULL);
		secs = ((double)(stop.tv_usec - start.tv_usec) / 1000000) + (double)(stop.tv_sec - start.tv_sec);
		if(secs>0){
			if(transfer_len == 4*1023*1024*1024l)
			debug_printk("Time taken Host To FPGA - %f s, BandWidth = %f MB/s \n",secs, ((unsigned long long)transfer_len/(float)secs/1000000));
		}
		res = verify_buffer((unsigned char *)dma_rx_buf_ptr, transfer_len);
		ON_ERR(res, out, "verify_buffer");
		clear_buffer((char*)dma_rx_buf_ptr, transfer_len);
		res = stop_generator(dma_h->fpga_h);
		ON_ERR(res, out, "stop generator");
	out:
		free(dma_rx_buf_ptr);
		pthread_mutex_unlock(&mutex);
		return (fpga_result)err_cnt;
	}

	uint64_t single_tf_length;
	uint64_t cnt_left;
	fpga_result S2M_multiple_transfer(fpga_dma_handle_t dma_h, fpga_dma_transfer_t rx_transfer, uint64_t transfer_len, int pkt_transfer, fpga_dma_transfer_cb cb, int tf_cnt){

		uint64_t *dma_rx_buf_ptr = NULL;
		int i;
		// Divide single transfer into tf_cnt chunks
		single_tf_length = transfer_len/tf_cnt;
		// Round down the single transfer size to be multiple of 64
		single_tf_length = (single_tf_length/64)*64;
		// Left over count
		cnt_left = transfer_len - tf_cnt*(single_tf_length);
		
		dma_rx_buf_ptr = (uint64_t*)malloc(transfer_len);
		if(!dma_rx_buf_ptr) {
			res = FPGA_NO_MEMORY;
			ON_ERR(res, out, "Error allocating memory");
		}
		gettimeofday(&start, NULL);
		res = populate_pattern_generator(dma_h->fpga_h);
		ON_ERR(res, out, "populate_pattern_generator");

		res = stop_generator(dma_h->fpga_h);
		ON_ERR(res, out, "stop generator");

		res = start_generator(dma_h->fpga_h, transfer_len, pkt_transfer/*Not PACKET TRANSFER*/);
		ON_ERR(res, out, "start pattern generator");
		for (i =0; i < tf_cnt; i++) {
			if(pkt_transfer == 1 && i == (tf_cnt-1) && cnt_left == 0){
				res = sendrxTransfer(dma_h, rx_transfer, 0, (uint64_t)dma_rx_buf_ptr+(i*single_tf_length), single_tf_length, FPGA_ST_TO_HOST_MM, END_ON_EOP, cb);
			} else {
				res = sendrxTransfer(dma_h, rx_transfer, 0, (uint64_t)dma_rx_buf_ptr+(i*single_tf_length), single_tf_length, FPGA_ST_TO_HOST_MM, RX_NO_PACKET, rxtransferComplete_dummy);
			}
			ON_ERR(res, out, "fpgaDMATransfer");
		}

		if(cnt_left && pkt_transfer == 1){
			res = sendrxTransfer(dma_h, rx_transfer, 0, (uint64_t)dma_rx_buf_ptr+(i*single_tf_length), cnt_left, FPGA_ST_TO_HOST_MM, END_ON_EOP, cb);
		}

		res = wait_for_generator_complete(dma_h->fpga_h);
		ON_ERR(res, out, "wait_for_generator_complete");

		if(cb && i == tf_cnt)
		 sem_wait(&rx_cb_status);
		gettimeofday(&stop, NULL);
		secs = ((double)(stop.tv_usec - start.tv_usec) / 1000000) + (double)(stop.tv_sec - start.tv_sec);
		if(secs>0){
			if(transfer_len == 4*1023*1024*1024l)
		 debug_printk("Time taken Host To FPGA - %f s, BandWidth = %f MB/s \n",secs, ((unsigned long long)transfer_len/(float)secs/1000000));
		}
		res = verify_buffer((unsigned char *)dma_rx_buf_ptr, transfer_len);
		ON_ERR(res, out, "verify_buffer");
		clear_buffer((char*)dma_rx_buf_ptr, transfer_len);
		res = stop_generator(dma_h->fpga_h);
		ON_ERR(res, out, "stop generator");
	out:
		free(dma_rx_buf_ptr);

		return (fpga_result)err_cnt;
	}
	
};

class TestTransferLength : public DmaAfuTest, public ::testing::WithParamInterface<int> {
};

const int test_generation_params[] = {64, 128, 192, 256};
INSTANTIATE_TEST_CASE_P(AlignmentTest, TestTransferLength, ::testing::ValuesIn(test_generation_params));

void *initiate_tx_tf(void* arg) {
	fpga_result res = FPGA_OK;
	DmaAfuTest *tx_this = static_cast<DmaAfuTest *>(arg);
	for(int x=0; x < 100; x++) {
		res=tx_this->M2S_transfer(tx_this->tf.tx_dma, tx_this->tf.tx_transfer, 4096, 1, tx_this->tf.tx_callbk);
		ON_ERR(res, out, "initiate_tf");
	}
out:
	pthread_exit(0);
}

void *initiate_rx_tf(void* arg) {
	fpga_result res = FPGA_OK;
	DmaAfuTest *rx_this = static_cast<DmaAfuTest *>(arg);
	for(int x=0; x < 100; x++) {
		res=rx_this->S2M_transfer(rx_this->tf.rx_dma, rx_this->tf.rx_transfer, 4096, 1, rx_this->tf.rx_callbk);
		ON_ERR(res, out, "initiate_tf");
	}
out:
	pthread_exit(0);
}

void *initiate_random_rx_tf_threadA(void* arg) {
	fpga_result res = FPGA_OK;
	DmaAfuTest *rx_this = static_cast<DmaAfuTest *>(arg);
	int count;
	for(int x=0; x < 100; x++) {
	srand(time(0)+x);
	count = (uint64_t)RAND_CNT();
	if(count % 4 != 0)
		count = ((count/4)+1)*4;	
		res=rx_this->S2M_transfer(rx_this->tf.rx_dma, rx_this->tf.rx_transfer, count, 1, rx_this->tf.rx_callbk);
		ON_ERR(res, out, "initiate_tf");
	}
out:
	pthread_exit(0);
}

void *initiate_random_tx_tf_threadA(void* arg) {
fpga_result res = FPGA_OK;
DmaAfuTest *tx_this = static_cast<DmaAfuTest *>(arg);
int count;
for(int x=0; x < 100; x++) {
	srand(time(0)+x);
	count = (uint64_t)RAND_CNT();
	if(count % 4 != 0)
	count = ((count/4)+1)*4;
	res=tx_this->M2S_transfer(tx_this->tf.tx_dma, tx_this->tf.tx_transfer, count, 1, tx_this->tf.tx_callbk);
	ON_ERR(res, out, "initiate_tf");
}
out:
	pthread_exit(0);
}

void *initiate_random_rx_tf_threadB(void* arg) {
	fpga_result res = FPGA_OK;
	DmaAfuTest *rx_this = static_cast<DmaAfuTest *>(arg);
	int count;
	for(int x=0; x < 100; x++) {
		srand(time(0)+x);
		count = (uint64_t)RAND_CNT();
		if(count % 4 != 0)
		count = ((count/4)+1)*4;
		res=rx_this->S2M_transfer(rx_this->tf.rx_dma, rx_this->tf.rx_transfer, count, 1, rx_this->tf.rx_callbk);
		ON_ERR(res, out, "initiate_tf");
	}
out:
	pthread_exit(0);
}

void *initiate_random_tx_tf_threadB(void* arg) {
	fpga_result res = FPGA_OK;
	DmaAfuTest *tx_this = static_cast<DmaAfuTest *>(arg);
	int count;
	for(int x=0; x < 100; x++) {
		srand(time(0)+x);
		count = (uint64_t)RAND_CNT();
		if(count % 4 != 0)
		 count = ((count/4)+1)*4;
		res=tx_this->M2S_transfer(tx_this->tf.tx_dma, tx_this->tf.tx_transfer, count, 1, tx_this->tf.tx_callbk);
		ON_ERR(res, out, "initiate_tf");
	}
out:
	pthread_exit(0);
}

// fpgaCountDMAChannels
TEST_F(DmaAfuTest, fpgaCountDMAChannels_InvalidFpgaHandle)
{
	uint64_t count;
	ASSERT_EQ(fpgaCountDMAChannels(NULL, &count), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaCountDMAChannels_InvalidCount)
{
	ASSERT_EQ(fpgaCountDMAChannels(afc_h, NULL), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaCountDMAChannels_ValidCount)
{
	uint64_t count = 0;
	ASSERT_EQ(fpgaCountDMAChannels(afc_h, &count), FPGA_OK);
	ASSERT_EQ(count, 2);
}

// fpgaDMAOpen
TEST_F(DmaAfuTest, fpgaDMAOpen_InvalidFpgaHandle)
{
	ASSERT_EQ(fpgaDMAOpen(NULL, 0, &dma_h[0]), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaDMAOpen_InvalidPtrToDmaHandle)
{
	ASSERT_EQ(fpgaDMAOpen(afc_h, 0, NULL), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaDMAOpen_IndexOutOfRange)
{
	uint64_t count = 0;

	EXPECT_EQ(fpgaCountDMAChannels(afc_h, &count), FPGA_OK);
	EXPECT_EQ(count, 2);

	ASSERT_EQ(fpgaDMAOpen(afc_h, count+1, &dma_h[0]), FPGA_NOT_FOUND);
}

// fpgaDMAClose
TEST_F(DmaAfuTest, fpgaDmaClose_InvalidDmaHandle)
{
	ASSERT_EQ(fpgaDMAClose(NULL), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaDmaClose_ValidDmaHandle)
{
	// fpgaDmaClose(valid_dma_h) must return FPGA_OK
	EXPECT_EQ(fpgaDMAOpen(afc_h, 0, &dma_h[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMAClose(dma_h[0]), FPGA_OK);
}

// fpgaGetDMAChannelType
TEST_F(DmaAfuTest, fpgaGetDMAChannelType_InvalidDmaHandle)
{
	ASSERT_EQ(fpgaGetDMAChannelType(NULL, &ch_type[0]), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaGetDMAChannelType_InvalidPtrToChannel)
{
	EXPECT_EQ(fpgaDMAOpen(afc_h, 0, &dma_h[0]), FPGA_OK);
	ASSERT_EQ(fpgaGetDMAChannelType(dma_h[0], NULL), FPGA_INVALID_PARAM);
	EXPECT_EQ(fpgaDMAClose(dma_h[0]), FPGA_OK);
}

TEST_F(DmaAfuTest, fpgaGetDMAChannelType_ValidTX)
{
	EXPECT_EQ(fpgaDMAOpen(afc_h, 0, &dma_h[0]), FPGA_OK);
	EXPECT_EQ(fpgaGetDMAChannelType(dma_h[0], &ch_type[0]), FPGA_OK);
	ASSERT_EQ(ch_type[0], TX_ST);
	EXPECT_EQ(fpgaDMAClose(dma_h[0]), FPGA_OK);
}

TEST_F(DmaAfuTest, fpgaGetDMAChannelType_ValidRX)
{
	EXPECT_EQ(fpgaDMAOpen(afc_h, 1, &dma_h[1]), FPGA_OK);
	EXPECT_EQ(fpgaGetDMAChannelType(dma_h[1], &ch_type[1]), FPGA_OK);
	ASSERT_EQ(ch_type[1], RX_ST);
	EXPECT_EQ(fpgaDMAClose(dma_h[1]), FPGA_OK);
}

// fpgaDMATransferInit
TEST_F(DmaAfuTest, fpgaDMATransferInit_InvalidPtrToTransfer)
{
	ASSERT_EQ(fpgaDMATransferInit(NULL), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaDMATransferInit_ValidPtrToTransfer)
{
	ASSERT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
}

// fpgaDMATransferDestroy
TEST_F(DmaAfuTest, fpgaDMATransferDestroy_InvalidTransfer)
{
	ASSERT_EQ(fpgaDMATransferDestroy(NULL), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaDMATransferDestroy_ValidTransfer)
{
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);

}

// fpgaDMATransferSetSrc
TEST_F(DmaAfuTest, fpgaDMATransferSetSrc_InvalidTransfer)
{
	ASSERT_EQ(fpgaDMATransferSetSrc(NULL, 0x0), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaDMATransferSetSrc_ValidTransfer)
{
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetSrc(transfer[0], 0x0), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
}	

// fpgaDMATransferSetDst
TEST_F(DmaAfuTest, fpgaDMATransferSetDst_InvalidTransfer)
{
	ASSERT_EQ(fpgaDMATransferSetDst(NULL, 0x0), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaDMATransferSetDst_ValidTransfer)
{
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetDst(transfer[0], 0x0), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
}

// fpgaDMATransferSetLen
TEST_F(DmaAfuTest, fpgaDMATransferSetLen_InvalidTransfer)
{
	ASSERT_EQ(fpgaDMATransferSetLen(NULL, 64), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaDMATransferSetLen_ValidTransfer)
{
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetLen(transfer[0], 64), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);

}

// fpgaDMATransferSetTransferType
TEST_F(DmaAfuTest, fpgaDMATransferSetTransferType_InvalidTransfer)
{
	ASSERT_EQ(fpgaDMATransferSetTransferType(NULL, HOST_MM_TO_FPGA_ST), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaDMATransferSetTransferType_InvalidTransferType)
{
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetTransferType(transfer[0], FPGA_MAX_TRANSFER_TYPE), FPGA_INVALID_PARAM);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
}

TEST_F(DmaAfuTest, fpgaDMATransferSetTransferType_ValidTransfer)
{
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetTransferType(transfer[0], HOST_MM_TO_FPGA_ST), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetTransferType(transfer[0], FPGA_ST_TO_HOST_MM), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetTransferType(transfer[0], FPGA_MM_TO_FPGA_ST), FPGA_NOT_SUPPORTED);
	ASSERT_EQ(fpgaDMATransferSetTransferType(transfer[0], FPGA_ST_TO_FPGA_MM), FPGA_NOT_SUPPORTED);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
}

// fpgaDMATransferSetTxControl
TEST_F(DmaAfuTest, fpgaDMATransferSetTxControl_InvalidTransfer)
{
	ASSERT_EQ(fpgaDMATransferSetTxControl(NULL, TX_NO_PACKET), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaDMATransferSetTxControl_InvalidTxCtrl)
{
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetTxControl(transfer[0], FPGA_MAX_TX_CTRL), FPGA_INVALID_PARAM);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
}

TEST_F(DmaAfuTest, fpgaDMATransferSetTxControl_ValidTransfer)
{
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetTxControl(transfer[0], TX_NO_PACKET), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetTxControl(transfer[0], GENERATE_SOP), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetTxControl(transfer[0], GENERATE_EOP), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetTxControl(transfer[0], GENERATE_SOP_AND_EOP), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
}

// fpgaDMATransferSetRxControl
TEST_F(DmaAfuTest, fpgaDMATransferSetRxControl_InvalidTransfer)
{
	ASSERT_EQ(fpgaDMATransferSetRxControl(NULL, RX_NO_PACKET), FPGA_INVALID_PARAM);
}

TEST_F(DmaAfuTest, fpgaDMATransferSetRxControl_InvalidRxCtrl)
{
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetRxControl(transfer[0], FPGA_MAX_RX_CTRL), FPGA_INVALID_PARAM);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
}

TEST_F(DmaAfuTest, fpgaDMATransferSetRxControl_ValidTransfer)
{
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetRxControl(transfer[0], RX_NO_PACKET), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetRxControl(transfer[0], END_ON_EOP), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
}

// fpgaDMATransferSetTransferCallback
TEST_F(DmaAfuTest, fpgaDMATransferSetTransferCallback_InvalidTransfer)
{
	ASSERT_EQ(fpgaDMATransferSetTransferCallback(NULL, NULL, NULL), FPGA_INVALID_PARAM);	
}

TEST_F(DmaAfuTest, fpgaDMATransferSetTransferCallback_ValidTransfer)
{
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransferSetTransferCallback(transfer[0], rxtransferComplete, NULL), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);	
}

// fpgaDMATransfer
TEST_F(DmaAfuTest, fpgaDMATransfer_nullDMAHandle)
{
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransfer(NULL/*dma_h*/, transfer[0]), FPGA_INVALID_PARAM);	
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
}

TEST_F(DmaAfuTest, fpgaDMATransfer_InvalidTransfer)
{
	EXPECT_EQ(fpgaDMAOpen(afc_h, 0, &dma_h[0]), FPGA_OK);
	ASSERT_EQ(fpgaDMATransfer(dma_h[0], NULL), FPGA_INVALID_PARAM);	
	EXPECT_EQ(fpgaDMAClose(dma_h[0]), FPGA_OK);
}

TEST_F(DmaAfuTest, fpgaDMATransfer_InvalidTransferType)
{
	for (int i=0; i < 2; i++) {
		EXPECT_EQ(fpgaDMAOpen(afc_h, i, &dma_h[i]), FPGA_OK);
		EXPECT_EQ(fpgaDMATransferInit(&transfer[i]), FPGA_OK);	
		EXPECT_EQ(fpgaGetDMAChannelType(dma_h[i], &ch_type[i]), FPGA_OK);
		if(ch_type[i] == TX_ST) {
			// try to force FPGA_ST_TO_HOST_MM on TX channel
			EXPECT_EQ(fpgaDMATransferSetTransferType(transfer[i], FPGA_ST_TO_HOST_MM), FPGA_OK);
			EXPECT_EQ(fpgaDMATransferSetTransferCallback(transfer[i], NULL, NULL), FPGA_OK);
			ASSERT_EQ(fpgaDMATransfer(dma_h[i], transfer[i]), FPGA_INVALID_PARAM);	
		}
		if(ch_type[i] == RX_ST) {
			// try to force HOST_MM_TO_FPGA_ST on RX channel
			EXPECT_EQ(fpgaDMATransferSetTransferType(transfer[i], HOST_MM_TO_FPGA_ST), FPGA_OK);
			EXPECT_EQ(fpgaDMATransferSetTransferCallback(transfer[i], NULL, NULL), FPGA_OK);
			ASSERT_EQ(fpgaDMATransfer(dma_h[i], transfer[i]), FPGA_INVALID_PARAM);	
		}

		EXPECT_EQ(fpgaDMATransferDestroy(transfer[i]), FPGA_OK);
		EXPECT_EQ(fpgaDMAClose(dma_h[i]), FPGA_OK);
	}
}

TEST_P(TestTransferLength, fpgaDMATransfer_ValidLen)
{
	// Deterministic DMA transfer must pass for all valid transfer types 
	// where length is < 1CL, 1CL, 2CL, 3CL and 4CL and any multiple of those lengths +- < 1CL
	for (int i=0; i < 2; i++) {
		EXPECT_EQ(fpgaDMAOpen(afc_h, i, &dma_h[i]), FPGA_OK);
		EXPECT_EQ(fpgaGetDMAChannelType(dma_h[i], &ch_type[i]), FPGA_OK);
		EXPECT_EQ(fpgaDMATransferInit(&transfer[i]), FPGA_OK);
		count = GetParam();
		pkt_transfer = 0;
		if(ch_type[i] == TX_ST)
			EXPECT_EQ(M2S_transfer(dma_h[i], transfer[i], count, pkt_transfer, NULL), FPGA_OK);
		else if (ch_type[i] == RX_ST) {
			EXPECT_EQ(S2M_transfer(dma_h[i], transfer[i], count, pkt_transfer, NULL), FPGA_OK);
		}
		EXPECT_EQ(fpgaDMATransferDestroy(transfer[i]), FPGA_OK);
		err_cnt = 0;
	}
	EXPECT_EQ(fpgaDMAClose(dma_h[0]), FPGA_OK);
	EXPECT_EQ(fpgaDMAClose(dma_h[1]), FPGA_OK);
}

TEST_F(DmaAfuTest, fpgaDMATransfer_M2SBasicDeterministic)
{	
	// fpgaDMATransfer for any transfer type must return only after completion of the transfer if cb is set to NULL
	EXPECT_EQ(fpgaDMAOpen(afc_h, 0, &dma_h[0]), FPGA_OK);
	count = 20*1024*1024;
	debug_printk("count = %08lx \n", count);
	pkt_transfer = 0;
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	EXPECT_EQ(M2S_transfer(dma_h[0], transfer[0], count, pkt_transfer, NULL), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
	EXPECT_EQ(fpgaDMAClose(dma_h[0]), FPGA_OK);
	err_cnt = 0;
}

TEST_F(DmaAfuTest, fpgaDMATransfer_M2SStressDeterministic)
{	
	// Issue 10,000 deterministic length fpgaDMATransfer with randomized packet length
	EXPECT_EQ(fpgaDMAOpen(afc_h, 0, &dma_h[0]), FPGA_OK);
	for(int i=0; i<100; i++) {
		srand(time(0)+i);
		count = (uint64_t)RAND_CNT();
		// Round to next 64 byte
		if(count % 64 != 0)
			count = ((count/64)+1)*64;
		debug_printk("count = %08lx \n", count);
		pkt_transfer = 0;
		EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
		EXPECT_EQ(M2S_transfer(dma_h[0], transfer[0], count, pkt_transfer, NULL), FPGA_OK);
		EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
	}
	EXPECT_EQ(fpgaDMAClose(dma_h[0]), FPGA_OK);
	err_cnt = 0;
}

TEST_F(DmaAfuTest, fpgaDMATransfer_M2SBasicNonDeterministic)
{
	// fpgaDMATransfer for any transfer type must return immediately if cb is not set to NULL. Cb must get called
	EXPECT_EQ(fpgaDMAOpen(afc_h, 0, &dma_h[0]), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	count = 15*1024*1024;
	debug_printk("count = %08lx \n", count);
	pkt_transfer = 1;
	EXPECT_EQ(M2S_transfer(dma_h[0], transfer[0], count, pkt_transfer, txtransferComplete), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
	EXPECT_EQ(fpgaDMAClose(dma_h[0]), FPGA_OK);
	err_cnt = 0;
}

TEST_F(DmaAfuTest, fpgaDMATransfer_M2SStressNonDeterministicOnSameTransfer)
{
	// Issue 10,000 non-deterministic length fpgaDMATransfer using the same transfer object, EOP set at random lengths   
	// This test will also verify transfer attributes can be correctly manipulated
	EXPECT_EQ(fpgaDMAOpen(afc_h, 0, &dma_h[0]), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferInit(&transfer[0]), FPGA_OK);
	for(int i=0; i<10; i++) {
		srand(time(0)+i);
		count = (uint64_t)RAND_CNT();
		if(count % 4 != 0)
			count = ((count/4)+1)*4;
		debug_printk("count = %08lx \n", count);
		pkt_transfer = 1;
		EXPECT_EQ(M2S_transfer(dma_h[0], transfer[0],count, pkt_transfer, txtransferComplete), FPGA_OK);
	}
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[0]), FPGA_OK);
	EXPECT_EQ(fpgaDMAClose(dma_h[0]), FPGA_OK);
	err_cnt = 0;
}

TEST_F(DmaAfuTest, fpgaDMATransfer_S2MBasicDeterministic)
{
	// fpgaDMATransfer for any transfer type must return only after completion of the transfer if cb is set to NULL
	EXPECT_EQ(fpgaDMAOpen(afc_h, 1, &dma_h[1]), FPGA_OK);
	count = 10*1024*1024;
	debug_printk("count = %08lx \n", count);
	pkt_transfer = 0;
	EXPECT_EQ(fpgaDMATransferInit(&transfer[1]), FPGA_OK);
	EXPECT_EQ(S2M_transfer(dma_h[1], transfer[1], count, pkt_transfer, NULL), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[1]), FPGA_OK);
	EXPECT_EQ(fpgaDMAClose(dma_h[1]), FPGA_OK);
	err_cnt = 0;
}

TEST_F(DmaAfuTest, fpgaDMATransfer_S2MBasicNonDeterministic)
{
	// fpgaDMATransfer for any transfer type must return immediately if cb is not set to NULL. Cb must get called
	EXPECT_EQ(fpgaDMAOpen(afc_h, 1, &dma_h[1]), FPGA_OK);
	count = 15*1024*1024;
	debug_printk("count = %08lx \n", count);
	pkt_transfer = 1;
	EXPECT_EQ(fpgaDMATransferInit(&transfer[1]), FPGA_OK);
	EXPECT_EQ(S2M_transfer(dma_h[1], transfer[1], count, pkt_transfer, rxtransferComplete), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[1]), FPGA_OK);
	EXPECT_EQ(fpgaDMAClose(dma_h[1]), FPGA_OK);
	err_cnt = 0;
}

TEST_F(DmaAfuTest, fpgaDMATransfer_S2MStressDeterministic)
{
	// Issue 10,000 deterministic length fpgaDMATransfer with randomized packet length
	EXPECT_EQ(fpgaDMAOpen(afc_h, 1, &dma_h[1]), FPGA_OK);
	for(int i=0; i<100; i++) {
		srand(time(0)+i);
		count = (uint64_t)RAND_CNT();
		// Round to next 64 byte
		if(count % 64 != 0)
			count = ((count/64)+1)*64;
		debug_printk("count = %08lx \n", count);
		pkt_transfer = 0;
		EXPECT_EQ(fpgaDMATransferInit(&transfer[1]), FPGA_OK);
		EXPECT_EQ(S2M_transfer(dma_h[1], transfer[1], count, pkt_transfer, NULL), FPGA_OK);
		EXPECT_EQ(fpgaDMATransferDestroy(transfer[1]), FPGA_OK);
	}
	EXPECT_EQ(fpgaDMAClose(dma_h[1]), FPGA_OK);
	err_cnt = 0;
}

TEST_F(DmaAfuTest, fpgaDMATransfer_S2MStressNonDeterministicOnSameTransfer)
{	
	// Issue 10,000 non-deterministic length fpgaDMATransfer using the same transfer object, EOP set at random lengths	
	// This test will also verify transfer attributes can be correctly manipulated
	EXPECT_EQ(fpgaDMAOpen(afc_h, 1, &dma_h[1]), FPGA_OK);
	EXPECT_EQ(fpgaDMATransferInit(&transfer[1]), FPGA_OK);
	for(int i=0; i<10; i++) {
		srand(time(0)+i);
		count = (uint64_t)RAND_CNT();
		// Round to next 64 byte
		if(count % 64 != 0)
			count = ((count/64)+1)*64;
		debug_printk("count = %08lx \n", count);
		pkt_transfer = 1;
		EXPECT_EQ(S2M_multiple_transfer(dma_h[1], transfer[1], count, pkt_transfer, rxtransferComplete, 8), FPGA_OK);
	}
	EXPECT_EQ(fpgaDMATransferDestroy(transfer[1]), FPGA_OK);
	EXPECT_EQ(fpgaDMAClose(dma_h[1]), FPGA_OK);
	err_cnt = 0;
}

TEST_F(DmaAfuTest, fpgaDMATransfer_ParallelChannelOperation)
{	
	// Issue 10,000 deterministic length transfers on Tx and Rx channels in parallel	
	// Use 4CL as the length (short transfers)
	pthread_t threads[2];
	int rc;
	for(int i=0; i<2; i++) {
		if(i==0){
			EXPECT_EQ(fpgaDMAOpen(afc_h, i, &dma_h[i]), FPGA_OK);
			EXPECT_EQ(fpgaDMATransferInit(&transfer[i]), FPGA_OK);
			tf.tx_dma = dma_h[i];
			tf.tx_ch_no = i;
			tf.tx_transfer = transfer[0];
			tf.tx_callbk = txtransferComplete;
			rc = pthread_create(&threads[i], NULL, initiate_tx_tf, (void*)this);
		} else {
			EXPECT_EQ(fpgaDMAOpen(afc_h, i, &dma_h[i]), FPGA_OK);
			EXPECT_EQ(fpgaDMATransferInit(&transfer[i]), FPGA_OK);
			tf.rx_dma = dma_h[i];
			tf.rx_ch_no = i;
			tf.rx_transfer = transfer[1];
			tf.rx_callbk = rxtransferComplete;
			rc = pthread_create(&threads[i], NULL, initiate_rx_tf, (void*)this);
		}
		ASSERT_EQ(0, rc);
	}
	for(int i=0; i<2; i++) {
		pthread_join(threads[i], NULL);
		ASSERT_EQ(0, err_cnt);
		EXPECT_EQ(fpgaDMATransferDestroy(transfer[i]), FPGA_OK);
		EXPECT_EQ(fpgaDMAClose(dma_h[i]), FPGA_OK);
	}
}

TEST_F(DmaAfuTest, fpgaDMATransfer_MultiThreaded_Channel)
{	
	// Issue 10,000 deterministic length transfers on Tx, half from Thread A, other half from thread B
	// use very long transfers
	pthread_t threads[2];
	int rc;
	EXPECT_EQ(fpgaDMAOpen(afc_h, 0, &dma_h[0]), FPGA_OK);
	for(int i=0; i<2; i++) {
		if(i==0){
			EXPECT_EQ(fpgaDMATransferInit(&transfer[i]), FPGA_OK);
			tf.tx_dma = dma_h[0];
			tf.tx_transfer = transfer[0];
			tf.tx_callbk = txtransferComplete;
			rc = pthread_create(&threads[i], NULL, initiate_random_tx_tf_threadA, (void*)this);
		} else {
			EXPECT_EQ(fpgaDMATransferInit(&transfer[i]), FPGA_OK);
			tf.tx_dma = dma_h[0];
			tf.tx_transfer = transfer[1];
			tf.tx_callbk = txtransferComplete;
			rc = pthread_create(&threads[i], NULL, initiate_random_tx_tf_threadB, (void*)this);
		}
		ASSERT_EQ(0, rc);
	}
	for(int i=0; i<2; i++) {
		pthread_join(threads[i], NULL);
		ASSERT_EQ(0, err_cnt);
		EXPECT_EQ(fpgaDMATransferDestroy(transfer[i]), FPGA_OK);
	}
	EXPECT_EQ(fpgaDMAClose(dma_h[0]), FPGA_OK);		
}

TEST_F(DmaAfuTest, fpgaDMATransfer_Random)
{	
	// Issue 10,000 transfers, half from Thread A, other half from thread B
	// Use a random combination of deterministic and non-deterministc transfers
	// Use randomized length and ranomized EOP
	pthread_t threads[2];
	int rc;
	EXPECT_EQ(fpgaDMAOpen(afc_h, 1, &dma_h[1]), FPGA_OK);
	for(int i=0; i<2; i++) {
		if(i==0){
			EXPECT_EQ(fpgaDMATransferInit(&transfer[i]), FPGA_OK);
			tf.rx_dma = dma_h[1];
			tf.rx_transfer = transfer[0];
			tf.rx_callbk = rxtransferComplete;
			rc = pthread_create(&threads[i], NULL, initiate_random_rx_tf_threadA, (void*)this);
		} else {
			EXPECT_EQ(fpgaDMATransferInit(&transfer[i]), FPGA_OK);
			tf.rx_dma = dma_h[1];
			tf.rx_transfer = transfer[1];
			tf.rx_callbk = rxtransferComplete;
			rc = pthread_create(&threads[i], NULL, initiate_random_rx_tf_threadB, (void*)this);
		}
		ASSERT_EQ(0, rc);
	}
	for(int i=0; i<2; i++) {
		pthread_join(threads[i], NULL);
		ASSERT_EQ(0, err_cnt);
		EXPECT_EQ(fpgaDMATransferDestroy(transfer[i]), FPGA_OK);
	}
	EXPECT_EQ(fpgaDMAClose(dma_h[1]), FPGA_OK);
}

TEST_F(DmaAfuTest, fpgaDMATransfer_BandwidthTest)
{	
	// Measure median bandwidth by running M2S and S2M transfer 30 times
}

int main(int argc, char** argv)
{
	testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}
