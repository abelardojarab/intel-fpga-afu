LDFLAGS ?=
CFLAGS = -g -O2 -std=c99

ifdef prefix
CFLAGS += -I$(prefix)/include
LDFLAGS += -L$(prefix)/lib -luuid
LDFLAGS += $(prefix)/lib/libsafestr.a
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

all: hello_afu

hello_afu: hello_afu.o
	gcc $(CFLAGS) -o hello_afu hello_afu.o $(LDFLAGS)

hello_afu.o: hello_afu.c  Makefile
	gcc $(CFLAGS) -c -o hello_afu.o hello_afu.c

clean:
	$(RM) hello_afu hello_afu.o

.PHONY:all clean
