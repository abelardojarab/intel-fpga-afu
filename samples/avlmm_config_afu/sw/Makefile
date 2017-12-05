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

all: avlmm_config_afu

avlmm_config_afu: avlmm_config_afu.o
	gcc $(CFLAGS) -o avlmm_config_afu avlmm_config_afu.o $(LDFLAGS)

avlmm_config_afu.o: avlmm_config_afu.c  Makefile
	gcc $(CFLAGS) -c -o avlmm_config_afu.o avlmm_config_afu.c

clean:
	$(RM) avlmm_config_afu avlmm_config_afu.o

.PHONY:all clean
