
# qhasm: int64 r

# qhasm: int64 a

# qhasm: int64 b

# qhasm: int64 a0load

# qhasm: int64 a51M19

# qhasm: int64 a102M19

# qhasm: int64 a153M19

# qhasm: int64 a204M19

# qhasm: int6464 a0

# qhasm: int6464 a51

# qhasm: int6464 a102

# qhasm: int6464 a153

# qhasm: int6464 a204

# qhasm: int6464 r_copy

# qhasm: int64 b0

# qhasm: int64 b51

# qhasm: int64 b102

# qhasm: int64 b153

# qhasm: int64 b204

# qhasm: int64 r0

# qhasm: int64 r51

# qhasm: int64 r102

# qhasm: int64 r153

# qhasm: int64 r204

# qhasm: int64 rax

# qhasm: int64 rdx

# qhasm: int64 high

# qhasm: int64 low

# qhasm: int64 mask

# qhasm: int64 r11

# qhasm: int64 r12

# qhasm: int64 r13

# qhasm: int64 r14

# qhasm: int64 r15

# qhasm: caller r11

# qhasm: caller r12

# qhasm: caller r13

# qhasm: caller r14

# qhasm: caller r15

# qhasm: stack64 r11_stack

# qhasm: stack64 r12_stack

# qhasm: stack64 r13_stack

# qhasm: stack64 r14_stack

# qhasm: stack64 r15_stack

# qhasm: enter field25519_wes_mul
.text
.p2align 5
.globl _field25519_wes_mul
.globl field25519_wes_mul
_field25519_wes_mul:
field25519_wes_mul:
mov %rsp,%r11
and $31,%r11
add $64,%r11
sub %r11,%rsp

# qhasm:   input r

# qhasm:   input a

# qhasm:   input b

# qhasm:   r11_stack = r11
# asm 1: movq <r11=int64#9,>r11_stack=stack64#1
# asm 2: movq <r11=%r11,>r11_stack=0(%rsp)
movq %r11,0(%rsp)

# qhasm:   r12_stack = r12
# asm 1: movq <r12=int64#10,>r12_stack=stack64#2
# asm 2: movq <r12=%r12,>r12_stack=8(%rsp)
movq %r12,8(%rsp)

# qhasm:   r13_stack = r13
# asm 1: movq <r13=int64#11,>r13_stack=stack64#3
# asm 2: movq <r13=%r13,>r13_stack=16(%rsp)
movq %r13,16(%rsp)

# qhasm:   r14_stack = r14
# asm 1: movq <r14=int64#12,>r14_stack=stack64#4
# asm 2: movq <r14=%r14,>r14_stack=24(%rsp)
movq %r14,24(%rsp)

# qhasm:   r15_stack = r15
# asm 1: movq <r15=int64#13,>r15_stack=stack64#5
# asm 2: movq <r15=%r15,>r15_stack=32(%rsp)
movq %r15,32(%rsp)

# qhasm:   r_copy = r
# asm 1: movd   <r=int64#1,>r_copy=int6464#1
# asm 2: movd   <r=%rdi,>r_copy=%xmm0
movd   %rdi,%xmm0

# qhasm:   a0load  = *(uint64 *) (a +  0)
# asm 1: movq   0(<a=int64#2),>a0load=int64#1
# asm 2: movq   0(<a=%rsi),>a0load=%rdi
movq   0(%rsi),%rdi

# qhasm:   a51M19  = *(uint64 *) (a +  8)
# asm 1: movq   8(<a=int64#2),>a51M19=int64#4
# asm 2: movq   8(<a=%rsi),>a51M19=%rcx
movq   8(%rsi),%rcx

# qhasm:   a102M19 = *(uint64 *) (a + 16)
# asm 1: movq   16(<a=int64#2),>a102M19=int64#5
# asm 2: movq   16(<a=%rsi),>a102M19=%r8
movq   16(%rsi),%r8

