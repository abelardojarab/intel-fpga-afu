LDFLAGS ?=
CFLAGS = -g -O2 -std=c99

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

all: hello_afu

hello_afu: hello_afu.o
	gcc $(CFLAGS) -o hello_afu hello_afu.o $(LDFLAGS)

hello_afu.o: hello_afu.c  Makefile
	gcc $(CFLAGS) -c -o hello_afu.o hello_afu.c

clean:
	$(RM) hello_afu hello_afu.o

.PHONY:all clean
