
# qhasm: int64 a0      

# qhasm: int64 a51     

# qhasm: int64 a102    

# qhasm: int64 a153    

# qhasm: int64 a204    

# qhasm: int64 b0      

# qhasm: int64 b51     

# qhasm: int64 b102    

# qhasm: int64 b153    

# qhasm: int64 b204    

# qhasm: int6464 c0    

# qhasm: int6464 c51   

# qhasm: int6464 c102  

# qhasm: int6464 c153  

# qhasm: int6464 c204  

# qhasm: int6464 xmm6

# qhasm: int6464 xmm7

# qhasm: int6464 xmm8

# qhasm: int6464 xmm9

# qhasm: int6464 xmm10

# qhasm: int6464 xmm11

# qhasm: int6464 xmm12

# qhasm: int6464 xmm13

# qhasm: int6464 xmm14

# qhasm: int6464 xmm15

# qhasm: int64 r11

# qhasm: int64 r12

# qhasm: int64 r13

# qhasm: int64 r14

# qhasm: int64 r15

# qhasm: int64 rdi

# qhasm: int64 rsi

# qhasm: int64 rbx

# qhasm: int64 rbp

# qhasm: stack128 xmm6_stack

# qhasm: stack128 xmm7_stack

# qhasm: stack128 xmm8_stack

# qhasm: stack128 xmm9_stack

# qhasm: stack128 xmm10_stack

# qhasm: stack128 xmm11_stack

# qhasm: stack128 xmm12_stack

# qhasm: stack128 xmm13_stack

# qhasm: stack128 xmm14_stack

# qhasm: stack128 xmm15_stack

# qhasm: stack64 r11_stack

# qhasm: stack64 r12_stack

# qhasm: stack64 r13_stack

# qhasm: stack64 r14_stack

# qhasm: stack64 r15_stack

# qhasm: stack64 rdi_stack

# qhasm: stack64 rsi_stack

# qhasm: stack64 rbx_stack

# qhasm: stack64 rbp_stack

# qhasm: caller xmm6

# qhasm: caller xmm7

# qhasm: caller xmm8

# qhasm: caller xmm9

# qhasm: caller xmm10

# qhasm: caller xmm11

# qhasm: caller xmm12

# qhasm: caller xmm13

# qhasm: caller xmm14

# qhasm: caller xmm15

# qhasm: caller r11

# qhasm: caller r12

# qhasm: caller r13

# qhasm: caller r14

# qhasm: caller r15

# qhasm: caller rdi

# qhasm: caller rsi

# qhasm: caller rbx

# qhasm: caller rbp

# qhasm: int64 r

# qhasm: int64 a

# qhasm: stack64 r_stack

# qhasm: stack64 a_stack

# qhasm: input r

# qhasm: input a

# qhasm: enter field25519_wes_powq
.text
.p2align 5
.globl _field25519_wes_powq
.globl field25519_wes_powq
_field25519_wes_powq:
field25519_wes_powq:
mov %rsp,%r11
and $31,%r11
add $256,%r11
sub %r11,%rsp

# qhasm:   xmm6_stack = xmm6
# asm 1: movdqa <xmm6=int6464#7,>xmm6_stack=stack128#1
# asm 2: movdqa <xmm6=%xmm6,>xmm6_stack=0(%rsp)
movdqa %xmm6,0(%rsp)

# qhasm:   xmm7_stack = xmm7
# asm 1: movdqa <xmm7=int6464#8,>xmm7_stack=stack128#2
# asm 2: movdqa <xmm7=%xmm7,>xmm7_stack=16(%rsp)
movdqa %xmm7,16(%rsp)

# qhasm:   xmm8_stack = xmm8
# asm 1: movdqa <xmm8=int6464#9,>xmm8_stack=stack128#3
# asm 2: movdqa <xmm8=%xmm8,>xmm8_stack=32(%rsp)
movdqa %xmm8,32(%rsp)