# qhasm:   a153M19 = *(uint64 *) (a + 24)
# asm 1: movq   24(<a=int64#2),>a153M19=int64#6
# asm 2: movq   24(<a=%rsi),>a153M19=%r9
movq   24(%rsi),%r9

# qhasm:   a204M19 = *(uint64 *) (a + 32)
# asm 1: movq   32(<a=int64#2),>a204M19=int64#2
# asm 2: movq   32(<a=%rsi),>a204M19=%rsi
movq   32(%rsi),%rsi

# qhasm:   b0   = *(uint64 *) (b +  0)
# asm 1: movq   0(<b=int64#3),>b0=int64#8
# asm 2: movq   0(<b=%rdx),>b0=%r10
movq   0(%rdx),%r10

# qhasm:   b51  = *(uint64 *) (b +  8)
# asm 1: movq   8(<b=int64#3),>b51=int64#9
# asm 2: movq   8(<b=%rdx),>b51=%r11
movq   8(%rdx),%r11

# qhasm:   b102 = *(uint64 *) (b + 16)
# asm 1: movq   16(<b=int64#3),>b102=int64#10
# asm 2: movq   16(<b=%rdx),>b102=%r12
movq   16(%rdx),%r12

# qhasm:   b153 = *(uint64 *) (b + 24)
# asm 1: movq   24(<b=int64#3),>b153=int64#11
# asm 2: movq   24(<b=%rdx),>b153=%r13
movq   24(%rdx),%r13

# qhasm:   b204 = *(uint64 *) (b + 32)
# asm 1: movq   32(<b=int64#3),>b204=int64#12
# asm 2: movq   32(<b=%rdx),>b204=%r14
movq   32(%rdx),%r14

# qhasm:   a0   = a0load
# asm 1: movd   <a0load=int64#1,>a0=int6464#2
# asm 2: movd   <a0load=%rdi,>a0=%xmm1
movd   %rdi,%xmm1

# qhasm:   a51  = a51M19
# asm 1: movd   <a51M19=int64#4,>a51=int6464#3
# asm 2: movd   <a51M19=%rcx,>a51=%xmm2
movd   %rcx,%xmm2

# qhasm:   a102 = a102M19
# asm 1: movd   <a102M19=int64#5,>a102=int6464#4
# asm 2: movd   <a102M19=%r8,>a102=%xmm3
movd   %r8,%xmm3

# qhasm:   a153 = a153M19
# asm 1: movd   <a153M19=int64#6,>a153=int6464#5
# asm 2: movd   <a153M19=%r9,>a153=%xmm4
movd   %r9,%xmm4

# qhasm:   a204 = a204M19
# asm 1: movd   <a204M19=int64#2,>a204=int6464#6
# asm 2: movd   <a204M19=%rsi,>a204=%xmm5
movd   %rsi,%xmm5

# qhasm:   a51M19  *= 19
# asm 1: imul  $19,<a51M19=int64#4
# asm 2: imul  $19,<a51M19=%rcx
imul  $19,%rcx

# qhasm:   a102M19 *= 19
# asm 1: imul  $19,<a102M19=int64#5
# asm 2: imul  $19,<a102M19=%r8
imul  $19,%r8

# qhasm:   a153M19 *= 19
# asm 1: imul  $19,<a153M19=int64#6
# asm 2: imul  $19,<a153M19=%r9
imul  $19,%r9

# qhasm:   a204M19 *= 19
# asm 1: imul  $19,<a204M19=int64#2
# asm 2: imul  $19,<a204M19=%rsi
imul  $19,%rsi

# qhasm:     rax = a204M19
# asm 1: mov  <a204M19=int64#2,>rax=int64#7
# asm 2: mov  <a204M19=%rsi,>rax=%rax
mov  %rsi,%rax

# qhasm:     (int128) rdx rax = rax * b51
# asm 1: imul <b51=int64#9
# asm 2: imul <b51=%r11
imul %r11

# qhasm:     low = rax
# asm 1: mov  <rax=int64#7,>low=int64#1
# asm 2: mov  <rax=%rax,>low=%rdi
mov  %rax,%rdi

