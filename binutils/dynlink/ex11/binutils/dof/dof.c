/*
 * dof.c -- dump object file
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include "eof.h"
#include "common.h"
#include "instr.h"
#include "disasm.h"


/**************************************************************/


FILE *inFile;
EofHeader inFileHeader;
SegmentRecord *segmentTable;
SymbolRecord *symbolTable;
RelocRecord *relocTable;


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


void warning(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  printf("Warning: ");
  vprintf(fmt, ap);
  printf("\n");
  va_end(ap);
}


void *memAlloc(unsigned int size) {
  void *p;

  p = malloc(size);
  if (p == NULL) {
    error("out of memory");
  }
  return p;
}


void memFree(void *p) {
  if (p == NULL) {
    error("memFree() got NULL pointer");
  }
  free(p);
}


/**************************************************************/


unsigned int read4FromEco(unsigned char *p) {
  return (unsigned int) p[0] << 24 |
         (unsigned int) p[1] << 16 |
         (unsigned int) p[2] <<  8 |
         (unsigned int) p[3] <<  0;
}


void write4ToEco(unsigned char *p, unsigned int data) {
  p[0] = data >> 24;
  p[1] = data >> 16;
  p[2] = data >>  8;
  p[3] = data >>  0;
}


void conv4FromEcoToNative(unsigned char *p) {
  unsigned int data;

  data = read4FromEco(p);
  * (unsigned int *) p = data;
}


void conv4FromNativeToEco(unsigned char *p) {
  unsigned int data;

  data = * (unsigned int *) p;
  write4ToEco(p, data);
}


/**************************************************************/


void dumpBytes(unsigned int totalSize) {
  unsigned int currSize;
  unsigned char line[16];
  int n, i;
  unsigned char c;

  currSize = 0;
  while (currSize < totalSize) {
    if (totalSize - currSize >= 16) {
      n = 16;
    } else {
      n = totalSize - currSize;
    }
    for (i = 0; i < n; i++) {
      line[i] = fgetc(inFile);
    }
    printf("%08X:  ", currSize);
    for (i = 0; i < 16; i++) {
      if (i < n) {
        c = line[i];
        printf("%02X", c);
      } else {
        printf("  ");
      }
      printf(" ");
    }
    printf("  ");
    for (i = 0; i < 16; i++) {
      if (i < n) {
        c = line[i];
        if (c >= 32 && c <= 126) {
          printf("%c", c);
        } else {
          printf(".");
        }
      } else {
        printf(" ");
      }
    }
    printf("\n");
    currSize += n;
  }
}


unsigned int dumpString(unsigned int offset) {
  long pos;
  int c;

  pos = ftell(inFile);
  if (fseek(inFile, inFileHeader.ostrs + offset, SEEK_SET) < 0) {
    error("cannot seek to string");
  }
  while (1) {
    c = fgetc(inFile);
    offset++;
    if (c == EOF) {
      error("unexpected end of file");
    }
    if (c == 0) {
      break;
    }
    fputc(c, stdout);
  }
  fseek(inFile, pos, SEEK_SET);
  return offset;
}


/**************************************************************/


void disasmInstrs(unsigned int virtAddr, unsigned int numInstrs) {
  unsigned int addr;
  unsigned int i;
  unsigned char c[4];
  unsigned int instr;

  addr = virtAddr;
  for (i = 0; i < numInstrs; i++) {
    c[0] = fgetc(inFile);
    c[1] = fgetc(inFile);
    c[2] = fgetc(inFile);
    c[3] = fgetc(inFile);
    instr = read4FromEco(c);
    printf("%08X:  %08X    %s\n",
           addr, instr, disasm(instr, addr));
    addr += 4;
  }
}


/**************************************************************/


void readHeader(void) {
  if (fseek(inFile, 0, SEEK_SET) < 0) {
    error("cannot seek to exec header");
  }
  if (fread(&inFileHeader, sizeof(EofHeader), 1, inFile) != 1) {
    error("cannot read exec header");
  }
  conv4FromEcoToNative((unsigned char *) &inFileHeader.magic);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.osegs);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.nsegs);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.osyms);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.nsyms);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.orels);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.nrels);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.odata);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.sdata);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.ostrs);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.sstrs);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.entry);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.olibs);
  conv4FromEcoToNative((unsigned char *) &inFileHeader.nlibs);
}


