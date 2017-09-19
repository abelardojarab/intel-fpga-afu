include ../../base/sw/base_include.mk

FPGA_LIBS = -lfpga -ljson-c
ASE_LIBS = -lfpga-ASE

all: test_random test_random_ase

test_random: test_random.o $(BASE_FILE_OBJ)
	$(CXX) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(FPGA_LIBS)

test_random_ase: test_random.o $(BASE_FILE_OBJ)
	$(CXX) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(ASE_LIBS)

.cpp.o: cci_test.h $(BASE_FILE_INC)
	$(CXX) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

clean:
	$(RM) test_random $(BASE_FILE_OBJ) *.o

.PHONY:all clean
