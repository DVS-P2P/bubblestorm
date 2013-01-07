
# qhasm: int64 r11

# qhasm: int64 r12

# qhasm: int64 r13

# qhasm: int64 r14

# qhasm: int64 r15

# qhasm: int64 rbp

# qhasm: int64 rbx

# qhasm: caller r11

# qhasm: caller r12

# qhasm: caller r13

# qhasm: caller r14

# qhasm: caller r15

# qhasm: caller rbp

# qhasm: caller rbx

# qhasm: stack64 r11_stack

# qhasm: stack64 r12_stack

# qhasm: stack64 r13_stack

# qhasm: stack64 r14_stack

# qhasm: stack64 r15_stack

# qhasm: stack64 rbp_stack

# qhasm: stack64 rbx_stack

# qhasm: int64 arg1

# qhasm: int64 arg2

# qhasm: int64 arg3

# qhasm: int64 arg4

# qhasm: int64 arg5

# qhasm: input arg1

# qhasm: input arg2

# qhasm: input arg3

# qhasm: input arg4

# qhasm: input arg5

# qhasm: int64 out_stack

# qhasm: int64 out

# qhasm: int64 r

# qhasm: int64 s

# qhasm: int64 m

# qhasm: int64 l

# qhasm: int64 m0

# qhasm: int64 m1

# qhasm: int64 m2

# qhasm: int64 m3

# qhasm: float80 a0

# qhasm: float80 a1

# qhasm: float80 a2

# qhasm: float80 a3

# qhasm: float80 h0

# qhasm: float80 h1

# qhasm: float80 h2

# qhasm: float80 h3

# qhasm: float80 x0

# qhasm: float80 x1

# qhasm: float80 x2

# qhasm: float80 x3

# qhasm: float80 y0

# qhasm: float80 y1

# qhasm: float80 y2

# qhasm: float80 y3

# qhasm: float80 r0x0

# qhasm: float80 r1x0

# qhasm: float80 r2x0

# qhasm: float80 r3x0

# qhasm: float80 r0x1

# qhasm: float80 r1x1

# qhasm: float80 r2x1

# qhasm: float80 sr3x1

# qhasm: float80 r0x2

# qhasm: float80 r1x2

# qhasm: float80 sr2x2

# qhasm: float80 sr3x2

# qhasm: float80 r0x3

# qhasm: float80 sr1x3

# qhasm: float80 sr2x3

# qhasm: float80 sr3x3

# qhasm: stack64 d0

# qhasm: stack64 d1

# qhasm: stack64 d2

# qhasm: stack64 d3

# qhasm: stack64 r0

# qhasm: stack64 r1

# qhasm: stack64 r2

# qhasm: stack64 r3

# qhasm: stack64 sr1

# qhasm: stack64 sr2

# qhasm: stack64 sr3

# qhasm: enter poly1305_amd64 stackaligned4096 poly1305_amd64_constants
.text
.p2align 5
.globl _poly1305_amd64
.globl poly1305_amd64
_poly1305_amd64:
poly1305_amd64:
mov %rsp,%r11
lea poly1305_amd64_constants(%rip),%r10
sub %r10,%r11
and $4095,%r11
add $192,%r11
sub %r11,%rsp

# qhasm:   r11_stack = r11
# asm 1: movq <r11=int64#9,>r11_stack=stack64#1
# asm 2: movq <r11=%r11,>r11_stack=32(%rsp)
movq %r11,32(%rsp)

# qhasm:   r12_stack = r12
# asm 1: movq <r12=int64#10,>r12_stack=stack64#2
# asm 2: movq <r12=%r12,>r12_stack=40(%rsp)
movq %r12,40(%rsp)

# qhasm:   r13_stack = r13
# asm 1: movq <r13=int64#11,>r13_stack=stack64#3
# asm 2: movq <r13=%r13,>r13_stack=48(%rsp)
movq %r13,48(%rsp)

# qhasm:   r14_stack = r14
# asm 1: movq <r14=int64#12,>r14_stack=stack64#4
# asm 2: movq <r14=%r14,>r14_stack=56(%rsp)
movq %r14,56(%rsp)

# qhasm:   r15_stack = r15
# asm 1: movq <r15=int64#13,>r15_stack=stack64#5
# asm 2: movq <r15=%r15,>r15_stack=64(%rsp)
movq %r15,64(%rsp)

# qhasm:   rbp_stack = rbp
# asm 1: movq <rbp=int64#14,>rbp_stack=stack64#6
# asm 2: movq <rbp=%rbx,>rbp_stack=72(%rsp)
movq %rbx,72(%rsp)

# qhasm:   rbx_stack = rbx
# asm 1: movq <rbx=int64#15,>rbx_stack=stack64#7
# asm 2: movq <rbx=%rbp,>rbx_stack=80(%rsp)
movq %rbp,80(%rsp)

# qhasm:   out_stack = arg1
# asm 1: mov  <arg1=int64#1,>out_stack=int64#6
# asm 2: mov  <arg1=%rdi,>out_stack=%r9
mov  %rdi,%r9

# qhasm:   round *(uint16 *) &poly1305_amd64_rounding
fldcw poly1305_amd64_rounding(%rip)

# qhasm:   r = arg2
# asm 1: mov  <arg2=int64#2,>r=int64#1
# asm 2: mov  <arg2=%rsi,>r=%rdi
mov  %rsi,%rdi

# qhasm:   a0 = *(int32 *) (r + 0)
# asm 1: fildl 0(<r=int64#1)
# asm 2: fildl 0(<r=%rdi)
fildl 0(%rdi)
# comment:fpstackfrombottom:<a0#21:

# qhasm:   *(float64 *) &r0 = a0
# asm 1: fstpl >r0=stack64#8
# asm 2: fstpl >r0=88(%rsp)
fstpl 88(%rsp)
# comment:fpstackfrombottom:

# qhasm:   a1 = *(int32 *) (r + 4)
# asm 1: fildl 4(<r=int64#1)
# asm 2: fildl 4(<r=%rdi)
fildl 4(%rdi)
# comment:fpstackfrombottom:<a1#23:

# qhasm:   a1 *= *(float64 *) &poly1305_amd64_two32
fmull poly1305_amd64_two32(%rip)
# comment:fpstackfrombottom:<a1#23:

# qhasm:   *(float64 *) &r1 = a1
# asm 1: fstl >r1=stack64#9
# asm 2: fstl >r1=96(%rsp)
fstl 96(%rsp)
# comment:fpstackfrombottom:<a1#23:

# qhasm:   a1 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<a1#23:

# qhasm:   *(float64 *) &sr1 = a1
# asm 1: fstpl >sr1=stack64#10
# asm 2: fstpl >sr1=104(%rsp)
fstpl 104(%rsp)
# comment:fpstackfrombottom:

# qhasm:   a2 = *(int32 *) (r + 8)
# asm 1: fildl 8(<r=int64#1)
# asm 2: fildl 8(<r=%rdi)
fildl 8(%rdi)
# comment:fpstackfrombottom:<a2#26:

# qhasm:   a2 *= *(float64 *) &poly1305_amd64_two64
fmull poly1305_amd64_two64(%rip)
# comment:fpstackfrombottom:<a2#26:

# qhasm:   *(float64 *) &r2 = a2
# asm 1: fstl >r2=stack64#11
# asm 2: fstl >r2=112(%rsp)
fstl 112(%rsp)
# comment:fpstackfrombottom:<a2#26:

# qhasm:   a2 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<a2#26:

# qhasm:   *(float64 *) &sr2 = a2
# asm 1: fstpl >sr2=stack64#12
# asm 2: fstpl >sr2=120(%rsp)
fstpl 120(%rsp)
# comment:fpstackfrombottom:

# qhasm:   a3 = *(int32 *) (r + 12)
# asm 1: fildl 12(<r=int64#1)
# asm 2: fildl 12(<r=%rdi)
fildl 12(%rdi)
# comment:fpstackfrombottom:<a3#29:

# qhasm:   a3 *= *(float64 *) &poly1305_amd64_two96
fmull poly1305_amd64_two96(%rip)
# comment:fpstackfrombottom:<a3#29:

# qhasm:   *(float64 *) &r3 = a3
# asm 1: fstl >r3=stack64#13
# asm 2: fstl >r3=128(%rsp)
fstl 128(%rsp)
# comment:fpstackfrombottom:<a3#29:

# qhasm:   a3 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<a3#29:

# qhasm:   *(float64 *) &sr3 = a3
# asm 1: fstpl >sr3=stack64#14
# asm 2: fstpl >sr3=136(%rsp)
fstpl 136(%rsp)
# comment:fpstackfrombottom:

# qhasm:   h3 = 0
fldz
# comment:fpstackfrombottom:<h3#32:

# qhasm:   h2 = 0
fldz
# comment:fpstackfrombottom:<h3#32:<h2#33:

# qhasm:   h1 = 0
fldz
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:

