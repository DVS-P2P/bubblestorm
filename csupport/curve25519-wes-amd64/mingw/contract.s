
# qhasm: int64 r

# qhasm: int64 a

# qhasm: int64 low

# qhasm: int64 neg1

# qhasm: int6464 tmp

# qhasm: int64 r0

# qhasm: int64 r1

# qhasm: int64 r2

# qhasm: int64 r3

# qhasm: int64 r4

# qhasm: int64 Y

# qhasm: int64 m19

# qhasm: enter field25519_wes_contract nostack
.text
.p2align 5
.globl _field25519_wes_contract
.globl field25519_wes_contract
_field25519_wes_contract:
field25519_wes_contract:

# qhasm:   input r

# qhasm:   input a

# qhasm:   tmp = r
# asm 1: movd   <r=int64#1,>tmp=int6464#1
# asm 2: movd   <r=%rcx,>tmp=%xmm0
movd   %rcx,%xmm0

# qhasm:   r0 = *(uint64 *) (a +  0)
# asm 1: movq   0(<a=int64#2),>r0=int64#1
# asm 2: movq   0(<a=%rdx),>r0=%rcx
movq   0(%rdx),%rcx

# qhasm:   r1 = *(uint64 *) (a +  8)
# asm 1: movq   8(<a=int64#2),>r1=int64#3
# asm 2: movq   8(<a=%rdx),>r1=%r8
movq   8(%rdx),%r8

# qhasm:   r2 = *(uint64 *) (a + 16)
# asm 1: movq   16(<a=int64#2),>r2=int64#4
# asm 2: movq   16(<a=%rdx),>r2=%r9
movq   16(%rdx),%r9

# qhasm:   r3 = *(uint64 *) (a + 24)
# asm 1: movq   24(<a=int64#2),>r3=int64#5
# asm 2: movq   24(<a=%rdx),>r3=%rax
movq   24(%rdx),%rax

# qhasm:   r4 = *(uint64 *) (a + 32)
# asm 1: movq   32(<a=int64#2),>r4=int64#2
# asm 2: movq   32(<a=%rdx),>r4=%rdx
movq   32(%rdx),%rdx

# qhasm:   neg1 = r0
# asm 1: mov  <r0=int64#1,>neg1=int64#6
# asm 2: mov  <r0=%rcx,>neg1=%r10
mov  %rcx,%r10

# qhasm:   (int64) neg1 >>= 63
# asm 1: sar  $63,<neg1=int64#6
# asm 2: sar  $63,<neg1=%r10
sar  $63,%r10

# qhasm:   low = r1
# asm 1: mov  <r1=int64#3,>low=int64#7
# asm 2: mov  <r1=%r8,>low=%r11
mov  %r8,%r11

# qhasm:   low <<= 51
# asm 1: shl  $51,<low=int64#7
# asm 2: shl  $51,<low=%r11
shl  $51,%r11

# qhasm:   (int64) r1 >>= 13
# asm 1: sar  $13,<r1=int64#3
# asm 2: sar  $13,<r1=%r8
sar  $13,%r8

# qhasm:   carry? r0 += low
# asm 1: add  <low=int64#7,<r0=int64#1
# asm 2: add  <low=%r11,<r0=%rcx
add  %r11,%rcx

# qhasm:   carry? r1 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r1=int64#3
# asm 2: adc <neg1=%r10,<r1=%r8
adc %r10,%r8

# qhasm:   neg1 = r1
# asm 1: mov  <r1=int64#3,>neg1=int64#6
# asm 2: mov  <r1=%r8,>neg1=%r10
mov  %r8,%r10

# qhasm:   (int64) neg1 >>= 63
# asm 1: sar  $63,<neg1=int64#6
# asm 2: sar  $63,<neg1=%r10
sar  $63,%r10

# qhasm:   low = r2
# asm 1: mov  <r2=int64#4,>low=int64#7
# asm 2: mov  <r2=%r9,>low=%r11
mov  %r9,%r11

# qhasm:   low <<= 38
# asm 1: shl  $38,<low=int64#7
# asm 2: shl  $38,<low=%r11
shl  $38,%r11

# qhasm:   (int64) r2 >>= 26
# asm 1: sar  $26,<r2=int64#4
# asm 2: sar  $26,<r2=%r9
sar  $26,%r9

