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

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "poly1305aes-20050218/aes.h"
#include "poly1305aes-20050218/poly1305aes.h"

unsigned char nonce[16];
unsigned char kr[32] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
unsigned char mac[16];
unsigned char* block;
int fd;

/* Essentially a profiling tool to compare vs. md5sum/cksum */
int main (int argc, char** argv) {
  void* tmp;
  off_t len, align;
  int i;
  
  if (argc != 2) {
    fprintf(stderr, "Syntax: %s <filename>\n", argv[0]);
    return 1;
  }
  
  if ((fd = open(argv[1], O_RDONLY)) == -1) {
    perror(argv[1]);
    return 1;
  }
  
  len = lseek(fd, 0, SEEK_END);
  align = (len + 4095) & ~0x8ffUL;
  if ((tmp = mmap(0, align, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0)) == MAP_FAILED) {
    perror("mmap");
    return 1;
  }
  block = (unsigned char*)tmp;
  
  memset(nonce, 0, sizeof(nonce));
  poly1305aes_clamp(kr);
  poly1305aes_authenticate(mac,kr,nonce,block,len);
  
  for (i = 0; i < 16; ++i)
    printf("%02x", mac[i]);
  printf("\n");
  return 0;
}
