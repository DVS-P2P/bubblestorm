
# qhasm: int64 r11_caller

# qhasm: int64 r12_caller

# qhasm: int64 r13_caller

# qhasm: int64 r14_caller

# qhasm: int64 r15_caller

# qhasm: int64 rdi_caller

# qhasm: int64 rsi_caller

# qhasm: int64 rbp_caller

# qhasm: int64 rbx_caller

# qhasm: caller r11_caller

# qhasm: caller r12_caller

# qhasm: caller r13_caller

# qhasm: caller r14_caller

# qhasm: caller r15_caller

# qhasm: caller rdi_caller

# qhasm: caller rsi_caller

# qhasm: caller rbp_caller

# qhasm: caller rbx_caller

# qhasm: stack64 r11_stack

# qhasm: stack64 r12_stack

# qhasm: stack64 r13_stack

# qhasm: stack64 r14_stack

# qhasm: stack64 r15_stack

# qhasm: stack64 rdi_stack

# qhasm: stack64 rsi_stack

# qhasm: stack64 rbp_stack

# qhasm: stack64 rbx_stack

# qhasm: int64 table

# qhasm: int64 c

# qhasm: int64 k

# qhasm: int64 iv

# qhasm: int64 x0

# qhasm: int64 x1

# qhasm: int64 x2

# qhasm: int64 x3

# qhasm: int64 e

# qhasm: int64 in

# qhasm: int64 out

# qhasm: stack64 out_stack

# qhasm: stack64 n0

# qhasm: stack64 n1

# qhasm: stack64 n2

# qhasm: stack64 n3

# qhasm: int64 y0

# qhasm: int64 y1

# qhasm: int64 y2

# qhasm: int64 y3

# qhasm: int64 z0

# qhasm: int64 z1

# qhasm: int64 z2

# qhasm: int64 z3

# qhasm: int64 p00

# qhasm: int64 p01

# qhasm: int64 p02

# qhasm: int64 p03

# qhasm: int64 p10

# qhasm: int64 p11

# qhasm: int64 p12

# qhasm: int64 p13

# qhasm: int64 p20

# qhasm: int64 p21

# qhasm: int64 p22

# qhasm: int64 p23

# qhasm: int64 p30

# qhasm: int64 p31

# qhasm: int64 p32

# qhasm: int64 p33

# qhasm: int64 q00

# qhasm: int64 q01

# qhasm: int64 q02

# qhasm: int64 q03

# qhasm: int64 q10

# qhasm: int64 q11

# qhasm: int64 q12

# qhasm: int64 q13

# qhasm: int64 q20

# qhasm: int64 q21

# qhasm: int64 q22

# qhasm: int64 q23

# qhasm: int64 q30

# qhasm: int64 q31

# qhasm: int64 q32

# qhasm: int64 q33

# qhasm: enter aes128_amd64_2_block stackaligned4096 aes128_amd64_2_constants
.text
.p2align 5
.globl _aes128_amd64_2_block
.globl aes128_amd64_2_block
_aes128_amd64_2_block:
aes128_amd64_2_block:
mov %rsp,%r11
lea aes128_amd64_2_constants(%rip),%r10
sub %r10,%r11
and $4095,%r11
add $96,%r11
sub %r11,%rsp

# qhasm: input out

# qhasm: input in

# qhasm: input c

# qhasm: out_stack = out
# asm 1: movq <out=int64#1,>out_stack=stack64#1
# asm 2: movq <out=%rcx,>out_stack=0(%rsp)
movq %rcx,0(%rsp)

# qhasm: r11_stack = r11_caller
# asm 1: movq <r11_caller=int64#7,>r11_stack=stack64#2
# asm 2: movq <r11_caller=%r11,>r11_stack=8(%rsp)
movq %r11,8(%rsp)

# qhasm: r12_stack = r12_caller
# asm 1: movq <r12_caller=int64#8,>r12_stack=stack64#3
# asm 2: movq <r12_caller=%r12,>r12_stack=16(%rsp)
movq %r12,16(%rsp)

# qhasm: r13_stack = r13_caller
# asm 1: movq <r13_caller=int64#9,>r13_stack=stack64#4
# asm 2: movq <r13_caller=%r13,>r13_stack=24(%rsp)
movq %r13,24(%rsp)

# qhasm: r14_stack = r14_caller
# asm 1: movq <r14_caller=int64#10,>r14_stack=stack64#5
# asm 2: movq <r14_caller=%r14,>r14_stack=32(%rsp)
movq %r14,32(%rsp)

# qhasm: r15_stack = r15_caller
# asm 1: movq <r15_caller=int64#11,>r15_stack=stack64#6
# asm 2: movq <r15_caller=%r15,>r15_stack=40(%rsp)
movq %r15,40(%rsp)

# qhasm: rdi_stack = rdi_caller
# asm 1: movq <rdi_caller=int64#12,>rdi_stack=stack64#7
# asm 2: movq <rdi_caller=%rdi,>rdi_stack=48(%rsp)
movq %rdi,48(%rsp)

# qhasm: rsi_stack = rsi_caller
# asm 1: movq <rsi_caller=int64#13,>rsi_stack=stack64#8
# asm 2: movq <rsi_caller=%rsi,>rsi_stack=56(%rsp)
movq %rsi,56(%rsp)

# qhasm: rbp_stack = rbp_caller
# asm 1: movq <rbp_caller=int64#14,>rbp_stack=stack64#9
# asm 2: movq <rbp_caller=%rbp,>rbp_stack=64(%rsp)
movq %rbp,64(%rsp)

# qhasm: rbx_stack = rbx_caller
# asm 1: movq <rbx_caller=int64#15,>rbx_stack=stack64#10
# asm 2: movq <rbx_caller=%rbx,>rbx_stack=72(%rsp)
movq %rbx,72(%rsp)

# qhasm: x0 = *(uint32 *) (c + 0)
# asm 1: movl   0(<c=int64#3),>x0=int64#4d
# asm 2: movl   0(<c=%r8),>x0=%r9d
movl   0(%r8),%r9d

# qhasm: x1 = *(uint32 *) (c + 4)
# asm 1: movl   4(<c=int64#3),>x1=int64#6d
# asm 2: movl   4(<c=%r8),>x1=%r10d
movl   4(%r8),%r10d

# qhasm: x2 = *(uint32 *) (c + 8)
# asm 1: movl   8(<c=int64#3),>x2=int64#7d
# asm 2: movl   8(<c=%r8),>x2=%r11d
movl   8(%r8),%r11d

# qhasm: x3 = *(uint32 *) (c + 12)
# asm 1: movl   12(<c=int64#3),>x3=int64#8d
# asm 2: movl   12(<c=%r8),>x3=%r12d
movl   12(%r8),%r12d

# qhasm: y0 = *(uint32 *) (in + 0)
# asm 1: movl   0(<in=int64#2),>y0=int64#1d
# asm 2: movl   0(<in=%rdx),>y0=%ecx
movl   0(%rdx),%ecx

# qhasm: y1 = *(uint32 *) (in + 4)
# asm 1: movl   4(<in=int64#2),>y1=int64#15d
# asm 2: movl   4(<in=%rdx),>y1=%ebx
movl   4(%rdx),%ebx

# qhasm: y2 = *(uint32 *) (in + 8)
# asm 1: movl   8(<in=int64#2),>y2=int64#5d
# asm 2: movl   8(<in=%rdx),>y2=%eax
movl   8(%rdx),%eax

# qhasm: y3 = *(uint32 *) (in + 12)
# asm 1: movl   12(<in=int64#2),>y3=int64#2d
# asm 2: movl   12(<in=%rdx),>y3=%edx
movl   12(%rdx),%edx

# qhasm: table = &aes128_amd64_2_tablex
# asm 1: lea  aes128_amd64_2_tablex(%rip),>table=int64#9
# asm 2: lea  aes128_amd64_2_tablex(%rip),>table=%r13
lea  aes128_amd64_2_tablex(%rip),%r13

# qhasm: y0 ^= x0
# asm 1: xor  <x0=int64#4,<y0=int64#1
# asm 2: xor  <x0=%r9,<y0=%rcx
xor  %r9,%rcx

# qhasm: y1 ^= x1
# asm 1: xor  <x1=int64#6,<y1=int64#15
# asm 2: xor  <x1=%r10,<y1=%rbx
xor  %r10,%rbx

# qhasm: y2 ^= x2
# asm 1: xor  <x2=int64#7,<y2=int64#5
# asm 2: xor  <x2=%r11,<y2=%rax
xor  %r11,%rax

# qhasm: y3 ^= x3
# asm 1: xor  <x3=int64#8,<y3=int64#2
# asm 2: xor  <x3=%r12,<y3=%rdx
xor  %r12,%rdx

# qhasm: x0 = *(uint32 *) (c + 16)
# asm 1: movl   16(<c=int64#3),>x0=int64#4d
# asm 2: movl   16(<c=%r8),>x0=%r9d
movl   16(%r8),%r9d

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#4,<x1=int64#6
# asm 2: xor  <x0=%r9,<x1=%r10
xor  %r9,%r10

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#6,<x2=int64#7
# asm 2: xor  <x1=%r10,<x2=%r11
xor  %r10,%r11

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#7,<x3=int64#8
# asm 2: xor  <x2=%r11,<x3=%r12
xor  %r11,%r12

# qhasm: p00 = y0 & 255
# asm 1: movzbl  <y0=int64#1b,>p00=int64#10d
# asm 2: movzbl  <y0=%cl,>p00=%r14d
movzbl  %cl,%r14d

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#1%next8,>p01=int64#12d
# asm 2: movzbl  <y0=%ch,>p01=%edi
movzbl  %ch,%edi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int64#1d
# asm 2: shr  $16,<y0=%ecx
shr  $16,%ecx

# qhasm: p02 = y0 & 255
# asm 1: movzbl  <y0=int64#1b,>p02=int64#11d
# asm 2: movzbl  <y0=%cl,>p02=%r15d
movzbl  %cl,%r15d

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#1%next8,>p03=int64#13d
# asm 2: movzbl  <y0=%ch,>p03=%esi
movzbl  %ch,%esi

# qhasm: z0 = *(uint32 *) (table + 3 + p00 * 8)
# asm 1: movl   3(<table=int64#9,<p00=int64#10,8),>z0=int64#1d
# asm 2: movl   3(<table=%r13,<p00=%r14,8),>z0=%ecx
movl   3(%r13,%r14,8),%ecx

# qhasm: z0 ^= x0
# asm 1: xor  <x0=int64#4,<z0=int64#1
# asm 2: xor  <x0=%r9,<z0=%rcx
xor  %r9,%rcx

# qhasm: p10 = y1 & 255
# asm 1: movzbl  <y1=int64#15b,>p10=int64#4d
# asm 2: movzbl  <y1=%bl,>p10=%r9d
movzbl  %bl,%r9d

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#15%next8,>p11=int64#14d
# asm 2: movzbl  <y1=%bh,>p11=%ebp
movzbl  %bh,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
# asm 1: xorl 2(<table=int64#9,<p11=int64#14,8),<z0=int64#1d
# asm 2: xorl 2(<table=%r13,<p11=%rbp,8),<z0=%ecx
xorl 2(%r13,%rbp,8),%ecx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int64#15d
# asm 2: shr  $16,<y1=%ebx
shr  $16,%ebx

# qhasm: p12 = y1 & 255
# asm 1: movzbl  <y1=int64#15b,>p12=int64#10d
# asm 2: movzbl  <y1=%bl,>p12=%r14d
movzbl  %bl,%r14d

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#15%next8,>p13=int64#14d
# asm 2: movzbl  <y1=%bh,>p13=%ebp
movzbl  %bh,%ebp

# qhasm: z1 = *(uint32 *) (table + 4 + p03 * 8)
# asm 1: movl   4(<table=int64#9,<p03=int64#13,8),>z1=int64#15d
# asm 2: movl   4(<table=%r13,<p03=%rsi,8),>z1=%ebx
movl   4(%r13,%rsi,8),%ebx

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
# asm 1: xorl 3(<table=int64#9,<p10=int64#4,8),<z1=int64#15d
# asm 2: xorl 3(<table=%r13,<p10=%r9,8),<z1=%ebx
xorl 3(%r13,%r9,8),%ebx

# qhasm: p20 = y2 & 255
# asm 1: movzbl  <y2=int64#5b,>p20=int64#4d
# asm 2: movzbl  <y2=%al,>p20=%r9d
movzbl  %al,%r9d

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#5%next8,>p21=int64#13d
# asm 2: movzbl  <y2=%ah,>p21=%esi
movzbl  %ah,%esi

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
# asm 1: xorl 2(<table=int64#9,<p21=int64#13,8),<z1=int64#15d
# asm 2: xorl 2(<table=%r13,<p21=%rsi,8),<z1=%ebx
xorl 2(%r13,%rsi,8),%ebx

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int64#5d
# asm 2: shr  $16,<y2=%eax
shr  $16,%eax

# qhasm: p22 = y2 & 255
# asm 1: movzbl  <y2=int64#5b,>p22=int64#13d
# asm 2: movzbl  <y2=%al,>p22=%esi
movzbl  %al,%esi

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
# asm 1: xorl 1(<table=int64#9,<p22=int64#13,8),<z0=int64#1d
# asm 2: xorl 1(<table=%r13,<p22=%rsi,8),<z0=%ecx
xorl 1(%r13,%rsi,8),%ecx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#5%next8,>p23=int64#13d
# asm 2: movzbl  <y2=%ah,>p23=%esi
movzbl  %ah,%esi

