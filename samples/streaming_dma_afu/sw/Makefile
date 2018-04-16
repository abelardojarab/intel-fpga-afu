LDFLAGS ?=
CFLAGS = -g -O2 -fPIC
CFLAGS += -D FPGA_DMA_DEBUG=0
ifdef prefix
CFLAGS += -I$(prefix)/include
LDFLAGS += -L$(prefix)/lib -L$(prefix)/lib64
endif

CFLAGS += -Wall -Werror -Wno-unknown-pragmas
LDFLAGS += -luuid
LDFLAGS += -lsafestr
LDFLAGS += -lrt

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
fpga_dma_st_test: fpga_dma_st_test.o fpga_dma_st.so fpga_pattern_gen.o fpga_pattern_checker.o
	gcc -o $@ $^ $(LDFLAGS)

fpga_dma_st_test.o: fpga_dma_st_test.c
	gcc $(CFLAGS) -o $@ -c $^

fpga_dma_st.so: fpga_dma_st.o x86-sse2.o
	gcc $(CFLAGS) -shared -o $@ $^ $(LDFLAGS)

fpga_dma_st.o: fpga_dma_st.c
	gcc $(CFLAGS) -c -o $@ $^

fpga_pattern_gen.o: fpga_pattern_gen.c
	gcc $(CFLAGS) -c -o $@ $^

fpga_pattern_checker.o: fpga_pattern_checker.c
	gcc $(CFLAGS) -c -o $@ $^
	 
x86-sse2.o: x86-sse2.S
	gcc $(CFLAGS) -c -o $@ $^

clean:
	$(RM) fpga_dma_st_test *.o *.so

.PHONY:all clean
