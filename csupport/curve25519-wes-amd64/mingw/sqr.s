
# qhasm: int64 r

# qhasm: int64 a

# qhasm: int6464 r_copy

# qhasm: int64 a0

# qhasm: int64 a51

# qhasm: int64 a102

# qhasm: int64 a153

# qhasm: int64 a204

# qhasm: int64 a204M19

# qhasm: int64 a153M19

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

# qhasm: enter field25519_wes_sqr
.text
.p2align 5
.globl _field25519_wes_sqr
.globl field25519_wes_sqr
_field25519_wes_sqr:
field25519_wes_sqr:
mov %rsp,%r11
and $31,%r11
add $64,%r11
sub %r11,%rsp

# qhasm:   input r

# qhasm:   input a

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

# qhasm:   a0   = *(uint64 *) (a +  0)
# asm 1: movq   0(<a=int64#2),>a0=int64#1
# asm 2: movq   0(<a=%rdx),>a0=%rcx
movq   0(%rdx),%rcx

# qhasm:   a51  = *(uint64 *) (a +  8)
# asm 1: movq   8(<a=int64#2),>a51=int64#3
# asm 2: movq   8(<a=%rdx),>a51=%r8
movq   8(%rdx),%r8

# qhasm:   a102 = *(uint64 *) (a + 16)
# asm 1: movq   16(<a=int64#2),>a102=int64#4
# asm 2: movq   16(<a=%rdx),>a102=%r9
movq   16(%rdx),%r9

# qhasm:   a153 = *(uint64 *) (a + 24)
# asm 1: movq   24(<a=int64#2),>a153=int64#6
# asm 2: movq   24(<a=%rdx),>a153=%r10
movq   24(%rdx),%r10

# qhasm:   a204 = *(uint64 *) (a + 32)
# asm 1: movq   32(<a=int64#2),>a204=int64#7
# asm 2: movq   32(<a=%rdx),>a204=%r11
movq   32(%rdx),%r11

# qhasm:   a204M19 = a204
# asm 1: mov  <a204=int64#7,>a204M19=int64#8
# asm 2: mov  <a204=%r11,>a204M19=%r12
mov  %r11,%r12

# qhasm:   a153M19 = a153
# asm 1: mov  <a153=int64#6,>a153M19=int64#9
# asm 2: mov  <a153=%r10,>a153M19=%r13
mov  %r10,%r13

# qhasm:   a204M19 *= 19
# asm 1: imul  $19,<a204M19=int64#8
# asm 2: imul  $19,<a204M19=%r12
imul  $19,%r12

# qhasm:   a153M19 *= 19
# asm 1: imul  $19,<a153M19=int64#9
# asm 2: imul  $19,<a153M19=%r13
imul  $19,%r13

# qhasm:     rax = a51 + a51
# asm 1: lea  (<a51=int64#3,<a51=int64#3),>rax=int64#5
# asm 2: lea  (<a51=%r8,<a51=%r8),>rax=%rax
lea  (%r8,%r8),%rax

# qhasm:     (int128) rdx rax = rax * a204M19
# asm 1: imul <a204M19=int64#8
# asm 2: imul <a204M19=%r12
imul %r12

# qhasm:     low = rax
# asm 1: mov  <rax=int64#5,>low=int64#10
# asm 2: mov  <rax=%rax,>low=%r14
mov  %rax,%r14

# qhasm:     high = rdx
# asm 1: mov  <rdx=int64#2,>high=int64#11
# asm 2: mov  <rdx=%rdx,>high=%r15
mov  %rdx,%r15

# qhasm:     rax = a102 + a102
# asm 1: lea  (<a102=int64#4,<a102=int64#4),>rax=int64#5
# asm 2: lea  (<a102=%r9,<a102=%r9),>rax=%rax
lea  (%r9,%r9),%rax

