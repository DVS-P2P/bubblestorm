
# qhasm: int64 r11_caller

# qhasm: int64 r12_caller

# qhasm: int64 r13_caller

# qhasm: int64 r14_caller

# qhasm: int64 r15_caller

# qhasm: int64 rbp_caller

# qhasm: int64 rbx_caller

# qhasm: caller r11_caller

# qhasm: caller r12_caller

# qhasm: caller r13_caller

# qhasm: caller r14_caller

# qhasm: caller r15_caller

# qhasm: caller rbp_caller

# qhasm: caller rbx_caller

# qhasm: stack64 r11_stack

# qhasm: stack64 r12_stack

# qhasm: stack64 r13_stack

# qhasm: stack64 r14_stack

# qhasm: stack64 r15_stack

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

# qhasm: stack64 c_stack

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

# qhasm: c_stack = c
# asm 1: movq <c=int64#3,>c_stack=stack64#1
# asm 2: movq <c=%rdx,>c_stack=0(%rsp)
movq %rdx,0(%rsp)

# qhasm: out_stack = out
# asm 1: movq <out=int64#1,>out_stack=stack64#2
# asm 2: movq <out=%rdi,>out_stack=8(%rsp)
movq %rdi,8(%rsp)

# qhasm: r11_stack = r11_caller
# asm 1: movq <r11_caller=int64#9,>r11_stack=stack64#3
# asm 2: movq <r11_caller=%r11,>r11_stack=16(%rsp)
movq %r11,16(%rsp)

# qhasm: r12_stack = r12_caller
# asm 1: movq <r12_caller=int64#10,>r12_stack=stack64#4
# asm 2: movq <r12_caller=%r12,>r12_stack=24(%rsp)
movq %r12,24(%rsp)

# qhasm: r13_stack = r13_caller
# asm 1: movq <r13_caller=int64#11,>r13_stack=stack64#5
# asm 2: movq <r13_caller=%r13,>r13_stack=32(%rsp)
movq %r13,32(%rsp)

# qhasm: r14_stack = r14_caller
# asm 1: movq <r14_caller=int64#12,>r14_stack=stack64#6
# asm 2: movq <r14_caller=%r14,>r14_stack=40(%rsp)
movq %r14,40(%rsp)

# qhasm: r15_stack = r15_caller
# asm 1: movq <r15_caller=int64#13,>r15_stack=stack64#7
# asm 2: movq <r15_caller=%r15,>r15_stack=48(%rsp)
movq %r15,48(%rsp)

# qhasm: rbp_stack = rbp_caller
# asm 1: movq <rbp_caller=int64#14,>rbp_stack=stack64#8
# asm 2: movq <rbp_caller=%rbx,>rbp_stack=56(%rsp)
movq %rbx,56(%rsp)

# qhasm: rbx_stack = rbx_caller
# asm 1: movq <rbx_caller=int64#15,>rbx_stack=stack64#9
# asm 2: movq <rbx_caller=%rbp,>rbx_stack=64(%rsp)
movq %rbp,64(%rsp)

# qhasm: x0 = *(uint32 *) (c + 0)
# asm 1: movl   0(<c=int64#3),>x0=int64#1d
# asm 2: movl   0(<c=%rdx),>x0=%edi
movl   0(%rdx),%edi

# qhasm: x1 = *(uint32 *) (c + 4)
# asm 1: movl   4(<c=int64#3),>x1=int64#5d
# asm 2: movl   4(<c=%rdx),>x1=%r8d
movl   4(%rdx),%r8d

# qhasm: x2 = *(uint32 *) (c + 8)
# asm 1: movl   8(<c=int64#3),>x2=int64#6d
# asm 2: movl   8(<c=%rdx),>x2=%r9d
movl   8(%rdx),%r9d

# qhasm: x3 = *(uint32 *) (c + 12)
# asm 1: movl   12(<c=int64#3),>x3=int64#8d
# asm 2: movl   12(<c=%rdx),>x3=%r10d
movl   12(%rdx),%r10d

# qhasm: y0 = *(uint32 *) (in + 0)
# asm 1: movl   0(<in=int64#2),>y0=int64#3d
# asm 2: movl   0(<in=%rsi),>y0=%edx
movl   0(%rsi),%edx

# qhasm: y1 = *(uint32 *) (in + 4)
# asm 1: movl   4(<in=int64#2),>y1=int64#4d
# asm 2: movl   4(<in=%rsi),>y1=%ecx
movl   4(%rsi),%ecx

# qhasm: y2 = *(uint32 *) (in + 8)
# asm 1: movl   8(<in=int64#2),>y2=int64#7d
# asm 2: movl   8(<in=%rsi),>y2=%eax
movl   8(%rsi),%eax

# qhasm: y3 = *(uint32 *) (in + 12)
# asm 1: movl   12(<in=int64#2),>y3=int64#14d
# asm 2: movl   12(<in=%rsi),>y3=%ebx
movl   12(%rsi),%ebx

# qhasm: assign 3 to y0

# qhasm: assign 4 to y1

# qhasm: assign 7 to y2

# qhasm: assign 14 to y3

# qhasm: table = &aes128_amd64_2_tablex
# asm 1: lea  aes128_amd64_2_tablex(%rip),>table=int64#9
# asm 2: lea  aes128_amd64_2_tablex(%rip),>table=%r11
lea  aes128_amd64_2_tablex(%rip),%r11

# qhasm: c = c_stack
# asm 1: movq <c_stack=stack64#1,>c=int64#10
# asm 2: movq <c_stack=0(%rsp),>c=%r12
movq 0(%rsp),%r12

# qhasm: y0 ^= x0
# asm 1: xor  <x0=int64#1,<y0=int64#3
# asm 2: xor  <x0=%rdi,<y0=%rdx
xor  %rdi,%rdx

# qhasm: y1 ^= x1
# asm 1: xor  <x1=int64#5,<y1=int64#4
# asm 2: xor  <x1=%r8,<y1=%rcx
xor  %r8,%rcx

# qhasm: y2 ^= x2
# asm 1: xor  <x2=int64#6,<y2=int64#7
# asm 2: xor  <x2=%r9,<y2=%rax
xor  %r9,%rax

# qhasm: y3 ^= x3
# asm 1: xor  <x3=int64#8,<y3=int64#14
# asm 2: xor  <x3=%r10,<y3=%rbx
xor  %r10,%rbx

# qhasm: x0 = *(uint32 *) (c + 16)
# asm 1: movl   16(<c=int64#10),>x0=int64#2d
# asm 2: movl   16(<c=%r12),>x0=%esi
movl   16(%r12),%esi

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#2,<x1=int64#5
# asm 2: xor  <x0=%rsi,<x1=%r8
xor  %rsi,%r8

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#5,<x2=int64#6
# asm 2: xor  <x1=%r8,<x2=%r9
xor  %r8,%r9

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#6,<x3=int64#8
# asm 2: xor  <x2=%r9,<x3=%r10
xor  %r9,%r10

# qhasm: p00 = y0 & 255
# asm 1: movzbl  <y0=int64#3b,>p00=int64#11d
# asm 2: movzbl  <y0=%dl,>p00=%r13d
movzbl  %dl,%r13d

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#3%next8,>p01=int64#1d
# asm 2: movzbl  <y0=%dh,>p01=%edi
movzbl  %dh,%edi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int64#3d
# asm 2: shr  $16,<y0=%edx
shr  $16,%edx

# qhasm: p02 = y0 & 255
# asm 1: movzbl  <y0=int64#3b,>p02=int64#12d
# asm 2: movzbl  <y0=%dl,>p02=%r14d
movzbl  %dl,%r14d

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#3%next8,>p03=int64#15d
# asm 2: movzbl  <y0=%dh,>p03=%ebp
movzbl  %dh,%ebp

# qhasm: z0 = *(uint32 *) (table + 3 + p00 * 8)
# asm 1: movl   3(<table=int64#9,<p00=int64#11,8),>z0=int64#3d
# asm 2: movl   3(<table=%r11,<p00=%r13,8),>z0=%edx
movl   3(%r11,%r13,8),%edx

# qhasm: assign 3 to z0

# qhasm: z0 ^= x0
# asm 1: xor  <x0=int64#2,<z0=int64#3
# asm 2: xor  <x0=%rsi,<z0=%rdx
xor  %rsi,%rdx

# qhasm: p10 = y1 & 255
# asm 1: movzbl  <y1=int64#4b,>p10=int64#11d
# asm 2: movzbl  <y1=%cl,>p10=%r13d
movzbl  %cl,%r13d

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#4%next8,>p11=int64#2d
# asm 2: movzbl  <y1=%ch,>p11=%esi
movzbl  %ch,%esi

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
# asm 1: xorl 2(<table=int64#9,<p11=int64#2,8),<z0=int64#3d
# asm 2: xorl 2(<table=%r11,<p11=%rsi,8),<z0=%edx
xorl 2(%r11,%rsi,8),%edx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int64#4d
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl  <y1=int64#4b,>p12=int64#13d
# asm 2: movzbl  <y1=%cl,>p12=%r15d
movzbl  %cl,%r15d

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#4%next8,>p13=int64#2d
# asm 2: movzbl  <y1=%ch,>p13=%esi
movzbl  %ch,%esi

# qhasm: z1 = *(uint32 *) (table + 4 + p03 * 8)
# asm 1: movl   4(<table=int64#9,<p03=int64#15,8),>z1=int64#4d
# asm 2: movl   4(<table=%r11,<p03=%rbp,8),>z1=%ecx
movl   4(%r11,%rbp,8),%ecx

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
# asm 1: xorl 3(<table=int64#9,<p10=int64#11,8),<z1=int64#4d
# asm 2: xorl 3(<table=%r11,<p10=%r13,8),<z1=%ecx
xorl 3(%r11,%r13,8),%ecx

# qhasm: assign 4 to z1

# qhasm: p20 = y2 & 255
# asm 1: movzbl  <y2=int64#7b,>p20=int64#11d
# asm 2: movzbl  <y2=%al,>p20=%r13d
movzbl  %al,%r13d

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#7%next8,>p21=int64#15d
# asm 2: movzbl  <y2=%ah,>p21=%ebp
movzbl  %ah,%ebp

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
# asm 1: xorl 2(<table=int64#9,<p21=int64#15,8),<z1=int64#4d
# asm 2: xorl 2(<table=%r11,<p21=%rbp,8),<z1=%ecx
xorl 2(%r11,%rbp,8),%ecx

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int64#7d
# asm 2: shr  $16,<y2=%eax
shr  $16,%eax

# qhasm: p22 = y2 & 255
# asm 1: movzbl  <y2=int64#7b,>p22=int64#15d
# asm 2: movzbl  <y2=%al,>p22=%ebp
movzbl  %al,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
# asm 1: xorl 1(<table=int64#9,<p22=int64#15,8),<z0=int64#3d
# asm 2: xorl 1(<table=%r11,<p22=%rbp,8),<z0=%edx
xorl 1(%r11,%rbp,8),%edx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#7%next8,>p23=int64#15d
# asm 2: movzbl  <y2=%ah,>p23=%ebp
movzbl  %ah,%ebp

