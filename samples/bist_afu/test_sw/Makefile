LDFLAGS ?=
CFLAGS = -g -O2 -std=c99

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

all: simple_ddr

simple_ddr: simple_ddr.o
	gcc $(CFLAGS) -o simple_ddr simple_ddr.o $(LDFLAGS)

simple_ddr.o: simple_ddr.c  Makefile
	gcc $(CFLAGS) -c -o simple_ddr.o simple_ddr.c

clean:
	$(RM) simple_ddr simple_ddr.o

.PHONY:all clean