# qhasm: z2 = *(uint32 *) (table + 1 + p02 * 8)
# asm 1: movl   1(<table=int64#9,<p02=int64#11,8),>z2=int64#5d
# asm 2: movl   1(<table=%r13,<p02=%r15,8),>z2=%eax
movl   1(%r13,%r15,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
# asm 1: xorl 4(<table=int64#9,<p13=int64#14,8),<z2=int64#5d
# asm 2: xorl 4(<table=%r13,<p13=%rbp,8),<z2=%eax
xorl 4(%r13,%rbp,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
# asm 1: xorl 3(<table=int64#9,<p20=int64#4,8),<z2=int64#5d
# asm 2: xorl 3(<table=%r13,<p20=%r9,8),<z2=%eax
xorl 3(%r13,%r9,8),%eax

# qhasm: p30 = y3 & 255
# asm 1: movzbl  <y3=int64#2b,>p30=int64#4d
# asm 2: movzbl  <y3=%dl,>p30=%r9d
movzbl  %dl,%r9d

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#2%next8,>p31=int64#14d
# asm 2: movzbl  <y3=%dh,>p31=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
# asm 1: xorl 2(<table=int64#9,<p31=int64#14,8),<z2=int64#5d
# asm 2: xorl 2(<table=%r13,<p31=%rbp,8),<z2=%eax
xorl 2(%r13,%rbp,8),%eax

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int64#2d
# asm 2: shr  $16,<y3=%edx
shr  $16,%edx

# qhasm: p32 = y3 & 255
# asm 1: movzbl  <y3=int64#2b,>p32=int64#11d
# asm 2: movzbl  <y3=%dl,>p32=%r15d
movzbl  %dl,%r15d

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
# asm 1: xorl 1(<table=int64#9,<p32=int64#11,8),<z1=int64#15d
# asm 2: xorl 1(<table=%r13,<p32=%r15,8),<z1=%ebx
xorl 1(%r13,%r15,8),%ebx

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#2%next8,>p33=int64#14d
# asm 2: movzbl  <y3=%dh,>p33=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
# asm 1: xorl 4(<table=int64#9,<p33=int64#14,8),<z0=int64#1d
# asm 2: xorl 4(<table=%r13,<p33=%rbp,8),<z0=%ecx
xorl 4(%r13,%rbp,8),%ecx

# qhasm: z3 = *(uint32 *) (table + 2 + p01 * 8)
# asm 1: movl   2(<table=int64#9,<p01=int64#12,8),>z3=int64#2d
# asm 2: movl   2(<table=%r13,<p01=%rdi,8),>z3=%edx
movl   2(%r13,%rdi,8),%edx

# qhasm: z2 ^= x2
# asm 1: xor  <x2=int64#7,<z2=int64#5
# asm 2: xor  <x2=%r11,<z2=%rax
xor  %r11,%rax

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
# asm 1: xorl 1(<table=int64#9,<p12=int64#10,8),<z3=int64#2d
# asm 2: xorl 1(<table=%r13,<p12=%r14,8),<z3=%edx
xorl 1(%r13,%r14,8),%edx

# qhasm: z1 ^= x1
# asm 1: xor  <x1=int64#6,<z1=int64#15
# asm 2: xor  <x1=%r10,<z1=%rbx
xor  %r10,%rbx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
# asm 1: xorl 4(<table=int64#9,<p23=int64#13,8),<z3=int64#2d
# asm 2: xorl 4(<table=%r13,<p23=%rsi,8),<z3=%edx
xorl 4(%r13,%rsi,8),%edx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
# asm 1: xorl 3(<table=int64#9,<p30=int64#4,8),<z3=int64#2d
# asm 2: xorl 3(<table=%r13,<p30=%r9,8),<z3=%edx
xorl 3(%r13,%r9,8),%edx

# qhasm: z3 ^= x3
# asm 1: xor  <x3=int64#8,<z3=int64#2
# asm 2: xor  <x3=%r12,<z3=%rdx
xor  %r12,%rdx

# qhasm: x0 = *(uint32 *) (c + 20)
# asm 1: movl   20(<c=int64#3),>x0=int64#4d
# asm 2: movl   20(<c=%r8),>x0=%r9d
movl   20(%r8),%r9d

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#4,<x1=int64#6
# asm 2: xor  <x0=%r9,<x1=%r10
xor  %r9,%r10

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#6,<x2=int64#7
# asm 2: xor  <x1=%r10,<x2=%r11
xor  %r10,%r11

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#7,<x3=int64#8
# asm 2: xor  <x2=%r11,<x3=%r12
xor  %r11,%r12

# qhasm: q00 = z0 & 255
# asm 1: movzbl  <z0=int64#1b,>q00=int64#10d
# asm 2: movzbl  <z0=%cl,>q00=%r14d
movzbl  %cl,%r14d

# qhasm: q03 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#1%next8,>q03=int64#12d
# asm 2: movzbl  <z0=%ch,>q03=%edi
movzbl  %ch,%edi

# qhasm: (uint32) z0 >>= 16
# asm 1: shr  $16,<z0=int64#1d
# asm 2: shr  $16,<z0=%ecx
shr  $16,%ecx

# qhasm: q02 = z0 & 255
# asm 1: movzbl  <z0=int64#1b,>q02=int64#11d
# asm 2: movzbl  <z0=%cl,>q02=%r15d
movzbl  %cl,%r15d

# qhasm: q01 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#1%next8,>q01=int64#13d
# asm 2: movzbl  <z0=%ch,>q01=%esi
movzbl  %ch,%esi

# qhasm: y0 = *(uint32 *) (table + 3 + q00 * 8)
# asm 1: movl   3(<table=int64#9,<q00=int64#10,8),>y0=int64#1d
# asm 2: movl   3(<table=%r13,<q00=%r14,8),>y0=%ecx
movl   3(%r13,%r14,8),%ecx

# qhasm: y0 ^= x0
# asm 1: xor  <x0=int64#4,<y0=int64#1
# asm 2: xor  <x0=%r9,<y0=%rcx
xor  %r9,%rcx

# qhasm: q10 = z1 & 255
# asm 1: movzbl  <z1=int64#15b,>q10=int64#4d
# asm 2: movzbl  <z1=%bl,>q10=%r9d
movzbl  %bl,%r9d

# qhasm: q11 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#15%next8,>q11=int64#14d
# asm 2: movzbl  <z1=%bh,>q11=%ebp
movzbl  %bh,%ebp

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 2 + q11 * 8)
# asm 1: xorl 2(<table=int64#9,<q11=int64#14,8),<y0=int64#1d
# asm 2: xorl 2(<table=%r13,<q11=%rbp,8),<y0=%ecx
xorl 2(%r13,%rbp,8),%ecx

# qhasm: (uint32) z1 >>= 16
# asm 1: shr  $16,<z1=int64#15d
# asm 2: shr  $16,<z1=%ebx
shr  $16,%ebx

# qhasm: q12 = z1 & 255
# asm 1: movzbl  <z1=int64#15b,>q12=int64#10d
# asm 2: movzbl  <z1=%bl,>q12=%r14d
movzbl  %bl,%r14d

# qhasm: q13 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#15%next8,>q13=int64#14d
# asm 2: movzbl  <z1=%bh,>q13=%ebp
movzbl  %bh,%ebp

# qhasm: y1 = *(uint32 *) (table + 4 + q01 * 8)
# asm 1: movl   4(<table=int64#9,<q01=int64#13,8),>y1=int64#15d
# asm 2: movl   4(<table=%r13,<q01=%rsi,8),>y1=%ebx
movl   4(%r13,%rsi,8),%ebx

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 3 + q10 * 8)
# asm 1: xorl 3(<table=int64#9,<q10=int64#4,8),<y1=int64#15d
# asm 2: xorl 3(<table=%r13,<q10=%r9,8),<y1=%ebx
xorl 3(%r13,%r9,8),%ebx

# qhasm: q20 = z2 & 255
# asm 1: movzbl  <z2=int64#5b,>q20=int64#4d
# asm 2: movzbl  <z2=%al,>q20=%r9d
movzbl  %al,%r9d

# qhasm: q21 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#5%next8,>q21=int64#13d
# asm 2: movzbl  <z2=%ah,>q21=%esi
movzbl  %ah,%esi

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 2 + q21 * 8)
# asm 1: xorl 2(<table=int64#9,<q21=int64#13,8),<y1=int64#15d
# asm 2: xorl 2(<table=%r13,<q21=%rsi,8),<y1=%ebx
xorl 2(%r13,%rsi,8),%ebx

# qhasm: (uint32) z2 >>= 16
# asm 1: shr  $16,<z2=int64#5d
# asm 2: shr  $16,<z2=%eax
shr  $16,%eax

# qhasm: q22 = z2 & 255
# asm 1: movzbl  <z2=int64#5b,>q22=int64#13d
# asm 2: movzbl  <z2=%al,>q22=%esi
movzbl  %al,%esi

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 1 + q22 * 8)
# asm 1: xorl 1(<table=int64#9,<q22=int64#13,8),<y0=int64#1d
# asm 2: xorl 1(<table=%r13,<q22=%rsi,8),<y0=%ecx
xorl 1(%r13,%rsi,8),%ecx

# qhasm: q23 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#5%next8,>q23=int64#13d
# asm 2: movzbl  <z2=%ah,>q23=%esi
movzbl  %ah,%esi

# qhasm: y2 = *(uint32 *) (table + 1 + q02 * 8)
# asm 1: movl   1(<table=int64#9,<q02=int64#11,8),>y2=int64#5d
# asm 2: movl   1(<table=%r13,<q02=%r15,8),>y2=%eax
movl   1(%r13,%r15,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 4 + q13 * 8)
# asm 1: xorl 4(<table=int64#9,<q13=int64#14,8),<y2=int64#5d
# asm 2: xorl 4(<table=%r13,<q13=%rbp,8),<y2=%eax
xorl 4(%r13,%rbp,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 3 + q20 * 8)
# asm 1: xorl 3(<table=int64#9,<q20=int64#4,8),<y2=int64#5d
# asm 2: xorl 3(<table=%r13,<q20=%r9,8),<y2=%eax
xorl 3(%r13,%r9,8),%eax

# qhasm: q30 = z3 & 255
# asm 1: movzbl  <z3=int64#2b,>q30=int64#4d
# asm 2: movzbl  <z3=%dl,>q30=%r9d
movzbl  %dl,%r9d

# qhasm: q31 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#2%next8,>q31=int64#14d
# asm 2: movzbl  <z3=%dh,>q31=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 2 + q31 * 8)
# asm 1: xorl 2(<table=int64#9,<q31=int64#14,8),<y2=int64#5d
# asm 2: xorl 2(<table=%r13,<q31=%rbp,8),<y2=%eax
xorl 2(%r13,%rbp,8),%eax

# qhasm: (uint32) z3 >>= 16
# asm 1: shr  $16,<z3=int64#2d
# asm 2: shr  $16,<z3=%edx
shr  $16,%edx

# qhasm: q32 = z3 & 255
# asm 1: movzbl  <z3=int64#2b,>q32=int64#11d
# asm 2: movzbl  <z3=%dl,>q32=%r15d
movzbl  %dl,%r15d

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 1 + q32 * 8)
# asm 1: xorl 1(<table=int64#9,<q32=int64#11,8),<y1=int64#15d
# asm 2: xorl 1(<table=%r13,<q32=%r15,8),<y1=%ebx
xorl 1(%r13,%r15,8),%ebx

# qhasm: q33 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#2%next8,>q33=int64#14d
# asm 2: movzbl  <z3=%dh,>q33=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 4 + q33 * 8)
# asm 1: xorl 4(<table=int64#9,<q33=int64#14,8),<y0=int64#1d
# asm 2: xorl 4(<table=%r13,<q33=%rbp,8),<y0=%ecx
xorl 4(%r13,%rbp,8),%ecx

# qhasm: y3 = *(uint32 *) (table + 2 + q03 * 8)
# asm 1: movl   2(<table=int64#9,<q03=int64#12,8),>y3=int64#2d
# asm 2: movl   2(<table=%r13,<q03=%rdi,8),>y3=%edx
movl   2(%r13,%rdi,8),%edx

# qhasm: y2 ^= x2
# asm 1: xor  <x2=int64#7,<y2=int64#5
# asm 2: xor  <x2=%r11,<y2=%rax
xor  %r11,%rax

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 1 + q12 * 8)
# asm 1: xorl 1(<table=int64#9,<q12=int64#10,8),<y3=int64#2d
# asm 2: xorl 1(<table=%r13,<q12=%r14,8),<y3=%edx
xorl 1(%r13,%r14,8),%edx

# qhasm: y1 ^= x1
# asm 1: xor  <x1=int64#6,<y1=int64#15
# asm 2: xor  <x1=%r10,<y1=%rbx
xor  %r10,%rbx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 4 + q23 * 8)
# asm 1: xorl 4(<table=int64#9,<q23=int64#13,8),<y3=int64#2d
# asm 2: xorl 4(<table=%r13,<q23=%rsi,8),<y3=%edx
xorl 4(%r13,%rsi,8),%edx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 3 + q30 * 8)
# asm 1: xorl 3(<table=int64#9,<q30=int64#4,8),<y3=int64#2d
# asm 2: xorl 3(<table=%r13,<q30=%r9,8),<y3=%edx
xorl 3(%r13,%r9,8),%edx

# qhasm: y3 ^= x3
# asm 1: xor  <x3=int64#8,<y3=int64#2
# asm 2: xor  <x3=%r12,<y3=%rdx
xor  %r12,%rdx