# qhasm:     (int128) rdx rax = rax * a153M19
# asm 1: imul <a153M19=int64#9
# asm 2: imul <a153M19=%r13
imul %r13

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a0
# asm 1: mov  <a0=int64#1,>rax=int64#5
# asm 2: mov  <a0=%rcx,>rax=%rax
mov  %rcx,%rax

# qhasm:     (int128) rdx rax = rax * a0
# asm 1: imul <a0=int64#1
# asm 2: imul <a0=%rcx
imul %rcx

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     r0 = low
# asm 1: mov  <low=int64#10,>r0=int64#12
# asm 2: mov  <low=%r14,>r0=%rdi
mov  %r14,%rdi

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#11,<low=int64#10
# asm 2: shrd $51,<high=%r15,<low=%r14
shrd $51,%r15,%r14

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#11
# asm 2: sar  $51,<high=%r15
sar  $51,%r15

# qhasm:     rax = a102 + a102
# asm 1: lea  (<a102=int64#4,<a102=int64#4),>rax=int64#5
# asm 2: lea  (<a102=%r9,<a102=%r9),>rax=%rax
lea  (%r9,%r9),%rax

# qhasm:     (int128) rdx rax = rax * a204M19
# asm 1: imul <a204M19=int64#8
# asm 2: imul <a204M19=%r12
imul %r12

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a153
# asm 1: mov  <a153=int64#6,>rax=int64#5
# asm 2: mov  <a153=%r10,>rax=%rax
mov  %r10,%rax

# qhasm:     (int128) rdx rax = rax * a153M19
# asm 1: imul <a153M19=int64#9
# asm 2: imul <a153M19=%r13
imul %r13

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a0 + a0
# asm 1: lea  (<a0=int64#1,<a0=int64#1),>rax=int64#5
# asm 2: lea  (<a0=%rcx,<a0=%rcx),>rax=%rax
lea  (%rcx,%rcx),%rax

# qhasm:     (int128) rdx rax = rax * a51
# asm 1: imul <a51=int64#3
# asm 2: imul <a51=%r8
imul %r8

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     r51 = low
# asm 1: mov  <low=int64#10,>r51=int64#9
# asm 2: mov  <low=%r14,>r51=%r13
mov  %r14,%r13

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#11,<low=int64#10
# asm 2: shrd $51,<high=%r15,<low=%r14
shrd $51,%r15,%r14

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#11
# asm 2: sar  $51,<high=%r15
sar  $51,%r15

# qhasm:     rax = a153 + a153
# asm 1: lea  (<a153=int64#6,<a153=int64#6),>rax=int64#5
# asm 2: lea  (<a153=%r10,<a153=%r10),>rax=%rax
lea  (%r10,%r10),%rax

# qhasm:     (int128) rdx rax = rax * a204M19
# asm 1: imul <a204M19=int64#8
# asm 2: imul <a204M19=%r12
imul %r12

# qhasm:     carry? low += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a0 + a0
# asm 1: lea  (<a0=int64#1,<a0=int64#1),>rax=int64#5
# asm 2: lea  (<a0=%rcx,<a0=%rcx),>rax=%rax
lea  (%rcx,%rcx),%rax

# qhasm:     (int128) rdx rax = rax * a102
# asm 1: imul <a102=int64#4
# asm 2: imul <a102=%r9
imul %r9

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a51
# asm 1: mov  <a51=int64#3,>rax=int64#5
# asm 2: mov  <a51=%r8,>rax=%rax
mov  %r8,%rax

# qhasm:     (int128) rdx rax = rax * a51
# asm 1: imul <a51=int64#3
# asm 2: imul <a51=%r8
imul %r8

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     r102 = low
# asm 1: mov  <low=int64#10,>r102=int64#13
# asm 2: mov  <low=%r14,>r102=%rsi
mov  %r14,%rsi

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#11,<low=int64#10
# asm 2: shrd $51,<high=%r15,<low=%r14
shrd $51,%r15,%r14

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#11
# asm 2: sar  $51,<high=%r15
sar  $51,%r15