# qhasm: z2 = *(uint32 *) (table + 1 + p02 * 8)
# asm 1: movl   1(<table=int64#9,<p02=int64#12,8),>z2=int64#7d
# asm 2: movl   1(<table=%r11,<p02=%r14,8),>z2=%eax
movl   1(%r11,%r14,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
# asm 1: xorl 4(<table=int64#9,<p13=int64#2,8),<z2=int64#7d
# asm 2: xorl 4(<table=%r11,<p13=%rsi,8),<z2=%eax
xorl 4(%r11,%rsi,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
# asm 1: xorl 3(<table=int64#9,<p20=int64#11,8),<z2=int64#7d
# asm 2: xorl 3(<table=%r11,<p20=%r13,8),<z2=%eax
xorl 3(%r11,%r13,8),%eax

# qhasm: assign 7 to z2

# qhasm: p30 = y3 & 255
# asm 1: movzbl  <y3=int64#14b,>p30=int64#11d
# asm 2: movzbl  <y3=%bl,>p30=%r13d
movzbl  %bl,%r13d

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#14%next8,>p31=int64#2d
# asm 2: movzbl  <y3=%bh,>p31=%esi
movzbl  %bh,%esi

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
# asm 1: xorl 2(<table=int64#9,<p31=int64#2,8),<z2=int64#7d
# asm 2: xorl 2(<table=%r11,<p31=%rsi,8),<z2=%eax
xorl 2(%r11,%rsi,8),%eax

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int64#14d
# asm 2: shr  $16,<y3=%ebx
shr  $16,%ebx

# qhasm: p32 = y3 & 255
# asm 1: movzbl  <y3=int64#14b,>p32=int64#2d
# asm 2: movzbl  <y3=%bl,>p32=%esi
movzbl  %bl,%esi

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
# asm 1: xorl 1(<table=int64#9,<p32=int64#2,8),<z1=int64#4d
# asm 2: xorl 1(<table=%r11,<p32=%rsi,8),<z1=%ecx
xorl 1(%r11,%rsi,8),%ecx

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#14%next8,>p33=int64#14d
# asm 2: movzbl  <y3=%bh,>p33=%ebx
movzbl  %bh,%ebx

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
# asm 1: xorl 4(<table=int64#9,<p33=int64#14,8),<z0=int64#3d
# asm 2: xorl 4(<table=%r11,<p33=%rbx,8),<z0=%edx
xorl 4(%r11,%rbx,8),%edx

# qhasm: z3 = *(uint32 *) (table + 2 + p01 * 8)
# asm 1: movl   2(<table=int64#9,<p01=int64#1,8),>z3=int64#14d
# asm 2: movl   2(<table=%r11,<p01=%rdi,8),>z3=%ebx
movl   2(%r11,%rdi,8),%ebx

# qhasm: z2 ^= x2
# asm 1: xor  <x2=int64#6,<z2=int64#7
# asm 2: xor  <x2=%r9,<z2=%rax
xor  %r9,%rax

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
# asm 1: xorl 1(<table=int64#9,<p12=int64#13,8),<z3=int64#14d
# asm 2: xorl 1(<table=%r11,<p12=%r15,8),<z3=%ebx
xorl 1(%r11,%r15,8),%ebx

# qhasm: z1 ^= x1
# asm 1: xor  <x1=int64#5,<z1=int64#4
# asm 2: xor  <x1=%r8,<z1=%rcx
xor  %r8,%rcx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
# asm 1: xorl 4(<table=int64#9,<p23=int64#15,8),<z3=int64#14d
# asm 2: xorl 4(<table=%r11,<p23=%rbp,8),<z3=%ebx
xorl 4(%r11,%rbp,8),%ebx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
# asm 1: xorl 3(<table=int64#9,<p30=int64#11,8),<z3=int64#14d
# asm 2: xorl 3(<table=%r11,<p30=%r13,8),<z3=%ebx
xorl 3(%r11,%r13,8),%ebx

# qhasm: z3 ^= x3
# asm 1: xor  <x3=int64#8,<z3=int64#14
# asm 2: xor  <x3=%r10,<z3=%rbx
xor  %r10,%rbx

# qhasm: assign 14 to z3

# qhasm: x0 = *(uint32 *) (c + 20)
# asm 1: movl   20(<c=int64#10),>x0=int64#2d
# asm 2: movl   20(<c=%r12),>x0=%esi
movl   20(%r12),%esi

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#2,<x1=int64#5
# asm 2: xor  <x0=%rsi,<x1=%r8
xor  %rsi,%r8

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#5,<x2=int64#6
# asm 2: xor  <x1=%r8,<x2=%r9
xor  %r8,%r9

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#6,<x3=int64#8
# asm 2: xor  <x2=%r9,<x3=%r10
xor  %r9,%r10

# qhasm: q00 = z0 & 255
# asm 1: movzbl  <z0=int64#3b,>q00=int64#11d
# asm 2: movzbl  <z0=%dl,>q00=%r13d
movzbl  %dl,%r13d

# qhasm: q03 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#3%next8,>q03=int64#1d
# asm 2: movzbl  <z0=%dh,>q03=%edi
movzbl  %dh,%edi

# qhasm: (uint32) z0 >>= 16
# asm 1: shr  $16,<z0=int64#3d
# asm 2: shr  $16,<z0=%edx
shr  $16,%edx

# qhasm: q02 = z0 & 255
# asm 1: movzbl  <z0=int64#3b,>q02=int64#12d
# asm 2: movzbl  <z0=%dl,>q02=%r14d
movzbl  %dl,%r14d

# qhasm: q01 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#3%next8,>q01=int64#15d
# asm 2: movzbl  <z0=%dh,>q01=%ebp
movzbl  %dh,%ebp

# qhasm: y0 = *(uint32 *) (table + 3 + q00 * 8)
# asm 1: movl   3(<table=int64#9,<q00=int64#11,8),>y0=int64#3d
# asm 2: movl   3(<table=%r11,<q00=%r13,8),>y0=%edx
movl   3(%r11,%r13,8),%edx

# qhasm: assign 3 to y0

# qhasm: y0 ^= x0
# asm 1: xor  <x0=int64#2,<y0=int64#3
# asm 2: xor  <x0=%rsi,<y0=%rdx
xor  %rsi,%rdx

# qhasm: q10 = z1 & 255
# asm 1: movzbl  <z1=int64#4b,>q10=int64#11d
# asm 2: movzbl  <z1=%cl,>q10=%r13d
movzbl  %cl,%r13d

# qhasm: q11 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#4%next8,>q11=int64#2d
# asm 2: movzbl  <z1=%ch,>q11=%esi
movzbl  %ch,%esi

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 2 + q11 * 8)
# asm 1: xorl 2(<table=int64#9,<q11=int64#2,8),<y0=int64#3d
# asm 2: xorl 2(<table=%r11,<q11=%rsi,8),<y0=%edx
xorl 2(%r11,%rsi,8),%edx

# qhasm: (uint32) z1 >>= 16
# asm 1: shr  $16,<z1=int64#4d
# asm 2: shr  $16,<z1=%ecx
shr  $16,%ecx

# qhasm: q12 = z1 & 255
# asm 1: movzbl  <z1=int64#4b,>q12=int64#13d
# asm 2: movzbl  <z1=%cl,>q12=%r15d
movzbl  %cl,%r15d

# qhasm: q13 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#4%next8,>q13=int64#2d
# asm 2: movzbl  <z1=%ch,>q13=%esi
movzbl  %ch,%esi

# qhasm: y1 = *(uint32 *) (table + 4 + q01 * 8)
# asm 1: movl   4(<table=int64#9,<q01=int64#15,8),>y1=int64#4d
# asm 2: movl   4(<table=%r11,<q01=%rbp,8),>y1=%ecx
movl   4(%r11,%rbp,8),%ecx

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 3 + q10 * 8)
# asm 1: xorl 3(<table=int64#9,<q10=int64#11,8),<y1=int64#4d
# asm 2: xorl 3(<table=%r11,<q10=%r13,8),<y1=%ecx
xorl 3(%r11,%r13,8),%ecx

# qhasm: assign 4 to y1

# qhasm: q20 = z2 & 255
# asm 1: movzbl  <z2=int64#7b,>q20=int64#11d
# asm 2: movzbl  <z2=%al,>q20=%r13d
movzbl  %al,%r13d

# qhasm: q21 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#7%next8,>q21=int64#15d
# asm 2: movzbl  <z2=%ah,>q21=%ebp
movzbl  %ah,%ebp

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 2 + q21 * 8)
# asm 1: xorl 2(<table=int64#9,<q21=int64#15,8),<y1=int64#4d
# asm 2: xorl 2(<table=%r11,<q21=%rbp,8),<y1=%ecx
xorl 2(%r11,%rbp,8),%ecx

# qhasm: (uint32) z2 >>= 16
# asm 1: shr  $16,<z2=int64#7d
# asm 2: shr  $16,<z2=%eax
shr  $16,%eax

# qhasm: q22 = z2 & 255
# asm 1: movzbl  <z2=int64#7b,>q22=int64#15d
# asm 2: movzbl  <z2=%al,>q22=%ebp
movzbl  %al,%ebp

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 1 + q22 * 8)
# asm 1: xorl 1(<table=int64#9,<q22=int64#15,8),<y0=int64#3d
# asm 2: xorl 1(<table=%r11,<q22=%rbp,8),<y0=%edx
xorl 1(%r11,%rbp,8),%edx

# qhasm: q23 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#7%next8,>q23=int64#15d
# asm 2: movzbl  <z2=%ah,>q23=%ebp
movzbl  %ah,%ebp

# qhasm: y2 = *(uint32 *) (table + 1 + q02 * 8)
# asm 1: movl   1(<table=int64#9,<q02=int64#12,8),>y2=int64#7d
# asm 2: movl   1(<table=%r11,<q02=%r14,8),>y2=%eax
movl   1(%r11,%r14,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 4 + q13 * 8)
# asm 1: xorl 4(<table=int64#9,<q13=int64#2,8),<y2=int64#7d
# asm 2: xorl 4(<table=%r11,<q13=%rsi,8),<y2=%eax
xorl 4(%r11,%rsi,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 3 + q20 * 8)
# asm 1: xorl 3(<table=int64#9,<q20=int64#11,8),<y2=int64#7d
# asm 2: xorl 3(<table=%r11,<q20=%r13,8),<y2=%eax
xorl 3(%r11,%r13,8),%eax

# qhasm: assign 7 to y2

# qhasm: q30 = z3 & 255
# asm 1: movzbl  <z3=int64#14b,>q30=int64#11d
# asm 2: movzbl  <z3=%bl,>q30=%r13d
movzbl  %bl,%r13d

# qhasm: q31 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#14%next8,>q31=int64#2d
# asm 2: movzbl  <z3=%bh,>q31=%esi
movzbl  %bh,%esi

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 2 + q31 * 8)
# asm 1: xorl 2(<table=int64#9,<q31=int64#2,8),<y2=int64#7d
# asm 2: xorl 2(<table=%r11,<q31=%rsi,8),<y2=%eax
xorl 2(%r11,%rsi,8),%eax

# qhasm: (uint32) z3 >>= 16
# asm 1: shr  $16,<z3=int64#14d
# asm 2: shr  $16,<z3=%ebx
shr  $16,%ebx

# qhasm: q32 = z3 & 255
# asm 1: movzbl  <z3=int64#14b,>q32=int64#2d
# asm 2: movzbl  <z3=%bl,>q32=%esi
movzbl  %bl,%esi

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 1 + q32 * 8)
# asm 1: xorl 1(<table=int64#9,<q32=int64#2,8),<y1=int64#4d
# asm 2: xorl 1(<table=%r11,<q32=%rsi,8),<y1=%ecx
xorl 1(%r11,%rsi,8),%ecx

# qhasm: q33 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#14%next8,>q33=int64#14d
# asm 2: movzbl  <z3=%bh,>q33=%ebx
movzbl  %bh,%ebx

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 4 + q33 * 8)
# asm 1: xorl 4(<table=int64#9,<q33=int64#14,8),<y0=int64#3d
# asm 2: xorl 4(<table=%r11,<q33=%rbx,8),<y0=%edx
xorl 4(%r11,%rbx,8),%edx

# qhasm: y3 = *(uint32 *) (table + 2 + q03 * 8)
# asm 1: movl   2(<table=int64#9,<q03=int64#1,8),>y3=int64#14d
# asm 2: movl   2(<table=%r11,<q03=%rdi,8),>y3=%ebx
movl   2(%r11,%rdi,8),%ebx

# qhasm: y2 ^= x2
# asm 1: xor  <x2=int64#6,<y2=int64#7
# asm 2: xor  <x2=%r9,<y2=%rax
xor  %r9,%rax

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 1 + q12 * 8)
# asm 1: xorl 1(<table=int64#9,<q12=int64#13,8),<y3=int64#14d
# asm 2: xorl 1(<table=%r11,<q12=%r15,8),<y3=%ebx
xorl 1(%r11,%r15,8),%ebx

# qhasm: y1 ^= x1
# asm 1: xor  <x1=int64#5,<y1=int64#4
# asm 2: xor  <x1=%r8,<y1=%rcx
xor  %r8,%rcx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 4 + q23 * 8)
# asm 1: xorl 4(<table=int64#9,<q23=int64#15,8),<y3=int64#14d
# asm 2: xorl 4(<table=%r11,<q23=%rbp,8),<y3=%ebx
xorl 4(%r11,%rbp,8),%ebx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 3 + q30 * 8)
# asm 1: xorl 3(<table=int64#9,<q30=int64#11,8),<y3=int64#14d
# asm 2: xorl 3(<table=%r11,<q30=%r13,8),<y3=%ebx
xorl 3(%r11,%r13,8),%ebx

# qhasm: y3 ^= x3
# asm 1: xor  <x3=int64#8,<y3=int64#14
# asm 2: xor  <x3=%r10,<y3=%rbx
xor  %r10,%rbx

# qhasm: assign 14 to y3

# qhasm: x0 = *(uint32 *) (c + 24)
# asm 1: movl   24(<c=int64#10),>x0=int64#2d
# asm 2: movl   24(<c=%r12),>x0=%esi
movl   24(%r12),%esi

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#2,<x1=int64#5
# asm 2: xor  <x0=%rsi,<x1=%r8
xor  %rsi,%r8

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#5,<x2=int64#6
# asm 2: xor  <x1=%r8,<x2=%r9
xor  %r8,%r9

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#6,<x3=int64#8
# asm 2: xor  <x2=%r9,<x3=%r10
xor  %r9,%r10

# qhasm: p00 = y0 & 255
# asm 1: movzbl  <y0=int64#3b,>p00=int64#11d
# asm 2: movzbl  <y0=%dl,>p00=%r13d
movzbl  %dl,%r13d

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#3%next8,>p01=int64#1d
# asm 2: movzbl  <y0=%dh,>p01=%edi
movzbl  %dh,%edi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int64#3d
# asm 2: shr  $16,<y0=%edx
shr  $16,%edx

# qhasm: p02 = y0 & 255
# asm 1: movzbl  <y0=int64#3b,>p02=int64#12d
# asm 2: movzbl  <y0=%dl,>p02=%r14d
movzbl  %dl,%r14d

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#3%next8,>p03=int64#15d
# asm 2: movzbl  <y0=%dh,>p03=%ebp
movzbl  %dh,%ebp

# qhasm: z0 = *(uint32 *) (table + 3 + p00 * 8)
# asm 1: movl   3(<table=int64#9,<p00=int64#11,8),>z0=int64#3d
# asm 2: movl   3(<table=%r11,<p00=%r13,8),>z0=%edx
movl   3(%r11,%r13,8),%edx

# qhasm: assign 3 to z0

# qhasm: z0 ^= x0
# asm 1: xor  <x0=int64#2,<z0=int64#3
# asm 2: xor  <x0=%rsi,<z0=%rdx
xor  %rsi,%rdx

