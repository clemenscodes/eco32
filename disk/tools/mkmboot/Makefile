#
# Makefile to build the master boot, 2 stages
#

BUILD = ../../../build

.PHONY:		all install clean

all:		stage1/mboot1.bin stage2/mboot2.bin

install:	stage1/mboot1.bin stage2/mboot2.bin
		mkdir -p $(BUILD)/run-GPT
		cp stage1/mboot1.bin $(BUILD)/run-GPT
		cp stage2/mboot2.bin $(BUILD)/run-GPT

stage1/mboot1.bin:
		$(MAKE) -C stage1 all

stage2/mboot2.bin:
		$(MAKE) -C stage2 all

clean:
		$(MAKE) -C stage1 clean
		$(MAKE) -C stage2 clean
		rm -f *~
