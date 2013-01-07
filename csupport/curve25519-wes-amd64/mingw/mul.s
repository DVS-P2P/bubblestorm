
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

# qhasm: int64 rdi

# qhasm: int64 rsi

# qhasm: caller r11

# qhasm: caller r12

# qhasm: caller r13

# qhasm: caller r14

# qhasm: caller r15

# qhasm: caller rdi

# qhasm: caller rsi

# qhasm: stack64 r11_stack

# qhasm: stack64 r12_stack

# qhasm: stack64 r13_stack

# qhasm: stack64 r14_stack

# qhasm: stack64 r15_stack

# qhasm: stack64 rdi_stack

# qhasm: stack64 rsi_stack

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
# asm 1: movq <r11=int64#7,>r11_stack=stack64#1
# asm 2: movq <r11=%r11,>r11_stack=0(%rsp)
movq %r11,0(%rsp)

# qhasm:   r12_stack = r12
# asm 1: movq <r12=int64#8,>r12_stack=stack64#2
# asm 2: movq <r12=%r12,>r12_stack=8(%rsp)
movq %r12,8(%rsp)

# qhasm:   r13_stack = r13
# asm 1: movq <r13=int64#9,>r13_stack=stack64#3
# asm 2: movq <r13=%r13,>r13_stack=16(%rsp)
movq %r13,16(%rsp)

# qhasm:   r14_stack = r14
# asm 1: movq <r14=int64#10,>r14_stack=stack64#4
# asm 2: movq <r14=%r14,>r14_stack=24(%rsp)
movq %r14,24(%rsp)

# qhasm:   r15_stack = r15
# asm 1: movq <r15=int64#11,>r15_stack=stack64#5
# asm 2: movq <r15=%r15,>r15_stack=32(%rsp)
movq %r15,32(%rsp)

# qhasm: rdi_stack = rdi
# asm 1: movq <rdi=int64#12,>rdi_stack=stack64#6
# asm 2: movq <rdi=%rdi,>rdi_stack=40(%rsp)
movq %rdi,40(%rsp)

# qhasm: rsi_stack = rsi
# asm 1: movq <rsi=int64#13,>rsi_stack=stack64#7
# asm 2: movq <rsi=%rsi,>rsi_stack=48(%rsp)
movq %rsi,48(%rsp)

# qhasm:   r_copy = r
# asm 1: movd   <r=int64#1,>r_copy=int6464#1
# asm 2: movd   <r=%rcx,>r_copy=%xmm0
movd   %rcx,%xmm0

# qhasm:   a0load  = *(uint64 *) (a +  0)
# asm 1: movq   0(<a=int64#2),>a0load=int64#1
# asm 2: movq   0(<a=%rdx),>a0load=%rcx
movq   0(%rdx),%rcx

# qhasm:   a51M19  = *(uint64 *) (a +  8)
# asm 1: movq   8(<a=int64#2),>a51M19=int64#4
# asm 2: movq   8(<a=%rdx),>a51M19=%r9
movq   8(%rdx),%r9

# qhasm:   a102M19 = *(uint64 *) (a + 16)
# asm 1: movq   16(<a=int64#2),>a102M19=int64#6
# asm 2: movq   16(<a=%rdx),>a102M19=%r10
movq   16(%rdx),%r10

# qhasm:   a153M19 = *(uint64 *) (a + 24)
# asm 1: movq   24(<a=int64#2),>a153M19=int64#7
# asm 2: movq   24(<a=%rdx),>a153M19=%r11
movq   24(%rdx),%r11

# qhasm:   a204M19 = *(uint64 *) (a + 32)
# asm 1: movq   32(<a=int64#2),>a204M19=int64#8
# asm 2: movq   32(<a=%rdx),>a204M19=%r12
movq   32(%rdx),%r12

# qhasm:   b0   = *(uint64 *) (b +  0)
# asm 1: movq   0(<b=int64#3),>b0=int64#9
# asm 2: movq   0(<b=%r8),>b0=%r13
movq   0(%r8),%r13

