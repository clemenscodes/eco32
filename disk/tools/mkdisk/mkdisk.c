/*
 * mkdisk.c -- make an empty 'physical' disk (sparse disk image file)
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <unistd.h>
#include <fcntl.h>


#define SECTOR_SIZE		512
#define SECTORS_PER_MB		((1 << 20) / SECTOR_SIZE)
#define SECTORS_PER_GB		((1 << 30) / SECTOR_SIZE)
#define MIN_NUMBER_SECTORS	((long) 128)
#define MAX_NUMBER_SECTORS	((long) 2048 * SECTORS_PER_GB)
#define DATA_BYTE		0xE5


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  fprintf(stderr, "Error: ");
  vfprintf(stderr, fmt, ap);
  fprintf(stderr, "\n");
  va_end(ap);
  exit(1);
}


void usage(void) {
  fprintf(stderr, "Usage: mkdisk <file name> <n>[M|G]\n");
  fprintf(stderr, "       <n>: decimal number of sectors\n");
  fprintf(stderr, "       if 'M' appended: MiB instead of sectors\n");
  fprintf(stderr, "       if 'G' appended: GiB instead of sectors\n");
  fprintf(stderr, "       (sector size is always %d bytes)\n", SECTOR_SIZE);
  exit(1);
}


int main(int argc, char *argv[]) {
  int dskFile;
  long numSectors;
  unsigned char sectorBuffer[SECTOR_SIZE];
  int i;

  if (argc != 3) {
    usage();
  }
  numSectors = atol(argv[2]);
  i = strlen(argv[2]) - 1;
  if (argv[2][i] == 'M') {
    numSectors *= SECTORS_PER_MB;
  } else
  if (argv[2][i] == 'G') {
    numSectors *= SECTORS_PER_GB;
  }
  if (numSectors < MIN_NUMBER_SECTORS) {
    error("disk is too small to be useful (minimum size is %ld sectors)",
          MIN_NUMBER_SECTORS);
  }
  if (numSectors > MAX_NUMBER_SECTORS) {
    error("disk capacity exceeds sector address limit (%ld sectors)",
          MAX_NUMBER_SECTORS);
  }
  dskFile = open(argv[1], O_CREAT | O_WRONLY, 0666);
  if (dskFile < 0) {
    error("cannot open file '%s' for write", argv[1]);
  }
  fprintf(stdout,
          "Creating disk '%s' with %ld sectors (around %ld MB)...\n",
          argv[1], numSectors,
          (numSectors + SECTORS_PER_MB / 2) / SECTORS_PER_MB);
  for (i = 0; i < SECTOR_SIZE; i++) {
    sectorBuffer[i] = DATA_BYTE;
  }
  if (lseek(dskFile, 0, SEEK_SET) < 0) {
    error("cannot seek to begin of file '%s'", argv[1]);
  }
  if (write(dskFile, sectorBuffer, SECTOR_SIZE) != SECTOR_SIZE) {
    error("cannot write first sector of file '%s'", argv[1]);
  }
  if (lseek(dskFile, (numSectors - 1) * SECTOR_SIZE, SEEK_SET) < 0) {
    error("cannot seek to end of file '%s'", argv[1]);
  }
  if (write(dskFile, sectorBuffer, SECTOR_SIZE) != SECTOR_SIZE) {
    error("cannot write last sector of file '%s'", argv[1]);
  }
  close(dskFile);
  return 0;
}
