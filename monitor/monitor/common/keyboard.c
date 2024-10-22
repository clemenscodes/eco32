/*
 * keyboard.c -- keyboard input
 */


#include "common.h"


#define KBD_BASE	((unsigned int *) 0xF0200000)
#define KBD_CTRL	(KBD_BASE + 0)
#define KBD_DATA	(KBD_BASE + 1)

#define KBD_RDY		0x01


extern Byte kbdTbl1[];
extern Byte kbdTbl2[];

static Bool recd;
static Bool up;
static Bool shift;
static Bool ctrl;
static Bool alt;
static Bool ext;

static Byte kbdCode;


static void peek(void) {
  if ((*KBD_CTRL) & KBD_RDY) {
    kbdCode = *KBD_DATA;
    if (kbdCode == 0xF0) {
      up = true;
    } else
    if (kbdCode == 0xE0) {
      ext = true;
    } else {
      if (kbdCode == 0x12 || kbdCode == 0x59) {
        /* shift */
        shift = !up;
      } else
      if (kbdCode == 0x14) {
        /* ctrl */
        ctrl = !up;
      } else
      if (kbdCode == 0x11) {
        /* alt */
        alt = !up;
      } else
      if (!up) {
        /* real key going down */
        recd = true;
      }
      up = false;
      ext = false;
    }
  }
}


/**************************************************************/


void kbdinit(void) {
  recd = false;
  up = false;
  shift = false;
  ctrl = false;
  alt = false;
  ext = false;
  if ((*KBD_CTRL) & KBD_RDY) {
    kbdCode = *KBD_DATA;
  }
}


Bool kbdinchk(void) {
  peek();
  return recd;
}


char kbdin(void) {
  char ch;

  while (!recd) {
    peek();
  }
  if (shift || ctrl) {
    /* ctrl implies shift */
    kbdCode |= 0x80;
  }
  ch = alt ? kbdTbl2[kbdCode] : kbdTbl1[kbdCode];
  if (ctrl) {
    ch &= 0x1F;
  }
  recd = false;
  return ch;
}