# qhasm: x0 = *(uint32 *) (c + 24)
# asm 1: movl   24(<c=int64#3),>x0=int64#4d
# asm 2: movl   24(<c=%r8),>x0=%r9d
movl   24(%r8),%r9d

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#4,<x1=int64#6
# asm 2: xor  <x0=%r9,<x1=%r10
xor  %r9,%r10

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#6,<x2=int64#7
# asm 2: xor  <x1=%r10,<x2=%r11
xor  %r10,%r11

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#7,<x3=int64#8
# asm 2: xor  <x2=%r11,<x3=%r12
xor  %r11,%r12

# qhasm: p00 = y0 & 255
# asm 1: movzbl  <y0=int64#1b,>p00=int64#10d
# asm 2: movzbl  <y0=%cl,>p00=%r14d
movzbl  %cl,%r14d

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#1%next8,>p01=int64#12d
# asm 2: movzbl  <y0=%ch,>p01=%edi
movzbl  %ch,%edi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int64#1d
# asm 2: shr  $16,<y0=%ecx
shr  $16,%ecx

# qhasm: p02 = y0 & 255
# asm 1: movzbl  <y0=int64#1b,>p02=int64#11d
# asm 2: movzbl  <y0=%cl,>p02=%r15d
movzbl  %cl,%r15d

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#1%next8,>p03=int64#13d
# asm 2: movzbl  <y0=%ch,>p03=%esi
movzbl  %ch,%esi

# qhasm: z0 = *(uint32 *) (table + 3 + p00 * 8)
# asm 1: movl   3(<table=int64#9,<p00=int64#10,8),>z0=int64#1d
# asm 2: movl   3(<table=%r13,<p00=%r14,8),>z0=%ecx
movl   3(%r13,%r14,8),%ecx

# qhasm: z0 ^= x0
# asm 1: xor  <x0=int64#4,<z0=int64#1
# asm 2: xor  <x0=%r9,<z0=%rcx
xor  %r9,%rcx

# qhasm: p10 = y1 & 255
# asm 1: movzbl  <y1=int64#15b,>p10=int64#4d
# asm 2: movzbl  <y1=%bl,>p10=%r9d
movzbl  %bl,%r9d

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#15%next8,>p11=int64#14d
# asm 2: movzbl  <y1=%bh,>p11=%ebp
movzbl  %bh,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
# asm 1: xorl 2(<table=int64#9,<p11=int64#14,8),<z0=int64#1d
# asm 2: xorl 2(<table=%r13,<p11=%rbp,8),<z0=%ecx
xorl 2(%r13,%rbp,8),%ecx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int64#15d
# asm 2: shr  $16,<y1=%ebx
shr  $16,%ebx

# qhasm: p12 = y1 & 255
# asm 1: movzbl  <y1=int64#15b,>p12=int64#10d
# asm 2: movzbl  <y1=%bl,>p12=%r14d
movzbl  %bl,%r14d

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#15%next8,>p13=int64#14d
# asm 2: movzbl  <y1=%bh,>p13=%ebp
movzbl  %bh,%ebp

# qhasm: z1 = *(uint32 *) (table + 4 + p03 * 8)
# asm 1: movl   4(<table=int64#9,<p03=int64#13,8),>z1=int64#15d
# asm 2: movl   4(<table=%r13,<p03=%rsi,8),>z1=%ebx
movl   4(%r13,%rsi,8),%ebx

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
# asm 1: xorl 3(<table=int64#9,<p10=int64#4,8),<z1=int64#15d
# asm 2: xorl 3(<table=%r13,<p10=%r9,8),<z1=%ebx
xorl 3(%r13,%r9,8),%ebx

# qhasm: p20 = y2 & 255
# asm 1: movzbl  <y2=int64#5b,>p20=int64#4d
# asm 2: movzbl  <y2=%al,>p20=%r9d
movzbl  %al,%r9d

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#5%next8,>p21=int64#13d
# asm 2: movzbl  <y2=%ah,>p21=%esi
movzbl  %ah,%esi

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
# asm 1: xorl 2(<table=int64#9,<p21=int64#13,8),<z1=int64#15d
# asm 2: xorl 2(<table=%r13,<p21=%rsi,8),<z1=%ebx
xorl 2(%r13,%rsi,8),%ebx

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int64#5d
# asm 2: shr  $16,<y2=%eax
shr  $16,%eax

# qhasm: p22 = y2 & 255
# asm 1: movzbl  <y2=int64#5b,>p22=int64#13d
# asm 2: movzbl  <y2=%al,>p22=%esi
movzbl  %al,%esi

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
# asm 1: xorl 1(<table=int64#9,<p22=int64#13,8),<z0=int64#1d
# asm 2: xorl 1(<table=%r13,<p22=%rsi,8),<z0=%ecx
xorl 1(%r13,%rsi,8),%ecx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#5%next8,>p23=int64#13d
# asm 2: movzbl  <y2=%ah,>p23=%esi
movzbl  %ah,%esi

# qhasm: z2 = *(uint32 *) (table + 1 + p02 * 8)
# asm 1: movl   1(<table=int64#9,<p02=int64#11,8),>z2=int64#5d
# asm 2: movl   1(<table=%r13,<p02=%r15,8),>z2=%eax
movl   1(%r13,%r15,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
# asm 1: xorl 4(<table=int64#9,<p13=int64#14,8),<z2=int64#5d
# asm 2: xorl 4(<table=%r13,<p13=%rbp,8),<z2=%eax
xorl 4(%r13,%rbp,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
# asm 1: xorl 3(<table=int64#9,<p20=int64#4,8),<z2=int64#5d
# asm 2: xorl 3(<table=%r13,<p20=%r9,8),<z2=%eax
xorl 3(%r13,%r9,8),%eax

# qhasm: p30 = y3 & 255
# asm 1: movzbl  <y3=int64#2b,>p30=int64#4d
# asm 2: movzbl  <y3=%dl,>p30=%r9d
movzbl  %dl,%r9d

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#2%next8,>p31=int64#14d
# asm 2: movzbl  <y3=%dh,>p31=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
# asm 1: xorl 2(<table=int64#9,<p31=int64#14,8),<z2=int64#5d
# asm 2: xorl 2(<table=%r13,<p31=%rbp,8),<z2=%eax
xorl 2(%r13,%rbp,8),%eax

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int64#2d
# asm 2: shr  $16,<y3=%edx
shr  $16,%edx

# qhasm: p32 = y3 & 255
# asm 1: movzbl  <y3=int64#2b,>p32=int64#11d
# asm 2: movzbl  <y3=%dl,>p32=%r15d
movzbl  %dl,%r15d

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
# asm 1: xorl 1(<table=int64#9,<p32=int64#11,8),<z1=int64#15d
# asm 2: xorl 1(<table=%r13,<p32=%r15,8),<z1=%ebx
xorl 1(%r13,%r15,8),%ebx

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#2%next8,>p33=int64#14d
# asm 2: movzbl  <y3=%dh,>p33=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
# asm 1: xorl 4(<table=int64#9,<p33=int64#14,8),<z0=int64#1d
# asm 2: xorl 4(<table=%r13,<p33=%rbp,8),<z0=%ecx
xorl 4(%r13,%rbp,8),%ecx

# qhasm: z3 = *(uint32 *) (table + 2 + p01 * 8)
# asm 1: movl   2(<table=int64#9,<p01=int64#12,8),>z3=int64#2d
# asm 2: movl   2(<table=%r13,<p01=%rdi,8),>z3=%edx
movl   2(%r13,%rdi,8),%edx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
# asm 1: xorl 1(<table=int64#9,<p12=int64#10,8),<z3=int64#2d
# asm 2: xorl 1(<table=%r13,<p12=%r14,8),<z3=%edx
xorl 1(%r13,%r14,8),%edx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
# asm 1: xorl 4(<table=int64#9,<p23=int64#13,8),<z3=int64#2d
# asm 2: xorl 4(<table=%r13,<p23=%rsi,8),<z3=%edx
xorl 4(%r13,%rsi,8),%edx

# qhasm: z1 ^= x1
# asm 1: xor  <x1=int64#6,<z1=int64#15
# asm 2: xor  <x1=%r10,<z1=%rbx
xor  %r10,%rbx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
# asm 1: xorl 3(<table=int64#9,<p30=int64#4,8),<z3=int64#2d
# asm 2: xorl 3(<table=%r13,<p30=%r9,8),<z3=%edx
xorl 3(%r13,%r9,8),%edx

# qhasm: z2 ^= x2
# asm 1: xor  <x2=int64#7,<z2=int64#5
# asm 2: xor  <x2=%r11,<z2=%rax
xor  %r11,%rax

# qhasm: z3 ^= x3
# asm 1: xor  <x3=int64#8,<z3=int64#2
# asm 2: xor  <x3=%r12,<z3=%rdx
xor  %r12,%rdx

# qhasm: x0 = *(uint32 *) (c + 28)
# asm 1: movl   28(<c=int64#3),>x0=int64#4d
# asm 2: movl   28(<c=%r8),>x0=%r9d
movl   28(%r8),%r9d

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#4,<x1=int64#6
# asm 2: xor  <x0=%r9,<x1=%r10
xor  %r9,%r10

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#6,<x2=int64#7
# asm 2: xor  <x1=%r10,<x2=%r11
xor  %r10,%r11

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#7,<x3=int64#8
# asm 2: xor  <x2=%r11,<x3=%r12
xor  %r11,%r12

# qhasm: q00 = z0 & 255
# asm 1: movzbl  <z0=int64#1b,>q00=int64#10d
# asm 2: movzbl  <z0=%cl,>q00=%r14d
movzbl  %cl,%r14d

# qhasm: q03 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#1%next8,>q03=int64#12d
# asm 2: movzbl  <z0=%ch,>q03=%edi
movzbl  %ch,%edi

# qhasm: (uint32) z0 >>= 16
# asm 1: shr  $16,<z0=int64#1d
# asm 2: shr  $16,<z0=%ecx
shr  $16,%ecx

# qhasm: q02 = z0 & 255
# asm 1: movzbl  <z0=int64#1b,>q02=int64#11d
# asm 2: movzbl  <z0=%cl,>q02=%r15d
movzbl  %cl,%r15d

# qhasm: q01 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#1%next8,>q01=int64#13d
# asm 2: movzbl  <z0=%ch,>q01=%esi
movzbl  %ch,%esi

# qhasm: y0 = *(uint32 *) (table + 3 + q00 * 8)
# asm 1: movl   3(<table=int64#9,<q00=int64#10,8),>y0=int64#1d
# asm 2: movl   3(<table=%r13,<q00=%r14,8),>y0=%ecx
movl   3(%r13,%r14,8),%ecx

# qhasm: y0 ^= x0
# asm 1: xor  <x0=int64#4,<y0=int64#1
# asm 2: xor  <x0=%r9,<y0=%rcx
xor  %r9,%rcx

# qhasm: q10 = z1 & 255
# asm 1: movzbl  <z1=int64#15b,>q10=int64#4d
# asm 2: movzbl  <z1=%bl,>q10=%r9d
movzbl  %bl,%r9d

# qhasm: q11 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#15%next8,>q11=int64#14d
# asm 2: movzbl  <z1=%bh,>q11=%ebp
movzbl  %bh,%ebp

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 2 + q11 * 8)
# asm 1: xorl 2(<table=int64#9,<q11=int64#14,8),<y0=int64#1d
# asm 2: xorl 2(<table=%r13,<q11=%rbp,8),<y0=%ecx
xorl 2(%r13,%rbp,8),%ecx

# qhasm: (uint32) z1 >>= 16
# asm 1: shr  $16,<z1=int64#15d
# asm 2: shr  $16,<z1=%ebx
shr  $16,%ebx

# qhasm: q12 = z1 & 255
# asm 1: movzbl  <z1=int64#15b,>q12=int64#10d
# asm 2: movzbl  <z1=%bl,>q12=%r14d
movzbl  %bl,%r14d

# qhasm: q13 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#15%next8,>q13=int64#14d
# asm 2: movzbl  <z1=%bh,>q13=%ebp
movzbl  %bh,%ebp

# qhasm: y1 = *(uint32 *) (table + 4 + q01 * 8)
# asm 1: movl   4(<table=int64#9,<q01=int64#13,8),>y1=int64#15d
# asm 2: movl   4(<table=%r13,<q01=%rsi,8),>y1=%ebx
movl   4(%r13,%rsi,8),%ebx

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 3 + q10 * 8)
# asm 1: xorl 3(<table=int64#9,<q10=int64#4,8),<y1=int64#15d
# asm 2: xorl 3(<table=%r13,<q10=%r9,8),<y1=%ebx
xorl 3(%r13,%r9,8),%ebx

# qhasm: q20 = z2 & 255
# asm 1: movzbl  <z2=int64#5b,>q20=int64#4d
# asm 2: movzbl  <z2=%al,>q20=%r9d
movzbl  %al,%r9d

# qhasm: q21 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#5%next8,>q21=int64#13d
# asm 2: movzbl  <z2=%ah,>q21=%esi
movzbl  %ah,%esi

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 2 + q21 * 8)
# asm 1: xorl 2(<table=int64#9,<q21=int64#13,8),<y1=int64#15d
# asm 2: xorl 2(<table=%r13,<q21=%rsi,8),<y1=%ebx
xorl 2(%r13,%rsi,8),%ebx

# qhasm: (uint32) z2 >>= 16
# asm 1: shr  $16,<z2=int64#5d
# asm 2: shr  $16,<z2=%eax
shr  $16,%eax