# qhasm:   xmm9_stack = xmm9
# asm 1: movdqa <xmm9=int6464#10,>xmm9_stack=stack128#4
# asm 2: movdqa <xmm9=%xmm9,>xmm9_stack=48(%rsp)
movdqa %xmm9,48(%rsp)

# qhasm:   xmm10_stack = xmm10
# asm 1: movdqa <xmm10=int6464#11,>xmm10_stack=stack128#5
# asm 2: movdqa <xmm10=%xmm10,>xmm10_stack=64(%rsp)
movdqa %xmm10,64(%rsp)

# qhasm:   xmm11_stack = xmm11
# asm 1: movdqa <xmm11=int6464#12,>xmm11_stack=stack128#6
# asm 2: movdqa <xmm11=%xmm11,>xmm11_stack=80(%rsp)
movdqa %xmm11,80(%rsp)

# qhasm:   xmm12_stack = xmm12
# asm 1: movdqa <xmm12=int6464#13,>xmm12_stack=stack128#7
# asm 2: movdqa <xmm12=%xmm12,>xmm12_stack=96(%rsp)
movdqa %xmm12,96(%rsp)

# qhasm:   xmm13_stack = xmm13
# asm 1: movdqa <xmm13=int6464#14,>xmm13_stack=stack128#8
# asm 2: movdqa <xmm13=%xmm13,>xmm13_stack=112(%rsp)
movdqa %xmm13,112(%rsp)

# qhasm:   xmm14_stack = xmm14
# asm 1: movdqa <xmm14=int6464#15,>xmm14_stack=stack128#9
# asm 2: movdqa <xmm14=%xmm14,>xmm14_stack=128(%rsp)
movdqa %xmm14,128(%rsp)

# qhasm:   xmm15_stack = xmm15
# asm 1: movdqa <xmm15=int6464#16,>xmm15_stack=stack128#10
# asm 2: movdqa <xmm15=%xmm15,>xmm15_stack=144(%rsp)
movdqa %xmm15,144(%rsp)

# qhasm:   r11_stack = r11
# asm 1: movq <r11=int64#7,>r11_stack=stack64#1
# asm 2: movq <r11=%r11,>r11_stack=160(%rsp)
movq %r11,160(%rsp)

# qhasm:   r12_stack = r12
# asm 1: movq <r12=int64#8,>r12_stack=stack64#2
# asm 2: movq <r12=%r12,>r12_stack=168(%rsp)
movq %r12,168(%rsp)

# qhasm:   r13_stack = r13
# asm 1: movq <r13=int64#9,>r13_stack=stack64#3
# asm 2: movq <r13=%r13,>r13_stack=176(%rsp)
movq %r13,176(%rsp)

# qhasm:   r14_stack = r14
# asm 1: movq <r14=int64#10,>r14_stack=stack64#4
# asm 2: movq <r14=%r14,>r14_stack=184(%rsp)
movq %r14,184(%rsp)

# qhasm:   r15_stack = r15
# asm 1: movq <r15=int64#11,>r15_stack=stack64#5
# asm 2: movq <r15=%r15,>r15_stack=192(%rsp)
movq %r15,192(%rsp)

# qhasm:  rdi_stack = rdi
# asm 1: movq <rdi=int64#12,>rdi_stack=stack64#6
# asm 2: movq <rdi=%rdi,>rdi_stack=200(%rsp)
movq %rdi,200(%rsp)

# qhasm:  rsi_stack = rsi
# asm 1: movq <rsi=int64#13,>rsi_stack=stack64#7
# asm 2: movq <rsi=%rsi,>rsi_stack=208(%rsp)
movq %rsi,208(%rsp)

# qhasm:   rbx_stack = rbx
# asm 1: movq <rbx=int64#14,>rbx_stack=stack64#8
# asm 2: movq <rbx=%rbp,>rbx_stack=216(%rsp)
movq %rbp,216(%rsp)

