LDFLAGS ?=
CFLAGS = -g -O2 -std=c99 -fPIC

CFLAGS += -I$(prefix)/common/include
CFLAGS += -I$(prefix)/libfpga/src
LDFLAGS += -L$(prefix)/build/lib -luuid 

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ASE
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