# qhasm:     rax = a204
# asm 1: mov  <a204=int64#7,>rax=int64#5
# asm 2: mov  <a204=%r11,>rax=%rax
mov  %r11,%rax

# qhasm:     (int128) rdx rax = rax * a204M19
# asm 1: imul <a204M19=int64#8
# asm 2: imul <a204M19=%r12
imul %r12

# qhasm:     carry? low += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a0 + a0
# asm 1: lea  (<a0=int64#1,<a0=int64#1),>rax=int64#5
# asm 2: lea  (<a0=%rcx,<a0=%rcx),>rax=%rax
lea  (%rcx,%rcx),%rax

# qhasm:     (int128) rdx rax = rax * a153
# asm 1: imul <a153=int64#6
# asm 2: imul <a153=%r10
imul %r10

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a51 + a51
# asm 1: lea  (<a51=int64#3,<a51=int64#3),>rax=int64#5
# asm 2: lea  (<a51=%r8,<a51=%r8),>rax=%rax
lea  (%r8,%r8),%rax

# qhasm:     (int128) rdx rax = rax * a102
# asm 1: imul <a102=int64#4
# asm 2: imul <a102=%r9
imul %r9

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     r153 = low
# asm 1: mov  <low=int64#10,>r153=int64#8
# asm 2: mov  <low=%r14,>r153=%r12
mov  %r14,%r12

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#11,<low=int64#10
# asm 2: shrd $51,<high=%r15,<low=%r14
shrd $51,%r15,%r14

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#11
# asm 2: sar  $51,<high=%r15
sar  $51,%r15

# qhasm:     rax = a0 + a0
# asm 1: lea  (<a0=int64#1,<a0=int64#1),>rax=int64#5
# asm 2: lea  (<a0=%rcx,<a0=%rcx),>rax=%rax
lea  (%rcx,%rcx),%rax

# qhasm:     (int128) rdx rax = rax * a204
# asm 1: imul <a204=int64#7
# asm 2: imul <a204=%r11
imul %r11

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a51 + a51
# asm 1: lea  (<a51=int64#3,<a51=int64#3),>rax=int64#5
# asm 2: lea  (<a51=%r8,<a51=%r8),>rax=%rax
lea  (%r8,%r8),%rax

# qhasm:     (int128) rdx rax = rax * a153
# asm 1: imul <a153=int64#6
# asm 2: imul <a153=%r10
imul %r10

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     rax = a102
# asm 1: mov  <a102=int64#4,>rax=int64#5
# asm 2: mov  <a102=%r9,>rax=%rax
mov  %r9,%rax

# qhasm:     (int128) rdx rax = rax * a102
# asm 1: imul <a102=int64#4
# asm 2: imul <a102=%r9
imul %r9

# qhasm:     carry? low  += rax
# asm 1: add  <rax=int64#5,<low=int64#10
# asm 2: add  <rax=%rax,<low=%r14
add  %rax,%r14

# qhasm:     carry? high += rdx + carry
# asm 1: adc <rdx=int64#2,<high=int64#11
# asm 2: adc <rdx=%rdx,<high=%r15
adc %rdx,%r15

# qhasm:     r204 = low
# asm 1: mov  <low=int64#10,>r204=int64#1
# asm 2: mov  <low=%r14,>r204=%rcx
mov  %r14,%rcx

# qhasm:     low = (high low) >> 51
# asm 1: shrd $51,<high=int64#11,<low=int64#10
# asm 2: shrd $51,<high=%r15,<low=%r14
shrd $51,%r15,%r14

# qhasm:     (int64) high >>= 51
# asm 1: sar  $51,<high=int64#11
# asm 2: sar  $51,<high=%r15
sar  $51,%r15

# qhasm:   mask = 0x7ffffffffffff
# asm 1: mov  $0x7ffffffffffff,>mask=int64#3
# asm 2: mov  $0x7ffffffffffff,>mask=%r8
mov  $0x7ffffffffffff,%r8