# qhasm:   carry? r1 += low
# asm 1: add  <low=int64#7,<r1=int64#3
# asm 2: add  <low=%r11,<r1=%r8
add  %r11,%r8

# qhasm:   carry? r2 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r2=int64#4
# asm 2: adc <neg1=%r10,<r2=%r9
adc %r10,%r9

# qhasm:   neg1 = r2
# asm 1: mov  <r2=int64#4,>neg1=int64#6
# asm 2: mov  <r2=%r9,>neg1=%r10
mov  %r9,%r10

# qhasm:   (int64) neg1 >>= 63
# asm 1: sar  $63,<neg1=int64#6
# asm 2: sar  $63,<neg1=%r10
sar  $63,%r10

# qhasm:   low = r3
# asm 1: mov  <r3=int64#5,>low=int64#7
# asm 2: mov  <r3=%rax,>low=%r11
mov  %rax,%r11

# qhasm:   low <<= 25
# asm 1: shl  $25,<low=int64#7
# asm 2: shl  $25,<low=%r11
shl  $25,%r11

# qhasm:   (int64) r3 >>= 39
# asm 1: sar  $39,<r3=int64#5
# asm 2: sar  $39,<r3=%rax
sar  $39,%rax

# qhasm:   carry? r2 += low
# asm 1: add  <low=int64#7,<r2=int64#4
# asm 2: add  <low=%r11,<r2=%r9
add  %r11,%r9

# qhasm:   carry? r3 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r3=int64#5
# asm 2: adc <neg1=%r10,<r3=%rax
adc %r10,%rax

# qhasm:   neg1 = r3
# asm 1: mov  <r3=int64#5,>neg1=int64#6
# asm 2: mov  <r3=%rax,>neg1=%r10
mov  %rax,%r10

# qhasm:   (int64) neg1 >>= 63
# asm 1: sar  $63,<neg1=int64#6
# asm 2: sar  $63,<neg1=%r10
sar  $63,%r10

# qhasm:   low = r4
# asm 1: mov  <r4=int64#2,>low=int64#7
# asm 2: mov  <r4=%rdx,>low=%r11
mov  %rdx,%r11

# qhasm:   low <<= 12
# asm 1: shl  $12,<low=int64#7
# asm 2: shl  $12,<low=%r11
shl  $12,%r11

# qhasm:   (int64) r4 >>= 52
# asm 1: sar  $52,<r4=int64#2
# asm 2: sar  $52,<r4=%rdx
sar  $52,%rdx

# qhasm:   carry? r3 += low
# asm 1: add  <low=int64#7,<r3=int64#5
# asm 2: add  <low=%r11,<r3=%rax
add  %r11,%rax

# qhasm:   carry? r4 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r4=int64#2
# asm 2: adc <neg1=%r10,<r4=%rdx
adc %r10,%rdx

# qhasm:   r4 = (r4.r3) << 1
# asm 1: shld $1,<r3=int64#5,<r4=int64#2
# asm 2: shld $1,<r3=%rax,<r4=%rdx
shld $1,%rax,%rdx

# qhasm:   r3 <<= 1
# asm 1: shl  $1,<r3=int64#5
# asm 2: shl  $1,<r3=%rax
shl  $1,%rax

# qhasm:   (uint64) r3 >>= 1
# asm 1: shr  $1,<r3=int64#5
# asm 2: shr  $1,<r3=%rax
shr  $1,%rax

# qhasm:   neg1 = r4
# asm 1: mov  <r4=int64#2,>neg1=int64#6
# asm 2: mov  <r4=%rdx,>neg1=%r10
mov  %rdx,%r10

# qhasm:   (int64) neg1 >>= 63
# asm 1: sar  $63,<neg1=int64#6
# asm 2: sar  $63,<neg1=%r10
sar  $63,%r10

# qhasm:   Y = r4 + neg1 + 1
# asm 1: lea  1(<r4=int64#2,<neg1=int64#6),>Y=int64#2
# asm 2: lea  1(<r4=%rdx,<neg1=%r10),>Y=%rdx
lea  1(%rdx,%r10),%rdx

# qhasm:   Y *= 19
# asm 1: imul  $19,<Y=int64#2
# asm 2: imul  $19,<Y=%rdx
imul  $19,%rdx

