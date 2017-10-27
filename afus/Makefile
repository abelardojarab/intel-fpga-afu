SUBDIRS := hello_afu dma_afu user_clock_test
CLEAN_SUBDIRS := $(addprefix clean-,$(SUBDIRS))

.PHONY: all $(SUBDIRS)
all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: clean $(CLEAN_SUBDIRS)
clean: $(CLEAN_SUBDIRS)

$(CLEAN_SUBDIRS):
	$(MAKE) -C $(subst clean-,,$@) clean

