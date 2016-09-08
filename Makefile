ACCEL_SRC_DIRS := nlb_400 nlb_mpf_async_fifo sgemm

ACCEL_DEST := $(ADAPT_DEST_ROOT)/afu
ACCEL_DEST_DIRS := $(foreach d,$(ACCEL_SRC_DIRS),$(addprefix $(ACCEL_DEST)/,$d))

.PHONY: all clean
all: $(ACCEL_DEST_DIRS)
clean:
	rm -rf $(ACCEL_DEST)

# TODO: avoid rsync in "build"
.PHONY: _force
$(ACCEL_DEST)/%: % _force | $(ACCEL_DEST)/
	rsync -r $< $(@D)/

$(ACCEL_DEST)/:
	mkdir -p $@
