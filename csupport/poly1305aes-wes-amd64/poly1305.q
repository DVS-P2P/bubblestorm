int64 r11
int64 r12
int64 r13
int64 r14
int64 r15
#MINGW int64 rdi
#MINGW int64 rsi
int64 rbp
int64 rbx
caller r11
caller r12
caller r13
caller r14
caller r15
#MINGW caller rdi
#MINGW caller rsi
caller rbp
caller rbx
stack64 r11_stack
stack64 r12_stack
stack64 r13_stack
stack64 r14_stack
stack64 r15_stack
#MINGW stack64 rdi_stack
#MINGW stack64 rsi_stack
stack64 rbp_stack
stack64 rbx_stack

int64 arg1
int64 arg2
int64 arg3
int64 arg4
#MINGW stack64 arg5
#LINUX int64 arg5
input arg1
input arg2
input arg3
input arg4
input arg5

int64 out_stack
int64 out
int64 r
int64 s
int64 m
int64 l
int64 m0
int64 m1
int64 m2
int64 m3
float80 a0
float80 a1
float80 a2
float80 a3
float80 h0
float80 h1
float80 h2
float80 h3
float80 x0
float80 x1
float80 x2
float80 x3
float80 y0
float80 y1
float80 y2
float80 y3
float80 r0x0
float80 r1x0
float80 r2x0
float80 r3x0
float80 r0x1
float80 r1x1
float80 r2x1
float80 sr3x1
float80 r0x2
float80 r1x2
float80 sr2x2
float80 sr3x2
float80 r0x3
float80 sr1x3
float80 sr2x3
float80 sr3x3
stack64 d0
stack64 d1
stack64 d2
stack64 d3
stack64 r0
stack64 r1
stack64 r2
stack64 r3
stack64 sr1
stack64 sr2
stack64 sr3

enter poly1305_amd64 stackaligned4096 poly1305_amd64_constants

  r11_stack = r11
  r12_stack = r12
  r13_stack = r13
  r14_stack = r14
  r15_stack = r15
#MINGW rdi_stack = rdi
#MINGW rsi_stack = rsi
  rbp_stack = rbp
  rbx_stack = rbx
  out_stack = arg1

  round *(uint16 *) &poly1305_amd64_rounding

  r = arg2

  a0 = *(int32 *) (r + 0)
  *(float64 *) &r0 = a0

  a1 = *(int32 *) (r + 4)
  a1 *= *(float64 *) &poly1305_amd64_two32
  *(float64 *) &r1 = a1
  a1 *= *(float64 *) &poly1305_amd64_scale
  *(float64 *) &sr1 = a1

  a2 = *(int32 *) (r + 8)
  a2 *= *(float64 *) &poly1305_amd64_two64
  *(float64 *) &r2 = a2
  a2 *= *(float64 *) &poly1305_amd64_scale
  *(float64 *) &sr2 = a2

  a3 = *(int32 *) (r + 12)
  a3 *= *(float64 *) &poly1305_amd64_two96
  *(float64 *) &r3 = a3
  a3 *= *(float64 *) &poly1305_amd64_scale
  *(float64 *) &sr3 = a3

  h3 = 0
  h2 = 0
  h1 = 0
  h0 = 0

  d0 top = 0x43300000
  d1 top = 0x45300000
  d2 top = 0x47300000
  d3 top = 0x49300000

  m = arg4
  l = arg5

                         unsigned<? l - 16
goto addatmost15bytes if unsigned<

  m3 = *(uint32 *) (m + 12)
  m2 = *(uint32 *) (m + 8)
  m1 = *(uint32 *) (m + 4)
  m0 = *(uint32 *) (m + 0)
  inplace d3 bottom = m3
  inplace d2 bottom = m2
  inplace d1 bottom = m1
  inplace d0 bottom = m0

  m += 16
  l -= 16

  h3 += *(float64 *) &d3
  h3 -= *(float64 *) &poly1305_amd64_doffset3minustwo128
  h2 += *(float64 *) &d2
  h2 -= *(float64 *) &poly1305_amd64_doffset2
  h1 += *(float64 *) &d1
  h1 -= *(float64 *) &poly1305_amd64_doffset1
  h0 += *(float64 *) &d0
  h0 -= *(float64 *) &poly1305_amd64_doffset0

                                 unsigned<? l - 16
