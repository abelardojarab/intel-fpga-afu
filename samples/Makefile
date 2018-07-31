SUBDIRS := nlb_400 hello_afu dma_afu user_clock_test eth_e2e_e10 eth_e2e_e40 e100g_mac_afu
CLEAN_SUBDIRS := $(addprefix clean-,$(SUBDIRS))

.PHONY: all $(SUBDIRS)
all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: clean $(CLEAN_SUBDIRS)
clean: $(CLEAN_SUBDIRS)

$(CLEAN_SUBDIRS):
	$(MAKE) -C $(subst clean-,,$@) clean