# qhasm:     high = rdx
# asm 1: mov  <rdx=int64#3,>high=int64#13
# asm 2: mov  <rdx=%rdx,>high=%r15
mov  %rdx,%r15

# qhasm:     rax = a153M19
# asm 1: mov  <a153M19=int64#6,>rax=int64#7
# asm 2: mov  <a153M19=%r9,>rax=%rax
mov  %r9,%rax

# qhasm:     (int128) rdx rax = rax * b102
# asm 1: imul <b102=int64#10
# asm 2: imul <b102=%r12
imul %r12

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a102M19
# asm 1: mov  <a102M19=int64#5,>rax=int64#7
# asm 2: mov  <a102M19=%r8,>rax=%rax
mov  %r8,%rax

# qhasm:     (int128) rdx rax = rax * b153
# asm 1: imul <b153=int64#11
# asm 2: imul <b153=%r13
imul %r13

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a51M19
# asm 1: mov  <a51M19=int64#4,>rax=int64#7
# asm 2: mov  <a51M19=%rcx,>rax=%rax
mov  %rcx,%rax

# qhasm:     (int128) rdx rax = rax * b204
# asm 1: imul <b204=int64#12
# asm 2: imul <b204=%r14
imul %r14

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a0
# asm 1: movd   <a0=int6464#2,>rax=int64#7
# asm 2: movd   <a0=%xmm1,>rax=%rax
movd   %xmm1,%rax

# qhasm:     (int128) rdx rax = rax * b0
# asm 1: imul <b0=int64#8
# asm 2: imul <b0=%r10
imul %r10

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     r0 = low
# asm 1: mov  <low=int64#1,>r0=int64#4
# asm 2: mov  <low=%rdi,>r0=%rcx
mov  %rdi,%rcx

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#13,<low=int64#1
# asm 2: shrd $51,<high=%r15,<low=%rdi
shrd $51,%r15,%rdi

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#13
# asm 2: sar  $51,<high=%r15
sar  $51,%r15

# qhasm:     rax = a204M19
# asm 1: mov  <a204M19=int64#2,>rax=int64#7
# asm 2: mov  <a204M19=%rsi,>rax=%rax
mov  %rsi,%rax

# qhasm:     (int128) rdx rax = rax * b102
# asm 1: imul <b102=int64#10
# asm 2: imul <b102=%r12
imul %r12

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a153M19
# asm 1: mov  <a153M19=int64#6,>rax=int64#7
# asm 2: mov  <a153M19=%r9,>rax=%rax
mov  %r9,%rax

# qhasm:     (int128) rdx rax = rax * b153
# asm 1: imul <b153=int64#11
# asm 2: imul <b153=%r13
imul %r13

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a102M19
# asm 1: mov  <a102M19=int64#5,>rax=int64#7
# asm 2: mov  <a102M19=%r8,>rax=%rax
mov  %r8,%rax

# qhasm:     (int128) rdx rax = rax * b204
# asm 1: imul <b204=int64#12
# asm 2: imul <b204=%r14
imul %r14

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a51
# asm 1: movd   <a51=int6464#3,>rax=int64#7
# asm 2: movd   <a51=%xmm2,>rax=%rax
movd   %xmm2,%rax

# qhasm:     (int128) rdx rax = rax * b0
# asm 1: imul <b0=int64#8
# asm 2: imul <b0=%r10
imul %r10

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a0
# asm 1: movd   <a0=int6464#2,>rax=int64#7
# asm 2: movd   <a0=%xmm1,>rax=%rax
movd   %xmm1,%rax

# qhasm:     (int128) rdx rax = rax * b51
# asm 1: imul <b51=int64#9
# asm 2: imul <b51=%r11
imul %r11

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     r51 = low
# asm 1: mov  <low=int64#1,>r51=int64#5
# asm 2: mov  <low=%rdi,>r51=%r8
mov  %rdi,%r8

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#13,<low=int64#1
# asm 2: shrd $51,<high=%r15,<low=%rdi
shrd $51,%r15,%rdi

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#13
# asm 2: sar  $51,<high=%r15
sar  $51,%r15

