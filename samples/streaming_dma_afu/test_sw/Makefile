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
ifneq ($(wildcard fpga_dma_st.c),)
	DMA_OBJS += fpga_dma_st.o
endif

all: fpga_dma_st_gtest

fpga_dma_st_gtest: fpga_dma_st_gtest.o fpga_pattern_gen.o fpga_pattern_checker.o
	g++ -o $@ $^ -L$(gtest_lib) -lgtest -L$(drv_path) -l:fpga_dma_st.so $(LDFLAGS)

fpga_dma_st_gtest.o: fpga_dma_st_gtest.cpp
	gcc -o $@ -c $^ $(CFLAGS) -I$(drv_path) -I$(gtest_include)

fpga_pattern_gen.o: $(drv_path)/fpga_pattern_gen.c
	gcc $(CFLAGS) -c -o $@ $^

fpga_pattern_checker.o: $(drv_path)/fpga_pattern_checker.c
	gcc $(CFLAGS) -c -o $@ $^

%.o: %.cpp
	g++ $(CFLAGS) $(GTEST_INC) -c -o $@ $<

clean:
	$(RM) fpga_dma_st_gtest *.o *.so

.PHONY:all clean
