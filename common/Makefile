include ../../bcommon/common.mk

COPY_DIRS := scripts

.PHONY: all clean target-dir

all: $(COPY_DIRS)
clean:
	rm -rf $(THIS_TARGET_DIR)

target-dir:
	rm -rf $(THIS_TARGET_DIR)
	mkdir -p $(THIS_TARGET_DIR)

$(COPY_DIRS): target-dir
	cp -rf $@ $(THIS_TARGET_DIR)/

