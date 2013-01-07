
# qhasm: stack32 arg1

# qhasm: stack32 arg2

# qhasm: stack32 arg3

# qhasm: input arg1

# qhasm: input arg2

# qhasm: input arg3

# qhasm: int32 eax

# qhasm: int32 ebx

# qhasm: int32 esi

# qhasm: int32 edi

# qhasm: int32 ebp

# qhasm: caller eax

# qhasm: caller ebx

# qhasm: caller esi

# qhasm: caller edi

# qhasm: caller ebp

# qhasm: stack32 eax_stack

# qhasm: stack32 ebx_stack

# qhasm: stack32 esi_stack

# qhasm: stack32 edi_stack

# qhasm: stack32 ebp_stack

# qhasm: int32 c

# qhasm: int32 k

# qhasm: int32 iv

# qhasm: int32 x0

# qhasm: int32 x1

# qhasm: int32 x2

# qhasm: int32 x3

# qhasm: int32 e

# qhasm: int32 q0

# qhasm: int32 q1

# qhasm: int32 q2

# qhasm: int32 q3

# qhasm: int32 in

# qhasm: int32 out

# qhasm: int32 len

# qhasm: int3232 c_stack

# qhasm: int3232 in_stack

# qhasm: int3232 out_stack

# qhasm: int3232 len_stack

# qhasm: int3232 y1_stack

# qhasm: int3232 y2_stack

# qhasm: int3232 y3_stack

# qhasm: int3232 z1_stack

# qhasm: int3232 z2_stack

# qhasm: int3232 z3_stack

# qhasm: stack32 n0

# qhasm: stack32 n1

# qhasm: stack32 n2

# qhasm: stack32 n3

# qhasm: stack32 r0

# qhasm: stack32 r1

# qhasm: stack32 r2

# qhasm: stack32 r3

# qhasm: stack32 r4

# qhasm: stack32 r5

# qhasm: stack32 r6

# qhasm: stack32 r7

# qhasm: stack32 r8

# qhasm: stack32 r9

# qhasm: stack32 r10

# qhasm: stack32 r11

# qhasm: stack32 r12

# qhasm: stack32 r13

# qhasm: stack32 r14

# qhasm: stack32 r15

# qhasm: stack32 r16

# qhasm: stack32 r17

# qhasm: stack32 r18

# qhasm: stack32 r19

# qhasm: stack32 r20

# qhasm: stack32 r21

# qhasm: stack32 r22

# qhasm: stack32 r23

# qhasm: stack32 r24

# qhasm: stack32 r25

# qhasm: stack32 r26

# qhasm: stack32 r27

# qhasm: stack32 r28

# qhasm: stack32 r29

# qhasm: stack32 r30

# qhasm: stack32 r31

# qhasm: stack32 r32

# qhasm: stack32 r33

# qhasm: stack32 r34

# qhasm: stack32 r35

# qhasm: stack32 r36

# qhasm: stack32 r37

# qhasm: stack32 r38

# qhasm: stack32 r39

# qhasm: stack32 r40

# qhasm: stack32 r41

# qhasm: stack32 r42

# qhasm: stack32 r43

# qhasm: int32 y0

# qhasm: int32 y1

# qhasm: int32 y2

# qhasm: int32 y3

# qhasm: int32 z0

# qhasm: int32 z1

# qhasm: int32 z2

# qhasm: int32 z3

# qhasm: int32 p00

# qhasm: int32 p01

# qhasm: int32 p02

# qhasm: int32 p03

# qhasm: int32 p10

# qhasm: int32 p11

# qhasm: int32 p12

# qhasm: int32 p13

# qhasm: int32 p20

# qhasm: int32 p21

# qhasm: int32 p22

# qhasm: int32 p23

# qhasm: int32 p30

# qhasm: int32 p31

# qhasm: int32 p32

# qhasm: int32 p33

# qhasm: int32 b0

# qhasm: int32 b1

# qhasm: int32 b2

# qhasm: int32 b3

# qhasm: enter aes128_x86mmx1_block stackaligned4096 aes128_x86mmx1_constants
.text
.p2align 5
.globl _aes128_x86mmx1_block
.globl aes128_x86mmx1_block
_aes128_x86mmx1_block:
aes128_x86mmx1_block:
mov %esp,%eax
sub $aes128_x86mmx1_constants,%eax
and $4095,%eax
add $224,%eax
sub %eax,%esp

# qhasm: eax_stack = eax
# asm 1: movl <eax=int32#1,>eax_stack=stack32#1
# asm 2: movl <eax=%eax,>eax_stack=0(%esp)
movl %eax,0(%esp)

# qhasm: ebx_stack = ebx
# asm 1: movl <ebx=int32#4,>ebx_stack=stack32#2
# asm 2: movl <ebx=%ebx,>ebx_stack=4(%esp)
movl %ebx,4(%esp)

# qhasm: esi_stack = esi
# asm 1: movl <esi=int32#5,>esi_stack=stack32#3
# asm 2: movl <esi=%esi,>esi_stack=8(%esp)
movl %esi,8(%esp)

# qhasm: edi_stack = edi
# asm 1: movl <edi=int32#6,>edi_stack=stack32#4
# asm 2: movl <edi=%edi,>edi_stack=12(%esp)
movl %edi,12(%esp)

# qhasm: ebp_stack = ebp
# asm 1: movl <ebp=int32#7,>ebp_stack=stack32#5
# asm 2: movl <ebp=%ebp,>ebp_stack=16(%esp)
movl %ebp,16(%esp)

# qhasm: c = arg3
# asm 1: movl <arg3=stack32#-3,>c=int32#2
# asm 2: movl <arg3=12(%esp,%eax),>c=%ecx
movl 12(%esp,%eax),%ecx

# qhasm: out = arg1
# asm 1: movl <arg1=stack32#-1,>out=int32#3
# asm 2: movl <arg1=4(%esp,%eax),>out=%edx
movl 4(%esp,%eax),%edx

# qhasm: out_stack = out
# asm 1: movd <out=int32#3,>out_stack=int3232#1
# asm 2: movd <out=%edx,>out_stack=%mm0
movd %edx,%mm0

# qhasm: x0 = *(uint32 *) (c + 0)
# asm 1: movl 0(<c=int32#2),>x0=int32#3
# asm 2: movl 0(<c=%ecx),>x0=%edx
movl 0(%ecx),%edx

# qhasm: x1 = *(uint32 *) (c + 4)
# asm 1: movl 4(<c=int32#2),>x1=int32#4
# asm 2: movl 4(<c=%ecx),>x1=%ebx
movl 4(%ecx),%ebx

# qhasm: x2 = *(uint32 *) (c + 8)
# asm 1: movl 8(<c=int32#2),>x2=int32#5
# asm 2: movl 8(<c=%ecx),>x2=%esi
movl 8(%ecx),%esi

# qhasm: x3 = *(uint32 *) (c + 12)
# asm 1: movl 12(<c=int32#2),>x3=int32#6
# asm 2: movl 12(<c=%ecx),>x3=%edi
movl 12(%ecx),%edi

# qhasm: r0 = x0
# asm 1: movl <x0=int32#3,>r0=stack32#6
# asm 2: movl <x0=%edx,>r0=20(%esp)
movl %edx,20(%esp)

# qhasm: r1 = x1
# asm 1: movl <x1=int32#4,>r1=stack32#7
# asm 2: movl <x1=%ebx,>r1=24(%esp)
movl %ebx,24(%esp)

# qhasm: r2 = x2
# asm 1: movl <x2=int32#5,>r2=stack32#8
# asm 2: movl <x2=%esi,>r2=28(%esp)
movl %esi,28(%esp)

# qhasm: r3 = x3
# asm 1: movl <x3=int32#6,>r3=stack32#9
# asm 2: movl <x3=%edi,>r3=32(%esp)
movl %edi,32(%esp)

# qhasm: x0 = *(uint32 *) (c + 16)
# asm 1: movl 16(<c=int32#2),>x0=int32#3
# asm 2: movl 16(<c=%ecx),>x0=%edx
movl 16(%ecx),%edx

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#6
# asm 2: xorl <x2=%esi,<x3=%edi
xorl %esi,%edi

# qhasm: r4 = x0
# asm 1: movl <x0=int32#3,>r4=stack32#10
# asm 2: movl <x0=%edx,>r4=36(%esp)
movl %edx,36(%esp)

# qhasm: r5 = x1
# asm 1: movl <x1=int32#4,>r5=stack32#11
# asm 2: movl <x1=%ebx,>r5=40(%esp)
movl %ebx,40(%esp)

# qhasm: r6 = x2
# asm 1: movl <x2=int32#5,>r6=stack32#12
# asm 2: movl <x2=%esi,>r6=44(%esp)
movl %esi,44(%esp)

# qhasm: r7 = x3
# asm 1: movl <x3=int32#6,>r7=stack32#13
# asm 2: movl <x3=%edi,>r7=48(%esp)
movl %edi,48(%esp)

# qhasm: x0 = *(uint32 *) (c + 20)
# asm 1: movl 20(<c=int32#2),>x0=int32#3
# asm 2: movl 20(<c=%ecx),>x0=%edx
movl 20(%ecx),%edx

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#6
# asm 2: xorl <x2=%esi,<x3=%edi
xorl %esi,%edi

# qhasm: r8 = x0
# asm 1: movl <x0=int32#3,>r8=stack32#14
# asm 2: movl <x0=%edx,>r8=52(%esp)
movl %edx,52(%esp)

# qhasm: r9 = x1
# asm 1: movl <x1=int32#4,>r9=stack32#15
# asm 2: movl <x1=%ebx,>r9=56(%esp)
movl %ebx,56(%esp)

# qhasm: r10 = x2
# asm 1: movl <x2=int32#5,>r10=stack32#16
# asm 2: movl <x2=%esi,>r10=60(%esp)
movl %esi,60(%esp)

# qhasm: r11 = x3
# asm 1: movl <x3=int32#6,>r11=stack32#17
# asm 2: movl <x3=%edi,>r11=64(%esp)
movl %edi,64(%esp)

# qhasm: x0 = *(uint32 *) (c + 24)
# asm 1: movl 24(<c=int32#2),>x0=int32#3
# asm 2: movl 24(<c=%ecx),>x0=%edx
movl 24(%ecx),%edx

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#6
# asm 2: xorl <x2=%esi,<x3=%edi
xorl %esi,%edi

# qhasm: r12 = x0
# asm 1: movl <x0=int32#3,>r12=stack32#18
# asm 2: movl <x0=%edx,>r12=68(%esp)
movl %edx,68(%esp)

# qhasm: r13 = x1
# asm 1: movl <x1=int32#4,>r13=stack32#19
# asm 2: movl <x1=%ebx,>r13=72(%esp)
movl %ebx,72(%esp)

# qhasm: r14 = x2
# asm 1: movl <x2=int32#5,>r14=stack32#20
# asm 2: movl <x2=%esi,>r14=76(%esp)
movl %esi,76(%esp)

# qhasm: r15 = x3
# asm 1: movl <x3=int32#6,>r15=stack32#21
# asm 2: movl <x3=%edi,>r15=80(%esp)
movl %edi,80(%esp)

# qhasm: x0 = *(uint32 *) (c + 28)
# asm 1: movl 28(<c=int32#2),>x0=int32#3
# asm 2: movl 28(<c=%ecx),>x0=%edx
movl 28(%ecx),%edx

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#6
# asm 2: xorl <x2=%esi,<x3=%edi
xorl %esi,%edi

# qhasm: r16 = x0
# asm 1: movl <x0=int32#3,>r16=stack32#22
# asm 2: movl <x0=%edx,>r16=84(%esp)
movl %edx,84(%esp)

# qhasm: r17 = x1
# asm 1: movl <x1=int32#4,>r17=stack32#23
# asm 2: movl <x1=%ebx,>r17=88(%esp)
movl %ebx,88(%esp)

# qhasm: r18 = x2
# asm 1: movl <x2=int32#5,>r18=stack32#24
# asm 2: movl <x2=%esi,>r18=92(%esp)
movl %esi,92(%esp)

# qhasm: r19 = x3
# asm 1: movl <x3=int32#6,>r19=stack32#25
# asm 2: movl <x3=%edi,>r19=96(%esp)
movl %edi,96(%esp)

