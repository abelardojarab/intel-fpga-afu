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

CFLAGS += -g -O2 -std=c99

ifdef prefix
CFLAGS += -I$(prefix)/include
LDFLAGS += -L$(prefix)/lib
endif
LDFLAGS += -luuid

CFLAGS += -Wall -Wno-unknown-pragmas

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ase
	CFLAGS += -DUSE_ASE
else
	LDFLAGS += -lpthread
	LDFLAGS += -lopae-c
endif

all: hello_afu

afu_json_info.h: ../hw/rtl/hello_afu.json
	afu_json_mgr json-info --afu-json=$^ --c-hdr=$@

hello_afu.o: afu_json_info.h

hello_afu: hello_afu.o
	gcc $(CFLAGS) -o hello_afu hello_afu.o $(LDFLAGS)

hello_afu.o: hello_afu.c  Makefile
	gcc $(CFLAGS) -c -o hello_afu.o hello_afu.c

clean:
	$(RM) hello_afu hello_afu.o afu_json_info.h

.PHONY:all clean