# qhasm:   rbp_stack = rbp
# asm 1: movq <rbp=int64#15,>rbp_stack=stack64#9
# asm 2: movq <rbp=%rbx,>rbp_stack=224(%rsp)
movq %rbx,224(%rsp)

# qhasm:   r_stack = r
# asm 1: movq <r=int64#1,>r_stack=stack64#10
# asm 2: movq <r=%rcx,>r_stack=232(%rsp)
movq %rcx,232(%rsp)

# qhasm:   a_stack = a
# asm 1: movq <a=int64#2,>a_stack=stack64#11
# asm 2: movq <a=%rdx,>a_stack=240(%rsp)
movq %rdx,240(%rsp)

# qhasm:   b0   = *(uint64 *)(a +  0)
# asm 1: movq   0(<a=int64#2),>b0=int64#11
# asm 2: movq   0(<a=%rdx),>b0=%r15
movq   0(%rdx),%r15

# qhasm:   b51  = *(uint64 *)(a +  8)
# asm 1: movq   8(<a=int64#2),>b51=int64#12
# asm 2: movq   8(<a=%rdx),>b51=%rdi
movq   8(%rdx),%rdi

# qhasm:   b102 = *(uint64 *)(a + 16)
# asm 1: movq   16(<a=int64#2),>b102=int64#13
# asm 2: movq   16(<a=%rdx),>b102=%rsi
movq   16(%rdx),%rsi

# qhasm:   b153 = *(uint64 *)(a + 24)
# asm 1: movq   24(<a=int64#2),>b153=int64#14
# asm 2: movq   24(<a=%rdx),>b153=%rbp
movq   24(%rdx),%rbp

# qhasm:   b204 = *(uint64 *)(a + 32)
# asm 1: movq   32(<a=int64#2),>b204=int64#15
# asm 2: movq   32(<a=%rdx),>b204=%rbx
movq   32(%rdx),%rbx

# qhasm:   assign 11 to b0

# qhasm:   assign 12 to b51

# qhasm:   assign 13 to b102

# qhasm:   assign 14 to b153

# qhasm:   assign 15 to b204

# qhasm:   call powtrick local
call powtrick

# qhasm:   call sqrBtoA local
call sqrBtoA

# qhasm:   call sqrAtoB local
call sqrAtoB

# qhasm:   a = a_stack
# asm 1: movq <a_stack=stack64#11,>a=int64#2
# asm 2: movq <a_stack=240(%rsp),>a=%rdx
movq 240(%rsp),%rdx

# qhasm:   a0   = *(uint64 *)(a +  0)
# asm 1: movq   0(<a=int64#2),>a0=int64#6
# asm 2: movq   0(<a=%rdx),>a0=%r10
movq   0(%rdx),%r10

# qhasm:   a51  = *(uint64 *)(a +  8)
# asm 1: movq   8(<a=int64#2),>a51=int64#1
# asm 2: movq   8(<a=%rdx),>a51=%rcx
movq   8(%rdx),%rcx

# qhasm:   a102 = *(uint64 *)(a + 16)
# asm 1: movq   16(<a=int64#2),>a102=int64#8
# asm 2: movq   16(<a=%rdx),>a102=%r12
movq   16(%rdx),%r12

# qhasm:   a153 = *(uint64 *)(a + 24)
# asm 1: movq   24(<a=int64#2),>a153=int64#9
# asm 2: movq   24(<a=%rdx),>a153=%r13
movq   24(%rdx),%r13

# qhasm:   a204 = *(uint64 *)(a + 32)
# asm 1: movq   32(<a=int64#2),>a204=int64#10
# asm 2: movq   32(<a=%rdx),>a204=%r14
movq   32(%rdx),%r14

# qhasm:   assign 6  to a0

# qhasm:   assign 1  to a51

# qhasm:   assign 8  to a102

# qhasm:   assign 9  to a153

# qhasm:   assign 10 to a204