# qhasm: p10 = y1 & 255
# asm 1: movzbl  <y1=int64#4b,>p10=int64#11d
# asm 2: movzbl  <y1=%cl,>p10=%r13d
movzbl  %cl,%r13d

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#4%next8,>p11=int64#2d
# asm 2: movzbl  <y1=%ch,>p11=%esi
movzbl  %ch,%esi

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
# asm 1: xorl 2(<table=int64#9,<p11=int64#2,8),<z0=int64#3d
# asm 2: xorl 2(<table=%r11,<p11=%rsi,8),<z0=%edx
xorl 2(%r11,%rsi,8),%edx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int64#4d
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl  <y1=int64#4b,>p12=int64#13d
# asm 2: movzbl  <y1=%cl,>p12=%r15d
movzbl  %cl,%r15d

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#4%next8,>p13=int64#2d
# asm 2: movzbl  <y1=%ch,>p13=%esi
movzbl  %ch,%esi

# qhasm: z1 = *(uint32 *) (table + 4 + p03 * 8)
# asm 1: movl   4(<table=int64#9,<p03=int64#15,8),>z1=int64#4d
# asm 2: movl   4(<table=%r11,<p03=%rbp,8),>z1=%ecx
movl   4(%r11,%rbp,8),%ecx

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
# asm 1: xorl 3(<table=int64#9,<p10=int64#11,8),<z1=int64#4d
# asm 2: xorl 3(<table=%r11,<p10=%r13,8),<z1=%ecx
xorl 3(%r11,%r13,8),%ecx

# qhasm: assign 4 to z1

# qhasm: p20 = y2 & 255
# asm 1: movzbl  <y2=int64#7b,>p20=int64#11d
# asm 2: movzbl  <y2=%al,>p20=%r13d
movzbl  %al,%r13d

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#7%next8,>p21=int64#15d
# asm 2: movzbl  <y2=%ah,>p21=%ebp
movzbl  %ah,%ebp

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
# asm 1: xorl 2(<table=int64#9,<p21=int64#15,8),<z1=int64#4d
# asm 2: xorl 2(<table=%r11,<p21=%rbp,8),<z1=%ecx
xorl 2(%r11,%rbp,8),%ecx

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int64#7d
# asm 2: shr  $16,<y2=%eax
shr  $16,%eax

# qhasm: p22 = y2 & 255
# asm 1: movzbl  <y2=int64#7b,>p22=int64#15d
# asm 2: movzbl  <y2=%al,>p22=%ebp
movzbl  %al,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
# asm 1: xorl 1(<table=int64#9,<p22=int64#15,8),<z0=int64#3d
# asm 2: xorl 1(<table=%r11,<p22=%rbp,8),<z0=%edx
xorl 1(%r11,%rbp,8),%edx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#7%next8,>p23=int64#15d
# asm 2: movzbl  <y2=%ah,>p23=%ebp
movzbl  %ah,%ebp

# qhasm: z2 = *(uint32 *) (table + 1 + p02 * 8)
# asm 1: movl   1(<table=int64#9,<p02=int64#12,8),>z2=int64#7d
# asm 2: movl   1(<table=%r11,<p02=%r14,8),>z2=%eax
movl   1(%r11,%r14,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
# asm 1: xorl 4(<table=int64#9,<p13=int64#2,8),<z2=int64#7d
# asm 2: xorl 4(<table=%r11,<p13=%rsi,8),<z2=%eax
xorl 4(%r11,%rsi,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
# asm 1: xorl 3(<table=int64#9,<p20=int64#11,8),<z2=int64#7d
# asm 2: xorl 3(<table=%r11,<p20=%r13,8),<z2=%eax
xorl 3(%r11,%r13,8),%eax

# qhasm: assign 7 to z2

# qhasm: p30 = y3 & 255
# asm 1: movzbl  <y3=int64#14b,>p30=int64#11d
# asm 2: movzbl  <y3=%bl,>p30=%r13d
movzbl  %bl,%r13d

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#14%next8,>p31=int64#2d
# asm 2: movzbl  <y3=%bh,>p31=%esi
movzbl  %bh,%esi

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
# asm 1: xorl 2(<table=int64#9,<p31=int64#2,8),<z2=int64#7d
# asm 2: xorl 2(<table=%r11,<p31=%rsi,8),<z2=%eax
xorl 2(%r11,%rsi,8),%eax

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int64#14d
# asm 2: shr  $16,<y3=%ebx
shr  $16,%ebx

# qhasm: p32 = y3 & 255
# asm 1: movzbl  <y3=int64#14b,>p32=int64#2d
# asm 2: movzbl  <y3=%bl,>p32=%esi
movzbl  %bl,%esi

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
# asm 1: xorl 1(<table=int64#9,<p32=int64#2,8),<z1=int64#4d
# asm 2: xorl 1(<table=%r11,<p32=%rsi,8),<z1=%ecx
xorl 1(%r11,%rsi,8),%ecx

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#14%next8,>p33=int64#14d
# asm 2: movzbl  <y3=%bh,>p33=%ebx
movzbl  %bh,%ebx

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
# asm 1: xorl 4(<table=int64#9,<p33=int64#14,8),<z0=int64#3d
# asm 2: xorl 4(<table=%r11,<p33=%rbx,8),<z0=%edx
xorl 4(%r11,%rbx,8),%edx

# qhasm: z3 = *(uint32 *) (table + 2 + p01 * 8)
# asm 1: movl   2(<table=int64#9,<p01=int64#1,8),>z3=int64#14d
# asm 2: movl   2(<table=%r11,<p01=%rdi,8),>z3=%ebx
movl   2(%r11,%rdi,8),%ebx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
# asm 1: xorl 1(<table=int64#9,<p12=int64#13,8),<z3=int64#14d
# asm 2: xorl 1(<table=%r11,<p12=%r15,8),<z3=%ebx
xorl 1(%r11,%r15,8),%ebx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
# asm 1: xorl 4(<table=int64#9,<p23=int64#15,8),<z3=int64#14d
# asm 2: xorl 4(<table=%r11,<p23=%rbp,8),<z3=%ebx
xorl 4(%r11,%rbp,8),%ebx

# qhasm: z1 ^= x1
# asm 1: xor  <x1=int64#5,<z1=int64#4
# asm 2: xor  <x1=%r8,<z1=%rcx
xor  %r8,%rcx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
# asm 1: xorl 3(<table=int64#9,<p30=int64#11,8),<z3=int64#14d
# asm 2: xorl 3(<table=%r11,<p30=%r13,8),<z3=%ebx
xorl 3(%r11,%r13,8),%ebx

# qhasm: assign 14 to z3

# qhasm: z2 ^= x2
# asm 1: xor  <x2=int64#6,<z2=int64#7
# asm 2: xor  <x2=%r9,<z2=%rax
xor  %r9,%rax

# qhasm: z3 ^= x3
# asm 1: xor  <x3=int64#8,<z3=int64#14
# asm 2: xor  <x3=%r10,<z3=%rbx
xor  %r10,%rbx

# qhasm: x0 = *(uint32 *) (c + 28)
# asm 1: movl   28(<c=int64#10),>x0=int64#2d
# asm 2: movl   28(<c=%r12),>x0=%esi
movl   28(%r12),%esi

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#2,<x1=int64#5
# asm 2: xor  <x0=%rsi,<x1=%r8
xor  %rsi,%r8

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#5,<x2=int64#6
# asm 2: xor  <x1=%r8,<x2=%r9
xor  %r8,%r9

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#6,<x3=int64#8
# asm 2: xor  <x2=%r9,<x3=%r10
xor  %r9,%r10

# qhasm: q00 = z0 & 255
# asm 1: movzbl  <z0=int64#3b,>q00=int64#11d
# asm 2: movzbl  <z0=%dl,>q00=%r13d
movzbl  %dl,%r13d

# qhasm: q03 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#3%next8,>q03=int64#1d
# asm 2: movzbl  <z0=%dh,>q03=%edi
movzbl  %dh,%edi

# qhasm: (uint32) z0 >>= 16
# asm 1: shr  $16,<z0=int64#3d
# asm 2: shr  $16,<z0=%edx
shr  $16,%edx

# qhasm: q02 = z0 & 255
# asm 1: movzbl  <z0=int64#3b,>q02=int64#12d
# asm 2: movzbl  <z0=%dl,>q02=%r14d
movzbl  %dl,%r14d

# qhasm: q01 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#3%next8,>q01=int64#15d
# asm 2: movzbl  <z0=%dh,>q01=%ebp
movzbl  %dh,%ebp

# qhasm: y0 = *(uint32 *) (table + 3 + q00 * 8)
# asm 1: movl   3(<table=int64#9,<q00=int64#11,8),>y0=int64#3d
# asm 2: movl   3(<table=%r11,<q00=%r13,8),>y0=%edx
movl   3(%r11,%r13,8),%edx

# qhasm: assign 3 to y0

# qhasm: y0 ^= x0
# asm 1: xor  <x0=int64#2,<y0=int64#3
# asm 2: xor  <x0=%rsi,<y0=%rdx
xor  %rsi,%rdx

# qhasm: q10 = z1 & 255
# asm 1: movzbl  <z1=int64#4b,>q10=int64#11d
# asm 2: movzbl  <z1=%cl,>q10=%r13d
movzbl  %cl,%r13d

# qhasm: q11 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#4%next8,>q11=int64#2d
# asm 2: movzbl  <z1=%ch,>q11=%esi
movzbl  %ch,%esi

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 2 + q11 * 8)
# asm 1: xorl 2(<table=int64#9,<q11=int64#2,8),<y0=int64#3d
# asm 2: xorl 2(<table=%r11,<q11=%rsi,8),<y0=%edx
xorl 2(%r11,%rsi,8),%edx

# qhasm: (uint32) z1 >>= 16
# asm 1: shr  $16,<z1=int64#4d
# asm 2: shr  $16,<z1=%ecx
shr  $16,%ecx

# qhasm: q12 = z1 & 255
# asm 1: movzbl  <z1=int64#4b,>q12=int64#13d
# asm 2: movzbl  <z1=%cl,>q12=%r15d
movzbl  %cl,%r15d

# qhasm: q13 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#4%next8,>q13=int64#2d
# asm 2: movzbl  <z1=%ch,>q13=%esi
movzbl  %ch,%esi

# qhasm: y1 = *(uint32 *) (table + 4 + q01 * 8)
# asm 1: movl   4(<table=int64#9,<q01=int64#15,8),>y1=int64#4d
# asm 2: movl   4(<table=%r11,<q01=%rbp,8),>y1=%ecx
movl   4(%r11,%rbp,8),%ecx

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 3 + q10 * 8)
# asm 1: xorl 3(<table=int64#9,<q10=int64#11,8),<y1=int64#4d
# asm 2: xorl 3(<table=%r11,<q10=%r13,8),<y1=%ecx
xorl 3(%r11,%r13,8),%ecx

# qhasm: assign 4 to y1

# qhasm: q20 = z2 & 255
# asm 1: movzbl  <z2=int64#7b,>q20=int64#11d
# asm 2: movzbl  <z2=%al,>q20=%r13d
movzbl  %al,%r13d

# qhasm: q21 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#7%next8,>q21=int64#15d
# asm 2: movzbl  <z2=%ah,>q21=%ebp
movzbl  %ah,%ebp

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 2 + q21 * 8)
# asm 1: xorl 2(<table=int64#9,<q21=int64#15,8),<y1=int64#4d
# asm 2: xorl 2(<table=%r11,<q21=%rbp,8),<y1=%ecx
xorl 2(%r11,%rbp,8),%ecx

# qhasm: (uint32) z2 >>= 16
# asm 1: shr  $16,<z2=int64#7d
# asm 2: shr  $16,<z2=%eax
shr  $16,%eax

# qhasm: q22 = z2 & 255
# asm 1: movzbl  <z2=int64#7b,>q22=int64#15d
# asm 2: movzbl  <z2=%al,>q22=%ebp
movzbl  %al,%ebp

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 1 + q22 * 8)
# asm 1: xorl 1(<table=int64#9,<q22=int64#15,8),<y0=int64#3d
# asm 2: xorl 1(<table=%r11,<q22=%rbp,8),<y0=%edx
xorl 1(%r11,%rbp,8),%edx

# qhasm: q23 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#7%next8,>q23=int64#15d
# asm 2: movzbl  <z2=%ah,>q23=%ebp
movzbl  %ah,%ebp

# qhasm: y2 = *(uint32 *) (table + 1 + q02 * 8)
# asm 1: movl   1(<table=int64#9,<q02=int64#12,8),>y2=int64#7d
# asm 2: movl   1(<table=%r11,<q02=%r14,8),>y2=%eax
movl   1(%r11,%r14,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 4 + q13 * 8)
# asm 1: xorl 4(<table=int64#9,<q13=int64#2,8),<y2=int64#7d
# asm 2: xorl 4(<table=%r11,<q13=%rsi,8),<y2=%eax
xorl 4(%r11,%rsi,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 3 + q20 * 8)
# asm 1: xorl 3(<table=int64#9,<q20=int64#11,8),<y2=int64#7d
# asm 2: xorl 3(<table=%r11,<q20=%r13,8),<y2=%eax
xorl 3(%r11,%r13,8),%eax

# qhasm: assign 7 to y2

# qhasm: q30 = z3 & 255
# asm 1: movzbl  <z3=int64#14b,>q30=int64#11d
# asm 2: movzbl  <z3=%bl,>q30=%r13d
movzbl  %bl,%r13d

