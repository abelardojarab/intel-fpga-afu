LDFLAGS ?=
CFLAGS = -g -O2 -fPIC

CFLAGS += -I$(prefix)/common/include
CFLAGS += -I$(prefix)/libopae/src
CFLAGS += -D FPGA_DMA_DEBUG=0
LDFLAGS += -L$(prefix)/build/lib -luuid 

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ase
	CFLAGS += -DUSE_ASE
else
	LDFLAGS += -lpthread
	LDFLAGS += -ljson-c
	LDFLAGS += -lopae-c
endif

all: fpga_dma_test

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
	$(RM) fpga_dma fpga_dma_test *.o *.so

.PHONY:all clean
