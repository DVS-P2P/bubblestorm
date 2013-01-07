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

#include "curve25519-wes.h"

/* add, sub, mul, sqr, inv, mulC, contract, expand... & these from assembler */
extern void field25519_wes_powq(field25519_t out, const field25519_t a);
extern void curve25519_wes_loop(uint64_t a[20], const exponent_t e, int length);

/* mod p the multiplicative group has order p-1.
 * p-1 = 2^255-20 = 4*3*65147*74058212732561358302231226437062788676166966415465897661863160754340907
 *
 * This means we can represent powers in the multiplicative group as (i, j),
 * where i is [0, 3) and j is [0,r) for odd r=(p-1)/4.
 *
 * When you square an element you double it's power, doubling both i & j.
 * To find a square-root we need to 'undouble' both i & j.
 * The j term is easy to undouble; r is odd so (r+1)/2 is the inverse of 2.
 *
 * The i term has had information destroyed by doubling.
 * If the i term of a is 0
 *   Then it's square-roots have i=0 or i=2.
 *   => we can leave it as 0, which is unaffected by *(r+1)/2
 * If the i term of a is 2 (unaffected by multiplication with r, an odd #)
 *   Then it's square-roots have i=1 or i=3.
 *   We need to adjust the i term by adding +1 or +3, both generators mod 4.
 *   Multiplying 1 or 3 by r leaves them as 1 or 3, but kills the j term.
 *   Thus mul by a generator to the power r to add 1 or 3 w/o changing j.
 * If the i term of a is 1 or 3
 *   Then a is not a square number...
 */
static const field25519_t u = { /* (s-1)/2, s=2^r  (2 is a generator)  */
  UINT64_C(0x00070D93A507504E), 
  UINT64_C(0x00006AD2FE478C4E), 
  UINT64_C(0x0003F7AF4E5E8630), 
  UINT64_C(0x0007C2CAD340264F), 
  UINT64_C(0x00055C1924027E0E)
};

int field25519_wes_sqrt(field25519_t out, const field25519_t a) {
  field25519_t b, z;
  
  field25519_wes_powq(b, a);   /* b = a^(2^252-3) */
  field25519_wes_mul(z, b, a); /* z = a^(2^252-2) = a^((r+1)/2) */
  field25519_wes_sqr(b, b);    /* b = a^(2^253-6) */
  field25519_wes_mul(b, b, a); /* b = a^(2^253-5) = a^r aka +-1 [or +-sqrt(-1)] */
  
  /* if b = 1 then z else z * s ... want to achieve this w/o an 'if' */
  
  /* 1*(1+b)/2 + s*(1-b)/2 = (s+1)/2 - b*(s-1)/2 = 1+u - b*u, u=(s-1)/2 */
  field25519_wes_mul(b, b, u);
  field25519_wes_sub(b, u, b);
  b[0]++;
  
  field25519_wes_mul(out, b, z);
  return 0;
}

void curve25519_wes_mul(curve25519_t out, const curve25519_t a, const curve25519_t b) {
  field25519_t l, m, x;
  /* l =  (Ay - By) * inv (Ax - Bx) */
  field25519_wes_sub(l, &a[5], &b[5]);
  field25519_wes_sub(m, a, b);
  field25519_wes_inv(m, m);
  field25519_wes_mul(l, l, m);
  /* x = l^2 - Ax - Bx - A */
  field25519_wes_sqr(m, l);
  field25519_wes_sub(m, m, a);
  field25519_wes_sub(x, m, b);
  x[0] -= 486662;
  /* y = l * (Ax - x) - Ay */
  field25519_wes_sub(m, a, x);
  field25519_wes_mul(m, l, m);
  field25519_wes_sub(&out[5], m, &a[5]);
  out[0] = x[0]; out[1] = x[1]; out[2] = x[2]; out[3] = x[3]; out[4] = x[4];
}