# qhasm: q31 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#14%next8,>q31=int64#2d
# asm 2: movzbl  <z3=%bh,>q31=%esi
movzbl  %bh,%esi

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 2 + q31 * 8)
# asm 1: xorl 2(<table=int64#9,<q31=int64#2,8),<y2=int64#7d
# asm 2: xorl 2(<table=%r11,<q31=%rsi,8),<y2=%eax
xorl 2(%r11,%rsi,8),%eax

# qhasm: (uint32) z3 >>= 16
# asm 1: shr  $16,<z3=int64#14d
# asm 2: shr  $16,<z3=%ebx
shr  $16,%ebx

# qhasm: q32 = z3 & 255
# asm 1: movzbl  <z3=int64#14b,>q32=int64#2d
# asm 2: movzbl  <z3=%bl,>q32=%esi
movzbl  %bl,%esi

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 1 + q32 * 8)
# asm 1: xorl 1(<table=int64#9,<q32=int64#2,8),<y1=int64#4d
# asm 2: xorl 1(<table=%r11,<q32=%rsi,8),<y1=%ecx
xorl 1(%r11,%rsi,8),%ecx

# qhasm: q33 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#14%next8,>q33=int64#14d
# asm 2: movzbl  <z3=%bh,>q33=%ebx
movzbl  %bh,%ebx

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 4 + q33 * 8)
# asm 1: xorl 4(<table=int64#9,<q33=int64#14,8),<y0=int64#3d
# asm 2: xorl 4(<table=%r11,<q33=%rbx,8),<y0=%edx
xorl 4(%r11,%rbx,8),%edx

# qhasm: y3 = *(uint32 *) (table + 2 + q03 * 8)
# asm 1: movl   2(<table=int64#9,<q03=int64#1,8),>y3=int64#14d
# asm 2: movl   2(<table=%r11,<q03=%rdi,8),>y3=%ebx
movl   2(%r11,%rdi,8),%ebx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 1 + q12 * 8)
# asm 1: xorl 1(<table=int64#9,<q12=int64#13,8),<y3=int64#14d
# asm 2: xorl 1(<table=%r11,<q12=%r15,8),<y3=%ebx
xorl 1(%r11,%r15,8),%ebx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 4 + q23 * 8)
# asm 1: xorl 4(<table=int64#9,<q23=int64#15,8),<y3=int64#14d
# asm 2: xorl 4(<table=%r11,<q23=%rbp,8),<y3=%ebx
xorl 4(%r11,%rbp,8),%ebx

# qhasm: y1 ^= x1
# asm 1: xor  <x1=int64#5,<y1=int64#4
# asm 2: xor  <x1=%r8,<y1=%rcx
xor  %r8,%rcx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 3 + q30 * 8)
# asm 1: xorl 3(<table=int64#9,<q30=int64#11,8),<y3=int64#14d
# asm 2: xorl 3(<table=%r11,<q30=%r13,8),<y3=%ebx
xorl 3(%r11,%r13,8),%ebx

# qhasm: assign 14 to y3

# qhasm: y2 ^= x2
# asm 1: xor  <x2=int64#6,<y2=int64#7
# asm 2: xor  <x2=%r9,<y2=%rax
xor  %r9,%rax

# qhasm: y3 ^= x3
# asm 1: xor  <x3=int64#8,<y3=int64#14
# asm 2: xor  <x3=%r10,<y3=%rbx
xor  %r10,%rbx

# qhasm: x0 = *(uint32 *) (c + 32)
# asm 1: movl   32(<c=int64#10),>x0=int64#2d
# asm 2: movl   32(<c=%r12),>x0=%esi
movl   32(%r12),%esi

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#2,<x1=int64#5
# asm 2: xor  <x0=%rsi,<x1=%r8
xor  %rsi,%r8

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#5,<x2=int64#6
# asm 2: xor  <x1=%r8,<x2=%r9
xor  %r8,%r9

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#6,<x3=int64#8
# asm 2: xor  <x2=%r9,<x3=%r10
xor  %r9,%r10

# qhasm: p00 = y0 & 255
# asm 1: movzbl  <y0=int64#3b,>p00=int64#11d
# asm 2: movzbl  <y0=%dl,>p00=%r13d
movzbl  %dl,%r13d

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#3%next8,>p01=int64#1d
# asm 2: movzbl  <y0=%dh,>p01=%edi
movzbl  %dh,%edi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int64#3d
# asm 2: shr  $16,<y0=%edx
shr  $16,%edx

# qhasm: p02 = y0 & 255
# asm 1: movzbl  <y0=int64#3b,>p02=int64#12d
# asm 2: movzbl  <y0=%dl,>p02=%r14d
movzbl  %dl,%r14d

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#3%next8,>p03=int64#15d
# asm 2: movzbl  <y0=%dh,>p03=%ebp
movzbl  %dh,%ebp

# qhasm: z0 = *(uint32 *) (table + 3 + p00 * 8)
# asm 1: movl   3(<table=int64#9,<p00=int64#11,8),>z0=int64#3d
# asm 2: movl   3(<table=%r11,<p00=%r13,8),>z0=%edx
movl   3(%r11,%r13,8),%edx

# qhasm: assign 3 to z0

# qhasm: z0 ^= x0
# asm 1: xor  <x0=int64#2,<z0=int64#3
# asm 2: xor  <x0=%rsi,<z0=%rdx
xor  %rsi,%rdx

# qhasm: p10 = y1 & 255
# asm 1: movzbl  <y1=int64#4b,>p10=int64#11d
# asm 2: movzbl  <y1=%cl,>p10=%r13d
movzbl  %cl,%r13d

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#4%next8,>p11=int64#2d
# asm 2: movzbl  <y1=%ch,>p11=%esi
movzbl  %ch,%esi

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
# asm 1: xorl 2(<table=int64#9,<p11=int64#2,8),<z0=int64#3d
# asm 2: xorl 2(<table=%r11,<p11=%rsi,8),<z0=%edx
xorl 2(%r11,%rsi,8),%edx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int64#4d
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl  <y1=int64#4b,>p12=int64#13d
# asm 2: movzbl  <y1=%cl,>p12=%r15d
movzbl  %cl,%r15d

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#4%next8,>p13=int64#2d
# asm 2: movzbl  <y1=%ch,>p13=%esi
movzbl  %ch,%esi

# qhasm: z1 = *(uint32 *) (table + 4 + p03 * 8)
# asm 1: movl   4(<table=int64#9,<p03=int64#15,8),>z1=int64#4d
# asm 2: movl   4(<table=%r11,<p03=%rbp,8),>z1=%ecx
movl   4(%r11,%rbp,8),%ecx

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
# asm 1: xorl 3(<table=int64#9,<p10=int64#11,8),<z1=int64#4d
# asm 2: xorl 3(<table=%r11,<p10=%r13,8),<z1=%ecx
xorl 3(%r11,%r13,8),%ecx

# qhasm: assign 4 to z1

# qhasm: p20 = y2 & 255
# asm 1: movzbl  <y2=int64#7b,>p20=int64#11d
# asm 2: movzbl  <y2=%al,>p20=%r13d
movzbl  %al,%r13d

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#7%next8,>p21=int64#15d
# asm 2: movzbl  <y2=%ah,>p21=%ebp
movzbl  %ah,%ebp

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
# asm 1: xorl 2(<table=int64#9,<p21=int64#15,8),<z1=int64#4d
# asm 2: xorl 2(<table=%r11,<p21=%rbp,8),<z1=%ecx
xorl 2(%r11,%rbp,8),%ecx

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int64#7d
# asm 2: shr  $16,<y2=%eax
shr  $16,%eax

# qhasm: p22 = y2 & 255
# asm 1: movzbl  <y2=int64#7b,>p22=int64#15d
# asm 2: movzbl  <y2=%al,>p22=%ebp
movzbl  %al,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
# asm 1: xorl 1(<table=int64#9,<p22=int64#15,8),<z0=int64#3d
# asm 2: xorl 1(<table=%r11,<p22=%rbp,8),<z0=%edx
xorl 1(%r11,%rbp,8),%edx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#7%next8,>p23=int64#15d
# asm 2: movzbl  <y2=%ah,>p23=%ebp
movzbl  %ah,%ebp

# qhasm: z2 = *(uint32 *) (table + 1 + p02 * 8)
# asm 1: movl   1(<table=int64#9,<p02=int64#12,8),>z2=int64#7d
# asm 2: movl   1(<table=%r11,<p02=%r14,8),>z2=%eax
movl   1(%r11,%r14,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
# asm 1: xorl 4(<table=int64#9,<p13=int64#2,8),<z2=int64#7d
# asm 2: xorl 4(<table=%r11,<p13=%rsi,8),<z2=%eax
xorl 4(%r11,%rsi,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
# asm 1: xorl 3(<table=int64#9,<p20=int64#11,8),<z2=int64#7d
# asm 2: xorl 3(<table=%r11,<p20=%r13,8),<z2=%eax
xorl 3(%r11,%r13,8),%eax

# qhasm: assign 7 to z2

# qhasm: p30 = y3 & 255
# asm 1: movzbl  <y3=int64#14b,>p30=int64#11d
# asm 2: movzbl  <y3=%bl,>p30=%r13d
movzbl  %bl,%r13d

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#14%next8,>p31=int64#2d
# asm 2: movzbl  <y3=%bh,>p31=%esi
movzbl  %bh,%esi

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
# asm 1: xorl 2(<table=int64#9,<p31=int64#2,8),<z2=int64#7d
# asm 2: xorl 2(<table=%r11,<p31=%rsi,8),<z2=%eax
xorl 2(%r11,%rsi,8),%eax

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int64#14d
# asm 2: shr  $16,<y3=%ebx
shr  $16,%ebx

# qhasm: p32 = y3 & 255
# asm 1: movzbl  <y3=int64#14b,>p32=int64#2d
# asm 2: movzbl  <y3=%bl,>p32=%esi
movzbl  %bl,%esi

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
# asm 1: xorl 1(<table=int64#9,<p32=int64#2,8),<z1=int64#4d
# asm 2: xorl 1(<table=%r11,<p32=%rsi,8),<z1=%ecx
xorl 1(%r11,%rsi,8),%ecx

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#14%next8,>p33=int64#14d
# asm 2: movzbl  <y3=%bh,>p33=%ebx
movzbl  %bh,%ebx

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
# asm 1: xorl 4(<table=int64#9,<p33=int64#14,8),<z0=int64#3d
# asm 2: xorl 4(<table=%r11,<p33=%rbx,8),<z0=%edx
xorl 4(%r11,%rbx,8),%edx

# qhasm: z3 = *(uint32 *) (table + 2 + p01 * 8)
# asm 1: movl   2(<table=int64#9,<p01=int64#1,8),>z3=int64#14d
# asm 2: movl   2(<table=%r11,<p01=%rdi,8),>z3=%ebx
movl   2(%r11,%rdi,8),%ebx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
# asm 1: xorl 1(<table=int64#9,<p12=int64#13,8),<z3=int64#14d
# asm 2: xorl 1(<table=%r11,<p12=%r15,8),<z3=%ebx
xorl 1(%r11,%r15,8),%ebx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
# asm 1: xorl 4(<table=int64#9,<p23=int64#15,8),<z3=int64#14d
# asm 2: xorl 4(<table=%r11,<p23=%rbp,8),<z3=%ebx
xorl 4(%r11,%rbp,8),%ebx

# qhasm: z1 ^= x1
# asm 1: xor  <x1=int64#5,<z1=int64#4
# asm 2: xor  <x1=%r8,<z1=%rcx
xor  %r8,%rcx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
# asm 1: xorl 3(<table=int64#9,<p30=int64#11,8),<z3=int64#14d
# asm 2: xorl 3(<table=%r11,<p30=%r13,8),<z3=%ebx
xorl 3(%r11,%r13,8),%ebx

# qhasm: assign 14 to z3

# qhasm: z2 ^= x2
# asm 1: xor  <x2=int64#6,<z2=int64#7
# asm 2: xor  <x2=%r9,<z2=%rax
xor  %r9,%rax

# qhasm: z3 ^= x3
# asm 1: xor  <x3=int64#8,<z3=int64#14
# asm 2: xor  <x3=%r10,<z3=%rbx
xor  %r10,%rbx

# qhasm: x0 = *(uint32 *) (c + 36)
# asm 1: movl   36(<c=int64#10),>x0=int64#2d
# asm 2: movl   36(<c=%r12),>x0=%esi
movl   36(%r12),%esi

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#2,<x1=int64#5
# asm 2: xor  <x0=%rsi,<x1=%r8
xor  %rsi,%r8

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#5,<x2=int64#6
# asm 2: xor  <x1=%r8,<x2=%r9
xor  %r8,%r9

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#6,<x3=int64#8
# asm 2: xor  <x2=%r9,<x3=%r10
xor  %r9,%r10

# qhasm: q00 = z0 & 255
# asm 1: movzbl  <z0=int64#3b,>q00=int64#11d
# asm 2: movzbl  <z0=%dl,>q00=%r13d
movzbl  %dl,%r13d

# qhasm: q03 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#3%next8,>q03=int64#1d
# asm 2: movzbl  <z0=%dh,>q03=%edi
movzbl  %dh,%edi

# qhasm: (uint32) z0 >>= 16
# asm 1: shr  $16,<z0=int64#3d
# asm 2: shr  $16,<z0=%edx
shr  $16,%edx

# qhasm: q02 = z0 & 255
# asm 1: movzbl  <z0=int64#3b,>q02=int64#12d
# asm 2: movzbl  <z0=%dl,>q02=%r14d
movzbl  %dl,%r14d

# qhasm: q01 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#3%next8,>q01=int64#15d
# asm 2: movzbl  <z0=%dh,>q01=%ebp
movzbl  %dh,%ebp

# qhasm: y0 = *(uint32 *) (table + 3 + q00 * 8)
# asm 1: movl   3(<table=int64#9,<q00=int64#11,8),>y0=int64#3d
# asm 2: movl   3(<table=%r11,<q00=%r13,8),>y0=%edx
movl   3(%r11,%r13,8),%edx

# qhasm: assign 3 to y0

# qhasm: y0 ^= x0
# asm 1: xor  <x0=int64#2,<y0=int64#3
# asm 2: xor  <x0=%rsi,<y0=%rdx
xor  %rsi,%rdx

# qhasm: q10 = z1 & 255
# asm 1: movzbl  <z1=int64#4b,>q10=int64#11d
# asm 2: movzbl  <z1=%cl,>q10=%r13d
movzbl  %cl,%r13d

# qhasm: q11 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#4%next8,>q11=int64#2d
# asm 2: movzbl  <z1=%ch,>q11=%esi
movzbl  %ch,%esi

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 2 + q11 * 8)
# asm 1: xorl 2(<table=int64#9,<q11=int64#2,8),<y0=int64#3d
# asm 2: xorl 2(<table=%r11,<q11=%rsi,8),<y0=%edx
xorl 2(%r11,%rsi,8),%edx

# qhasm: (uint32) z1 >>= 16
# asm 1: shr  $16,<z1=int64#4d
# asm 2: shr  $16,<z1=%ecx
shr  $16,%ecx

# qhasm: q12 = z1 & 255
# asm 1: movzbl  <z1=int64#4b,>q12=int64#13d
# asm 2: movzbl  <z1=%cl,>q12=%r15d
movzbl  %cl,%r15d

# qhasm: q13 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#4%next8,>q13=int64#2d
# asm 2: movzbl  <z1=%ch,>q13=%esi
movzbl  %ch,%esi

# qhasm: y1 = *(uint32 *) (table + 4 + q01 * 8)
# asm 1: movl   4(<table=int64#9,<q01=int64#15,8),>y1=int64#4d
# asm 2: movl   4(<table=%r11,<q01=%rbp,8),>y1=%ecx
movl   4(%r11,%rbp,8),%ecx

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 3 + q10 * 8)
# asm 1: xorl 3(<table=int64#9,<q10=int64#11,8),<y1=int64#4d
# asm 2: xorl 3(<table=%r11,<q10=%r13,8),<y1=%ecx
xorl 3(%r11,%r13,8),%ecx

