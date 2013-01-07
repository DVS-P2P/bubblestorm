              #                     lin  win
int64 counter #  4                  rcx  r9

int64 a0      #  6                  r9   r10
int64 a51     #  1  <---- WARNING   rdi  rcx
int64 a102    #  8                  r10  r12
int64 a153    #  9                  r11  r13
int64 a204    # 10                  r12  r14

int64 b0      # 11                  r13  r15
int64 b51     # 12                  r14  rdi
int64 b102    # 13                  r15  rsi
int64 b153    # 14                  rbx  rbp
int64 b204    # 15                  rbp  rbx

int64 tmp0
int64 tmp1
int64 tmp2
int64 tmp3

int6464 c0    #  1
int6464 c51   #  2
int6464 c102  #  3
int6464 c153  #  4
int6464 c204  #  5

int6464 d0    #  6
int6464 d51   #  7
int6464 d102  #  8
int6464 d153  #  9
int6464 d204  # 10

int6464 e0    # 11
int6464 e51   # 12
int6464 e102  # 13
int6464 e153  # 14
int6464 e204  # 15

int6464 mask # 16
int6464 one

int3232 f0   # 1
int3232 f51  # 2
int3232 f102 # 3
int3232 f153 # 4
int3232 f204 # 5

stack256 exponent_stack

int64 exponent
int64 source
int64 length

int3232 exp64
int3232 oldbit
int3232 newbit

int6464 xmm6
int6464 xmm7
int6464 xmm8
int6464 xmm9
int6464 xmm10
int6464 xmm11
int6464 xmm12
int6464 xmm13
int6464 xmm14
int6464 xmm15

int64 r11
int64 r12
int64 r13
int64 r14
int64 r15
#MINGW int64 rdi
#MINGW int64 rsi
int64 rbx
int64 rbp

stack128 xmm6_stack
stack128 xmm7_stack
stack128 xmm8_stack
stack128 xmm9_stack
stack128 xmm10_stack
stack128 xmm11_stack
stack128 xmm12_stack
stack128 xmm13_stack
stack128 xmm14_stack
stack128 xmm15_stack

stack64 r11_stack
stack64 r12_stack
stack64 r13_stack
stack64 r14_stack
stack64 r15_stack
#MINGW stack64 rdi_stack
#MINGW stack64 rsi_stack
stack64 rbx_stack
stack64 rbp_stack

caller xmm6
caller xmm7
caller xmm8
caller xmm9
caller xmm10
caller xmm11
caller xmm12
caller xmm13
caller xmm14
caller xmm15

caller r11
caller r12
caller r13
caller r14
caller r15
#MINGW caller rdi
#MINGW caller rsi
caller rbx
caller rbp

int64 a
int64 e
int64 l

stack64 a_stack

input a
input e
input l

enter curve25519_wes_loop
  xmm6_stack = xmm6
  xmm7_stack = xmm7
  xmm8_stack = xmm8
  xmm9_stack = xmm9
  xmm10_stack = xmm10
  xmm11_stack = xmm11
  xmm12_stack = xmm12
  xmm13_stack = xmm13
  xmm14_stack = xmm14
  xmm15_stack = xmm15

  r11_stack = r11
  r12_stack = r12
  r13_stack = r13
  r14_stack = r14
  r15_stack = r15
#MINGW  rdi_stack = rdi
#MINGW  rsi_stack = rsi
  rbx_stack = rbx
  rbp_stack = rbp

  a_stack = a

  # Load the base, F = x1
  f0   = *(int64 *)(a +  0)
  f51  = *(int64 *)(a +  8)
  f102 = *(int64 *)(a + 16)
  f153 = *(int64 *)(a + 24)
  f204 = *(int64 *)(a + 32)

  # Setup the initial state
  tmp0 = 1
  oldbit = 0
  one = tmp0
  assign 16 to one

  # D = (1, x1) ... ie: xnp  = 1  / 0 = infinity
  # E = (0,  1)         xn1p = x1 / 1

  c0   = f0
  c51  = f51
  c102 = f102
  c153 = f153
  c204 = f204

  d0   = one
  d51  = 0
  d102 = 0
  d153 = 0
  d204 = 0

  d0   = c0   << 64 | (d0   & 0x0000000000000000ffffffffffffffff)
  d51  = c51  << 64 | (d51  & 0x0000000000000000ffffffffffffffff)
  d102 = c102 << 64 | (d102 & 0x0000000000000000ffffffffffffffff)
  d153 = c153 << 64 | (d153 & 0x0000000000000000ffffffffffffffff)
  d204 = c204 << 64 | (d204 & 0x0000000000000000ffffffffffffffff)

  e0   = one
  e51  = 0
  e102 = 0
  e153 = 0
  e204 = 0

  e0 <<<= 64

  # Prep the exponent on our stack (zero fill  / align)
  exponent = &exponent_stack
  source = e
  length = l
  while (length) { *exponent++ = *source++; --length }

  source = 0
  length = 32
  length -= l
  while (length) { *exponent++ = source; --length }

  # Now setup the loop
  oldbit = 0
  l -= 1
  counter = 0xf8
  counter &= l
  counter += 8
  counter <<= 32
  assign 4 to counter