goto multiplyaddatmost15bytes if unsigned<

multiplyaddatleast16bytes:

  m3 = *(uint32 *) (m + 12)
  m2 = *(uint32 *) (m + 8)
  m1 = *(uint32 *) (m + 4)
  m0 = *(uint32 *) (m + 0)
  inplace d3 bottom = m3
  inplace d2 bottom = m2
  inplace d1 bottom = m1
  inplace d0 bottom = m0

  m += 16
  l -= 16

  x0 = *(float64 *) &poly1305_amd64_alpha130
  x0 += h3
  x0 -= *(float64 *) &poly1305_amd64_alpha130
  h3 -= x0
  x0 *= *(float64 *) &poly1305_amd64_scale

  x1 = *(float64 *) &poly1305_amd64_alpha32
  x1 += h0
  x1 -= *(float64 *) &poly1305_amd64_alpha32
  h0 -= x1

  x0 += h0

  x2 = *(float64 *) &poly1305_amd64_alpha64
  x2 += h1
  x2 -= *(float64 *) &poly1305_amd64_alpha64
  h1 -= x2

  x3 = *(float64 *) &poly1305_amd64_alpha96
  x3 += h2
  x3 -= *(float64 *) &poly1305_amd64_alpha96
  h2 -= x3

  x2 += h2
  x3 += h3
  x1 += h1

  h3 = *(float64 *) &r3
  h3 *= x0
  h2 = *(float64 *) &r2
  h2 *= x0
  h1 = *(float64 *) &r1
  h1 *= x0
  h0 = *(float64 *) &r0
  h0 *= x0

  r2x1 = *(float64 *) &r2
  r2x1 *= x1
  h3 += r2x1
  r1x1 = *(float64 *) &r1
  r1x1 *= x1
  h2 += r1x1
  r0x1 = *(float64 *) &r0
  r0x1 *= x1
  h1 += r0x1
  sr3x1 = *(float64 *) &sr3
  sr3x1 *= x1
  h0 += sr3x1

  r1x2 = *(float64 *) &r1
  r1x2 *= x2
  h3 += r1x2
  r0x2 = *(float64 *) &r0
  r0x2 *= x2
  h2 += r0x2
  sr3x2 = *(float64 *) &sr3
  sr3x2 *= x2
  h1 += sr3x2
  sr2x2 = *(float64 *) &sr2
  sr2x2 *= x2
  h0 += sr2x2

  r0x3 = *(float64 *) &r0
  r0x3 *= x3
  h3 += r0x3
  sr3x3 = *(float64 *) &sr3
  sr3x3 *= x3
  h2 += sr3x3
  sr2x3 = *(float64 *) &sr2
  sr2x3 *= x3
  h1 += sr2x3
  stacktop h2
  sr1x3 = *(float64 *) &sr1
  sr1x3 *= x3
  h0 += sr1x3

                                   unsigned<? l - 16

  y3 = *(float64 *) &d3
  y3 -= *(float64 *) &poly1305_amd64_doffset3minustwo128
  h3 += y3
  y2 = *(float64 *) &d2
  y2 -= *(float64 *) &poly1305_amd64_doffset2
  h2 += y2
  y1 = *(float64 *) &d1
  y1 -= *(float64 *) &poly1305_amd64_doffset1
  h1 += y1
  stacktop h0
  y0 = *(float64 *) &d0
  y0 -= *(float64 *) &poly1305_amd64_doffset0
  h0 += y0

goto multiplyaddatleast16bytes if !unsigned<

