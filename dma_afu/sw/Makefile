LDFLAGS ?=
CFLAGS = -g -O2 -fPIC

CFLAGS += -I$(prefix)/common/include
CFLAGS += -I$(prefix)/libfpga/src
CFLAGS += -D FPGA_DMA_DEBUG=0
LDFLAGS += -L$(prefix)/build/lib -luuid 

ifeq ($(USE_ASE),1)
	LDFLAGS += -lfpga-ASE
	CFLAGS += -DUSE_ASE
else
	LDFLAGS += -lpthread
	LDFLAGS += -ljson-c
	LDFLAGS += -lfpga
endif

all: dma_afu_test fpga_dma_test

dma_afu_test: dma_afu_test.o
	g++ $(CFLAGS) -o dma_afu_test dma_afu_test.o $(LDFLAGS)

dma_afu_test.o: dma_afu_test.cpp  Makefile
	g++ $(CFLAGS) -c -o dma_afu_test.o dma_afu_test.cpp

# FPGA DMA Driver
fpga_dma_test: fpga_dma_test.o fpga_dma.so
	gcc -o $@ $^ $(LDFLAGS)

fpga_dma_test.o: fpga_dma_test.c
	gcc $(CFLAGS) -o $@ -c $^ 

fpga_dma.so: fpga_dma.o
	gcc $(CFLAGS) -shared -o $@ $^ $(LDFLAGS)

fpga_dma.o: fpga_dma.c
	gcc $(CFLAGS) -c -o $@ $^

clean:
	$(RM) dma_afu_test fpga_dma fpga_dma_test *.o *.so

run: all
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(prefix)/build/lib ./dma_afu_test


.PHONY:all clean