# Given: x*n,      x*(n   +1), x, and q
# Find:  x*(2n+q), x*(2n+q+1)
#
# Input:
#    p = Old flip bit
#    q = New flip / input bit
#    D = (xnp, xn1p)  xnp  means x*(n+p)
#    E = (znp, zn1p)  xn1p means x*(n+(1-p))
#    F = x1
# Output:
#    D = (xmq, xm1q)  where m = 2n+q
#    E = (zmq, zm1q)
quadloop:
  =? (uint64) counter >>= 32
  goto done if =
  counter -= 8

  exponent = &exponent_stack
  exp64 = *(int64 *)(exponent + counter)
  counter <<= 32
  counter += 64

bitloop:
  =? (uint32) counter - 0
  goto quadloop if =
  counter -= 1

  newbit = exp64
  (uint64) exp64 <<= 1
  (int3232) newbit >>= 31
  newbit = newbit >> 32 | (newbit & 0xffffffff00000000)

  oldbit ^= newbit
  mask = oldbit
  mask = mask << 64 | (mask & 0x0000000000000000ffffffffffffffff)
  oldbit = newbit

  assign 16 to mask

  # Calculate the differences of x and z:
  #   D = (D0 D1) = (xnp-znp, xn1p-zn1p)
  #   E = (E0 E1) = (xnp+znp, xn1p+zn1p)
  e0   += d0
  e51  += d51
  e102 += d102
  e153 += d153
  e204 += d204

  d0   <<= 1
  d51  <<= 1
  d102 <<= 1
  d153 <<= 1
  d204 <<= 1

  d0   -= e0
  d51  -= e51
  d102 -= e102
  d153 -= e153
  d204 -= e204

  # Transpose the inputs
  #   C = (E1 D1) = (xn1p + zn1p, xn1p - zn1p)
  #   E = (E0 D0) = (xnp  + znp,  xnp  - znp)
  c0   = e0
  c51  = e51
  c102 = e102
  c153 = e153
  c204 = e204

  c0   = c0   >> 64 | (d0   & 0xffffffffffffffff0000000000000000)
  c51  = c51  >> 64 | (d51  & 0xffffffffffffffff0000000000000000)
  c102 = c102 >> 64 | (d102 & 0xffffffffffffffff0000000000000000)
  c153 = c153 >> 64 | (d153 & 0xffffffffffffffff0000000000000000)
  c204 = c204 >> 64 | (d204 & 0xffffffffffffffff0000000000000000)

  e0   = d0   << 64 | (e0   & 0x0000000000000000ffffffffffffffff)
  e51  = d51  << 64 | (e51  & 0x0000000000000000ffffffffffffffff)
  e102 = d102 << 64 | (e102 & 0x0000000000000000ffffffffffffffff)
  e153 = d153 << 64 | (e153 & 0x0000000000000000ffffffffffffffff)
  e204 = d204 << 64 | (e204 & 0x0000000000000000ffffffffffffffff)

  # Process flip bit to rearrange input
  #   C = (xn1q + zn1q, xn1q - zn1q)
  #   E = (xnq  + znq,  xnq  - znq)

  d0   = c0
  d51  = c51
  d102 = c102
  d153 = c153
  d204 = c204

  d0   -= e0
  d51  -= e51
  d102 -= e102
  d153 -= e153
  d204 -= e204

  d0   &= mask
  d51  &= mask
  d102 &= mask
  d153 &= mask
  d204 &= mask

  c0   -= d0
  c51  -= d51
  c102 -= d102
  c153 -= d153
  c204 -= d204

  e0   += d0
  e51  += d51
  e102 += d102
  e153 += d153
  e204 += d204

  # Find the sum first, because it's outputs can overwrite inputs
  d0   = e0   <<< 64
  d51  = e51  <<< 64
  d102 = e102 <<< 64
  d153 = e153 <<< 64
  d204 = e204 <<< 64

  a0   = d0
  a51  = d51
  a102 = d102
  a153 = d153
  a204 = d204                 # A = xnq - znq
                              # C = xn1q + zn1q
  call mulACtoB local
  assign  6 to a0
  assign  1 to a51
  assign  8 to a102
  assign  9 to a153
  assign 10 to a204
  assign  1 to c0
  assign  2 to c51
  assign  3 to c102
  assign  4 to c153
  assign  5 to c204
  b0   = register 11
  b51  = register 12
  b102 = register 13
  b153 = register 14
  b204 = register 15
  # B = p
 
  d0   = b0
  d51  = b51
  d102 = b102
  d153 = b153
  d204 = b204               # D = p

  a0   = e0
  a51  = e51
  a102 = e102
  a153 = e153
  a204 = e204               # A = xnq+znq

  c0   <<<= 64   # C = xn1q - zn1q (could also use unpack here)
  c51  <<<= 64
  c102 <<<= 64
  c153 <<<= 64
  c204 <<<= 64

  call mulACtoB local
  assign  6 to a0
  assign  1 to a51
  assign  8 to a102
  assign  9 to a153
  assign 10 to a204
  assign  1 to c0
  assign  2 to c51
  assign  3 to c102
  assign  4 to c153
  assign  5 to c204
  b0   = register 11
  b51  = register 12
  b102 = register 13
  b153 = register 14
  b204 = register 15      # B = q

  a0   = d0               # A = p
  a51  = d51
  a102 = d102
  a153 = d153
  a204 = d204

  b0   += a0              # B = p + q
  b51  += a51
  b102 += a102
  b153 += a153
  b204 += a204

  a0   <<= 1
  a51  <<= 1
  a102 <<= 1
  a153 <<= 1
  a204 <<= 1

  a0   -= b0              # A = p - q
  a51  -= b51
  a102 -= b102
  a153 -= b153
  a204 -= b204

  c0   = a0
  c51  = a51
  c102 = a102
  c153 = a153
  c204 = a204             # C = p - q

  call sqrBtoA local
  assign 11 to b0
  assign 12 to b51
  assign 13 to b102
  assign 14 to b153
  assign 15 to b204
  a0   = register  6
  a51  = register  1
  a102 = register  8
  a153 = register  9
  a204 = register 10      # A = (p+q)^2 = xm1q

  d0   = a0
  d51  = a51
  d102 = a102
  d153 = a153
  d204 = a204             # D = xm1q

  b0   = c0
  b51  = c51
  b102 = c102
  b153 = c153
  b204 = c204             # B = p - q

  c0   = f0
  c51  = f51
  c102 = f102
  c153 = f153
  c204 = f204             # C = x1

  call sqrBtoA local      # A = (p - q)^2
  call mulACtoB local     # B = zm1q
  assign 11 to b0
  assign 12 to b51
  assign 13 to b102
  assign 14 to b153
  assign 15 to b204
  assign  1 to c0
  assign  2 to c51
  assign  3 to c102
  assign  4 to c153
  assign  5 to c204

  c0   = b0
  c51  = b51
  c102 = b102
  c153 = b153
  c204 = b204

  d0   = c0   << 64 | (d0   & 0x0000000000000000ffffffffffffffff)
  d51  = c51  << 64 | (d51  & 0x0000000000000000ffffffffffffffff)
  d102 = c102 << 64 | (d102 & 0x0000000000000000ffffffffffffffff)
  d153 = c153 << 64 | (d153 & 0x0000000000000000ffffffffffffffff)
  d204 = c204 << 64 | (d204 & 0x0000000000000000ffffffffffffffff)
  # D = (xm1q zm1q)

  b0   = e0
  b51  = e51
  b102 = e102
  b153 = e153
  b204 = e204             # B = xnq + znq

  call sqrBtoA local
  assign 11 to b0
  assign 12 to b51
  assign 13 to b102
  assign 14 to b153
  assign 15 to b204
  a0   = register  6
  a51  = register  1
  a102 = register  8
  a153 = register  9
  a204 = register 10      # A = m

  c0   = a0
  c51  = a51
  c102 = a102
  c153 = a153
  c204 = a204             # C = m

  e0   = e0   <<< 64
  e51  = e51  <<< 64
  e102 = e102 <<< 64
  e153 = e153 <<< 64
  e204 = e204 <<< 64      # E = xnq - znq

  b0   = e0
  b51  = e51
  b102 = e102
  b153 = e153
  b204 = e204             # B = xnq - znq
  call sqrBtoA local      # A = n
  call mulACtoB local     # B = xmq
  assign 11 to b0
  assign 12 to b51
  assign 13 to b102
  assign 14 to b153
  assign 15 to b204
  assign  1 to c0
  assign  2 to c51
  assign  3 to c102
  assign  4 to c153
  assign  5 to c204

  e0   = b0
  e51  = b51
  e102 = b102
  e153 = b153
  e204 = b204             # E = xmq

  b0   = c0
  b51  = c51
  b102 = c102
  b153 = c153
  b204 = c204             # B = m

  b0   -= a0
  b51  -= a51
  b102 -= a102
  b153 -= a153
  b204 -= a204            # B = k
  call scalBtoA local
  assign 11 to b0
  assign 12 to b51
  assign 13 to b102
  assign 14 to b153
  assign 15 to b204
  a0   = register  6
  a51  = register  1
  a102 = register  8
  a153 = register  9
  a204 = register 10      # A = K

  tmp0 = c0
  tmp1 = c51
  tmp2 = c102
  a0   += tmp0
  a51  += tmp1
  a102 += tmp2
  c0   = b0
  c51  = b51
  c102 = b102

  tmp0 = c153
  tmp1 = c204
  a153 += tmp0
  a204 += tmp1
  c153 = b153             # A = K + m
  c204 = b204             # C = k

  call mulACtoB local
  assign  6 to a0
  assign  1 to a51
  assign  8 to a102
  assign  9 to a153
  assign 10 to a204
  assign  1 to c0
  assign  2 to c51
  assign  3 to c102
  assign  4 to c153
  assign  5 to c204
  b0   = register 11
  b51  = register 12
  b102 = register 13
  b153 = register 14
  b204 = register 15      # B = zmq

  c0   = b0 
  c51  = b51
  c102 = b102
  c153 = b153
  c204 = b204             # C = zmq

  # Need to rearrange data for invariant.
  # C = (C0 C1) = (zmq,      )
  # D = (D0 D1) = (xm1q, zm1q) => (xmq, xm1q)
  # E = (E0 E1) = (xmq,      )    (zmq, zm1q)

  e0   = d0   << 64 | (e0   & 0x0000000000000000ffffffffffffffff)
  e51  = d51  << 64 | (e51  & 0x0000000000000000ffffffffffffffff)
  e102 = d102 << 64 | (e102 & 0x0000000000000000ffffffffffffffff)
  e153 = d153 << 64 | (e153 & 0x0000000000000000ffffffffffffffff)
  e204 = d204 << 64 | (e204 & 0x0000000000000000ffffffffffffffff)
  d0   <<<= 64
  d51  <<<= 64
  d102 <<<= 64
  d153 <<<= 64
  d204 <<<= 64
  c0   = d0   << 64 | (c0   & 0x0000000000000000ffffffffffffffff)
  c51  = d51  << 64 | (c51  & 0x0000000000000000ffffffffffffffff)
  c102 = d102 << 64 | (c102 & 0x0000000000000000ffffffffffffffff)
  c153 = d153 << 64 | (c153 & 0x0000000000000000ffffffffffffffff)
  c204 = d204 << 64 | (c204 & 0x0000000000000000ffffffffffffffff)
  d0   = e0
  d51  = e51
  d102 = e102
  d153 = e153
  d204 = e204
  e0   = c0
  e51  = c51
  e102 = c102
  e153 = c153
  e204 = c204
  goto bitloop