multiplyaddatmost15bytes:

  x0 = *(float64 *) &poly1305_amd64_alpha130
  x0 += h3
  x0 -= *(float64 *) &poly1305_amd64_alpha130
  h3 -= x0
  x0 *= *(float64 *) &poly1305_amd64_scale

  x1 = *(float64 *) &poly1305_amd64_alpha32
  x1 += h0
  x1 -= *(float64 *) &poly1305_amd64_alpha32
  h0 -= x1

  x2 = *(float64 *) &poly1305_amd64_alpha64
  x2 += h1
  x2 -= *(float64 *) &poly1305_amd64_alpha64
  h1 -= x2

  x3 = *(float64 *) &poly1305_amd64_alpha96
  x3 += h2
  x3 -= *(float64 *) &poly1305_amd64_alpha96
  h2 -= x3

  x0 += h0
  x1 += h1
  x2 += h2
  x3 += h3

  h3 = *(float64 *) &r3
  h3 *= x0
  h2 = *(float64 *) &r2
  h2 *= x0
  h1 = *(float64 *) &r1
  h1 *= x0
  h0 = *(float64 *) &r0
  h0 *= x0

  r2x1 = *(float64 *) &r2
  r2x1 *= x1
  h3 += r2x1
  r1x1 = *(float64 *) &r1
  r1x1 *= x1
  h2 += r1x1
  r0x1 = *(float64 *) &r0
  r0x1 *= x1
  h1 += r0x1
  sr3x1 = *(float64 *) &sr3
  sr3x1 *= x1
  h0 += sr3x1

  r1x2 = *(float64 *) &r1
  r1x2 *= x2
  h3 += r1x2
  r0x2 = *(float64 *) &r0
  r0x2 *= x2
  h2 += r0x2
  sr3x2 = *(float64 *) &sr3
  sr3x2 *= x2
  h1 += sr3x2
  sr2x2 = *(float64 *) &sr2
  sr2x2 *= x2
  h0 += sr2x2

  r0x3 = *(float64 *) &r0
  r0x3 *= x3
  h3 += r0x3
  sr3x3 = *(float64 *) &sr3
  sr3x3 *= x3
  h2 += sr3x3
  sr2x3 = *(float64 *) &sr2
  sr2x3 *= x3
  h1 += sr2x3
  sr1x3 = *(float64 *) &sr1
  sr1x3 *= x3
  h0 += sr1x3

addatmost15bytes:

                    =? l - 0
goto nomorebytes if =

stack128 lastchunk
int64 destination

  ((uint32 *) &lastchunk)[0] = 0
  ((uint32 *) &lastchunk)[1] = 0
  ((uint32 *) &lastchunk)[2] = 0
  ((uint32 *) &lastchunk)[3] = 0

  destination = &lastchunk
  while (l) { *destination++ = *m++; --l }
  *(uint8 *) (destination + 0) = 1

  m3 = ((uint32 *) &lastchunk)[3]
  m2 = ((uint32 *) &lastchunk)[2]
  m1 = ((uint32 *) &lastchunk)[1]
  m0 = ((uint32 *) &lastchunk)[0]
  inplace d3 bottom = m3
  inplace d2 bottom = m2
  inplace d1 bottom = m1
  inplace d0 bottom = m0

  h3 += *(float64 *) &d3
  h3 -= *(float64 *) &poly1305_amd64_doffset3
  h2 += *(float64 *) &d2
  h2 -= *(float64 *) &poly1305_amd64_doffset2
  h1 += *(float64 *) &d1
  h1 -= *(float64 *) &poly1305_amd64_doffset1
  h0 += *(float64 *) &d0
  h0 -= *(float64 *) &poly1305_amd64_doffset0

  x0 = *(float64 *) &poly1305_amd64_alpha130
  x0 += h3
  x0 -= *(float64 *) &poly1305_amd64_alpha130
  h3 -= x0
  x0 *= *(float64 *) &poly1305_amd64_scale

  x1 = *(float64 *) &poly1305_amd64_alpha32
  x1 += h0
  x1 -= *(float64 *) &poly1305_amd64_alpha32
  h0 -= x1

  x2 = *(float64 *) &poly1305_amd64_alpha64
  x2 += h1
  x2 -= *(float64 *) &poly1305_amd64_alpha64
  h1 -= x2

  x3 = *(float64 *) &poly1305_amd64_alpha96
  x3 += h2
  x3 -= *(float64 *) &poly1305_amd64_alpha96
  h2 -= x3

  x0 += h0
  x1 += h1
  x2 += h2
  x3 += h3

  h3 = *(float64 *) &r3
  h3 *= x0
  h2 = *(float64 *) &r2
  h2 *= x0
  h1 = *(float64 *) &r1
  h1 *= x0
  h0 = *(float64 *) &r0
  h0 *= x0

  r2x1 = *(float64 *) &r2
  r2x1 *= x1
  h3 += r2x1
  r1x1 = *(float64 *) &r1
  r1x1 *= x1
  h2 += r1x1
  r0x1 = *(float64 *) &r0
  r0x1 *= x1
  h1 += r0x1
  sr3x1 = *(float64 *) &sr3
  sr3x1 *= x1
  h0 += sr3x1

  r1x2 = *(float64 *) &r1
  r1x2 *= x2
  h3 += r1x2
  r0x2 = *(float64 *) &r0
  r0x2 *= x2
  h2 += r0x2
  sr3x2 = *(float64 *) &sr3
  sr3x2 *= x2
  h1 += sr3x2
  sr2x2 = *(float64 *) &sr2
  sr2x2 *= x2
  h0 += sr2x2

  r0x3 = *(float64 *) &r0
  r0x3 *= x3
  h3 += r0x3
  sr3x3 = *(float64 *) &sr3
  sr3x3 *= x3
  h2 += sr3x3
  sr2x3 = *(float64 *) &sr2
  sr2x3 *= x3
  h1 += sr2x3
  sr1x3 = *(float64 *) &sr1
  sr1x3 *= x3
  h0 += sr1x3


