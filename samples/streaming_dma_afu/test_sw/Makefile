LDFLAGS ?=
CFLAGS = -g -O2 -fPIC

CFLAGS += -I$(prefix)/include
CFLAGS += -D FPGA_DMA_DEBUG=0
LDFLAGS += -L$(prefix)/lib -luuid -lrt

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
ifneq ($(wildcard fpga_dma_st.c),)
	DMA_OBJS += fpga_dma_st.o
endif

all: fpga_dma_st_gtest

fpga_dma_st_gtest: fpga_dma_st_gtest.o
	g++ -o $@ $^ -L$(gtest_lib) -lgtest -L$(drv_path) -l:fpga_dma_st.so $(LDFLAGS)

fpga_dma_st_gtest.o: fpga_dma_st_gtest.cpp
	g++ -o $@ -c $^ $(CFLAGS) -I$(drv_path) -I$(gtest_include)

%.o: %.cpp
	g++ $(CFLAGS) -c -o $@ $<

clean:
	$(RM) fpga_dma_st_gtest *.o *.so

.PHONY:all clean