# qhasm:   c0   = b0
# asm 1: movd   <b0=int64#11,>c0=int6464#1
# asm 2: movd   <b0=%r15,>c0=%xmm0
movd   %r15,%xmm0

# qhasm:   c51  = b51
# asm 1: movd   <b51=int64#12,>c51=int6464#2
# asm 2: movd   <b51=%rdi,>c51=%xmm1
movd   %rdi,%xmm1

# qhasm:   c102 = b102
# asm 1: movd   <b102=int64#13,>c102=int6464#3
# asm 2: movd   <b102=%rsi,>c102=%xmm2
movd   %rsi,%xmm2

# qhasm:   c153 = b153
# asm 1: movd   <b153=int64#14,>c153=int6464#4
# asm 2: movd   <b153=%rbp,>c153=%xmm3
movd   %rbp,%xmm3

# qhasm:   c204 = b204
# asm 1: movd   <b204=int64#15,>c204=int6464#5
# asm 2: movd   <b204=%rbx,>c204=%xmm4
movd   %rbx,%xmm4

# qhasm:   assign 1 to c0

# qhasm:   assign 2 to c51

# qhasm:   assign 3 to c102

# qhasm:   assign 4 to c153

# qhasm:   assign 5 to c204

# qhasm:   call mulACtoB local
call mulACtoB

# qhasm:   r = r_stack
# asm 1: movq <r_stack=stack64#10,>r=int64#1
# asm 2: movq <r_stack=232(%rsp),>r=%rcx
movq 232(%rsp),%rcx

# qhasm:   *(uint64 *)(r +  0) = b0
# asm 1: movq   <b0=int64#11,0(<r=int64#1)
# asm 2: movq   <b0=%r15,0(<r=%rcx)
movq   %r15,0(%rcx)

# qhasm:   *(uint64 *)(r +  8) = b51
# asm 1: movq   <b51=int64#12,8(<r=int64#1)
# asm 2: movq   <b51=%rdi,8(<r=%rcx)
movq   %rdi,8(%rcx)

# qhasm:   *(uint64 *)(r + 16) = b102
# asm 1: movq   <b102=int64#13,16(<r=int64#1)
# asm 2: movq   <b102=%rsi,16(<r=%rcx)
movq   %rsi,16(%rcx)

# qhasm:   *(uint64 *)(r + 24) = b153
# asm 1: movq   <b153=int64#14,24(<r=int64#1)
# asm 2: movq   <b153=%rbp,24(<r=%rcx)
movq   %rbp,24(%rcx)

# qhasm:   *(uint64 *)(r + 32) = b204
# asm 1: movq   <b204=int64#15,32(<r=int64#1)
# asm 2: movq   <b204=%rbx,32(<r=%rcx)
movq   %rbx,32(%rcx)

# qhasm:   xmm6 = xmm6_stack
# asm 1: movdqa <xmm6_stack=stack128#1,>xmm6=int6464#7
# asm 2: movdqa <xmm6_stack=0(%rsp),>xmm6=%xmm6
movdqa 0(%rsp),%xmm6

# qhasm:   xmm7 = xmm7_stack
# asm 1: movdqa <xmm7_stack=stack128#2,>xmm7=int6464#8
# asm 2: movdqa <xmm7_stack=16(%rsp),>xmm7=%xmm7
movdqa 16(%rsp),%xmm7

# qhasm:   xmm8 = xmm8_stack
# asm 1: movdqa <xmm8_stack=stack128#3,>xmm8=int6464#9
# asm 2: movdqa <xmm8_stack=32(%rsp),>xmm8=%xmm8
movdqa 32(%rsp),%xmm8

# qhasm:   xmm9 = xmm9_stack
# asm 1: movdqa <xmm9_stack=stack128#4,>xmm9=int6464#10
# asm 2: movdqa <xmm9_stack=48(%rsp),>xmm9=%xmm9
movdqa 48(%rsp),%xmm9