# qhasm:   r = r_copy
# asm 1: movd   <r_copy=int6464#1,>r=int64#4
# asm 2: movd   <r_copy=%xmm0,>r=%r9
movd   %xmm0,%r9

# qhasm:   r0   &= mask
# asm 1: and  <mask=int64#3,<r0=int64#12
# asm 2: and  <mask=%r8,<r0=%rdi
and  %r8,%rdi

# qhasm:   r51  &= mask
# asm 1: and  <mask=int64#3,<r51=int64#9
# asm 2: and  <mask=%r8,<r51=%r13
and  %r8,%r13

# qhasm:   r102 &= mask
# asm 1: and  <mask=int64#3,<r102=int64#13
# asm 2: and  <mask=%r8,<r102=%rsi
and  %r8,%rsi

# qhasm:   r153 &= mask
# asm 1: and  <mask=int64#3,<r153=int64#8
# asm 2: and  <mask=%r8,<r153=%r12
and  %r8,%r12

# qhasm:   r204 &= mask
# asm 1: and  <mask=int64#3,<r204=int64#1
# asm 2: and  <mask=%r8,<r204=%rcx
and  %r8,%rcx

# qhasm:   high *= 19
# asm 1: imul  $19,<high=int64#11
# asm 2: imul  $19,<high=%r15
imul  $19,%r15

# qhasm:   rax = 19
# asm 1: mov  $19,>rax=int64#5
# asm 2: mov  $19,>rax=%rax
mov  $19,%rax

# qhasm:   (uint128) rdx rax = rax * low
# asm 1: mul  <low=int64#10
# asm 2: mul  <low=%r14
mul  %r14

# qhasm:   rdx += high
# asm 1: add  <high=int64#11,<rdx=int64#2
# asm 2: add  <high=%r15,<rdx=%rdx
add  %r15,%rdx

# qhasm:   mask &= rax
# asm 1: and  <rax=int64#5,<mask=int64#3
# asm 2: and  <rax=%rax,<mask=%r8
and  %rax,%r8

# qhasm:   rax = (rdx rax) >> 51
# asm 1: shrd $51,<rdx=int64#2,<rax=int64#5
# asm 2: shrd $51,<rdx=%rdx,<rax=%rax
shrd $51,%rdx,%rax

# qhasm:   r0  += mask
# asm 1: add  <mask=int64#3,<r0=int64#12
# asm 2: add  <mask=%r8,<r0=%rdi
add  %r8,%rdi

# qhasm:   r51 += rax
# asm 1: add  <rax=int64#5,<r51=int64#9
# asm 2: add  <rax=%rax,<r51=%r13
add  %rax,%r13

# qhasm:   *(uint64 *) (r +  0) = r0
# asm 1: movq   <r0=int64#12,0(<r=int64#4)
# asm 2: movq   <r0=%rdi,0(<r=%r9)
movq   %rdi,0(%r9)

# qhasm:   *(uint64 *) (r +  8) = r51
# asm 1: movq   <r51=int64#9,8(<r=int64#4)
# asm 2: movq   <r51=%r13,8(<r=%r9)
movq   %r13,8(%r9)

# qhasm:   *(uint64 *) (r + 16) = r102
# asm 1: movq   <r102=int64#13,16(<r=int64#4)
# asm 2: movq   <r102=%rsi,16(<r=%r9)
movq   %rsi,16(%r9)

# qhasm:   *(uint64 *) (r + 24) = r153
# asm 1: movq   <r153=int64#8,24(<r=int64#4)
# asm 2: movq   <r153=%r12,24(<r=%r9)
movq   %r12,24(%r9)

# qhasm:   *(uint64 *) (r + 32) = r204
# asm 1: movq   <r204=int64#1,32(<r=int64#4)
# asm 2: movq   <r204=%rcx,32(<r=%r9)
movq   %rcx,32(%r9)

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