# qhasm: q22 = z2 & 255
# asm 1: movzbl  <z2=int64#5b,>q22=int64#13d
# asm 2: movzbl  <z2=%al,>q22=%esi
movzbl  %al,%esi

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 1 + q22 * 8)
# asm 1: xorl 1(<table=int64#9,<q22=int64#13,8),<y0=int64#1d
# asm 2: xorl 1(<table=%r13,<q22=%rsi,8),<y0=%ecx
xorl 1(%r13,%rsi,8),%ecx

# qhasm: q23 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#5%next8,>q23=int64#13d
# asm 2: movzbl  <z2=%ah,>q23=%esi
movzbl  %ah,%esi

# qhasm: y2 = *(uint32 *) (table + 1 + q02 * 8)
# asm 1: movl   1(<table=int64#9,<q02=int64#11,8),>y2=int64#5d
# asm 2: movl   1(<table=%r13,<q02=%r15,8),>y2=%eax
movl   1(%r13,%r15,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 4 + q13 * 8)
# asm 1: xorl 4(<table=int64#9,<q13=int64#14,8),<y2=int64#5d
# asm 2: xorl 4(<table=%r13,<q13=%rbp,8),<y2=%eax
xorl 4(%r13,%rbp,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 3 + q20 * 8)
# asm 1: xorl 3(<table=int64#9,<q20=int64#4,8),<y2=int64#5d
# asm 2: xorl 3(<table=%r13,<q20=%r9,8),<y2=%eax
xorl 3(%r13,%r9,8),%eax

# qhasm: q30 = z3 & 255
# asm 1: movzbl  <z3=int64#2b,>q30=int64#4d
# asm 2: movzbl  <z3=%dl,>q30=%r9d
movzbl  %dl,%r9d

# qhasm: q31 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#2%next8,>q31=int64#14d
# asm 2: movzbl  <z3=%dh,>q31=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 2 + q31 * 8)
# asm 1: xorl 2(<table=int64#9,<q31=int64#14,8),<y2=int64#5d
# asm 2: xorl 2(<table=%r13,<q31=%rbp,8),<y2=%eax
xorl 2(%r13,%rbp,8),%eax

# qhasm: (uint32) z3 >>= 16
# asm 1: shr  $16,<z3=int64#2d
# asm 2: shr  $16,<z3=%edx
shr  $16,%edx

# qhasm: q32 = z3 & 255
# asm 1: movzbl  <z3=int64#2b,>q32=int64#11d
# asm 2: movzbl  <z3=%dl,>q32=%r15d
movzbl  %dl,%r15d

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 1 + q32 * 8)
# asm 1: xorl 1(<table=int64#9,<q32=int64#11,8),<y1=int64#15d
# asm 2: xorl 1(<table=%r13,<q32=%r15,8),<y1=%ebx
xorl 1(%r13,%r15,8),%ebx

# qhasm: q33 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#2%next8,>q33=int64#14d
# asm 2: movzbl  <z3=%dh,>q33=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 4 + q33 * 8)
# asm 1: xorl 4(<table=int64#9,<q33=int64#14,8),<y0=int64#1d
# asm 2: xorl 4(<table=%r13,<q33=%rbp,8),<y0=%ecx
xorl 4(%r13,%rbp,8),%ecx

# qhasm: y3 = *(uint32 *) (table + 2 + q03 * 8)
# asm 1: movl   2(<table=int64#9,<q03=int64#12,8),>y3=int64#2d
# asm 2: movl   2(<table=%r13,<q03=%rdi,8),>y3=%edx
movl   2(%r13,%rdi,8),%edx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 1 + q12 * 8)
# asm 1: xorl 1(<table=int64#9,<q12=int64#10,8),<y3=int64#2d
# asm 2: xorl 1(<table=%r13,<q12=%r14,8),<y3=%edx
xorl 1(%r13,%r14,8),%edx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 4 + q23 * 8)
# asm 1: xorl 4(<table=int64#9,<q23=int64#13,8),<y3=int64#2d
# asm 2: xorl 4(<table=%r13,<q23=%rsi,8),<y3=%edx
xorl 4(%r13,%rsi,8),%edx

# qhasm: y1 ^= x1
# asm 1: xor  <x1=int64#6,<y1=int64#15
# asm 2: xor  <x1=%r10,<y1=%rbx
xor  %r10,%rbx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 3 + q30 * 8)
# asm 1: xorl 3(<table=int64#9,<q30=int64#4,8),<y3=int64#2d
# asm 2: xorl 3(<table=%r13,<q30=%r9,8),<y3=%edx
xorl 3(%r13,%r9,8),%edx

# qhasm: y2 ^= x2
# asm 1: xor  <x2=int64#7,<y2=int64#5
# asm 2: xor  <x2=%r11,<y2=%rax
xor  %r11,%rax

# qhasm: y3 ^= x3
# asm 1: xor  <x3=int64#8,<y3=int64#2
# asm 2: xor  <x3=%r12,<y3=%rdx
xor  %r12,%rdx

# qhasm: x0 = *(uint32 *) (c + 32)
# asm 1: movl   32(<c=int64#3),>x0=int64#4d
# asm 2: movl   32(<c=%r8),>x0=%r9d
movl   32(%r8),%r9d

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#4,<x1=int64#6
# asm 2: xor  <x0=%r9,<x1=%r10
xor  %r9,%r10

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#6,<x2=int64#7
# asm 2: xor  <x1=%r10,<x2=%r11
xor  %r10,%r11

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#7,<x3=int64#8
# asm 2: xor  <x2=%r11,<x3=%r12
xor  %r11,%r12

# qhasm: p00 = y0 & 255
# asm 1: movzbl  <y0=int64#1b,>p00=int64#10d
# asm 2: movzbl  <y0=%cl,>p00=%r14d
movzbl  %cl,%r14d

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#1%next8,>p01=int64#12d
# asm 2: movzbl  <y0=%ch,>p01=%edi
movzbl  %ch,%edi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int64#1d
# asm 2: shr  $16,<y0=%ecx
shr  $16,%ecx

# qhasm: p02 = y0 & 255
# asm 1: movzbl  <y0=int64#1b,>p02=int64#11d
# asm 2: movzbl  <y0=%cl,>p02=%r15d
movzbl  %cl,%r15d

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#1%next8,>p03=int64#13d
# asm 2: movzbl  <y0=%ch,>p03=%esi
movzbl  %ch,%esi

# qhasm: z0 = *(uint32 *) (table + 3 + p00 * 8)
# asm 1: movl   3(<table=int64#9,<p00=int64#10,8),>z0=int64#1d
# asm 2: movl   3(<table=%r13,<p00=%r14,8),>z0=%ecx
movl   3(%r13,%r14,8),%ecx

# qhasm: z0 ^= x0
# asm 1: xor  <x0=int64#4,<z0=int64#1
# asm 2: xor  <x0=%r9,<z0=%rcx
xor  %r9,%rcx

# qhasm: p10 = y1 & 255
# asm 1: movzbl  <y1=int64#15b,>p10=int64#4d
# asm 2: movzbl  <y1=%bl,>p10=%r9d
movzbl  %bl,%r9d

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#15%next8,>p11=int64#14d
# asm 2: movzbl  <y1=%bh,>p11=%ebp
movzbl  %bh,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
# asm 1: xorl 2(<table=int64#9,<p11=int64#14,8),<z0=int64#1d
# asm 2: xorl 2(<table=%r13,<p11=%rbp,8),<z0=%ecx
xorl 2(%r13,%rbp,8),%ecx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int64#15d
# asm 2: shr  $16,<y1=%ebx
shr  $16,%ebx

# qhasm: p12 = y1 & 255
# asm 1: movzbl  <y1=int64#15b,>p12=int64#10d
# asm 2: movzbl  <y1=%bl,>p12=%r14d
movzbl  %bl,%r14d

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#15%next8,>p13=int64#14d
# asm 2: movzbl  <y1=%bh,>p13=%ebp
movzbl  %bh,%ebp

# qhasm: z1 = *(uint32 *) (table + 4 + p03 * 8)
# asm 1: movl   4(<table=int64#9,<p03=int64#13,8),>z1=int64#15d
# asm 2: movl   4(<table=%r13,<p03=%rsi,8),>z1=%ebx
movl   4(%r13,%rsi,8),%ebx

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
# asm 1: xorl 3(<table=int64#9,<p10=int64#4,8),<z1=int64#15d
# asm 2: xorl 3(<table=%r13,<p10=%r9,8),<z1=%ebx
xorl 3(%r13,%r9,8),%ebx

# qhasm: p20 = y2 & 255
# asm 1: movzbl  <y2=int64#5b,>p20=int64#4d
# asm 2: movzbl  <y2=%al,>p20=%r9d
movzbl  %al,%r9d

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#5%next8,>p21=int64#13d
# asm 2: movzbl  <y2=%ah,>p21=%esi
movzbl  %ah,%esi

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
# asm 1: xorl 2(<table=int64#9,<p21=int64#13,8),<z1=int64#15d
# asm 2: xorl 2(<table=%r13,<p21=%rsi,8),<z1=%ebx
xorl 2(%r13,%rsi,8),%ebx

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int64#5d
# asm 2: shr  $16,<y2=%eax
shr  $16,%eax

# qhasm: p22 = y2 & 255
# asm 1: movzbl  <y2=int64#5b,>p22=int64#13d
# asm 2: movzbl  <y2=%al,>p22=%esi
movzbl  %al,%esi

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
# asm 1: xorl 1(<table=int64#9,<p22=int64#13,8),<z0=int64#1d
# asm 2: xorl 1(<table=%r13,<p22=%rsi,8),<z0=%ecx
xorl 1(%r13,%rsi,8),%ecx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#5%next8,>p23=int64#13d
# asm 2: movzbl  <y2=%ah,>p23=%esi
movzbl  %ah,%esi

# qhasm: z2 = *(uint32 *) (table + 1 + p02 * 8)
# asm 1: movl   1(<table=int64#9,<p02=int64#11,8),>z2=int64#5d
# asm 2: movl   1(<table=%r13,<p02=%r15,8),>z2=%eax
movl   1(%r13,%r15,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
# asm 1: xorl 4(<table=int64#9,<p13=int64#14,8),<z2=int64#5d
# asm 2: xorl 4(<table=%r13,<p13=%rbp,8),<z2=%eax
xorl 4(%r13,%rbp,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
# asm 1: xorl 3(<table=int64#9,<p20=int64#4,8),<z2=int64#5d
# asm 2: xorl 3(<table=%r13,<p20=%r9,8),<z2=%eax
xorl 3(%r13,%r9,8),%eax

# qhasm: p30 = y3 & 255
# asm 1: movzbl  <y3=int64#2b,>p30=int64#4d
# asm 2: movzbl  <y3=%dl,>p30=%r9d
movzbl  %dl,%r9d

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#2%next8,>p31=int64#14d
# asm 2: movzbl  <y3=%dh,>p31=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
# asm 1: xorl 2(<table=int64#9,<p31=int64#14,8),<z2=int64#5d
# asm 2: xorl 2(<table=%r13,<p31=%rbp,8),<z2=%eax
xorl 2(%r13,%rbp,8),%eax

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int64#2d
# asm 2: shr  $16,<y3=%edx
shr  $16,%edx

# qhasm: p32 = y3 & 255
# asm 1: movzbl  <y3=int64#2b,>p32=int64#11d
# asm 2: movzbl  <y3=%dl,>p32=%r15d
movzbl  %dl,%r15d

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
# asm 1: xorl 1(<table=int64#9,<p32=int64#11,8),<z1=int64#15d
# asm 2: xorl 1(<table=%r13,<p32=%r15,8),<z1=%ebx
xorl 1(%r13,%r15,8),%ebx

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#2%next8,>p33=int64#14d
# asm 2: movzbl  <y3=%dh,>p33=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
# asm 1: xorl 4(<table=int64#9,<p33=int64#14,8),<z0=int64#1d
# asm 2: xorl 4(<table=%r13,<p33=%rbp,8),<z0=%ecx
xorl 4(%r13,%rbp,8),%ecx

# qhasm: z3 = *(uint32 *) (table + 2 + p01 * 8)
# asm 1: movl   2(<table=int64#9,<p01=int64#12,8),>z3=int64#2d
# asm 2: movl   2(<table=%r13,<p01=%rdi,8),>z3=%edx
movl   2(%r13,%rdi,8),%edx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
# asm 1: xorl 1(<table=int64#9,<p12=int64#10,8),<z3=int64#2d
# asm 2: xorl 1(<table=%r13,<p12=%r14,8),<z3=%edx
xorl 1(%r13,%r14,8),%edx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
# asm 1: xorl 4(<table=int64#9,<p23=int64#13,8),<z3=int64#2d
# asm 2: xorl 4(<table=%r13,<p23=%rsi,8),<z3=%edx
xorl 4(%r13,%rsi,8),%edx

# qhasm: z1 ^= x1
# asm 1: xor  <x1=int64#6,<z1=int64#15
# asm 2: xor  <x1=%r10,<z1=%rbx
xor  %r10,%rbx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
# asm 1: xorl 3(<table=int64#9,<p30=int64#4,8),<z3=int64#2d
# asm 2: xorl 3(<table=%r13,<p30=%r9,8),<z3=%edx
xorl 3(%r13,%r9,8),%edx

# qhasm: z2 ^= x2
# asm 1: xor  <x2=int64#7,<z2=int64#5
# asm 2: xor  <x2=%r11,<z2=%rax
xor  %r11,%rax

# qhasm: z3 ^= x3
# asm 1: xor  <x3=int64#8,<z3=int64#2
# asm 2: xor  <x3=%r12,<z3=%rdx
xor  %r12,%rdx

# qhasm: x0 = *(uint32 *) (c + 36)
# asm 1: movl   36(<c=int64#3),>x0=int64#4d
# asm 2: movl   36(<c=%r8),>x0=%r9d
movl   36(%r8),%r9d

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#4,<x1=int64#6
# asm 2: xor  <x0=%r9,<x1=%r10
xor  %r9,%r10

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#6,<x2=int64#7
# asm 2: xor  <x1=%r10,<x2=%r11
xor  %r10,%r11

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#7,<x3=int64#8
# asm 2: xor  <x2=%r11,<x3=%r12
xor  %r11,%r12

# qhasm: q00 = z0 & 255
# asm 1: movzbl  <z0=int64#1b,>q00=int64#10d
# asm 2: movzbl  <z0=%cl,>q00=%r14d
movzbl  %cl,%r14d

# qhasm: q03 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#1%next8,>q03=int64#12d
# asm 2: movzbl  <z0=%ch,>q03=%edi
movzbl  %ch,%edi

# qhasm: (uint32) z0 >>= 16
# asm 1: shr  $16,<z0=int64#1d
# asm 2: shr  $16,<z0=%ecx
shr  $16,%ecx

# qhasm: q02 = z0 & 255
# asm 1: movzbl  <z0=int64#1b,>q02=int64#11d
# asm 2: movzbl  <z0=%cl,>q02=%r15d
movzbl  %cl,%r15d

# qhasm: q01 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#1%next8,>q01=int64#13d
# asm 2: movzbl  <z0=%ch,>q01=%esi
movzbl  %ch,%esi

# qhasm: y0 = *(uint32 *) (table + 3 + q00 * 8)
# asm 1: movl   3(<table=int64#9,<q00=int64#10,8),>y0=int64#1d
# asm 2: movl   3(<table=%r13,<q00=%r14,8),>y0=%ecx
movl   3(%r13,%r14,8),%ecx

# qhasm: y0 ^= x0
# asm 1: xor  <x0=int64#4,<y0=int64#1
# asm 2: xor  <x0=%r9,<y0=%rcx
xor  %r9,%rcx

# qhasm: q10 = z1 & 255
# asm 1: movzbl  <z1=int64#15b,>q10=int64#4d
# asm 2: movzbl  <z1=%bl,>q10=%r9d
movzbl  %bl,%r9d

# qhasm: q11 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#15%next8,>q11=int64#14d
# asm 2: movzbl  <z1=%bh,>q11=%ebp
movzbl  %bh,%ebp

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 2 + q11 * 8)
# asm 1: xorl 2(<table=int64#9,<q11=int64#14,8),<y0=int64#1d
# asm 2: xorl 2(<table=%r13,<q11=%rbp,8),<y0=%ecx
xorl 2(%r13,%rbp,8),%ecx

# qhasm: (uint32) z1 >>= 16
# asm 1: shr  $16,<z1=int64#15d
# asm 2: shr  $16,<z1=%ebx
shr  $16,%ebx

# qhasm: q12 = z1 & 255
# asm 1: movzbl  <z1=int64#15b,>q12=int64#10d
# asm 2: movzbl  <z1=%bl,>q12=%r14d
movzbl  %bl,%r14d

# qhasm: q13 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#15%next8,>q13=int64#14d
# asm 2: movzbl  <z1=%bh,>q13=%ebp
movzbl  %bh,%ebp

# qhasm: y1 = *(uint32 *) (table + 4 + q01 * 8)
# asm 1: movl   4(<table=int64#9,<q01=int64#13,8),>y1=int64#15d
# asm 2: movl   4(<table=%r13,<q01=%rsi,8),>y1=%ebx
movl   4(%r13,%rsi,8),%ebx

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 3 + q10 * 8)
# asm 1: xorl 3(<table=int64#9,<q10=int64#4,8),<y1=int64#15d
# asm 2: xorl 3(<table=%r13,<q10=%r9,8),<y1=%ebx
xorl 3(%r13,%r9,8),%ebx

