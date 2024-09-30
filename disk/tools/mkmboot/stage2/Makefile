#
# Makefile to build the master boot, stage 2
#

BUILD = ../../../../build

all:		mboot2.bin

mboot2.bin:	mboot2
		$(BUILD)/bin/load -p mboot2 mboot2.bin

mboot2:		c0.o mboot2.o biolib.o
		$(BUILD)/bin/ld -s stage2.lnk -o mboot2 \
		  c0.o mboot2.o biolib.o

c0.o:		c0.s
		$(BUILD)/bin/as -o c0.o c0.s

mboot2.o:	mboot2.c
		$(BUILD)/bin/lcc -A -c -o mboot2.o mboot2.c

biolib.o:	biolib.s
		$(BUILD)/bin/as -o biolib.o biolib.s

clean:
		rm -f *~ c0.o mboot2.o biolib.o mboot2 mboot2.bin
