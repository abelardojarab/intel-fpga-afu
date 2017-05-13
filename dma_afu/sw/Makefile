LDFLAGS ?=
CFLAGS = -g -O2

CFLAGS += -I$(prefix)/common/include 
LDFLAGS += -L$(prefix)/build/lib -luuid 

ifeq ($(USE_ASE),1)
	LDFLAGS += -lfpga-ASE
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
	$(RM) dma_afu_test dma_afu_test.o

run: all
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(prefix)/build/lib ./dma_afu_test


.PHONY:all clean