# qhasm:   h0 = 0
fldz
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   d0 top = 0x43300000
# asm 1: movl  $0x43300000,>d0=stack64#15
# asm 2: movl  $0x43300000,>d0=148(%rsp)
movl  $0x43300000,148(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   d1 top = 0x45300000
# asm 1: movl  $0x45300000,>d1=stack64#16
# asm 2: movl  $0x45300000,>d1=156(%rsp)
movl  $0x45300000,156(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   d2 top = 0x47300000
# asm 1: movl  $0x47300000,>d2=stack64#17
# asm 2: movl  $0x47300000,>d2=164(%rsp)
movl  $0x47300000,164(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   d3 top = 0x49300000
# asm 1: movl  $0x49300000,>d3=stack64#18
# asm 2: movl  $0x49300000,>d3=172(%rsp)
movl  $0x49300000,172(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   m = arg4
# asm 1: mov  <arg4=int64#4,>m=int64#2
# asm 2: mov  <arg4=%rcx,>m=%rsi
mov  %rcx,%rsi
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   l = arg5
# asm 1: mov  <arg5=int64#5,>l=int64#4
# asm 2: mov  <arg5=%r8,>l=%rcx
mov  %r8,%rcx
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:                          unsigned<? l - 16
# asm 1: cmp  $16,<l=int64#4
# asm 2: cmp  $16,<l=%rcx
cmp  $16,%rcx
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:
# comment:fp stack unchanged by jump
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm: goto addatmost15bytes if unsigned<
jb ._addatmost15bytes
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   m3 = *(uint32 *) (m + 12)
# asm 1: movl   12(<m=int64#2),>m3=int64#1d
# asm 2: movl   12(<m=%rsi),>m3=%edi
movl   12(%rsi),%edi
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   m2 = *(uint32 *) (m + 8)
# asm 1: movl   8(<m=int64#2),>m2=int64#5d
# asm 2: movl   8(<m=%rsi),>m2=%r8d
movl   8(%rsi),%r8d
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   m1 = *(uint32 *) (m + 4)
# asm 1: movl   4(<m=int64#2),>m1=int64#7d
# asm 2: movl   4(<m=%rsi),>m1=%eax
movl   4(%rsi),%eax
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   m0 = *(uint32 *) (m + 0)
# asm 1: movl   0(<m=int64#2),>m0=int64#8d
# asm 2: movl   0(<m=%rsi),>m0=%r10d
movl   0(%rsi),%r10d
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   inplace d3 bottom = m3
# asm 1: movl <m3=int64#1d,<d3=stack64#18
# asm 2: movl <m3=%edi,<d3=168(%rsp)
movl %edi,168(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   inplace d2 bottom = m2
# asm 1: movl <m2=int64#5d,<d2=stack64#17
# asm 2: movl <m2=%r8d,<d2=160(%rsp)
movl %r8d,160(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   inplace d1 bottom = m1
# asm 1: movl <m1=int64#7d,<d1=stack64#16
# asm 2: movl <m1=%eax,<d1=152(%rsp)
movl %eax,152(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   inplace d0 bottom = m0
# asm 1: movl <m0=int64#8d,<d0=stack64#15
# asm 2: movl <m0=%r10d,<d0=144(%rsp)
movl %r10d,144(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   m += 16
# asm 1: add  $16,<m=int64#2
# asm 2: add  $16,<m=%rsi
add  $16,%rsi
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   l -= 16
# asm 1: sub  $16,<l=int64#4
# asm 2: sub  $16,<l=%rcx
sub  $16,%rcx
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm: internal stacktop h3
# asm 1: fxch <h3=float80#4
# asm 2: fxch <h3=%st(3)
fxch %st(3)

# qhasm:   h3 += *(float64 *) &d3
# asm 1: faddl <d3=stack64#18
# asm 2: faddl <d3=168(%rsp)
faddl 168(%rsp)
# comment:fpstackfrombottom:<h0#35:<h2#33:<h1#34:<h3#32:

# qhasm:   h3 -= *(float64 *) &poly1305_amd64_doffset3minustwo128
fsubl poly1305_amd64_doffset3minustwo128(%rip)
# comment:fpstackfrombottom:<h0#35:<h2#33:<h1#34:<h3#32:

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#3
# asm 2: fxch <h2=%st(2)
fxch %st(2)

# qhasm:   h2 += *(float64 *) &d2
# asm 1: faddl <d2=stack64#17
# asm 2: faddl <d2=160(%rsp)
faddl 160(%rsp)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h1#34:<h2#33:

# qhasm:   h2 -= *(float64 *) &poly1305_amd64_doffset2
fsubl poly1305_amd64_doffset2(%rip)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h1#34:<h2#33:

# qhasm: internal stacktop h1
# asm 1: fxch <h1=float80#2
# asm 2: fxch <h1=%st(1)
fxch %st(1)

# qhasm:   h1 += *(float64 *) &d1
# asm 1: faddl <d1=stack64#16
# asm 2: faddl <d1=152(%rsp)
faddl 152(%rsp)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:

# qhasm:   h1 -= *(float64 *) &poly1305_amd64_doffset1
fsubl poly1305_amd64_doffset1(%rip)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#4
# asm 2: fxch <h0=%st(3)
fxch %st(3)

# qhasm:   h0 += *(float64 *) &d0
# asm 1: faddl <d0=stack64#15
# asm 2: faddl <d0=144(%rsp)
faddl 144(%rsp)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   h0 -= *(float64 *) &poly1305_amd64_doffset0
fsubl poly1305_amd64_doffset0(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:                                  unsigned<? l - 16
# asm 1: cmp  $16,<l=int64#4
# asm 2: cmp  $16,<l=%rcx
cmp  $16,%rcx
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:
# comment:fp stack unchanged by jump
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm: goto multiplyaddatmost15bytes if unsigned<
jb ._multiplyaddatmost15bytes
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm: multiplyaddatleast16bytes:
._multiplyaddatleast16bytes:
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   m3 = *(uint32 *) (m + 12)
# asm 1: movl   12(<m=int64#2),>m3=int64#1d
# asm 2: movl   12(<m=%rsi),>m3=%edi
movl   12(%rsi),%edi
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   m2 = *(uint32 *) (m + 8)
# asm 1: movl   8(<m=int64#2),>m2=int64#5d
# asm 2: movl   8(<m=%rsi),>m2=%r8d
movl   8(%rsi),%r8d
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   m1 = *(uint32 *) (m + 4)
# asm 1: movl   4(<m=int64#2),>m1=int64#7d
# asm 2: movl   4(<m=%rsi),>m1=%eax
movl   4(%rsi),%eax
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   m0 = *(uint32 *) (m + 0)
# asm 1: movl   0(<m=int64#2),>m0=int64#8d
# asm 2: movl   0(<m=%rsi),>m0=%r10d
movl   0(%rsi),%r10d
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   inplace d3 bottom = m3
# asm 1: movl <m3=int64#1d,<d3=stack64#18
# asm 2: movl <m3=%edi,<d3=168(%rsp)
movl %edi,168(%rsp)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   inplace d2 bottom = m2
# asm 1: movl <m2=int64#5d,<d2=stack64#17
# asm 2: movl <m2=%r8d,<d2=160(%rsp)
movl %r8d,160(%rsp)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   inplace d1 bottom = m1
# asm 1: movl <m1=int64#7d,<d1=stack64#16
# asm 2: movl <m1=%eax,<d1=152(%rsp)
movl %eax,152(%rsp)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   inplace d0 bottom = m0
# asm 1: movl <m0=int64#8d,<d0=stack64#15
# asm 2: movl <m0=%r10d,<d0=144(%rsp)
movl %r10d,144(%rsp)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   m += 16
# asm 1: add  $16,<m=int64#2
# asm 2: add  $16,<m=%rsi
add  $16,%rsi
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   l -= 16
# asm 1: sub  $16,<l=int64#4
# asm 2: sub  $16,<l=%rcx
sub  $16,%rcx
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   x0 = *(float64 *) &poly1305_amd64_alpha130
fldl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#52:

# qhasm:   x0 += h3
# asm 1: fadd <h3=float80#4,<x0=float80#1
# asm 2: fadd <h3=%st(3),<x0=%st(0)
fadd %st(3),%st(0)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#52:

# qhasm:   x0 -= *(float64 *) &poly1305_amd64_alpha130
fsubl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#52:

# qhasm:   h3 -= x0
# asm 1: fsubr <x0=float80#1,<h3=float80#4
# asm 2: fsubr <x0=%st(0),<h3=%st(3)
fsubr %st(0),%st(3)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#52:

# qhasm:   x0 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#52:

# qhasm:   x1 = *(float64 *) &poly1305_amd64_alpha32
fldl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#52:<x1#53:

# qhasm:   x1 += h0
# asm 1: fadd <h0=float80#3,<x1=float80#1
# asm 2: fadd <h0=%st(2),<x1=%st(0)
fadd %st(2),%st(0)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#52:<x1#53:

# qhasm:   x1 -= *(float64 *) &poly1305_amd64_alpha32
fsubl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#52:<x1#53:

# qhasm:   h0 -= x1
# asm 1: fsubr <x1=float80#1,<h0=float80#3
# asm 2: fsubr <x1=%st(0),<h0=%st(2)
fsubr %st(0),%st(2)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#52:<x1#53:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#3
# asm 2: fxch <h0=%st(2)
fxch %st(2)

# qhasm:   x0 += h0
# asm 1: faddp <h0=float80#1,<x0=float80#2
# asm 2: faddp <h0=%st(0),<x0=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<x1#53:<x0#52:

# qhasm:   x2 = *(float64 *) &poly1305_amd64_alpha64
fldl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<x1#53:<x0#52:<x2#54:

# qhasm:   x2 += h1
# asm 1: fadd <h1=float80#6,<x2=float80#1
# asm 2: fadd <h1=%st(5),<x2=%st(0)
fadd %st(5),%st(0)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<x1#53:<x0#52:<x2#54:

# qhasm:   x2 -= *(float64 *) &poly1305_amd64_alpha64
fsubl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<x1#53:<x0#52:<x2#54:

# qhasm:   h1 -= x2
# asm 1: fsubr <x2=float80#1,<h1=float80#6
# asm 2: fsubr <x2=%st(0),<h1=%st(5)
fsubr %st(0),%st(5)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<x1#53:<x0#52:<x2#54:

# qhasm:   x3 = *(float64 *) &poly1305_amd64_alpha96
fldl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<x1#53:<x0#52:<x2#54:<x3#55:

# qhasm:   x3 += h2
# asm 1: fadd <h2=float80#5,<x3=float80#1
# asm 2: fadd <h2=%st(4),<x3=%st(0)
fadd %st(4),%st(0)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<x1#53:<x0#52:<x2#54:<x3#55:

# qhasm:   x3 -= *(float64 *) &poly1305_amd64_alpha96
fsubl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<x1#53:<x0#52:<x2#54:<x3#55:

# qhasm:   h2 -= x3
# asm 1: fsubr <x3=float80#1,<h2=float80#5
# asm 2: fsubr <x3=%st(0),<h2=%st(4)
fsubr %st(0),%st(4)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<x1#53:<x0#52:<x2#54:<x3#55:

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#5
# asm 2: fxch <h2=%st(4)
fxch %st(4)

# qhasm:   x2 += h2
# asm 1: faddp <h2=float80#1,<x2=float80#2
# asm 2: faddp <h2=%st(0),<x2=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h1#34:<h3#32:<x3#55:<x1#53:<x0#52:<x2#54:

# qhasm: internal stacktop h3
# asm 1: fxch <h3=float80#5
# asm 2: fxch <h3=%st(4)
fxch %st(4)

# qhasm:   x3 += h3
# asm 1: faddp <h3=float80#1,<x3=float80#4
# asm 2: faddp <h3=%st(0),<x3=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h1#34:<x2#54:<x3#55:<x1#53:<x0#52:

# qhasm: internal stacktop h1
# asm 1: fxch <h1=float80#5
# asm 2: fxch <h1=%st(4)
fxch %st(4)

# qhasm:   x1 += h1
# asm 1: faddp <h1=float80#1,<x1=float80#2
# asm 2: faddp <h1=%st(0),<x1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x0#52:<x2#54:<x3#55:<x1#53:

# qhasm:   h3 = *(float64 *) &r3
# asm 1: fldl <r3=stack64#13
# asm 2: fldl <r3=128(%rsp)
fldl 128(%rsp)
# comment:fpstackfrombottom:<x0#52:<x2#54:<x3#55:<x1#53:<h3#32:

# qhasm:   h3 *= x0
# asm 1: fmul <x0=float80#5,<h3=float80#1
# asm 2: fmul <x0=%st(4),<h3=%st(0)
fmul %st(4),%st(0)
# comment:fpstackfrombottom:<x0#52:<x2#54:<x3#55:<x1#53:<h3#32:

# qhasm:   h2 = *(float64 *) &r2
# asm 1: fldl <r2=stack64#11
# asm 2: fldl <r2=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<x0#52:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:

# qhasm:   h2 *= x0
# asm 1: fmul <x0=float80#6,<h2=float80#1
# asm 2: fmul <x0=%st(5),<h2=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x0#52:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:

# qhasm:   h1 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#9
# asm 2: fldl <r1=96(%rsp)
fldl 96(%rsp)
# comment:fpstackfrombottom:<x0#52:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:

# qhasm:   h1 *= x0
# asm 1: fmul <x0=float80#7,<h1=float80#1
# asm 2: fmul <x0=%st(6),<h1=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x0#52:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:

# qhasm:   h0 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#8
# asm 2: fldl <r0=88(%rsp)
fldl 88(%rsp)
# comment:fpstackfrombottom:<x0#52:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   h0 *= x0
# asm 1: fmulp <x0=float80#1,<h0=float80#8
# asm 2: fmulp <x0=%st(0),<h0=%st(7)
fmulp %st(0),%st(7)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:

# qhasm:   r2x1 = *(float64 *) &r2
# asm 1: fldl <r2=stack64#11
# asm 2: fldl <r2=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:<r2x1#56:

# qhasm:   r2x1 *= x1
# asm 1: fmul <x1=float80#5,<r2x1=float80#1
# asm 2: fmul <x1=%st(4),<r2x1=%st(0)
fmul %st(4),%st(0)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:<r2x1#56:

# qhasm:   h3 += r2x1
# asm 1: faddp <r2x1=float80#1,<h3=float80#4
# asm 2: faddp <r2x1=%st(0),<h3=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:

# qhasm:   r1x1 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#9
# asm 2: fldl <r1=96(%rsp)
fldl 96(%rsp)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:<r1x1#57:

# qhasm:   r1x1 *= x1
# asm 1: fmul <x1=float80#5,<r1x1=float80#1
# asm 2: fmul <x1=%st(4),<r1x1=%st(0)
fmul %st(4),%st(0)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:<r1x1#57:

# qhasm:   h2 += r1x1
# asm 1: faddp <r1x1=float80#1,<h2=float80#3
# asm 2: faddp <r1x1=%st(0),<h2=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:

# qhasm:   r0x1 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#8
# asm 2: fldl <r0=88(%rsp)
fldl 88(%rsp)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:<r0x1#58:

# qhasm:   r0x1 *= x1
# asm 1: fmul <x1=float80#5,<r0x1=float80#1
# asm 2: fmul <x1=%st(4),<r0x1=%st(0)
fmul %st(4),%st(0)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:<r0x1#58:

# qhasm:   h1 += r0x1
# asm 1: faddp <r0x1=float80#1,<h1=float80#2
# asm 2: faddp <r0x1=%st(0),<h1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:

# qhasm:   sr3x1 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#14
# asm 2: fldl <sr3=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<x1#53:<h3#32:<h2#33:<h1#34:<sr3x1#59:

# qhasm:   sr3x1 *= x1
# asm 1: fmulp <x1=float80#1,<sr3x1=float80#5
# asm 2: fmulp <x1=%st(0),<sr3x1=%st(4)
fmulp %st(0),%st(4)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<sr3x1#59:<h3#32:<h2#33:<h1#34:

# qhasm: internal stacktop sr3x1
# asm 1: fxch <sr3x1=float80#4
# asm 2: fxch <sr3x1=%st(3)
fxch %st(3)

# qhasm:   h0 += sr3x1
# asm 1: faddp <sr3x1=float80#1,<h0=float80#7
# asm 2: faddp <sr3x1=%st(0),<h0=%st(6)
faddp %st(0),%st(6)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<h1#34:<h3#32:<h2#33:

# qhasm:   r1x2 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#9
# asm 2: fldl <r1=96(%rsp)
fldl 96(%rsp)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<h1#34:<h3#32:<h2#33:<r1x2#60:

# qhasm:   r1x2 *= x2
# asm 1: fmul <x2=float80#6,<r1x2=float80#1
# asm 2: fmul <x2=%st(5),<r1x2=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<h1#34:<h3#32:<h2#33:<r1x2#60:

# qhasm:   h3 += r1x2
# asm 1: faddp <r1x2=float80#1,<h3=float80#3
# asm 2: faddp <r1x2=%st(0),<h3=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<h1#34:<h3#32:<h2#33:

# qhasm:   r0x2 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#8
# asm 2: fldl <r0=88(%rsp)
fldl 88(%rsp)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<h1#34:<h3#32:<h2#33:<r0x2#61:

# qhasm:   r0x2 *= x2
# asm 1: fmul <x2=float80#6,<r0x2=float80#1
# asm 2: fmul <x2=%st(5),<r0x2=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<h1#34:<h3#32:<h2#33:<r0x2#61:

# qhasm:   h2 += r0x2
# asm 1: faddp <r0x2=float80#1,<h2=float80#2
# asm 2: faddp <r0x2=%st(0),<h2=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<h1#34:<h3#32:<h2#33:

# qhasm:   sr3x2 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#14
# asm 2: fldl <sr3=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<h1#34:<h3#32:<h2#33:<sr3x2#62:

# qhasm:   sr3x2 *= x2
# asm 1: fmul <x2=float80#6,<sr3x2=float80#1
# asm 2: fmul <x2=%st(5),<sr3x2=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<h1#34:<h3#32:<h2#33:<sr3x2#62:

# qhasm:   h1 += sr3x2
# asm 1: faddp <sr3x2=float80#1,<h1=float80#4
# asm 2: faddp <sr3x2=%st(0),<h1=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<h1#34:<h3#32:<h2#33:

# qhasm:   sr2x2 = *(float64 *) &sr2
# asm 1: fldl <sr2=stack64#12
# asm 2: fldl <sr2=120(%rsp)
fldl 120(%rsp)
# comment:fpstackfrombottom:<h0#35:<x2#54:<x3#55:<h1#34:<h3#32:<h2#33:<sr2x2#63:

# qhasm:   sr2x2 *= x2
# asm 1: fmulp <x2=float80#1,<sr2x2=float80#6
# asm 2: fmulp <x2=%st(0),<sr2x2=%st(5)
fmulp %st(0),%st(5)
# comment:fpstackfrombottom:<h0#35:<sr2x2#63:<x3#55:<h1#34:<h3#32:<h2#33:

# qhasm: internal stacktop sr2x2
# asm 1: fxch <sr2x2=float80#5
# asm 2: fxch <sr2x2=%st(4)
fxch %st(4)

# qhasm:   h0 += sr2x2
# asm 1: faddp <sr2x2=float80#1,<h0=float80#6
# asm 2: faddp <sr2x2=%st(0),<h0=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<h0#35:<h2#33:<x3#55:<h1#34:<h3#32:

# qhasm:   r0x3 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#8
# asm 2: fldl <r0=88(%rsp)
fldl 88(%rsp)
# comment:fpstackfrombottom:<h0#35:<h2#33:<x3#55:<h1#34:<h3#32:<r0x3#64:

# qhasm:   r0x3 *= x3
# asm 1: fmul <x3=float80#4,<r0x3=float80#1
# asm 2: fmul <x3=%st(3),<r0x3=%st(0)
fmul %st(3),%st(0)
# comment:fpstackfrombottom:<h0#35:<h2#33:<x3#55:<h1#34:<h3#32:<r0x3#64:

# qhasm:   h3 += r0x3
# asm 1: faddp <r0x3=float80#1,<h3=float80#2
# asm 2: faddp <r0x3=%st(0),<h3=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h0#35:<h2#33:<x3#55:<h1#34:<h3#32:

# qhasm:   sr3x3 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#14
# asm 2: fldl <sr3=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<h0#35:<h2#33:<x3#55:<h1#34:<h3#32:<sr3x3#65:

# qhasm:   sr3x3 *= x3
# asm 1: fmul <x3=float80#4,<sr3x3=float80#1
# asm 2: fmul <x3=%st(3),<sr3x3=%st(0)
fmul %st(3),%st(0)
# comment:fpstackfrombottom:<h0#35:<h2#33:<x3#55:<h1#34:<h3#32:<sr3x3#65:

# qhasm:   h2 += sr3x3
# asm 1: faddp <sr3x3=float80#1,<h2=float80#5
# asm 2: faddp <sr3x3=%st(0),<h2=%st(4)
faddp %st(0),%st(4)
# comment:fpstackfrombottom:<h0#35:<h2#33:<x3#55:<h1#34:<h3#32:

# qhasm:   sr2x3 = *(float64 *) &sr2
# asm 1: fldl <sr2=stack64#12
# asm 2: fldl <sr2=120(%rsp)
fldl 120(%rsp)
# comment:fpstackfrombottom:<h0#35:<h2#33:<x3#55:<h1#34:<h3#32:<sr2x3#66:

# qhasm:   sr2x3 *= x3
# asm 1: fmul <x3=float80#4,<sr2x3=float80#1
# asm 2: fmul <x3=%st(3),<sr2x3=%st(0)
fmul %st(3),%st(0)
# comment:fpstackfrombottom:<h0#35:<h2#33:<x3#55:<h1#34:<h3#32:<sr2x3#66:

# qhasm:   h1 += sr2x3
# asm 1: faddp <sr2x3=float80#1,<h1=float80#3
# asm 2: faddp <sr2x3=%st(0),<h1=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<h0#35:<h2#33:<x3#55:<h1#34:<h3#32:

# qhasm:   stacktop h2
# asm 1: fxch <h2=float80#4
# asm 2: fxch <h2=%st(3)
fxch %st(3)
# comment:fpstackfrombottom:<h0#35:<h3#32:<x3#55:<h1#34:<h2#33:

# qhasm:   sr1x3 = *(float64 *) &sr1
# asm 1: fldl <sr1=stack64#10
# asm 2: fldl <sr1=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<h0#35:<h3#32:<x3#55:<h1#34:<h2#33:<sr1x3#67:

# qhasm:   sr1x3 *= x3
# asm 1: fmulp <x3=float80#1,<sr1x3=float80#4
# asm 2: fmulp <x3=%st(0),<sr1x3=%st(3)
fmulp %st(0),%st(3)
# comment:fpstackfrombottom:<h0#35:<h3#32:<sr1x3#67:<h1#34:<h2#33:

# qhasm: internal stacktop sr1x3
# asm 1: fxch <sr1x3=float80#3
# asm 2: fxch <sr1x3=%st(2)
fxch %st(2)

# qhasm:   h0 += sr1x3
# asm 1: faddp <sr1x3=float80#1,<h0=float80#5
# asm 2: faddp <sr1x3=%st(0),<h0=%st(4)
faddp %st(0),%st(4)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:

# qhasm:                                    unsigned<? l - 16
# asm 1: cmp  $16,<l=int64#4
# asm 2: cmp  $16,<l=%rcx
cmp  $16,%rcx
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:

# qhasm:   y3 = *(float64 *) &d3
# asm 1: fldl <d3=stack64#18
# asm 2: fldl <d3=168(%rsp)
fldl 168(%rsp)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:<y3#69:

# qhasm:   y3 -= *(float64 *) &poly1305_amd64_doffset3minustwo128
fsubl poly1305_amd64_doffset3minustwo128(%rip)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:<y3#69:

# qhasm:   h3 += y3
# asm 1: faddp <y3=float80#1,<h3=float80#4
# asm 2: faddp <y3=%st(0),<h3=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:

# qhasm:   y2 = *(float64 *) &d2
# asm 1: fldl <d2=stack64#17
# asm 2: fldl <d2=160(%rsp)
fldl 160(%rsp)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:<y2#70:

# qhasm:   y2 -= *(float64 *) &poly1305_amd64_doffset2
fsubl poly1305_amd64_doffset2(%rip)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:<y2#70:

# qhasm:   h2 += y2
# asm 1: faddp <y2=float80#1,<h2=float80#3
# asm 2: faddp <y2=%st(0),<h2=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:

# qhasm:   y1 = *(float64 *) &d1
# asm 1: fldl <d1=stack64#16
# asm 2: fldl <d1=152(%rsp)
fldl 152(%rsp)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:<y1#71:

# qhasm:   y1 -= *(float64 *) &poly1305_amd64_doffset1
fsubl poly1305_amd64_doffset1(%rip)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:<y1#71:

# qhasm:   h1 += y1
# asm 1: faddp <y1=float80#1,<h1=float80#2
# asm 2: faddp <y1=%st(0),<h1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:

# qhasm:   stacktop h0
# asm 1: fxch <h0=float80#4
# asm 2: fxch <h0=%st(3)
fxch %st(3)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   y0 = *(float64 *) &d0
# asm 1: fldl <d0=stack64#15
# asm 2: fldl <d0=144(%rsp)
fldl 144(%rsp)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<y0#72:

# qhasm:   y0 -= *(float64 *) &poly1305_amd64_doffset0
fsubl poly1305_amd64_doffset0(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<y0#72:

# qhasm:   h0 += y0
# asm 1: faddp <y0=float80#1,<h0=float80#2
# asm 2: faddp <y0=%st(0),<h0=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:
# comment:fp stack unchanged by jump
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm: goto multiplyaddatleast16bytes if !unsigned<
jae ._multiplyaddatleast16bytes
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:
# comment:fp stack unchanged by fallthrough
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm: multiplyaddatmost15bytes:
._multiplyaddatmost15bytes:
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   x0 = *(float64 *) &poly1305_amd64_alpha130
fldl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:

# qhasm:   x0 += h3
# asm 1: fadd <h3=float80#4,<x0=float80#1
# asm 2: fadd <h3=%st(3),<x0=%st(0)
fadd %st(3),%st(0)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:

# qhasm:   x0 -= *(float64 *) &poly1305_amd64_alpha130
fsubl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:

# qhasm:   h3 -= x0
# asm 1: fsubr <x0=float80#1,<h3=float80#4
# asm 2: fsubr <x0=%st(0),<h3=%st(3)
fsubr %st(0),%st(3)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:

# qhasm:   x0 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:

# qhasm:   x1 = *(float64 *) &poly1305_amd64_alpha32
fldl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:<x1#74:

# qhasm:   x1 += h0
# asm 1: fadd <h0=float80#3,<x1=float80#1
# asm 2: fadd <h0=%st(2),<x1=%st(0)
fadd %st(2),%st(0)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:<x1#74:

# qhasm:   x1 -= *(float64 *) &poly1305_amd64_alpha32
fsubl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:<x1#74:

# qhasm:   h0 -= x1
# asm 1: fsubr <x1=float80#1,<h0=float80#3
# asm 2: fsubr <x1=%st(0),<h0=%st(2)
fsubr %st(0),%st(2)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:<x1#74:

# qhasm:   x2 = *(float64 *) &poly1305_amd64_alpha64
fldl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:<x1#74:<x2#75:

# qhasm:   x2 += h1
# asm 1: fadd <h1=float80#7,<x2=float80#1
# asm 2: fadd <h1=%st(6),<x2=%st(0)
fadd %st(6),%st(0)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:<x1#74:<x2#75:

# qhasm:   x2 -= *(float64 *) &poly1305_amd64_alpha64
fsubl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:<x1#74:<x2#75:

# qhasm:   h1 -= x2
# asm 1: fsubr <x2=float80#1,<h1=float80#7
# asm 2: fsubr <x2=%st(0),<h1=%st(6)
fsubr %st(0),%st(6)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:<x1#74:<x2#75:

# qhasm:   x3 = *(float64 *) &poly1305_amd64_alpha96
fldl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:<x1#74:<x2#75:<x3#76:

# qhasm:   x3 += h2
# asm 1: fadd <h2=float80#6,<x3=float80#1
# asm 2: fadd <h2=%st(5),<x3=%st(0)
fadd %st(5),%st(0)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:<x1#74:<x2#75:<x3#76:

# qhasm:   x3 -= *(float64 *) &poly1305_amd64_alpha96
fsubl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:<x1#74:<x2#75:<x3#76:

# qhasm:   h2 -= x3
# asm 1: fsubr <x3=float80#1,<h2=float80#6
# asm 2: fsubr <x3=%st(0),<h2=%st(5)
fsubr %st(0),%st(5)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#73:<x1#74:<x2#75:<x3#76:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#5
# asm 2: fxch <h0=%st(4)
fxch %st(4)

# qhasm:   x0 += h0
# asm 1: faddp <h0=float80#1,<x0=float80#4
# asm 2: faddp <h0=%st(0),<x0=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<x3#76:<x0#73:<x1#74:<x2#75:

# qhasm: internal stacktop h1
# asm 1: fxch <h1=float80#7
# asm 2: fxch <h1=%st(6)
fxch %st(6)

# qhasm:   x1 += h1
# asm 1: faddp <h1=float80#1,<x1=float80#2
# asm 2: faddp <h1=%st(0),<x1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#75:<h3#32:<h2#33:<x3#76:<x0#73:<x1#74:

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#4
# asm 2: fxch <h2=%st(3)
fxch %st(3)

# qhasm:   x2 += h2
# asm 1: faddp <h2=float80#1,<x2=float80#6
# asm 2: faddp <h2=%st(0),<x2=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<x2#75:<h3#32:<x1#74:<x3#76:<x0#73:

# qhasm: internal stacktop h3
# asm 1: fxch <h3=float80#4
# asm 2: fxch <h3=%st(3)
fxch %st(3)

# qhasm:   x3 += h3
# asm 1: faddp <h3=float80#1,<x3=float80#2
# asm 2: faddp <h3=%st(0),<x3=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#75:<x0#73:<x1#74:<x3#76:

# qhasm:   h3 = *(float64 *) &r3
# asm 1: fldl <r3=stack64#13
# asm 2: fldl <r3=128(%rsp)
fldl 128(%rsp)
# comment:fpstackfrombottom:<x2#75:<x0#73:<x1#74:<x3#76:<h3#32:

# qhasm:   h3 *= x0
# asm 1: fmul <x0=float80#4,<h3=float80#1
# asm 2: fmul <x0=%st(3),<h3=%st(0)
fmul %st(3),%st(0)
# comment:fpstackfrombottom:<x2#75:<x0#73:<x1#74:<x3#76:<h3#32:

# qhasm:   h2 = *(float64 *) &r2
# asm 1: fldl <r2=stack64#11
# asm 2: fldl <r2=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<x2#75:<x0#73:<x1#74:<x3#76:<h3#32:<h2#33:

# qhasm:   h2 *= x0
# asm 1: fmul <x0=float80#5,<h2=float80#1
# asm 2: fmul <x0=%st(4),<h2=%st(0)
fmul %st(4),%st(0)
# comment:fpstackfrombottom:<x2#75:<x0#73:<x1#74:<x3#76:<h3#32:<h2#33:

# qhasm:   h1 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#9
# asm 2: fldl <r1=96(%rsp)
fldl 96(%rsp)
# comment:fpstackfrombottom:<x2#75:<x0#73:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:

# qhasm:   h1 *= x0
# asm 1: fmul <x0=float80#6,<h1=float80#1
# asm 2: fmul <x0=%st(5),<h1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#75:<x0#73:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:

# qhasm:   h0 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#8
# asm 2: fldl <r0=88(%rsp)
fldl 88(%rsp)
# comment:fpstackfrombottom:<x2#75:<x0#73:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   h0 *= x0
# asm 1: fmulp <x0=float80#1,<h0=float80#7
# asm 2: fmulp <x0=%st(0),<h0=%st(6)
fmulp %st(0),%st(6)
# comment:fpstackfrombottom:<x2#75:<h0#35:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:

# qhasm:   r2x1 = *(float64 *) &r2
# asm 1: fldl <r2=stack64#11
# asm 2: fldl <r2=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<x2#75:<h0#35:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:<r2x1#77:

# qhasm:   r2x1 *= x1
# asm 1: fmul <x1=float80#6,<r2x1=float80#1
# asm 2: fmul <x1=%st(5),<r2x1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#75:<h0#35:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:<r2x1#77:

# qhasm:   h3 += r2x1
# asm 1: faddp <r2x1=float80#1,<h3=float80#4
# asm 2: faddp <r2x1=%st(0),<h3=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<x2#75:<h0#35:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:

# qhasm:   r1x1 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#9
# asm 2: fldl <r1=96(%rsp)
fldl 96(%rsp)
# comment:fpstackfrombottom:<x2#75:<h0#35:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:<r1x1#78:

# qhasm:   r1x1 *= x1
# asm 1: fmul <x1=float80#6,<r1x1=float80#1
# asm 2: fmul <x1=%st(5),<r1x1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#75:<h0#35:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:<r1x1#78:

# qhasm:   h2 += r1x1
# asm 1: faddp <r1x1=float80#1,<h2=float80#3
# asm 2: faddp <r1x1=%st(0),<h2=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<x2#75:<h0#35:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:

# qhasm:   r0x1 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#8
# asm 2: fldl <r0=88(%rsp)
fldl 88(%rsp)
# comment:fpstackfrombottom:<x2#75:<h0#35:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:<r0x1#79:

# qhasm:   r0x1 *= x1
# asm 1: fmul <x1=float80#6,<r0x1=float80#1
# asm 2: fmul <x1=%st(5),<r0x1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#75:<h0#35:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:<r0x1#79:

# qhasm:   h1 += r0x1
# asm 1: faddp <r0x1=float80#1,<h1=float80#2
# asm 2: faddp <r0x1=%st(0),<h1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#75:<h0#35:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:

# qhasm:   sr3x1 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#14
# asm 2: fldl <sr3=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<x2#75:<h0#35:<x1#74:<x3#76:<h3#32:<h2#33:<h1#34:<sr3x1#80:

# qhasm:   sr3x1 *= x1
# asm 1: fmulp <x1=float80#1,<sr3x1=float80#6
# asm 2: fmulp <x1=%st(0),<sr3x1=%st(5)
fmulp %st(0),%st(5)
# comment:fpstackfrombottom:<x2#75:<h0#35:<sr3x1#80:<x3#76:<h3#32:<h2#33:<h1#34:

# qhasm: internal stacktop sr3x1
# asm 1: fxch <sr3x1=float80#5
# asm 2: fxch <sr3x1=%st(4)
fxch %st(4)

# qhasm:   h0 += sr3x1
# asm 1: faddp <sr3x1=float80#1,<h0=float80#6
# asm 2: faddp <sr3x1=%st(0),<h0=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<x2#75:<h0#35:<h1#34:<x3#76:<h3#32:<h2#33:

# qhasm:   r1x2 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#9
# asm 2: fldl <r1=96(%rsp)
fldl 96(%rsp)
# comment:fpstackfrombottom:<x2#75:<h0#35:<h1#34:<x3#76:<h3#32:<h2#33:<r1x2#81:

# qhasm:   r1x2 *= x2
# asm 1: fmul <x2=float80#7,<r1x2=float80#1
# asm 2: fmul <x2=%st(6),<r1x2=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x2#75:<h0#35:<h1#34:<x3#76:<h3#32:<h2#33:<r1x2#81:

# qhasm:   h3 += r1x2
# asm 1: faddp <r1x2=float80#1,<h3=float80#3
# asm 2: faddp <r1x2=%st(0),<h3=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<x2#75:<h0#35:<h1#34:<x3#76:<h3#32:<h2#33:

# qhasm:   r0x2 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#8
# asm 2: fldl <r0=88(%rsp)
fldl 88(%rsp)
# comment:fpstackfrombottom:<x2#75:<h0#35:<h1#34:<x3#76:<h3#32:<h2#33:<r0x2#82:

# qhasm:   r0x2 *= x2
# asm 1: fmul <x2=float80#7,<r0x2=float80#1
# asm 2: fmul <x2=%st(6),<r0x2=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x2#75:<h0#35:<h1#34:<x3#76:<h3#32:<h2#33:<r0x2#82:

# qhasm:   h2 += r0x2
# asm 1: faddp <r0x2=float80#1,<h2=float80#2
# asm 2: faddp <r0x2=%st(0),<h2=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#75:<h0#35:<h1#34:<x3#76:<h3#32:<h2#33:

# qhasm:   sr3x2 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#14
# asm 2: fldl <sr3=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<x2#75:<h0#35:<h1#34:<x3#76:<h3#32:<h2#33:<sr3x2#83:

# qhasm:   sr3x2 *= x2
# asm 1: fmul <x2=float80#7,<sr3x2=float80#1
# asm 2: fmul <x2=%st(6),<sr3x2=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x2#75:<h0#35:<h1#34:<x3#76:<h3#32:<h2#33:<sr3x2#83:

# qhasm:   h1 += sr3x2
# asm 1: faddp <sr3x2=float80#1,<h1=float80#5
# asm 2: faddp <sr3x2=%st(0),<h1=%st(4)
faddp %st(0),%st(4)
# comment:fpstackfrombottom:<x2#75:<h0#35:<h1#34:<x3#76:<h3#32:<h2#33:

# qhasm:   sr2x2 = *(float64 *) &sr2
# asm 1: fldl <sr2=stack64#12
# asm 2: fldl <sr2=120(%rsp)
fldl 120(%rsp)
# comment:fpstackfrombottom:<x2#75:<h0#35:<h1#34:<x3#76:<h3#32:<h2#33:<sr2x2#84:

# qhasm:   sr2x2 *= x2
# asm 1: fmulp <x2=float80#1,<sr2x2=float80#7
# asm 2: fmulp <x2=%st(0),<sr2x2=%st(6)
fmulp %st(0),%st(6)
# comment:fpstackfrombottom:<sr2x2#84:<h0#35:<h1#34:<x3#76:<h3#32:<h2#33:

# qhasm: internal stacktop sr2x2
# asm 1: fxch <sr2x2=float80#6
# asm 2: fxch <sr2x2=%st(5)
fxch %st(5)

# qhasm:   h0 += sr2x2
# asm 1: faddp <sr2x2=float80#1,<h0=float80#5
# asm 2: faddp <sr2x2=%st(0),<h0=%st(4)
faddp %st(0),%st(4)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#76:<h3#32:

# qhasm:   r0x3 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#8
# asm 2: fldl <r0=88(%rsp)
fldl 88(%rsp)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#76:<h3#32:<r0x3#85:

# qhasm:   r0x3 *= x3
# asm 1: fmul <x3=float80#3,<r0x3=float80#1
# asm 2: fmul <x3=%st(2),<r0x3=%st(0)
fmul %st(2),%st(0)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#76:<h3#32:<r0x3#85:

# qhasm:   h3 += r0x3
# asm 1: faddp <r0x3=float80#1,<h3=float80#2
# asm 2: faddp <r0x3=%st(0),<h3=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#76:<h3#32:

# qhasm:   sr3x3 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#14
# asm 2: fldl <sr3=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#76:<h3#32:<sr3x3#86:

# qhasm:   sr3x3 *= x3
# asm 1: fmul <x3=float80#3,<sr3x3=float80#1
# asm 2: fmul <x3=%st(2),<sr3x3=%st(0)
fmul %st(2),%st(0)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#76:<h3#32:<sr3x3#86:

# qhasm:   h2 += sr3x3
# asm 1: faddp <sr3x3=float80#1,<h2=float80#6
# asm 2: faddp <sr3x3=%st(0),<h2=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#76:<h3#32:

# qhasm:   sr2x3 = *(float64 *) &sr2
# asm 1: fldl <sr2=stack64#12
# asm 2: fldl <sr2=120(%rsp)
fldl 120(%rsp)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#76:<h3#32:<sr2x3#87:

# qhasm:   sr2x3 *= x3
# asm 1: fmul <x3=float80#3,<sr2x3=float80#1
# asm 2: fmul <x3=%st(2),<sr2x3=%st(0)
fmul %st(2),%st(0)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#76:<h3#32:<sr2x3#87:

# qhasm:   h1 += sr2x3
# asm 1: faddp <sr2x3=float80#1,<h1=float80#4
# asm 2: faddp <sr2x3=%st(0),<h1=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#76:<h3#32:

# qhasm:   sr1x3 = *(float64 *) &sr1
# asm 1: fldl <sr1=stack64#10
# asm 2: fldl <sr1=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#76:<h3#32:<sr1x3#88:

# qhasm:   sr1x3 *= x3
# asm 1: fmulp <x3=float80#1,<sr1x3=float80#3
# asm 2: fmulp <x3=%st(0),<sr1x3=%st(2)
fmulp %st(0),%st(2)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<sr1x3#88:<h3#32:

# qhasm: internal stacktop sr1x3
# asm 1: fxch <sr1x3=float80#2
# asm 2: fxch <sr1x3=%st(1)
fxch %st(1)

# qhasm:   h0 += sr1x3
# asm 1: faddp <sr1x3=float80#1,<h0=float80#4
# asm 2: faddp <sr1x3=%st(0),<h0=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<h3#32:
# comment:automatically reorganizing fp stack for fallthrough

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#4
# asm 2: fxch <h2=%st(3)
fxch %st(3)
# comment:fpstackfrombottom:<h3#32:<h0#35:<h1#34:<h2#33:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#3
# asm 2: fxch <h0=%st(2)
fxch %st(2)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm: addatmost15bytes:
._addatmost15bytes:
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:                     =? l - 0
# asm 1: cmp  $0,<l=int64#4
# asm 2: cmp  $0,<l=%rcx
cmp  $0,%rcx
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:
# comment:fp stack unchanged by jump
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm: goto nomorebytes if =
je ._nomorebytes
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm: stack128 lastchunk
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm: int64 destination
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   ((uint32 *) &lastchunk)[0] = 0
# asm 1: movl $0,>lastchunk=stack128#1
# asm 2: movl $0,>lastchunk=0(%rsp)
movl $0,0(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   ((uint32 *) &lastchunk)[1] = 0
# asm 1: movl $0,4+<lastchunk=stack128#1
# asm 2: movl $0,4+<lastchunk=0(%rsp)
movl $0,4+0(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   ((uint32 *) &lastchunk)[2] = 0
# asm 1: movl $0,8+<lastchunk=stack128#1
# asm 2: movl $0,8+<lastchunk=0(%rsp)
movl $0,8+0(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   ((uint32 *) &lastchunk)[3] = 0
# asm 1: movl $0,12+<lastchunk=stack128#1
# asm 2: movl $0,12+<lastchunk=0(%rsp)
movl $0,12+0(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   destination = &lastchunk
# asm 1: leaq <lastchunk=stack128#1,>destination=int64#1
# asm 2: leaq <lastchunk=0(%rsp),>destination=%rdi
leaq 0(%rsp),%rdi
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   while (l) { *destination++ = *m++; --l }
rep movsb
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   *(uint8 *) (destination + 0) = 1
# asm 1: movb   $1,0(<destination=int64#1)
# asm 2: movb   $1,0(<destination=%rdi)
movb   $1,0(%rdi)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   m3 = ((uint32 *) &lastchunk)[3]
# asm 1: movl 12+<lastchunk=stack128#1,>m3=int64#1d
# asm 2: movl 12+<lastchunk=0(%rsp),>m3=%edi
movl 12+0(%rsp),%edi
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   m2 = ((uint32 *) &lastchunk)[2]
# asm 1: movl 8+<lastchunk=stack128#1,>m2=int64#2d
# asm 2: movl 8+<lastchunk=0(%rsp),>m2=%esi
movl 8+0(%rsp),%esi
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   m1 = ((uint32 *) &lastchunk)[1]
# asm 1: movl 4+<lastchunk=stack128#1,>m1=int64#4d
# asm 2: movl 4+<lastchunk=0(%rsp),>m1=%ecx
movl 4+0(%rsp),%ecx
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   m0 = ((uint32 *) &lastchunk)[0]
# asm 1: movl <lastchunk=stack128#1,>m0=int64#5d
# asm 2: movl <lastchunk=0(%rsp),>m0=%r8d
movl 0(%rsp),%r8d
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   inplace d3 bottom = m3
# asm 1: movl <m3=int64#1d,<d3=stack64#18
# asm 2: movl <m3=%edi,<d3=168(%rsp)
movl %edi,168(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   inplace d2 bottom = m2
# asm 1: movl <m2=int64#2d,<d2=stack64#17
# asm 2: movl <m2=%esi,<d2=160(%rsp)
movl %esi,160(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   inplace d1 bottom = m1
# asm 1: movl <m1=int64#4d,<d1=stack64#16
# asm 2: movl <m1=%ecx,<d1=152(%rsp)
movl %ecx,152(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   inplace d0 bottom = m0
# asm 1: movl <m0=int64#5d,<d0=stack64#15
# asm 2: movl <m0=%r8d,<d0=144(%rsp)
movl %r8d,144(%rsp)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm: internal stacktop h3
# asm 1: fxch <h3=float80#4
# asm 2: fxch <h3=%st(3)
fxch %st(3)

# qhasm:   h3 += *(float64 *) &d3
# asm 1: faddl <d3=stack64#18
# asm 2: faddl <d3=168(%rsp)
faddl 168(%rsp)
# comment:fpstackfrombottom:<h0#35:<h2#33:<h1#34:<h3#32:

# qhasm:   h3 -= *(float64 *) &poly1305_amd64_doffset3
fsubl poly1305_amd64_doffset3(%rip)
# comment:fpstackfrombottom:<h0#35:<h2#33:<h1#34:<h3#32:

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#3
# asm 2: fxch <h2=%st(2)
fxch %st(2)

# qhasm:   h2 += *(float64 *) &d2
# asm 1: faddl <d2=stack64#17
# asm 2: faddl <d2=160(%rsp)
faddl 160(%rsp)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h1#34:<h2#33:

# qhasm:   h2 -= *(float64 *) &poly1305_amd64_doffset2
fsubl poly1305_amd64_doffset2(%rip)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h1#34:<h2#33:

# qhasm: internal stacktop h1
# asm 1: fxch <h1=float80#2
# asm 2: fxch <h1=%st(1)
fxch %st(1)

# qhasm:   h1 += *(float64 *) &d1
# asm 1: faddl <d1=stack64#16
# asm 2: faddl <d1=152(%rsp)
faddl 152(%rsp)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:

# qhasm:   h1 -= *(float64 *) &poly1305_amd64_doffset1
fsubl poly1305_amd64_doffset1(%rip)
# comment:fpstackfrombottom:<h0#35:<h3#32:<h2#33:<h1#34:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#4
# asm 2: fxch <h0=%st(3)
fxch %st(3)

# qhasm:   h0 += *(float64 *) &d0
# asm 1: faddl <d0=stack64#15
# asm 2: faddl <d0=144(%rsp)
faddl 144(%rsp)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   h0 -= *(float64 *) &poly1305_amd64_doffset0
fsubl poly1305_amd64_doffset0(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:

# qhasm:   x0 = *(float64 *) &poly1305_amd64_alpha130
fldl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:

# qhasm:   x0 += h3
# asm 1: fadd <h3=float80#4,<x0=float80#1
# asm 2: fadd <h3=%st(3),<x0=%st(0)
fadd %st(3),%st(0)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:

# qhasm:   x0 -= *(float64 *) &poly1305_amd64_alpha130
fsubl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:

# qhasm:   h3 -= x0
# asm 1: fsubr <x0=float80#1,<h3=float80#4
# asm 2: fsubr <x0=%st(0),<h3=%st(3)
fsubr %st(0),%st(3)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:

# qhasm:   x0 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:

# qhasm:   x1 = *(float64 *) &poly1305_amd64_alpha32
fldl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:<x1#97:

# qhasm:   x1 += h0
# asm 1: fadd <h0=float80#3,<x1=float80#1
# asm 2: fadd <h0=%st(2),<x1=%st(0)
fadd %st(2),%st(0)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:<x1#97:

# qhasm:   x1 -= *(float64 *) &poly1305_amd64_alpha32
fsubl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:<x1#97:

# qhasm:   h0 -= x1
# asm 1: fsubr <x1=float80#1,<h0=float80#3
# asm 2: fsubr <x1=%st(0),<h0=%st(2)
fsubr %st(0),%st(2)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:<x1#97:

# qhasm:   x2 = *(float64 *) &poly1305_amd64_alpha64
fldl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:<x1#97:<x2#98:

# qhasm:   x2 += h1
# asm 1: fadd <h1=float80#7,<x2=float80#1
# asm 2: fadd <h1=%st(6),<x2=%st(0)
fadd %st(6),%st(0)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:<x1#97:<x2#98:

# qhasm:   x2 -= *(float64 *) &poly1305_amd64_alpha64
fsubl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:<x1#97:<x2#98:

# qhasm:   h1 -= x2
# asm 1: fsubr <x2=float80#1,<h1=float80#7
# asm 2: fsubr <x2=%st(0),<h1=%st(6)
fsubr %st(0),%st(6)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:<x1#97:<x2#98:

# qhasm:   x3 = *(float64 *) &poly1305_amd64_alpha96
fldl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:<x1#97:<x2#98:<x3#99:

# qhasm:   x3 += h2
# asm 1: fadd <h2=float80#6,<x3=float80#1
# asm 2: fadd <h2=%st(5),<x3=%st(0)
fadd %st(5),%st(0)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:<x1#97:<x2#98:<x3#99:

# qhasm:   x3 -= *(float64 *) &poly1305_amd64_alpha96
fsubl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:<x1#97:<x2#98:<x3#99:

# qhasm:   h2 -= x3
# asm 1: fsubr <x3=float80#1,<h2=float80#6
# asm 2: fsubr <x3=%st(0),<h2=%st(5)
fsubr %st(0),%st(5)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<h0#35:<x0#96:<x1#97:<x2#98:<x3#99:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#5
# asm 2: fxch <h0=%st(4)
fxch %st(4)

# qhasm:   x0 += h0
# asm 1: faddp <h0=float80#1,<x0=float80#4
# asm 2: faddp <h0=%st(0),<x0=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h1#34:<h3#32:<h2#33:<x3#99:<x0#96:<x1#97:<x2#98:

# qhasm: internal stacktop h1
# asm 1: fxch <h1=float80#7
# asm 2: fxch <h1=%st(6)
fxch %st(6)

# qhasm:   x1 += h1
# asm 1: faddp <h1=float80#1,<x1=float80#2
# asm 2: faddp <h1=%st(0),<x1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#98:<h3#32:<h2#33:<x3#99:<x0#96:<x1#97:

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#4
# asm 2: fxch <h2=%st(3)
fxch %st(3)

# qhasm:   x2 += h2
# asm 1: faddp <h2=float80#1,<x2=float80#6
# asm 2: faddp <h2=%st(0),<x2=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<x2#98:<h3#32:<x1#97:<x3#99:<x0#96:

# qhasm: internal stacktop h3
# asm 1: fxch <h3=float80#4
# asm 2: fxch <h3=%st(3)
fxch %st(3)

# qhasm:   x3 += h3
# asm 1: faddp <h3=float80#1,<x3=float80#2
# asm 2: faddp <h3=%st(0),<x3=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#98:<x0#96:<x1#97:<x3#99:

# qhasm:   h3 = *(float64 *) &r3
# asm 1: fldl <r3=stack64#13
# asm 2: fldl <r3=128(%rsp)
fldl 128(%rsp)
# comment:fpstackfrombottom:<x2#98:<x0#96:<x1#97:<x3#99:<h3#32:

# qhasm:   h3 *= x0
# asm 1: fmul <x0=float80#4,<h3=float80#1
# asm 2: fmul <x0=%st(3),<h3=%st(0)
fmul %st(3),%st(0)
# comment:fpstackfrombottom:<x2#98:<x0#96:<x1#97:<x3#99:<h3#32:

# qhasm:   h2 = *(float64 *) &r2
# asm 1: fldl <r2=stack64#11
# asm 2: fldl <r2=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<x2#98:<x0#96:<x1#97:<x3#99:<h3#32:<h2#33:

# qhasm:   h2 *= x0
# asm 1: fmul <x0=float80#5,<h2=float80#1
# asm 2: fmul <x0=%st(4),<h2=%st(0)
fmul %st(4),%st(0)
# comment:fpstackfrombottom:<x2#98:<x0#96:<x1#97:<x3#99:<h3#32:<h2#33:

# qhasm:   h1 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#9
# asm 2: fldl <r1=96(%rsp)
fldl 96(%rsp)
# comment:fpstackfrombottom:<x2#98:<x0#96:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:

# qhasm:   h1 *= x0
# asm 1: fmul <x0=float80#6,<h1=float80#1
# asm 2: fmul <x0=%st(5),<h1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#98:<x0#96:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:

# qhasm:   h0 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#8
# asm 2: fldl <r0=88(%rsp)
fldl 88(%rsp)
# comment:fpstackfrombottom:<x2#98:<x0#96:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   h0 *= x0
# asm 1: fmulp <x0=float80#1,<h0=float80#7
# asm 2: fmulp <x0=%st(0),<h0=%st(6)
fmulp %st(0),%st(6)
# comment:fpstackfrombottom:<x2#98:<h0#35:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:

# qhasm:   r2x1 = *(float64 *) &r2
# asm 1: fldl <r2=stack64#11
# asm 2: fldl <r2=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<x2#98:<h0#35:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:<r2x1#100:

# qhasm:   r2x1 *= x1
# asm 1: fmul <x1=float80#6,<r2x1=float80#1
# asm 2: fmul <x1=%st(5),<r2x1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#98:<h0#35:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:<r2x1#100:

# qhasm:   h3 += r2x1
# asm 1: faddp <r2x1=float80#1,<h3=float80#4
# asm 2: faddp <r2x1=%st(0),<h3=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<x2#98:<h0#35:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:

# qhasm:   r1x1 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#9
# asm 2: fldl <r1=96(%rsp)
fldl 96(%rsp)
# comment:fpstackfrombottom:<x2#98:<h0#35:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:<r1x1#101:

# qhasm:   r1x1 *= x1
# asm 1: fmul <x1=float80#6,<r1x1=float80#1
# asm 2: fmul <x1=%st(5),<r1x1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#98:<h0#35:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:<r1x1#101:

# qhasm:   h2 += r1x1
# asm 1: faddp <r1x1=float80#1,<h2=float80#3
# asm 2: faddp <r1x1=%st(0),<h2=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<x2#98:<h0#35:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:

# qhasm:   r0x1 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#8
# asm 2: fldl <r0=88(%rsp)
fldl 88(%rsp)
# comment:fpstackfrombottom:<x2#98:<h0#35:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:<r0x1#102:

# qhasm:   r0x1 *= x1
# asm 1: fmul <x1=float80#6,<r0x1=float80#1
# asm 2: fmul <x1=%st(5),<r0x1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#98:<h0#35:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:<r0x1#102:

# qhasm:   h1 += r0x1
# asm 1: faddp <r0x1=float80#1,<h1=float80#2
# asm 2: faddp <r0x1=%st(0),<h1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#98:<h0#35:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:

# qhasm:   sr3x1 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#14
# asm 2: fldl <sr3=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<x2#98:<h0#35:<x1#97:<x3#99:<h3#32:<h2#33:<h1#34:<sr3x1#103:

# qhasm:   sr3x1 *= x1
# asm 1: fmulp <x1=float80#1,<sr3x1=float80#6
# asm 2: fmulp <x1=%st(0),<sr3x1=%st(5)
fmulp %st(0),%st(5)
# comment:fpstackfrombottom:<x2#98:<h0#35:<sr3x1#103:<x3#99:<h3#32:<h2#33:<h1#34:

# qhasm: internal stacktop sr3x1
# asm 1: fxch <sr3x1=float80#5
# asm 2: fxch <sr3x1=%st(4)
fxch %st(4)

# qhasm:   h0 += sr3x1
# asm 1: faddp <sr3x1=float80#1,<h0=float80#6
# asm 2: faddp <sr3x1=%st(0),<h0=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<x2#98:<h0#35:<h1#34:<x3#99:<h3#32:<h2#33:

# qhasm:   r1x2 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#9
# asm 2: fldl <r1=96(%rsp)
fldl 96(%rsp)
# comment:fpstackfrombottom:<x2#98:<h0#35:<h1#34:<x3#99:<h3#32:<h2#33:<r1x2#104:

# qhasm:   r1x2 *= x2
# asm 1: fmul <x2=float80#7,<r1x2=float80#1
# asm 2: fmul <x2=%st(6),<r1x2=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x2#98:<h0#35:<h1#34:<x3#99:<h3#32:<h2#33:<r1x2#104:

# qhasm:   h3 += r1x2
# asm 1: faddp <r1x2=float80#1,<h3=float80#3
# asm 2: faddp <r1x2=%st(0),<h3=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<x2#98:<h0#35:<h1#34:<x3#99:<h3#32:<h2#33:

# qhasm:   r0x2 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#8
# asm 2: fldl <r0=88(%rsp)
fldl 88(%rsp)
# comment:fpstackfrombottom:<x2#98:<h0#35:<h1#34:<x3#99:<h3#32:<h2#33:<r0x2#105:

# qhasm:   r0x2 *= x2
# asm 1: fmul <x2=float80#7,<r0x2=float80#1
# asm 2: fmul <x2=%st(6),<r0x2=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x2#98:<h0#35:<h1#34:<x3#99:<h3#32:<h2#33:<r0x2#105:

# qhasm:   h2 += r0x2
# asm 1: faddp <r0x2=float80#1,<h2=float80#2
# asm 2: faddp <r0x2=%st(0),<h2=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#98:<h0#35:<h1#34:<x3#99:<h3#32:<h2#33:

# qhasm:   sr3x2 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#14
# asm 2: fldl <sr3=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<x2#98:<h0#35:<h1#34:<x3#99:<h3#32:<h2#33:<sr3x2#106:

# qhasm:   sr3x2 *= x2
# asm 1: fmul <x2=float80#7,<sr3x2=float80#1
# asm 2: fmul <x2=%st(6),<sr3x2=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x2#98:<h0#35:<h1#34:<x3#99:<h3#32:<h2#33:<sr3x2#106:

# qhasm:   h1 += sr3x2
# asm 1: faddp <sr3x2=float80#1,<h1=float80#5
# asm 2: faddp <sr3x2=%st(0),<h1=%st(4)
faddp %st(0),%st(4)
# comment:fpstackfrombottom:<x2#98:<h0#35:<h1#34:<x3#99:<h3#32:<h2#33:

# qhasm:   sr2x2 = *(float64 *) &sr2
# asm 1: fldl <sr2=stack64#12
# asm 2: fldl <sr2=120(%rsp)
fldl 120(%rsp)
# comment:fpstackfrombottom:<x2#98:<h0#35:<h1#34:<x3#99:<h3#32:<h2#33:<sr2x2#107:

# qhasm:   sr2x2 *= x2
# asm 1: fmulp <x2=float80#1,<sr2x2=float80#7
# asm 2: fmulp <x2=%st(0),<sr2x2=%st(6)
fmulp %st(0),%st(6)
# comment:fpstackfrombottom:<sr2x2#107:<h0#35:<h1#34:<x3#99:<h3#32:<h2#33:

# qhasm: internal stacktop sr2x2
# asm 1: fxch <sr2x2=float80#6
# asm 2: fxch <sr2x2=%st(5)
fxch %st(5)

# qhasm:   h0 += sr2x2
# asm 1: faddp <sr2x2=float80#1,<h0=float80#5
# asm 2: faddp <sr2x2=%st(0),<h0=%st(4)
faddp %st(0),%st(4)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#99:<h3#32:

# qhasm:   r0x3 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#8
# asm 2: fldl <r0=88(%rsp)
fldl 88(%rsp)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#99:<h3#32:<r0x3#108:

# qhasm:   r0x3 *= x3
# asm 1: fmul <x3=float80#3,<r0x3=float80#1
# asm 2: fmul <x3=%st(2),<r0x3=%st(0)
fmul %st(2),%st(0)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#99:<h3#32:<r0x3#108:

# qhasm:   h3 += r0x3
# asm 1: faddp <r0x3=float80#1,<h3=float80#2
# asm 2: faddp <r0x3=%st(0),<h3=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#99:<h3#32:

# qhasm:   sr3x3 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#14
# asm 2: fldl <sr3=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#99:<h3#32:<sr3x3#109:

# qhasm:   sr3x3 *= x3
# asm 1: fmul <x3=float80#3,<sr3x3=float80#1
# asm 2: fmul <x3=%st(2),<sr3x3=%st(0)
fmul %st(2),%st(0)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#99:<h3#32:<sr3x3#109:

# qhasm:   h2 += sr3x3
# asm 1: faddp <sr3x3=float80#1,<h2=float80#6
# asm 2: faddp <sr3x3=%st(0),<h2=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#99:<h3#32:

# qhasm:   sr2x3 = *(float64 *) &sr2
# asm 1: fldl <sr2=stack64#12
# asm 2: fldl <sr2=120(%rsp)
fldl 120(%rsp)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#99:<h3#32:<sr2x3#110:

# qhasm:   sr2x3 *= x3
# asm 1: fmul <x3=float80#3,<sr2x3=float80#1
# asm 2: fmul <x3=%st(2),<sr2x3=%st(0)
fmul %st(2),%st(0)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#99:<h3#32:<sr2x3#110:

# qhasm:   h1 += sr2x3
# asm 1: faddp <sr2x3=float80#1,<h1=float80#4
# asm 2: faddp <sr2x3=%st(0),<h1=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#99:<h3#32:

# qhasm:   sr1x3 = *(float64 *) &sr1
# asm 1: fldl <sr1=stack64#10
# asm 2: fldl <sr1=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<x3#99:<h3#32:<sr1x3#111:

# qhasm:   sr1x3 *= x3
# asm 1: fmulp <x3=float80#1,<sr1x3=float80#3
# asm 2: fmulp <x3=%st(0),<sr1x3=%st(2)
fmulp %st(0),%st(2)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<sr1x3#111:<h3#32:

# qhasm: internal stacktop sr1x3
# asm 1: fxch <sr1x3=float80#2
# asm 2: fxch <sr1x3=%st(1)
fxch %st(1)

# qhasm:   h0 += sr1x3
# asm 1: faddp <sr1x3=float80#1,<h0=float80#4
# asm 2: faddp <sr1x3=%st(0),<h0=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h2#33:<h0#35:<h1#34:<h3#32:
# comment:automatically reorganizing fp stack for fallthrough

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#4
# asm 2: fxch <h2=%st(3)
fxch %st(3)
# comment:fpstackfrombottom:<h3#32:<h0#35:<h1#34:<h2#33:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#3
# asm 2: fxch <h0=%st(2)
fxch %st(2)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm: nomorebytes:
._nomorebytes:
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:

# qhasm:   x0 = *(float64 *) &poly1305_amd64_alpha130
fldl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:

# qhasm:   x0 += h3
# asm 1: fadd <h3=float80#5,<x0=float80#1
# asm 2: fadd <h3=%st(4),<x0=%st(0)
fadd %st(4),%st(0)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:

# qhasm:   x0 -= *(float64 *) &poly1305_amd64_alpha130
fsubl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:

# qhasm:   h3 -= x0
# asm 1: fsubr <x0=float80#1,<h3=float80#5
# asm 2: fsubr <x0=%st(0),<h3=%st(4)
fsubr %st(0),%st(4)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:

# qhasm:   x0 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:

# qhasm:   x1 = *(float64 *) &poly1305_amd64_alpha32
fldl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:<x1#113:

# qhasm:   x1 += h0
# asm 1: fadd <h0=float80#3,<x1=float80#1
# asm 2: fadd <h0=%st(2),<x1=%st(0)
fadd %st(2),%st(0)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:<x1#113:

# qhasm:   x1 -= *(float64 *) &poly1305_amd64_alpha32
fsubl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:<x1#113:

# qhasm:   h0 -= x1
# asm 1: fsubr <x1=float80#1,<h0=float80#3
# asm 2: fsubr <x1=%st(0),<h0=%st(2)
fsubr %st(0),%st(2)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:<x1#113:

# qhasm:   x2 = *(float64 *) &poly1305_amd64_alpha64
fldl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:<x1#113:<x2#114:

# qhasm:   x2 += h1
# asm 1: fadd <h1=float80#5,<x2=float80#1
# asm 2: fadd <h1=%st(4),<x2=%st(0)
fadd %st(4),%st(0)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:<x1#113:<x2#114:

# qhasm:   x2 -= *(float64 *) &poly1305_amd64_alpha64
fsubl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:<x1#113:<x2#114:

# qhasm:   h1 -= x2
# asm 1: fsubr <x2=float80#1,<h1=float80#5
# asm 2: fsubr <x2=%st(0),<h1=%st(4)
fsubr %st(0),%st(4)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:<x1#113:<x2#114:

# qhasm:   x3 = *(float64 *) &poly1305_amd64_alpha96
fldl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:<x1#113:<x2#114:<x3#115:

# qhasm:   x3 += h2
# asm 1: fadd <h2=float80#7,<x3=float80#1
# asm 2: fadd <h2=%st(6),<x3=%st(0)
fadd %st(6),%st(0)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:<x1#113:<x2#114:<x3#115:

# qhasm:   x3 -= *(float64 *) &poly1305_amd64_alpha96
fsubl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:<x1#113:<x2#114:<x3#115:

# qhasm:   h2 -= x3
# asm 1: fsubr <x3=float80#1,<h2=float80#7
# asm 2: fsubr <x3=%st(0),<h2=%st(6)
fsubr %st(0),%st(6)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<h0#35:<x0#112:<x1#113:<x2#114:<x3#115:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#5
# asm 2: fxch <h0=%st(4)
fxch %st(4)

# qhasm:   x0 += h0
# asm 1: faddp <h0=float80#1,<x0=float80#4
# asm 2: faddp <h0=%st(0),<x0=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h3#32:<h2#33:<h1#34:<x3#115:<x0#112:<x1#113:<x2#114:

# qhasm: internal stacktop h1
# asm 1: fxch <h1=float80#5
# asm 2: fxch <h1=%st(4)
fxch %st(4)

# qhasm:   x1 += h1
# asm 1: faddp <h1=float80#1,<x1=float80#2
# asm 2: faddp <h1=%st(0),<x1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h3#32:<h2#33:<x2#114:<x3#115:<x0#112:<x1#113:

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#5
# asm 2: fxch <h2=%st(4)
fxch %st(4)

# qhasm:   x2 += h2
# asm 1: faddp <h2=float80#1,<x2=float80#4
# asm 2: faddp <h2=%st(0),<x2=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h3#32:<x1#113:<x2#114:<x3#115:<x0#112:

# qhasm: internal stacktop h3
# asm 1: fxch <h3=float80#5
# asm 2: fxch <h3=%st(4)
fxch %st(4)

# qhasm:   x3 += h3
# asm 1: faddp <h3=float80#1,<x3=float80#2
# asm 2: faddp <h3=%st(0),<x3=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x0#112:<x1#113:<x2#114:<x3#115:

# qhasm: internal stacktop x0
# asm 1: fxch <x0=float80#4
# asm 2: fxch <x0=%st(3)
fxch %st(3)

# qhasm:   x0 += *(float64 *) &poly1305_amd64_hoffset0
faddl poly1305_amd64_hoffset0(%rip)
# comment:fpstackfrombottom:<x3#115:<x1#113:<x2#114:<x0#112:

# qhasm: internal stacktop x1
# asm 1: fxch <x1=float80#3
# asm 2: fxch <x1=%st(2)
fxch %st(2)

# qhasm:   x1 += *(float64 *) &poly1305_amd64_hoffset1
faddl poly1305_amd64_hoffset1(%rip)
# comment:fpstackfrombottom:<x3#115:<x0#112:<x2#114:<x1#113:

# qhasm: internal stacktop x2
# asm 1: fxch <x2=float80#2
# asm 2: fxch <x2=%st(1)
fxch %st(1)

# qhasm:   x2 += *(float64 *) &poly1305_amd64_hoffset2
faddl poly1305_amd64_hoffset2(%rip)
# comment:fpstackfrombottom:<x3#115:<x0#112:<x1#113:<x2#114:

# qhasm: internal stacktop x3
# asm 1: fxch <x3=float80#4
# asm 2: fxch <x3=%st(3)
fxch %st(3)

# qhasm:   x3 += *(float64 *) &poly1305_amd64_hoffset3
faddl poly1305_amd64_hoffset3(%rip)
# comment:fpstackfrombottom:<x2#114:<x0#112:<x1#113:<x3#115:

# qhasm: internal stacktop x0
# asm 1: fxch <x0=float80#3
# asm 2: fxch <x0=%st(2)
fxch %st(2)

# qhasm:   *(float64 *) &d0 = x0
# asm 1: fstpl >d0=stack64#8
# asm 2: fstpl >d0=88(%rsp)
fstpl 88(%rsp)
# comment:fpstackfrombottom:<x2#114:<x3#115:<x1#113:

# qhasm:   *(float64 *) &d1 = x1
# asm 1: fstpl >d1=stack64#9
# asm 2: fstpl >d1=96(%rsp)
fstpl 96(%rsp)
# comment:fpstackfrombottom:<x2#114:<x3#115:

# qhasm: internal stacktop x2
# asm 1: fxch <x2=float80#2
# asm 2: fxch <x2=%st(1)
fxch %st(1)

# qhasm:   *(float64 *) &d2 = x2
# asm 1: fstpl >d2=stack64#10
# asm 2: fstpl >d2=104(%rsp)
fstpl 104(%rsp)
# comment:fpstackfrombottom:<x3#115:

# qhasm:   *(float64 *) &d3 = x3
# asm 1: fstpl >d3=stack64#11
# asm 2: fstpl >d3=112(%rsp)
fstpl 112(%rsp)
# comment:fpstackfrombottom:

# qhasm: int64 f0

# qhasm: int64 f1

# qhasm: int64 f2

# qhasm: int64 f3

# qhasm: int64 f4

# qhasm: int64 g0

# qhasm: int64 g1

# qhasm: int64 g2

# qhasm: int64 g3

# qhasm: int64 f

# qhasm: int64 notf

# qhasm:   g0 = top d0
# asm 1: movl <d0=stack64#8,>g0=int64#1d
# asm 2: movl <d0=92(%rsp),>g0=%edi
movl 92(%rsp),%edi

# qhasm:   (uint32) g0 &= 63
# asm 1: and  $63,<g0=int64#1d
# asm 2: and  $63,<g0=%edi
and  $63,%edi

# qhasm:   g1 = top d1
# asm 1: movl <d1=stack64#9,>g1=int64#2d
# asm 2: movl <d1=100(%rsp),>g1=%esi
movl 100(%rsp),%esi

# qhasm:   (uint32) g1 &= 63
# asm 1: and  $63,<g1=int64#2d
# asm 2: and  $63,<g1=%esi
and  $63,%esi

# qhasm:   g2 = top d2
# asm 1: movl <d2=stack64#10,>g2=int64#4d
# asm 2: movl <d2=108(%rsp),>g2=%ecx
movl 108(%rsp),%ecx

# qhasm:   (uint32) g2 &= 63
# asm 1: and  $63,<g2=int64#4d
# asm 2: and  $63,<g2=%ecx
and  $63,%ecx

# qhasm:   g3 = top d3
# asm 1: movl <d3=stack64#11,>g3=int64#5d
# asm 2: movl <d3=116(%rsp),>g3=%r8d
movl 116(%rsp),%r8d

# qhasm:   (uint32) g3 &= 63
# asm 1: and  $63,<g3=int64#5d
# asm 2: and  $63,<g3=%r8d
and  $63,%r8d

# qhasm:   f1 = bottom d1
# asm 1: movl <d1=stack64#9,>f1=int64#7d
# asm 2: movl <d1=96(%rsp),>f1=%eax
movl 96(%rsp),%eax

# qhasm:   carry? (uint32) f1 += g0
# asm 1: add <g0=int64#1d,<f1=int64#7d
# asm 2: add <g0=%edi,<f1=%eax
add %edi,%eax

# qhasm:   f2 = bottom d2
# asm 1: movl <d2=stack64#10,>f2=int64#1d
# asm 2: movl <d2=104(%rsp),>f2=%edi
movl 104(%rsp),%edi

# qhasm:   carry? (uint32) f2 += g1 + carry
# asm 1: adc <g1=int64#2d,<f2=int64#1d
# asm 2: adc <g1=%esi,<f2=%edi
adc %esi,%edi

# qhasm:   f3 = bottom d3
# asm 1: movl <d3=stack64#11,>f3=int64#2d
# asm 2: movl <d3=112(%rsp),>f3=%esi
movl 112(%rsp),%esi

# qhasm:   carry? (uint32) f3 += g2 + carry
# asm 1: adc <g2=int64#4d,<f3=int64#2d
# asm 2: adc <g2=%ecx,<f3=%esi
adc %ecx,%esi

# qhasm:   f4 = 0
# asm 1: mov  $0,>f4=int64#4
# asm 2: mov  $0,>f4=%rcx
mov  $0,%rcx

# qhasm:          (uint32) f4 += g3 + carry
# asm 1: adc <g3=int64#5d,<f4=int64#4d
# asm 2: adc <g3=%r8d,<f4=%ecx
adc %r8d,%ecx

# qhasm:   g0 = 5
# asm 1: mov  $5,>g0=int64#5
# asm 2: mov  $5,>g0=%r8
mov  $5,%r8

# qhasm:   f0 = bottom d0
# asm 1: movl <d0=stack64#8,>f0=int64#8d
# asm 2: movl <d0=88(%rsp),>f0=%r10d
movl 88(%rsp),%r10d

# qhasm:   carry? (uint32) g0 += f0
# asm 1: add <f0=int64#8d,<g0=int64#5d
# asm 2: add <f0=%r10d,<g0=%r8d
add %r10d,%r8d

# qhasm:   g1 = 0
# asm 1: mov  $0,>g1=int64#9
# asm 2: mov  $0,>g1=%r11
mov  $0,%r11

# qhasm:   carry? (uint32) g1 += f1 + carry
# asm 1: adc <f1=int64#7d,<g1=int64#9d
# asm 2: adc <f1=%eax,<g1=%r11d
adc %eax,%r11d

# qhasm:   g2 = 0
# asm 1: mov  $0,>g2=int64#10
# asm 2: mov  $0,>g2=%r12
mov  $0,%r12

# qhasm:   carry? (uint32) g2 += f2 + carry
# asm 1: adc <f2=int64#1d,<g2=int64#10d
# asm 2: adc <f2=%edi,<g2=%r12d
adc %edi,%r12d

# qhasm:   g3 = 0
# asm 1: mov  $0,>g3=int64#11
# asm 2: mov  $0,>g3=%r13
mov  $0,%r13

# qhasm:   carry? (uint32) g3 += f3 + carry
# asm 1: adc <f3=int64#2d,<g3=int64#11d
# asm 2: adc <f3=%esi,<g3=%r13d
adc %esi,%r13d

# qhasm:   f = -4
# asm 1: mov  $-4,>f=int64#12
# asm 2: mov  $-4,>f=%r14
mov  $-4,%r14

# qhasm:          (uint32) f += f4 + carry
# asm 1: adc <f4=int64#4d,<f=int64#12d
# asm 2: adc <f4=%ecx,<f=%r14d
adc %ecx,%r14d

# qhasm:   (int32) f >>= 16
# asm 1: sar  $16,<f=int64#12d
# asm 2: sar  $16,<f=%r14d
sar  $16,%r14d

# qhasm:   notf = f
# asm 1: mov  <f=int64#12,>notf=int64#4
# asm 2: mov  <f=%r14,>notf=%rcx
mov  %r14,%rcx

# qhasm:   (uint32) notf ^= -1
# asm 1: xor  $-1,<notf=int64#4d
# asm 2: xor  $-1,<notf=%ecx
xor  $-1,%ecx

# qhasm:   f0 &= f
# asm 1: and  <f=int64#12,<f0=int64#8
# asm 2: and  <f=%r14,<f0=%r10
and  %r14,%r10

# qhasm:   g0 &= notf
# asm 1: and  <notf=int64#4,<g0=int64#5
# asm 2: and  <notf=%rcx,<g0=%r8
and  %rcx,%r8

# qhasm:   f0 |= g0
# asm 1: or   <g0=int64#5,<f0=int64#8
# asm 2: or   <g0=%r8,<f0=%r10
or   %r8,%r10

# qhasm:   f1 &= f
# asm 1: and  <f=int64#12,<f1=int64#7
# asm 2: and  <f=%r14,<f1=%rax
and  %r14,%rax

# qhasm:   g1 &= notf
# asm 1: and  <notf=int64#4,<g1=int64#9
# asm 2: and  <notf=%rcx,<g1=%r11
and  %rcx,%r11

# qhasm:   f1 |= g1
# asm 1: or   <g1=int64#9,<f1=int64#7
# asm 2: or   <g1=%r11,<f1=%rax
or   %r11,%rax

# qhasm:   f2 &= f
# asm 1: and  <f=int64#12,<f2=int64#1
# asm 2: and  <f=%r14,<f2=%rdi
and  %r14,%rdi

# qhasm:   g2 &= notf
# asm 1: and  <notf=int64#4,<g2=int64#10
# asm 2: and  <notf=%rcx,<g2=%r12
and  %rcx,%r12

# qhasm:   f2 |= g2
# asm 1: or   <g2=int64#10,<f2=int64#1
# asm 2: or   <g2=%r12,<f2=%rdi
or   %r12,%rdi

# qhasm:   f3 &= f
# asm 1: and  <f=int64#12,<f3=int64#2
# asm 2: and  <f=%r14,<f3=%rsi
and  %r14,%rsi

# qhasm:   g3 &= notf
# asm 1: and  <notf=int64#4,<g3=int64#11
# asm 2: and  <notf=%rcx,<g3=%r13
and  %rcx,%r13

# qhasm:   f3 |= g3
# asm 1: or   <g3=int64#11,<f3=int64#2
# asm 2: or   <g3=%r13,<f3=%rsi
or   %r13,%rsi

# qhasm:   s = arg3
# asm 1: mov  <arg3=int64#3,>s=int64#3
# asm 2: mov  <arg3=%rdx,>s=%rdx
mov  %rdx,%rdx

# qhasm:   carry? (uint32) f0 += *(uint32 *) (s + 0)
# asm 1: addl 0(<s=int64#3),<f0=int64#8d
# asm 2: addl 0(<s=%rdx),<f0=%r10d
addl 0(%rdx),%r10d

# qhasm:   carry? (uint32) f1 += *(uint32 *) (s + 4) + carry
# asm 1: adcl 4(<s=int64#3),<f1=int64#7d
# asm 2: adcl 4(<s=%rdx),<f1=%eax
adcl 4(%rdx),%eax

# qhasm:   carry? (uint32) f2 += *(uint32 *) (s + 8) + carry
# asm 1: adcl 8(<s=int64#3),<f2=int64#1d
# asm 2: adcl 8(<s=%rdx),<f2=%edi
adcl 8(%rdx),%edi

# qhasm:          (uint32) f3 += *(uint32 *) (s + 12) + carry
# asm 1: adcl 12(<s=int64#3),<f3=int64#2d
# asm 2: adcl 12(<s=%rdx),<f3=%esi
adcl 12(%rdx),%esi

# qhasm:   out = out_stack
# asm 1: mov  <out_stack=int64#6,>out=int64#3
# asm 2: mov  <out_stack=%r9,>out=%rdx
mov  %r9,%rdx

# qhasm:   *(uint32 *) (out + 0) = f0
# asm 1: movl   <f0=int64#8d,0(<out=int64#3)
# asm 2: movl   <f0=%r10d,0(<out=%rdx)
movl   %r10d,0(%rdx)

# qhasm:   *(uint32 *) (out + 4) = f1
# asm 1: movl   <f1=int64#7d,4(<out=int64#3)
# asm 2: movl   <f1=%eax,4(<out=%rdx)
movl   %eax,4(%rdx)

# qhasm:   *(uint32 *) (out + 8) = f2
# asm 1: movl   <f2=int64#1d,8(<out=int64#3)
# asm 2: movl   <f2=%edi,8(<out=%rdx)
movl   %edi,8(%rdx)

# qhasm:   *(uint32 *) (out + 12) = f3
# asm 1: movl   <f3=int64#2d,12(<out=int64#3)
# asm 2: movl   <f3=%esi,12(<out=%rdx)
movl   %esi,12(%rdx)

# qhasm:   r11 = r11_stack
# asm 1: movq <r11_stack=stack64#1,>r11=int64#9
# asm 2: movq <r11_stack=32(%rsp),>r11=%r11
movq 32(%rsp),%r11

# qhasm:   r12 = r12_stack
# asm 1: movq <r12_stack=stack64#2,>r12=int64#10
# asm 2: movq <r12_stack=40(%rsp),>r12=%r12
movq 40(%rsp),%r12

# qhasm:   r13 = r13_stack
# asm 1: movq <r13_stack=stack64#3,>r13=int64#11
# asm 2: movq <r13_stack=48(%rsp),>r13=%r13
movq 48(%rsp),%r13

# qhasm:   r14 = r14_stack
# asm 1: movq <r14_stack=stack64#4,>r14=int64#12
# asm 2: movq <r14_stack=56(%rsp),>r14=%r14
movq 56(%rsp),%r14

# qhasm:   r15 = r15_stack
# asm 1: movq <r15_stack=stack64#5,>r15=int64#13
# asm 2: movq <r15_stack=64(%rsp),>r15=%r15
movq 64(%rsp),%r15

# qhasm:   rbp = rbp_stack
# asm 1: movq <rbp_stack=stack64#6,>rbp=int64#14
# asm 2: movq <rbp_stack=72(%rsp),>rbp=%rbx
movq 72(%rsp),%rbx

# qhasm:   rbx = rbx_stack
# asm 1: movq <rbx_stack=stack64#7,>rbx=int64#15
# asm 2: movq <rbx_stack=80(%rsp),>rbx=%rbp
movq 80(%rsp),%rbp

# qhasm: leave
add %r11,%rsp
ret