# qhasm:     rax = a204M19
# asm 1: mov  <a204M19=int64#2,>rax=int64#7
# asm 2: mov  <a204M19=%rsi,>rax=%rax
mov  %rsi,%rax

# qhasm:     (int128) rdx rax = rax * b153
# asm 1: imul <b153=int64#11
# asm 2: imul <b153=%r13
imul %r13

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a153M19
# asm 1: mov  <a153M19=int64#6,>rax=int64#7
# asm 2: mov  <a153M19=%r9,>rax=%rax
mov  %r9,%rax

# qhasm:     (int128) rdx rax = rax * b204
# asm 1: imul <b204=int64#12
# asm 2: imul <b204=%r14
imul %r14

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a102
# asm 1: movd   <a102=int6464#4,>rax=int64#7
# asm 2: movd   <a102=%xmm3,>rax=%rax
movd   %xmm3,%rax

# qhasm:     (int128) rdx rax = rax * b0
# asm 1: imul <b0=int64#8
# asm 2: imul <b0=%r10
imul %r10

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a51
# asm 1: movd   <a51=int6464#3,>rax=int64#7
# asm 2: movd   <a51=%xmm2,>rax=%rax
movd   %xmm2,%rax

# qhasm:     (int128) rdx rax = rax * b51
# asm 1: imul <b51=int64#9
# asm 2: imul <b51=%r11
imul %r11

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a0
# asm 1: movd   <a0=int6464#2,>rax=int64#7
# asm 2: movd   <a0=%xmm1,>rax=%rax
movd   %xmm1,%rax

# qhasm:     (int128) rdx rax = rax * b102
# asm 1: imul <b102=int64#10
# asm 2: imul <b102=%r12
imul %r12

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     r102 = low
# asm 1: mov  <low=int64#1,>r102=int64#6
# asm 2: mov  <low=%rdi,>r102=%r9
mov  %rdi,%r9

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#13,<low=int64#1
# asm 2: shrd $51,<high=%r15,<low=%rdi
shrd $51,%r15,%rdi

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#13
# asm 2: sar  $51,<high=%r15
sar  $51,%r15

# qhasm:     rax = a204M19
# asm 1: mov  <a204M19=int64#2,>rax=int64#7
# asm 2: mov  <a204M19=%rsi,>rax=%rax
mov  %rsi,%rax

# qhasm:     (int128) rdx rax = rax * b204
# asm 1: imul <b204=int64#12
# asm 2: imul <b204=%r14
imul %r14

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a153
# asm 1: movd   <a153=int6464#5,>rax=int64#7
# asm 2: movd   <a153=%xmm4,>rax=%rax
movd   %xmm4,%rax

# qhasm:     (int128) rdx rax = rax * b0
# asm 1: imul <b0=int64#8
# asm 2: imul <b0=%r10
imul %r10

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a102
# asm 1: movd   <a102=int6464#4,>rax=int64#7
# asm 2: movd   <a102=%xmm3,>rax=%rax
movd   %xmm3,%rax

# qhasm:     (int128) rdx rax = rax * b51
# asm 1: imul <b51=int64#9
# asm 2: imul <b51=%r11
imul %r11

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a51
# asm 1: movd   <a51=int6464#3,>rax=int64#7
# asm 2: movd   <a51=%xmm2,>rax=%rax
movd   %xmm2,%rax

# qhasm:     (int128) rdx rax = rax * b102
# asm 1: imul <b102=int64#10
# asm 2: imul <b102=%r12
imul %r12

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a0
# asm 1: movd   <a0=int6464#2,>rax=int64#7
# asm 2: movd   <a0=%xmm1,>rax=%rax
movd   %xmm1,%rax