# qhasm: assign 4 to y1

# qhasm: q20 = z2 & 255
# asm 1: movzbl  <z2=int64#7b,>q20=int64#11d
# asm 2: movzbl  <z2=%al,>q20=%r13d
movzbl  %al,%r13d

# qhasm: q21 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#7%next8,>q21=int64#15d
# asm 2: movzbl  <z2=%ah,>q21=%ebp
movzbl  %ah,%ebp

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 2 + q21 * 8)
# asm 1: xorl 2(<table=int64#9,<q21=int64#15,8),<y1=int64#4d
# asm 2: xorl 2(<table=%r11,<q21=%rbp,8),<y1=%ecx
xorl 2(%r11,%rbp,8),%ecx

# qhasm: (uint32) z2 >>= 16
# asm 1: shr  $16,<z2=int64#7d
# asm 2: shr  $16,<z2=%eax
shr  $16,%eax

# qhasm: q22 = z2 & 255
# asm 1: movzbl  <z2=int64#7b,>q22=int64#15d
# asm 2: movzbl  <z2=%al,>q22=%ebp
movzbl  %al,%ebp

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 1 + q22 * 8)
# asm 1: xorl 1(<table=int64#9,<q22=int64#15,8),<y0=int64#3d
# asm 2: xorl 1(<table=%r11,<q22=%rbp,8),<y0=%edx
xorl 1(%r11,%rbp,8),%edx

# qhasm: q23 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#7%next8,>q23=int64#15d
# asm 2: movzbl  <z2=%ah,>q23=%ebp
movzbl  %ah,%ebp

# qhasm: y2 = *(uint32 *) (table + 1 + q02 * 8)
# asm 1: movl   1(<table=int64#9,<q02=int64#12,8),>y2=int64#7d
# asm 2: movl   1(<table=%r11,<q02=%r14,8),>y2=%eax
movl   1(%r11,%r14,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 4 + q13 * 8)
# asm 1: xorl 4(<table=int64#9,<q13=int64#2,8),<y2=int64#7d
# asm 2: xorl 4(<table=%r11,<q13=%rsi,8),<y2=%eax
xorl 4(%r11,%rsi,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 3 + q20 * 8)
# asm 1: xorl 3(<table=int64#9,<q20=int64#11,8),<y2=int64#7d
# asm 2: xorl 3(<table=%r11,<q20=%r13,8),<y2=%eax
xorl 3(%r11,%r13,8),%eax

# qhasm: assign 7 to y2

# qhasm: q30 = z3 & 255
# asm 1: movzbl  <z3=int64#14b,>q30=int64#11d
# asm 2: movzbl  <z3=%bl,>q30=%r13d
movzbl  %bl,%r13d

# qhasm: q31 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#14%next8,>q31=int64#2d
# asm 2: movzbl  <z3=%bh,>q31=%esi
movzbl  %bh,%esi

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 2 + q31 * 8)
# asm 1: xorl 2(<table=int64#9,<q31=int64#2,8),<y2=int64#7d
# asm 2: xorl 2(<table=%r11,<q31=%rsi,8),<y2=%eax
xorl 2(%r11,%rsi,8),%eax

# qhasm: (uint32) z3 >>= 16
# asm 1: shr  $16,<z3=int64#14d
# asm 2: shr  $16,<z3=%ebx
shr  $16,%ebx

# qhasm: q32 = z3 & 255
# asm 1: movzbl  <z3=int64#14b,>q32=int64#2d
# asm 2: movzbl  <z3=%bl,>q32=%esi
movzbl  %bl,%esi

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 1 + q32 * 8)
# asm 1: xorl 1(<table=int64#9,<q32=int64#2,8),<y1=int64#4d
# asm 2: xorl 1(<table=%r11,<q32=%rsi,8),<y1=%ecx
xorl 1(%r11,%rsi,8),%ecx

# qhasm: q33 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#14%next8,>q33=int64#14d
# asm 2: movzbl  <z3=%bh,>q33=%ebx
movzbl  %bh,%ebx

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 4 + q33 * 8)
# asm 1: xorl 4(<table=int64#9,<q33=int64#14,8),<y0=int64#3d
# asm 2: xorl 4(<table=%r11,<q33=%rbx,8),<y0=%edx
xorl 4(%r11,%rbx,8),%edx

# qhasm: y3 = *(uint32 *) (table + 2 + q03 * 8)
# asm 1: movl   2(<table=int64#9,<q03=int64#1,8),>y3=int64#14d
# asm 2: movl   2(<table=%r11,<q03=%rdi,8),>y3=%ebx
movl   2(%r11,%rdi,8),%ebx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 1 + q12 * 8)
# asm 1: xorl 1(<table=int64#9,<q12=int64#13,8),<y3=int64#14d
# asm 2: xorl 1(<table=%r11,<q12=%r15,8),<y3=%ebx
xorl 1(%r11,%r15,8),%ebx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 4 + q23 * 8)
# asm 1: xorl 4(<table=int64#9,<q23=int64#15,8),<y3=int64#14d
# asm 2: xorl 4(<table=%r11,<q23=%rbp,8),<y3=%ebx
xorl 4(%r11,%rbp,8),%ebx

# qhasm: y1 ^= x1
# asm 1: xor  <x1=int64#5,<y1=int64#4
# asm 2: xor  <x1=%r8,<y1=%rcx
xor  %r8,%rcx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 3 + q30 * 8)
# asm 1: xorl 3(<table=int64#9,<q30=int64#11,8),<y3=int64#14d
# asm 2: xorl 3(<table=%r11,<q30=%r13,8),<y3=%ebx
xorl 3(%r11,%r13,8),%ebx

# qhasm: assign 14 to y3

# qhasm: y2 ^= x2
# asm 1: xor  <x2=int64#6,<y2=int64#7
# asm 2: xor  <x2=%r9,<y2=%rax
xor  %r9,%rax

# qhasm: y3 ^= x3
# asm 1: xor  <x3=int64#8,<y3=int64#14
# asm 2: xor  <x3=%r10,<y3=%rbx
xor  %r10,%rbx

# qhasm: x0 = *(uint32 *) (c + 40)
# asm 1: movl   40(<c=int64#10),>x0=int64#2d
# asm 2: movl   40(<c=%r12),>x0=%esi
movl   40(%r12),%esi

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#2,<x1=int64#5
# asm 2: xor  <x0=%rsi,<x1=%r8
xor  %rsi,%r8

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#5,<x2=int64#6
# asm 2: xor  <x1=%r8,<x2=%r9
xor  %r8,%r9

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#6,<x3=int64#8
# asm 2: xor  <x2=%r9,<x3=%r10
xor  %r9,%r10

# qhasm: p00 = y0 & 255
# asm 1: movzbl  <y0=int64#3b,>p00=int64#11d
# asm 2: movzbl  <y0=%dl,>p00=%r13d
movzbl  %dl,%r13d

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#3%next8,>p01=int64#1d
# asm 2: movzbl  <y0=%dh,>p01=%edi
movzbl  %dh,%edi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int64#3d
# asm 2: shr  $16,<y0=%edx
shr  $16,%edx

# qhasm: p02 = y0 & 255
# asm 1: movzbl  <y0=int64#3b,>p02=int64#12d
# asm 2: movzbl  <y0=%dl,>p02=%r14d
movzbl  %dl,%r14d

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#3%next8,>p03=int64#15d
# asm 2: movzbl  <y0=%dh,>p03=%ebp
movzbl  %dh,%ebp

# qhasm: z0 = *(uint32 *) (table + 3 + p00 * 8)
# asm 1: movl   3(<table=int64#9,<p00=int64#11,8),>z0=int64#3d
# asm 2: movl   3(<table=%r11,<p00=%r13,8),>z0=%edx
movl   3(%r11,%r13,8),%edx

# qhasm: assign 3 to z0

# qhasm: z0 ^= x0
# asm 1: xor  <x0=int64#2,<z0=int64#3
# asm 2: xor  <x0=%rsi,<z0=%rdx
xor  %rsi,%rdx

# qhasm: p10 = y1 & 255
# asm 1: movzbl  <y1=int64#4b,>p10=int64#11d
# asm 2: movzbl  <y1=%cl,>p10=%r13d
movzbl  %cl,%r13d

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#4%next8,>p11=int64#2d
# asm 2: movzbl  <y1=%ch,>p11=%esi
movzbl  %ch,%esi

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
# asm 1: xorl 2(<table=int64#9,<p11=int64#2,8),<z0=int64#3d
# asm 2: xorl 2(<table=%r11,<p11=%rsi,8),<z0=%edx
xorl 2(%r11,%rsi,8),%edx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int64#4d
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl  <y1=int64#4b,>p12=int64#13d
# asm 2: movzbl  <y1=%cl,>p12=%r15d
movzbl  %cl,%r15d

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#4%next8,>p13=int64#2d
# asm 2: movzbl  <y1=%ch,>p13=%esi
movzbl  %ch,%esi

# qhasm: z1 = *(uint32 *) (table + 4 + p03 * 8)
# asm 1: movl   4(<table=int64#9,<p03=int64#15,8),>z1=int64#4d
# asm 2: movl   4(<table=%r11,<p03=%rbp,8),>z1=%ecx
movl   4(%r11,%rbp,8),%ecx

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
# asm 1: xorl 3(<table=int64#9,<p10=int64#11,8),<z1=int64#4d
# asm 2: xorl 3(<table=%r11,<p10=%r13,8),<z1=%ecx
xorl 3(%r11,%r13,8),%ecx

# qhasm: assign 4 to z1

# qhasm: p20 = y2 & 255
# asm 1: movzbl  <y2=int64#7b,>p20=int64#11d
# asm 2: movzbl  <y2=%al,>p20=%r13d
movzbl  %al,%r13d

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#7%next8,>p21=int64#15d
# asm 2: movzbl  <y2=%ah,>p21=%ebp
movzbl  %ah,%ebp

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
# asm 1: xorl 2(<table=int64#9,<p21=int64#15,8),<z1=int64#4d
# asm 2: xorl 2(<table=%r11,<p21=%rbp,8),<z1=%ecx
xorl 2(%r11,%rbp,8),%ecx

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int64#7d
# asm 2: shr  $16,<y2=%eax
shr  $16,%eax

# qhasm: p22 = y2 & 255
# asm 1: movzbl  <y2=int64#7b,>p22=int64#15d
# asm 2: movzbl  <y2=%al,>p22=%ebp
movzbl  %al,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
# asm 1: xorl 1(<table=int64#9,<p22=int64#15,8),<z0=int64#3d
# asm 2: xorl 1(<table=%r11,<p22=%rbp,8),<z0=%edx
xorl 1(%r11,%rbp,8),%edx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#7%next8,>p23=int64#15d
# asm 2: movzbl  <y2=%ah,>p23=%ebp
movzbl  %ah,%ebp