void dumpHeader(void) {
  char *type;
  unsigned int offset;
  int i;

  if (inFileHeader.magic != EOF_R_MAGIC &&
      inFileHeader.magic != EOF_X_MAGIC &&
      inFileHeader.magic != EOF_D_MAGIC) {
    error("wrong magic number in object header");
  }
  switch (inFileHeader.magic) {
    case EOF_R_MAGIC:
      type = "relocatable";
      break;
    case EOF_X_MAGIC:
      type = "executable";
      break;
    case EOF_D_MAGIC:
      type = "dynamic library";
      break;
  }
  printf("Header\n");
  printf("    magic number              : EOF %s\n", type);
  printf("    offset of segment table   : 0x%08X\n", inFileHeader.osegs);
  printf("    number of segment entries : %10u\n", inFileHeader.nsegs);
  printf("    offset of symbol table    : 0x%08X\n", inFileHeader.osyms);
  printf("    number of symbol entries  : %10u\n", inFileHeader.nsyms);
  printf("    offset of reloc table     : 0x%08X\n", inFileHeader.orels);
  printf("    number of reloc entries   : %10u\n", inFileHeader.nrels);
  printf("    offset of segment data    : 0x%08X\n", inFileHeader.odata);
  printf("    size of segment data      : 0x%08X\n", inFileHeader.sdata);
  printf("    offset of string space    : 0x%08X\n", inFileHeader.ostrs);
  printf("    size of string space      : 0x%08X\n", inFileHeader.sstrs);
  printf("    entry point               : 0x%08X\n", inFileHeader.entry);
  printf("    dynamic libs needed       : %10u\n", inFileHeader.nlibs);
  offset = inFileHeader.olibs;
  for (i = 0; i < inFileHeader.nlibs; i++) {
    printf("        name = ");
    offset = dumpString(offset);
    printf("\n");
  }
}


/**************************************************************/


void readSegmentTable(void) {
  int sn;

  segmentTable = memAlloc(inFileHeader.nsegs * sizeof(SegmentRecord));
  if (fseek(inFile, inFileHeader.osegs, SEEK_SET) < 0) {
    error("cannot seek to segment table");
  }
  for (sn = 0; sn < inFileHeader.nsegs; sn++) {
    if (fread(&segmentTable[sn], sizeof(SegmentRecord), 1, inFile) != 1) {
      error("cannot read segment record %d", sn);
    }
    conv4FromEcoToNative((unsigned char *) &segmentTable[sn].name);
    conv4FromEcoToNative((unsigned char *) &segmentTable[sn].offs);
    conv4FromEcoToNative((unsigned char *) &segmentTable[sn].addr);
    conv4FromEcoToNative((unsigned char *) &segmentTable[sn].size);
    conv4FromEcoToNative((unsigned char *) &segmentTable[sn].attr);
  }
}


void dumpSegmentTable(void) {
  int sn;

  printf("\nSegment Table\n");
  if (inFileHeader.nsegs == 0) {
    printf("<empty>\n");
    return;
  }
  for (sn = 0; sn < inFileHeader.nsegs; sn++) {
    printf("    %d:\n", sn);
    printf("        name = ");
    dumpString(segmentTable[sn].name);
    printf("\n");
    printf("        offs = 0x%08X\n", segmentTable[sn].offs);
    printf("        addr = 0x%08X\n", segmentTable[sn].addr);
    printf("        size = 0x%08X\n", segmentTable[sn].size);
    printf("        attr = ");
    if (segmentTable[sn].attr & SEG_ATTR_A) {
      printf("A");
    } else {
      printf("-");
    }
    if (segmentTable[sn].attr & SEG_ATTR_P) {
      printf("P");
    } else {
      printf("-");
    }
    if (segmentTable[sn].attr & SEG_ATTR_W) {
      printf("W");
    } else {
      printf("-");
    }
    if (segmentTable[sn].attr & SEG_ATTR_X) {
      printf("X");
    } else {
      printf("-");
    }
    printf("\n");
  }
}


