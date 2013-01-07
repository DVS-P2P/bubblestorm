
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
# asm 2: movd   <r=%rdi,>tmp=%xmm0
movd   %rdi,%xmm0

# qhasm:   r0 = *(uint64 *) (a +  0)
# asm 1: movq   0(<a=int64#2),>r0=int64#1
# asm 2: movq   0(<a=%rsi),>r0=%rdi
movq   0(%rsi),%rdi

# qhasm:   r1 = *(uint64 *) (a +  8)
# asm 1: movq   8(<a=int64#2),>r1=int64#3
# asm 2: movq   8(<a=%rsi),>r1=%rdx
movq   8(%rsi),%rdx

# qhasm:   r2 = *(uint64 *) (a + 16)
# asm 1: movq   16(<a=int64#2),>r2=int64#4
# asm 2: movq   16(<a=%rsi),>r2=%rcx
movq   16(%rsi),%rcx

# qhasm:   r3 = *(uint64 *) (a + 24)
# asm 1: movq   24(<a=int64#2),>r3=int64#5
# asm 2: movq   24(<a=%rsi),>r3=%r8
movq   24(%rsi),%r8

# qhasm:   r4 = *(uint64 *) (a + 32)
# asm 1: movq   32(<a=int64#2),>r4=int64#2
# asm 2: movq   32(<a=%rsi),>r4=%rsi
movq   32(%rsi),%rsi

# qhasm:   neg1 = r0
# asm 1: mov  <r0=int64#1,>neg1=int64#6
# asm 2: mov  <r0=%rdi,>neg1=%r9
mov  %rdi,%r9

# qhasm:   (int64) neg1 >>= 63
# asm 1: sar  $63,<neg1=int64#6
# asm 2: sar  $63,<neg1=%r9
sar  $63,%r9

# qhasm:   low = r1
# asm 1: mov  <r1=int64#3,>low=int64#7
# asm 2: mov  <r1=%rdx,>low=%rax
mov  %rdx,%rax

# qhasm:   low <<= 51
# asm 1: shl  $51,<low=int64#7
# asm 2: shl  $51,<low=%rax
shl  $51,%rax

# qhasm:   (int64) r1 >>= 13
# asm 1: sar  $13,<r1=int64#3
# asm 2: sar  $13,<r1=%rdx
sar  $13,%rdx

# qhasm:   carry? r0 += low
# asm 1: add  <low=int64#7,<r0=int64#1
# asm 2: add  <low=%rax,<r0=%rdi
add  %rax,%rdi

# qhasm:   carry? r1 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r1=int64#3
# asm 2: adc <neg1=%r9,<r1=%rdx
adc %r9,%rdx

# qhasm:   neg1 = r1
# asm 1: mov  <r1=int64#3,>neg1=int64#6
# asm 2: mov  <r1=%rdx,>neg1=%r9
mov  %rdx,%r9

# qhasm:   (int64) neg1 >>= 63
# asm 1: sar  $63,<neg1=int64#6
# asm 2: sar  $63,<neg1=%r9
sar  $63,%r9

# qhasm:   low = r2
# asm 1: mov  <r2=int64#4,>low=int64#7
# asm 2: mov  <r2=%rcx,>low=%rax
mov  %rcx,%rax

# qhasm:   low <<= 38
# asm 1: shl  $38,<low=int64#7
# asm 2: shl  $38,<low=%rax
shl  $38,%rax

# qhasm:   (int64) r2 >>= 26
# asm 1: sar  $26,<r2=int64#4
# asm 2: sar  $26,<r2=%rcx
sar  $26,%rcx

# qhasm:   carry? r1 += low
# asm 1: add  <low=int64#7,<r1=int64#3
# asm 2: add  <low=%rax,<r1=%rdx
add  %rax,%rdx

# qhasm:   carry? r2 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r2=int64#4
# asm 2: adc <neg1=%r9,<r2=%rcx
adc %r9,%rcx

# qhasm:   neg1 = r2
# asm 1: mov  <r2=int64#4,>neg1=int64#6
# asm 2: mov  <r2=%rcx,>neg1=%r9
mov  %rcx,%r9