# qhasm: z2 = *(uint32 *) (table + 1 + p02 * 8)
# asm 1: movl   1(<table=int64#9,<p02=int64#12,8),>z2=int64#7d
# asm 2: movl   1(<table=%r11,<p02=%r14,8),>z2=%eax
movl   1(%r11,%r14,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
# asm 1: xorl 4(<table=int64#9,<p13=int64#2,8),<z2=int64#7d
# asm 2: xorl 4(<table=%r11,<p13=%rsi,8),<z2=%eax
xorl 4(%r11,%rsi,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
# asm 1: xorl 3(<table=int64#9,<p20=int64#11,8),<z2=int64#7d
# asm 2: xorl 3(<table=%r11,<p20=%r13,8),<z2=%eax
xorl 3(%r11,%r13,8),%eax

# qhasm: assign 7 to z2

# qhasm: p30 = y3 & 255
# asm 1: movzbl  <y3=int64#14b,>p30=int64#11d
# asm 2: movzbl  <y3=%bl,>p30=%r13d
movzbl  %bl,%r13d

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#14%next8,>p31=int64#2d
# asm 2: movzbl  <y3=%bh,>p31=%esi
movzbl  %bh,%esi

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
# asm 1: xorl 2(<table=int64#9,<p31=int64#2,8),<z2=int64#7d
# asm 2: xorl 2(<table=%r11,<p31=%rsi,8),<z2=%eax
xorl 2(%r11,%rsi,8),%eax

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int64#14d
# asm 2: shr  $16,<y3=%ebx
shr  $16,%ebx

# qhasm: p32 = y3 & 255
# asm 1: movzbl  <y3=int64#14b,>p32=int64#2d
# asm 2: movzbl  <y3=%bl,>p32=%esi
movzbl  %bl,%esi

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
# asm 1: xorl 1(<table=int64#9,<p32=int64#2,8),<z1=int64#4d
# asm 2: xorl 1(<table=%r11,<p32=%rsi,8),<z1=%ecx
xorl 1(%r11,%rsi,8),%ecx

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#14%next8,>p33=int64#14d
# asm 2: movzbl  <y3=%bh,>p33=%ebx
movzbl  %bh,%ebx

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
# asm 1: xorl 4(<table=int64#9,<p33=int64#14,8),<z0=int64#3d
# asm 2: xorl 4(<table=%r11,<p33=%rbx,8),<z0=%edx
xorl 4(%r11,%rbx,8),%edx

# qhasm: z3 = *(uint32 *) (table + 2 + p01 * 8)
# asm 1: movl   2(<table=int64#9,<p01=int64#1,8),>z3=int64#14d
# asm 2: movl   2(<table=%r11,<p01=%rdi,8),>z3=%ebx
movl   2(%r11,%rdi,8),%ebx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
# asm 1: xorl 1(<table=int64#9,<p12=int64#13,8),<z3=int64#14d
# asm 2: xorl 1(<table=%r11,<p12=%r15,8),<z3=%ebx
xorl 1(%r11,%r15,8),%ebx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
# asm 1: xorl 4(<table=int64#9,<p23=int64#15,8),<z3=int64#14d
# asm 2: xorl 4(<table=%r11,<p23=%rbp,8),<z3=%ebx
xorl 4(%r11,%rbp,8),%ebx

# qhasm: z1 ^= x1
# asm 1: xor  <x1=int64#5,<z1=int64#4
# asm 2: xor  <x1=%r8,<z1=%rcx
xor  %r8,%rcx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
# asm 1: xorl 3(<table=int64#9,<p30=int64#11,8),<z3=int64#14d
# asm 2: xorl 3(<table=%r11,<p30=%r13,8),<z3=%ebx
xorl 3(%r11,%r13,8),%ebx

# qhasm: assign 14 to z3

# qhasm: z2 ^= x2
# asm 1: xor  <x2=int64#6,<z2=int64#7
# asm 2: xor  <x2=%r9,<z2=%rax
xor  %r9,%rax

# qhasm: z3 ^= x3
# asm 1: xor  <x3=int64#8,<z3=int64#14
# asm 2: xor  <x3=%r10,<z3=%rbx
xor  %r10,%rbx

# qhasm: x0 = *(uint32 *) (c + 44)
# asm 1: movl   44(<c=int64#10),>x0=int64#2d
# asm 2: movl   44(<c=%r12),>x0=%esi
movl   44(%r12),%esi

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#2,<x1=int64#5
# asm 2: xor  <x0=%rsi,<x1=%r8
xor  %rsi,%r8

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#5,<x2=int64#6
# asm 2: xor  <x1=%r8,<x2=%r9
xor  %r8,%r9

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#6,<x3=int64#8
# asm 2: xor  <x2=%r9,<x3=%r10
xor  %r9,%r10

# qhasm: q00 = z0 & 255
# asm 1: movzbl  <z0=int64#3b,>q00=int64#11d
# asm 2: movzbl  <z0=%dl,>q00=%r13d
movzbl  %dl,%r13d

# qhasm: q03 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#3%next8,>q03=int64#1d
# asm 2: movzbl  <z0=%dh,>q03=%edi
movzbl  %dh,%edi

# qhasm: (uint32) z0 >>= 16
# asm 1: shr  $16,<z0=int64#3d
# asm 2: shr  $16,<z0=%edx
shr  $16,%edx

# qhasm: q02 = z0 & 255
# asm 1: movzbl  <z0=int64#3b,>q02=int64#12d
# asm 2: movzbl  <z0=%dl,>q02=%r14d
movzbl  %dl,%r14d

# qhasm: q01 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#3%next8,>q01=int64#15d
# asm 2: movzbl  <z0=%dh,>q01=%ebp
movzbl  %dh,%ebp

# qhasm: y0 = *(uint32 *) (table + 3 + q00 * 8)
# asm 1: movl   3(<table=int64#9,<q00=int64#11,8),>y0=int64#3d
# asm 2: movl   3(<table=%r11,<q00=%r13,8),>y0=%edx
movl   3(%r11,%r13,8),%edx

# qhasm: assign 3 to y0

# qhasm: y0 ^= x0
# asm 1: xor  <x0=int64#2,<y0=int64#3
# asm 2: xor  <x0=%rsi,<y0=%rdx
xor  %rsi,%rdx

# qhasm: q10 = z1 & 255
# asm 1: movzbl  <z1=int64#4b,>q10=int64#11d
# asm 2: movzbl  <z1=%cl,>q10=%r13d
movzbl  %cl,%r13d

# qhasm: q11 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#4%next8,>q11=int64#2d
# asm 2: movzbl  <z1=%ch,>q11=%esi
movzbl  %ch,%esi

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 2 + q11 * 8)
# asm 1: xorl 2(<table=int64#9,<q11=int64#2,8),<y0=int64#3d
# asm 2: xorl 2(<table=%r11,<q11=%rsi,8),<y0=%edx
xorl 2(%r11,%rsi,8),%edx

# qhasm: (uint32) z1 >>= 16
# asm 1: shr  $16,<z1=int64#4d
# asm 2: shr  $16,<z1=%ecx
shr  $16,%ecx

# qhasm: q12 = z1 & 255
# asm 1: movzbl  <z1=int64#4b,>q12=int64#13d
# asm 2: movzbl  <z1=%cl,>q12=%r15d
movzbl  %cl,%r15d

# qhasm: q13 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#4%next8,>q13=int64#2d
# asm 2: movzbl  <z1=%ch,>q13=%esi
movzbl  %ch,%esi

# qhasm: y1 = *(uint32 *) (table + 4 + q01 * 8)
# asm 1: movl   4(<table=int64#9,<q01=int64#15,8),>y1=int64#4d
# asm 2: movl   4(<table=%r11,<q01=%rbp,8),>y1=%ecx
movl   4(%r11,%rbp,8),%ecx

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 3 + q10 * 8)
# asm 1: xorl 3(<table=int64#9,<q10=int64#11,8),<y1=int64#4d
# asm 2: xorl 3(<table=%r11,<q10=%r13,8),<y1=%ecx
xorl 3(%r11,%r13,8),%ecx

# qhasm: assign 4 to y1

# qhasm: q20 = z2 & 255
# asm 1: movzbl  <z2=int64#7b,>q20=int64#11d
# asm 2: movzbl  <z2=%al,>q20=%r13d
movzbl  %al,%r13d

# qhasm: q21 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#7%next8,>q21=int64#15d
# asm 2: movzbl  <z2=%ah,>q21=%ebp
movzbl  %ah,%ebp

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 2 + q21 * 8)
# asm 1: xorl 2(<table=int64#9,<q21=int64#15,8),<y1=int64#4d
# asm 2: xorl 2(<table=%r11,<q21=%rbp,8),<y1=%ecx
xorl 2(%r11,%rbp,8),%ecx

# qhasm: (uint32) z2 >>= 16
# asm 1: shr  $16,<z2=int64#7d
# asm 2: shr  $16,<z2=%eax
shr  $16,%eax

# qhasm: q22 = z2 & 255
# asm 1: movzbl  <z2=int64#7b,>q22=int64#15d
# asm 2: movzbl  <z2=%al,>q22=%ebp
movzbl  %al,%ebp

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 1 + q22 * 8)
# asm 1: xorl 1(<table=int64#9,<q22=int64#15,8),<y0=int64#3d
# asm 2: xorl 1(<table=%r11,<q22=%rbp,8),<y0=%edx
xorl 1(%r11,%rbp,8),%edx

# qhasm: q23 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#7%next8,>q23=int64#15d
# asm 2: movzbl  <z2=%ah,>q23=%ebp
movzbl  %ah,%ebp

# qhasm: y2 = *(uint32 *) (table + 1 + q02 * 8)
# asm 1: movl   1(<table=int64#9,<q02=int64#12,8),>y2=int64#7d
# asm 2: movl   1(<table=%r11,<q02=%r14,8),>y2=%eax
movl   1(%r11,%r14,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 4 + q13 * 8)
# asm 1: xorl 4(<table=int64#9,<q13=int64#2,8),<y2=int64#7d
# asm 2: xorl 4(<table=%r11,<q13=%rsi,8),<y2=%eax
xorl 4(%r11,%rsi,8),%eax

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 3 + q20 * 8)
# asm 1: xorl 3(<table=int64#9,<q20=int64#11,8),<y2=int64#7d
# asm 2: xorl 3(<table=%r11,<q20=%r13,8),<y2=%eax
xorl 3(%r11,%r13,8),%eax

# qhasm: assign 7 to y2

# qhasm: q30 = z3 & 255
# asm 1: movzbl  <z3=int64#14b,>q30=int64#11d
# asm 2: movzbl  <z3=%bl,>q30=%r13d
movzbl  %bl,%r13d

# qhasm: q31 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#14%next8,>q31=int64#2d
# asm 2: movzbl  <z3=%bh,>q31=%esi
movzbl  %bh,%esi

# qhasm: (uint32) y2 ^= *(uint32 *) (table + 2 + q31 * 8)
# asm 1: xorl 2(<table=int64#9,<q31=int64#2,8),<y2=int64#7d
# asm 2: xorl 2(<table=%r11,<q31=%rsi,8),<y2=%eax
xorl 2(%r11,%rsi,8),%eax

# qhasm: (uint32) z3 >>= 16
# asm 1: shr  $16,<z3=int64#14d
# asm 2: shr  $16,<z3=%ebx
shr  $16,%ebx

# qhasm: q32 = z3 & 255
# asm 1: movzbl  <z3=int64#14b,>q32=int64#2d
# asm 2: movzbl  <z3=%bl,>q32=%esi
movzbl  %bl,%esi

# qhasm: (uint32) y1 ^= *(uint32 *) (table + 1 + q32 * 8)
# asm 1: xorl 1(<table=int64#9,<q32=int64#2,8),<y1=int64#4d
# asm 2: xorl 1(<table=%r11,<q32=%rsi,8),<y1=%ecx
xorl 1(%r11,%rsi,8),%ecx

# qhasm: q33 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#14%next8,>q33=int64#14d
# asm 2: movzbl  <z3=%bh,>q33=%ebx
movzbl  %bh,%ebx

# qhasm: (uint32) y0 ^= *(uint32 *) (table + 4 + q33 * 8)
# asm 1: xorl 4(<table=int64#9,<q33=int64#14,8),<y0=int64#3d
# asm 2: xorl 4(<table=%r11,<q33=%rbx,8),<y0=%edx
xorl 4(%r11,%rbx,8),%edx

# qhasm: y3 = *(uint32 *) (table + 2 + q03 * 8)
# asm 1: movl   2(<table=int64#9,<q03=int64#1,8),>y3=int64#14d
# asm 2: movl   2(<table=%r11,<q03=%rdi,8),>y3=%ebx
movl   2(%r11,%rdi,8),%ebx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 1 + q12 * 8)
# asm 1: xorl 1(<table=int64#9,<q12=int64#13,8),<y3=int64#14d
# asm 2: xorl 1(<table=%r11,<q12=%r15,8),<y3=%ebx
xorl 1(%r11,%r15,8),%ebx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 4 + q23 * 8)
# asm 1: xorl 4(<table=int64#9,<q23=int64#15,8),<y3=int64#14d
# asm 2: xorl 4(<table=%r11,<q23=%rbp,8),<y3=%ebx
xorl 4(%r11,%rbp,8),%ebx

# qhasm: y1 ^= x1
# asm 1: xor  <x1=int64#5,<y1=int64#4
# asm 2: xor  <x1=%r8,<y1=%rcx
xor  %r8,%rcx

# qhasm: (uint32) y3 ^= *(uint32 *) (table + 3 + q30 * 8)
# asm 1: xorl 3(<table=int64#9,<q30=int64#11,8),<y3=int64#14d
# asm 2: xorl 3(<table=%r11,<q30=%r13,8),<y3=%ebx
xorl 3(%r11,%r13,8),%ebx

# qhasm: assign 14 to y3

# qhasm: y2 ^= x2
# asm 1: xor  <x2=int64#6,<y2=int64#7
# asm 2: xor  <x2=%r9,<y2=%rax
xor  %r9,%rax