# qhasm:   b51  = *(uint64 *) (b +  8)
# asm 1: movq   8(<b=int64#3),>b51=int64#10
# asm 2: movq   8(<b=%r8),>b51=%r14
movq   8(%r8),%r14

# qhasm:   b102 = *(uint64 *) (b + 16)
# asm 1: movq   16(<b=int64#3),>b102=int64#11
# asm 2: movq   16(<b=%r8),>b102=%r15
movq   16(%r8),%r15

# qhasm:   b153 = *(uint64 *) (b + 24)
# asm 1: movq   24(<b=int64#3),>b153=int64#12
# asm 2: movq   24(<b=%r8),>b153=%rdi
movq   24(%r8),%rdi

# qhasm:   b204 = *(uint64 *) (b + 32)
# asm 1: movq   32(<b=int64#3),>b204=int64#3
# asm 2: movq   32(<b=%r8),>b204=%r8
movq   32(%r8),%r8

# qhasm:   a0   = a0load
# asm 1: movd   <a0load=int64#1,>a0=int6464#2
# asm 2: movd   <a0load=%rcx,>a0=%xmm1
movd   %rcx,%xmm1

# qhasm:   a51  = a51M19
# asm 1: movd   <a51M19=int64#4,>a51=int6464#3
# asm 2: movd   <a51M19=%r9,>a51=%xmm2
movd   %r9,%xmm2

# qhasm:   a102 = a102M19
# asm 1: movd   <a102M19=int64#6,>a102=int6464#4
# asm 2: movd   <a102M19=%r10,>a102=%xmm3
movd   %r10,%xmm3

# qhasm:   a153 = a153M19
# asm 1: movd   <a153M19=int64#7,>a153=int6464#5
# asm 2: movd   <a153M19=%r11,>a153=%xmm4
movd   %r11,%xmm4

# qhasm:   a204 = a204M19
# asm 1: movd   <a204M19=int64#8,>a204=int6464#6
# asm 2: movd   <a204M19=%r12,>a204=%xmm5
movd   %r12,%xmm5

# qhasm:   a51M19  *= 19
# asm 1: imul  $19,<a51M19=int64#4
# asm 2: imul  $19,<a51M19=%r9
imul  $19,%r9

# qhasm:   a102M19 *= 19
# asm 1: imul  $19,<a102M19=int64#6
# asm 2: imul  $19,<a102M19=%r10
imul  $19,%r10

# qhasm:   a153M19 *= 19
# asm 1: imul  $19,<a153M19=int64#7
# asm 2: imul  $19,<a153M19=%r11
imul  $19,%r11

# qhasm:   a204M19 *= 19
# asm 1: imul  $19,<a204M19=int64#8
# asm 2: imul  $19,<a204M19=%r12
imul  $19,%r12

# qhasm:     rax = a204M19
# asm 1: mov  <a204M19=int64#8,>rax=int64#5
# asm 2: mov  <a204M19=%r12,>rax=%rax
mov  %r12,%rax

# qhasm:     (int128) rdx rax = rax * b51
# asm 1: imul <b51=int64#10
# asm 2: imul <b51=%r14
imul %r14

# qhasm:     low = rax
# asm 1: mov  <rax=int64#5,>low=int64#1
# asm 2: mov  <rax=%rax,>low=%rcx
mov  %rax,%rcx

# qhasm:     high = rdx
# asm 1: mov  <rdx=int64#2,>high=int64#13
# asm 2: mov  <rdx=%rdx,>high=%rsi
mov  %rdx,%rsi

# qhasm:     rax = a153M19
# asm 1: mov  <a153M19=int64#7,>rax=int64#5
# asm 2: mov  <a153M19=%r11,>rax=%rax
mov  %r11,%rax

# qhasm:     (int128) rdx rax = rax * b102
# asm 1: imul <b102=int64#11
# asm 2: imul <b102=%r15
imul %r15

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a102M19
# asm 1: mov  <a102M19=int64#6,>rax=int64#5
# asm 2: mov  <a102M19=%r10,>rax=%rax
mov  %r10,%rax