void curve25519_wes_power(curve25519_t out, const curve25519_t a, const exponent_t e) {
  uint64_t b[20];
  b[0] = a[0]; b[1] = a[1]; b[2] = a[2]; b[3] = a[3]; b[4] = a[4];

  curve25519_wes_loop(b, e, 32);
  field25519_wes_inv(b+ 5, b+ 5);
  field25519_wes_inv(b+15, b+15);
  field25519_wes_mul(b+ 0, b+ 0, b+ 5);
  field25519_wes_mul(b+ 5, b+10, b+15);
  
  /* b+0 = Rx, b+5 = RAx */
  /* c = sqr (Rx - Ax) * (RAx + Rx + Ax + A) */
  field25519_wes_sub(b+10, b+0, a);
  field25519_wes_sqr(b+10, b+10);
  field25519_wes_add(b+5, b+5, b+0);
  field25519_wes_add(b+5, b+5, a);
  b[5] += 486662;
  field25519_wes_mul(b+5, b+5, b+10);
  
  field25519_wes_sqr(b+15, a+5);
  field25519_wes_sub(b+15, b+15, b+5);
  /* b+0 = Rx, b+15 = By2 - c */
  
  /* find Ry2 */
  field25519_wes_sqr(b+10, b+0);
  field25519_wes_mul(b+5, b+10, b+0);
  field25519_wes_mulC(b+10, b+10, 486662);
  field25519_wes_add(b+5, b+5, b+10);
  field25519_wes_add(b+5, b+5, b+0);
  
  field25519_wes_add(b+15, b+15, b+5);
  /* b+0 = Rx, b+15 = Ry2 + By2 - c */
  
  /* (Ay*2)^-1 */
  b[5] = a[5] << 1;
  b[6] = a[6] << 1;
  b[7] = a[7] << 1;
  b[8] = a[8] << 1;
  b[9] = a[9] << 1;
  field25519_wes_inv(b+5, b+5);
  
  field25519_wes_mul(out+5, b+5, b+15);
  out[0] = b[0]; out[1] = b[1]; out[2] = b[2]; out[3] = b[3]; out[4] = b[4];
}

void curve25519_wes_contract(raw25519_t out, const curve25519_t a) {
  field25519_wes_contract(out, a);
}

int curve25519_wes_expand(curve25519_t out, const raw25519_t in) {
  field25519_t tmp;
  int r;
  uint64_t sign;
  
  field25519_wes_expand(out, in);
  field25519_wes_sqr(tmp, out);
  field25519_wes_mul(out+5, tmp, out);
  field25519_wes_mulC(tmp, tmp, 486662);
  field25519_wes_add(out+5, out+5, tmp);
  field25519_wes_add(out+5, out+5, out);
  r = field25519_wes_sqrt(out+5, out+5);
  
  sign = 1 - ((in[31] >> 7) << 1);
  out[5] *= sign; out[6] *= sign; out[7] *= sign; out[8] *= sign; out[9] *= sign;
  
  return r;
}

void curve25519_wes_clamp(exponent_t inout) {
  inout[31] = (inout[31] & 63) | 64;
  inout[0] &= ~7;
}

curve25519_t generator = {
  UINT64_C(0x9),
  UINT64_C(0x0),
  UINT64_C(0x0),
  UINT64_C(0x0),
  UINT64_C(0x0),
  UINT64_C(0x0009C5A27ECED3D9),
  UINT64_C(0x0007CDAF8C36453C),
  UINT64_C(0x000523453248F535),
  UINT64_C(0x00035A700F6E963B),
  UINT64_C(0x00020AE19A1B8A08)
};

void curve25519_wes(raw25519_t outx, const raw25519_t inx, const exponent_t e) {
  uint64_t b[20];

  field25519_wes_expand(b, inx);
  curve25519_wes_loop(b, e, 32);
  field25519_wes_inv(b+5, b+5);
  field25519_wes_mul(b+0, b+0, b+5);
  field25519_wes_contract(outx, b);
}
