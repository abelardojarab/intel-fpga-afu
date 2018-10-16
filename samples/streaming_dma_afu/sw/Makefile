CXX = g++
LDFLAGS ?=
CXXFLAGS += -D FPGA_DMA_DEBUG=1 -g -O2 -fPIC -D EMU_MODE=0 -Wall -Wno-unknown-pragmas -I$(tbb)/include -fpermissive -std=c++11

# Flush and avoid use of DMA descriptors from previous transfer
CFLAGS += -D FORCE_DESC_FLUSH=1
ifdef prefix
LDFLAGS += -L$(prefix)/lib -L$(prefix)/lib64 
endif

LDFLAGS += -luuid
LDFLAGS += -lsafestr
LDFLAGS += -lrt
LDFLAGS += -ltbb
LDFLAGS += -L$(tbb)/lib/intel64_lin/gcc4.7/

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ase
	CXXFLAGS += -DUSE_ASE
else
	LDFLAGS += -ljson-c
	LDFLAGS += -lopae-c
	LDFLAGS += -lhwloc
endif

LDFLAGS += -pthread
LDFLAGS += -lm

SRCS=$(wildcard *.cpp)
OBJS=$(SRCS:.cpp=.o)
all: $(OBJS) fpga_dma_st_test

fpga_dma_st.a: fpga_dma_st.o x86-sse2.o
	ar rcs $@ $^

fpga_dma_st_test: $(OBJS) fpga_dma_st.a
	$(CXX) -o $@ $^ $(LDFLAGS)

clean:
	$(RM) fpga_dma_st_test *.o *.so *.a

.PHONY:all clean