# qhasm: x0 = *(uint32 *) (c + 32)
# asm 1: movl 32(<c=int32#2),>x0=int32#3
# asm 2: movl 32(<c=%ecx),>x0=%edx
movl 32(%ecx),%edx

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#6
# asm 2: xorl <x2=%esi,<x3=%edi
xorl %esi,%edi

# qhasm: r20 = x0
# asm 1: movl <x0=int32#3,>r20=stack32#26
# asm 2: movl <x0=%edx,>r20=100(%esp)
movl %edx,100(%esp)

# qhasm: r21 = x1
# asm 1: movl <x1=int32#4,>r21=stack32#27
# asm 2: movl <x1=%ebx,>r21=104(%esp)
movl %ebx,104(%esp)

# qhasm: r22 = x2
# asm 1: movl <x2=int32#5,>r22=stack32#28
# asm 2: movl <x2=%esi,>r22=108(%esp)
movl %esi,108(%esp)

# qhasm: r23 = x3
# asm 1: movl <x3=int32#6,>r23=stack32#29
# asm 2: movl <x3=%edi,>r23=112(%esp)
movl %edi,112(%esp)

# qhasm: x0 = *(uint32 *) (c + 36)
# asm 1: movl 36(<c=int32#2),>x0=int32#3
# asm 2: movl 36(<c=%ecx),>x0=%edx
movl 36(%ecx),%edx

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#6
# asm 2: xorl <x2=%esi,<x3=%edi
xorl %esi,%edi

# qhasm: r24 = x0
# asm 1: movl <x0=int32#3,>r24=stack32#30
# asm 2: movl <x0=%edx,>r24=116(%esp)
movl %edx,116(%esp)

# qhasm: r25 = x1
# asm 1: movl <x1=int32#4,>r25=stack32#31
# asm 2: movl <x1=%ebx,>r25=120(%esp)
movl %ebx,120(%esp)

# qhasm: r26 = x2
# asm 1: movl <x2=int32#5,>r26=stack32#32
# asm 2: movl <x2=%esi,>r26=124(%esp)
movl %esi,124(%esp)

# qhasm: r27 = x3
# asm 1: movl <x3=int32#6,>r27=stack32#33
# asm 2: movl <x3=%edi,>r27=128(%esp)
movl %edi,128(%esp)

# qhasm: x0 = *(uint32 *) (c + 40)
# asm 1: movl 40(<c=int32#2),>x0=int32#3
# asm 2: movl 40(<c=%ecx),>x0=%edx
movl 40(%ecx),%edx

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#6
# asm 2: xorl <x2=%esi,<x3=%edi
xorl %esi,%edi

# qhasm: r28 = x0
# asm 1: movl <x0=int32#3,>r28=stack32#34
# asm 2: movl <x0=%edx,>r28=132(%esp)
movl %edx,132(%esp)

# qhasm: r29 = x1
# asm 1: movl <x1=int32#4,>r29=stack32#35
# asm 2: movl <x1=%ebx,>r29=136(%esp)
movl %ebx,136(%esp)

# qhasm: r30 = x2
# asm 1: movl <x2=int32#5,>r30=stack32#36
# asm 2: movl <x2=%esi,>r30=140(%esp)
movl %esi,140(%esp)

# qhasm: r31 = x3
# asm 1: movl <x3=int32#6,>r31=stack32#37
# asm 2: movl <x3=%edi,>r31=144(%esp)
movl %edi,144(%esp)

# qhasm: x0 = *(uint32 *) (c + 44)
# asm 1: movl 44(<c=int32#2),>x0=int32#3
# asm 2: movl 44(<c=%ecx),>x0=%edx
movl 44(%ecx),%edx

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#6
# asm 2: xorl <x2=%esi,<x3=%edi
xorl %esi,%edi

# qhasm: r32 = x0
# asm 1: movl <x0=int32#3,>r32=stack32#38
# asm 2: movl <x0=%edx,>r32=148(%esp)
movl %edx,148(%esp)

# qhasm: r33 = x1
# asm 1: movl <x1=int32#4,>r33=stack32#39
# asm 2: movl <x1=%ebx,>r33=152(%esp)
movl %ebx,152(%esp)

# qhasm: r34 = x2
# asm 1: movl <x2=int32#5,>r34=stack32#40
# asm 2: movl <x2=%esi,>r34=156(%esp)
movl %esi,156(%esp)

# qhasm: r35 = x3
# asm 1: movl <x3=int32#6,>r35=stack32#41
# asm 2: movl <x3=%edi,>r35=160(%esp)
movl %edi,160(%esp)

# qhasm: x0 = *(uint32 *) (c + 48)
# asm 1: movl 48(<c=int32#2),>x0=int32#3
# asm 2: movl 48(<c=%ecx),>x0=%edx
movl 48(%ecx),%edx

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#3,<x1=int32#4
# asm 2: xorl <x0=%edx,<x1=%ebx
xorl %edx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#6
# asm 2: xorl <x2=%esi,<x3=%edi
xorl %esi,%edi

# qhasm: r36 = x0
# asm 1: movl <x0=int32#3,>r36=stack32#42
# asm 2: movl <x0=%edx,>r36=164(%esp)
movl %edx,164(%esp)

# qhasm: r37 = x1
# asm 1: movl <x1=int32#4,>r37=stack32#43
# asm 2: movl <x1=%ebx,>r37=168(%esp)
movl %ebx,168(%esp)

# qhasm: r38 = x2
# asm 1: movl <x2=int32#5,>r38=stack32#44
# asm 2: movl <x2=%esi,>r38=172(%esp)
movl %esi,172(%esp)

# qhasm: r39 = x3
# asm 1: movl <x3=int32#6,>r39=stack32#45
# asm 2: movl <x3=%edi,>r39=176(%esp)
movl %edi,176(%esp)

# qhasm: x0 = *(uint32 *) (c + 52)
# asm 1: movl 52(<c=int32#2),>x0=int32#2
# asm 2: movl 52(<c=%ecx),>x0=%ecx
movl 52(%ecx),%ecx

# qhasm: x1 ^= x0
# asm 1: xorl <x0=int32#2,<x1=int32#4
# asm 2: xorl <x0=%ecx,<x1=%ebx
xorl %ecx,%ebx

# qhasm: x2 ^= x1
# asm 1: xorl <x1=int32#4,<x2=int32#5
# asm 2: xorl <x1=%ebx,<x2=%esi
xorl %ebx,%esi

# qhasm: x3 ^= x2
# asm 1: xorl <x2=int32#5,<x3=int32#6
# asm 2: xorl <x2=%esi,<x3=%edi
xorl %esi,%edi

# qhasm: r40 = x0
# asm 1: movl <x0=int32#2,>r40=stack32#46
# asm 2: movl <x0=%ecx,>r40=180(%esp)
movl %ecx,180(%esp)

# qhasm: r41 = x1
# asm 1: movl <x1=int32#4,>r41=stack32#47
# asm 2: movl <x1=%ebx,>r41=184(%esp)
movl %ebx,184(%esp)

# qhasm: r42 = x2
# asm 1: movl <x2=int32#5,>r42=stack32#48
# asm 2: movl <x2=%esi,>r42=188(%esp)
movl %esi,188(%esp)

# qhasm: r43 = x3
# asm 1: movl <x3=int32#6,>r43=stack32#49
# asm 2: movl <x3=%edi,>r43=192(%esp)
movl %edi,192(%esp)

# qhasm: in = arg2
# asm 1: movl <arg2=stack32#-2,>in=int32#4
# asm 2: movl <arg2=8(%esp,%eax),>in=%ebx
movl 8(%esp,%eax),%ebx

# qhasm: y0 = *(uint32 *) (in + 0)
# asm 1: movl 0(<in=int32#4),>y0=int32#1
# asm 2: movl 0(<in=%ebx),>y0=%eax
movl 0(%ebx),%eax

# qhasm: y1 = *(uint32 *) (in + 4)
# asm 1: movl 4(<in=int32#4),>y1=int32#2
# asm 2: movl 4(<in=%ebx),>y1=%ecx
movl 4(%ebx),%ecx

# qhasm: y2 = *(uint32 *) (in + 8)
# asm 1: movl 8(<in=int32#4),>y2=int32#3
# asm 2: movl 8(<in=%ebx),>y2=%edx
movl 8(%ebx),%edx

# qhasm: y3 = *(uint32 *) (in + 12)
# asm 1: movl 12(<in=int32#4),>y3=int32#4
# asm 2: movl 12(<in=%ebx),>y3=%ebx
movl 12(%ebx),%ebx

# qhasm: y0 ^= r0
# asm 1: xorl <r0=stack32#6,<y0=int32#1
# asm 2: xorl <r0=20(%esp),<y0=%eax
xorl 20(%esp),%eax

# qhasm: y1 ^= r1
# asm 1: xorl <r1=stack32#7,<y1=int32#2
# asm 2: xorl <r1=24(%esp),<y1=%ecx
xorl 24(%esp),%ecx

# qhasm: y2 ^= r2
# asm 1: xorl <r2=stack32#8,<y2=int32#3
# asm 2: xorl <r2=28(%esp),<y2=%edx
xorl 28(%esp),%edx

# qhasm: y3 ^= r3
# asm 1: xorl <r3=stack32#9,<y3=int32#4
# asm 2: xorl <r3=32(%esp),<y3=%ebx
xorl 32(%esp),%ebx

# qhasm: y3_stack = y3
# asm 1: movd <y3=int32#4,>y3_stack=int3232#2
# asm 2: movd <y3=%ebx,>y3_stack=%mm1
movd %ebx,%mm1

# qhasm: p00 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p00=int32#4
# asm 2: movzbl <y0=%al,>p00=%ebx
movzbl %al,%ebx

# qhasm: z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<p00=int32#4,8),>z0=int32#4
# asm 2: movl aes128_x86mmx1_table0(,<p00=%ebx,8),>z0=%ebx
movl aes128_x86mmx1_table0(,%ebx,8),%ebx

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p03=int32#5
# asm 2: movzbl <y0=%ah,>p03=%esi
movzbl %ah,%esi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int32#1
# asm 2: shr  $16,<y0=%eax
shr  $16,%eax

# qhasm: z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<p03=int32#5,8),>z3=int32#5
# asm 2: movl aes128_x86mmx1_table1(,<p03=%esi,8),>z3=%esi
movl aes128_x86mmx1_table1(,%esi,8),%esi

# qhasm: p02 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p02=int32#6
# asm 2: movzbl <y0=%al,>p02=%edi
movzbl %al,%edi

# qhasm: z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
# asm 1: movl aes128_x86mmx1_table2(,<p02=int32#6,8),>z2=int32#6
# asm 2: movl aes128_x86mmx1_table2(,<p02=%edi,8),>z2=%edi
movl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p01=int32#1
# asm 2: movzbl <y0=%ah,>p01=%eax
movzbl %ah,%eax

# qhasm: z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
# asm 1: movl aes128_x86mmx1_table3(,<p01=int32#1,8),>z1=int32#7
# asm 2: movl aes128_x86mmx1_table3(,<p01=%eax,8),>z1=%ebp
movl aes128_x86mmx1_table3(,%eax,8),%ebp