# qhasm:     (int128) rdx rax = rax * b153
# asm 1: imul <b153=int64#12
# asm 2: imul <b153=%rdi
imul %rdi

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a51M19
# asm 1: mov  <a51M19=int64#4,>rax=int64#5
# asm 2: mov  <a51M19=%r9,>rax=%rax
mov  %r9,%rax

# qhasm:     (int128) rdx rax = rax * b204
# asm 1: imul <b204=int64#3
# asm 2: imul <b204=%r8
imul %r8

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a0
# asm 1: movd   <a0=int6464#2,>rax=int64#5
# asm 2: movd   <a0=%xmm1,>rax=%rax
movd   %xmm1,%rax

# qhasm:     (int128) rdx rax = rax * b0
# asm 1: imul <b0=int64#9
# asm 2: imul <b0=%r13
imul %r13

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     r0 = low
# asm 1: mov  <low=int64#1,>r0=int64#4
# asm 2: mov  <low=%rcx,>r0=%r9
mov  %rcx,%r9

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#13,<low=int64#1
# asm 2: shrd $51,<high=%rsi,<low=%rcx
shrd $51,%rsi,%rcx

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#13
# asm 2: sar  $51,<high=%rsi
sar  $51,%rsi

# qhasm:     rax = a204M19
# asm 1: mov  <a204M19=int64#8,>rax=int64#5
# asm 2: mov  <a204M19=%r12,>rax=%rax
mov  %r12,%rax

# qhasm:     (int128) rdx rax = rax * b102
# asm 1: imul <b102=int64#11
# asm 2: imul <b102=%r15
imul %r15

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a153M19
# asm 1: mov  <a153M19=int64#7,>rax=int64#5
# asm 2: mov  <a153M19=%r11,>rax=%rax
mov  %r11,%rax

# qhasm:     (int128) rdx rax = rax * b153
# asm 1: imul <b153=int64#12
# asm 2: imul <b153=%rdi
imul %rdi

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a102M19
# asm 1: mov  <a102M19=int64#6,>rax=int64#5
# asm 2: mov  <a102M19=%r10,>rax=%rax
mov  %r10,%rax

# qhasm:     (int128) rdx rax = rax * b204
# asm 1: imul <b204=int64#3
# asm 2: imul <b204=%r8
imul %r8

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a51
# asm 1: movd   <a51=int6464#3,>rax=int64#5
# asm 2: movd   <a51=%xmm2,>rax=%rax
movd   %xmm2,%rax

# qhasm:     (int128) rdx rax = rax * b0
# asm 1: imul <b0=int64#9
# asm 2: imul <b0=%r13
imul %r13

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a0
# asm 1: movd   <a0=int6464#2,>rax=int64#5
# asm 2: movd   <a0=%xmm1,>rax=%rax
movd   %xmm1,%rax

# qhasm:     (int128) rdx rax = rax * b51
# asm 1: imul <b51=int64#10
# asm 2: imul <b51=%r14
imul %r14

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     r51 = low
# asm 1: mov  <low=int64#1,>r51=int64#6
# asm 2: mov  <low=%rcx,>r51=%r10
mov  %rcx,%r10

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#13,<low=int64#1
# asm 2: shrd $51,<high=%rsi,<low=%rcx
shrd $51,%rsi,%rcx

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#13
# asm 2: sar  $51,<high=%rsi
sar  $51,%rsi

# qhasm:     rax = a204M19
# asm 1: mov  <a204M19=int64#8,>rax=int64#5
# asm 2: mov  <a204M19=%r12,>rax=%rax
mov  %r12,%rax

# qhasm:     (int128) rdx rax = rax * b153
# asm 1: imul <b153=int64#12
# asm 2: imul <b153=%rdi
imul %rdi

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a153M19
# asm 1: mov  <a153M19=int64#7,>rax=int64#5
# asm 2: mov  <a153M19=%r11,>rax=%rax
mov  %r11,%rax