# qhasm:   (int64) neg1 >>= 63
# asm 1: sar  $63,<neg1=int64#6
# asm 2: sar  $63,<neg1=%r9
sar  $63,%r9

# qhasm:   low = r3
# asm 1: mov  <r3=int64#5,>low=int64#7
# asm 2: mov  <r3=%r8,>low=%rax
mov  %r8,%rax

# qhasm:   low <<= 25
# asm 1: shl  $25,<low=int64#7
# asm 2: shl  $25,<low=%rax
shl  $25,%rax

# qhasm:   (int64) r3 >>= 39
# asm 1: sar  $39,<r3=int64#5
# asm 2: sar  $39,<r3=%r8
sar  $39,%r8

# qhasm:   carry? r2 += low
# asm 1: add  <low=int64#7,<r2=int64#4
# asm 2: add  <low=%rax,<r2=%rcx
add  %rax,%rcx

# qhasm:   carry? r3 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r3=int64#5
# asm 2: adc <neg1=%r9,<r3=%r8
adc %r9,%r8

# qhasm:   neg1 = r3
# asm 1: mov  <r3=int64#5,>neg1=int64#6
# asm 2: mov  <r3=%r8,>neg1=%r9
mov  %r8,%r9

# qhasm:   (int64) neg1 >>= 63
# asm 1: sar  $63,<neg1=int64#6
# asm 2: sar  $63,<neg1=%r9
sar  $63,%r9

# qhasm:   low = r4
# asm 1: mov  <r4=int64#2,>low=int64#7
# asm 2: mov  <r4=%rsi,>low=%rax
mov  %rsi,%rax

# qhasm:   low <<= 12
# asm 1: shl  $12,<low=int64#7
# asm 2: shl  $12,<low=%rax
shl  $12,%rax

# qhasm:   (int64) r4 >>= 52
# asm 1: sar  $52,<r4=int64#2
# asm 2: sar  $52,<r4=%rsi
sar  $52,%rsi

# qhasm:   carry? r3 += low
# asm 1: add  <low=int64#7,<r3=int64#5
# asm 2: add  <low=%rax,<r3=%r8
add  %rax,%r8

# qhasm:   carry? r4 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r4=int64#2
# asm 2: adc <neg1=%r9,<r4=%rsi
adc %r9,%rsi

# qhasm:   r4 = (r4.r3) << 1
# asm 1: shld $1,<r3=int64#5,<r4=int64#2
# asm 2: shld $1,<r3=%r8,<r4=%rsi
shld $1,%r8,%rsi

# qhasm:   r3 <<= 1
# asm 1: shl  $1,<r3=int64#5
# asm 2: shl  $1,<r3=%r8
shl  $1,%r8

# qhasm:   (uint64) r3 >>= 1
# asm 1: shr  $1,<r3=int64#5
# asm 2: shr  $1,<r3=%r8
shr  $1,%r8

# qhasm:   neg1 = r4
# asm 1: mov  <r4=int64#2,>neg1=int64#6
# asm 2: mov  <r4=%rsi,>neg1=%r9
mov  %rsi,%r9

# qhasm:   (int64) neg1 >>= 63
# asm 1: sar  $63,<neg1=int64#6
# asm 2: sar  $63,<neg1=%r9
sar  $63,%r9

# qhasm:   Y = r4 + neg1 + 1
# asm 1: lea  1(<r4=int64#2,<neg1=int64#6),>Y=int64#2
# asm 2: lea  1(<r4=%rsi,<neg1=%r9),>Y=%rsi
lea  1(%rsi,%r9),%rsi

# qhasm:   Y *= 19
# asm 1: imul  $19,<Y=int64#2
# asm 2: imul  $19,<Y=%rsi
imul  $19,%rsi

# qhasm:   carry? r0 += Y
# asm 1: add  <Y=int64#2,<r0=int64#1
# asm 2: add  <Y=%rsi,<r0=%rdi
add  %rsi,%rdi

# qhasm:   carry? r1 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r1=int64#3
# asm 2: adc <neg1=%r9,<r1=%rdx
adc %r9,%rdx

