LFLAGS ?=
CFLAGS = -g -O2 -fPIC 

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
	LDFLAGS += -pthread
endif

all: bist_afu

# FPGA BIST Driver
bist_afu: bist_afu.o fpga_bist.so
	gcc -o $@ $^ $(LDFLAGS)

bist_afu.o: bist_afu.c
	gcc $(CFLAGS) -o $@ -c $^ 

fpga_bist.so: fpga_bist.o
	gcc $(CFLAGS) -shared -o $@ $^ $(LDFLAGS)

fpga_bist.o: fpga_bist.c
	gcc $(CFLAGS) -c -o $@ $^

clean:
	$(RM) bist_afu *.o *.so

.PHONY:all clean
