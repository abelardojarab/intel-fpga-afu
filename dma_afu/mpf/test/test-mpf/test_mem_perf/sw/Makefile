include ../../base/sw/base_include.mk

CFLAGS += -DVCMAP_ENABLE_DEFAULT=false

FPGA_LIBS = -lfpga -ljson-c
ASE_LIBS = -lfpga-ASE

all: test_mem_perf test_mem_perf_ase test_mem_latency test_mem_latency_ase \
	compute_latency_qos_params compute_latency_qos_params_ase \
	compute_vc_map_params compute_vc_map_params_ase

test_mem_perf: test_mem_perf.o test_mem_perf_common.o $(BASE_FILE_OBJ)
	$(CXX) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(FPGA_LIBS)
test_mem_perf_ase: test_mem_perf.o test_mem_perf_common.o $(BASE_FILE_OBJ)
	$(CXX) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(ASE_LIBS)

test_mem_latency: test_mem_latency.o test_mem_perf_common.o $(BASE_FILE_OBJ)
	$(CXX) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(FPGA_LIBS)
test_mem_latency_ase: test_mem_latency.o test_mem_perf_common.o $(BASE_FILE_OBJ)
	$(CXX) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(ASE_LIBS)

compute_latency_qos_params: compute_latency_qos_params.o test_mem_perf_common.o $(BASE_FILE_OBJ)
	$(CXX) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(FPGA_LIBS)
compute_latency_qos_params_ase: compute_latency_qos_params.o test_mem_perf_common.o $(BASE_FILE_OBJ)
	$(CXX) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(ASE_LIBS)

compute_vc_map_params: compute_vc_map_params.o test_mem_perf_common.o $(BASE_FILE_OBJ)
	$(CXX) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(FPGA_LIBS)
compute_vc_map_params_ase: compute_vc_map_params.o test_mem_perf_common.o $(BASE_FILE_OBJ)
	$(CXX) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(ASE_LIBS)

.cpp.o: cci_test.h $(BASE_FILE_INC)
	$(CXX) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

clean:
	$(RM) test_mem_perf test_mem_latency compute_latency_qos_params compute_vc_map_params *_ase $(BASE_FILE_OBJ) *.o

.PHONY:all clean
