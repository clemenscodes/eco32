#
# Makefile to build the master boot, stage 2
#

BUILD = ../../../../build

all:		mboot2.bin

mboot2.bin:	mngrcode.bin
		cp mngrcode.bin mboot2.bin

clean:
		rm -f *~ mboot2.bin
