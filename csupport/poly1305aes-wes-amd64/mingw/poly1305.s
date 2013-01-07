
# qhasm: int64 r11

# qhasm: int64 r12

# qhasm: int64 r13

# qhasm: int64 r14

# qhasm: int64 r15

# qhasm: int64 rdi

# qhasm: int64 rsi

# qhasm: int64 rbp

# qhasm: int64 rbx

# qhasm: caller r11

# qhasm: caller r12

# qhasm: caller r13

# qhasm: caller r14

# qhasm: caller r15

# qhasm: caller rdi

# qhasm: caller rsi

# qhasm: caller rbp

# qhasm: caller rbx

# qhasm: stack64 r11_stack

# qhasm: stack64 r12_stack

# qhasm: stack64 r13_stack

# qhasm: stack64 r14_stack

# qhasm: stack64 r15_stack

# qhasm: stack64 rdi_stack

# qhasm: stack64 rsi_stack

# qhasm: stack64 rbp_stack

# qhasm: stack64 rbx_stack

# qhasm: int64 arg1

# qhasm: int64 arg2

# qhasm: int64 arg3

# qhasm: int64 arg4

# qhasm: stack64 arg5

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
# asm 1: movq <r11=int64#7,>r11_stack=stack64#1
# asm 2: movq <r11=%r11,>r11_stack=32(%rsp)
movq %r11,32(%rsp)

# qhasm:   r12_stack = r12
# asm 1: movq <r12=int64#8,>r12_stack=stack64#2
# asm 2: movq <r12=%r12,>r12_stack=40(%rsp)
movq %r12,40(%rsp)

# qhasm:   r13_stack = r13
# asm 1: movq <r13=int64#9,>r13_stack=stack64#3
# asm 2: movq <r13=%r13,>r13_stack=48(%rsp)
movq %r13,48(%rsp)

# qhasm:   r14_stack = r14
# asm 1: movq <r14=int64#10,>r14_stack=stack64#4
# asm 2: movq <r14=%r14,>r14_stack=56(%rsp)
movq %r14,56(%rsp)

# qhasm:   r15_stack = r15
# asm 1: movq <r15=int64#11,>r15_stack=stack64#5
# asm 2: movq <r15=%r15,>r15_stack=64(%rsp)
movq %r15,64(%rsp)

# qhasm: rdi_stack = rdi
# asm 1: movq <rdi=int64#12,>rdi_stack=stack64#6
# asm 2: movq <rdi=%rdi,>rdi_stack=72(%rsp)
movq %rdi,72(%rsp)

# qhasm: rsi_stack = rsi
# asm 1: movq <rsi=int64#13,>rsi_stack=stack64#7
# asm 2: movq <rsi=%rsi,>rsi_stack=80(%rsp)
movq %rsi,80(%rsp)

# qhasm:   rbp_stack = rbp
# asm 1: movq <rbp=int64#14,>rbp_stack=stack64#8
# asm 2: movq <rbp=%rbp,>rbp_stack=88(%rsp)
movq %rbp,88(%rsp)

# qhasm:   rbx_stack = rbx
# asm 1: movq <rbx=int64#15,>rbx_stack=stack64#9
# asm 2: movq <rbx=%rbx,>rbx_stack=96(%rsp)
movq %rbx,96(%rsp)

# qhasm:   out_stack = arg1
# asm 1: mov  <arg1=int64#1,>out_stack=int64#5
# asm 2: mov  <arg1=%rcx,>out_stack=%rax
mov  %rcx,%rax

# qhasm:   round *(uint16 *) &poly1305_amd64_rounding
fldcw poly1305_amd64_rounding(%rip)

# qhasm:   r = arg2
# asm 1: mov  <arg2=int64#2,>r=int64#1
# asm 2: mov  <arg2=%rdx,>r=%rcx
mov  %rdx,%rcx

# qhasm:   a0 = *(int32 *) (r + 0)
# asm 1: fildl 0(<r=int64#1)
# asm 2: fildl 0(<r=%rcx)
fildl 0(%rcx)
# comment:fpstackfrombottom:<a0#25:

# qhasm:   *(float64 *) &r0 = a0
# asm 1: fstpl >r0=stack64#10
# asm 2: fstpl >r0=104(%rsp)
fstpl 104(%rsp)
# comment:fpstackfrombottom:

# qhasm:   a1 = *(int32 *) (r + 4)
# asm 1: fildl 4(<r=int64#1)
# asm 2: fildl 4(<r=%rcx)
fildl 4(%rcx)
# comment:fpstackfrombottom:<a1#27:

# qhasm:   a1 *= *(float64 *) &poly1305_amd64_two32
fmull poly1305_amd64_two32(%rip)
# comment:fpstackfrombottom:<a1#27:

# qhasm:   *(float64 *) &r1 = a1
# asm 1: fstl >r1=stack64#11
# asm 2: fstl >r1=112(%rsp)
fstl 112(%rsp)
# comment:fpstackfrombottom:<a1#27:

# qhasm:   a1 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<a1#27:

# qhasm:   *(float64 *) &sr1 = a1
# asm 1: fstpl >sr1=stack64#12
# asm 2: fstpl >sr1=120(%rsp)
fstpl 120(%rsp)
# comment:fpstackfrombottom:

# qhasm:   a2 = *(int32 *) (r + 8)
# asm 1: fildl 8(<r=int64#1)
# asm 2: fildl 8(<r=%rcx)
fildl 8(%rcx)
# comment:fpstackfrombottom:<a2#30:

# qhasm:   a2 *= *(float64 *) &poly1305_amd64_two64
fmull poly1305_amd64_two64(%rip)
# comment:fpstackfrombottom:<a2#30:

# qhasm:   *(float64 *) &r2 = a2
# asm 1: fstl >r2=stack64#13
# asm 2: fstl >r2=128(%rsp)
fstl 128(%rsp)
# comment:fpstackfrombottom:<a2#30:

# qhasm:   a2 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<a2#30:

# qhasm:   *(float64 *) &sr2 = a2
# asm 1: fstpl >sr2=stack64#14
# asm 2: fstpl >sr2=136(%rsp)
fstpl 136(%rsp)
# comment:fpstackfrombottom:

# qhasm:   a3 = *(int32 *) (r + 12)
# asm 1: fildl 12(<r=int64#1)
# asm 2: fildl 12(<r=%rcx)
fildl 12(%rcx)
# comment:fpstackfrombottom:<a3#33:

# qhasm:   a3 *= *(float64 *) &poly1305_amd64_two96
fmull poly1305_amd64_two96(%rip)
# comment:fpstackfrombottom:<a3#33:

# qhasm:   *(float64 *) &r3 = a3
# asm 1: fstl >r3=stack64#15
# asm 2: fstl >r3=144(%rsp)
fstl 144(%rsp)
# comment:fpstackfrombottom:<a3#33:

# qhasm:   a3 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<a3#33:

# qhasm:   *(float64 *) &sr3 = a3
# asm 1: fstpl >sr3=stack64#16
# asm 2: fstpl >sr3=152(%rsp)
fstpl 152(%rsp)
# comment:fpstackfrombottom:

# qhasm:   h3 = 0
fldz
# comment:fpstackfrombottom:<h3#36:

# qhasm:   h2 = 0
fldz
# comment:fpstackfrombottom:<h3#36:<h2#37:

# qhasm:   h1 = 0
fldz
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:

