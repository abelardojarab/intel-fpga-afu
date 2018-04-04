LDFLAGS ?=
CFLAGS = -g -O2 -fPIC
CFLAGS += -D FPGA_DMA_DEBUG=0
ifdef prefix
CFLAGS += -I$(prefix)/include
LDFLAGS += -L$(prefix)/lib
endif

CFLAGS += -Wall -Werror -Wno-unknown-pragmas
LDFLAGS += -luuid
LDFLAGS += -lsafestr

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ase
	CFLAGS += -DUSE_ASE
else
	LDFLAGS += -ljson-c
	LDFLAGS += -lopae-c
endif

LDFLAGS += -pthread
LDFLAGS += -lm

all: fpga_dma_st_test

# FPGA DMA Driver
fpga_dma_st_test: fpga_dma_st_test.o fpga_dma_st.so
	gcc -o $@ $^ $(LDFLAGS)

fpga_dma_st_test.o: fpga_dma_st_test.c
	gcc $(CFLAGS) -o $@ -c $^

fpga_dma_st.so: fpga_dma_st.o
	gcc $(CFLAGS) -shared -o $@ $^ $(LDFLAGS)

fpga_dma_st.o: fpga_dma_st.c
	gcc $(CFLAGS) -c -o $@ $^

clean:
	$(RM) fpga_dma_st_test *.o *.so

.PHONY:all clean