/**************************************************************/


void readSymbolTable(void) {
  int sn;

  symbolTable = memAlloc(inFileHeader.nsyms * sizeof(SymbolRecord));
  if (fseek(inFile, inFileHeader.osyms, SEEK_SET) < 0) {
    error("cannot seek to symbol table");
  }
  for (sn = 0; sn < inFileHeader.nsyms; sn++) {
    if (fread(&symbolTable[sn], sizeof(SymbolRecord), 1, inFile) != 1) {
      error("cannot read symbol record %d", sn);
    }
    conv4FromEcoToNative((unsigned char *) &symbolTable[sn].name);
    conv4FromEcoToNative((unsigned char *) &symbolTable[sn].val);
    conv4FromEcoToNative((unsigned char *) &symbolTable[sn].seg);
    conv4FromEcoToNative((unsigned char *) &symbolTable[sn].attr);
  }
}


void dumpSymbolTable(void) {
  int sn;

  printf("\nSymbol Table\n");
  if (inFileHeader.nsyms == 0) {
    printf("<empty>\n");
    return;
  }
  for (sn = 0; sn < inFileHeader.nsyms; sn++) {
    printf("    %d:\n", sn);
    printf("        name = ");
    dumpString(symbolTable[sn].name);
    printf("\n");
    printf("        val  = 0x%08X\n", symbolTable[sn].val);
    printf("        seg  = %d\n", symbolTable[sn].seg);
    printf("        attr = ");
    if (symbolTable[sn].attr & SYM_ATTR_U) {
      printf("U");
    } else {
      printf("D");
    }
    printf("\n");
  }
}


/**************************************************************/


void readRelocTable(void) {
  int rn;

  relocTable = memAlloc(inFileHeader.nrels * sizeof(RelocRecord));
  if (fseek(inFile, inFileHeader.orels, SEEK_SET) < 0) {
    error("cannot seek to relocation table");
  }
  for (rn = 0; rn < inFileHeader.nrels; rn++) {
    if (fread(&relocTable[rn], sizeof(RelocRecord), 1, inFile) != 1) {
      error("cannot read relocation record %d", rn);
    }
    conv4FromEcoToNative((unsigned char *) &relocTable[rn].loc);
    conv4FromEcoToNative((unsigned char *) &relocTable[rn].seg);
    conv4FromEcoToNative((unsigned char *) &relocTable[rn].typ);
    conv4FromEcoToNative((unsigned char *) &relocTable[rn].ref);
    conv4FromEcoToNative((unsigned char *) &relocTable[rn].add);
  }
}


void dumpRelocTable(void) {
  int rn;

  printf("\nRelocation Table\n");
  if (inFileHeader.nrels == 0) {
    printf("<empty>\n");
    return;
  }
  for (rn = 0; rn < inFileHeader.nrels; rn++) {
    printf("    %d:\n", rn);
    printf("        loc  = 0x%08X\n", relocTable[rn].loc);
    printf("        seg  = ");
    if (relocTable[rn].seg == -1) {
      printf("*none*");
    } else {
      printf("%d", relocTable[rn].seg);
    }
    printf("\n");
    printf("        typ  = ");
    switch (relocTable[rn].typ & ~RELOC_SYM) {
      case RELOC_H16:
        printf("H16");
        break;
      case RELOC_L16:
        printf("L16");
        break;
      case RELOC_R16:
        printf("R16");
        break;
      case RELOC_R26:
        printf("R26");
        break;
      case RELOC_W32:
        printf("W32");
        break;
      case RELOC_GA_H16:
        printf("GA_H16");
        break;
      case RELOC_GA_L16:
        printf("GA_L16");
        break;
      case RELOC_GR_H16:
        printf("GR_H16");
        break;
      case RELOC_GR_L16:
        printf("GR_L16");
        break;
      case RELOC_GP_L16:
        printf("GP_L16");
        break;
      case RELOC_ER_W32:
        printf("ER_W32");
        break;
      default:
        printf("\n");
        error("unknown relocation type 0x%08X", relocTable[rn].typ);
    }
    printf("\n");
    printf("        ref  = ");
    if (relocTable[rn].ref == -1) {
      printf("*none*");
    } else {
      printf("%s # %d",
             relocTable[rn].typ & RELOC_SYM ? "symbol" : "segment",
             relocTable[rn].ref);
    }
    printf("\n");
    printf("        add  = 0x%08X\n", relocTable[rn].add);
  }
}