# qhasm:   h0 = 0
fldz
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   d0 top = 0x43300000
# asm 1: movl  $0x43300000,>d0=stack64#17
# asm 2: movl  $0x43300000,>d0=164(%rsp)
movl  $0x43300000,164(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   d1 top = 0x45300000
# asm 1: movl  $0x45300000,>d1=stack64#18
# asm 2: movl  $0x45300000,>d1=172(%rsp)
movl  $0x45300000,172(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   d2 top = 0x47300000
# asm 1: movl  $0x47300000,>d2=stack64#19
# asm 2: movl  $0x47300000,>d2=180(%rsp)
movl  $0x47300000,180(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   d3 top = 0x49300000
# asm 1: movl  $0x49300000,>d3=stack64#20
# asm 2: movl  $0x49300000,>d3=188(%rsp)
movl  $0x49300000,188(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   m = arg4
# asm 1: mov  <arg4=int64#4,>m=int64#13
# asm 2: mov  <arg4=%r9,>m=%rsi
mov  %r9,%rsi
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   l = arg5
# asm 1: movq <arg5=stack64#-1,>l=int64#1
# asm 2: movq <arg5=40(%rsp,%r11),>l=%rcx
movq 40(%rsp,%r11),%rcx
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:                          unsigned<? l - 16
# asm 1: cmp  $16,<l=int64#1
# asm 2: cmp  $16,<l=%rcx
cmp  $16,%rcx
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:
# comment:fp stack unchanged by jump
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm: goto addatmost15bytes if unsigned<
jb ._addatmost15bytes
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   m3 = *(uint32 *) (m + 12)
# asm 1: movl   12(<m=int64#13),>m3=int64#2d
# asm 2: movl   12(<m=%rsi),>m3=%edx
movl   12(%rsi),%edx
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   m2 = *(uint32 *) (m + 8)
# asm 1: movl   8(<m=int64#13),>m2=int64#4d
# asm 2: movl   8(<m=%rsi),>m2=%r9d
movl   8(%rsi),%r9d
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   m1 = *(uint32 *) (m + 4)
# asm 1: movl   4(<m=int64#13),>m1=int64#6d
# asm 2: movl   4(<m=%rsi),>m1=%r10d
movl   4(%rsi),%r10d
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   m0 = *(uint32 *) (m + 0)
# asm 1: movl   0(<m=int64#13),>m0=int64#7d
# asm 2: movl   0(<m=%rsi),>m0=%r11d
movl   0(%rsi),%r11d
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   inplace d3 bottom = m3
# asm 1: movl <m3=int64#2d,<d3=stack64#20
# asm 2: movl <m3=%edx,<d3=184(%rsp)
movl %edx,184(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   inplace d2 bottom = m2
# asm 1: movl <m2=int64#4d,<d2=stack64#19
# asm 2: movl <m2=%r9d,<d2=176(%rsp)
movl %r9d,176(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   inplace d1 bottom = m1
# asm 1: movl <m1=int64#6d,<d1=stack64#18
# asm 2: movl <m1=%r10d,<d1=168(%rsp)
movl %r10d,168(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   inplace d0 bottom = m0
# asm 1: movl <m0=int64#7d,<d0=stack64#17
# asm 2: movl <m0=%r11d,<d0=160(%rsp)
movl %r11d,160(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   m += 16
# asm 1: add  $16,<m=int64#13
# asm 2: add  $16,<m=%rsi
add  $16,%rsi
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   l -= 16
# asm 1: sub  $16,<l=int64#1
# asm 2: sub  $16,<l=%rcx
sub  $16,%rcx
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm: internal stacktop h3
# asm 1: fxch <h3=float80#4
# asm 2: fxch <h3=%st(3)
fxch %st(3)

# qhasm:   h3 += *(float64 *) &d3
# asm 1: faddl <d3=stack64#20
# asm 2: faddl <d3=184(%rsp)
faddl 184(%rsp)
# comment:fpstackfrombottom:<h0#39:<h2#37:<h1#38:<h3#36:

# qhasm:   h3 -= *(float64 *) &poly1305_amd64_doffset3minustwo128
fsubl poly1305_amd64_doffset3minustwo128(%rip)
# comment:fpstackfrombottom:<h0#39:<h2#37:<h1#38:<h3#36:

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#3
# asm 2: fxch <h2=%st(2)
fxch %st(2)

# qhasm:   h2 += *(float64 *) &d2
# asm 1: faddl <d2=stack64#19
# asm 2: faddl <d2=176(%rsp)
faddl 176(%rsp)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h1#38:<h2#37:

# qhasm:   h2 -= *(float64 *) &poly1305_amd64_doffset2
fsubl poly1305_amd64_doffset2(%rip)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h1#38:<h2#37:

# qhasm: internal stacktop h1
# asm 1: fxch <h1=float80#2
# asm 2: fxch <h1=%st(1)
fxch %st(1)

# qhasm:   h1 += *(float64 *) &d1
# asm 1: faddl <d1=stack64#18
# asm 2: faddl <d1=168(%rsp)
faddl 168(%rsp)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:

# qhasm:   h1 -= *(float64 *) &poly1305_amd64_doffset1
fsubl poly1305_amd64_doffset1(%rip)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#4
# asm 2: fxch <h0=%st(3)
fxch %st(3)

# qhasm:   h0 += *(float64 *) &d0
# asm 1: faddl <d0=stack64#17
# asm 2: faddl <d0=160(%rsp)
faddl 160(%rsp)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   h0 -= *(float64 *) &poly1305_amd64_doffset0
fsubl poly1305_amd64_doffset0(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:                                  unsigned<? l - 16
# asm 1: cmp  $16,<l=int64#1
# asm 2: cmp  $16,<l=%rcx
cmp  $16,%rcx
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:
# comment:fp stack unchanged by jump
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm: goto multiplyaddatmost15bytes if unsigned<
jb ._multiplyaddatmost15bytes
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm: multiplyaddatleast16bytes:
._multiplyaddatleast16bytes:
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   m3 = *(uint32 *) (m + 12)
# asm 1: movl   12(<m=int64#13),>m3=int64#2d
# asm 2: movl   12(<m=%rsi),>m3=%edx
movl   12(%rsi),%edx
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   m2 = *(uint32 *) (m + 8)
# asm 1: movl   8(<m=int64#13),>m2=int64#4d
# asm 2: movl   8(<m=%rsi),>m2=%r9d
movl   8(%rsi),%r9d
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   m1 = *(uint32 *) (m + 4)
# asm 1: movl   4(<m=int64#13),>m1=int64#6d
# asm 2: movl   4(<m=%rsi),>m1=%r10d
movl   4(%rsi),%r10d
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   m0 = *(uint32 *) (m + 0)
# asm 1: movl   0(<m=int64#13),>m0=int64#7d
# asm 2: movl   0(<m=%rsi),>m0=%r11d
movl   0(%rsi),%r11d
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   inplace d3 bottom = m3
# asm 1: movl <m3=int64#2d,<d3=stack64#20
# asm 2: movl <m3=%edx,<d3=184(%rsp)
movl %edx,184(%rsp)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   inplace d2 bottom = m2
# asm 1: movl <m2=int64#4d,<d2=stack64#19
# asm 2: movl <m2=%r9d,<d2=176(%rsp)
movl %r9d,176(%rsp)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   inplace d1 bottom = m1
# asm 1: movl <m1=int64#6d,<d1=stack64#18
# asm 2: movl <m1=%r10d,<d1=168(%rsp)
movl %r10d,168(%rsp)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   inplace d0 bottom = m0
# asm 1: movl <m0=int64#7d,<d0=stack64#17
# asm 2: movl <m0=%r11d,<d0=160(%rsp)
movl %r11d,160(%rsp)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   m += 16
# asm 1: add  $16,<m=int64#13
# asm 2: add  $16,<m=%rsi
add  $16,%rsi
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   l -= 16
# asm 1: sub  $16,<l=int64#1
# asm 2: sub  $16,<l=%rcx
sub  $16,%rcx
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   x0 = *(float64 *) &poly1305_amd64_alpha130
fldl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#56:

# qhasm:   x0 += h3
# asm 1: fadd <h3=float80#4,<x0=float80#1
# asm 2: fadd <h3=%st(3),<x0=%st(0)
fadd %st(3),%st(0)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#56:

# qhasm:   x0 -= *(float64 *) &poly1305_amd64_alpha130
fsubl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#56:

# qhasm:   h3 -= x0
# asm 1: fsubr <x0=float80#1,<h3=float80#4
# asm 2: fsubr <x0=%st(0),<h3=%st(3)
fsubr %st(0),%st(3)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#56:

# qhasm:   x0 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#56:

# qhasm:   x1 = *(float64 *) &poly1305_amd64_alpha32
fldl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#56:<x1#57:

# qhasm:   x1 += h0
# asm 1: fadd <h0=float80#3,<x1=float80#1
# asm 2: fadd <h0=%st(2),<x1=%st(0)
fadd %st(2),%st(0)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#56:<x1#57:

# qhasm:   x1 -= *(float64 *) &poly1305_amd64_alpha32
fsubl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#56:<x1#57:

# qhasm:   h0 -= x1
# asm 1: fsubr <x1=float80#1,<h0=float80#3
# asm 2: fsubr <x1=%st(0),<h0=%st(2)
fsubr %st(0),%st(2)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#56:<x1#57:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#3
# asm 2: fxch <h0=%st(2)
fxch %st(2)

# qhasm:   x0 += h0
# asm 1: faddp <h0=float80#1,<x0=float80#2
# asm 2: faddp <h0=%st(0),<x0=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<x1#57:<x0#56:

# qhasm:   x2 = *(float64 *) &poly1305_amd64_alpha64
fldl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<x1#57:<x0#56:<x2#58:

# qhasm:   x2 += h1
# asm 1: fadd <h1=float80#6,<x2=float80#1
# asm 2: fadd <h1=%st(5),<x2=%st(0)
fadd %st(5),%st(0)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<x1#57:<x0#56:<x2#58:

# qhasm:   x2 -= *(float64 *) &poly1305_amd64_alpha64
fsubl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<x1#57:<x0#56:<x2#58:

# qhasm:   h1 -= x2
# asm 1: fsubr <x2=float80#1,<h1=float80#6
# asm 2: fsubr <x2=%st(0),<h1=%st(5)
fsubr %st(0),%st(5)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<x1#57:<x0#56:<x2#58:

# qhasm:   x3 = *(float64 *) &poly1305_amd64_alpha96
fldl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<x1#57:<x0#56:<x2#58:<x3#59:

# qhasm:   x3 += h2
# asm 1: fadd <h2=float80#5,<x3=float80#1
# asm 2: fadd <h2=%st(4),<x3=%st(0)
fadd %st(4),%st(0)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<x1#57:<x0#56:<x2#58:<x3#59:

# qhasm:   x3 -= *(float64 *) &poly1305_amd64_alpha96
fsubl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<x1#57:<x0#56:<x2#58:<x3#59:

# qhasm:   h2 -= x3
# asm 1: fsubr <x3=float80#1,<h2=float80#5
# asm 2: fsubr <x3=%st(0),<h2=%st(4)
fsubr %st(0),%st(4)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<x1#57:<x0#56:<x2#58:<x3#59:

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#5
# asm 2: fxch <h2=%st(4)
fxch %st(4)

# qhasm:   x2 += h2
# asm 1: faddp <h2=float80#1,<x2=float80#2
# asm 2: faddp <h2=%st(0),<x2=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h1#38:<h3#36:<x3#59:<x1#57:<x0#56:<x2#58:

# qhasm: internal stacktop h3
# asm 1: fxch <h3=float80#5
# asm 2: fxch <h3=%st(4)
fxch %st(4)

# qhasm:   x3 += h3
# asm 1: faddp <h3=float80#1,<x3=float80#4
# asm 2: faddp <h3=%st(0),<x3=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h1#38:<x2#58:<x3#59:<x1#57:<x0#56:

# qhasm: internal stacktop h1
# asm 1: fxch <h1=float80#5
# asm 2: fxch <h1=%st(4)
fxch %st(4)

# qhasm:   x1 += h1
# asm 1: faddp <h1=float80#1,<x1=float80#2
# asm 2: faddp <h1=%st(0),<x1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x0#56:<x2#58:<x3#59:<x1#57:

# qhasm:   h3 = *(float64 *) &r3
# asm 1: fldl <r3=stack64#15
# asm 2: fldl <r3=144(%rsp)
fldl 144(%rsp)
# comment:fpstackfrombottom:<x0#56:<x2#58:<x3#59:<x1#57:<h3#36:

# qhasm:   h3 *= x0
# asm 1: fmul <x0=float80#5,<h3=float80#1
# asm 2: fmul <x0=%st(4),<h3=%st(0)
fmul %st(4),%st(0)
# comment:fpstackfrombottom:<x0#56:<x2#58:<x3#59:<x1#57:<h3#36:

# qhasm:   h2 = *(float64 *) &r2
# asm 1: fldl <r2=stack64#13
# asm 2: fldl <r2=128(%rsp)
fldl 128(%rsp)
# comment:fpstackfrombottom:<x0#56:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:

# qhasm:   h2 *= x0
# asm 1: fmul <x0=float80#6,<h2=float80#1
# asm 2: fmul <x0=%st(5),<h2=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x0#56:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:

# qhasm:   h1 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#11
# asm 2: fldl <r1=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<x0#56:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:

# qhasm:   h1 *= x0
# asm 1: fmul <x0=float80#7,<h1=float80#1
# asm 2: fmul <x0=%st(6),<h1=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x0#56:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:

# qhasm:   h0 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#10
# asm 2: fldl <r0=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<x0#56:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   h0 *= x0
# asm 1: fmulp <x0=float80#1,<h0=float80#8
# asm 2: fmulp <x0=%st(0),<h0=%st(7)
fmulp %st(0),%st(7)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:

# qhasm:   r2x1 = *(float64 *) &r2
# asm 1: fldl <r2=stack64#13
# asm 2: fldl <r2=128(%rsp)
fldl 128(%rsp)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:<r2x1#60:

# qhasm:   r2x1 *= x1
# asm 1: fmul <x1=float80#5,<r2x1=float80#1
# asm 2: fmul <x1=%st(4),<r2x1=%st(0)
fmul %st(4),%st(0)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:<r2x1#60:

# qhasm:   h3 += r2x1
# asm 1: faddp <r2x1=float80#1,<h3=float80#4
# asm 2: faddp <r2x1=%st(0),<h3=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:

# qhasm:   r1x1 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#11
# asm 2: fldl <r1=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:<r1x1#61:

# qhasm:   r1x1 *= x1
# asm 1: fmul <x1=float80#5,<r1x1=float80#1
# asm 2: fmul <x1=%st(4),<r1x1=%st(0)
fmul %st(4),%st(0)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:<r1x1#61:

# qhasm:   h2 += r1x1
# asm 1: faddp <r1x1=float80#1,<h2=float80#3
# asm 2: faddp <r1x1=%st(0),<h2=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:

# qhasm:   r0x1 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#10
# asm 2: fldl <r0=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:<r0x1#62:

# qhasm:   r0x1 *= x1
# asm 1: fmul <x1=float80#5,<r0x1=float80#1
# asm 2: fmul <x1=%st(4),<r0x1=%st(0)
fmul %st(4),%st(0)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:<r0x1#62:

# qhasm:   h1 += r0x1
# asm 1: faddp <r0x1=float80#1,<h1=float80#2
# asm 2: faddp <r0x1=%st(0),<h1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:

# qhasm:   sr3x1 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#16
# asm 2: fldl <sr3=152(%rsp)
fldl 152(%rsp)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<x1#57:<h3#36:<h2#37:<h1#38:<sr3x1#63:

# qhasm:   sr3x1 *= x1
# asm 1: fmulp <x1=float80#1,<sr3x1=float80#5
# asm 2: fmulp <x1=%st(0),<sr3x1=%st(4)
fmulp %st(0),%st(4)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<sr3x1#63:<h3#36:<h2#37:<h1#38:

# qhasm: internal stacktop sr3x1
# asm 1: fxch <sr3x1=float80#4
# asm 2: fxch <sr3x1=%st(3)
fxch %st(3)

# qhasm:   h0 += sr3x1
# asm 1: faddp <sr3x1=float80#1,<h0=float80#7
# asm 2: faddp <sr3x1=%st(0),<h0=%st(6)
faddp %st(0),%st(6)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<h1#38:<h3#36:<h2#37:

# qhasm:   r1x2 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#11
# asm 2: fldl <r1=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<h1#38:<h3#36:<h2#37:<r1x2#64:

# qhasm:   r1x2 *= x2
# asm 1: fmul <x2=float80#6,<r1x2=float80#1
# asm 2: fmul <x2=%st(5),<r1x2=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<h1#38:<h3#36:<h2#37:<r1x2#64:

# qhasm:   h3 += r1x2
# asm 1: faddp <r1x2=float80#1,<h3=float80#3
# asm 2: faddp <r1x2=%st(0),<h3=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<h1#38:<h3#36:<h2#37:

# qhasm:   r0x2 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#10
# asm 2: fldl <r0=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<h1#38:<h3#36:<h2#37:<r0x2#65:

# qhasm:   r0x2 *= x2
# asm 1: fmul <x2=float80#6,<r0x2=float80#1
# asm 2: fmul <x2=%st(5),<r0x2=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<h1#38:<h3#36:<h2#37:<r0x2#65:

# qhasm:   h2 += r0x2
# asm 1: faddp <r0x2=float80#1,<h2=float80#2
# asm 2: faddp <r0x2=%st(0),<h2=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<h1#38:<h3#36:<h2#37:

# qhasm:   sr3x2 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#16
# asm 2: fldl <sr3=152(%rsp)
fldl 152(%rsp)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<h1#38:<h3#36:<h2#37:<sr3x2#66:

# qhasm:   sr3x2 *= x2
# asm 1: fmul <x2=float80#6,<sr3x2=float80#1
# asm 2: fmul <x2=%st(5),<sr3x2=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<h1#38:<h3#36:<h2#37:<sr3x2#66:

# qhasm:   h1 += sr3x2
# asm 1: faddp <sr3x2=float80#1,<h1=float80#4
# asm 2: faddp <sr3x2=%st(0),<h1=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<h1#38:<h3#36:<h2#37:

# qhasm:   sr2x2 = *(float64 *) &sr2
# asm 1: fldl <sr2=stack64#14
# asm 2: fldl <sr2=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<h0#39:<x2#58:<x3#59:<h1#38:<h3#36:<h2#37:<sr2x2#67:

# qhasm:   sr2x2 *= x2
# asm 1: fmulp <x2=float80#1,<sr2x2=float80#6
# asm 2: fmulp <x2=%st(0),<sr2x2=%st(5)
fmulp %st(0),%st(5)
# comment:fpstackfrombottom:<h0#39:<sr2x2#67:<x3#59:<h1#38:<h3#36:<h2#37:

# qhasm: internal stacktop sr2x2
# asm 1: fxch <sr2x2=float80#5
# asm 2: fxch <sr2x2=%st(4)
fxch %st(4)

# qhasm:   h0 += sr2x2
# asm 1: faddp <sr2x2=float80#1,<h0=float80#6
# asm 2: faddp <sr2x2=%st(0),<h0=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<h0#39:<h2#37:<x3#59:<h1#38:<h3#36:

# qhasm:   r0x3 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#10
# asm 2: fldl <r0=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<h0#39:<h2#37:<x3#59:<h1#38:<h3#36:<r0x3#68:

# qhasm:   r0x3 *= x3
# asm 1: fmul <x3=float80#4,<r0x3=float80#1
# asm 2: fmul <x3=%st(3),<r0x3=%st(0)
fmul %st(3),%st(0)
# comment:fpstackfrombottom:<h0#39:<h2#37:<x3#59:<h1#38:<h3#36:<r0x3#68:

# qhasm:   h3 += r0x3
# asm 1: faddp <r0x3=float80#1,<h3=float80#2
# asm 2: faddp <r0x3=%st(0),<h3=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h0#39:<h2#37:<x3#59:<h1#38:<h3#36:

# qhasm:   sr3x3 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#16
# asm 2: fldl <sr3=152(%rsp)
fldl 152(%rsp)
# comment:fpstackfrombottom:<h0#39:<h2#37:<x3#59:<h1#38:<h3#36:<sr3x3#69:

# qhasm:   sr3x3 *= x3
# asm 1: fmul <x3=float80#4,<sr3x3=float80#1
# asm 2: fmul <x3=%st(3),<sr3x3=%st(0)
fmul %st(3),%st(0)
# comment:fpstackfrombottom:<h0#39:<h2#37:<x3#59:<h1#38:<h3#36:<sr3x3#69:

# qhasm:   h2 += sr3x3
# asm 1: faddp <sr3x3=float80#1,<h2=float80#5
# asm 2: faddp <sr3x3=%st(0),<h2=%st(4)
faddp %st(0),%st(4)
# comment:fpstackfrombottom:<h0#39:<h2#37:<x3#59:<h1#38:<h3#36:

# qhasm:   sr2x3 = *(float64 *) &sr2
# asm 1: fldl <sr2=stack64#14
# asm 2: fldl <sr2=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<h0#39:<h2#37:<x3#59:<h1#38:<h3#36:<sr2x3#70:

# qhasm:   sr2x3 *= x3
# asm 1: fmul <x3=float80#4,<sr2x3=float80#1
# asm 2: fmul <x3=%st(3),<sr2x3=%st(0)
fmul %st(3),%st(0)
# comment:fpstackfrombottom:<h0#39:<h2#37:<x3#59:<h1#38:<h3#36:<sr2x3#70:

# qhasm:   h1 += sr2x3
# asm 1: faddp <sr2x3=float80#1,<h1=float80#3
# asm 2: faddp <sr2x3=%st(0),<h1=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<h0#39:<h2#37:<x3#59:<h1#38:<h3#36:

# qhasm:   stacktop h2
# asm 1: fxch <h2=float80#4
# asm 2: fxch <h2=%st(3)
fxch %st(3)
# comment:fpstackfrombottom:<h0#39:<h3#36:<x3#59:<h1#38:<h2#37:

# qhasm:   sr1x3 = *(float64 *) &sr1
# asm 1: fldl <sr1=stack64#12
# asm 2: fldl <sr1=120(%rsp)
fldl 120(%rsp)
# comment:fpstackfrombottom:<h0#39:<h3#36:<x3#59:<h1#38:<h2#37:<sr1x3#71:

# qhasm:   sr1x3 *= x3
# asm 1: fmulp <x3=float80#1,<sr1x3=float80#4
# asm 2: fmulp <x3=%st(0),<sr1x3=%st(3)
fmulp %st(0),%st(3)
# comment:fpstackfrombottom:<h0#39:<h3#36:<sr1x3#71:<h1#38:<h2#37:

# qhasm: internal stacktop sr1x3
# asm 1: fxch <sr1x3=float80#3
# asm 2: fxch <sr1x3=%st(2)
fxch %st(2)

# qhasm:   h0 += sr1x3
# asm 1: faddp <sr1x3=float80#1,<h0=float80#5
# asm 2: faddp <sr1x3=%st(0),<h0=%st(4)
faddp %st(0),%st(4)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:

# qhasm:                                    unsigned<? l - 16
# asm 1: cmp  $16,<l=int64#1
# asm 2: cmp  $16,<l=%rcx
cmp  $16,%rcx
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:

# qhasm:   y3 = *(float64 *) &d3
# asm 1: fldl <d3=stack64#20
# asm 2: fldl <d3=184(%rsp)
fldl 184(%rsp)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:<y3#73:

# qhasm:   y3 -= *(float64 *) &poly1305_amd64_doffset3minustwo128
fsubl poly1305_amd64_doffset3minustwo128(%rip)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:<y3#73:

# qhasm:   h3 += y3
# asm 1: faddp <y3=float80#1,<h3=float80#4
# asm 2: faddp <y3=%st(0),<h3=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:

# qhasm:   y2 = *(float64 *) &d2
# asm 1: fldl <d2=stack64#19
# asm 2: fldl <d2=176(%rsp)
fldl 176(%rsp)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:<y2#74:

# qhasm:   y2 -= *(float64 *) &poly1305_amd64_doffset2
fsubl poly1305_amd64_doffset2(%rip)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:<y2#74:

# qhasm:   h2 += y2
# asm 1: faddp <y2=float80#1,<h2=float80#3
# asm 2: faddp <y2=%st(0),<h2=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:

# qhasm:   y1 = *(float64 *) &d1
# asm 1: fldl <d1=stack64#18
# asm 2: fldl <d1=168(%rsp)
fldl 168(%rsp)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:<y1#75:

# qhasm:   y1 -= *(float64 *) &poly1305_amd64_doffset1
fsubl poly1305_amd64_doffset1(%rip)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:<y1#75:

# qhasm:   h1 += y1
# asm 1: faddp <y1=float80#1,<h1=float80#2
# asm 2: faddp <y1=%st(0),<h1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:

# qhasm:   stacktop h0
# asm 1: fxch <h0=float80#4
# asm 2: fxch <h0=%st(3)
fxch %st(3)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   y0 = *(float64 *) &d0
# asm 1: fldl <d0=stack64#17
# asm 2: fldl <d0=160(%rsp)
fldl 160(%rsp)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<y0#76:

# qhasm:   y0 -= *(float64 *) &poly1305_amd64_doffset0
fsubl poly1305_amd64_doffset0(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<y0#76:

# qhasm:   h0 += y0
# asm 1: faddp <y0=float80#1,<h0=float80#2
# asm 2: faddp <y0=%st(0),<h0=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:
# comment:fp stack unchanged by jump
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm: goto multiplyaddatleast16bytes if !unsigned<
jae ._multiplyaddatleast16bytes
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:
# comment:fp stack unchanged by fallthrough
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm: multiplyaddatmost15bytes:
._multiplyaddatmost15bytes:
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   x0 = *(float64 *) &poly1305_amd64_alpha130
fldl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:

# qhasm:   x0 += h3
# asm 1: fadd <h3=float80#4,<x0=float80#1
# asm 2: fadd <h3=%st(3),<x0=%st(0)
fadd %st(3),%st(0)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:

# qhasm:   x0 -= *(float64 *) &poly1305_amd64_alpha130
fsubl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:

# qhasm:   h3 -= x0
# asm 1: fsubr <x0=float80#1,<h3=float80#4
# asm 2: fsubr <x0=%st(0),<h3=%st(3)
fsubr %st(0),%st(3)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:

# qhasm:   x0 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:

# qhasm:   x1 = *(float64 *) &poly1305_amd64_alpha32
fldl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:<x1#78:

# qhasm:   x1 += h0
# asm 1: fadd <h0=float80#3,<x1=float80#1
# asm 2: fadd <h0=%st(2),<x1=%st(0)
fadd %st(2),%st(0)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:<x1#78:

# qhasm:   x1 -= *(float64 *) &poly1305_amd64_alpha32
fsubl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:<x1#78:

# qhasm:   h0 -= x1
# asm 1: fsubr <x1=float80#1,<h0=float80#3
# asm 2: fsubr <x1=%st(0),<h0=%st(2)
fsubr %st(0),%st(2)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:<x1#78:

# qhasm:   x2 = *(float64 *) &poly1305_amd64_alpha64
fldl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:<x1#78:<x2#79:

# qhasm:   x2 += h1
# asm 1: fadd <h1=float80#7,<x2=float80#1
# asm 2: fadd <h1=%st(6),<x2=%st(0)
fadd %st(6),%st(0)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:<x1#78:<x2#79:

# qhasm:   x2 -= *(float64 *) &poly1305_amd64_alpha64
fsubl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:<x1#78:<x2#79:

# qhasm:   h1 -= x2
# asm 1: fsubr <x2=float80#1,<h1=float80#7
# asm 2: fsubr <x2=%st(0),<h1=%st(6)
fsubr %st(0),%st(6)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:<x1#78:<x2#79:

# qhasm:   x3 = *(float64 *) &poly1305_amd64_alpha96
fldl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:<x1#78:<x2#79:<x3#80:

# qhasm:   x3 += h2
# asm 1: fadd <h2=float80#6,<x3=float80#1
# asm 2: fadd <h2=%st(5),<x3=%st(0)
fadd %st(5),%st(0)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:<x1#78:<x2#79:<x3#80:

# qhasm:   x3 -= *(float64 *) &poly1305_amd64_alpha96
fsubl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:<x1#78:<x2#79:<x3#80:

# qhasm:   h2 -= x3
# asm 1: fsubr <x3=float80#1,<h2=float80#6
# asm 2: fsubr <x3=%st(0),<h2=%st(5)
fsubr %st(0),%st(5)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#77:<x1#78:<x2#79:<x3#80:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#5
# asm 2: fxch <h0=%st(4)
fxch %st(4)

# qhasm:   x0 += h0
# asm 1: faddp <h0=float80#1,<x0=float80#4
# asm 2: faddp <h0=%st(0),<x0=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<x3#80:<x0#77:<x1#78:<x2#79:

# qhasm: internal stacktop h1
# asm 1: fxch <h1=float80#7
# asm 2: fxch <h1=%st(6)
fxch %st(6)

# qhasm:   x1 += h1
# asm 1: faddp <h1=float80#1,<x1=float80#2
# asm 2: faddp <h1=%st(0),<x1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#79:<h3#36:<h2#37:<x3#80:<x0#77:<x1#78:

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#4
# asm 2: fxch <h2=%st(3)
fxch %st(3)

# qhasm:   x2 += h2
# asm 1: faddp <h2=float80#1,<x2=float80#6
# asm 2: faddp <h2=%st(0),<x2=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<x2#79:<h3#36:<x1#78:<x3#80:<x0#77:

# qhasm: internal stacktop h3
# asm 1: fxch <h3=float80#4
# asm 2: fxch <h3=%st(3)
fxch %st(3)

# qhasm:   x3 += h3
# asm 1: faddp <h3=float80#1,<x3=float80#2
# asm 2: faddp <h3=%st(0),<x3=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#79:<x0#77:<x1#78:<x3#80:

# qhasm:   h3 = *(float64 *) &r3
# asm 1: fldl <r3=stack64#15
# asm 2: fldl <r3=144(%rsp)
fldl 144(%rsp)
# comment:fpstackfrombottom:<x2#79:<x0#77:<x1#78:<x3#80:<h3#36:

# qhasm:   h3 *= x0
# asm 1: fmul <x0=float80#4,<h3=float80#1
# asm 2: fmul <x0=%st(3),<h3=%st(0)
fmul %st(3),%st(0)
# comment:fpstackfrombottom:<x2#79:<x0#77:<x1#78:<x3#80:<h3#36:

# qhasm:   h2 = *(float64 *) &r2
# asm 1: fldl <r2=stack64#13
# asm 2: fldl <r2=128(%rsp)
fldl 128(%rsp)
# comment:fpstackfrombottom:<x2#79:<x0#77:<x1#78:<x3#80:<h3#36:<h2#37:

# qhasm:   h2 *= x0
# asm 1: fmul <x0=float80#5,<h2=float80#1
# asm 2: fmul <x0=%st(4),<h2=%st(0)
fmul %st(4),%st(0)
# comment:fpstackfrombottom:<x2#79:<x0#77:<x1#78:<x3#80:<h3#36:<h2#37:

# qhasm:   h1 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#11
# asm 2: fldl <r1=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<x2#79:<x0#77:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:

# qhasm:   h1 *= x0
# asm 1: fmul <x0=float80#6,<h1=float80#1
# asm 2: fmul <x0=%st(5),<h1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#79:<x0#77:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:

# qhasm:   h0 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#10
# asm 2: fldl <r0=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<x2#79:<x0#77:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   h0 *= x0
# asm 1: fmulp <x0=float80#1,<h0=float80#7
# asm 2: fmulp <x0=%st(0),<h0=%st(6)
fmulp %st(0),%st(6)
# comment:fpstackfrombottom:<x2#79:<h0#39:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:

# qhasm:   r2x1 = *(float64 *) &r2
# asm 1: fldl <r2=stack64#13
# asm 2: fldl <r2=128(%rsp)
fldl 128(%rsp)
# comment:fpstackfrombottom:<x2#79:<h0#39:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:<r2x1#81:

# qhasm:   r2x1 *= x1
# asm 1: fmul <x1=float80#6,<r2x1=float80#1
# asm 2: fmul <x1=%st(5),<r2x1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#79:<h0#39:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:<r2x1#81:

# qhasm:   h3 += r2x1
# asm 1: faddp <r2x1=float80#1,<h3=float80#4
# asm 2: faddp <r2x1=%st(0),<h3=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<x2#79:<h0#39:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:

# qhasm:   r1x1 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#11
# asm 2: fldl <r1=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<x2#79:<h0#39:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:<r1x1#82:

# qhasm:   r1x1 *= x1
# asm 1: fmul <x1=float80#6,<r1x1=float80#1
# asm 2: fmul <x1=%st(5),<r1x1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#79:<h0#39:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:<r1x1#82:

# qhasm:   h2 += r1x1
# asm 1: faddp <r1x1=float80#1,<h2=float80#3
# asm 2: faddp <r1x1=%st(0),<h2=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<x2#79:<h0#39:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:

# qhasm:   r0x1 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#10
# asm 2: fldl <r0=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<x2#79:<h0#39:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:<r0x1#83:

# qhasm:   r0x1 *= x1
# asm 1: fmul <x1=float80#6,<r0x1=float80#1
# asm 2: fmul <x1=%st(5),<r0x1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#79:<h0#39:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:<r0x1#83:

# qhasm:   h1 += r0x1
# asm 1: faddp <r0x1=float80#1,<h1=float80#2
# asm 2: faddp <r0x1=%st(0),<h1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#79:<h0#39:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:

# qhasm:   sr3x1 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#16
# asm 2: fldl <sr3=152(%rsp)
fldl 152(%rsp)
# comment:fpstackfrombottom:<x2#79:<h0#39:<x1#78:<x3#80:<h3#36:<h2#37:<h1#38:<sr3x1#84:

# qhasm:   sr3x1 *= x1
# asm 1: fmulp <x1=float80#1,<sr3x1=float80#6
# asm 2: fmulp <x1=%st(0),<sr3x1=%st(5)
fmulp %st(0),%st(5)
# comment:fpstackfrombottom:<x2#79:<h0#39:<sr3x1#84:<x3#80:<h3#36:<h2#37:<h1#38:

# qhasm: internal stacktop sr3x1
# asm 1: fxch <sr3x1=float80#5
# asm 2: fxch <sr3x1=%st(4)
fxch %st(4)

# qhasm:   h0 += sr3x1
# asm 1: faddp <sr3x1=float80#1,<h0=float80#6
# asm 2: faddp <sr3x1=%st(0),<h0=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<x2#79:<h0#39:<h1#38:<x3#80:<h3#36:<h2#37:

# qhasm:   r1x2 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#11
# asm 2: fldl <r1=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<x2#79:<h0#39:<h1#38:<x3#80:<h3#36:<h2#37:<r1x2#85:

# qhasm:   r1x2 *= x2
# asm 1: fmul <x2=float80#7,<r1x2=float80#1
# asm 2: fmul <x2=%st(6),<r1x2=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x2#79:<h0#39:<h1#38:<x3#80:<h3#36:<h2#37:<r1x2#85:

# qhasm:   h3 += r1x2
# asm 1: faddp <r1x2=float80#1,<h3=float80#3
# asm 2: faddp <r1x2=%st(0),<h3=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<x2#79:<h0#39:<h1#38:<x3#80:<h3#36:<h2#37:

# qhasm:   r0x2 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#10
# asm 2: fldl <r0=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<x2#79:<h0#39:<h1#38:<x3#80:<h3#36:<h2#37:<r0x2#86:

# qhasm:   r0x2 *= x2
# asm 1: fmul <x2=float80#7,<r0x2=float80#1
# asm 2: fmul <x2=%st(6),<r0x2=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x2#79:<h0#39:<h1#38:<x3#80:<h3#36:<h2#37:<r0x2#86:

# qhasm:   h2 += r0x2
# asm 1: faddp <r0x2=float80#1,<h2=float80#2
# asm 2: faddp <r0x2=%st(0),<h2=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#79:<h0#39:<h1#38:<x3#80:<h3#36:<h2#37:

# qhasm:   sr3x2 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#16
# asm 2: fldl <sr3=152(%rsp)
fldl 152(%rsp)
# comment:fpstackfrombottom:<x2#79:<h0#39:<h1#38:<x3#80:<h3#36:<h2#37:<sr3x2#87:

# qhasm:   sr3x2 *= x2
# asm 1: fmul <x2=float80#7,<sr3x2=float80#1
# asm 2: fmul <x2=%st(6),<sr3x2=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x2#79:<h0#39:<h1#38:<x3#80:<h3#36:<h2#37:<sr3x2#87:

# qhasm:   h1 += sr3x2
# asm 1: faddp <sr3x2=float80#1,<h1=float80#5
# asm 2: faddp <sr3x2=%st(0),<h1=%st(4)
faddp %st(0),%st(4)
# comment:fpstackfrombottom:<x2#79:<h0#39:<h1#38:<x3#80:<h3#36:<h2#37:

# qhasm:   sr2x2 = *(float64 *) &sr2
# asm 1: fldl <sr2=stack64#14
# asm 2: fldl <sr2=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<x2#79:<h0#39:<h1#38:<x3#80:<h3#36:<h2#37:<sr2x2#88:

# qhasm:   sr2x2 *= x2
# asm 1: fmulp <x2=float80#1,<sr2x2=float80#7
# asm 2: fmulp <x2=%st(0),<sr2x2=%st(6)
fmulp %st(0),%st(6)
# comment:fpstackfrombottom:<sr2x2#88:<h0#39:<h1#38:<x3#80:<h3#36:<h2#37:

# qhasm: internal stacktop sr2x2
# asm 1: fxch <sr2x2=float80#6
# asm 2: fxch <sr2x2=%st(5)
fxch %st(5)

# qhasm:   h0 += sr2x2
# asm 1: faddp <sr2x2=float80#1,<h0=float80#5
# asm 2: faddp <sr2x2=%st(0),<h0=%st(4)
faddp %st(0),%st(4)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#80:<h3#36:

# qhasm:   r0x3 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#10
# asm 2: fldl <r0=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#80:<h3#36:<r0x3#89:

# qhasm:   r0x3 *= x3
# asm 1: fmul <x3=float80#3,<r0x3=float80#1
# asm 2: fmul <x3=%st(2),<r0x3=%st(0)
fmul %st(2),%st(0)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#80:<h3#36:<r0x3#89:

# qhasm:   h3 += r0x3
# asm 1: faddp <r0x3=float80#1,<h3=float80#2
# asm 2: faddp <r0x3=%st(0),<h3=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#80:<h3#36:

# qhasm:   sr3x3 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#16
# asm 2: fldl <sr3=152(%rsp)
fldl 152(%rsp)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#80:<h3#36:<sr3x3#90:

# qhasm:   sr3x3 *= x3
# asm 1: fmul <x3=float80#3,<sr3x3=float80#1
# asm 2: fmul <x3=%st(2),<sr3x3=%st(0)
fmul %st(2),%st(0)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#80:<h3#36:<sr3x3#90:

# qhasm:   h2 += sr3x3
# asm 1: faddp <sr3x3=float80#1,<h2=float80#6
# asm 2: faddp <sr3x3=%st(0),<h2=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#80:<h3#36:

# qhasm:   sr2x3 = *(float64 *) &sr2
# asm 1: fldl <sr2=stack64#14
# asm 2: fldl <sr2=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#80:<h3#36:<sr2x3#91:

# qhasm:   sr2x3 *= x3
# asm 1: fmul <x3=float80#3,<sr2x3=float80#1
# asm 2: fmul <x3=%st(2),<sr2x3=%st(0)
fmul %st(2),%st(0)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#80:<h3#36:<sr2x3#91:

# qhasm:   h1 += sr2x3
# asm 1: faddp <sr2x3=float80#1,<h1=float80#4
# asm 2: faddp <sr2x3=%st(0),<h1=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#80:<h3#36:

# qhasm:   sr1x3 = *(float64 *) &sr1
# asm 1: fldl <sr1=stack64#12
# asm 2: fldl <sr1=120(%rsp)
fldl 120(%rsp)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#80:<h3#36:<sr1x3#92:

# qhasm:   sr1x3 *= x3
# asm 1: fmulp <x3=float80#1,<sr1x3=float80#3
# asm 2: fmulp <x3=%st(0),<sr1x3=%st(2)
fmulp %st(0),%st(2)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<sr1x3#92:<h3#36:

# qhasm: internal stacktop sr1x3
# asm 1: fxch <sr1x3=float80#2
# asm 2: fxch <sr1x3=%st(1)
fxch %st(1)

# qhasm:   h0 += sr1x3
# asm 1: faddp <sr1x3=float80#1,<h0=float80#4
# asm 2: faddp <sr1x3=%st(0),<h0=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<h3#36:
# comment:automatically reorganizing fp stack for fallthrough

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#4
# asm 2: fxch <h2=%st(3)
fxch %st(3)
# comment:fpstackfrombottom:<h3#36:<h0#39:<h1#38:<h2#37:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#3
# asm 2: fxch <h0=%st(2)
fxch %st(2)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm: addatmost15bytes:
._addatmost15bytes:
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:                     =? l - 0
# asm 1: cmp  $0,<l=int64#1
# asm 2: cmp  $0,<l=%rcx
cmp  $0,%rcx
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:
# comment:fp stack unchanged by jump
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm: goto nomorebytes if =
je ._nomorebytes
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm: stack128 lastchunk
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm: int64 destination
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   ((uint32 *) &lastchunk)[0] = 0
# asm 1: movl $0,>lastchunk=stack128#1
# asm 2: movl $0,>lastchunk=0(%rsp)
movl $0,0(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   ((uint32 *) &lastchunk)[1] = 0
# asm 1: movl $0,4+<lastchunk=stack128#1
# asm 2: movl $0,4+<lastchunk=0(%rsp)
movl $0,4+0(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   ((uint32 *) &lastchunk)[2] = 0
# asm 1: movl $0,8+<lastchunk=stack128#1
# asm 2: movl $0,8+<lastchunk=0(%rsp)
movl $0,8+0(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   ((uint32 *) &lastchunk)[3] = 0
# asm 1: movl $0,12+<lastchunk=stack128#1
# asm 2: movl $0,12+<lastchunk=0(%rsp)
movl $0,12+0(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   destination = &lastchunk
# asm 1: leaq <lastchunk=stack128#1,>destination=int64#12
# asm 2: leaq <lastchunk=0(%rsp),>destination=%rdi
leaq 0(%rsp),%rdi
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   while (l) { *destination++ = *m++; --l }
rep movsb
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   *(uint8 *) (destination + 0) = 1
# asm 1: movb   $1,0(<destination=int64#12)
# asm 2: movb   $1,0(<destination=%rdi)
movb   $1,0(%rdi)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   m3 = ((uint32 *) &lastchunk)[3]
# asm 1: movl 12+<lastchunk=stack128#1,>m3=int64#1d
# asm 2: movl 12+<lastchunk=0(%rsp),>m3=%ecx
movl 12+0(%rsp),%ecx
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   m2 = ((uint32 *) &lastchunk)[2]
# asm 1: movl 8+<lastchunk=stack128#1,>m2=int64#2d
# asm 2: movl 8+<lastchunk=0(%rsp),>m2=%edx
movl 8+0(%rsp),%edx
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   m1 = ((uint32 *) &lastchunk)[1]
# asm 1: movl 4+<lastchunk=stack128#1,>m1=int64#4d
# asm 2: movl 4+<lastchunk=0(%rsp),>m1=%r9d
movl 4+0(%rsp),%r9d
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   m0 = ((uint32 *) &lastchunk)[0]
# asm 1: movl <lastchunk=stack128#1,>m0=int64#6d
# asm 2: movl <lastchunk=0(%rsp),>m0=%r10d
movl 0(%rsp),%r10d
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   inplace d3 bottom = m3
# asm 1: movl <m3=int64#1d,<d3=stack64#20
# asm 2: movl <m3=%ecx,<d3=184(%rsp)
movl %ecx,184(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   inplace d2 bottom = m2
# asm 1: movl <m2=int64#2d,<d2=stack64#19
# asm 2: movl <m2=%edx,<d2=176(%rsp)
movl %edx,176(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   inplace d1 bottom = m1
# asm 1: movl <m1=int64#4d,<d1=stack64#18
# asm 2: movl <m1=%r9d,<d1=168(%rsp)
movl %r9d,168(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   inplace d0 bottom = m0
# asm 1: movl <m0=int64#6d,<d0=stack64#17
# asm 2: movl <m0=%r10d,<d0=160(%rsp)
movl %r10d,160(%rsp)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm: internal stacktop h3
# asm 1: fxch <h3=float80#4
# asm 2: fxch <h3=%st(3)
fxch %st(3)

# qhasm:   h3 += *(float64 *) &d3
# asm 1: faddl <d3=stack64#20
# asm 2: faddl <d3=184(%rsp)
faddl 184(%rsp)
# comment:fpstackfrombottom:<h0#39:<h2#37:<h1#38:<h3#36:

# qhasm:   h3 -= *(float64 *) &poly1305_amd64_doffset3
fsubl poly1305_amd64_doffset3(%rip)
# comment:fpstackfrombottom:<h0#39:<h2#37:<h1#38:<h3#36:

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#3
# asm 2: fxch <h2=%st(2)
fxch %st(2)

# qhasm:   h2 += *(float64 *) &d2
# asm 1: faddl <d2=stack64#19
# asm 2: faddl <d2=176(%rsp)
faddl 176(%rsp)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h1#38:<h2#37:

# qhasm:   h2 -= *(float64 *) &poly1305_amd64_doffset2
fsubl poly1305_amd64_doffset2(%rip)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h1#38:<h2#37:

# qhasm: internal stacktop h1
# asm 1: fxch <h1=float80#2
# asm 2: fxch <h1=%st(1)
fxch %st(1)

# qhasm:   h1 += *(float64 *) &d1
# asm 1: faddl <d1=stack64#18
# asm 2: faddl <d1=168(%rsp)
faddl 168(%rsp)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:

# qhasm:   h1 -= *(float64 *) &poly1305_amd64_doffset1
fsubl poly1305_amd64_doffset1(%rip)
# comment:fpstackfrombottom:<h0#39:<h3#36:<h2#37:<h1#38:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#4
# asm 2: fxch <h0=%st(3)
fxch %st(3)

# qhasm:   h0 += *(float64 *) &d0
# asm 1: faddl <d0=stack64#17
# asm 2: faddl <d0=160(%rsp)
faddl 160(%rsp)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   h0 -= *(float64 *) &poly1305_amd64_doffset0
fsubl poly1305_amd64_doffset0(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:

# qhasm:   x0 = *(float64 *) &poly1305_amd64_alpha130
fldl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:

# qhasm:   x0 += h3
# asm 1: fadd <h3=float80#4,<x0=float80#1
# asm 2: fadd <h3=%st(3),<x0=%st(0)
fadd %st(3),%st(0)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:

# qhasm:   x0 -= *(float64 *) &poly1305_amd64_alpha130
fsubl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:

# qhasm:   h3 -= x0
# asm 1: fsubr <x0=float80#1,<h3=float80#4
# asm 2: fsubr <x0=%st(0),<h3=%st(3)
fsubr %st(0),%st(3)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:

# qhasm:   x0 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:

# qhasm:   x1 = *(float64 *) &poly1305_amd64_alpha32
fldl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:<x1#101:

# qhasm:   x1 += h0
# asm 1: fadd <h0=float80#3,<x1=float80#1
# asm 2: fadd <h0=%st(2),<x1=%st(0)
fadd %st(2),%st(0)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:<x1#101:

# qhasm:   x1 -= *(float64 *) &poly1305_amd64_alpha32
fsubl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:<x1#101:

# qhasm:   h0 -= x1
# asm 1: fsubr <x1=float80#1,<h0=float80#3
# asm 2: fsubr <x1=%st(0),<h0=%st(2)
fsubr %st(0),%st(2)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:<x1#101:

# qhasm:   x2 = *(float64 *) &poly1305_amd64_alpha64
fldl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:<x1#101:<x2#102:

# qhasm:   x2 += h1
# asm 1: fadd <h1=float80#7,<x2=float80#1
# asm 2: fadd <h1=%st(6),<x2=%st(0)
fadd %st(6),%st(0)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:<x1#101:<x2#102:

# qhasm:   x2 -= *(float64 *) &poly1305_amd64_alpha64
fsubl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:<x1#101:<x2#102:

# qhasm:   h1 -= x2
# asm 1: fsubr <x2=float80#1,<h1=float80#7
# asm 2: fsubr <x2=%st(0),<h1=%st(6)
fsubr %st(0),%st(6)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:<x1#101:<x2#102:

# qhasm:   x3 = *(float64 *) &poly1305_amd64_alpha96
fldl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:<x1#101:<x2#102:<x3#103:

# qhasm:   x3 += h2
# asm 1: fadd <h2=float80#6,<x3=float80#1
# asm 2: fadd <h2=%st(5),<x3=%st(0)
fadd %st(5),%st(0)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:<x1#101:<x2#102:<x3#103:

# qhasm:   x3 -= *(float64 *) &poly1305_amd64_alpha96
fsubl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:<x1#101:<x2#102:<x3#103:

# qhasm:   h2 -= x3
# asm 1: fsubr <x3=float80#1,<h2=float80#6
# asm 2: fsubr <x3=%st(0),<h2=%st(5)
fsubr %st(0),%st(5)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<h0#39:<x0#100:<x1#101:<x2#102:<x3#103:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#5
# asm 2: fxch <h0=%st(4)
fxch %st(4)

# qhasm:   x0 += h0
# asm 1: faddp <h0=float80#1,<x0=float80#4
# asm 2: faddp <h0=%st(0),<x0=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h1#38:<h3#36:<h2#37:<x3#103:<x0#100:<x1#101:<x2#102:

# qhasm: internal stacktop h1
# asm 1: fxch <h1=float80#7
# asm 2: fxch <h1=%st(6)
fxch %st(6)

# qhasm:   x1 += h1
# asm 1: faddp <h1=float80#1,<x1=float80#2
# asm 2: faddp <h1=%st(0),<x1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#102:<h3#36:<h2#37:<x3#103:<x0#100:<x1#101:

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#4
# asm 2: fxch <h2=%st(3)
fxch %st(3)

# qhasm:   x2 += h2
# asm 1: faddp <h2=float80#1,<x2=float80#6
# asm 2: faddp <h2=%st(0),<x2=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<x2#102:<h3#36:<x1#101:<x3#103:<x0#100:

# qhasm: internal stacktop h3
# asm 1: fxch <h3=float80#4
# asm 2: fxch <h3=%st(3)
fxch %st(3)

# qhasm:   x3 += h3
# asm 1: faddp <h3=float80#1,<x3=float80#2
# asm 2: faddp <h3=%st(0),<x3=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#102:<x0#100:<x1#101:<x3#103:

# qhasm:   h3 = *(float64 *) &r3
# asm 1: fldl <r3=stack64#15
# asm 2: fldl <r3=144(%rsp)
fldl 144(%rsp)
# comment:fpstackfrombottom:<x2#102:<x0#100:<x1#101:<x3#103:<h3#36:

# qhasm:   h3 *= x0
# asm 1: fmul <x0=float80#4,<h3=float80#1
# asm 2: fmul <x0=%st(3),<h3=%st(0)
fmul %st(3),%st(0)
# comment:fpstackfrombottom:<x2#102:<x0#100:<x1#101:<x3#103:<h3#36:

# qhasm:   h2 = *(float64 *) &r2
# asm 1: fldl <r2=stack64#13
# asm 2: fldl <r2=128(%rsp)
fldl 128(%rsp)
# comment:fpstackfrombottom:<x2#102:<x0#100:<x1#101:<x3#103:<h3#36:<h2#37:

# qhasm:   h2 *= x0
# asm 1: fmul <x0=float80#5,<h2=float80#1
# asm 2: fmul <x0=%st(4),<h2=%st(0)
fmul %st(4),%st(0)
# comment:fpstackfrombottom:<x2#102:<x0#100:<x1#101:<x3#103:<h3#36:<h2#37:

# qhasm:   h1 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#11
# asm 2: fldl <r1=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<x2#102:<x0#100:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:

# qhasm:   h1 *= x0
# asm 1: fmul <x0=float80#6,<h1=float80#1
# asm 2: fmul <x0=%st(5),<h1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#102:<x0#100:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:

# qhasm:   h0 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#10
# asm 2: fldl <r0=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<x2#102:<x0#100:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   h0 *= x0
# asm 1: fmulp <x0=float80#1,<h0=float80#7
# asm 2: fmulp <x0=%st(0),<h0=%st(6)
fmulp %st(0),%st(6)
# comment:fpstackfrombottom:<x2#102:<h0#39:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:

# qhasm:   r2x1 = *(float64 *) &r2
# asm 1: fldl <r2=stack64#13
# asm 2: fldl <r2=128(%rsp)
fldl 128(%rsp)
# comment:fpstackfrombottom:<x2#102:<h0#39:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:<r2x1#104:

# qhasm:   r2x1 *= x1
# asm 1: fmul <x1=float80#6,<r2x1=float80#1
# asm 2: fmul <x1=%st(5),<r2x1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#102:<h0#39:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:<r2x1#104:

# qhasm:   h3 += r2x1
# asm 1: faddp <r2x1=float80#1,<h3=float80#4
# asm 2: faddp <r2x1=%st(0),<h3=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<x2#102:<h0#39:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:

# qhasm:   r1x1 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#11
# asm 2: fldl <r1=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<x2#102:<h0#39:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:<r1x1#105:

# qhasm:   r1x1 *= x1
# asm 1: fmul <x1=float80#6,<r1x1=float80#1
# asm 2: fmul <x1=%st(5),<r1x1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#102:<h0#39:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:<r1x1#105:

# qhasm:   h2 += r1x1
# asm 1: faddp <r1x1=float80#1,<h2=float80#3
# asm 2: faddp <r1x1=%st(0),<h2=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<x2#102:<h0#39:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:

# qhasm:   r0x1 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#10
# asm 2: fldl <r0=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<x2#102:<h0#39:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:<r0x1#106:

# qhasm:   r0x1 *= x1
# asm 1: fmul <x1=float80#6,<r0x1=float80#1
# asm 2: fmul <x1=%st(5),<r0x1=%st(0)
fmul %st(5),%st(0)
# comment:fpstackfrombottom:<x2#102:<h0#39:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:<r0x1#106:

# qhasm:   h1 += r0x1
# asm 1: faddp <r0x1=float80#1,<h1=float80#2
# asm 2: faddp <r0x1=%st(0),<h1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#102:<h0#39:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:

# qhasm:   sr3x1 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#16
# asm 2: fldl <sr3=152(%rsp)
fldl 152(%rsp)
# comment:fpstackfrombottom:<x2#102:<h0#39:<x1#101:<x3#103:<h3#36:<h2#37:<h1#38:<sr3x1#107:

# qhasm:   sr3x1 *= x1
# asm 1: fmulp <x1=float80#1,<sr3x1=float80#6
# asm 2: fmulp <x1=%st(0),<sr3x1=%st(5)
fmulp %st(0),%st(5)
# comment:fpstackfrombottom:<x2#102:<h0#39:<sr3x1#107:<x3#103:<h3#36:<h2#37:<h1#38:

# qhasm: internal stacktop sr3x1
# asm 1: fxch <sr3x1=float80#5
# asm 2: fxch <sr3x1=%st(4)
fxch %st(4)

# qhasm:   h0 += sr3x1
# asm 1: faddp <sr3x1=float80#1,<h0=float80#6
# asm 2: faddp <sr3x1=%st(0),<h0=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<x2#102:<h0#39:<h1#38:<x3#103:<h3#36:<h2#37:

# qhasm:   r1x2 = *(float64 *) &r1
# asm 1: fldl <r1=stack64#11
# asm 2: fldl <r1=112(%rsp)
fldl 112(%rsp)
# comment:fpstackfrombottom:<x2#102:<h0#39:<h1#38:<x3#103:<h3#36:<h2#37:<r1x2#108:

# qhasm:   r1x2 *= x2
# asm 1: fmul <x2=float80#7,<r1x2=float80#1
# asm 2: fmul <x2=%st(6),<r1x2=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x2#102:<h0#39:<h1#38:<x3#103:<h3#36:<h2#37:<r1x2#108:

# qhasm:   h3 += r1x2
# asm 1: faddp <r1x2=float80#1,<h3=float80#3
# asm 2: faddp <r1x2=%st(0),<h3=%st(2)
faddp %st(0),%st(2)
# comment:fpstackfrombottom:<x2#102:<h0#39:<h1#38:<x3#103:<h3#36:<h2#37:

# qhasm:   r0x2 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#10
# asm 2: fldl <r0=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<x2#102:<h0#39:<h1#38:<x3#103:<h3#36:<h2#37:<r0x2#109:

# qhasm:   r0x2 *= x2
# asm 1: fmul <x2=float80#7,<r0x2=float80#1
# asm 2: fmul <x2=%st(6),<r0x2=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x2#102:<h0#39:<h1#38:<x3#103:<h3#36:<h2#37:<r0x2#109:

# qhasm:   h2 += r0x2
# asm 1: faddp <r0x2=float80#1,<h2=float80#2
# asm 2: faddp <r0x2=%st(0),<h2=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x2#102:<h0#39:<h1#38:<x3#103:<h3#36:<h2#37:

# qhasm:   sr3x2 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#16
# asm 2: fldl <sr3=152(%rsp)
fldl 152(%rsp)
# comment:fpstackfrombottom:<x2#102:<h0#39:<h1#38:<x3#103:<h3#36:<h2#37:<sr3x2#110:

# qhasm:   sr3x2 *= x2
# asm 1: fmul <x2=float80#7,<sr3x2=float80#1
# asm 2: fmul <x2=%st(6),<sr3x2=%st(0)
fmul %st(6),%st(0)
# comment:fpstackfrombottom:<x2#102:<h0#39:<h1#38:<x3#103:<h3#36:<h2#37:<sr3x2#110:

# qhasm:   h1 += sr3x2
# asm 1: faddp <sr3x2=float80#1,<h1=float80#5
# asm 2: faddp <sr3x2=%st(0),<h1=%st(4)
faddp %st(0),%st(4)
# comment:fpstackfrombottom:<x2#102:<h0#39:<h1#38:<x3#103:<h3#36:<h2#37:

# qhasm:   sr2x2 = *(float64 *) &sr2
# asm 1: fldl <sr2=stack64#14
# asm 2: fldl <sr2=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<x2#102:<h0#39:<h1#38:<x3#103:<h3#36:<h2#37:<sr2x2#111:

# qhasm:   sr2x2 *= x2
# asm 1: fmulp <x2=float80#1,<sr2x2=float80#7
# asm 2: fmulp <x2=%st(0),<sr2x2=%st(6)
fmulp %st(0),%st(6)
# comment:fpstackfrombottom:<sr2x2#111:<h0#39:<h1#38:<x3#103:<h3#36:<h2#37:

# qhasm: internal stacktop sr2x2
# asm 1: fxch <sr2x2=float80#6
# asm 2: fxch <sr2x2=%st(5)
fxch %st(5)

# qhasm:   h0 += sr2x2
# asm 1: faddp <sr2x2=float80#1,<h0=float80#5
# asm 2: faddp <sr2x2=%st(0),<h0=%st(4)
faddp %st(0),%st(4)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#103:<h3#36:

# qhasm:   r0x3 = *(float64 *) &r0
# asm 1: fldl <r0=stack64#10
# asm 2: fldl <r0=104(%rsp)
fldl 104(%rsp)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#103:<h3#36:<r0x3#112:

# qhasm:   r0x3 *= x3
# asm 1: fmul <x3=float80#3,<r0x3=float80#1
# asm 2: fmul <x3=%st(2),<r0x3=%st(0)
fmul %st(2),%st(0)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#103:<h3#36:<r0x3#112:

# qhasm:   h3 += r0x3
# asm 1: faddp <r0x3=float80#1,<h3=float80#2
# asm 2: faddp <r0x3=%st(0),<h3=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#103:<h3#36:

# qhasm:   sr3x3 = *(float64 *) &sr3
# asm 1: fldl <sr3=stack64#16
# asm 2: fldl <sr3=152(%rsp)
fldl 152(%rsp)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#103:<h3#36:<sr3x3#113:

# qhasm:   sr3x3 *= x3
# asm 1: fmul <x3=float80#3,<sr3x3=float80#1
# asm 2: fmul <x3=%st(2),<sr3x3=%st(0)
fmul %st(2),%st(0)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#103:<h3#36:<sr3x3#113:

# qhasm:   h2 += sr3x3
# asm 1: faddp <sr3x3=float80#1,<h2=float80#6
# asm 2: faddp <sr3x3=%st(0),<h2=%st(5)
faddp %st(0),%st(5)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#103:<h3#36:

# qhasm:   sr2x3 = *(float64 *) &sr2
# asm 1: fldl <sr2=stack64#14
# asm 2: fldl <sr2=136(%rsp)
fldl 136(%rsp)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#103:<h3#36:<sr2x3#114:

# qhasm:   sr2x3 *= x3
# asm 1: fmul <x3=float80#3,<sr2x3=float80#1
# asm 2: fmul <x3=%st(2),<sr2x3=%st(0)
fmul %st(2),%st(0)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#103:<h3#36:<sr2x3#114:

# qhasm:   h1 += sr2x3
# asm 1: faddp <sr2x3=float80#1,<h1=float80#4
# asm 2: faddp <sr2x3=%st(0),<h1=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#103:<h3#36:

# qhasm:   sr1x3 = *(float64 *) &sr1
# asm 1: fldl <sr1=stack64#12
# asm 2: fldl <sr1=120(%rsp)
fldl 120(%rsp)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<x3#103:<h3#36:<sr1x3#115:

# qhasm:   sr1x3 *= x3
# asm 1: fmulp <x3=float80#1,<sr1x3=float80#3
# asm 2: fmulp <x3=%st(0),<sr1x3=%st(2)
fmulp %st(0),%st(2)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<sr1x3#115:<h3#36:

# qhasm: internal stacktop sr1x3
# asm 1: fxch <sr1x3=float80#2
# asm 2: fxch <sr1x3=%st(1)
fxch %st(1)

# qhasm:   h0 += sr1x3
# asm 1: faddp <sr1x3=float80#1,<h0=float80#4
# asm 2: faddp <sr1x3=%st(0),<h0=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h2#37:<h0#39:<h1#38:<h3#36:
# comment:automatically reorganizing fp stack for fallthrough

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#4
# asm 2: fxch <h2=%st(3)
fxch %st(3)
# comment:fpstackfrombottom:<h3#36:<h0#39:<h1#38:<h2#37:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#3
# asm 2: fxch <h0=%st(2)
fxch %st(2)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm: nomorebytes:
._nomorebytes:
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:

# qhasm:   x0 = *(float64 *) &poly1305_amd64_alpha130
fldl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:

# qhasm:   x0 += h3
# asm 1: fadd <h3=float80#5,<x0=float80#1
# asm 2: fadd <h3=%st(4),<x0=%st(0)
fadd %st(4),%st(0)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:

# qhasm:   x0 -= *(float64 *) &poly1305_amd64_alpha130
fsubl poly1305_amd64_alpha130(%rip)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:

# qhasm:   h3 -= x0
# asm 1: fsubr <x0=float80#1,<h3=float80#5
# asm 2: fsubr <x0=%st(0),<h3=%st(4)
fsubr %st(0),%st(4)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:

# qhasm:   x0 *= *(float64 *) &poly1305_amd64_scale
fmull poly1305_amd64_scale(%rip)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:

# qhasm:   x1 = *(float64 *) &poly1305_amd64_alpha32
fldl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:<x1#117:

# qhasm:   x1 += h0
# asm 1: fadd <h0=float80#3,<x1=float80#1
# asm 2: fadd <h0=%st(2),<x1=%st(0)
fadd %st(2),%st(0)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:<x1#117:

# qhasm:   x1 -= *(float64 *) &poly1305_amd64_alpha32
fsubl poly1305_amd64_alpha32(%rip)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:<x1#117:

# qhasm:   h0 -= x1
# asm 1: fsubr <x1=float80#1,<h0=float80#3
# asm 2: fsubr <x1=%st(0),<h0=%st(2)
fsubr %st(0),%st(2)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:<x1#117:

# qhasm:   x2 = *(float64 *) &poly1305_amd64_alpha64
fldl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:<x1#117:<x2#118:

# qhasm:   x2 += h1
# asm 1: fadd <h1=float80#5,<x2=float80#1
# asm 2: fadd <h1=%st(4),<x2=%st(0)
fadd %st(4),%st(0)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:<x1#117:<x2#118:

# qhasm:   x2 -= *(float64 *) &poly1305_amd64_alpha64
fsubl poly1305_amd64_alpha64(%rip)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:<x1#117:<x2#118:

# qhasm:   h1 -= x2
# asm 1: fsubr <x2=float80#1,<h1=float80#5
# asm 2: fsubr <x2=%st(0),<h1=%st(4)
fsubr %st(0),%st(4)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:<x1#117:<x2#118:

# qhasm:   x3 = *(float64 *) &poly1305_amd64_alpha96
fldl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:<x1#117:<x2#118:<x3#119:

# qhasm:   x3 += h2
# asm 1: fadd <h2=float80#7,<x3=float80#1
# asm 2: fadd <h2=%st(6),<x3=%st(0)
fadd %st(6),%st(0)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:<x1#117:<x2#118:<x3#119:

# qhasm:   x3 -= *(float64 *) &poly1305_amd64_alpha96
fsubl poly1305_amd64_alpha96(%rip)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:<x1#117:<x2#118:<x3#119:

# qhasm:   h2 -= x3
# asm 1: fsubr <x3=float80#1,<h2=float80#7
# asm 2: fsubr <x3=%st(0),<h2=%st(6)
fsubr %st(0),%st(6)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<h0#39:<x0#116:<x1#117:<x2#118:<x3#119:

# qhasm: internal stacktop h0
# asm 1: fxch <h0=float80#5
# asm 2: fxch <h0=%st(4)
fxch %st(4)

# qhasm:   x0 += h0
# asm 1: faddp <h0=float80#1,<x0=float80#4
# asm 2: faddp <h0=%st(0),<x0=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h3#36:<h2#37:<h1#38:<x3#119:<x0#116:<x1#117:<x2#118:

# qhasm: internal stacktop h1
# asm 1: fxch <h1=float80#5
# asm 2: fxch <h1=%st(4)
fxch %st(4)

# qhasm:   x1 += h1
# asm 1: faddp <h1=float80#1,<x1=float80#2
# asm 2: faddp <h1=%st(0),<x1=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<h3#36:<h2#37:<x2#118:<x3#119:<x0#116:<x1#117:

# qhasm: internal stacktop h2
# asm 1: fxch <h2=float80#5
# asm 2: fxch <h2=%st(4)
fxch %st(4)

# qhasm:   x2 += h2
# asm 1: faddp <h2=float80#1,<x2=float80#4
# asm 2: faddp <h2=%st(0),<x2=%st(3)
faddp %st(0),%st(3)
# comment:fpstackfrombottom:<h3#36:<x1#117:<x2#118:<x3#119:<x0#116:

# qhasm: internal stacktop h3
# asm 1: fxch <h3=float80#5
# asm 2: fxch <h3=%st(4)
fxch %st(4)

# qhasm:   x3 += h3
# asm 1: faddp <h3=float80#1,<x3=float80#2
# asm 2: faddp <h3=%st(0),<x3=%st(1)
faddp %st(0),%st(1)
# comment:fpstackfrombottom:<x0#116:<x1#117:<x2#118:<x3#119:

# qhasm: internal stacktop x0
# asm 1: fxch <x0=float80#4
# asm 2: fxch <x0=%st(3)
fxch %st(3)

# qhasm:   x0 += *(float64 *) &poly1305_amd64_hoffset0
faddl poly1305_amd64_hoffset0(%rip)
# comment:fpstackfrombottom:<x3#119:<x1#117:<x2#118:<x0#116:

# qhasm: internal stacktop x1
# asm 1: fxch <x1=float80#3
# asm 2: fxch <x1=%st(2)
fxch %st(2)

# qhasm:   x1 += *(float64 *) &poly1305_amd64_hoffset1
faddl poly1305_amd64_hoffset1(%rip)
# comment:fpstackfrombottom:<x3#119:<x0#116:<x2#118:<x1#117:

# qhasm: internal stacktop x2
# asm 1: fxch <x2=float80#2
# asm 2: fxch <x2=%st(1)
fxch %st(1)

# qhasm:   x2 += *(float64 *) &poly1305_amd64_hoffset2
faddl poly1305_amd64_hoffset2(%rip)
# comment:fpstackfrombottom:<x3#119:<x0#116:<x1#117:<x2#118:

# qhasm: internal stacktop x3
# asm 1: fxch <x3=float80#4
# asm 2: fxch <x3=%st(3)
fxch %st(3)

# qhasm:   x3 += *(float64 *) &poly1305_amd64_hoffset3
faddl poly1305_amd64_hoffset3(%rip)
# comment:fpstackfrombottom:<x2#118:<x0#116:<x1#117:<x3#119:

# qhasm: internal stacktop x0
# asm 1: fxch <x0=float80#3
# asm 2: fxch <x0=%st(2)
fxch %st(2)

# qhasm:   *(float64 *) &d0 = x0
# asm 1: fstpl >d0=stack64#10
# asm 2: fstpl >d0=104(%rsp)
fstpl 104(%rsp)
# comment:fpstackfrombottom:<x2#118:<x3#119:<x1#117:

# qhasm:   *(float64 *) &d1 = x1
# asm 1: fstpl >d1=stack64#11
# asm 2: fstpl >d1=112(%rsp)
fstpl 112(%rsp)
# comment:fpstackfrombottom:<x2#118:<x3#119:

# qhasm: internal stacktop x2
# asm 1: fxch <x2=float80#2
# asm 2: fxch <x2=%st(1)
fxch %st(1)

# qhasm:   *(float64 *) &d2 = x2
# asm 1: fstpl >d2=stack64#12
# asm 2: fstpl >d2=120(%rsp)
fstpl 120(%rsp)
# comment:fpstackfrombottom:<x3#119:

# qhasm:   *(float64 *) &d3 = x3
# asm 1: fstpl >d3=stack64#13
# asm 2: fstpl >d3=128(%rsp)
fstpl 128(%rsp)
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
# asm 1: movl <d0=stack64#10,>g0=int64#1d
# asm 2: movl <d0=108(%rsp),>g0=%ecx
movl 108(%rsp),%ecx

# qhasm:   (uint32) g0 &= 63
# asm 1: and  $63,<g0=int64#1d
# asm 2: and  $63,<g0=%ecx
and  $63,%ecx

# qhasm:   g1 = top d1
# asm 1: movl <d1=stack64#11,>g1=int64#2d
# asm 2: movl <d1=116(%rsp),>g1=%edx
movl 116(%rsp),%edx

# qhasm:   (uint32) g1 &= 63
# asm 1: and  $63,<g1=int64#2d
# asm 2: and  $63,<g1=%edx
and  $63,%edx

# qhasm:   g2 = top d2
# asm 1: movl <d2=stack64#12,>g2=int64#4d
# asm 2: movl <d2=124(%rsp),>g2=%r9d
movl 124(%rsp),%r9d

# qhasm:   (uint32) g2 &= 63
# asm 1: and  $63,<g2=int64#4d
# asm 2: and  $63,<g2=%r9d
and  $63,%r9d

# qhasm:   g3 = top d3
# asm 1: movl <d3=stack64#13,>g3=int64#6d
# asm 2: movl <d3=132(%rsp),>g3=%r10d
movl 132(%rsp),%r10d

# qhasm:   (uint32) g3 &= 63
# asm 1: and  $63,<g3=int64#6d
# asm 2: and  $63,<g3=%r10d
and  $63,%r10d

# qhasm:   f1 = bottom d1
# asm 1: movl <d1=stack64#11,>f1=int64#7d
# asm 2: movl <d1=112(%rsp),>f1=%r11d
movl 112(%rsp),%r11d

# qhasm:   carry? (uint32) f1 += g0
# asm 1: add <g0=int64#1d,<f1=int64#7d
# asm 2: add <g0=%ecx,<f1=%r11d
add %ecx,%r11d

# qhasm:   f2 = bottom d2
# asm 1: movl <d2=stack64#12,>f2=int64#1d
# asm 2: movl <d2=120(%rsp),>f2=%ecx
movl 120(%rsp),%ecx

# qhasm:   carry? (uint32) f2 += g1 + carry
# asm 1: adc <g1=int64#2d,<f2=int64#1d
# asm 2: adc <g1=%edx,<f2=%ecx
adc %edx,%ecx

# qhasm:   f3 = bottom d3
# asm 1: movl <d3=stack64#13,>f3=int64#2d
# asm 2: movl <d3=128(%rsp),>f3=%edx
movl 128(%rsp),%edx

# qhasm:   carry? (uint32) f3 += g2 + carry
# asm 1: adc <g2=int64#4d,<f3=int64#2d
# asm 2: adc <g2=%r9d,<f3=%edx
adc %r9d,%edx

# qhasm:   f4 = 0
# asm 1: mov  $0,>f4=int64#4
# asm 2: mov  $0,>f4=%r9
mov  $0,%r9

# qhasm:          (uint32) f4 += g3 + carry
# asm 1: adc <g3=int64#6d,<f4=int64#4d
# asm 2: adc <g3=%r10d,<f4=%r9d
adc %r10d,%r9d

# qhasm:   g0 = 5
# asm 1: mov  $5,>g0=int64#6
# asm 2: mov  $5,>g0=%r10
mov  $5,%r10

# qhasm:   f0 = bottom d0
# asm 1: movl <d0=stack64#10,>f0=int64#8d
# asm 2: movl <d0=104(%rsp),>f0=%r12d
movl 104(%rsp),%r12d

# qhasm:   carry? (uint32) g0 += f0
# asm 1: add <f0=int64#8d,<g0=int64#6d
# asm 2: add <f0=%r12d,<g0=%r10d
add %r12d,%r10d

# qhasm:   g1 = 0
# asm 1: mov  $0,>g1=int64#9
# asm 2: mov  $0,>g1=%r13
mov  $0,%r13

# qhasm:   carry? (uint32) g1 += f1 + carry
# asm 1: adc <f1=int64#7d,<g1=int64#9d
# asm 2: adc <f1=%r11d,<g1=%r13d
adc %r11d,%r13d

# qhasm:   g2 = 0
# asm 1: mov  $0,>g2=int64#10
# asm 2: mov  $0,>g2=%r14
mov  $0,%r14

# qhasm:   carry? (uint32) g2 += f2 + carry
# asm 1: adc <f2=int64#1d,<g2=int64#10d
# asm 2: adc <f2=%ecx,<g2=%r14d
adc %ecx,%r14d

# qhasm:   g3 = 0
# asm 1: mov  $0,>g3=int64#11
# asm 2: mov  $0,>g3=%r15
mov  $0,%r15

# qhasm:   carry? (uint32) g3 += f3 + carry
# asm 1: adc <f3=int64#2d,<g3=int64#11d
# asm 2: adc <f3=%edx,<g3=%r15d
adc %edx,%r15d

# qhasm:   f = -4
# asm 1: mov  $-4,>f=int64#12
# asm 2: mov  $-4,>f=%rdi
mov  $-4,%rdi

# qhasm:          (uint32) f += f4 + carry
# asm 1: adc <f4=int64#4d,<f=int64#12d
# asm 2: adc <f4=%r9d,<f=%edi
adc %r9d,%edi

# qhasm:   (int32) f >>= 16
# asm 1: sar  $16,<f=int64#12d
# asm 2: sar  $16,<f=%edi
sar  $16,%edi

# qhasm:   notf = f
# asm 1: mov  <f=int64#12,>notf=int64#4
# asm 2: mov  <f=%rdi,>notf=%r9
mov  %rdi,%r9

# qhasm:   (uint32) notf ^= -1
# asm 1: xor  $-1,<notf=int64#4d
# asm 2: xor  $-1,<notf=%r9d
xor  $-1,%r9d

# qhasm:   f0 &= f
# asm 1: and  <f=int64#12,<f0=int64#8
# asm 2: and  <f=%rdi,<f0=%r12
and  %rdi,%r12

# qhasm:   g0 &= notf
# asm 1: and  <notf=int64#4,<g0=int64#6
# asm 2: and  <notf=%r9,<g0=%r10
and  %r9,%r10

# qhasm:   f0 |= g0
# asm 1: or   <g0=int64#6,<f0=int64#8
# asm 2: or   <g0=%r10,<f0=%r12
or   %r10,%r12

# qhasm:   f1 &= f
# asm 1: and  <f=int64#12,<f1=int64#7
# asm 2: and  <f=%rdi,<f1=%r11
and  %rdi,%r11

# qhasm:   g1 &= notf
# asm 1: and  <notf=int64#4,<g1=int64#9
# asm 2: and  <notf=%r9,<g1=%r13
and  %r9,%r13

# qhasm:   f1 |= g1
# asm 1: or   <g1=int64#9,<f1=int64#7
# asm 2: or   <g1=%r13,<f1=%r11
or   %r13,%r11

# qhasm:   f2 &= f
# asm 1: and  <f=int64#12,<f2=int64#1
# asm 2: and  <f=%rdi,<f2=%rcx
and  %rdi,%rcx

# qhasm:   g2 &= notf
# asm 1: and  <notf=int64#4,<g2=int64#10
# asm 2: and  <notf=%r9,<g2=%r14
and  %r9,%r14

# qhasm:   f2 |= g2
# asm 1: or   <g2=int64#10,<f2=int64#1
# asm 2: or   <g2=%r14,<f2=%rcx
or   %r14,%rcx

# qhasm:   f3 &= f
# asm 1: and  <f=int64#12,<f3=int64#2
# asm 2: and  <f=%rdi,<f3=%rdx
and  %rdi,%rdx

# qhasm:   g3 &= notf
# asm 1: and  <notf=int64#4,<g3=int64#11
# asm 2: and  <notf=%r9,<g3=%r15
and  %r9,%r15

# qhasm:   f3 |= g3
# asm 1: or   <g3=int64#11,<f3=int64#2
# asm 2: or   <g3=%r15,<f3=%rdx
or   %r15,%rdx

# qhasm:   s = arg3
# asm 1: mov  <arg3=int64#3,>s=int64#3
# asm 2: mov  <arg3=%r8,>s=%r8
mov  %r8,%r8

# qhasm:   carry? (uint32) f0 += *(uint32 *) (s + 0)
# asm 1: addl 0(<s=int64#3),<f0=int64#8d
# asm 2: addl 0(<s=%r8),<f0=%r12d
addl 0(%r8),%r12d

# qhasm:   carry? (uint32) f1 += *(uint32 *) (s + 4) + carry
# asm 1: adcl 4(<s=int64#3),<f1=int64#7d
# asm 2: adcl 4(<s=%r8),<f1=%r11d
adcl 4(%r8),%r11d

# qhasm:   carry? (uint32) f2 += *(uint32 *) (s + 8) + carry
# asm 1: adcl 8(<s=int64#3),<f2=int64#1d
# asm 2: adcl 8(<s=%r8),<f2=%ecx
adcl 8(%r8),%ecx

# qhasm:          (uint32) f3 += *(uint32 *) (s + 12) + carry
# asm 1: adcl 12(<s=int64#3),<f3=int64#2d
# asm 2: adcl 12(<s=%r8),<f3=%edx
adcl 12(%r8),%edx

# qhasm:   out = out_stack
# asm 1: mov  <out_stack=int64#5,>out=int64#3
# asm 2: mov  <out_stack=%rax,>out=%r8
mov  %rax,%r8

# qhasm:   *(uint32 *) (out + 0) = f0
# asm 1: movl   <f0=int64#8d,0(<out=int64#3)
# asm 2: movl   <f0=%r12d,0(<out=%r8)
movl   %r12d,0(%r8)

# qhasm:   *(uint32 *) (out + 4) = f1
# asm 1: movl   <f1=int64#7d,4(<out=int64#3)
# asm 2: movl   <f1=%r11d,4(<out=%r8)
movl   %r11d,4(%r8)

# qhasm:   *(uint32 *) (out + 8) = f2
# asm 1: movl   <f2=int64#1d,8(<out=int64#3)
# asm 2: movl   <f2=%ecx,8(<out=%r8)
movl   %ecx,8(%r8)

# qhasm:   *(uint32 *) (out + 12) = f3
# asm 1: movl   <f3=int64#2d,12(<out=int64#3)
# asm 2: movl   <f3=%edx,12(<out=%r8)
movl   %edx,12(%r8)

# qhasm:   r11 = r11_stack
# asm 1: movq <r11_stack=stack64#1,>r11=int64#7
# asm 2: movq <r11_stack=32(%rsp),>r11=%r11
movq 32(%rsp),%r11

# qhasm:   r12 = r12_stack
# asm 1: movq <r12_stack=stack64#2,>r12=int64#8
# asm 2: movq <r12_stack=40(%rsp),>r12=%r12
movq 40(%rsp),%r12

# qhasm:   r13 = r13_stack
# asm 1: movq <r13_stack=stack64#3,>r13=int64#9
# asm 2: movq <r13_stack=48(%rsp),>r13=%r13
movq 48(%rsp),%r13

# qhasm:   r14 = r14_stack
# asm 1: movq <r14_stack=stack64#4,>r14=int64#10
# asm 2: movq <r14_stack=56(%rsp),>r14=%r14
movq 56(%rsp),%r14

# qhasm:   r15 = r15_stack
# asm 1: movq <r15_stack=stack64#5,>r15=int64#11
# asm 2: movq <r15_stack=64(%rsp),>r15=%r15
movq 64(%rsp),%r15

# qhasm: rdi = rdi_stack
# asm 1: movq <rdi_stack=stack64#6,>rdi=int64#12
# asm 2: movq <rdi_stack=72(%rsp),>rdi=%rdi
movq 72(%rsp),%rdi

# qhasm: rsi = rsi_stack
# asm 1: movq <rsi_stack=stack64#7,>rsi=int64#13
# asm 2: movq <rsi_stack=80(%rsp),>rsi=%rsi
movq 80(%rsp),%rsi

# qhasm:   rbp = rbp_stack
# asm 1: movq <rbp_stack=stack64#8,>rbp=int64#14
# asm 2: movq <rbp_stack=88(%rsp),>rbp=%rbp
movq 88(%rsp),%rbp

# qhasm:   rbx = rbx_stack
# asm 1: movq <rbx_stack=stack64#9,>rbx=int64#15
# asm 2: movq <rbx_stack=96(%rsp),>rbx=%rbx
movq 96(%rsp),%rbx

# qhasm: leave
add %r11,%rsp
ret