# qhasm:   xmm10 = xmm10_stack
# asm 1: movdqa <xmm10_stack=stack128#5,>xmm10=int6464#11
# asm 2: movdqa <xmm10_stack=64(%rsp),>xmm10=%xmm10
movdqa 64(%rsp),%xmm10

# qhasm:   xmm11 = xmm11_stack
# asm 1: movdqa <xmm11_stack=stack128#6,>xmm11=int6464#12
# asm 2: movdqa <xmm11_stack=80(%rsp),>xmm11=%xmm11
movdqa 80(%rsp),%xmm11

# qhasm:   xmm12 = xmm12_stack
# asm 1: movdqa <xmm12_stack=stack128#7,>xmm12=int6464#13
# asm 2: movdqa <xmm12_stack=96(%rsp),>xmm12=%xmm12
movdqa 96(%rsp),%xmm12

# qhasm:   xmm13 = xmm13_stack
# asm 1: movdqa <xmm13_stack=stack128#8,>xmm13=int6464#14
# asm 2: movdqa <xmm13_stack=112(%rsp),>xmm13=%xmm13
movdqa 112(%rsp),%xmm13

# qhasm:   xmm14 = xmm14_stack
# asm 1: movdqa <xmm14_stack=stack128#9,>xmm14=int6464#15
# asm 2: movdqa <xmm14_stack=128(%rsp),>xmm14=%xmm14
movdqa 128(%rsp),%xmm14

# qhasm:   xmm15 = xmm15_stack
# asm 1: movdqa <xmm15_stack=stack128#10,>xmm15=int6464#16
# asm 2: movdqa <xmm15_stack=144(%rsp),>xmm15=%xmm15
movdqa 144(%rsp),%xmm15

# qhasm:   r11 = r11_stack
# asm 1: movq <r11_stack=stack64#1,>r11=int64#7
# asm 2: movq <r11_stack=160(%rsp),>r11=%r11
movq 160(%rsp),%r11

# qhasm:   r12 = r12_stack
# asm 1: movq <r12_stack=stack64#2,>r12=int64#8
# asm 2: movq <r12_stack=168(%rsp),>r12=%r12
movq 168(%rsp),%r12

# qhasm:   r13 = r13_stack
# asm 1: movq <r13_stack=stack64#3,>r13=int64#9
# asm 2: movq <r13_stack=176(%rsp),>r13=%r13
movq 176(%rsp),%r13

# qhasm:   r14 = r14_stack
# asm 1: movq <r14_stack=stack64#4,>r14=int64#10
# asm 2: movq <r14_stack=184(%rsp),>r14=%r14
movq 184(%rsp),%r14

# qhasm:   r15 = r15_stack
# asm 1: movq <r15_stack=stack64#5,>r15=int64#11
# asm 2: movq <r15_stack=192(%rsp),>r15=%r15
movq 192(%rsp),%r15

# qhasm:  rdi = rdi_stack
# asm 1: movq <rdi_stack=stack64#6,>rdi=int64#12
# asm 2: movq <rdi_stack=200(%rsp),>rdi=%rdi
movq 200(%rsp),%rdi

# qhasm:  rsi = rsi_stack
# asm 1: movq <rsi_stack=stack64#7,>rsi=int64#13
# asm 2: movq <rsi_stack=208(%rsp),>rsi=%rsi
movq 208(%rsp),%rsi

# qhasm:   rbx = rbx_stack
# asm 1: movq <rbx_stack=stack64#8,>rbx=int64#14
# asm 2: movq <rbx_stack=216(%rsp),>rbx=%rbp
movq 216(%rsp),%rbp

# qhasm:   rbp = rbp_stack
# asm 1: movq <rbp_stack=stack64#9,>rbp=int64#15
# asm 2: movq <rbp_stack=224(%rsp),>rbp=%rbx
movq 224(%rsp),%rbx

# qhasm: leave
add %r11,%rsp
ret
