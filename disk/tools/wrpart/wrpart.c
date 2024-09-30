/*
 * wrpart.c -- write a binary image to a partition on a disk
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include "gpt.h"


#define SECTOR_SIZE	512


/**************************************************************/


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  printf("Error: ");
  vprintf(fmt, ap);
  printf("\n");
  va_end(ap);
  exit(1);
}


/**************************************************************/


int main(int argc, char *argv[]) {
  char *diskName;
  char *partNo;
  char *partImg;
  FILE *disk;
  unsigned int diskSize;
  char *endp;
  int partNumber;
  GptEntry entry;
  unsigned int partStart;
  unsigned int partSize;
  FILE *image;
  unsigned int imageSize;
  unsigned int i;
  int n;
  unsigned char sectBuf[SECTOR_SIZE];

  /* check command line arguments */
  if (argc != 4) {
    printf("Usage: %s <disk image> ", argv[0]);
    printf("<partition number> <partition image>\n");
    exit(1);
  }
  diskName = argv[1];
  partNo = argv[2];
  partImg = argv[3];
  disk = fopen(diskName, "r+b");
  if (disk == NULL) {
    error("cannot open disk image '%s'", diskName);
  }
  fseek(disk, 0, SEEK_END);
  diskSize = ftell(disk) / SECTOR_SIZE;
  printf("disk '%s' has %u (0x%X) sectors\n",
         diskName, diskSize, diskSize);
  /* get partition number, determine start and size of partition */
  partNumber = strtol(partNo, &endp, 0);
  if (*endp != '\0') {
    error("cannot read partition number '%s'", partNo);
  }
  gptRead(disk, diskSize);
  gptGetEntry(partNumber, &entry);
  if (strcmp(entry.type, GPT_NULL_UUID) == 0) {
    error("partition %d is not used", partNumber);
  }
  partStart = entry.start;
  partSize = entry.end - entry.start + 1;
  printf("partition %d: start sector %u (0x%X), size is %u (0x%X) sectors\n",
         partNumber, partStart, partStart, partSize, partSize);
  if (partStart >= diskSize || partStart + partSize > diskSize) {
    error("partition %d is larger than the disk", partNumber);
  }
  fseek(disk, partStart * SECTOR_SIZE, SEEK_SET);
  /* open partition image, check size (rounded up to whole sectors) */
  image = fopen(partImg, "rb");
  if (image == NULL) {
    error("cannot open partition image '%s'", partImg);
  }
  fseek(image, 0, SEEK_END);
  imageSize = (ftell(image) + SECTOR_SIZE - 1) / SECTOR_SIZE;
  printf("partition image '%s' occupies %d (0x%X) sectors\n",
         partImg, imageSize, imageSize);
  if (imageSize > partSize) {
    error("partition image (%d sectors) too big for partition (%d sectors)",
          imageSize, partSize);
  }
  fseek(image, 0, SEEK_SET);
  /* copy partition image to partition on disk */
  for (i = 0; i < imageSize; i++) {
    n = fread(sectBuf, 1, SECTOR_SIZE, image);
    if (n != SECTOR_SIZE) {
      if (i != imageSize - 1) {
        error("cannot read partition image '%s'", partImg);
      } else {
        while (n < SECTOR_SIZE) {
          sectBuf[n++] = 0;
        }
      }
    }
    n = fwrite(sectBuf, 1, SECTOR_SIZE, disk);
    if (n != SECTOR_SIZE) {
      error("cannot write disk image '%s'", diskName);
    }
  }
  printf("partition image '%s' (%d sectors) copied to partition %d\n",
         partImg, imageSize, partNumber);
  fclose(image);
  fclose(disk);
  return 0;
}
