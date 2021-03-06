LDFLAGS ?=
CFLAGS = -g -O2 -fPIC

CFLAGS += -I$(prefix)/include
CFLAGS += -D FPGA_DMA_DEBUG=0
LDFLAGS += -L$(prefix)/lib -L$(prefix)/lib64 -luuid -lrt

GTEST_INC += -I$(drv_path)

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ase
	CFLAGS += -DUSE_ASE
else
	LDFLAGS += -lpthread
	LDFLAGS += -ljson-c
	LDFLAGS += -lopae-c
endif

DMA_OBJS ?=
ifneq ($(wildcard fpga_dma.c),)
	DMA_OBJS += fpga_dma.o
	CFLAGS += -DINCLUDE_DMA_DRIVER
	CFLAGS += -DINCLUDE_DMA_DRIVER
endif

all: dma_afu_test dma_bbb_speed_test dma_memtest

dma_memtest: dma_memtest.o dma_test_common.o
	g++ $(CFLAGS) -o $@ $^ $(LDFLAGS)

dma_afu_test: dma_afu_test.o dma_test_common.o
	g++ $(CFLAGS) -o $@ $^ $(LDFLAGS)

fpga_dma_gtest: fpga_dma_gtest.o
	g++ -o $@ $^ -L$(gtest_lib) -lgtest -L$(drv_path) -l:fpga_dma.a $(LDFLAGS)

fpga_dma_gtest.o: fpga_dma_gtest.cpp
	g++ -o $@ -c $^ $(CFLAGS) -I$(drv_path) -I$(gtest_include)


dma_bbb_speed_test: dma_bbb_speed_test.o dma_test_common.o $(DMA_OBJS)
	g++ $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.cpp
	g++ $(CFLAGS) -c -o $@ $<

clean:
	$(RM) dma_afu_test *.o *.so

.PHONY:all clean
