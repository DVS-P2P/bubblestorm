/*
poly1305aes_aix_authenticate.c version 20050205
D. J. Bernstein
Public domain.
*/

#include "poly1305aes_aix.h"
#include "poly1305_aix.h"
#include "aes_aix.h"

void poly1305aes_aix_authenticate(unsigned char out[16],
  const unsigned char kr[32],
#define k (kr + 0)
#define r (kr + 16)
  const unsigned char n[16],
  const unsigned char m[],unsigned int l)
{
  unsigned char aeskn[16];
  aes_aix(aeskn,k,n);
  poly1305_aix(out,r,aeskn,m,l);
}