# qhasm: q20 = z2 & 255
# asm 1: movzbl  <z2=int64#5b,>q20=int64#4d
# asm 2: movzbl  <z2=%al,>q20=%r9d
movzbl  %al,%r9d

# qhasm: q21 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#5%next8,>q21=int64#13d
# asm 2: movzbl  <z2=%ah,>q21=%esi
movzbl  %ah,%esi

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 2 + q21 * 8)
# asm 1: xorl 2(<table=int64#9,<q21=int64#13,8),<y1=int64#15d
# asm 2: xorl 2(<table=%r13,<q21=%rsi,8),<y1=%ebx
xorl 2(%r13,%rsi,8),%ebx

# qhasm: (uint32) z2 >>= 16
# asm 1: shr  $16,<z2=int64#5d
# asm 2: shr  $16,<z2=%eax
shr  $16,%eax

# qhasm: q22 = z2 & 255
# asm 1: movzbl  <z2=int64#5b,>q22=int64#13d
# asm 2: movzbl  <z2=%al,>q22=%esi
movzbl  %al,%esi

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 1 + q22 * 8)
# asm 1: xorl 1(<table=int64#9,<q22=int64#13,8),<y0=int64#1d
# asm 2: xorl 1(<table=%r13,<q22=%rsi,8),<y0=%ecx
xorl 1(%r13,%rsi,8),%ecx

# qhasm: q23 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#5%next8,>q23=int64#13d
# asm 2: movzbl  <z2=%ah,>q23=%esi
movzbl  %ah,%esi

# qhasm: y2 = *(uint32 *) (table + 1 + q02 * 8)
# asm 1: movl   1(<table=int64#9,<q02=int64#11,8),>y2=int64#5d
# asm 2: movl   1(<table=%r13,<q02=%r15,8),>y2=%eax
movl   1(%r13,%r15,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 4 + q13 * 8)
# asm 1: xorl 4(<table=int64#9,<q13=int64#14,8),<y2=int64#5d
# asm 2: xorl 4(<table=%r13,<q13=%rbp,8),<y2=%eax
xorl 4(%r13,%rbp,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 3 + q20 * 8)
# asm 1: xorl 3(<table=int64#9,<q20=int64#4,8),<y2=int64#5d
# asm 2: xorl 3(<table=%r13,<q20=%r9,8),<y2=%eax
xorl 3(%r13,%r9,8),%eax

# qhasm: q30 = z3 & 255
# asm 1: movzbl  <z3=int64#2b,>q30=int64#4d
# asm 2: movzbl  <z3=%dl,>q30=%r9d
movzbl  %dl,%r9d

# qhasm: q31 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#2%next8,>q31=int64#14d
# asm 2: movzbl  <z3=%dh,>q31=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 2 + q31 * 8)
# asm 1: xorl 2(<table=int64#9,<q31=int64#14,8),<y2=int64#5d
# asm 2: xorl 2(<table=%r13,<q31=%rbp,8),<y2=%eax
xorl 2(%r13,%rbp,8),%eax

# qhasm: (uint32) z3 >>= 16
# asm 1: shr  $16,<z3=int64#2d
# asm 2: shr  $16,<z3=%edx
shr  $16,%edx

# qhasm: q32 = z3 & 255
# asm 1: movzbl  <z3=int64#2b,>q32=int64#11d
# asm 2: movzbl  <z3=%dl,>q32=%r15d
movzbl  %dl,%r15d

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 1 + q32 * 8)
# asm 1: xorl 1(<table=int64#9,<q32=int64#11,8),<y1=int64#15d
# asm 2: xorl 1(<table=%r13,<q32=%r15,8),<y1=%ebx
xorl 1(%r13,%r15,8),%ebx

# qhasm: q33 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#2%next8,>q33=int64#14d
# asm 2: movzbl  <z3=%dh,>q33=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 4 + q33 * 8)
# asm 1: xorl 4(<table=int64#9,<q33=int64#14,8),<y0=int64#1d
# asm 2: xorl 4(<table=%r13,<q33=%rbp,8),<y0=%ecx
xorl 4(%r13,%rbp,8),%ecx

# qhasm: y3 = *(uint32 *) (table + 2 + q03 * 8)
# asm 1: movl   2(<table=int64#9,<q03=int64#12,8),>y3=int64#2d
# asm 2: movl   2(<table=%r13,<q03=%rdi,8),>y3=%edx
movl   2(%r13,%rdi,8),%edx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 1 + q12 * 8)
# asm 1: xorl 1(<table=int64#9,<q12=int64#10,8),<y3=int64#2d
# asm 2: xorl 1(<table=%r13,<q12=%r14,8),<y3=%edx
xorl 1(%r13,%r14,8),%edx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 4 + q23 * 8)
# asm 1: xorl 4(<table=int64#9,<q23=int64#13,8),<y3=int64#2d
# asm 2: xorl 4(<table=%r13,<q23=%rsi,8),<y3=%edx
xorl 4(%r13,%rsi,8),%edx

# qhasm: y1 ^= x1
# asm 1: xor  <x1=int64#6,<y1=int64#15
# asm 2: xor  <x1=%r10,<y1=%rbx
xor  %r10,%rbx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 3 + q30 * 8)
# asm 1: xorl 3(<table=int64#9,<q30=int64#4,8),<y3=int64#2d
# asm 2: xorl 3(<table=%r13,<q30=%r9,8),<y3=%edx
xorl 3(%r13,%r9,8),%edx

# qhasm: y2 ^= x2
# asm 1: xor  <x2=int64#7,<y2=int64#5
# asm 2: xor  <x2=%r11,<y2=%rax
xor  %r11,%rax

# qhasm: y3 ^= x3
# asm 1: xor  <x3=int64#8,<y3=int64#2
# asm 2: xor  <x3=%r12,<y3=%rdx
xor  %r12,%rdx

# qhasm: x0 = *(uint32 *) (c + 40)
# asm 1: movl   40(<c=int64#3),>x0=int64#4d
# asm 2: movl   40(<c=%r8),>x0=%r9d
movl   40(%r8),%r9d

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#4,<x1=int64#6
# asm 2: xor  <x0=%r9,<x1=%r10
xor  %r9,%r10

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#6,<x2=int64#7
# asm 2: xor  <x1=%r10,<x2=%r11
xor  %r10,%r11

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#7,<x3=int64#8
# asm 2: xor  <x2=%r11,<x3=%r12
xor  %r11,%r12

# qhasm: p00 = y0 & 255
# asm 1: movzbl  <y0=int64#1b,>p00=int64#10d
# asm 2: movzbl  <y0=%cl,>p00=%r14d
movzbl  %cl,%r14d

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#1%next8,>p01=int64#12d
# asm 2: movzbl  <y0=%ch,>p01=%edi
movzbl  %ch,%edi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int64#1d
# asm 2: shr  $16,<y0=%ecx
shr  $16,%ecx

# qhasm: p02 = y0 & 255
# asm 1: movzbl  <y0=int64#1b,>p02=int64#11d
# asm 2: movzbl  <y0=%cl,>p02=%r15d
movzbl  %cl,%r15d

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#1%next8,>p03=int64#13d
# asm 2: movzbl  <y0=%ch,>p03=%esi
movzbl  %ch,%esi

# qhasm: z0 = *(uint32 *) (table + 3 + p00 * 8)
# asm 1: movl   3(<table=int64#9,<p00=int64#10,8),>z0=int64#1d
# asm 2: movl   3(<table=%r13,<p00=%r14,8),>z0=%ecx
movl   3(%r13,%r14,8),%ecx

# qhasm: z0 ^= x0
# asm 1: xor  <x0=int64#4,<z0=int64#1
# asm 2: xor  <x0=%r9,<z0=%rcx
xor  %r9,%rcx

# qhasm: p10 = y1 & 255
# asm 1: movzbl  <y1=int64#15b,>p10=int64#4d
# asm 2: movzbl  <y1=%bl,>p10=%r9d
movzbl  %bl,%r9d

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#15%next8,>p11=int64#14d
# asm 2: movzbl  <y1=%bh,>p11=%ebp
movzbl  %bh,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
# asm 1: xorl 2(<table=int64#9,<p11=int64#14,8),<z0=int64#1d
# asm 2: xorl 2(<table=%r13,<p11=%rbp,8),<z0=%ecx
xorl 2(%r13,%rbp,8),%ecx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int64#15d
# asm 2: shr  $16,<y1=%ebx
shr  $16,%ebx

# qhasm: p12 = y1 & 255
# asm 1: movzbl  <y1=int64#15b,>p12=int64#10d
# asm 2: movzbl  <y1=%bl,>p12=%r14d
movzbl  %bl,%r14d

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#15%next8,>p13=int64#14d
# asm 2: movzbl  <y1=%bh,>p13=%ebp
movzbl  %bh,%ebp

# qhasm: z1 = *(uint32 *) (table + 4 + p03 * 8)
# asm 1: movl   4(<table=int64#9,<p03=int64#13,8),>z1=int64#15d
# asm 2: movl   4(<table=%r13,<p03=%rsi,8),>z1=%ebx
movl   4(%r13,%rsi,8),%ebx

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
# asm 1: xorl 3(<table=int64#9,<p10=int64#4,8),<z1=int64#15d
# asm 2: xorl 3(<table=%r13,<p10=%r9,8),<z1=%ebx
xorl 3(%r13,%r9,8),%ebx

# qhasm: p20 = y2 & 255
# asm 1: movzbl  <y2=int64#5b,>p20=int64#4d
# asm 2: movzbl  <y2=%al,>p20=%r9d
movzbl  %al,%r9d

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#5%next8,>p21=int64#13d
# asm 2: movzbl  <y2=%ah,>p21=%esi
movzbl  %ah,%esi

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
# asm 1: xorl 2(<table=int64#9,<p21=int64#13,8),<z1=int64#15d
# asm 2: xorl 2(<table=%r13,<p21=%rsi,8),<z1=%ebx
xorl 2(%r13,%rsi,8),%ebx

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int64#5d
# asm 2: shr  $16,<y2=%eax
shr  $16,%eax