done:
  # Transpose the inputs
  #   C = (E1 D1) = (zn1p, xn1p)
  #   E = (E0 D0) = (znp,  znp)
  c0   = e0
  c51  = e51
  c102 = e102
  c153 = e153
  c204 = e204

  c0   = c0   >> 64 | (d0   & 0xffffffffffffffff0000000000000000)
  c51  = c51  >> 64 | (d51  & 0xffffffffffffffff0000000000000000)
  c102 = c102 >> 64 | (d102 & 0xffffffffffffffff0000000000000000)
  c153 = c153 >> 64 | (d153 & 0xffffffffffffffff0000000000000000)
  c204 = c204 >> 64 | (d204 & 0xffffffffffffffff0000000000000000)

  e0   = d0   << 64 | (e0   & 0x0000000000000000ffffffffffffffff)
  e51  = d51  << 64 | (e51  & 0x0000000000000000ffffffffffffffff)
  e102 = d102 << 64 | (e102 & 0x0000000000000000ffffffffffffffff)
  e153 = d153 << 64 | (e153 & 0x0000000000000000ffffffffffffffff)
  e204 = d204 << 64 | (e204 & 0x0000000000000000ffffffffffffffff)

  # Process flip bit to rearrange input
  #   C = (zn1, xn1)
  #   E = (zn,  xn)

  mask = oldbit
  mask = mask << 64 | (mask & 0x0000000000000000ffffffffffffffff)
  assign 16 to mask

  d0   = c0
  d51  = c51
  d102 = c102
  d153 = c153
  d204 = c204

  d0   -= e0
  d51  -= e51
  d102 -= e102
  d153 -= e153
  d204 -= e204

  d0   &= mask
  d51  &= mask
  d102 &= mask
  d153 &= mask
  d204 &= mask

  c0   -= d0
  c51  -= d51
  c102 -= d102
  c153 -= d153
  c204 -= d204

  e0   += d0
  e51  += d51
  e102 += d102
  e153 += d153
  e204 += d204

  a = a_stack

  b0   = e0
  b51  = e51
  b102 = e102
  b153 = e153
  b204 = e204
 
  e0   <<<= 64
  e51  <<<= 64
  e102 <<<= 64
  e153 <<<= 64
  e204 <<<= 64

  a0   = e0
  a51  = e51
  a102 = e102
  a153 = e153
  a204 = e204
 
  *(uint64 *)(a +  0) = a0
  *(uint64 *)(a +  8) = a51
  *(uint64 *)(a + 16) = a102
  *(uint64 *)(a + 24) = a153
  *(uint64 *)(a + 32) = a204
  *(uint64 *)(a + 40) = b0
  *(uint64 *)(a + 48) = b51
  *(uint64 *)(a + 56) = b102
  *(uint64 *)(a + 64) = b153
  *(uint64 *)(a + 72) = b204

  b0   = c0
  b51  = c51
  b102 = c102
  b153 = c153
  b204 = c204
 
  c0   <<<= 64
  c51  <<<= 64
  c102 <<<= 64
  c153 <<<= 64
  c204 <<<= 64

  a0   = c0
  a51  = c51
  a102 = c102
  a153 = c153
  a204 = c204
 
  *(uint64 *)(a +  80) = a0
  *(uint64 *)(a +  88) = a51
  *(uint64 *)(a +  96) = a102
  *(uint64 *)(a + 104) = a153
  *(uint64 *)(a + 112) = a204
  *(uint64 *)(a + 120) = b0
  *(uint64 *)(a + 128) = b51
  *(uint64 *)(a + 136) = b102
  *(uint64 *)(a + 144) = b153
  *(uint64 *)(a + 152) = b204

  xmm6 = xmm6_stack
  xmm7 = xmm7_stack
  xmm8 = xmm8_stack
  xmm9 = xmm9_stack
  xmm10 = xmm10_stack
  xmm11 = xmm11_stack
  xmm12 = xmm12_stack
  xmm13 = xmm13_stack
  xmm14 = xmm14_stack
  xmm15 = xmm15_stack

  r11 = r11_stack
  r12 = r12_stack
  r13 = r13_stack
  r14 = r14_stack
  r15 = r15_stack
#MINGW  rdi = rdi_stack
#MINGW  rsi = rsi_stack
  rbx = rbx_stack
  rbp = rbp_stack

  emms
leave
