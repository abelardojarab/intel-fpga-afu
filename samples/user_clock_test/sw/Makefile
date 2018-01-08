include ../../common_sw.mk

CFLAGS += -g -O2 

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

all: user_clock_test

user_clock_test: user_clock_test.o
	g++ $(CFLAGS) -o user_clock_test user_clock_test.o $(LDFLAGS)

user_clock_test.o: user_clock_test.c  Makefile
	g++ $(CFLAGS) -c -o user_clock_test.o user_clock_test.c

clean:
	$(RM) user_clock_test user_clock_test.o


run: all
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(prefix)/build/lib ./user_clock_test

.PHONY:all clean
