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

#include <signal.h>

void nope()
{
  exit(1);
}

int main()
{
  unsigned long x[4];
  unsigned long y[4];
  int i;
  int j;
  char c;

  signal(SIGILL,nope);

  x[0] = 0;
  x[1] = 0;
  x[2] = 0;
  x[3] = 0;

  asm volatile(".byte 15;.byte 162" : "=a"(x[0]),"=b"(x[1]),"=c"(x[3]),"=d"(x[2]) : "0"(0) );
  if (!x[0]) return 0;
  asm volatile(".byte 15;.byte 162" : "=a"(y[0]),"=b"(y[1]),"=c"(y[2]),"=d"(y[3]) : "0"(1) );

  for (i = 1;i < 4;++i)
    for (j = 0;j < 4;++j) {
      c = x[i] >> (8 * j);
      if (c < 32) c = 32;
      if (c > 126) c = 126;
      putchar(c);
    }

  printf("-%08x-%08x\n",y[0],y[3]);

  return 0;
}