# qhasm: p22 = y2 & 255
# asm 1: movzbl  <y2=int64#5b,>p22=int64#13d
# asm 2: movzbl  <y2=%al,>p22=%esi
movzbl  %al,%esi

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
# asm 1: xorl 1(<table=int64#9,<p22=int64#13,8),<z0=int64#1d
# asm 2: xorl 1(<table=%r13,<p22=%rsi,8),<z0=%ecx
xorl 1(%r13,%rsi,8),%ecx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#5%next8,>p23=int64#13d
# asm 2: movzbl  <y2=%ah,>p23=%esi
movzbl  %ah,%esi

# qhasm: z2 = *(uint32 *) (table + 1 + p02 * 8)
# asm 1: movl   1(<table=int64#9,<p02=int64#11,8),>z2=int64#5d
# asm 2: movl   1(<table=%r13,<p02=%r15,8),>z2=%eax
movl   1(%r13,%r15,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
# asm 1: xorl 4(<table=int64#9,<p13=int64#14,8),<z2=int64#5d
# asm 2: xorl 4(<table=%r13,<p13=%rbp,8),<z2=%eax
xorl 4(%r13,%rbp,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
# asm 1: xorl 3(<table=int64#9,<p20=int64#4,8),<z2=int64#5d
# asm 2: xorl 3(<table=%r13,<p20=%r9,8),<z2=%eax
xorl 3(%r13,%r9,8),%eax

# qhasm: p30 = y3 & 255
# asm 1: movzbl  <y3=int64#2b,>p30=int64#4d
# asm 2: movzbl  <y3=%dl,>p30=%r9d
movzbl  %dl,%r9d

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#2%next8,>p31=int64#14d
# asm 2: movzbl  <y3=%dh,>p31=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
# asm 1: xorl 2(<table=int64#9,<p31=int64#14,8),<z2=int64#5d
# asm 2: xorl 2(<table=%r13,<p31=%rbp,8),<z2=%eax
xorl 2(%r13,%rbp,8),%eax

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int64#2d
# asm 2: shr  $16,<y3=%edx
shr  $16,%edx

# qhasm: p32 = y3 & 255
# asm 1: movzbl  <y3=int64#2b,>p32=int64#11d
# asm 2: movzbl  <y3=%dl,>p32=%r15d
movzbl  %dl,%r15d

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
# asm 1: xorl 1(<table=int64#9,<p32=int64#11,8),<z1=int64#15d
# asm 2: xorl 1(<table=%r13,<p32=%r15,8),<z1=%ebx
xorl 1(%r13,%r15,8),%ebx

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#2%next8,>p33=int64#14d
# asm 2: movzbl  <y3=%dh,>p33=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
# asm 1: xorl 4(<table=int64#9,<p33=int64#14,8),<z0=int64#1d
# asm 2: xorl 4(<table=%r13,<p33=%rbp,8),<z0=%ecx
xorl 4(%r13,%rbp,8),%ecx

# qhasm: z3 = *(uint32 *) (table + 2 + p01 * 8)
# asm 1: movl   2(<table=int64#9,<p01=int64#12,8),>z3=int64#2d
# asm 2: movl   2(<table=%r13,<p01=%rdi,8),>z3=%edx
movl   2(%r13,%rdi,8),%edx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
# asm 1: xorl 1(<table=int64#9,<p12=int64#10,8),<z3=int64#2d
# asm 2: xorl 1(<table=%r13,<p12=%r14,8),<z3=%edx
xorl 1(%r13,%r14,8),%edx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
# asm 1: xorl 4(<table=int64#9,<p23=int64#13,8),<z3=int64#2d
# asm 2: xorl 4(<table=%r13,<p23=%rsi,8),<z3=%edx
xorl 4(%r13,%rsi,8),%edx

# qhasm: z1 ^= x1
# asm 1: xor  <x1=int64#6,<z1=int64#15
# asm 2: xor  <x1=%r10,<z1=%rbx
xor  %r10,%rbx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
# asm 1: xorl 3(<table=int64#9,<p30=int64#4,8),<z3=int64#2d
# asm 2: xorl 3(<table=%r13,<p30=%r9,8),<z3=%edx
xorl 3(%r13,%r9,8),%edx

# qhasm: z2 ^= x2
# asm 1: xor  <x2=int64#7,<z2=int64#5
# asm 2: xor  <x2=%r11,<z2=%rax
xor  %r11,%rax

# qhasm: z3 ^= x3
# asm 1: xor  <x3=int64#8,<z3=int64#2
# asm 2: xor  <x3=%r12,<z3=%rdx
xor  %r12,%rdx

# qhasm: x0 = *(uint32 *) (c + 44)
# asm 1: movl   44(<c=int64#3),>x0=int64#4d
# asm 2: movl   44(<c=%r8),>x0=%r9d
movl   44(%r8),%r9d

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#4,<x1=int64#6
# asm 2: xor  <x0=%r9,<x1=%r10
xor  %r9,%r10

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#6,<x2=int64#7
# asm 2: xor  <x1=%r10,<x2=%r11
xor  %r10,%r11

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#7,<x3=int64#8
# asm 2: xor  <x2=%r11,<x3=%r12
xor  %r11,%r12

# qhasm: q00 = z0 & 255
# asm 1: movzbl  <z0=int64#1b,>q00=int64#10d
# asm 2: movzbl  <z0=%cl,>q00=%r14d
movzbl  %cl,%r14d

# qhasm: q03 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#1%next8,>q03=int64#12d
# asm 2: movzbl  <z0=%ch,>q03=%edi
movzbl  %ch,%edi

# qhasm: (uint32) z0 >>= 16
# asm 1: shr  $16,<z0=int64#1d
# asm 2: shr  $16,<z0=%ecx
shr  $16,%ecx

# qhasm: q02 = z0 & 255
# asm 1: movzbl  <z0=int64#1b,>q02=int64#11d
# asm 2: movzbl  <z0=%cl,>q02=%r15d
movzbl  %cl,%r15d

# qhasm: q01 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#1%next8,>q01=int64#13d
# asm 2: movzbl  <z0=%ch,>q01=%esi
movzbl  %ch,%esi

# qhasm: y0 = *(uint32 *) (table + 3 + q00 * 8)
# asm 1: movl   3(<table=int64#9,<q00=int64#10,8),>y0=int64#1d
# asm 2: movl   3(<table=%r13,<q00=%r14,8),>y0=%ecx
movl   3(%r13,%r14,8),%ecx

# qhasm: y0 ^= x0
# asm 1: xor  <x0=int64#4,<y0=int64#1
# asm 2: xor  <x0=%r9,<y0=%rcx
xor  %r9,%rcx

# qhasm: q10 = z1 & 255
# asm 1: movzbl  <z1=int64#15b,>q10=int64#4d
# asm 2: movzbl  <z1=%bl,>q10=%r9d
movzbl  %bl,%r9d

# qhasm: q11 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#15%next8,>q11=int64#14d
# asm 2: movzbl  <z1=%bh,>q11=%ebp
movzbl  %bh,%ebp

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 2 + q11 * 8)
# asm 1: xorl 2(<table=int64#9,<q11=int64#14,8),<y0=int64#1d
# asm 2: xorl 2(<table=%r13,<q11=%rbp,8),<y0=%ecx
xorl 2(%r13,%rbp,8),%ecx

# qhasm: (uint32) z1 >>= 16
# asm 1: shr  $16,<z1=int64#15d
# asm 2: shr  $16,<z1=%ebx
shr  $16,%ebx

# qhasm: q12 = z1 & 255
# asm 1: movzbl  <z1=int64#15b,>q12=int64#10d
# asm 2: movzbl  <z1=%bl,>q12=%r14d
movzbl  %bl,%r14d

# qhasm: q13 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#15%next8,>q13=int64#14d
# asm 2: movzbl  <z1=%bh,>q13=%ebp
movzbl  %bh,%ebp

# qhasm: y1 = *(uint32 *) (table + 4 + q01 * 8)
# asm 1: movl   4(<table=int64#9,<q01=int64#13,8),>y1=int64#15d
# asm 2: movl   4(<table=%r13,<q01=%rsi,8),>y1=%ebx
movl   4(%r13,%rsi,8),%ebx

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 3 + q10 * 8)
# asm 1: xorl 3(<table=int64#9,<q10=int64#4,8),<y1=int64#15d
# asm 2: xorl 3(<table=%r13,<q10=%r9,8),<y1=%ebx
xorl 3(%r13,%r9,8),%ebx

# qhasm: q20 = z2 & 255
# asm 1: movzbl  <z2=int64#5b,>q20=int64#4d
# asm 2: movzbl  <z2=%al,>q20=%r9d
movzbl  %al,%r9d

# qhasm: q21 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#5%next8,>q21=int64#13d
# asm 2: movzbl  <z2=%ah,>q21=%esi
movzbl  %ah,%esi

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 2 + q21 * 8)
# asm 1: xorl 2(<table=int64#9,<q21=int64#13,8),<y1=int64#15d
# asm 2: xorl 2(<table=%r13,<q21=%rsi,8),<y1=%ebx
xorl 2(%r13,%rsi,8),%ebx

# qhasm: (uint32) z2 >>= 16
# asm 1: shr  $16,<z2=int64#5d
# asm 2: shr  $16,<z2=%eax
shr  $16,%eax

# qhasm: q22 = z2 & 255
# asm 1: movzbl  <z2=int64#5b,>q22=int64#13d
# asm 2: movzbl  <z2=%al,>q22=%esi
movzbl  %al,%esi

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 1 + q22 * 8)
# asm 1: xorl 1(<table=int64#9,<q22=int64#13,8),<y0=int64#1d
# asm 2: xorl 1(<table=%r13,<q22=%rsi,8),<y0=%ecx
xorl 1(%r13,%rsi,8),%ecx

# qhasm: q23 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#5%next8,>q23=int64#13d
# asm 2: movzbl  <z2=%ah,>q23=%esi
movzbl  %ah,%esi

# qhasm: y2 = *(uint32 *) (table + 1 + q02 * 8)
# asm 1: movl   1(<table=int64#9,<q02=int64#11,8),>y2=int64#5d
# asm 2: movl   1(<table=%r13,<q02=%r15,8),>y2=%eax
movl   1(%r13,%r15,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 4 + q13 * 8)
# asm 1: xorl 4(<table=int64#9,<q13=int64#14,8),<y2=int64#5d
# asm 2: xorl 4(<table=%r13,<q13=%rbp,8),<y2=%eax
xorl 4(%r13,%rbp,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 3 + q20 * 8)
# asm 1: xorl 3(<table=int64#9,<q20=int64#4,8),<y2=int64#5d
# asm 2: xorl 3(<table=%r13,<q20=%r9,8),<y2=%eax
xorl 3(%r13,%r9,8),%eax

# qhasm: q30 = z3 & 255
# asm 1: movzbl  <z3=int64#2b,>q30=int64#4d
# asm 2: movzbl  <z3=%dl,>q30=%r9d
movzbl  %dl,%r9d

# qhasm: q31 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#2%next8,>q31=int64#14d
# asm 2: movzbl  <z3=%dh,>q31=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 2 + q31 * 8)
# asm 1: xorl 2(<table=int64#9,<q31=int64#14,8),<y2=int64#5d
# asm 2: xorl 2(<table=%r13,<q31=%rbp,8),<y2=%eax
xorl 2(%r13,%rbp,8),%eax

# qhasm: (uint32) z3 >>= 16
# asm 1: shr  $16,<z3=int64#2d
# asm 2: shr  $16,<z3=%edx
shr  $16,%edx

# qhasm: q32 = z3 & 255
# asm 1: movzbl  <z3=int64#2b,>q32=int64#11d
# asm 2: movzbl  <z3=%dl,>q32=%r15d
movzbl  %dl,%r15d

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 1 + q32 * 8)
# asm 1: xorl 1(<table=int64#9,<q32=int64#11,8),<y1=int64#15d
# asm 2: xorl 1(<table=%r13,<q32=%r15,8),<y1=%ebx
xorl 1(%r13,%r15,8),%ebx

# qhasm: q33 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#2%next8,>q33=int64#14d
# asm 2: movzbl  <z3=%dh,>q33=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 4 + q33 * 8)
# asm 1: xorl 4(<table=int64#9,<q33=int64#14,8),<y0=int64#1d
# asm 2: xorl 4(<table=%r13,<q33=%rbp,8),<y0=%ecx
xorl 4(%r13,%rbp,8),%ecx

# qhasm: y3 = *(uint32 *) (table + 2 + q03 * 8)
# asm 1: movl   2(<table=int64#9,<q03=int64#12,8),>y3=int64#2d
# asm 2: movl   2(<table=%r13,<q03=%rdi,8),>y3=%edx
movl   2(%r13,%rdi,8),%edx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 1 + q12 * 8)
# asm 1: xorl 1(<table=int64#9,<q12=int64#10,8),<y3=int64#2d
# asm 2: xorl 1(<table=%r13,<q12=%r14,8),<y3=%edx
xorl 1(%r13,%r14,8),%edx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 4 + q23 * 8)
# asm 1: xorl 4(<table=int64#9,<q23=int64#13,8),<y3=int64#2d
# asm 2: xorl 4(<table=%r13,<q23=%rsi,8),<y3=%edx
xorl 4(%r13,%rsi,8),%edx