# qhasm:     (int128) rdx rax = rax * b204
# asm 1: imul <b204=int64#3
# asm 2: imul <b204=%r8
imul %r8

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a102
# asm 1: movd   <a102=int6464#4,>rax=int64#5
# asm 2: movd   <a102=%xmm3,>rax=%rax
movd   %xmm3,%rax

# qhasm:     (int128) rdx rax = rax * b0
# asm 1: imul <b0=int64#9
# asm 2: imul <b0=%r13
imul %r13

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a51
# asm 1: movd   <a51=int6464#3,>rax=int64#5
# asm 2: movd   <a51=%xmm2,>rax=%rax
movd   %xmm2,%rax

# qhasm:     (int128) rdx rax = rax * b51
# asm 1: imul <b51=int64#10
# asm 2: imul <b51=%r14
imul %r14

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a0
# asm 1: movd   <a0=int6464#2,>rax=int64#5
# asm 2: movd   <a0=%xmm1,>rax=%rax
movd   %xmm1,%rax

# qhasm:     (int128) rdx rax = rax * b102
# asm 1: imul <b102=int64#11
# asm 2: imul <b102=%r15
imul %r15

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     r102 = low
# asm 1: mov  <low=int64#1,>r102=int64#7
# asm 2: mov  <low=%rcx,>r102=%r11
mov  %rcx,%r11

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#13,<low=int64#1
# asm 2: shrd $51,<high=%rsi,<low=%rcx
shrd $51,%rsi,%rcx

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#13
# asm 2: sar  $51,<high=%rsi
sar  $51,%rsi

# qhasm:     rax = a204M19
# asm 1: mov  <a204M19=int64#8,>rax=int64#5
# asm 2: mov  <a204M19=%r12,>rax=%rax
mov  %r12,%rax

# qhasm:     (int128) rdx rax = rax * b204
# asm 1: imul <b204=int64#3
# asm 2: imul <b204=%r8
imul %r8

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a153
# asm 1: movd   <a153=int6464#5,>rax=int64#5
# asm 2: movd   <a153=%xmm4,>rax=%rax
movd   %xmm4,%rax

# qhasm:     (int128) rdx rax = rax * b0
# asm 1: imul <b0=int64#9
# asm 2: imul <b0=%r13
imul %r13

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a102
# asm 1: movd   <a102=int6464#4,>rax=int64#5
# asm 2: movd   <a102=%xmm3,>rax=%rax
movd   %xmm3,%rax

# qhasm:     (int128) rdx rax = rax * b51
# asm 1: imul <b51=int64#10
# asm 2: imul <b51=%r14
imul %r14

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a51
# asm 1: movd   <a51=int6464#3,>rax=int64#5
# asm 2: movd   <a51=%xmm2,>rax=%rax
movd   %xmm2,%rax

# qhasm:     (int128) rdx rax = rax * b102
# asm 1: imul <b102=int64#11
# asm 2: imul <b102=%r15
imul %r15

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a0
# asm 1: movd   <a0=int6464#2,>rax=int64#5
# asm 2: movd   <a0=%xmm1,>rax=%rax
movd   %xmm1,%rax

# qhasm:     (int128) rdx rax = rax * b153
# asm 1: imul <b153=int64#12
# asm 2: imul <b153=%rdi
imul %rdi

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     r153 = low
# asm 1: mov  <low=int64#1,>r153=int64#8
# asm 2: mov  <low=%rcx,>r153=%r12
mov  %rcx,%r12

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#13,<low=int64#1
# asm 2: shrd $51,<high=%rsi,<low=%rcx
shrd $51,%rsi,%rcx

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#13
# asm 2: sar  $51,<high=%rsi
sar  $51,%rsi

# qhasm:     rax = a204
# asm 1: movd   <a204=int6464#6,>rax=int64#5
# asm 2: movd   <a204=%xmm5,>rax=%rax
movd   %xmm5,%rax