# qhasm:     (int128) rdx rax = rax * b153
# asm 1: imul <b153=int64#11
# asm 2: imul <b153=%r13
imul %r13

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     r153 = low
# asm 1: mov  <low=int64#1,>r153=int64#2
# asm 2: mov  <low=%rdi,>r153=%rsi
mov  %rdi,%rsi

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#13,<low=int64#1
# asm 2: shrd $51,<high=%r15,<low=%rdi
shrd $51,%r15,%rdi

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#13
# asm 2: sar  $51,<high=%r15
sar  $51,%r15

# qhasm:     rax = a204
# asm 1: movd   <a204=int6464#6,>rax=int64#7
# asm 2: movd   <a204=%xmm5,>rax=%rax
movd   %xmm5,%rax

# qhasm:     (int128) rdx rax = rax * b0
# asm 1: imul <b0=int64#8
# asm 2: imul <b0=%r10
imul %r10

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a153
# asm 1: movd   <a153=int6464#5,>rax=int64#7
# asm 2: movd   <a153=%xmm4,>rax=%rax
movd   %xmm4,%rax

# qhasm:     (int128) rdx rax = rax * b51
# asm 1: imul <b51=int64#9
# asm 2: imul <b51=%r11
imul %r11

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a102
# asm 1: movd   <a102=int6464#4,>rax=int64#7
# asm 2: movd   <a102=%xmm3,>rax=%rax
movd   %xmm3,%rax

# qhasm:     (int128) rdx rax = rax * b102
# asm 1: imul <b102=int64#10
# asm 2: imul <b102=%r12
imul %r12

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a51
# asm 1: movd   <a51=int6464#3,>rax=int64#7
# asm 2: movd   <a51=%xmm2,>rax=%rax
movd   %xmm2,%rax

# qhasm:     (int128) rdx rax = rax * b153
# asm 1: imul <b153=int64#11
# asm 2: imul <b153=%r13
imul %r13

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a0
# asm 1: movd   <a0=int6464#2,>rax=int64#7
# asm 2: movd   <a0=%xmm1,>rax=%rax
movd   %xmm1,%rax

# qhasm:     (int128) rdx rax = rax * b204
# asm 1: imul <b204=int64#12
# asm 2: imul <b204=%r14
imul %r14

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#7,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rdi
add  %rax,%rdi

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#3,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     r204 = low
# asm 1: mov  <low=int64#1,>r204=int64#8
# asm 2: mov  <low=%rdi,>r204=%r10
mov  %rdi,%r10

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#13,<low=int64#1
# asm 2: shrd $51,<high=%r15,<low=%rdi
shrd $51,%r15,%rdi

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#13
# asm 2: sar  $51,<high=%r15
sar  $51,%r15

# qhasm:   mask = 0x7ffffffffffff
# asm 1: mov  $0x7ffffffffffff,>mask=int64#9
# asm 2: mov  $0x7ffffffffffff,>mask=%r11
mov  $0x7ffffffffffff,%r11

# qhasm:   r = r_copy
# asm 1: movd   <r_copy=int6464#1,>r=int64#10
# asm 2: movd   <r_copy=%xmm0,>r=%r12
movd   %xmm0,%r12

# qhasm:   r0   &= mask
# asm 1: and  <mask=int64#9,<r0=int64#4
# asm 2: and  <mask=%r11,<r0=%rcx
and  %r11,%rcx

# qhasm:   r51  &= mask
# asm 1: and  <mask=int64#9,<r51=int64#5
# asm 2: and  <mask=%r11,<r51=%r8
and  %r11,%r8

# qhasm:   r102 &= mask
# asm 1: and  <mask=int64#9,<r102=int64#6
# asm 2: and  <mask=%r11,<r102=%r9
and  %r11,%r9

# qhasm:   r153 &= mask
# asm 1: and  <mask=int64#9,<r153=int64#2
# asm 2: and  <mask=%r11,<r153=%rsi
and  %r11,%rsi

# qhasm:   r204 &= mask
# asm 1: and  <mask=int64#9,<r204=int64#8
# asm 2: and  <mask=%r11,<r204=%r10
and  %r11,%r10

