SUBDIRS := nlb_400 hello_afu user_clock_test opencl/blank opencl/hello_world opencl/mem_bandwidth opencl/vector_add
CLEAN_SUBDIRS := $(addprefix clean-,$(SUBDIRS))

.PHONY: all $(SUBDIRS)
all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: clean $(CLEAN_SUBDIRS)
clean: $(CLEAN_SUBDIRS)

$(CLEAN_SUBDIRS):
	$(MAKE) -C $(subst clean-,,$@) clean