# qhasm:   carry? r2 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r2=int64#4
# asm 2: adc <neg1=%r9,<r2=%rcx
adc %r9,%rcx

# qhasm:   carry? r3 += neg1 + carry
# asm 1: adc <neg1=int64#6,<r3=int64#5
# asm 2: adc <neg1=%r9,<r3=%r8
adc %r9,%r8

# qhasm:   neg1 <<= 63
# asm 1: shl  $63,<neg1=int64#6
# asm 2: shl  $63,<neg1=%r9
shl  $63,%r9

# qhasm:   r3 += neg1
# asm 1: add  <neg1=int64#6,<r3=int64#5
# asm 2: add  <neg1=%r9,<r3=%r8
add  %r9,%r8

# qhasm:   m19 = 19
# asm 1: mov  $19,>m19=int64#2
# asm 2: mov  $19,>m19=%rsi
mov  $19,%rsi

# qhasm:   neg1 = r3
# asm 1: mov  <r3=int64#5,>neg1=int64#6
# asm 2: mov  <r3=%r8,>neg1=%r9
mov  %r8,%r9

# qhasm:   (int64) neg1 >>= 63
# asm 1: sar  $63,<neg1=int64#6
# asm 2: sar  $63,<neg1=%r9
sar  $63,%r9

# qhasm:   neg1 = ~neg1
# asm 1: not  <neg1=int64#6
# asm 2: not  <neg1=%r9
not  %r9

# qhasm:   m19 &= neg1
# asm 1: and  <neg1=int64#6,<m19=int64#2
# asm 2: and  <neg1=%r9,<m19=%rsi
and  %r9,%rsi

# qhasm:   carry? r0 -= m19
# asm 1: sub  <m19=int64#2,<r0=int64#1
# asm 2: sub  <m19=%rsi,<r0=%rdi
sub  %rsi,%rdi

# qhasm:   carry? r1 -= 0 - carry
# asm 1: sbb $0,<r1=int64#3
# asm 2: sbb $0,<r1=%rdx
sbb $0,%rdx

# qhasm:   carry? r2 -= 0 - carry
# asm 1: sbb $0,<r2=int64#4
# asm 2: sbb $0,<r2=%rcx
sbb $0,%rcx

# qhasm:   carry? r3 -= 0 - carry
# asm 1: sbb $0,<r3=int64#5
# asm 2: sbb $0,<r3=%r8
sbb $0,%r8

# qhasm:   r3 <<= 1
# asm 1: shl  $1,<r3=int64#5
# asm 2: shl  $1,<r3=%r8
shl  $1,%r8

# qhasm:   (uint64) r3 >>= 1
# asm 1: shr  $1,<r3=int64#5
# asm 2: shr  $1,<r3=%r8
shr  $1,%r8

# qhasm:   r = tmp
# asm 1: movd   <tmp=int6464#1,>r=int64#2
# asm 2: movd   <tmp=%xmm0,>r=%rsi
movd   %xmm0,%rsi

# qhasm:   *(uint64 *) (r +  0) = r0
# asm 1: movq   <r0=int64#1,0(<r=int64#2)
# asm 2: movq   <r0=%rdi,0(<r=%rsi)
movq   %rdi,0(%rsi)

# qhasm:   *(uint64 *) (r +  8) = r1
# asm 1: movq   <r1=int64#3,8(<r=int64#2)
# asm 2: movq   <r1=%rdx,8(<r=%rsi)
movq   %rdx,8(%rsi)

# qhasm:   *(uint64 *) (r + 16) = r2
# asm 1: movq   <r2=int64#4,16(<r=int64#2)
# asm 2: movq   <r2=%rcx,16(<r=%rsi)
movq   %rcx,16(%rsi)

# qhasm:   *(uint64 *) (r + 24) = r3
# asm 1: movq   <r3=int64#5,24(<r=int64#2)
# asm 2: movq   <r3=%r8,24(<r=%rsi)
movq   %r8,24(%rsi)

# qhasm: leave nostack
ret