# qhasm: y3 ^= x3
# asm 1: xor  <x3=int64#8,<y3=int64#14
# asm 2: xor  <x3=%r10,<y3=%rbx
xor  %r10,%rbx

# qhasm: x0 = *(uint32 *) (c + 48)
# asm 1: movl   48(<c=int64#10),>x0=int64#2d
# asm 2: movl   48(<c=%r12),>x0=%esi
movl   48(%r12),%esi

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#2,<x1=int64#5
# asm 2: xor  <x0=%rsi,<x1=%r8
xor  %rsi,%r8

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#5,<x2=int64#6
# asm 2: xor  <x1=%r8,<x2=%r9
xor  %r8,%r9

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#6,<x3=int64#8
# asm 2: xor  <x2=%r9,<x3=%r10
xor  %r9,%r10

# qhasm: p00 = y0 & 255
# asm 1: movzbl  <y0=int64#3b,>p00=int64#11d
# asm 2: movzbl  <y0=%dl,>p00=%r13d
movzbl  %dl,%r13d

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#3%next8,>p01=int64#1d
# asm 2: movzbl  <y0=%dh,>p01=%edi
movzbl  %dh,%edi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int64#3d
# asm 2: shr  $16,<y0=%edx
shr  $16,%edx

# qhasm: p02 = y0 & 255
# asm 1: movzbl  <y0=int64#3b,>p02=int64#12d
# asm 2: movzbl  <y0=%dl,>p02=%r14d
movzbl  %dl,%r14d

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl  <y0=int64#3%next8,>p03=int64#15d
# asm 2: movzbl  <y0=%dh,>p03=%ebp
movzbl  %dh,%ebp

# qhasm: z0 = *(uint32 *) (table + 3 + p00 * 8)
# asm 1: movl   3(<table=int64#9,<p00=int64#11,8),>z0=int64#3d
# asm 2: movl   3(<table=%r11,<p00=%r13,8),>z0=%edx
movl   3(%r11,%r13,8),%edx

# qhasm: assign 3 to z0

# qhasm: z0 ^= x0
# asm 1: xor  <x0=int64#2,<z0=int64#3
# asm 2: xor  <x0=%rsi,<z0=%rdx
xor  %rsi,%rdx

# qhasm: p10 = y1 & 255
# asm 1: movzbl  <y1=int64#4b,>p10=int64#11d
# asm 2: movzbl  <y1=%cl,>p10=%r13d
movzbl  %cl,%r13d

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#4%next8,>p11=int64#2d
# asm 2: movzbl  <y1=%ch,>p11=%esi
movzbl  %ch,%esi

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 2 + p11 * 8)
# asm 1: xorl 2(<table=int64#9,<p11=int64#2,8),<z0=int64#3d
# asm 2: xorl 2(<table=%r11,<p11=%rsi,8),<z0=%edx
xorl 2(%r11,%rsi,8),%edx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int64#4d
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl  <y1=int64#4b,>p12=int64#13d
# asm 2: movzbl  <y1=%cl,>p12=%r15d
movzbl  %cl,%r15d

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl  <y1=int64#4%next8,>p13=int64#2d
# asm 2: movzbl  <y1=%ch,>p13=%esi
movzbl  %ch,%esi

# qhasm: z1 = *(uint32 *) (table + 4 + p03 * 8)
# asm 1: movl   4(<table=int64#9,<p03=int64#15,8),>z1=int64#4d
# asm 2: movl   4(<table=%r11,<p03=%rbp,8),>z1=%ecx
movl   4(%r11,%rbp,8),%ecx

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 3 + p10 * 8)
# asm 1: xorl 3(<table=int64#9,<p10=int64#11,8),<z1=int64#4d
# asm 2: xorl 3(<table=%r11,<p10=%r13,8),<z1=%ecx
xorl 3(%r11,%r13,8),%ecx

# qhasm: assign 4 to z1

# qhasm: p20 = y2 & 255
# asm 1: movzbl  <y2=int64#7b,>p20=int64#11d
# asm 2: movzbl  <y2=%al,>p20=%r13d
movzbl  %al,%r13d

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#7%next8,>p21=int64#15d
# asm 2: movzbl  <y2=%ah,>p21=%ebp
movzbl  %ah,%ebp

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 2 + p21 * 8)
# asm 1: xorl 2(<table=int64#9,<p21=int64#15,8),<z1=int64#4d
# asm 2: xorl 2(<table=%r11,<p21=%rbp,8),<z1=%ecx
xorl 2(%r11,%rbp,8),%ecx

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int64#7d
# asm 2: shr  $16,<y2=%eax
shr  $16,%eax

# qhasm: p22 = y2 & 255
# asm 1: movzbl  <y2=int64#7b,>p22=int64#15d
# asm 2: movzbl  <y2=%al,>p22=%ebp
movzbl  %al,%ebp

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 1 + p22 * 8)
# asm 1: xorl 1(<table=int64#9,<p22=int64#15,8),<z0=int64#3d
# asm 2: xorl 1(<table=%r11,<p22=%rbp,8),<z0=%edx
xorl 1(%r11,%rbp,8),%edx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl  <y2=int64#7%next8,>p23=int64#15d
# asm 2: movzbl  <y2=%ah,>p23=%ebp
movzbl  %ah,%ebp

# qhasm: z2 = *(uint32 *) (table + 1 + p02 * 8)
# asm 1: movl   1(<table=int64#9,<p02=int64#12,8),>z2=int64#7d
# asm 2: movl   1(<table=%r11,<p02=%r14,8),>z2=%eax
movl   1(%r11,%r14,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 4 + p13 * 8)
# asm 1: xorl 4(<table=int64#9,<p13=int64#2,8),<z2=int64#7d
# asm 2: xorl 4(<table=%r11,<p13=%rsi,8),<z2=%eax
xorl 4(%r11,%rsi,8),%eax

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 3 + p20 * 8)
# asm 1: xorl 3(<table=int64#9,<p20=int64#11,8),<z2=int64#7d
# asm 2: xorl 3(<table=%r11,<p20=%r13,8),<z2=%eax
xorl 3(%r11,%r13,8),%eax

# qhasm: assign 7 to z2

# qhasm: p30 = y3 & 255
# asm 1: movzbl  <y3=int64#14b,>p30=int64#11d
# asm 2: movzbl  <y3=%bl,>p30=%r13d
movzbl  %bl,%r13d

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#14%next8,>p31=int64#2d
# asm 2: movzbl  <y3=%bh,>p31=%esi
movzbl  %bh,%esi

# qhasm: (uint32) z2 ^= *(uint32 *) (table + 2 + p31 * 8)
# asm 1: xorl 2(<table=int64#9,<p31=int64#2,8),<z2=int64#7d
# asm 2: xorl 2(<table=%r11,<p31=%rsi,8),<z2=%eax
xorl 2(%r11,%rsi,8),%eax

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int64#14d
# asm 2: shr  $16,<y3=%ebx
shr  $16,%ebx

# qhasm: p32 = y3 & 255
# asm 1: movzbl  <y3=int64#14b,>p32=int64#2d
# asm 2: movzbl  <y3=%bl,>p32=%esi
movzbl  %bl,%esi

# qhasm: (uint32) z1 ^= *(uint32 *) (table + 1 + p32 * 8)
# asm 1: xorl 1(<table=int64#9,<p32=int64#2,8),<z1=int64#4d
# asm 2: xorl 1(<table=%r11,<p32=%rsi,8),<z1=%ecx
xorl 1(%r11,%rsi,8),%ecx

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl  <y3=int64#14%next8,>p33=int64#14d
# asm 2: movzbl  <y3=%bh,>p33=%ebx
movzbl  %bh,%ebx

# qhasm: (uint32) z0 ^= *(uint32 *) (table + 4 + p33 * 8)
# asm 1: xorl 4(<table=int64#9,<p33=int64#14,8),<z0=int64#3d
# asm 2: xorl 4(<table=%r11,<p33=%rbx,8),<z0=%edx
xorl 4(%r11,%rbx,8),%edx

# qhasm: z3 = *(uint32 *) (table + 2 + p01 * 8)
# asm 1: movl   2(<table=int64#9,<p01=int64#1,8),>z3=int64#14d
# asm 2: movl   2(<table=%r11,<p01=%rdi,8),>z3=%ebx
movl   2(%r11,%rdi,8),%ebx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 1 + p12 * 8)
# asm 1: xorl 1(<table=int64#9,<p12=int64#13,8),<z3=int64#14d
# asm 2: xorl 1(<table=%r11,<p12=%r15,8),<z3=%ebx
xorl 1(%r11,%r15,8),%ebx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 4 + p23 * 8)
# asm 1: xorl 4(<table=int64#9,<p23=int64#15,8),<z3=int64#14d
# asm 2: xorl 4(<table=%r11,<p23=%rbp,8),<z3=%ebx
xorl 4(%r11,%rbp,8),%ebx

# qhasm: z1 ^= x1
# asm 1: xor  <x1=int64#5,<z1=int64#4
# asm 2: xor  <x1=%r8,<z1=%rcx
xor  %r8,%rcx

# qhasm: (uint32) z3 ^= *(uint32 *) (table + 3 + p30 * 8)
# asm 1: xorl 3(<table=int64#9,<p30=int64#11,8),<z3=int64#14d
# asm 2: xorl 3(<table=%r11,<p30=%r13,8),<z3=%ebx
xorl 3(%r11,%r13,8),%ebx

# qhasm: assign 14 to z3

# qhasm: z2 ^= x2
# asm 1: xor  <x2=int64#6,<z2=int64#7
# asm 2: xor  <x2=%r9,<z2=%rax
xor  %r9,%rax

# qhasm: z3 ^= x3
# asm 1: xor  <x3=int64#8,<z3=int64#14
# asm 2: xor  <x3=%r10,<z3=%rbx
xor  %r10,%rbx

# qhasm: x0 = *(uint32 *) (c + 52)
# asm 1: movl   52(<c=int64#10),>x0=int64#2d
# asm 2: movl   52(<c=%r12),>x0=%esi
movl   52(%r12),%esi

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#2,<x1=int64#5
# asm 2: xor  <x0=%rsi,<x1=%r8
xor  %rsi,%r8

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#5,<x2=int64#6
# asm 2: xor  <x1=%r8,<x2=%r9
xor  %r8,%r9

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#6,<x3=int64#8
# asm 2: xor  <x2=%r9,<x3=%r10
xor  %r9,%r10

# qhasm: y0 = z0 & 255
# asm 1: movzbl  <z0=int64#3b,>y0=int64#1d
# asm 2: movzbl  <z0=%dl,>y0=%edi
movzbl  %dl,%edi

# qhasm: y0 = *(uint8 *) (table + 1 + y0 * 8)
# asm 1: movzbq 1(<table=int64#9,<y0=int64#1,8),>y0=int64#10
# asm 2: movzbq 1(<table=%r11,<y0=%rdi,8),>y0=%r12
movzbq 1(%r11,%rdi,8),%r12

# qhasm: y3 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#3%next8,>y3=int64#1d
# asm 2: movzbl  <z0=%dh,>y3=%edi
movzbl  %dh,%edi

# qhasm: y3 = *(uint16 *) (table + y3 * 8)
# asm 1: movzwq (<table=int64#9,<y3=int64#1,8),>y3=int64#11
# asm 2: movzwq (<table=%r11,<y3=%rdi,8),>y3=%r13
movzwq (%r11,%rdi,8),%r13

# qhasm: (uint32) z0 >>= 16
# asm 1: shr  $16,<z0=int64#3d
# asm 2: shr  $16,<z0=%edx
shr  $16,%edx

# qhasm: y2 = z0 & 255
# asm 1: movzbl  <z0=int64#3b,>y2=int64#1d
# asm 2: movzbl  <z0=%dl,>y2=%edi
movzbl  %dl,%edi

# qhasm: y2 = *(uint32 *) (table + 3 + y2 * 8)
# asm 1: movl   3(<table=int64#9,<y2=int64#1,8),>y2=int64#12d
# asm 2: movl   3(<table=%r11,<y2=%rdi,8),>y2=%r14d
movl   3(%r11,%rdi,8),%r14d

# qhasm: (uint32) y2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<y2=int64#12d
# asm 2: and  $0x00ff0000,<y2=%r14d
and  $0x00ff0000,%r14d

# qhasm: y1 = (z0 >> 8) & 255
# asm 1: movzbl  <z0=int64#3%next8,>y1=int64#1d
# asm 2: movzbl  <z0=%dh,>y1=%edi
movzbl  %dh,%edi

# qhasm: y1 = *(uint32 *) (table + 2 + y1 * 8)
# asm 1: movl   2(<table=int64#9,<y1=int64#1,8),>y1=int64#3d
# asm 2: movl   2(<table=%r11,<y1=%rdi,8),>y1=%edx
movl   2(%r11,%rdi,8),%edx

# qhasm: (uint32) y1 &= 0xff000000
# asm 1: and  $0xff000000,<y1=int64#3d
# asm 2: and  $0xff000000,<y1=%edx
and  $0xff000000,%edx

# qhasm: y0 ^= x0
# asm 1: xor  <x0=int64#2,<y0=int64#10
# asm 2: xor  <x0=%rsi,<y0=%r12
xor  %rsi,%r12

# qhasm: y3 ^= x3
# asm 1: xor  <x3=int64#8,<y3=int64#11
# asm 2: xor  <x3=%r10,<y3=%r13
xor  %r10,%r13

# qhasm: y1 ^= x1
# asm 1: xor  <x1=int64#5,<y1=int64#3
# asm 2: xor  <x1=%r8,<y1=%rdx
xor  %r8,%rdx