# qhasm:     (int128) rdx rax = rax * b0
# asm 1: imul <b0=int64#9
# asm 2: imul <b0=%r13
imul %r13

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a153
# asm 1: movd   <a153=int6464#5,>rax=int64#5
# asm 2: movd   <a153=%xmm4,>rax=%rax
movd   %xmm4,%rax

# qhasm:     (int128) rdx rax = rax * b51
# asm 1: imul <b51=int64#10
# asm 2: imul <b51=%r14
imul %r14

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a102
# asm 1: movd   <a102=int6464#4,>rax=int64#5
# asm 2: movd   <a102=%xmm3,>rax=%rax
movd   %xmm3,%rax

# qhasm:     (int128) rdx rax = rax * b102
# asm 1: imul <b102=int64#11
# asm 2: imul <b102=%r15
imul %r15

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a51
# asm 1: movd   <a51=int6464#3,>rax=int64#5
# asm 2: movd   <a51=%xmm2,>rax=%rax
movd   %xmm2,%rax

# qhasm:     (int128) rdx rax = rax * b153
# asm 1: imul <b153=int64#12
# asm 2: imul <b153=%rdi
imul %rdi

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     rax = a0
# asm 1: movd   <a0=int6464#2,>rax=int64#5
# asm 2: movd   <a0=%xmm1,>rax=%rax
movd   %xmm1,%rax

# qhasm:     (int128) rdx rax = rax * b204
# asm 1: imul <b204=int64#3
# asm 2: imul <b204=%r8
imul %r8

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#1
# asm 2: add  <rax=%rax,<low=%rcx
add  %rax,%rcx

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#13
# asm 2: adc <rdx=%rdx,<high=%rsi
adc %rdx,%rsi

# qhasm:     r204 = low
# asm 1: mov  <low=int64#1,>r204=int64#3
# asm 2: mov  <low=%rcx,>r204=%r8
mov  %rcx,%r8

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#13,<low=int64#1
# asm 2: shrd $51,<high=%rsi,<low=%rcx
shrd $51,%rsi,%rcx

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#13
# asm 2: sar  $51,<high=%rsi
sar  $51,%rsi

# qhasm:   mask = 0x7ffffffffffff
# asm 1: mov  $0x7ffffffffffff,>mask=int64#9
# asm 2: mov  $0x7ffffffffffff,>mask=%r13
mov  $0x7ffffffffffff,%r13

# qhasm:   r = r_copy
# asm 1: movd   <r_copy=int6464#1,>r=int64#10
# asm 2: movd   <r_copy=%xmm0,>r=%r14
movd   %xmm0,%r14

# qhasm:   r0   &= mask
# asm 1: and  <mask=int64#9,<r0=int64#4
# asm 2: and  <mask=%r13,<r0=%r9
and  %r13,%r9

# qhasm:   r51  &= mask
# asm 1: and  <mask=int64#9,<r51=int64#6
# asm 2: and  <mask=%r13,<r51=%r10
and  %r13,%r10

# qhasm:   r102 &= mask
# asm 1: and  <mask=int64#9,<r102=int64#7
# asm 2: and  <mask=%r13,<r102=%r11
and  %r13,%r11

# qhasm:   r153 &= mask
# asm 1: and  <mask=int64#9,<r153=int64#8
# asm 2: and  <mask=%r13,<r153=%r12
and  %r13,%r12

# qhasm:   r204 &= mask
# asm 1: and  <mask=int64#9,<r204=int64#3
# asm 2: and  <mask=%r13,<r204=%r8
and  %r13,%r8

# qhasm:   high *= 19
# asm 1: imul  $19,<high=int64#13
# asm 2: imul  $19,<high=%rsi
imul  $19,%rsi

# qhasm:   rax = 19
# asm 1: mov  $19,>rax=int64#5
# asm 2: mov  $19,>rax=%rax
mov  $19,%rax