nomorebytes:

  x0 = *(float64 *) &poly1305_amd64_alpha130
  x0 += h3
  x0 -= *(float64 *) &poly1305_amd64_alpha130
  h3 -= x0
  x0 *= *(float64 *) &poly1305_amd64_scale

  x1 = *(float64 *) &poly1305_amd64_alpha32
  x1 += h0
  x1 -= *(float64 *) &poly1305_amd64_alpha32
  h0 -= x1

  x2 = *(float64 *) &poly1305_amd64_alpha64
  x2 += h1
  x2 -= *(float64 *) &poly1305_amd64_alpha64
  h1 -= x2

  x3 = *(float64 *) &poly1305_amd64_alpha96
  x3 += h2
  x3 -= *(float64 *) &poly1305_amd64_alpha96
  h2 -= x3

  x0 += h0
  x1 += h1
  x2 += h2
  x3 += h3

  x0 += *(float64 *) &poly1305_amd64_hoffset0
  x1 += *(float64 *) &poly1305_amd64_hoffset1
  x2 += *(float64 *) &poly1305_amd64_hoffset2
  x3 += *(float64 *) &poly1305_amd64_hoffset3
  *(float64 *) &d0 = x0
  *(float64 *) &d1 = x1
  *(float64 *) &d2 = x2
  *(float64 *) &d3 = x3

int64 f0
int64 f1
int64 f2
int64 f3
int64 f4
int64 g0
int64 g1
int64 g2
int64 g3
int64 f
int64 notf

  g0 = top d0
  (uint32) g0 &= 63
  g1 = top d1
  (uint32) g1 &= 63
  g2 = top d2
  (uint32) g2 &= 63
  g3 = top d3
  (uint32) g3 &= 63

  f1 = bottom d1
  carry? (uint32) f1 += g0

  f2 = bottom d2
  carry? (uint32) f2 += g1 + carry

  f3 = bottom d3
  carry? (uint32) f3 += g2 + carry

  f4 = 0
         (uint32) f4 += g3 + carry

  g0 = 5
  f0 = bottom d0
  carry? (uint32) g0 += f0

  g1 = 0
  carry? (uint32) g1 += f1 + carry

  g2 = 0
  carry? (uint32) g2 += f2 + carry

  g3 = 0
  carry? (uint32) g3 += f3 + carry

  f = -4
         (uint32) f += f4 + carry

  (int32) f >>= 16

  notf = f
  (uint32) notf ^= -1
  f0 &= f
  g0 &= notf
  f0 |= g0
  f1 &= f
  g1 &= notf
  f1 |= g1
  f2 &= f
  g2 &= notf
  f2 |= g2
  f3 &= f
  g3 &= notf
  f3 |= g3

  s = arg3

  carry? (uint32) f0 += *(uint32 *) (s + 0)
  carry? (uint32) f1 += *(uint32 *) (s + 4) + carry
  carry? (uint32) f2 += *(uint32 *) (s + 8) + carry
         (uint32) f3 += *(uint32 *) (s + 12) + carry

  out = out_stack

  *(uint32 *) (out + 0) = f0
  *(uint32 *) (out + 4) = f1
  *(uint32 *) (out + 8) = f2
  *(uint32 *) (out + 12) = f3

  r11 = r11_stack
  r12 = r12_stack
  r13 = r13_stack
  r14 = r14_stack
  r15 = r15_stack
#MINGW rdi = rdi_stack
#MINGW rsi = rsi_stack
  rbp = rbp_stack
  rbx = rbx_stack

leave
