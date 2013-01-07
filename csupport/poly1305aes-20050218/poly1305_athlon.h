/*
poly1305_athlon.h version 20050218
D. J. Bernstein
Public domain.
*/

#ifndef POLY1305_ATHLON_H
#define POLY1305_ATHLON_H

extern void poly1305_athlon(unsigned char out[16],
  const unsigned char r[16],
  const unsigned char s[16],
  const unsigned char m[],unsigned int l);

#ifndef poly1305_implementation
#define poly1305_implementation "poly1305_athlon"
#define poly1305 poly1305_athlon
#endif

#endif
