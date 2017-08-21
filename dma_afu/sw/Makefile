LDFLAGS ?=
CFLAGS = -g -O2 -fPIC -std=gnu++11

CFLAGS += -I$(prefix)/common/include
CFLAGS += -I$(prefix)/libopae/src
CFLAGS += -D FPGA_DMA_DEBUG=0
CFLAGS += -Wall -Wno-unknown-pragmas
LDFLAGS += -L$(prefix)/build/lib -luuid
LDFLAGS += -L/usr/lib/

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ase
	CFLAGS += -DUSE_ASE
else
	LDFLAGS += -lpthread
	LDFLAGS += -ljson-c
	LDFLAGS += -lopae-c
	LDFLAGS += -pthread
endif

all: fpga_dma_test fpga_dma_gtest

fpga_dma_gtest: fpga_dma_gtest.o fpga_dma.so
	g++ -o $@ $^ $(LDFLAGS) libgtest.a

fpga_dma_gtest.o: fpga_dma_gtest.cpp
	g++ $(CFLAGS) -o $@ -c $^  

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
	$(RM) fpga_dma fpga_dma_gtest fpga_dma_test *.o *.so

.PHONY:all clean