# qhasm:   carry? r0 += Y
# asm 1: add  <Y=int64#2,<r0=int64#1
# asm 2: add  <Y=%rdx,<r0=%rcx
add  %rdx,%rcx

# qhasm:   carry? r1 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r1=int64#3
# asm 2: adc <neg1=%r10,<r1=%r8
adc %r10,%r8

# qhasm:   carry? r2 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r2=int64#4
# asm 2: adc <neg1=%r10,<r2=%r9
adc %r10,%r9

# qhasm:   carry? r3 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r3=int64#5
# asm 2: adc <neg1=%r10,<r3=%rax
adc %r10,%rax

# qhasm:   neg1 <<= 63
# asm 1: shl  $63,<neg1=int64#6
# asm 2: shl  $63,<neg1=%r10
shl  $63,%r10

# qhasm:   r3 += neg1
# asm 1: add  <neg1=int64#6,<r3=int64#5
# asm 2: add  <neg1=%r10,<r3=%rax
add  %r10,%rax

# qhasm:   m19 = 19
# asm 1: mov  $19,>m19=int64#2
# asm 2: mov  $19,>m19=%rdx
mov  $19,%rdx

# qhasm:   neg1 = r3
# asm 1: mov  <r3=int64#5,>neg1=int64#6
# asm 2: mov  <r3=%rax,>neg1=%r10
mov  %rax,%r10

# qhasm:   (int64) neg1 >>= 63
# asm 1: sar  $63,<neg1=int64#6
# asm 2: sar  $63,<neg1=%r10
sar  $63,%r10

# qhasm:   neg1 = ~neg1
# asm 1: not  <neg1=int64#6
# asm 2: not  <neg1=%r10
not  %r10

# qhasm:   m19 &= neg1
# asm 1: and  <neg1=int64#6,<m19=int64#2
# asm 2: and  <neg1=%r10,<m19=%rdx
and  %r10,%rdx

# qhasm:   carry? r0 -= m19
# asm 1: sub  <m19=int64#2,<r0=int64#1
# asm 2: sub  <m19=%rdx,<r0=%rcx
sub  %rdx,%rcx

# qhasm:   carry? r1 -= 0 - carry
# asm 1: sbb $0,<r1=int64#3
# asm 2: sbb $0,<r1=%r8
sbb $0,%r8

# qhasm:   carry? r2 -= 0 - carry
# asm 1: sbb $0,<r2=int64#4
# asm 2: sbb $0,<r2=%r9
sbb $0,%r9

# qhasm:   carry? r3 -= 0 - carry
# asm 1: sbb $0,<r3=int64#5
# asm 2: sbb $0,<r3=%rax
sbb $0,%rax

# qhasm:   r3 <<= 1
# asm 1: shl  $1,<r3=int64#5
# asm 2: shl  $1,<r3=%rax
shl  $1,%rax

# qhasm:   (uint64) r3 >>= 1
# asm 1: shr  $1,<r3=int64#5
# asm 2: shr  $1,<r3=%rax
shr  $1,%rax

# qhasm:   r = tmp
# asm 1: movd   <tmp=int6464#1,>r=int64#2
# asm 2: movd   <tmp=%xmm0,>r=%rdx
movd   %xmm0,%rdx

# qhasm:   *(uint64 *) (r +  0) = r0
# asm 1: movq   <r0=int64#1,0(<r=int64#2)
# asm 2: movq   <r0=%rcx,0(<r=%rdx)
movq   %rcx,0(%rdx)

# qhasm:   *(uint64 *) (r +  8) = r1
# asm 1: movq   <r1=int64#3,8(<r=int64#2)
# asm 2: movq   <r1=%r8,8(<r=%rdx)
movq   %r8,8(%rdx)

# qhasm:   *(uint64 *) (r + 16) = r2
# asm 1: movq   <r2=int64#4,16(<r=int64#2)
# asm 2: movq   <r2=%r9,16(<r=%rdx)
movq   %r9,16(%rdx)

# qhasm:   *(uint64 *) (r + 24) = r3
# asm 1: movq   <r3=int64#5,24(<r=int64#2)
# asm 2: movq   <r3=%rax,24(<r=%rdx)
movq   %rax,24(%rdx)

# qhasm: leave nostack
ret
