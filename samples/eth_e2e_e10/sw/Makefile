# #############################################################################
# Copyright(c) 2011-2018, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# * Neither the name of Intel Corporation nor the names of its contributors
# may be used to endorse or promote products derived from this software
# without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# #############################################################################

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

CFLAGS += -g -O2

ifdef prefix
CFLAGS += -I$(prefix)/include
LDFLAGS += -L$(prefix)/lib -L$(prefix)/lib64
AFU_JSON_MGR = $(prefix)/bin/afu_json_mgr
else
AFU_JSON_MGR = afu_json_mgr
endif
LDFLAGS += -luuid
LDFLAGS += -lrt
LDFLAGS += -lsafestr


CFLAGS += -Wall -Wno-unknown-pragmas -Werror

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ase
	CFLAGS += -DUSE_ASE
else
	LDFLAGS += -ljson-c
	LDFLAGS += -lpthread
	LDFLAGS += -lopae-c
	LDFLAGS += -pthread
endif

all: pac_hssi_e10

afu_json_info.h: ../hw/rtl/e10/${OPAE_PLATFORM_FPGA_FAMILY}/eth_e2e_e10.json
	$(AFU_JSON_MGR) json-info --afu-json=$^ --c-hdr=$@

pac_hssi_e10: pac_hssi_e10.o fpga_hssi.so
	gcc -o $@ $^ $(LDFLAGS)

pac_hssi_e10.o: pac_hssi_e10.c afu_json_info.h
	gcc -MD $(CFLAGS) -o $@ -c $<

fpga_hssi.so: fpga_hssi.o
	gcc $(CFLAGS)  -o $@ $^ $(LDFLAGS) -shared

fpga_hssi.o: fpga_hssi.c
	gcc $(CFLAGS) -c -o $@ $^

clean:
	$(RM) pac_hssi_e10 *.o *.so afu_json_info.h *.d

.PHONY:all clean
