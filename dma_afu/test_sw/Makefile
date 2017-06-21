LDFLAGS ?=
CFLAGS = -g -O2 -fPIC

CFLAGS += -I$(prefix)/common/include
CFLAGS += -I$(prefix)/libfpga/src
CFLAGS += -D FPGA_DMA_DEBUG=0
LDFLAGS += -L$(prefix)/build/lib -luuid 

ifeq ($(USE_ASE),1)
	LDFLAGS += -lfpga-ase
	CFLAGS += -DUSE_ASE
else
	LDFLAGS += -lpthread
	LDFLAGS += -ljson-c
	LDFLAGS += -lfpga
endif

all: dma_afu_test

dma_afu_test: dma_afu_test.o
	g++ $(CFLAGS) -o dma_afu_test dma_afu_test.o $(LDFLAGS)

dma_afu_test.o: dma_afu_test.cpp  Makefile
	g++ $(CFLAGS) -c -o dma_afu_test.o dma_afu_test.cpp

clean:
	$(RM) dma_afu_test *.o *.so

run: all
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(prefix)/build/lib ./dma_afu_test


.PHONY:all clean