# qhasm: p10 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p10=int32#1
# asm 2: movzbl <y1=%cl,>p10=%eax
movzbl %cl,%eax

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p10=int32#1,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table0(,<p10=%eax,8),<z1=%ebp
xorl aes128_x86mmx1_table0(,%eax,8),%ebp

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p11=int32#1
# asm 2: movzbl <y1=%ch,>p11=%eax
movzbl %ch,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p11=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table1(,<p11=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table1(,%eax,8),%ebx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int32#2
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p12=int32#1
# asm 2: movzbl <y1=%cl,>p12=%eax
movzbl %cl,%eax

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p12=int32#1,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table2(,<p12=%eax,8),<z3=%esi
xorl aes128_x86mmx1_table2(,%eax,8),%esi

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p13=int32#1
# asm 2: movzbl <y1=%ch,>p13=%eax
movzbl %ch,%eax

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p13=int32#1,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table3(,<p13=%eax,8),<z2=%edi
xorl aes128_x86mmx1_table3(,%eax,8),%edi

# qhasm: y3 = y3_stack
# asm 1: movd <y3_stack=int3232#2,>y3=int32#1
# asm 2: movd <y3_stack=%mm1,>y3=%eax
movd %mm1,%eax

# qhasm: p20 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p20=int32#2
# asm 2: movzbl <y2=%dl,>p20=%ecx
movzbl %dl,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p20=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table0(,<p20=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table0(,%ecx,8),%edi

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p21=int32#2
# asm 2: movzbl <y2=%dh,>p21=%ecx
movzbl %dh,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p21=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table1(,<p21=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table1(,%ecx,8),%ebp

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int32#3
# asm 2: shr  $16,<y2=%edx
shr  $16,%edx

# qhasm: p22 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p22=int32#2
# asm 2: movzbl <y2=%dl,>p22=%ecx
movzbl %dl,%ecx

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p22=int32#2,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table2(,<p22=%ecx,8),<z0=%ebx
xorl aes128_x86mmx1_table2(,%ecx,8),%ebx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p23=int32#2
# asm 2: movzbl <y2=%dh,>p23=%ecx
movzbl %dh,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p23=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table3(,<p23=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table3(,%ecx,8),%esi

# qhasm: p30 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p30=int32#2
# asm 2: movzbl <y3=%al,>p30=%ecx
movzbl %al,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p30=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table0(,<p30=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table0(,%ecx,8),%esi

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p31=int32#2
# asm 2: movzbl <y3=%ah,>p31=%ecx
movzbl %ah,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p31=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table1(,<p31=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table1(,%ecx,8),%edi

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int32#1
# asm 2: shr  $16,<y3=%eax
shr  $16,%eax

# qhasm: p32 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p32=int32#2
# asm 2: movzbl <y3=%al,>p32=%ecx
movzbl %al,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p32=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table2(,<p32=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table2(,%ecx,8),%ebp

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p33=int32#1
# asm 2: movzbl <y3=%ah,>p33=%eax
movzbl %ah,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p33=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table3(,<p33=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table3(,%eax,8),%ebx

# qhasm: y0 = r4
# asm 1: movl <r4=stack32#10,>y0=int32#1
# asm 2: movl <r4=36(%esp),>y0=%eax
movl 36(%esp),%eax

# qhasm: y0 ^= z0
# asm 1: xorl <z0=int32#4,<y0=int32#1
# asm 2: xorl <z0=%ebx,<y0=%eax
xorl %ebx,%eax

# qhasm: y1 = r5
# asm 1: movl <r5=stack32#11,>y1=int32#2
# asm 2: movl <r5=40(%esp),>y1=%ecx
movl 40(%esp),%ecx

# qhasm: y1 ^= z1
# asm 1: xorl <z1=int32#7,<y1=int32#2
# asm 2: xorl <z1=%ebp,<y1=%ecx
xorl %ebp,%ecx

# qhasm: y2 = r6
# asm 1: movl <r6=stack32#12,>y2=int32#3
# asm 2: movl <r6=44(%esp),>y2=%edx
movl 44(%esp),%edx

# qhasm: y2 ^= z2
# asm 1: xorl <z2=int32#6,<y2=int32#3
# asm 2: xorl <z2=%edi,<y2=%edx
xorl %edi,%edx

# qhasm: y3 = r7
# asm 1: movl <r7=stack32#13,>y3=int32#4
# asm 2: movl <r7=48(%esp),>y3=%ebx
movl 48(%esp),%ebx

# qhasm: y3 ^= z3
# asm 1: xorl <z3=int32#5,<y3=int32#4
# asm 2: xorl <z3=%esi,<y3=%ebx
xorl %esi,%ebx

# qhasm: y3_stack = y3
# asm 1: movd <y3=int32#4,>y3_stack=int3232#2
# asm 2: movd <y3=%ebx,>y3_stack=%mm1
movd %ebx,%mm1

# qhasm: p00 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p00=int32#4
# asm 2: movzbl <y0=%al,>p00=%ebx
movzbl %al,%ebx

# qhasm: z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<p00=int32#4,8),>z0=int32#4
# asm 2: movl aes128_x86mmx1_table0(,<p00=%ebx,8),>z0=%ebx
movl aes128_x86mmx1_table0(,%ebx,8),%ebx

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p03=int32#5
# asm 2: movzbl <y0=%ah,>p03=%esi
movzbl %ah,%esi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int32#1
# asm 2: shr  $16,<y0=%eax
shr  $16,%eax

# qhasm: z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<p03=int32#5,8),>z3=int32#5
# asm 2: movl aes128_x86mmx1_table1(,<p03=%esi,8),>z3=%esi
movl aes128_x86mmx1_table1(,%esi,8),%esi

# qhasm: p02 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p02=int32#6
# asm 2: movzbl <y0=%al,>p02=%edi
movzbl %al,%edi

# qhasm: z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
# asm 1: movl aes128_x86mmx1_table2(,<p02=int32#6,8),>z2=int32#6
# asm 2: movl aes128_x86mmx1_table2(,<p02=%edi,8),>z2=%edi
movl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p01=int32#1
# asm 2: movzbl <y0=%ah,>p01=%eax
movzbl %ah,%eax

# qhasm: z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
# asm 1: movl aes128_x86mmx1_table3(,<p01=int32#1,8),>z1=int32#7
# asm 2: movl aes128_x86mmx1_table3(,<p01=%eax,8),>z1=%ebp
movl aes128_x86mmx1_table3(,%eax,8),%ebp

# qhasm: p10 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p10=int32#1
# asm 2: movzbl <y1=%cl,>p10=%eax
movzbl %cl,%eax

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p10=int32#1,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table0(,<p10=%eax,8),<z1=%ebp
xorl aes128_x86mmx1_table0(,%eax,8),%ebp

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p11=int32#1
# asm 2: movzbl <y1=%ch,>p11=%eax
movzbl %ch,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p11=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table1(,<p11=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table1(,%eax,8),%ebx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int32#2
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p12=int32#1
# asm 2: movzbl <y1=%cl,>p12=%eax
movzbl %cl,%eax

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p12=int32#1,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table2(,<p12=%eax,8),<z3=%esi
xorl aes128_x86mmx1_table2(,%eax,8),%esi

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p13=int32#1
# asm 2: movzbl <y1=%ch,>p13=%eax
movzbl %ch,%eax

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p13=int32#1,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table3(,<p13=%eax,8),<z2=%edi
xorl aes128_x86mmx1_table3(,%eax,8),%edi

# qhasm: y3 = y3_stack
# asm 1: movd <y3_stack=int3232#2,>y3=int32#1
# asm 2: movd <y3_stack=%mm1,>y3=%eax
movd %mm1,%eax

# qhasm: p20 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p20=int32#2
# asm 2: movzbl <y2=%dl,>p20=%ecx
movzbl %dl,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p20=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table0(,<p20=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table0(,%ecx,8),%edi

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p21=int32#2
# asm 2: movzbl <y2=%dh,>p21=%ecx
movzbl %dh,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p21=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table1(,<p21=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table1(,%ecx,8),%ebp

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int32#3
# asm 2: shr  $16,<y2=%edx
shr  $16,%edx

# qhasm: p22 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p22=int32#2
# asm 2: movzbl <y2=%dl,>p22=%ecx
movzbl %dl,%ecx

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p22=int32#2,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table2(,<p22=%ecx,8),<z0=%ebx
xorl aes128_x86mmx1_table2(,%ecx,8),%ebx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p23=int32#2
# asm 2: movzbl <y2=%dh,>p23=%ecx
movzbl %dh,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p23=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table3(,<p23=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table3(,%ecx,8),%esi

# qhasm: p30 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p30=int32#2
# asm 2: movzbl <y3=%al,>p30=%ecx
movzbl %al,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p30=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table0(,<p30=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table0(,%ecx,8),%esi

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p31=int32#2
# asm 2: movzbl <y3=%ah,>p31=%ecx
movzbl %ah,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p31=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table1(,<p31=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table1(,%ecx,8),%edi

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int32#1
# asm 2: shr  $16,<y3=%eax
shr  $16,%eax

# qhasm: p32 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p32=int32#2
# asm 2: movzbl <y3=%al,>p32=%ecx
movzbl %al,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p32=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table2(,<p32=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table2(,%ecx,8),%ebp

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p33=int32#1
# asm 2: movzbl <y3=%ah,>p33=%eax
movzbl %ah,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p33=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table3(,<p33=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table3(,%eax,8),%ebx

# qhasm: y0 = r8
# asm 1: movl <r8=stack32#14,>y0=int32#1
# asm 2: movl <r8=52(%esp),>y0=%eax
movl 52(%esp),%eax

# qhasm: y0 ^= z0
# asm 1: xorl <z0=int32#4,<y0=int32#1
# asm 2: xorl <z0=%ebx,<y0=%eax
xorl %ebx,%eax

# qhasm: y1 = r9
# asm 1: movl <r9=stack32#15,>y1=int32#2
# asm 2: movl <r9=56(%esp),>y1=%ecx
movl 56(%esp),%ecx

# qhasm: y1 ^= z1
# asm 1: xorl <z1=int32#7,<y1=int32#2
# asm 2: xorl <z1=%ebp,<y1=%ecx
xorl %ebp,%ecx

# qhasm: y2 = r10
# asm 1: movl <r10=stack32#16,>y2=int32#3
# asm 2: movl <r10=60(%esp),>y2=%edx
movl 60(%esp),%edx

# qhasm: y2 ^= z2
# asm 1: xorl <z2=int32#6,<y2=int32#3
# asm 2: xorl <z2=%edi,<y2=%edx
xorl %edi,%edx

# qhasm: y3 = r11
# asm 1: movl <r11=stack32#17,>y3=int32#4
# asm 2: movl <r11=64(%esp),>y3=%ebx
movl 64(%esp),%ebx

# qhasm: y3 ^= z3
# asm 1: xorl <z3=int32#5,<y3=int32#4
# asm 2: xorl <z3=%esi,<y3=%ebx
xorl %esi,%ebx

# qhasm: y3_stack = y3
# asm 1: movd <y3=int32#4,>y3_stack=int3232#2
# asm 2: movd <y3=%ebx,>y3_stack=%mm1
movd %ebx,%mm1

# qhasm: p00 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p00=int32#4
# asm 2: movzbl <y0=%al,>p00=%ebx
movzbl %al,%ebx

# qhasm: z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<p00=int32#4,8),>z0=int32#4
# asm 2: movl aes128_x86mmx1_table0(,<p00=%ebx,8),>z0=%ebx
movl aes128_x86mmx1_table0(,%ebx,8),%ebx

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p03=int32#5
# asm 2: movzbl <y0=%ah,>p03=%esi
movzbl %ah,%esi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int32#1
# asm 2: shr  $16,<y0=%eax
shr  $16,%eax

# qhasm: z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<p03=int32#5,8),>z3=int32#5
# asm 2: movl aes128_x86mmx1_table1(,<p03=%esi,8),>z3=%esi
movl aes128_x86mmx1_table1(,%esi,8),%esi

# qhasm: p02 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p02=int32#6
# asm 2: movzbl <y0=%al,>p02=%edi
movzbl %al,%edi

# qhasm: z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
# asm 1: movl aes128_x86mmx1_table2(,<p02=int32#6,8),>z2=int32#6
# asm 2: movl aes128_x86mmx1_table2(,<p02=%edi,8),>z2=%edi
movl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p01=int32#1
# asm 2: movzbl <y0=%ah,>p01=%eax
movzbl %ah,%eax

# qhasm: z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
# asm 1: movl aes128_x86mmx1_table3(,<p01=int32#1,8),>z1=int32#7
# asm 2: movl aes128_x86mmx1_table3(,<p01=%eax,8),>z1=%ebp
movl aes128_x86mmx1_table3(,%eax,8),%ebp

# qhasm: p10 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p10=int32#1
# asm 2: movzbl <y1=%cl,>p10=%eax
movzbl %cl,%eax

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p10=int32#1,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table0(,<p10=%eax,8),<z1=%ebp
xorl aes128_x86mmx1_table0(,%eax,8),%ebp

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p11=int32#1
# asm 2: movzbl <y1=%ch,>p11=%eax
movzbl %ch,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p11=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table1(,<p11=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table1(,%eax,8),%ebx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int32#2
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p12=int32#1
# asm 2: movzbl <y1=%cl,>p12=%eax
movzbl %cl,%eax

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p12=int32#1,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table2(,<p12=%eax,8),<z3=%esi
xorl aes128_x86mmx1_table2(,%eax,8),%esi

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p13=int32#1
# asm 2: movzbl <y1=%ch,>p13=%eax
movzbl %ch,%eax

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p13=int32#1,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table3(,<p13=%eax,8),<z2=%edi
xorl aes128_x86mmx1_table3(,%eax,8),%edi

# qhasm: y3 = y3_stack
# asm 1: movd <y3_stack=int3232#2,>y3=int32#1
# asm 2: movd <y3_stack=%mm1,>y3=%eax
movd %mm1,%eax

# qhasm: p20 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p20=int32#2
# asm 2: movzbl <y2=%dl,>p20=%ecx
movzbl %dl,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p20=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table0(,<p20=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table0(,%ecx,8),%edi

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p21=int32#2
# asm 2: movzbl <y2=%dh,>p21=%ecx
movzbl %dh,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p21=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table1(,<p21=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table1(,%ecx,8),%ebp

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int32#3
# asm 2: shr  $16,<y2=%edx
shr  $16,%edx

# qhasm: p22 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p22=int32#2
# asm 2: movzbl <y2=%dl,>p22=%ecx
movzbl %dl,%ecx

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p22=int32#2,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table2(,<p22=%ecx,8),<z0=%ebx
xorl aes128_x86mmx1_table2(,%ecx,8),%ebx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p23=int32#2
# asm 2: movzbl <y2=%dh,>p23=%ecx
movzbl %dh,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p23=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table3(,<p23=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table3(,%ecx,8),%esi

# qhasm: p30 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p30=int32#2
# asm 2: movzbl <y3=%al,>p30=%ecx
movzbl %al,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p30=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table0(,<p30=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table0(,%ecx,8),%esi

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p31=int32#2
# asm 2: movzbl <y3=%ah,>p31=%ecx
movzbl %ah,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p31=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table1(,<p31=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table1(,%ecx,8),%edi

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int32#1
# asm 2: shr  $16,<y3=%eax
shr  $16,%eax

# qhasm: p32 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p32=int32#2
# asm 2: movzbl <y3=%al,>p32=%ecx
movzbl %al,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p32=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table2(,<p32=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table2(,%ecx,8),%ebp

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p33=int32#1
# asm 2: movzbl <y3=%ah,>p33=%eax
movzbl %ah,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p33=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table3(,<p33=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table3(,%eax,8),%ebx

# qhasm: y0 = r12
# asm 1: movl <r12=stack32#18,>y0=int32#1
# asm 2: movl <r12=68(%esp),>y0=%eax
movl 68(%esp),%eax

# qhasm: y0 ^= z0
# asm 1: xorl <z0=int32#4,<y0=int32#1
# asm 2: xorl <z0=%ebx,<y0=%eax
xorl %ebx,%eax

# qhasm: y1 = r13
# asm 1: movl <r13=stack32#19,>y1=int32#2
# asm 2: movl <r13=72(%esp),>y1=%ecx
movl 72(%esp),%ecx

# qhasm: y1 ^= z1
# asm 1: xorl <z1=int32#7,<y1=int32#2
# asm 2: xorl <z1=%ebp,<y1=%ecx
xorl %ebp,%ecx

# qhasm: y2 = r14
# asm 1: movl <r14=stack32#20,>y2=int32#3
# asm 2: movl <r14=76(%esp),>y2=%edx
movl 76(%esp),%edx

# qhasm: y2 ^= z2
# asm 1: xorl <z2=int32#6,<y2=int32#3
# asm 2: xorl <z2=%edi,<y2=%edx
xorl %edi,%edx

# qhasm: y3 = r15
# asm 1: movl <r15=stack32#21,>y3=int32#4
# asm 2: movl <r15=80(%esp),>y3=%ebx
movl 80(%esp),%ebx

# qhasm: y3 ^= z3
# asm 1: xorl <z3=int32#5,<y3=int32#4
# asm 2: xorl <z3=%esi,<y3=%ebx
xorl %esi,%ebx

# qhasm: y3_stack = y3
# asm 1: movd <y3=int32#4,>y3_stack=int3232#2
# asm 2: movd <y3=%ebx,>y3_stack=%mm1
movd %ebx,%mm1

# qhasm: p00 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p00=int32#4
# asm 2: movzbl <y0=%al,>p00=%ebx
movzbl %al,%ebx

# qhasm: z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<p00=int32#4,8),>z0=int32#4
# asm 2: movl aes128_x86mmx1_table0(,<p00=%ebx,8),>z0=%ebx
movl aes128_x86mmx1_table0(,%ebx,8),%ebx

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p03=int32#5
# asm 2: movzbl <y0=%ah,>p03=%esi
movzbl %ah,%esi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int32#1
# asm 2: shr  $16,<y0=%eax
shr  $16,%eax

# qhasm: z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<p03=int32#5,8),>z3=int32#5
# asm 2: movl aes128_x86mmx1_table1(,<p03=%esi,8),>z3=%esi
movl aes128_x86mmx1_table1(,%esi,8),%esi

# qhasm: p02 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p02=int32#6
# asm 2: movzbl <y0=%al,>p02=%edi
movzbl %al,%edi

# qhasm: z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
# asm 1: movl aes128_x86mmx1_table2(,<p02=int32#6,8),>z2=int32#6
# asm 2: movl aes128_x86mmx1_table2(,<p02=%edi,8),>z2=%edi
movl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p01=int32#1
# asm 2: movzbl <y0=%ah,>p01=%eax
movzbl %ah,%eax

# qhasm: z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
# asm 1: movl aes128_x86mmx1_table3(,<p01=int32#1,8),>z1=int32#7
# asm 2: movl aes128_x86mmx1_table3(,<p01=%eax,8),>z1=%ebp
movl aes128_x86mmx1_table3(,%eax,8),%ebp

# qhasm: p10 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p10=int32#1
# asm 2: movzbl <y1=%cl,>p10=%eax
movzbl %cl,%eax

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p10=int32#1,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table0(,<p10=%eax,8),<z1=%ebp
xorl aes128_x86mmx1_table0(,%eax,8),%ebp

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p11=int32#1
# asm 2: movzbl <y1=%ch,>p11=%eax
movzbl %ch,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p11=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table1(,<p11=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table1(,%eax,8),%ebx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int32#2
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p12=int32#1
# asm 2: movzbl <y1=%cl,>p12=%eax
movzbl %cl,%eax

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p12=int32#1,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table2(,<p12=%eax,8),<z3=%esi
xorl aes128_x86mmx1_table2(,%eax,8),%esi

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p13=int32#1
# asm 2: movzbl <y1=%ch,>p13=%eax
movzbl %ch,%eax

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p13=int32#1,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table3(,<p13=%eax,8),<z2=%edi
xorl aes128_x86mmx1_table3(,%eax,8),%edi

# qhasm: y3 = y3_stack
# asm 1: movd <y3_stack=int3232#2,>y3=int32#1
# asm 2: movd <y3_stack=%mm1,>y3=%eax
movd %mm1,%eax

# qhasm: p20 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p20=int32#2
# asm 2: movzbl <y2=%dl,>p20=%ecx
movzbl %dl,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p20=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table0(,<p20=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table0(,%ecx,8),%edi

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p21=int32#2
# asm 2: movzbl <y2=%dh,>p21=%ecx
movzbl %dh,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p21=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table1(,<p21=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table1(,%ecx,8),%ebp

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int32#3
# asm 2: shr  $16,<y2=%edx
shr  $16,%edx

# qhasm: p22 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p22=int32#2
# asm 2: movzbl <y2=%dl,>p22=%ecx
movzbl %dl,%ecx

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p22=int32#2,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table2(,<p22=%ecx,8),<z0=%ebx
xorl aes128_x86mmx1_table2(,%ecx,8),%ebx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p23=int32#2
# asm 2: movzbl <y2=%dh,>p23=%ecx
movzbl %dh,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p23=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table3(,<p23=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table3(,%ecx,8),%esi

# qhasm: p30 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p30=int32#2
# asm 2: movzbl <y3=%al,>p30=%ecx
movzbl %al,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p30=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table0(,<p30=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table0(,%ecx,8),%esi

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p31=int32#2
# asm 2: movzbl <y3=%ah,>p31=%ecx
movzbl %ah,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p31=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table1(,<p31=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table1(,%ecx,8),%edi

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int32#1
# asm 2: shr  $16,<y3=%eax
shr  $16,%eax

# qhasm: p32 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p32=int32#2
# asm 2: movzbl <y3=%al,>p32=%ecx
movzbl %al,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p32=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table2(,<p32=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table2(,%ecx,8),%ebp

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p33=int32#1
# asm 2: movzbl <y3=%ah,>p33=%eax
movzbl %ah,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p33=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table3(,<p33=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table3(,%eax,8),%ebx

# qhasm: y0 = r16
# asm 1: movl <r16=stack32#22,>y0=int32#1
# asm 2: movl <r16=84(%esp),>y0=%eax
movl 84(%esp),%eax

# qhasm: y0 ^= z0
# asm 1: xorl <z0=int32#4,<y0=int32#1
# asm 2: xorl <z0=%ebx,<y0=%eax
xorl %ebx,%eax

# qhasm: y1 = r17
# asm 1: movl <r17=stack32#23,>y1=int32#2
# asm 2: movl <r17=88(%esp),>y1=%ecx
movl 88(%esp),%ecx

# qhasm: y1 ^= z1
# asm 1: xorl <z1=int32#7,<y1=int32#2
# asm 2: xorl <z1=%ebp,<y1=%ecx
xorl %ebp,%ecx

# qhasm: y2 = r18
# asm 1: movl <r18=stack32#24,>y2=int32#3
# asm 2: movl <r18=92(%esp),>y2=%edx
movl 92(%esp),%edx

# qhasm: y2 ^= z2
# asm 1: xorl <z2=int32#6,<y2=int32#3
# asm 2: xorl <z2=%edi,<y2=%edx
xorl %edi,%edx

# qhasm: y3 = r19
# asm 1: movl <r19=stack32#25,>y3=int32#4
# asm 2: movl <r19=96(%esp),>y3=%ebx
movl 96(%esp),%ebx

# qhasm: y3 ^= z3
# asm 1: xorl <z3=int32#5,<y3=int32#4
# asm 2: xorl <z3=%esi,<y3=%ebx
xorl %esi,%ebx

# qhasm: y3_stack = y3
# asm 1: movd <y3=int32#4,>y3_stack=int3232#2
# asm 2: movd <y3=%ebx,>y3_stack=%mm1
movd %ebx,%mm1

# qhasm: p00 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p00=int32#4
# asm 2: movzbl <y0=%al,>p00=%ebx
movzbl %al,%ebx

# qhasm: z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<p00=int32#4,8),>z0=int32#4
# asm 2: movl aes128_x86mmx1_table0(,<p00=%ebx,8),>z0=%ebx
movl aes128_x86mmx1_table0(,%ebx,8),%ebx

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p03=int32#5
# asm 2: movzbl <y0=%ah,>p03=%esi
movzbl %ah,%esi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int32#1
# asm 2: shr  $16,<y0=%eax
shr  $16,%eax

# qhasm: z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<p03=int32#5,8),>z3=int32#5
# asm 2: movl aes128_x86mmx1_table1(,<p03=%esi,8),>z3=%esi
movl aes128_x86mmx1_table1(,%esi,8),%esi

# qhasm: p02 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p02=int32#6
# asm 2: movzbl <y0=%al,>p02=%edi
movzbl %al,%edi

# qhasm: z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
# asm 1: movl aes128_x86mmx1_table2(,<p02=int32#6,8),>z2=int32#6
# asm 2: movl aes128_x86mmx1_table2(,<p02=%edi,8),>z2=%edi
movl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p01=int32#1
# asm 2: movzbl <y0=%ah,>p01=%eax
movzbl %ah,%eax

# qhasm: z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
# asm 1: movl aes128_x86mmx1_table3(,<p01=int32#1,8),>z1=int32#7
# asm 2: movl aes128_x86mmx1_table3(,<p01=%eax,8),>z1=%ebp
movl aes128_x86mmx1_table3(,%eax,8),%ebp

# qhasm: p10 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p10=int32#1
# asm 2: movzbl <y1=%cl,>p10=%eax
movzbl %cl,%eax

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p10=int32#1,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table0(,<p10=%eax,8),<z1=%ebp
xorl aes128_x86mmx1_table0(,%eax,8),%ebp

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p11=int32#1
# asm 2: movzbl <y1=%ch,>p11=%eax
movzbl %ch,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p11=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table1(,<p11=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table1(,%eax,8),%ebx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int32#2
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p12=int32#1
# asm 2: movzbl <y1=%cl,>p12=%eax
movzbl %cl,%eax

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p12=int32#1,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table2(,<p12=%eax,8),<z3=%esi
xorl aes128_x86mmx1_table2(,%eax,8),%esi

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p13=int32#1
# asm 2: movzbl <y1=%ch,>p13=%eax
movzbl %ch,%eax

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p13=int32#1,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table3(,<p13=%eax,8),<z2=%edi
xorl aes128_x86mmx1_table3(,%eax,8),%edi

# qhasm: y3 = y3_stack
# asm 1: movd <y3_stack=int3232#2,>y3=int32#1
# asm 2: movd <y3_stack=%mm1,>y3=%eax
movd %mm1,%eax

# qhasm: p20 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p20=int32#2
# asm 2: movzbl <y2=%dl,>p20=%ecx
movzbl %dl,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p20=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table0(,<p20=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table0(,%ecx,8),%edi

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p21=int32#2
# asm 2: movzbl <y2=%dh,>p21=%ecx
movzbl %dh,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p21=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table1(,<p21=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table1(,%ecx,8),%ebp

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int32#3
# asm 2: shr  $16,<y2=%edx
shr  $16,%edx

# qhasm: p22 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p22=int32#2
# asm 2: movzbl <y2=%dl,>p22=%ecx
movzbl %dl,%ecx

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p22=int32#2,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table2(,<p22=%ecx,8),<z0=%ebx
xorl aes128_x86mmx1_table2(,%ecx,8),%ebx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p23=int32#2
# asm 2: movzbl <y2=%dh,>p23=%ecx
movzbl %dh,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p23=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table3(,<p23=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table3(,%ecx,8),%esi

# qhasm: p30 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p30=int32#2
# asm 2: movzbl <y3=%al,>p30=%ecx
movzbl %al,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p30=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table0(,<p30=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table0(,%ecx,8),%esi

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p31=int32#2
# asm 2: movzbl <y3=%ah,>p31=%ecx
movzbl %ah,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p31=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table1(,<p31=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table1(,%ecx,8),%edi

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int32#1
# asm 2: shr  $16,<y3=%eax
shr  $16,%eax

# qhasm: p32 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p32=int32#2
# asm 2: movzbl <y3=%al,>p32=%ecx
movzbl %al,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p32=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table2(,<p32=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table2(,%ecx,8),%ebp

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p33=int32#1
# asm 2: movzbl <y3=%ah,>p33=%eax
movzbl %ah,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p33=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table3(,<p33=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table3(,%eax,8),%ebx

# qhasm: y0 = r20
# asm 1: movl <r20=stack32#26,>y0=int32#1
# asm 2: movl <r20=100(%esp),>y0=%eax
movl 100(%esp),%eax

# qhasm: y0 ^= z0
# asm 1: xorl <z0=int32#4,<y0=int32#1
# asm 2: xorl <z0=%ebx,<y0=%eax
xorl %ebx,%eax

# qhasm: y1 = r21
# asm 1: movl <r21=stack32#27,>y1=int32#2
# asm 2: movl <r21=104(%esp),>y1=%ecx
movl 104(%esp),%ecx

# qhasm: y1 ^= z1
# asm 1: xorl <z1=int32#7,<y1=int32#2
# asm 2: xorl <z1=%ebp,<y1=%ecx
xorl %ebp,%ecx

# qhasm: y2 = r22
# asm 1: movl <r22=stack32#28,>y2=int32#3
# asm 2: movl <r22=108(%esp),>y2=%edx
movl 108(%esp),%edx

# qhasm: y2 ^= z2
# asm 1: xorl <z2=int32#6,<y2=int32#3
# asm 2: xorl <z2=%edi,<y2=%edx
xorl %edi,%edx

# qhasm: y3 = r23
# asm 1: movl <r23=stack32#29,>y3=int32#4
# asm 2: movl <r23=112(%esp),>y3=%ebx
movl 112(%esp),%ebx

# qhasm: y3 ^= z3
# asm 1: xorl <z3=int32#5,<y3=int32#4
# asm 2: xorl <z3=%esi,<y3=%ebx
xorl %esi,%ebx

# qhasm: y3_stack = y3
# asm 1: movd <y3=int32#4,>y3_stack=int3232#2
# asm 2: movd <y3=%ebx,>y3_stack=%mm1
movd %ebx,%mm1

# qhasm: p00 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p00=int32#4
# asm 2: movzbl <y0=%al,>p00=%ebx
movzbl %al,%ebx

# qhasm: z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<p00=int32#4,8),>z0=int32#4
# asm 2: movl aes128_x86mmx1_table0(,<p00=%ebx,8),>z0=%ebx
movl aes128_x86mmx1_table0(,%ebx,8),%ebx

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p03=int32#5
# asm 2: movzbl <y0=%ah,>p03=%esi
movzbl %ah,%esi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int32#1
# asm 2: shr  $16,<y0=%eax
shr  $16,%eax

# qhasm: z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<p03=int32#5,8),>z3=int32#5
# asm 2: movl aes128_x86mmx1_table1(,<p03=%esi,8),>z3=%esi
movl aes128_x86mmx1_table1(,%esi,8),%esi

# qhasm: p02 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p02=int32#6
# asm 2: movzbl <y0=%al,>p02=%edi
movzbl %al,%edi

# qhasm: z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
# asm 1: movl aes128_x86mmx1_table2(,<p02=int32#6,8),>z2=int32#6
# asm 2: movl aes128_x86mmx1_table2(,<p02=%edi,8),>z2=%edi
movl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p01=int32#1
# asm 2: movzbl <y0=%ah,>p01=%eax
movzbl %ah,%eax

# qhasm: z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
# asm 1: movl aes128_x86mmx1_table3(,<p01=int32#1,8),>z1=int32#7
# asm 2: movl aes128_x86mmx1_table3(,<p01=%eax,8),>z1=%ebp
movl aes128_x86mmx1_table3(,%eax,8),%ebp

# qhasm: p10 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p10=int32#1
# asm 2: movzbl <y1=%cl,>p10=%eax
movzbl %cl,%eax

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p10=int32#1,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table0(,<p10=%eax,8),<z1=%ebp
xorl aes128_x86mmx1_table0(,%eax,8),%ebp

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p11=int32#1
# asm 2: movzbl <y1=%ch,>p11=%eax
movzbl %ch,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p11=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table1(,<p11=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table1(,%eax,8),%ebx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int32#2
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p12=int32#1
# asm 2: movzbl <y1=%cl,>p12=%eax
movzbl %cl,%eax

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p12=int32#1,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table2(,<p12=%eax,8),<z3=%esi
xorl aes128_x86mmx1_table2(,%eax,8),%esi

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p13=int32#1
# asm 2: movzbl <y1=%ch,>p13=%eax
movzbl %ch,%eax

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p13=int32#1,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table3(,<p13=%eax,8),<z2=%edi
xorl aes128_x86mmx1_table3(,%eax,8),%edi

# qhasm: y3 = y3_stack
# asm 1: movd <y3_stack=int3232#2,>y3=int32#1
# asm 2: movd <y3_stack=%mm1,>y3=%eax
movd %mm1,%eax

# qhasm: p20 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p20=int32#2
# asm 2: movzbl <y2=%dl,>p20=%ecx
movzbl %dl,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p20=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table0(,<p20=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table0(,%ecx,8),%edi

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p21=int32#2
# asm 2: movzbl <y2=%dh,>p21=%ecx
movzbl %dh,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p21=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table1(,<p21=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table1(,%ecx,8),%ebp

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int32#3
# asm 2: shr  $16,<y2=%edx
shr  $16,%edx

# qhasm: p22 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p22=int32#2
# asm 2: movzbl <y2=%dl,>p22=%ecx
movzbl %dl,%ecx

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p22=int32#2,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table2(,<p22=%ecx,8),<z0=%ebx
xorl aes128_x86mmx1_table2(,%ecx,8),%ebx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p23=int32#2
# asm 2: movzbl <y2=%dh,>p23=%ecx
movzbl %dh,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p23=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table3(,<p23=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table3(,%ecx,8),%esi

# qhasm: p30 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p30=int32#2
# asm 2: movzbl <y3=%al,>p30=%ecx
movzbl %al,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p30=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table0(,<p30=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table0(,%ecx,8),%esi

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p31=int32#2
# asm 2: movzbl <y3=%ah,>p31=%ecx
movzbl %ah,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p31=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table1(,<p31=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table1(,%ecx,8),%edi

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int32#1
# asm 2: shr  $16,<y3=%eax
shr  $16,%eax

# qhasm: p32 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p32=int32#2
# asm 2: movzbl <y3=%al,>p32=%ecx
movzbl %al,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p32=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table2(,<p32=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table2(,%ecx,8),%ebp

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p33=int32#1
# asm 2: movzbl <y3=%ah,>p33=%eax
movzbl %ah,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p33=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table3(,<p33=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table3(,%eax,8),%ebx

# qhasm: y0 = r24
# asm 1: movl <r24=stack32#30,>y0=int32#1
# asm 2: movl <r24=116(%esp),>y0=%eax
movl 116(%esp),%eax

# qhasm: y0 ^= z0
# asm 1: xorl <z0=int32#4,<y0=int32#1
# asm 2: xorl <z0=%ebx,<y0=%eax
xorl %ebx,%eax

# qhasm: y1 = r25
# asm 1: movl <r25=stack32#31,>y1=int32#2
# asm 2: movl <r25=120(%esp),>y1=%ecx
movl 120(%esp),%ecx

# qhasm: y1 ^= z1
# asm 1: xorl <z1=int32#7,<y1=int32#2
# asm 2: xorl <z1=%ebp,<y1=%ecx
xorl %ebp,%ecx

# qhasm: y2 = r26
# asm 1: movl <r26=stack32#32,>y2=int32#3
# asm 2: movl <r26=124(%esp),>y2=%edx
movl 124(%esp),%edx

# qhasm: y2 ^= z2
# asm 1: xorl <z2=int32#6,<y2=int32#3
# asm 2: xorl <z2=%edi,<y2=%edx
xorl %edi,%edx

# qhasm: y3 = r27
# asm 1: movl <r27=stack32#33,>y3=int32#4
# asm 2: movl <r27=128(%esp),>y3=%ebx
movl 128(%esp),%ebx

# qhasm: y3 ^= z3
# asm 1: xorl <z3=int32#5,<y3=int32#4
# asm 2: xorl <z3=%esi,<y3=%ebx
xorl %esi,%ebx

# qhasm: y3_stack = y3
# asm 1: movd <y3=int32#4,>y3_stack=int3232#2
# asm 2: movd <y3=%ebx,>y3_stack=%mm1
movd %ebx,%mm1

# qhasm: p00 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p00=int32#4
# asm 2: movzbl <y0=%al,>p00=%ebx
movzbl %al,%ebx

# qhasm: z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<p00=int32#4,8),>z0=int32#4
# asm 2: movl aes128_x86mmx1_table0(,<p00=%ebx,8),>z0=%ebx
movl aes128_x86mmx1_table0(,%ebx,8),%ebx

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p03=int32#5
# asm 2: movzbl <y0=%ah,>p03=%esi
movzbl %ah,%esi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int32#1
# asm 2: shr  $16,<y0=%eax
shr  $16,%eax

# qhasm: z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<p03=int32#5,8),>z3=int32#5
# asm 2: movl aes128_x86mmx1_table1(,<p03=%esi,8),>z3=%esi
movl aes128_x86mmx1_table1(,%esi,8),%esi

# qhasm: p02 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p02=int32#6
# asm 2: movzbl <y0=%al,>p02=%edi
movzbl %al,%edi

# qhasm: z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
# asm 1: movl aes128_x86mmx1_table2(,<p02=int32#6,8),>z2=int32#6
# asm 2: movl aes128_x86mmx1_table2(,<p02=%edi,8),>z2=%edi
movl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p01=int32#1
# asm 2: movzbl <y0=%ah,>p01=%eax
movzbl %ah,%eax

# qhasm: z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
# asm 1: movl aes128_x86mmx1_table3(,<p01=int32#1,8),>z1=int32#7
# asm 2: movl aes128_x86mmx1_table3(,<p01=%eax,8),>z1=%ebp
movl aes128_x86mmx1_table3(,%eax,8),%ebp

# qhasm: p10 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p10=int32#1
# asm 2: movzbl <y1=%cl,>p10=%eax
movzbl %cl,%eax

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p10=int32#1,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table0(,<p10=%eax,8),<z1=%ebp
xorl aes128_x86mmx1_table0(,%eax,8),%ebp

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p11=int32#1
# asm 2: movzbl <y1=%ch,>p11=%eax
movzbl %ch,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p11=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table1(,<p11=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table1(,%eax,8),%ebx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int32#2
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p12=int32#1
# asm 2: movzbl <y1=%cl,>p12=%eax
movzbl %cl,%eax

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p12=int32#1,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table2(,<p12=%eax,8),<z3=%esi
xorl aes128_x86mmx1_table2(,%eax,8),%esi

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p13=int32#1
# asm 2: movzbl <y1=%ch,>p13=%eax
movzbl %ch,%eax

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p13=int32#1,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table3(,<p13=%eax,8),<z2=%edi
xorl aes128_x86mmx1_table3(,%eax,8),%edi

# qhasm: y3 = y3_stack
# asm 1: movd <y3_stack=int3232#2,>y3=int32#1
# asm 2: movd <y3_stack=%mm1,>y3=%eax
movd %mm1,%eax

# qhasm: p20 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p20=int32#2
# asm 2: movzbl <y2=%dl,>p20=%ecx
movzbl %dl,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p20=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table0(,<p20=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table0(,%ecx,8),%edi

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p21=int32#2
# asm 2: movzbl <y2=%dh,>p21=%ecx
movzbl %dh,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p21=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table1(,<p21=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table1(,%ecx,8),%ebp

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int32#3
# asm 2: shr  $16,<y2=%edx
shr  $16,%edx

# qhasm: p22 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p22=int32#2
# asm 2: movzbl <y2=%dl,>p22=%ecx
movzbl %dl,%ecx

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p22=int32#2,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table2(,<p22=%ecx,8),<z0=%ebx
xorl aes128_x86mmx1_table2(,%ecx,8),%ebx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p23=int32#2
# asm 2: movzbl <y2=%dh,>p23=%ecx
movzbl %dh,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p23=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table3(,<p23=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table3(,%ecx,8),%esi

# qhasm: p30 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p30=int32#2
# asm 2: movzbl <y3=%al,>p30=%ecx
movzbl %al,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p30=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table0(,<p30=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table0(,%ecx,8),%esi

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p31=int32#2
# asm 2: movzbl <y3=%ah,>p31=%ecx
movzbl %ah,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p31=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table1(,<p31=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table1(,%ecx,8),%edi

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int32#1
# asm 2: shr  $16,<y3=%eax
shr  $16,%eax

# qhasm: p32 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p32=int32#2
# asm 2: movzbl <y3=%al,>p32=%ecx
movzbl %al,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p32=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table2(,<p32=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table2(,%ecx,8),%ebp

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p33=int32#1
# asm 2: movzbl <y3=%ah,>p33=%eax
movzbl %ah,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p33=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table3(,<p33=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table3(,%eax,8),%ebx

# qhasm: y0 = r28
# asm 1: movl <r28=stack32#34,>y0=int32#1
# asm 2: movl <r28=132(%esp),>y0=%eax
movl 132(%esp),%eax

# qhasm: y0 ^= z0
# asm 1: xorl <z0=int32#4,<y0=int32#1
# asm 2: xorl <z0=%ebx,<y0=%eax
xorl %ebx,%eax

# qhasm: y1 = r29
# asm 1: movl <r29=stack32#35,>y1=int32#2
# asm 2: movl <r29=136(%esp),>y1=%ecx
movl 136(%esp),%ecx

# qhasm: y1 ^= z1
# asm 1: xorl <z1=int32#7,<y1=int32#2
# asm 2: xorl <z1=%ebp,<y1=%ecx
xorl %ebp,%ecx

# qhasm: y2 = r30
# asm 1: movl <r30=stack32#36,>y2=int32#3
# asm 2: movl <r30=140(%esp),>y2=%edx
movl 140(%esp),%edx

# qhasm: y2 ^= z2
# asm 1: xorl <z2=int32#6,<y2=int32#3
# asm 2: xorl <z2=%edi,<y2=%edx
xorl %edi,%edx

# qhasm: y3 = r31
# asm 1: movl <r31=stack32#37,>y3=int32#4
# asm 2: movl <r31=144(%esp),>y3=%ebx
movl 144(%esp),%ebx

# qhasm: y3 ^= z3
# asm 1: xorl <z3=int32#5,<y3=int32#4
# asm 2: xorl <z3=%esi,<y3=%ebx
xorl %esi,%ebx

# qhasm: y3_stack = y3
# asm 1: movd <y3=int32#4,>y3_stack=int3232#2
# asm 2: movd <y3=%ebx,>y3_stack=%mm1
movd %ebx,%mm1

# qhasm: p00 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p00=int32#4
# asm 2: movzbl <y0=%al,>p00=%ebx
movzbl %al,%ebx

# qhasm: z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<p00=int32#4,8),>z0=int32#4
# asm 2: movl aes128_x86mmx1_table0(,<p00=%ebx,8),>z0=%ebx
movl aes128_x86mmx1_table0(,%ebx,8),%ebx

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p03=int32#5
# asm 2: movzbl <y0=%ah,>p03=%esi
movzbl %ah,%esi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int32#1
# asm 2: shr  $16,<y0=%eax
shr  $16,%eax

# qhasm: z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<p03=int32#5,8),>z3=int32#5
# asm 2: movl aes128_x86mmx1_table1(,<p03=%esi,8),>z3=%esi
movl aes128_x86mmx1_table1(,%esi,8),%esi

# qhasm: p02 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p02=int32#6
# asm 2: movzbl <y0=%al,>p02=%edi
movzbl %al,%edi

# qhasm: z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
# asm 1: movl aes128_x86mmx1_table2(,<p02=int32#6,8),>z2=int32#6
# asm 2: movl aes128_x86mmx1_table2(,<p02=%edi,8),>z2=%edi
movl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p01=int32#1
# asm 2: movzbl <y0=%ah,>p01=%eax
movzbl %ah,%eax

# qhasm: z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
# asm 1: movl aes128_x86mmx1_table3(,<p01=int32#1,8),>z1=int32#7
# asm 2: movl aes128_x86mmx1_table3(,<p01=%eax,8),>z1=%ebp
movl aes128_x86mmx1_table3(,%eax,8),%ebp

# qhasm: p10 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p10=int32#1
# asm 2: movzbl <y1=%cl,>p10=%eax
movzbl %cl,%eax

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p10=int32#1,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table0(,<p10=%eax,8),<z1=%ebp
xorl aes128_x86mmx1_table0(,%eax,8),%ebp

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p11=int32#1
# asm 2: movzbl <y1=%ch,>p11=%eax
movzbl %ch,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p11=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table1(,<p11=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table1(,%eax,8),%ebx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int32#2
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p12=int32#1
# asm 2: movzbl <y1=%cl,>p12=%eax
movzbl %cl,%eax

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p12=int32#1,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table2(,<p12=%eax,8),<z3=%esi
xorl aes128_x86mmx1_table2(,%eax,8),%esi

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p13=int32#1
# asm 2: movzbl <y1=%ch,>p13=%eax
movzbl %ch,%eax

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p13=int32#1,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table3(,<p13=%eax,8),<z2=%edi
xorl aes128_x86mmx1_table3(,%eax,8),%edi

# qhasm: y3 = y3_stack
# asm 1: movd <y3_stack=int3232#2,>y3=int32#1
# asm 2: movd <y3_stack=%mm1,>y3=%eax
movd %mm1,%eax

# qhasm: p20 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p20=int32#2
# asm 2: movzbl <y2=%dl,>p20=%ecx
movzbl %dl,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p20=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table0(,<p20=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table0(,%ecx,8),%edi

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p21=int32#2
# asm 2: movzbl <y2=%dh,>p21=%ecx
movzbl %dh,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p21=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table1(,<p21=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table1(,%ecx,8),%ebp

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int32#3
# asm 2: shr  $16,<y2=%edx
shr  $16,%edx

# qhasm: p22 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p22=int32#2
# asm 2: movzbl <y2=%dl,>p22=%ecx
movzbl %dl,%ecx

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p22=int32#2,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table2(,<p22=%ecx,8),<z0=%ebx
xorl aes128_x86mmx1_table2(,%ecx,8),%ebx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p23=int32#2
# asm 2: movzbl <y2=%dh,>p23=%ecx
movzbl %dh,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p23=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table3(,<p23=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table3(,%ecx,8),%esi

# qhasm: p30 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p30=int32#2
# asm 2: movzbl <y3=%al,>p30=%ecx
movzbl %al,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p30=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table0(,<p30=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table0(,%ecx,8),%esi

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p31=int32#2
# asm 2: movzbl <y3=%ah,>p31=%ecx
movzbl %ah,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p31=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table1(,<p31=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table1(,%ecx,8),%edi

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int32#1
# asm 2: shr  $16,<y3=%eax
shr  $16,%eax

# qhasm: p32 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p32=int32#2
# asm 2: movzbl <y3=%al,>p32=%ecx
movzbl %al,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p32=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table2(,<p32=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table2(,%ecx,8),%ebp

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p33=int32#1
# asm 2: movzbl <y3=%ah,>p33=%eax
movzbl %ah,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p33=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table3(,<p33=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table3(,%eax,8),%ebx

# qhasm: y0 = r32
# asm 1: movl <r32=stack32#38,>y0=int32#1
# asm 2: movl <r32=148(%esp),>y0=%eax
movl 148(%esp),%eax

# qhasm: y0 ^= z0
# asm 1: xorl <z0=int32#4,<y0=int32#1
# asm 2: xorl <z0=%ebx,<y0=%eax
xorl %ebx,%eax

# qhasm: y1 = r33
# asm 1: movl <r33=stack32#39,>y1=int32#2
# asm 2: movl <r33=152(%esp),>y1=%ecx
movl 152(%esp),%ecx

# qhasm: y1 ^= z1
# asm 1: xorl <z1=int32#7,<y1=int32#2
# asm 2: xorl <z1=%ebp,<y1=%ecx
xorl %ebp,%ecx

# qhasm: y2 = r34
# asm 1: movl <r34=stack32#40,>y2=int32#3
# asm 2: movl <r34=156(%esp),>y2=%edx
movl 156(%esp),%edx

# qhasm: y2 ^= z2
# asm 1: xorl <z2=int32#6,<y2=int32#3
# asm 2: xorl <z2=%edi,<y2=%edx
xorl %edi,%edx

# qhasm: y3 = r35
# asm 1: movl <r35=stack32#41,>y3=int32#4
# asm 2: movl <r35=160(%esp),>y3=%ebx
movl 160(%esp),%ebx

# qhasm: y3 ^= z3
# asm 1: xorl <z3=int32#5,<y3=int32#4
# asm 2: xorl <z3=%esi,<y3=%ebx
xorl %esi,%ebx

# qhasm: y3_stack = y3
# asm 1: movd <y3=int32#4,>y3_stack=int3232#2
# asm 2: movd <y3=%ebx,>y3_stack=%mm1
movd %ebx,%mm1

# qhasm: p00 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p00=int32#4
# asm 2: movzbl <y0=%al,>p00=%ebx
movzbl %al,%ebx

# qhasm: z0 = *(uint32 *) (&aes128_x86mmx1_table0 + p00 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<p00=int32#4,8),>z0=int32#4
# asm 2: movl aes128_x86mmx1_table0(,<p00=%ebx,8),>z0=%ebx
movl aes128_x86mmx1_table0(,%ebx,8),%ebx

# qhasm: p03 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p03=int32#5
# asm 2: movzbl <y0=%ah,>p03=%esi
movzbl %ah,%esi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int32#1
# asm 2: shr  $16,<y0=%eax
shr  $16,%eax

# qhasm: z3 = *(uint32 *) (&aes128_x86mmx1_table1 + p03 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<p03=int32#5,8),>z3=int32#5
# asm 2: movl aes128_x86mmx1_table1(,<p03=%esi,8),>z3=%esi
movl aes128_x86mmx1_table1(,%esi,8),%esi

# qhasm: p02 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>p02=int32#6
# asm 2: movzbl <y0=%al,>p02=%edi
movzbl %al,%edi

# qhasm: z2 = *(uint32 *) (&aes128_x86mmx1_table2 + p02 * 8)
# asm 1: movl aes128_x86mmx1_table2(,<p02=int32#6,8),>z2=int32#6
# asm 2: movl aes128_x86mmx1_table2(,<p02=%edi,8),>z2=%edi
movl aes128_x86mmx1_table2(,%edi,8),%edi

# qhasm: p01 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>p01=int32#1
# asm 2: movzbl <y0=%ah,>p01=%eax
movzbl %ah,%eax

# qhasm: z1 = *(uint32 *) (&aes128_x86mmx1_table3 + p01 * 8)
# asm 1: movl aes128_x86mmx1_table3(,<p01=int32#1,8),>z1=int32#7
# asm 2: movl aes128_x86mmx1_table3(,<p01=%eax,8),>z1=%ebp
movl aes128_x86mmx1_table3(,%eax,8),%ebp

# qhasm: p10 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p10=int32#1
# asm 2: movzbl <y1=%cl,>p10=%eax
movzbl %cl,%eax

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p10 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p10=int32#1,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table0(,<p10=%eax,8),<z1=%ebp
xorl aes128_x86mmx1_table0(,%eax,8),%ebp

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p11=int32#1
# asm 2: movzbl <y1=%ch,>p11=%eax
movzbl %ch,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p11 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p11=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table1(,<p11=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table1(,%eax,8),%ebx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int32#2
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p12=int32#1
# asm 2: movzbl <y1=%cl,>p12=%eax
movzbl %cl,%eax

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p12 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p12=int32#1,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table2(,<p12=%eax,8),<z3=%esi
xorl aes128_x86mmx1_table2(,%eax,8),%esi

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p13=int32#1
# asm 2: movzbl <y1=%ch,>p13=%eax
movzbl %ch,%eax

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p13 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p13=int32#1,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table3(,<p13=%eax,8),<z2=%edi
xorl aes128_x86mmx1_table3(,%eax,8),%edi

# qhasm: y3 = y3_stack
# asm 1: movd <y3_stack=int3232#2,>y3=int32#1
# asm 2: movd <y3_stack=%mm1,>y3=%eax
movd %mm1,%eax

# qhasm: p20 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p20=int32#2
# asm 2: movzbl <y2=%dl,>p20=%ecx
movzbl %dl,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p20 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p20=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table0(,<p20=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table0(,%ecx,8),%edi

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p21=int32#2
# asm 2: movzbl <y2=%dh,>p21=%ecx
movzbl %dh,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p21 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p21=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table1(,<p21=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table1(,%ecx,8),%ebp

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int32#3
# asm 2: shr  $16,<y2=%edx
shr  $16,%edx

# qhasm: p22 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p22=int32#2
# asm 2: movzbl <y2=%dl,>p22=%ecx
movzbl %dl,%ecx

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p22 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p22=int32#2,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table2(,<p22=%ecx,8),<z0=%ebx
xorl aes128_x86mmx1_table2(,%ecx,8),%ebx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p23=int32#2
# asm 2: movzbl <y2=%dh,>p23=%ecx
movzbl %dh,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p23 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p23=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table3(,<p23=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table3(,%ecx,8),%esi

# qhasm: p30 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p30=int32#2
# asm 2: movzbl <y3=%al,>p30=%ecx
movzbl %al,%ecx

# qhasm: z3 ^= *(uint32 *) (&aes128_x86mmx1_table0 + p30 * 8)
# asm 1: xorl aes128_x86mmx1_table0(,<p30=int32#2,8),<z3=int32#5
# asm 2: xorl aes128_x86mmx1_table0(,<p30=%ecx,8),<z3=%esi
xorl aes128_x86mmx1_table0(,%ecx,8),%esi

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p31=int32#2
# asm 2: movzbl <y3=%ah,>p31=%ecx
movzbl %ah,%ecx

# qhasm: z2 ^= *(uint32 *) (&aes128_x86mmx1_table1 + p31 * 8)
# asm 1: xorl aes128_x86mmx1_table1(,<p31=int32#2,8),<z2=int32#6
# asm 2: xorl aes128_x86mmx1_table1(,<p31=%ecx,8),<z2=%edi
xorl aes128_x86mmx1_table1(,%ecx,8),%edi

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int32#1
# asm 2: shr  $16,<y3=%eax
shr  $16,%eax

# qhasm: p32 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p32=int32#2
# asm 2: movzbl <y3=%al,>p32=%ecx
movzbl %al,%ecx

# qhasm: z1 ^= *(uint32 *) (&aes128_x86mmx1_table2 + p32 * 8)
# asm 1: xorl aes128_x86mmx1_table2(,<p32=int32#2,8),<z1=int32#7
# asm 2: xorl aes128_x86mmx1_table2(,<p32=%ecx,8),<z1=%ebp
xorl aes128_x86mmx1_table2(,%ecx,8),%ebp

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p33=int32#1
# asm 2: movzbl <y3=%ah,>p33=%eax
movzbl %ah,%eax

# qhasm: z0 ^= *(uint32 *) (&aes128_x86mmx1_table3 + p33 * 8)
# asm 1: xorl aes128_x86mmx1_table3(,<p33=int32#1,8),<z0=int32#4
# asm 2: xorl aes128_x86mmx1_table3(,<p33=%eax,8),<z0=%ebx
xorl aes128_x86mmx1_table3(,%eax,8),%ebx

# qhasm: y0 = r36
# asm 1: movl <r36=stack32#42,>y0=int32#1
# asm 2: movl <r36=164(%esp),>y0=%eax
movl 164(%esp),%eax

# qhasm: y0 ^= z0
# asm 1: xorl <z0=int32#4,<y0=int32#1
# asm 2: xorl <z0=%ebx,<y0=%eax
xorl %ebx,%eax

# qhasm: y1 = r37
# asm 1: movl <r37=stack32#43,>y1=int32#2
# asm 2: movl <r37=168(%esp),>y1=%ecx
movl 168(%esp),%ecx

# qhasm: y1 ^= z1
# asm 1: xorl <z1=int32#7,<y1=int32#2
# asm 2: xorl <z1=%ebp,<y1=%ecx
xorl %ebp,%ecx

# qhasm: y2 = r38
# asm 1: movl <r38=stack32#44,>y2=int32#3
# asm 2: movl <r38=172(%esp),>y2=%edx
movl 172(%esp),%edx

# qhasm: y2 ^= z2
# asm 1: xorl <z2=int32#6,<y2=int32#3
# asm 2: xorl <z2=%edi,<y2=%edx
xorl %edi,%edx

# qhasm: y3 = r39
# asm 1: movl <r39=stack32#45,>y3=int32#4
# asm 2: movl <r39=176(%esp),>y3=%ebx
movl 176(%esp),%ebx

# qhasm: y3 ^= z3
# asm 1: xorl <z3=int32#5,<y3=int32#4
# asm 2: xorl <z3=%esi,<y3=%ebx
xorl %esi,%ebx

# qhasm: y3_stack = y3
# asm 1: movd <y3=int32#4,>y3_stack=int3232#2
# asm 2: movd <y3=%ebx,>y3_stack=%mm1
movd %ebx,%mm1

# qhasm: z0 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>z0=int32#4
# asm 2: movzbl <y0=%al,>z0=%ebx
movzbl %al,%ebx

# qhasm: z0 = *(uint8 *) (&aes128_x86mmx1_table2 + z0 * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<z0=int32#4,8),>z0=int32#4
# asm 2: movzbl aes128_x86mmx1_table2(,<z0=%ebx,8),>z0=%ebx
movzbl aes128_x86mmx1_table2(,%ebx,8),%ebx

# qhasm: z3 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>z3=int32#5
# asm 2: movzbl <y0=%ah,>z3=%esi
movzbl %ah,%esi

# qhasm: z3 = *(uint16 *) (&aes128_x86mmx1_tablex + z3 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<z3=int32#5,8),>z3=int32#5
# asm 2: movzwl aes128_x86mmx1_tablex(,<z3=%esi,8),>z3=%esi
movzwl aes128_x86mmx1_tablex(,%esi,8),%esi

# qhasm: (uint32) y0 >>= 16
# asm 1: shr  $16,<y0=int32#1
# asm 2: shr  $16,<y0=%eax
shr  $16,%eax

# qhasm: z2 = y0 & 255
# asm 1: movzbl <y0=int32#1%8,>z2=int32#6
# asm 2: movzbl <y0=%al,>z2=%edi
movzbl %al,%edi

# qhasm: z2 = *(uint32 *) (&aes128_x86mmx1_table0 + z2 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<z2=int32#6,8),>z2=int32#6
# asm 2: movl aes128_x86mmx1_table0(,<z2=%edi,8),>z2=%edi
movl aes128_x86mmx1_table0(,%edi,8),%edi

# qhasm: z2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<z2=int32#6
# asm 2: and  $0x00ff0000,<z2=%edi
and  $0x00ff0000,%edi

# qhasm: z1 = (y0 >> 8) & 255
# asm 1: movzbl <y0=int32#1%next8,>z1=int32#1
# asm 2: movzbl <y0=%ah,>z1=%eax
movzbl %ah,%eax

# qhasm: z1 = *(uint32 *) (&aes128_x86mmx1_table1 + z1 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<z1=int32#1,8),>z1=int32#7
# asm 2: movl aes128_x86mmx1_table1(,<z1=%eax,8),>z1=%ebp
movl aes128_x86mmx1_table1(,%eax,8),%ebp

# qhasm: z1 &= 0xff000000
# asm 1: and  $0xff000000,<z1=int32#7
# asm 2: and  $0xff000000,<z1=%ebp
and  $0xff000000,%ebp

# qhasm: z0 ^= r40
# asm 1: xorl <r40=stack32#46,<z0=int32#4
# asm 2: xorl <r40=180(%esp),<z0=%ebx
xorl 180(%esp),%ebx

# qhasm: z3 ^= r43
# asm 1: xorl <r43=stack32#49,<z3=int32#5
# asm 2: xorl <r43=192(%esp),<z3=%esi
xorl 192(%esp),%esi

# qhasm: z1 ^= r41
# asm 1: xorl <r41=stack32#47,<z1=int32#7
# asm 2: xorl <r41=184(%esp),<z1=%ebp
xorl 184(%esp),%ebp

# qhasm: z2 ^= r42
# asm 1: xorl <r42=stack32#48,<z2=int32#6
# asm 2: xorl <r42=188(%esp),<z2=%edi
xorl 188(%esp),%edi

# qhasm: p10 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p10=int32#1
# asm 2: movzbl <y1=%cl,>p10=%eax
movzbl %cl,%eax

# qhasm: p10 = *(uint8 *) (&aes128_x86mmx1_table2 + p10 * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<p10=int32#1,8),>p10=int32#1
# asm 2: movzbl aes128_x86mmx1_table2(,<p10=%eax,8),>p10=%eax
movzbl aes128_x86mmx1_table2(,%eax,8),%eax

# qhasm: z1 ^= p10
# asm 1: xorl <p10=int32#1,<z1=int32#7
# asm 2: xorl <p10=%eax,<z1=%ebp
xorl %eax,%ebp

# qhasm: p11 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p11=int32#1
# asm 2: movzbl <y1=%ch,>p11=%eax
movzbl %ch,%eax

# qhasm: p11 = *(uint16 *) (&aes128_x86mmx1_tablex + p11 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<p11=int32#1,8),>p11=int32#1
# asm 2: movzwl aes128_x86mmx1_tablex(,<p11=%eax,8),>p11=%eax
movzwl aes128_x86mmx1_tablex(,%eax,8),%eax

# qhasm: z0 ^= p11
# asm 1: xorl <p11=int32#1,<z0=int32#4
# asm 2: xorl <p11=%eax,<z0=%ebx
xorl %eax,%ebx

# qhasm: (uint32) y1 >>= 16
# asm 1: shr  $16,<y1=int32#2
# asm 2: shr  $16,<y1=%ecx
shr  $16,%ecx

# qhasm: p12 = y1 & 255
# asm 1: movzbl <y1=int32#2%8,>p12=int32#1
# asm 2: movzbl <y1=%cl,>p12=%eax
movzbl %cl,%eax

# qhasm: p12 = *(uint32 *) (&aes128_x86mmx1_table0 + p12 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<p12=int32#1,8),>p12=int32#1
# asm 2: movl aes128_x86mmx1_table0(,<p12=%eax,8),>p12=%eax
movl aes128_x86mmx1_table0(,%eax,8),%eax

# qhasm: p12 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<p12=int32#1
# asm 2: and  $0x00ff0000,<p12=%eax
and  $0x00ff0000,%eax

# qhasm: z3 ^= p12
# asm 1: xorl <p12=int32#1,<z3=int32#5
# asm 2: xorl <p12=%eax,<z3=%esi
xorl %eax,%esi

# qhasm: p13 = (y1 >> 8) & 255
# asm 1: movzbl <y1=int32#2%next8,>p13=int32#1
# asm 2: movzbl <y1=%ch,>p13=%eax
movzbl %ch,%eax

# qhasm: p13 = *(uint32 *) (&aes128_x86mmx1_table1 + p13 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<p13=int32#1,8),>p13=int32#1
# asm 2: movl aes128_x86mmx1_table1(,<p13=%eax,8),>p13=%eax
movl aes128_x86mmx1_table1(,%eax,8),%eax

# qhasm: p13 &= 0xff000000
# asm 1: and  $0xff000000,<p13=int32#1
# asm 2: and  $0xff000000,<p13=%eax
and  $0xff000000,%eax

# qhasm: z2 ^= p13
# asm 1: xorl <p13=int32#1,<z2=int32#6
# asm 2: xorl <p13=%eax,<z2=%edi
xorl %eax,%edi

# qhasm: y3 = y3_stack
# asm 1: movd <y3_stack=int3232#2,>y3=int32#1
# asm 2: movd <y3_stack=%mm1,>y3=%eax
movd %mm1,%eax

# qhasm: p20 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p20=int32#2
# asm 2: movzbl <y2=%dl,>p20=%ecx
movzbl %dl,%ecx

# qhasm: p20 = *(uint8 *) (&aes128_x86mmx1_table2 + p20 * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<p20=int32#2,8),>p20=int32#2
# asm 2: movzbl aes128_x86mmx1_table2(,<p20=%ecx,8),>p20=%ecx
movzbl aes128_x86mmx1_table2(,%ecx,8),%ecx

# qhasm: z2 ^= p20
# asm 1: xorl <p20=int32#2,<z2=int32#6
# asm 2: xorl <p20=%ecx,<z2=%edi
xorl %ecx,%edi

# qhasm: p21 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p21=int32#2
# asm 2: movzbl <y2=%dh,>p21=%ecx
movzbl %dh,%ecx

# qhasm: p21 = *(uint16 *) (&aes128_x86mmx1_tablex + p21 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<p21=int32#2,8),>p21=int32#2
# asm 2: movzwl aes128_x86mmx1_tablex(,<p21=%ecx,8),>p21=%ecx
movzwl aes128_x86mmx1_tablex(,%ecx,8),%ecx

# qhasm: z1 ^= p21
# asm 1: xorl <p21=int32#2,<z1=int32#7
# asm 2: xorl <p21=%ecx,<z1=%ebp
xorl %ecx,%ebp

# qhasm: (uint32) y2 >>= 16
# asm 1: shr  $16,<y2=int32#3
# asm 2: shr  $16,<y2=%edx
shr  $16,%edx

# qhasm: p22 = y2 & 255
# asm 1: movzbl <y2=int32#3%8,>p22=int32#2
# asm 2: movzbl <y2=%dl,>p22=%ecx
movzbl %dl,%ecx

# qhasm: p22 = *(uint32 *) (&aes128_x86mmx1_table0 + p22 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<p22=int32#2,8),>p22=int32#2
# asm 2: movl aes128_x86mmx1_table0(,<p22=%ecx,8),>p22=%ecx
movl aes128_x86mmx1_table0(,%ecx,8),%ecx

# qhasm: p22 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<p22=int32#2
# asm 2: and  $0x00ff0000,<p22=%ecx
and  $0x00ff0000,%ecx

# qhasm: z0 ^= p22
# asm 1: xorl <p22=int32#2,<z0=int32#4
# asm 2: xorl <p22=%ecx,<z0=%ebx
xorl %ecx,%ebx

# qhasm: p23 = (y2 >> 8) & 255
# asm 1: movzbl <y2=int32#3%next8,>p23=int32#2
# asm 2: movzbl <y2=%dh,>p23=%ecx
movzbl %dh,%ecx

# qhasm: p23 = *(uint32 *) (&aes128_x86mmx1_table1 + p23 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<p23=int32#2,8),>p23=int32#2
# asm 2: movl aes128_x86mmx1_table1(,<p23=%ecx,8),>p23=%ecx
movl aes128_x86mmx1_table1(,%ecx,8),%ecx

# qhasm: p23 &= 0xff000000
# asm 1: and  $0xff000000,<p23=int32#2
# asm 2: and  $0xff000000,<p23=%ecx
and  $0xff000000,%ecx

# qhasm: z3 ^= p23
# asm 1: xorl <p23=int32#2,<z3=int32#5
# asm 2: xorl <p23=%ecx,<z3=%esi
xorl %ecx,%esi

# qhasm: p30 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p30=int32#2
# asm 2: movzbl <y3=%al,>p30=%ecx
movzbl %al,%ecx

# qhasm: p30 = *(uint8 *) (&aes128_x86mmx1_table2 + p30 * 8)
# asm 1: movzbl aes128_x86mmx1_table2(,<p30=int32#2,8),>p30=int32#2
# asm 2: movzbl aes128_x86mmx1_table2(,<p30=%ecx,8),>p30=%ecx
movzbl aes128_x86mmx1_table2(,%ecx,8),%ecx

# qhasm: z3 ^= p30
# asm 1: xorl <p30=int32#2,<z3=int32#5
# asm 2: xorl <p30=%ecx,<z3=%esi
xorl %ecx,%esi

# qhasm: p31 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p31=int32#2
# asm 2: movzbl <y3=%ah,>p31=%ecx
movzbl %ah,%ecx

# qhasm: p31 = *(uint16 *) (&aes128_x86mmx1_tablex + p31 * 8)
# asm 1: movzwl aes128_x86mmx1_tablex(,<p31=int32#2,8),>p31=int32#2
# asm 2: movzwl aes128_x86mmx1_tablex(,<p31=%ecx,8),>p31=%ecx
movzwl aes128_x86mmx1_tablex(,%ecx,8),%ecx

# qhasm: z2 ^= p31
# asm 1: xorl <p31=int32#2,<z2=int32#6
# asm 2: xorl <p31=%ecx,<z2=%edi
xorl %ecx,%edi

# qhasm: (uint32) y3 >>= 16
# asm 1: shr  $16,<y3=int32#1
# asm 2: shr  $16,<y3=%eax
shr  $16,%eax

# qhasm: p32 = y3 & 255
# asm 1: movzbl <y3=int32#1%8,>p32=int32#2
# asm 2: movzbl <y3=%al,>p32=%ecx
movzbl %al,%ecx

# qhasm: p32 = *(uint32 *) (&aes128_x86mmx1_table0 + p32 * 8)
# asm 1: movl aes128_x86mmx1_table0(,<p32=int32#2,8),>p32=int32#2
# asm 2: movl aes128_x86mmx1_table0(,<p32=%ecx,8),>p32=%ecx
movl aes128_x86mmx1_table0(,%ecx,8),%ecx

# qhasm: p32 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<p32=int32#2
# asm 2: and  $0x00ff0000,<p32=%ecx
and  $0x00ff0000,%ecx

# qhasm: z1 ^= p32
# asm 1: xorl <p32=int32#2,<z1=int32#7
# asm 2: xorl <p32=%ecx,<z1=%ebp
xorl %ecx,%ebp

# qhasm: p33 = (y3 >> 8) & 255
# asm 1: movzbl <y3=int32#1%next8,>p33=int32#1
# asm 2: movzbl <y3=%ah,>p33=%eax
movzbl %ah,%eax

# qhasm: p33 = *(uint32 *) (&aes128_x86mmx1_table1 + p33 * 8)
# asm 1: movl aes128_x86mmx1_table1(,<p33=int32#1,8),>p33=int32#1
# asm 2: movl aes128_x86mmx1_table1(,<p33=%eax,8),>p33=%eax
movl aes128_x86mmx1_table1(,%eax,8),%eax

# qhasm: p33 &= 0xff000000
# asm 1: and  $0xff000000,<p33=int32#1
# asm 2: and  $0xff000000,<p33=%eax
and  $0xff000000,%eax

# qhasm: z0 ^= p33
# asm 1: xorl <p33=int32#1,<z0=int32#4
# asm 2: xorl <p33=%eax,<z0=%ebx
xorl %eax,%ebx

# qhasm: out = out_stack
# asm 1: movd <out_stack=int3232#1,>out=int32#1
# asm 2: movd <out_stack=%mm0,>out=%eax
movd %mm0,%eax

# qhasm: *(uint32 *) (out + 0) = z0
# asm 1: movl <z0=int32#4,0(<out=int32#1)
# asm 2: movl <z0=%ebx,0(<out=%eax)
movl %ebx,0(%eax)

# qhasm: *(uint32 *) (out + 4) = z1
# asm 1: movl <z1=int32#7,4(<out=int32#1)
# asm 2: movl <z1=%ebp,4(<out=%eax)
movl %ebp,4(%eax)

# qhasm: *(uint32 *) (out + 8) = z2
# asm 1: movl <z2=int32#6,8(<out=int32#1)
# asm 2: movl <z2=%edi,8(<out=%eax)
movl %edi,8(%eax)

# qhasm: *(uint32 *) (out + 12) = z3
# asm 1: movl <z3=int32#5,12(<out=int32#1)
# asm 2: movl <z3=%esi,12(<out=%eax)
movl %esi,12(%eax)

# qhasm: emms
emms

# qhasm: eax = eax_stack
# asm 1: movl <eax_stack=stack32#1,>eax=int32#1
# asm 2: movl <eax_stack=0(%esp),>eax=%eax
movl 0(%esp),%eax

# qhasm: ebx = ebx_stack
# asm 1: movl <ebx_stack=stack32#2,>ebx=int32#4
# asm 2: movl <ebx_stack=4(%esp),>ebx=%ebx
movl 4(%esp),%ebx

# qhasm: esi = esi_stack
# asm 1: movl <esi_stack=stack32#3,>esi=int32#5
# asm 2: movl <esi_stack=8(%esp),>esi=%esi
movl 8(%esp),%esi

# qhasm: edi = edi_stack
# asm 1: movl <edi_stack=stack32#4,>edi=int32#6
# asm 2: movl <edi_stack=12(%esp),>edi=%edi
movl 12(%esp),%edi

# qhasm: ebp = ebp_stack
# asm 1: movl <ebp_stack=stack32#5,>ebp=int32#7
# asm 2: movl <ebp_stack=16(%esp),>ebp=%ebp
movl 16(%esp),%ebp

# qhasm: leave
add %eax,%esp
ret
