LDFLAGS ?=
CFLAGS = -g -O2 -std=c99 -fPIC

ifdef prefix
CFLAGS += -I$(prefix)/include
LDFLAGS += -L$(prefix)/lib
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

all: hello_mem_afu

hello_mem_afu: hello_mem_afu.o
	gcc $(CFLAGS) -o hello_mem_afu hello_mem_afu.o $(LDFLAGS)

hello_mem_afu.o: hello_mem_afu.c  Makefile
	gcc $(CFLAGS) -c -o hello_mem_afu.o hello_mem_afu.c

clean:
	$(RM) hello_mem_afu hello_mem_afu.o

.PHONY:all clean