/**************************************************************/


void dumpData(int sn, int disassemble) {
  unsigned int offs;
  unsigned int addr;
  unsigned int size;

  printf("\nData of Segment %d\n", sn);
  if (!(segmentTable[sn].attr & SEG_ATTR_P)) {
    printf("<not present>\n");
    return;
  }
  offs = segmentTable[sn].offs;
  addr = segmentTable[sn].addr;
  size = segmentTable[sn].size;
  if (size == 0) {
    printf("<empty>\n");
    return;
  }
  if (fseek(inFile, inFileHeader.odata + offs, SEEK_SET) < 0) {
    error("cannot seek to segment data");
  }
  if (disassemble) {
    if (size & 3) {
      warning("segment size not a multiple of 4, last few bytes not shown");
    }
    disasmInstrs(addr, size >> 2);
  } else {
    dumpBytes(size);
  }
}


/**************************************************************/


void usage(char *myself) {
  printf("Usage: %s\n", myself);
  printf("         [-s]             dump symbol table\n");
  printf("         [-r]             dump relocations\n");
  printf("         [-d <n>]         dump data in segment <n>\n");
  printf("         [-D <n>]         disassemble data in segment <n>\n");
  printf("         [-a]             dump all\n");
  printf("         file             object file to be dumped\n");
  exit(1);
}


int main(int argc, char *argv[]) {
  int i;
  char *argp;
  char *inName;
  int optionSymbols;
  int optionRelocs;
  int optionData;
  int sn;
  char *endptr;

  inName = NULL;
  optionSymbols = 0;
  optionRelocs = 0;
  optionData = 0;
  for (i = 1; i < argc; i++) {
    argp = argv[i];
    if (*argp == '-') {
      argp++;
      switch (*argp) {
        case 's':
          optionSymbols = 1;
          break;
        case 'r':
          optionRelocs = 1;
          break;
        case 'd':
          optionData = 1;
          if (i == argc - 1) {
            error("option -d is missing a segment number");
          }
          sn = strtol(argv[++i], &endptr, 0);
          if (*endptr != '\0') {
            error("cannot read segment number in option -d");
          }
          break;
        case 'D':
          optionData = 2;
          if (i == argc - 1) {
            error("option -D is missing a segment number");
          }
          sn = strtol(argv[++i], &endptr, 0);
          if (*endptr != '\0') {
            error("cannot read segment number in option -D");
          }
          break;
        case 'a':
          optionSymbols = 1;
          optionRelocs = 1;
          optionData = 3;
          break;
        default:
          usage(argv[0]);
      }
    } else {
      if (inName != NULL) {
        usage(argv[0]);
      }
      inName = argp;
    }
  }
  if (inName == NULL) {
    usage(argv[0]);
  }
  inFile = fopen(inName, "r");
  if (inFile == NULL) {
    error("cannot open input file '%s'", inName);
  }
  initInstrTable();
  readHeader();
  dumpHeader();
  readSegmentTable();
  dumpSegmentTable();
  if (optionSymbols) {
    readSymbolTable();
    dumpSymbolTable();
  }
  if (optionRelocs) {
    readRelocTable();
    dumpRelocTable();
  }
  if (optionData) {
    if (optionData == 1) {
      if (sn < 0 || sn >= inFileHeader.nsegs) {
        error("option -d has illegal segment number %d", sn);
      }
      dumpData(sn, 0);
    } else
    if (optionData == 2) {
      if (sn < 0 || sn >= inFileHeader.nsegs) {
        error("option -D has illegal segment number %d", sn);
      }
      dumpData(sn, 1);
    } else {
      for (sn = 0; sn < inFileHeader.nsegs; sn++) {
        dumpData(sn, 0);
      }
    }
  }
  fclose(inFile);
  return 0;
}