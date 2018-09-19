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

#CFLAGS += -Werror

CFLAGS += -g -O2 -std=c99

ifdef prefix
CFLAGS += -I$(prefix)/include
LDFLAGS += -L$(prefix)/lib
AFU_JSON_MGR = $(prefix)/bin/afu_json_mgr
else
AFU_JSON_MGR = afu_json_mgr
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

all: pv_afu

afu_json_info.h: ../hw/rtl/pv_afu.json
	$(AFU_JSON_MGR) json-info --afu-json=$^ --c-hdr=$@

pv_afu.o: afu_json_info.h

pv_afu: pv_afu.o
	gcc $(CFLAGS) -o pv_afu pv_afu.o $(LDFLAGS)

pv_afu.o: pv_afu.c  Makefile
	gcc $(CFLAGS) -c -o pv_afu.o pv_afu.c

clean:
	$(RM) pv_afu pv_afu.o afu_json_info.h

.PHONY:all clean