# qhasm: y2 ^= x2
# asm 1: xor  <x2=int64#6,<y2=int64#12
# asm 2: xor  <x2=%r9,<y2=%r14
xor  %r9,%r14

# qhasm: q10 = z1 & 255
# asm 1: movzbl  <z1=int64#4b,>q10=int64#1d
# asm 2: movzbl  <z1=%cl,>q10=%edi
movzbl  %cl,%edi

# qhasm: q10 = *(uint8 *) (table + 1 + q10 * 8)
# asm 1: movzbq 1(<table=int64#9,<q10=int64#1,8),>q10=int64#1
# asm 2: movzbq 1(<table=%r11,<q10=%rdi,8),>q10=%rdi
movzbq 1(%r11,%rdi,8),%rdi

# qhasm: y1 ^= q10
# asm 1: xor  <q10=int64#1,<y1=int64#3
# asm 2: xor  <q10=%rdi,<y1=%rdx
xor  %rdi,%rdx

# qhasm: q11 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#4%next8,>q11=int64#1d
# asm 2: movzbl  <z1=%ch,>q11=%edi
movzbl  %ch,%edi

# qhasm: q11 = *(uint16 *) (table + q11 * 8)
# asm 1: movzwq (<table=int64#9,<q11=int64#1,8),>q11=int64#1
# asm 2: movzwq (<table=%r11,<q11=%rdi,8),>q11=%rdi
movzwq (%r11,%rdi,8),%rdi

# qhasm: y0 ^= q11
# asm 1: xor  <q11=int64#1,<y0=int64#10
# asm 2: xor  <q11=%rdi,<y0=%r12
xor  %rdi,%r12

# qhasm: (uint32) z1 >>= 16
# asm 1: shr  $16,<z1=int64#4d
# asm 2: shr  $16,<z1=%ecx
shr  $16,%ecx

# qhasm: q12 = z1 & 255
# asm 1: movzbl  <z1=int64#4b,>q12=int64#1d
# asm 2: movzbl  <z1=%cl,>q12=%edi
movzbl  %cl,%edi

# qhasm: q12 = *(uint32 *) (table + 3 + q12 * 8)
# asm 1: movl   3(<table=int64#9,<q12=int64#1,8),>q12=int64#1d
# asm 2: movl   3(<table=%r11,<q12=%rdi,8),>q12=%edi
movl   3(%r11,%rdi,8),%edi

# qhasm: (uint32) q12 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q12=int64#1d
# asm 2: and  $0x00ff0000,<q12=%edi
and  $0x00ff0000,%edi

# qhasm: y3 ^= q12
# asm 1: xor  <q12=int64#1,<y3=int64#11
# asm 2: xor  <q12=%rdi,<y3=%r13
xor  %rdi,%r13

# qhasm: q13 = (z1 >> 8) & 255
# asm 1: movzbl  <z1=int64#4%next8,>q13=int64#1d
# asm 2: movzbl  <z1=%ch,>q13=%edi
movzbl  %ch,%edi

# qhasm: q13 = *(uint32 *) (table + 2 + q13 * 8)
# asm 1: movl   2(<table=int64#9,<q13=int64#1,8),>q13=int64#1d
# asm 2: movl   2(<table=%r11,<q13=%rdi,8),>q13=%edi
movl   2(%r11,%rdi,8),%edi

# qhasm: (uint32) q13 &= 0xff000000
# asm 1: and  $0xff000000,<q13=int64#1d
# asm 2: and  $0xff000000,<q13=%edi
and  $0xff000000,%edi

# qhasm: y2 ^= q13
# asm 1: xor  <q13=int64#1,<y2=int64#12
# asm 2: xor  <q13=%rdi,<y2=%r14
xor  %rdi,%r14

# qhasm: q20 = z2 & 255
# asm 1: movzbl  <z2=int64#7b,>q20=int64#1d
# asm 2: movzbl  <z2=%al,>q20=%edi
movzbl  %al,%edi

# qhasm: q20 = *(uint8 *) (table + 1 + q20 * 8)
# asm 1: movzbq 1(<table=int64#9,<q20=int64#1,8),>q20=int64#1
# asm 2: movzbq 1(<table=%r11,<q20=%rdi,8),>q20=%rdi
movzbq 1(%r11,%rdi,8),%rdi

# qhasm: y2 ^= q20
# asm 1: xor  <q20=int64#1,<y2=int64#12
# asm 2: xor  <q20=%rdi,<y2=%r14
xor  %rdi,%r14

# qhasm: q21 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#7%next8,>q21=int64#1d
# asm 2: movzbl  <z2=%ah,>q21=%edi
movzbl  %ah,%edi

# qhasm: q21 = *(uint16 *) (table + q21 * 8)
# asm 1: movzwq (<table=int64#9,<q21=int64#1,8),>q21=int64#1
# asm 2: movzwq (<table=%r11,<q21=%rdi,8),>q21=%rdi
movzwq (%r11,%rdi,8),%rdi

# qhasm: y1 ^= q21
# asm 1: xor  <q21=int64#1,<y1=int64#3
# asm 2: xor  <q21=%rdi,<y1=%rdx
xor  %rdi,%rdx

# qhasm: (uint32) z2 >>= 16
# asm 1: shr  $16,<z2=int64#7d
# asm 2: shr  $16,<z2=%eax
shr  $16,%eax

# qhasm: q22 = z2 & 255
# asm 1: movzbl  <z2=int64#7b,>q22=int64#1d
# asm 2: movzbl  <z2=%al,>q22=%edi
movzbl  %al,%edi

# qhasm: q22 = *(uint32 *) (table + 3 + q22 * 8)
# asm 1: movl   3(<table=int64#9,<q22=int64#1,8),>q22=int64#1d
# asm 2: movl   3(<table=%r11,<q22=%rdi,8),>q22=%edi
movl   3(%r11,%rdi,8),%edi

# qhasm: (uint32) q22 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q22=int64#1d
# asm 2: and  $0x00ff0000,<q22=%edi
and  $0x00ff0000,%edi

# qhasm: y0 ^= q22
# asm 1: xor  <q22=int64#1,<y0=int64#10
# asm 2: xor  <q22=%rdi,<y0=%r12
xor  %rdi,%r12

# qhasm: q23 = (z2 >> 8) & 255
# asm 1: movzbl  <z2=int64#7%next8,>q23=int64#1d
# asm 2: movzbl  <z2=%ah,>q23=%edi
movzbl  %ah,%edi

# qhasm: q23 = *(uint32 *) (table + 2 + q23 * 8)
# asm 1: movl   2(<table=int64#9,<q23=int64#1,8),>q23=int64#1d
# asm 2: movl   2(<table=%r11,<q23=%rdi,8),>q23=%edi
movl   2(%r11,%rdi,8),%edi

# qhasm: (uint32) q23 &= 0xff000000
# asm 1: and  $0xff000000,<q23=int64#1d
# asm 2: and  $0xff000000,<q23=%edi
and  $0xff000000,%edi

# qhasm: y3 ^= q23
# asm 1: xor  <q23=int64#1,<y3=int64#11
# asm 2: xor  <q23=%rdi,<y3=%r13
xor  %rdi,%r13

# qhasm: q30 = z3 & 255
# asm 1: movzbl  <z3=int64#14b,>q30=int64#1d
# asm 2: movzbl  <z3=%bl,>q30=%edi
movzbl  %bl,%edi

# qhasm: q30 = *(uint8 *) (table + 1 + q30 * 8)
# asm 1: movzbq 1(<table=int64#9,<q30=int64#1,8),>q30=int64#1
# asm 2: movzbq 1(<table=%r11,<q30=%rdi,8),>q30=%rdi
movzbq 1(%r11,%rdi,8),%rdi

# qhasm: y3 ^= q30
# asm 1: xor  <q30=int64#1,<y3=int64#11
# asm 2: xor  <q30=%rdi,<y3=%r13
xor  %rdi,%r13

# qhasm: q31 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#14%next8,>q31=int64#1d
# asm 2: movzbl  <z3=%bh,>q31=%edi
movzbl  %bh,%edi

# qhasm: q31 = *(uint16 *) (table + q31 * 8)
# asm 1: movzwq (<table=int64#9,<q31=int64#1,8),>q31=int64#1
# asm 2: movzwq (<table=%r11,<q31=%rdi,8),>q31=%rdi
movzwq (%r11,%rdi,8),%rdi

# qhasm: y2 ^= q31
# asm 1: xor  <q31=int64#1,<y2=int64#12
# asm 2: xor  <q31=%rdi,<y2=%r14
xor  %rdi,%r14

# qhasm: (uint32) z3 >>= 16
# asm 1: shr  $16,<z3=int64#14d
# asm 2: shr  $16,<z3=%ebx
shr  $16,%ebx

# qhasm: q32 = z3 & 255
# asm 1: movzbl  <z3=int64#14b,>q32=int64#1d
# asm 2: movzbl  <z3=%bl,>q32=%edi
movzbl  %bl,%edi

# qhasm: q32 = *(uint32 *) (table + 3 + q32 * 8)
# asm 1: movl   3(<table=int64#9,<q32=int64#1,8),>q32=int64#1d
# asm 2: movl   3(<table=%r11,<q32=%rdi,8),>q32=%edi
movl   3(%r11,%rdi,8),%edi

# qhasm: (uint32) q32 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q32=int64#1d
# asm 2: and  $0x00ff0000,<q32=%edi
and  $0x00ff0000,%edi

# qhasm: y1 ^= q32
# asm 1: xor  <q32=int64#1,<y1=int64#3
# asm 2: xor  <q32=%rdi,<y1=%rdx
xor  %rdi,%rdx

# qhasm: q33 = (z3 >> 8) & 255
# asm 1: movzbl  <z3=int64#14%next8,>q33=int64#1d
# asm 2: movzbl  <z3=%bh,>q33=%edi
movzbl  %bh,%edi

# qhasm: q33 = *(uint32 *) (table + 2 + q33 * 8)
# asm 1: movl   2(<table=int64#9,<q33=int64#1,8),>q33=int64#1d
# asm 2: movl   2(<table=%r11,<q33=%rdi,8),>q33=%edi
movl   2(%r11,%rdi,8),%edi

# qhasm: (uint32) q33 &= 0xff000000
# asm 1: and  $0xff000000,<q33=int64#1d
# asm 2: and  $0xff000000,<q33=%edi
and  $0xff000000,%edi

# qhasm: y0 ^= q33
# asm 1: xor  <q33=int64#1,<y0=int64#10
# asm 2: xor  <q33=%rdi,<y0=%r12
xor  %rdi,%r12

# qhasm: out = out_stack
# asm 1: movq <out_stack=stack64#2,>out=int64#1
# asm 2: movq <out_stack=8(%rsp),>out=%rdi
movq 8(%rsp),%rdi

# qhasm: *(uint32 *) (out + 0) = y0
# asm 1: movl   <y0=int64#10d,0(<out=int64#1)
# asm 2: movl   <y0=%r12d,0(<out=%rdi)
movl   %r12d,0(%rdi)

# qhasm: *(uint32 *) (out + 4) = y1
# asm 1: movl   <y1=int64#3d,4(<out=int64#1)
# asm 2: movl   <y1=%edx,4(<out=%rdi)
movl   %edx,4(%rdi)

# qhasm: *(uint32 *) (out + 8) = y2
# asm 1: movl   <y2=int64#12d,8(<out=int64#1)
# asm 2: movl   <y2=%r14d,8(<out=%rdi)
movl   %r14d,8(%rdi)

# qhasm: *(uint32 *) (out + 12) = y3
# asm 1: movl   <y3=int64#11d,12(<out=int64#1)
# asm 2: movl   <y3=%r13d,12(<out=%rdi)
movl   %r13d,12(%rdi)

# qhasm: r11_caller = r11_stack
# asm 1: movq <r11_stack=stack64#3,>r11_caller=int64#9
# asm 2: movq <r11_stack=16(%rsp),>r11_caller=%r11
movq 16(%rsp),%r11

# qhasm: r12_caller = r12_stack
# asm 1: movq <r12_stack=stack64#4,>r12_caller=int64#10
# asm 2: movq <r12_stack=24(%rsp),>r12_caller=%r12
movq 24(%rsp),%r12

# qhasm: r13_caller = r13_stack
# asm 1: movq <r13_stack=stack64#5,>r13_caller=int64#11
# asm 2: movq <r13_stack=32(%rsp),>r13_caller=%r13
movq 32(%rsp),%r13

# qhasm: r14_caller = r14_stack
# asm 1: movq <r14_stack=stack64#6,>r14_caller=int64#12
# asm 2: movq <r14_stack=40(%rsp),>r14_caller=%r14
movq 40(%rsp),%r14

# qhasm: r15_caller = r15_stack
# asm 1: movq <r15_stack=stack64#7,>r15_caller=int64#13
# asm 2: movq <r15_stack=48(%rsp),>r15_caller=%r15
movq 48(%rsp),%r15

# qhasm: rbp_caller = rbp_stack
# asm 1: movq <rbp_stack=stack64#8,>rbp_caller=int64#14
# asm 2: movq <rbp_stack=56(%rsp),>rbp_caller=%rbx
movq 56(%rsp),%rbx

# qhasm: rbx_caller = rbx_stack
# asm 1: movq <rbx_stack=stack64#9,>rbx_caller=int64#15
# asm 2: movq <rbx_stack=64(%rsp),>rbx_caller=%rbp
movq 64(%rsp),%rbp

# qhasm: leave
add %r11,%rsp
ret
