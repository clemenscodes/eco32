/*
 * mboot.c -- the master bootstrap (boot manager)
 */


#include "stdarg.h"
#include "biolib.h"


#define DEFAULT_PARTITION	""      /* default boot partition number */

#define LOAD_ADDR		((unsigned char *) 0xC0010000)

#define LINE_SIZE		80


unsigned int bootDisk = 0;	/* gets loaded by previous stage */
unsigned int startSector = 0;	/* gets loaded by previous stage */
unsigned int numSectors = 0;	/* gets loaded by previous stage */


int strlen(char *str) {
  int i;

  i = 0;
  while (*str++ != '\0') {
    i++;
  }
  return i;
}


void strcpy(char *dst, char *src) {
  while ((*dst++ = *src++) != '\0') ;
}


char getchar(void) {
  return getc();
}


void putchar(char c) {
  if (c == '\n') {
    putchar('\r');
  }
  putc(c);
}


void puts(char *s) {
  char c;

  while ((c = *s++) != '\0') {
    putchar(c);
  }
}


void getline(char *prompt, char *line, int n) {
  int i;
  char c;

  puts(prompt);
  puts(line);
  i = strlen(line);
  while (i < n - 1) {
    c = getchar();
    if (c >= ' ' && c < 0x7F) {
      putchar(c);
      line[i] = c;
      i++;
    } else
    if (c == '\r') {
      putchar('\n');
      line[i] = '\0';
      i = n - 1;
    } else
    if (c == '\b' || c == 0x7F) {
      if (i > 0) {
        putchar('\b');
        putchar(' ');
        putchar('\b');
        i--;
      }
    }
  }
  line[n - 1] = '\0';
}


int countPrintn(int n) {
  int a;
  int res;

  res = 0;
  if (n < 0) {
    res++;
    n = -n;
  }
  a = n / 10;
  if (a != 0) {
    res += countPrintn(a);
  }
  return res + 1;
}


void printn(int n) {
  int a;

  if (n < 0) {
    putchar('-');
    n = -n;
  }
  a = n / 10;
  if (a != 0) {
    printn(a);
  }
  putchar(n % 10 + '0');
}


void printf(char *fmt, ...) {
  va_list ap;
  char c;
  int n;
  unsigned int u;
  char *s;
  char filler;
  int width, count, i;

  va_start(ap, fmt);
  while (1) {
    while ((c = *fmt++) != '%') {
      if (c == '\0') {
        va_end(ap);
        return;
      }
      putchar(c);
    }
    c = *fmt++;
    if (c == '0') {
      filler = '0';
      c = *fmt++;
    } else {
      filler = ' ';
    }
    width = 0;
    if (c >= '0' && c <= '9') {
      width = c - '0';
      c = *fmt++;
    }
    if (c == 'd') {
      n = va_arg(ap, int);
      if (width > 0) {
        count = countPrintn(n);
        for (i = 0; i < width - count; i++) {
          putchar(filler);
        }
      }
      printn(n);
    } else
    if (c == 's') {
      s = va_arg(ap, char *);
      puts(s);
    } else
    if (c == 'c') {
      c = va_arg(ap, char);
      putchar(c);
    } else {
      putchar(c);
    }
  }
}


void halt(void) {
  printf("Bootstrap halted\n");
  while (1) ;
}


void readDisk(unsigned int sector, unsigned char *buffer, int count) {
  int result;

  if (sector + count > numSectors) {
    printf("sector number exceeds disk or partition size\n");
    halt();
  }
  result = rwscts(bootDisk, 'r', sector + startSector,
                  (unsigned int) buffer & 0x3FFFFFFF, count);
  if (result != 0) {
    printf("disk read error\n");
    halt();
  }
}


unsigned int entryPoint;	/* where to continue from main() */


unsigned char partTbl[32 * 512];


unsigned int get4LE(unsigned char *addr) {
  return (((unsigned int) *(addr + 0)) <<  0) |
         (((unsigned int) *(addr + 1)) <<  8) |
         (((unsigned int) *(addr + 2)) << 16) |
         (((unsigned int) *(addr + 3)) << 24);
}


int isZero(unsigned char *buf, int len) {
  unsigned char res;
  int i;

  res = 0;
  for (i = 0; i < len; i++) {
    res |= buf[i];
  }
  return res == 0;
}


int main(void) {
  char line[LINE_SIZE];
  int i;
  unsigned char *p;
  int j;
  char c;
  int part;
  char *lp;
  unsigned int partStart;
  unsigned int partEnd;
  unsigned int partSize;
  unsigned int instCheck;

  printf("Bootstrap manager executing...\n");
  strcpy(line, DEFAULT_PARTITION);
  /* read primary partition table */
  readDisk(2, partTbl, 32);
  /* repeat until success or halt */
  while (1) {
    /* show partitions */
    printf("\nPartitions:\n");
    printf("  # | description\n");
    printf("----+----------------------\n");
    for (i = 0; i < 128; i++) {
      p = &partTbl[i * 128];
      if (isZero(p, 16)) {
        /* not used */
        continue;
      }
      printf("%3d | ", i + 1);
      for (j = 0; j < 36; j++) {
        c = *(p + 56 + 2 * j);
        if (c == 0) {
          break;
        }
        printf("%c", c);
      }
      printf("\n");
    }
    /* ask for partition to boot */
    getline("\nBoot partition #: ", line, LINE_SIZE);
    /* analyze answer */
    if (line[0] == '\0') {
      continue;
    }
    part = 0;
    lp = line;
    while (*lp >= '0' && *lp <= '9') {
      part = part * 10 + (*lp - '0');
      lp++;
    }
    if (*lp != '\0' || part < 1 || part > 128) {
      printf("illegal partition number\n");
      continue;
    }
    p = &partTbl[(part - 1) * 128];
    if (isZero(p, 16)) {
      /* not used */
      printf("partition %d is not in use\n", part);
      continue;
    }
    partStart = get4LE(p + 32);
    partEnd = get4LE(p + 40);
    partSize = partEnd - partStart + 1;
    /* load boot sector of selected partition */
    readDisk(partStart, LOAD_ADDR, 1);
    if (*(LOAD_ADDR + 510) != 0x55 ||
        *(LOAD_ADDR + 511) != 0xAA) {
      printf("PBR signature missing!\n");
      continue;
    }
    instCheck = 0;
    instCheck |= *(LOAD_ADDR +  0);
    instCheck |= *(LOAD_ADDR +  4);
    instCheck |= *(LOAD_ADDR +  8);
    instCheck |= *(LOAD_ADDR + 12);
    if (instCheck == 0) {
      printf("PBR lacks proper instructions in the first 4 words!\n");
      continue;
    }
    /* we have a valid boot sector, leave loop */
    break;
  }
  /* boot manager finished, now go executing loaded boot sector */
  startSector = partStart;
  numSectors = partSize;
  entryPoint = (unsigned int) LOAD_ADDR;
  return 0;
}
