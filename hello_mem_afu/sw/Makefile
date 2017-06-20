LDFLAGS ?=
CFLAGS = -g -O2 -std=c99 -fPIC

CFLAGS += -I$(prefix)/common/include 
CFLAGS += -I$(prefix)/libopae/src
LDFLAGS += -L$(prefix)/build/lib -luuid 

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ASE
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