# qhasm: y1 ^= x1
# asm 1: xor  <x1=int64#6,<y1=int64#15
# asm 2: xor  <x1=%r10,<y1=%rbx
xor  %r10,%rbx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 3 + q30 * 8)
# asm 1: xorl 3(<table=int64#9,<q30=int64#4,8),<y3=int64#2d
# asm 2: xorl 3(<table=%r13,<q30=%r9,8),<y3=%edx
xorl 3(%r13,%r9,8),%edx

# qhasm: y2 ^= x2
# asm 1: xor  <x2=int64#7,<y2=int64#5
# asm 2: xor  <x2=%r11,<y2=%rax
xor  %r11,%rax

# qhasm: y3 ^= x3
# asm 1: xor  <x3=int64#8,<y3=int64#2
# asm 2: xor  <x3=%r12,<y3=%rdx
xor  %r12,%rdx

# qhasm: x0 = *(uint32 *) (c + 48)
# asm 1: movl   48(<c=int64#3),>x0=int64#4d
# asm 2: movl   48(<c=%r8),>x0=%r9d
movl   48(%r8),%r9d

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#4,<x1=int64#6
# asm 2: xor  <x0=%r9,<x1=%r10
xor  %r9,%r10

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#6,<x2=int64#7
# asm 2: xor  <x1=%r10,<x2=%r11
xor  %r10,%r11

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#7,<x3=int64#8
# asm 2: xor  <x2=%r11,<x3=%r12
xor  %r11,%r12

# qhasm: p00 = y0 & 255
# asm 1: movzbl  <y0=int64#1b,>p00=int64#10d
# asm 2: movzbl  <y0=%cl,>p00=%r14d
movzbl  %cl,%r14d

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#1%next8,>p01=int64#12d
# asm 2: movzbl  <y0=%ch,>p01=%edi
movzbl  %ch,%edi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int64#1d
# asm 2: shr  $16,<y0=%ecx
shr  $16,%ecx

# qhasm: p02 = y0 & 255
# asm 1: movzbl  <y0=int64#1b,>p02=int64#11d
# asm 2: movzbl  <y0=%cl,>p02=%r15d
movzbl  %cl,%r15d

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#1%next8,>p03=int64#13d
# asm 2: movzbl  <y0=%ch,>p03=%esi
movzbl  %ch,%esi

# qhasm: z0 = *(uint32 *) (table + 3 + p00 * 8)
# asm 1: movl   3(<table=int64#9,<p00=int64#10,8),>z0=int64#1d
# asm 2: movl   3(<table=%r13,<p00=%r14,8),>z0=%ecx
movl   3(%r13,%r14,8),%ecx

# qhasm: z0 ^= x0
# asm 1: xor  <x0=int64#4,<z0=int64#1
# asm 2: xor  <x0=%r9,<z0=%rcx
xor  %r9,%rcx

# qhasm: p10 = y1 & 255
# asm 1: movzbl  <y1=int64#15b,>p10=int64#4d
# asm 2: movzbl  <y1=%bl,>p10=%r9d
movzbl  %bl,%r9d

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#15%next8,>p11=int64#14d
# asm 2: movzbl  <y1=%bh,>p11=%ebp
movzbl  %bh,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
# asm 1: xorl 2(<table=int64#9,<p11=int64#14,8),<z0=int64#1d
# asm 2: xorl 2(<table=%r13,<p11=%rbp,8),<z0=%ecx
xorl 2(%r13,%rbp,8),%ecx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int64#15d
# asm 2: shr  $16,<y1=%ebx
shr  $16,%ebx

# qhasm: p12 = y1 & 255
# asm 1: movzbl  <y1=int64#15b,>p12=int64#10d
# asm 2: movzbl  <y1=%bl,>p12=%r14d
movzbl  %bl,%r14d

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#15%next8,>p13=int64#14d
# asm 2: movzbl  <y1=%bh,>p13=%ebp
movzbl  %bh,%ebp

# qhasm: z1 = *(uint32 *) (table + 4 + p03 * 8)
# asm 1: movl   4(<table=int64#9,<p03=int64#13,8),>z1=int64#15d
# asm 2: movl   4(<table=%r13,<p03=%rsi,8),>z1=%ebx
movl   4(%r13,%rsi,8),%ebx

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
# asm 1: xorl 3(<table=int64#9,<p10=int64#4,8),<z1=int64#15d
# asm 2: xorl 3(<table=%r13,<p10=%r9,8),<z1=%ebx
xorl 3(%r13,%r9,8),%ebx

# qhasm: p20 = y2 & 255
# asm 1: movzbl  <y2=int64#5b,>p20=int64#4d
# asm 2: movzbl  <y2=%al,>p20=%r9d
movzbl  %al,%r9d

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#5%next8,>p21=int64#13d
# asm 2: movzbl  <y2=%ah,>p21=%esi
movzbl  %ah,%esi

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
# asm 1: xorl 2(<table=int64#9,<p21=int64#13,8),<z1=int64#15d
# asm 2: xorl 2(<table=%r13,<p21=%rsi,8),<z1=%ebx
xorl 2(%r13,%rsi,8),%ebx

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int64#5d
# asm 2: shr  $16,<y2=%eax
shr  $16,%eax

# qhasm: p22 = y2 & 255
# asm 1: movzbl  <y2=int64#5b,>p22=int64#13d
# asm 2: movzbl  <y2=%al,>p22=%esi
movzbl  %al,%esi

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
# asm 1: xorl 1(<table=int64#9,<p22=int64#13,8),<z0=int64#1d
# asm 2: xorl 1(<table=%r13,<p22=%rsi,8),<z0=%ecx
xorl 1(%r13,%rsi,8),%ecx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#5%next8,>p23=int64#13d
# asm 2: movzbl  <y2=%ah,>p23=%esi
movzbl  %ah,%esi