# qhasm:   (uint128) rdx rax = rax * low
# asm 1: mul  <low=int64#1
# asm 2: mul  <low=%rcx
mul  %rcx

# qhasm:   rdx += high
# asm 1: add  <high=int64#13,<rdx=int64#2
# asm 2: add  <high=%rsi,<rdx=%rdx
add  %rsi,%rdx

# qhasm:   mask &= rax
# asm 1: and  <rax=int64#5,<mask=int64#9
# asm 2: and  <rax=%rax,<mask=%r13
and  %rax,%r13

# qhasm:   rax = (rdx rax) >> 51
# asm 1: shrd $51,<rdx=int64#2,<rax=int64#5
# asm 2: shrd $51,<rdx=%rdx,<rax=%rax
shrd $51,%rdx,%rax

# qhasm:   r0  += mask
# asm 1: add  <mask=int64#9,<r0=int64#4
# asm 2: add  <mask=%r13,<r0=%r9
add  %r13,%r9

# qhasm:   r51 += rax
# asm 1: add  <rax=int64#5,<r51=int64#6
# asm 2: add  <rax=%rax,<r51=%r10
add  %rax,%r10

# qhasm:   *(uint64 *) (r +  0) = r0
# asm 1: movq   <r0=int64#4,0(<r=int64#10)
# asm 2: movq   <r0=%r9,0(<r=%r14)
movq   %r9,0(%r14)

# qhasm:   *(uint64 *) (r +  8) = r51
# asm 1: movq   <r51=int64#6,8(<r=int64#10)
# asm 2: movq   <r51=%r10,8(<r=%r14)
movq   %r10,8(%r14)

# qhasm:   *(uint64 *) (r + 16) = r102
# asm 1: movq   <r102=int64#7,16(<r=int64#10)
# asm 2: movq   <r102=%r11,16(<r=%r14)
movq   %r11,16(%r14)

# qhasm:   *(uint64 *) (r + 24) = r153
# asm 1: movq   <r153=int64#8,24(<r=int64#10)
# asm 2: movq   <r153=%r12,24(<r=%r14)
movq   %r12,24(%r14)

# qhasm:   *(uint64 *) (r + 32) = r204
# asm 1: movq   <r204=int64#3,32(<r=int64#10)
# asm 2: movq   <r204=%r8,32(<r=%r14)
movq   %r8,32(%r14)

# qhasm:   r11 = r11_stack
# asm 1: movq <r11_stack=stack64#1,>r11=int64#7
# asm 2: movq <r11_stack=0(%rsp),>r11=%r11
movq 0(%rsp),%r11

# qhasm:   r12 = r12_stack
# asm 1: movq <r12_stack=stack64#2,>r12=int64#8
# asm 2: movq <r12_stack=8(%rsp),>r12=%r12
movq 8(%rsp),%r12

# qhasm:   r13 = r13_stack
# asm 1: movq <r13_stack=stack64#3,>r13=int64#9
# asm 2: movq <r13_stack=16(%rsp),>r13=%r13
movq 16(%rsp),%r13

# qhasm:   r14 = r14_stack
# asm 1: movq <r14_stack=stack64#4,>r14=int64#10
# asm 2: movq <r14_stack=24(%rsp),>r14=%r14
movq 24(%rsp),%r14

# qhasm:   r15 = r15_stack
# asm 1: movq <r15_stack=stack64#5,>r15=int64#11
# asm 2: movq <r15_stack=32(%rsp),>r15=%r15
movq 32(%rsp),%r15

# qhasm: rdi = rdi_stack
# asm 1: movq <rdi_stack=stack64#6,>rdi=int64#12
# asm 2: movq <rdi_stack=40(%rsp),>rdi=%rdi
movq 40(%rsp),%rdi

# qhasm: rsi = rsi_stack
# asm 1: movq <rsi_stack=stack64#7,>rsi=int64#13
# asm 2: movq <rsi_stack=48(%rsp),>rsi=%rsi
movq 48(%rsp),%rsi

# qhasm: leave
add %r11,%rsp
ret
