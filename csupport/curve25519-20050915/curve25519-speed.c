/*
	This file is part of BubbleStorm.
	Copyright © 2008-2013 the BubbleStorm authors

	BubbleStorm is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	BubbleStorm is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with BubbleStorm.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
curve25519-speed.c version 20050915
D. J. Bernstein
Public domain.
*/

#include <time.h>
#include <sys/time.h>
#include <stdio.h>
#include "curve25519.h"
#include "cpucycles.h"

long long tstart;  struct timeval tvstart;
long long tfinish; struct timeval tvfinish;

long long t[21];
long long buf[16384];

main()
{
  unsigned char *ek;
  unsigned char *e;
  unsigned char *k;
  int i;
  int j;

  printf("%s %s\n",curve25519_implementation,cpucycles_implementation);
  tstart = cpucycles(); gettimeofday(&tvstart,0);

  for (i = 0;i < sizeof buf;++i) i[(char *) buf] = random();

  for (j = 0;j < 10;++j) {
    ek = (unsigned char *) buf;
    e = ek + 32;
    k = e + 32;
    for (i = 0;i <= 20;++i) t[i] = cpucycles();
    for (i = 0;i <= 20;++i) {
      t[i] = cpucycles();
      curve25519(ek,e,k);
      ek += 128;
      e += 128;
      k += 128;
    }
    for (i = 0;i < 20;++i) printf(" %5lld",t[i + 1] - t[i]);
    printf("\n");
    fflush(stdout);
    for (i = 0;i < sizeof buf - 128;++i) i[(char *) buf] = i[128 + (char *) buf];
  }

  tfinish = cpucycles(); gettimeofday(&tvfinish,0);
  printf("%lld cycles\n"
    ,tfinish - tstart);
  printf("%lld usecs\n"
    ,(tvfinish.tv_sec - tvstart.tv_sec) * 1000000LL + (tvfinish.tv_usec - tvstart.tv_usec));
  printf("%f MHz\n"
    ,(tfinish - tstart) * 1.0 / ((tvfinish.tv_sec - tvstart.tv_sec) * 1000000LL + (tvfinish.tv_usec - tvstart.tv_usec)));

  return 0;

}