# qhasm: z2 = *(uint32 *) (table + 1 + p02 * 8)
# asm 1: movl   1(<table=int64#9,<p02=int64#11,8),>z2=int64#5d
# asm 2: movl   1(<table=%r13,<p02=%r15,8),>z2=%eax
movl   1(%r13,%r15,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
# asm 1: xorl 4(<table=int64#9,<p13=int64#14,8),<z2=int64#5d
# asm 2: xorl 4(<table=%r13,<p13=%rbp,8),<z2=%eax
xorl 4(%r13,%rbp,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
# asm 1: xorl 3(<table=int64#9,<p20=int64#4,8),<z2=int64#5d
# asm 2: xorl 3(<table=%r13,<p20=%r9,8),<z2=%eax
xorl 3(%r13,%r9,8),%eax

# qhasm: p30 = y3 & 255
# asm 1: movzbl  <y3=int64#2b,>p30=int64#4d
# asm 2: movzbl  <y3=%dl,>p30=%r9d
movzbl  %dl,%r9d

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#2%next8,>p31=int64#14d
# asm 2: movzbl  <y3=%dh,>p31=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
# asm 1: xorl 2(<table=int64#9,<p31=int64#14,8),<z2=int64#5d
# asm 2: xorl 2(<table=%r13,<p31=%rbp,8),<z2=%eax
xorl 2(%r13,%rbp,8),%eax

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int64#2d
# asm 2: shr  $16,<y3=%edx
shr  $16,%edx

# qhasm: p32 = y3 & 255
# asm 1: movzbl  <y3=int64#2b,>p32=int64#11d
# asm 2: movzbl  <y3=%dl,>p32=%r15d
movzbl  %dl,%r15d

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
# asm 1: xorl 1(<table=int64#9,<p32=int64#11,8),<z1=int64#15d
# asm 2: xorl 1(<table=%r13,<p32=%r15,8),<z1=%ebx
xorl 1(%r13,%r15,8),%ebx

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#2%next8,>p33=int64#14d
# asm 2: movzbl  <y3=%dh,>p33=%ebp
movzbl  %dh,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
# asm 1: xorl 4(<table=int64#9,<p33=int64#14,8),<z0=int64#1d
# asm 2: xorl 4(<table=%r13,<p33=%rbp,8),<z0=%ecx
xorl 4(%r13,%rbp,8),%ecx

# qhasm: z3 = *(uint32 *) (table + 2 + p01 * 8)
# asm 1: movl   2(<table=int64#9,<p01=int64#12,8),>z3=int64#2d
# asm 2: movl   2(<table=%r13,<p01=%rdi,8),>z3=%edx
movl   2(%r13,%rdi,8),%edx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
# asm 1: xorl 1(<table=int64#9,<p12=int64#10,8),<z3=int64#2d
# asm 2: xorl 1(<table=%r13,<p12=%r14,8),<z3=%edx
xorl 1(%r13,%r14,8),%edx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
# asm 1: xorl 4(<table=int64#9,<p23=int64#13,8),<z3=int64#2d
# asm 2: xorl 4(<table=%r13,<p23=%rsi,8),<z3=%edx
xorl 4(%r13,%rsi,8),%edx

# qhasm: z1 ^= x1
# asm 1: xor  <x1=int64#6,<z1=int64#15
# asm 2: xor  <x1=%r10,<z1=%rbx
xor  %r10,%rbx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
# asm 1: xorl 3(<table=int64#9,<p30=int64#4,8),<z3=int64#2d
# asm 2: xorl 3(<table=%r13,<p30=%r9,8),<z3=%edx
xorl 3(%r13,%r9,8),%edx

# qhasm: z2 ^= x2
# asm 1: xor  <x2=int64#7,<z2=int64#5
# asm 2: xor  <x2=%r11,<z2=%rax
xor  %r11,%rax

# qhasm: z3 ^= x3
# asm 1: xor  <x3=int64#8,<z3=int64#2
# asm 2: xor  <x3=%r12,<z3=%rdx
xor  %r12,%rdx

# qhasm: x0 = *(uint32 *) (c + 52)
# asm 1: movl   52(<c=int64#3),>x0=int64#3d
# asm 2: movl   52(<c=%r8),>x0=%r8d
movl   52(%r8),%r8d

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#3,<x1=int64#6
# asm 2: xor  <x0=%r8,<x1=%r10
xor  %r8,%r10

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#6,<x2=int64#7
# asm 2: xor  <x1=%r10,<x2=%r11
xor  %r10,%r11

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#7,<x3=int64#8
# asm 2: xor  <x2=%r11,<x3=%r12
xor  %r11,%r12

# qhasm: y0 = z0 & 255
# asm 1: movzbl  <z0=int64#1b,>y0=int64#4d
# asm 2: movzbl  <z0=%cl,>y0=%r9d
movzbl  %cl,%r9d

# qhasm: y0 = *(uint8 *) (table + 1 + y0 * 8)
# asm 1: movzbq 1(<table=int64#9,<y0=int64#4,8),>y0=int64#4
# asm 2: movzbq 1(<table=%r13,<y0=%r9,8),>y0=%r9
movzbq 1(%r13,%r9,8),%r9

# qhasm: y3 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#1%next8,>y3=int64#12d
# asm 2: movzbl  <z0=%ch,>y3=%edi
movzbl  %ch,%edi

# qhasm: y3 = *(uint16 *) (table + y3 * 8)
# asm 1: movzwq (<table=int64#9,<y3=int64#12,8),>y3=int64#10
# asm 2: movzwq (<table=%r13,<y3=%rdi,8),>y3=%r14
movzwq (%r13,%rdi,8),%r14

# qhasm: (uint32) z0 >>= 16
# asm 1: shr  $16,<z0=int64#1d
# asm 2: shr  $16,<z0=%ecx
shr  $16,%ecx

# qhasm: y2 = z0 & 255
# asm 1: movzbl  <z0=int64#1b,>y2=int64#11d
# asm 2: movzbl  <z0=%cl,>y2=%r15d
movzbl  %cl,%r15d

# qhasm: y2 = *(uint32 *) (table + 3 + y2 * 8)
# asm 1: movl   3(<table=int64#9,<y2=int64#11,8),>y2=int64#11d
# asm 2: movl   3(<table=%r13,<y2=%r15,8),>y2=%r15d
movl   3(%r13,%r15,8),%r15d

# qhasm: (uint32) y2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<y2=int64#11d
# asm 2: and  $0x00ff0000,<y2=%r15d
and  $0x00ff0000,%r15d

# qhasm: y1 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#1%next8,>y1=int64#12d
# asm 2: movzbl  <z0=%ch,>y1=%edi
movzbl  %ch,%edi

# qhasm: y1 = *(uint32 *) (table + 2 + y1 * 8)
# asm 1: movl   2(<table=int64#9,<y1=int64#12,8),>y1=int64#1d
# asm 2: movl   2(<table=%r13,<y1=%rdi,8),>y1=%ecx
movl   2(%r13,%rdi,8),%ecx

# qhasm: (uint32) y1 &= 0xff000000
# asm 1: and  $0xff000000,<y1=int64#1d
# asm 2: and  $0xff000000,<y1=%ecx
and  $0xff000000,%ecx

# qhasm: y0 ^= x0
# asm 1: xor  <x0=int64#3,<y0=int64#4
# asm 2: xor  <x0=%r8,<y0=%r9
xor  %r8,%r9

# qhasm: y3 ^= x3
# asm 1: xor  <x3=int64#8,<y3=int64#10
# asm 2: xor  <x3=%r12,<y3=%r14
xor  %r12,%r14

# qhasm: y1 ^= x1
# asm 1: xor  <x1=int64#6,<y1=int64#1
# asm 2: xor  <x1=%r10,<y1=%rcx
xor  %r10,%rcx

# qhasm: y2 ^= x2
# asm 1: xor  <x2=int64#7,<y2=int64#11
# asm 2: xor  <x2=%r11,<y2=%r15
xor  %r11,%r15

# qhasm: q10 = z1 & 255
# asm 1: movzbl  <z1=int64#15b,>q10=int64#3d
# asm 2: movzbl  <z1=%bl,>q10=%r8d
movzbl  %bl,%r8d

# qhasm: q10 = *(uint8 *) (table + 1 + q10 * 8)
# asm 1: movzbq 1(<table=int64#9,<q10=int64#3,8),>q10=int64#3
# asm 2: movzbq 1(<table=%r13,<q10=%r8,8),>q10=%r8
movzbq 1(%r13,%r8,8),%r8

# qhasm: y1 ^= q10
# asm 1: xor  <q10=int64#3,<y1=int64#1
# asm 2: xor  <q10=%r8,<y1=%rcx
xor  %r8,%rcx

# qhasm: q11 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#15%next8,>q11=int64#12d
# asm 2: movzbl  <z1=%bh,>q11=%edi
movzbl  %bh,%edi

# qhasm: q11 = *(uint16 *) (table + q11 * 8)
# asm 1: movzwq (<table=int64#9,<q11=int64#12,8),>q11=int64#3
# asm 2: movzwq (<table=%r13,<q11=%rdi,8),>q11=%r8
movzwq (%r13,%rdi,8),%r8

# qhasm: y0 ^= q11
# asm 1: xor  <q11=int64#3,<y0=int64#4
# asm 2: xor  <q11=%r8,<y0=%r9
xor  %r8,%r9

# qhasm: (uint32) z1 >>= 16
# asm 1: shr  $16,<z1=int64#15d
# asm 2: shr  $16,<z1=%ebx
shr  $16,%ebx

# qhasm: q12 = z1 & 255
# asm 1: movzbl  <z1=int64#15b,>q12=int64#3d
# asm 2: movzbl  <z1=%bl,>q12=%r8d
movzbl  %bl,%r8d

# qhasm: q12 = *(uint32 *) (table + 3 + q12 * 8)
# asm 1: movl   3(<table=int64#9,<q12=int64#3,8),>q12=int64#3d
# asm 2: movl   3(<table=%r13,<q12=%r8,8),>q12=%r8d
movl   3(%r13,%r8,8),%r8d

# qhasm: (uint32) q12 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q12=int64#3d
# asm 2: and  $0x00ff0000,<q12=%r8d
and  $0x00ff0000,%r8d

# qhasm: y3 ^= q12
# asm 1: xor  <q12=int64#3,<y3=int64#10
# asm 2: xor  <q12=%r8,<y3=%r14
xor  %r8,%r14

# qhasm: q13 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#15%next8,>q13=int64#12d
# asm 2: movzbl  <z1=%bh,>q13=%edi
movzbl  %bh,%edi

# qhasm: q13 = *(uint32 *) (table + 2 + q13 * 8)
# asm 1: movl   2(<table=int64#9,<q13=int64#12,8),>q13=int64#3d
# asm 2: movl   2(<table=%r13,<q13=%rdi,8),>q13=%r8d
movl   2(%r13,%rdi,8),%r8d

# qhasm: (uint32) q13 &= 0xff000000
# asm 1: and  $0xff000000,<q13=int64#3d
# asm 2: and  $0xff000000,<q13=%r8d
and  $0xff000000,%r8d

# qhasm: y2 ^= q13
# asm 1: xor  <q13=int64#3,<y2=int64#11
# asm 2: xor  <q13=%r8,<y2=%r15
xor  %r8,%r15

# qhasm: q20 = z2 & 255
# asm 1: movzbl  <z2=int64#5b,>q20=int64#3d
# asm 2: movzbl  <z2=%al,>q20=%r8d
movzbl  %al,%r8d

# qhasm: q20 = *(uint8 *) (table + 1 + q20 * 8)
# asm 1: movzbq 1(<table=int64#9,<q20=int64#3,8),>q20=int64#3
# asm 2: movzbq 1(<table=%r13,<q20=%r8,8),>q20=%r8
movzbq 1(%r13,%r8,8),%r8

# qhasm: y2 ^= q20
# asm 1: xor  <q20=int64#3,<y2=int64#11
# asm 2: xor  <q20=%r8,<y2=%r15
xor  %r8,%r15

# qhasm: q21 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#5%next8,>q21=int64#12d
# asm 2: movzbl  <z2=%ah,>q21=%edi
movzbl  %ah,%edi

# qhasm: q21 = *(uint16 *) (table + q21 * 8)
# asm 1: movzwq (<table=int64#9,<q21=int64#12,8),>q21=int64#3
# asm 2: movzwq (<table=%r13,<q21=%rdi,8),>q21=%r8
movzwq (%r13,%rdi,8),%r8

# qhasm: y1 ^= q21
# asm 1: xor  <q21=int64#3,<y1=int64#1
# asm 2: xor  <q21=%r8,<y1=%rcx
xor  %r8,%rcx

# qhasm: (uint32) z2 >>= 16
# asm 1: shr  $16,<z2=int64#5d
# asm 2: shr  $16,<z2=%eax
shr  $16,%eax

# qhasm: q22 = z2 & 255
# asm 1: movzbl  <z2=int64#5b,>q22=int64#3d
# asm 2: movzbl  <z2=%al,>q22=%r8d
movzbl  %al,%r8d

# qhasm: q22 = *(uint32 *) (table + 3 + q22 * 8)
# asm 1: movl   3(<table=int64#9,<q22=int64#3,8),>q22=int64#3d
# asm 2: movl   3(<table=%r13,<q22=%r8,8),>q22=%r8d
movl   3(%r13,%r8,8),%r8d

# qhasm: (uint32) q22 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q22=int64#3d
# asm 2: and  $0x00ff0000,<q22=%r8d
and  $0x00ff0000,%r8d

# qhasm: y0 ^= q22
# asm 1: xor  <q22=int64#3,<y0=int64#4
# asm 2: xor  <q22=%r8,<y0=%r9
xor  %r8,%r9

# qhasm: q23 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#5%next8,>q23=int64#12d
# asm 2: movzbl  <z2=%ah,>q23=%edi
movzbl  %ah,%edi

# qhasm: q23 = *(uint32 *) (table + 2 + q23 * 8)
# asm 1: movl   2(<table=int64#9,<q23=int64#12,8),>q23=int64#3d
# asm 2: movl   2(<table=%r13,<q23=%rdi,8),>q23=%r8d
movl   2(%r13,%rdi,8),%r8d

# qhasm: (uint32) q23 &= 0xff000000
# asm 1: and  $0xff000000,<q23=int64#3d
# asm 2: and  $0xff000000,<q23=%r8d
and  $0xff000000,%r8d

# qhasm: y3 ^= q23
# asm 1: xor  <q23=int64#3,<y3=int64#10
# asm 2: xor  <q23=%r8,<y3=%r14
xor  %r8,%r14

# qhasm: q30 = z3 & 255
# asm 1: movzbl  <z3=int64#2b,>q30=int64#3d
# asm 2: movzbl  <z3=%dl,>q30=%r8d
movzbl  %dl,%r8d

# qhasm: q30 = *(uint8 *) (table + 1 + q30 * 8)
# asm 1: movzbq 1(<table=int64#9,<q30=int64#3,8),>q30=int64#3
# asm 2: movzbq 1(<table=%r13,<q30=%r8,8),>q30=%r8
movzbq 1(%r13,%r8,8),%r8

# qhasm: y3 ^= q30
# asm 1: xor  <q30=int64#3,<y3=int64#10
# asm 2: xor  <q30=%r8,<y3=%r14
xor  %r8,%r14

# qhasm: q31 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#2%next8,>q31=int64#12d
# asm 2: movzbl  <z3=%dh,>q31=%edi
movzbl  %dh,%edi

# qhasm: q31 = *(uint16 *) (table + q31 * 8)
# asm 1: movzwq (<table=int64#9,<q31=int64#12,8),>q31=int64#3
# asm 2: movzwq (<table=%r13,<q31=%rdi,8),>q31=%r8
movzwq (%r13,%rdi,8),%r8

# qhasm: y2 ^= q31
# asm 1: xor  <q31=int64#3,<y2=int64#11
# asm 2: xor  <q31=%r8,<y2=%r15
xor  %r8,%r15

# qhasm: (uint32) z3 >>= 16
# asm 1: shr  $16,<z3=int64#2d
# asm 2: shr  $16,<z3=%edx
shr  $16,%edx

# qhasm: q32 = z3 & 255
# asm 1: movzbl  <z3=int64#2b,>q32=int64#3d
# asm 2: movzbl  <z3=%dl,>q32=%r8d
movzbl  %dl,%r8d

# qhasm: q32 = *(uint32 *) (table + 3 + q32 * 8)
# asm 1: movl   3(<table=int64#9,<q32=int64#3,8),>q32=int64#3d
# asm 2: movl   3(<table=%r13,<q32=%r8,8),>q32=%r8d
movl   3(%r13,%r8,8),%r8d

# qhasm: (uint32) q32 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q32=int64#3d
# asm 2: and  $0x00ff0000,<q32=%r8d
and  $0x00ff0000,%r8d

# qhasm: y1 ^= q32
# asm 1: xor  <q32=int64#3,<y1=int64#1
# asm 2: xor  <q32=%r8,<y1=%rcx
xor  %r8,%rcx

# qhasm: q33 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#2%next8,>q33=int64#12d
# asm 2: movzbl  <z3=%dh,>q33=%edi
movzbl  %dh,%edi

# qhasm: q33 = *(uint32 *) (table + 2 + q33 * 8)
# asm 1: movl   2(<table=int64#9,<q33=int64#12,8),>q33=int64#2d
# asm 2: movl   2(<table=%r13,<q33=%rdi,8),>q33=%edx
movl   2(%r13,%rdi,8),%edx

# qhasm: (uint32) q33 &= 0xff000000
# asm 1: and  $0xff000000,<q33=int64#2d
# asm 2: and  $0xff000000,<q33=%edx
and  $0xff000000,%edx

# qhasm: y0 ^= q33
# asm 1: xor  <q33=int64#2,<y0=int64#4
# asm 2: xor  <q33=%rdx,<y0=%r9
xor  %rdx,%r9

# qhasm: out = out_stack
# asm 1: movq <out_stack=stack64#1,>out=int64#2
# asm 2: movq <out_stack=0(%rsp),>out=%rdx
movq 0(%rsp),%rdx

# qhasm: *(uint32 *) (out + 0) = y0
# asm 1: movl   <y0=int64#4d,0(<out=int64#2)
# asm 2: movl   <y0=%r9d,0(<out=%rdx)
movl   %r9d,0(%rdx)

# qhasm: *(uint32 *) (out + 4) = y1
# asm 1: movl   <y1=int64#1d,4(<out=int64#2)
# asm 2: movl   <y1=%ecx,4(<out=%rdx)
movl   %ecx,4(%rdx)

# qhasm: *(uint32 *) (out + 8) = y2
# asm 1: movl   <y2=int64#11d,8(<out=int64#2)
# asm 2: movl   <y2=%r15d,8(<out=%rdx)
movl   %r15d,8(%rdx)

# qhasm: *(uint32 *) (out + 12) = y3
# asm 1: movl   <y3=int64#10d,12(<out=int64#2)
# asm 2: movl   <y3=%r14d,12(<out=%rdx)
movl   %r14d,12(%rdx)

# qhasm: r11_caller = r11_stack
# asm 1: movq <r11_stack=stack64#2,>r11_caller=int64#7
# asm 2: movq <r11_stack=8(%rsp),>r11_caller=%r11
movq 8(%rsp),%r11

# qhasm: r12_caller = r12_stack
# asm 1: movq <r12_stack=stack64#3,>r12_caller=int64#8
# asm 2: movq <r12_stack=16(%rsp),>r12_caller=%r12
movq 16(%rsp),%r12

# qhasm: r13_caller = r13_stack
# asm 1: movq <r13_stack=stack64#4,>r13_caller=int64#9
# asm 2: movq <r13_stack=24(%rsp),>r13_caller=%r13
movq 24(%rsp),%r13

# qhasm: r14_caller = r14_stack
# asm 1: movq <r14_stack=stack64#5,>r14_caller=int64#10
# asm 2: movq <r14_stack=32(%rsp),>r14_caller=%r14
movq 32(%rsp),%r14

# qhasm: r15_caller = r15_stack
# asm 1: movq <r15_stack=stack64#6,>r15_caller=int64#11
# asm 2: movq <r15_stack=40(%rsp),>r15_caller=%r15
movq 40(%rsp),%r15

# qhasm: rdi_caller = rdi_stack
# asm 1: movq <rdi_stack=stack64#7,>rdi_caller=int64#12
# asm 2: movq <rdi_stack=48(%rsp),>rdi_caller=%rdi
movq 48(%rsp),%rdi

# qhasm: rsi_caller = rsi_stack
# asm 1: movq <rsi_stack=stack64#8,>rsi_caller=int64#13
# asm 2: movq <rsi_stack=56(%rsp),>rsi_caller=%rsi
movq 56(%rsp),%rsi

# qhasm: rbp_caller = rbp_stack
# asm 1: movq <rbp_stack=stack64#9,>rbp_caller=int64#14
# asm 2: movq <rbp_stack=64(%rsp),>rbp_caller=%rbp
movq 64(%rsp),%rbp

# qhasm: rbx_caller = rbx_stack
# asm 1: movq <rbx_stack=stack64#10,>rbx_caller=int64#15
# asm 2: movq <rbx_stack=72(%rsp),>rbx_caller=%rbx
movq 72(%rsp),%rbx

# qhasm: leave
add %r11,%rsp
ret
