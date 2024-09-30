#
# Makefile to build the master boot, stage 1
#

BUILD = ../../../../build

all:		mboot1.bin

mboot1.bin:	mboot1
		$(BUILD)/bin/load -p mboot1 mboot1.bin

mboot1:		mboot1.o
		$(BUILD)/bin/ld -s stage1.lnk -o mboot1 mboot1.o

mboot1.o:	mboot1.s
		$(BUILD)/bin/as -o mboot1.o mboot1.s

clean:
		rm -f *~ mboot1.o mboot1 mboot1.bin
