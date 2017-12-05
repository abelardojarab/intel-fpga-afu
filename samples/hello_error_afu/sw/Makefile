LDFLAGS ?=
CFLAGS = -g -O2 -std=c99

CFLAGS += -I$(prefix)/common/include 
CFLAGS += -I$(prefix)/libopae/src
LDFLAGS += -L$(prefix)/build/lib -luuid 

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