# qhasm:   high *= 19
# asm 1: imul  $19,<high=int64#13
# asm 2: imul  $19,<high=%r15
imul  $19,%r15

# qhasm:   rax = 19
# asm 1: mov  $19,>rax=int64#7
# asm 2: mov  $19,>rax=%rax
mov  $19,%rax

# qhasm:   (uint128) rdx rax = rax * low
# asm 1: mul  <low=int64#1
# asm 2: mul  <low=%rdi
mul  %rdi

# qhasm:   rdx += high
# asm 1: add  <high=int64#13,<rdx=int64#3
# asm 2: add  <high=%r15,<rdx=%rdx
add  %r15,%rdx

# qhasm:   mask &= rax
# asm 1: and  <rax=int64#7,<mask=int64#9
# asm 2: and  <rax=%rax,<mask=%r11
and  %rax,%r11

# qhasm:   rax = (rdx rax) >> 51
# asm 1: shrd $51,<rdx=int64#3,<rax=int64#7
# asm 2: shrd $51,<rdx=%rdx,<rax=%rax
shrd $51,%rdx,%rax

# qhasm:   r0  += mask
# asm 1: add  <mask=int64#9,<r0=int64#4
# asm 2: add  <mask=%r11,<r0=%rcx
add  %r11,%rcx

# qhasm:   r51 += rax
# asm 1: add  <rax=int64#7,<r51=int64#5
# asm 2: add  <rax=%rax,<r51=%r8
add  %rax,%r8

# qhasm:   *(uint64 *) (r +  0) = r0
# asm 1: movq   <r0=int64#4,0(<r=int64#10)
# asm 2: movq   <r0=%rcx,0(<r=%r12)
movq   %rcx,0(%r12)

# qhasm:   *(uint64 *) (r +  8) = r51
# asm 1: movq   <r51=int64#5,8(<r=int64#10)
# asm 2: movq   <r51=%r8,8(<r=%r12)
movq   %r8,8(%r12)

# qhasm:   *(uint64 *) (r + 16) = r102
# asm 1: movq   <r102=int64#6,16(<r=int64#10)
# asm 2: movq   <r102=%r9,16(<r=%r12)
movq   %r9,16(%r12)

# qhasm:   *(uint64 *) (r + 24) = r153
# asm 1: movq   <r153=int64#2,24(<r=int64#10)
# asm 2: movq   <r153=%rsi,24(<r=%r12)
movq   %rsi,24(%r12)

# qhasm:   *(uint64 *) (r + 32) = r204
# asm 1: movq   <r204=int64#8,32(<r=int64#10)
# asm 2: movq   <r204=%r10,32(<r=%r12)
movq   %r10,32(%r12)

# qhasm:   r11 = r11_stack
# asm 1: movq <r11_stack=stack64#1,>r11=int64#9
# asm 2: movq <r11_stack=0(%rsp),>r11=%r11
movq 0(%rsp),%r11

# qhasm:   r12 = r12_stack
# asm 1: movq <r12_stack=stack64#2,>r12=int64#10
# asm 2: movq <r12_stack=8(%rsp),>r12=%r12
movq 8(%rsp),%r12

# qhasm:   r13 = r13_stack
# asm 1: movq <r13_stack=stack64#3,>r13=int64#11
# asm 2: movq <r13_stack=16(%rsp),>r13=%r13
movq 16(%rsp),%r13

# qhasm:   r14 = r14_stack
# asm 1: movq <r14_stack=stack64#4,>r14=int64#12
# asm 2: movq <r14_stack=24(%rsp),>r14=%r14
movq 24(%rsp),%r14

# qhasm:   r15 = r15_stack
# asm 1: movq <r15_stack=stack64#5,>r15=int64#13
# asm 2: movq <r15_stack=32(%rsp),>r15=%r15
movq 32(%rsp),%r15

# qhasm: leave
add %r11,%rsp
ret
