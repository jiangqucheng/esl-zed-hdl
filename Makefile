####################################################################################
####################################################################################
## Copyright (c) 2018 - 2021 Analog Devices, Inc.
### SPDX short identifier: BSD-1-Clause
## Auto-generated, do not modify!
####################################################################################
####################################################################################

include quiet.mk

help:
	@echo ""
	@echo "Please specify a target."
	@echo ""
	@echo "To make all projects:"
	@echo "    make all"
	@echo ""
	@echo "To build a specific project:"
	@echo "    make proj.board"
	@echo "e.g.,"
	@echo "    make adv7511.zed"


PROJECTS := $(filter-out $(NO_PROJ), $(notdir $(wildcard projects/*)))
SUBPROJECTS := $(foreach projname,$(PROJECTS), \
	$(foreach archname,$(notdir $(subst /Makefile,,$(wildcard projects/$(projname)/*/Makefile))), \
		$(projname).$(archname)))

.PHONY: lib all clean clean-ipcache clean-all $(SUBPROJECTS)

$(SUBPROJECTS):
	$(MAKE) -C projects/$(subst .,/,$@)

lib:
	$(MAKE) -C library/ all


all:
	$(MAKE) -C projects/ all


clean:
	$(MAKE) -C projects/ clean

clean-ipcache:
	$(call clean, \
		ipcache, \
		$(HL)IP Cache$(NC))

clean-all:clean clean-ipcache
	$(MAKE) -C projects/ clean
	$(MAKE) -C library/ clean

####################################################################################
####################################################################################


####################################################################################
## ESL machine targets -- build XSA and symlink into build/
## Usage: make zedboard-esl  OR  make ebaz4205-esl
####################################################################################

BUILD_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))build

.PHONY: zedboard-esl ebaz4205-esl

zedboard-esl:
	$(MAKE) -C projects/imageon/zed ADI_IGNORE_VERSION_CHECK=1
	@mkdir -p $(BUILD_DIR)
	@XSA=projects/imageon/zed/ADIIGNOREVERSIONCHECK1/imageon_zed.sdk/system_top.xsa; \
	 TARGET=$(BUILD_DIR)/system_top-zedboard-esl.xsa; \
	 if [ ! -e "$$XSA" ]; then \
	   echo "FATAL: XSA not found: $$XSA"; \
	   exit 1; \
	 fi; \
	 rm -f "$$TARGET"; \
	 ln -s "`pwd`/$$XSA" "$$TARGET"; \
	 echo "Linked: $$TARGET"

ebaz4205-esl:
	$(MAKE) -C projects/imageon/ebaz4205 ADI_IGNORE_VERSION_CHECK=1
	@mkdir -p $(BUILD_DIR)
	@XSA=projects/imageon/ebaz4205/ADIIGNOREVERSIONCHECK1/imageon_ebaz4205.sdk/system_top.xsa; \
	 TARGET=$(BUILD_DIR)/system_top-ebaz4205-esl.xsa; \
	 if [ ! -e "$$XSA" ]; then \
	   echo "FATAL: XSA not found: $$XSA"; \
	   exit 1; \
	 fi; \
	 rm -f "$$TARGET"; \
	 ln -s "`pwd`/$$XSA" "$$TARGET"; \
	 echo "Linked: $$TARGET"
