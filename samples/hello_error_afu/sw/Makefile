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
LDFLAGS += -L$(prefix)/lib -L$(prefix)/lib64
endif

LDFLAGS += -luuid

CFLAGS += -Wall -Wno-unknown-pragmas -Werror

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ase
	CFLAGS += -DUSE_ASE
else
	LDFLAGS += -lpthread
	LDFLAGS += -ljson-c
	LDFLAGS += -lopae-c
endif

all: hello_error_afu

hello_error_afu: hello_error_afu.o
	gcc $(CFLAGS) -o hello_error_afu hello_error_afu.o $(LDFLAGS)

hello_error_afu.o: hello_error_afu.c  Makefile
	gcc $(CFLAGS) -c -o hello_error_afu.o hello_error_afu.c

clean:
	$(RM) hello_error_afu hello_error_afu.o

.PHONY:all clean
