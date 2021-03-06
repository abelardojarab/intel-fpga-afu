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
LDFLAGS += -L$(prefix)/lib -L$(prefix)/lib64
AFU_JSON_MGR = $(prefix)/bin/afu_json_mgr
else
AFU_JSON_MGR = afu_json_mgr
endif

LDFLAGS += -luuid

CFLAGS += -Wall -Wno-unknown-pragmas
#TODO: fix warnings
#CFLAGS += -Werror

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ase
	CFLAGS += -DUSE_ASE
else
	LDFLAGS += -lpthread
	LDFLAGS += -ljson-c
	LDFLAGS += -lopae-c
endif

all: user_clock_test

afu_json_info.h: ../hw/rtl/user_clock_test.json
	$(AFU_JSON_MGR) json-info --afu-json=$^ --c-hdr=$@

user_clock_test.o: afu_json_info.h

user_clock_test: user_clock_test.o
	g++ $(CFLAGS) -o user_clock_test user_clock_test.o $(LDFLAGS)

user_clock_test.o: user_clock_test.c  Makefile
	g++ $(CFLAGS) -c -o user_clock_test.o user_clock_test.c

clean:
	$(RM) user_clock_test user_clock_test.o afu_json_info.h


run: all
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(prefix)/build/lib:$(prefix)/build/lib64 ./user_clock_test

.PHONY:all clean
