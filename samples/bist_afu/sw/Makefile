############################################################
# Makefile setting required to comply with SDL
############################################################

# stack execution protection
LDFLAGS +=-z noexecstack

# data relocation and projection
LDFLAGS +=-z relro -z now

# stack buffer overrun detection
# Note that CentOS 7 has gcc 4.8 by default.  When we switch
# to a system with gcc 4.9 or newer this should be changed to
# CFLAGS="-fstack-protector-strong"
CFLAGS +=-fstack-protector

# Position independent execution
CFLAGS +=-fPIE -fPIC
LDFLAGS +=-pie

# fortify source
CFLAGS+=-O2 -D_FORTIFY_SOURCE=2

# format string vulnerabilities
CFLAGS+=-Wformat -Wformat-security

############################################################

CFLAGS += -Werror

CFLAGS += -g -O2

ifdef prefix
CFLAGS += -I$(prefix)/include
LDFLAGS += -L$(prefix)/lib
endif

#CFLAGS += -Wall -Werror -Wno-unknown-pragmas
LDFLAGS += -luuid
LDFLAGS += -lsafestr
LDFLAGS += -lrt

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ase
	CFLAGS += -DUSE_ASE
else
	LDFLAGS += -ljson-c
	LDFLAGS += -lopae-c
	LDFLAGS += -pthread
endif

all: bist_afu_ase_test

# FPGA DMA Driver
bist_afu_ase_test: bist_afu_ase_test.o bist_afu_ase.so
	gcc -o $@ $^ $(LDFLAGS)

bist_afu_ase_test.o: bist_afu_ase_test.c
	gcc $(CFLAGS) -o $@ -c $^ 

bist_afu_ase.so: bist_afu_ase.o
	gcc $(CFLAGS)  -o $@ $^ $(LDFLAGS) -shared

bist_afu_ase.o: bist_afu_ase.c
	gcc $(CFLAGS) -c -o $@ $^

clean:
	$(RM) bist_afu_ase_test *.o *.so

.PHONY:all clean
