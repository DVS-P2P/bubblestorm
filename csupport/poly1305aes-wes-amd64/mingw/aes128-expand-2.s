
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

# qhasm: int64 q0

# qhasm: int64 q1

# qhasm: int64 q2

# qhasm: int64 q3

# qhasm: int64 in

# qhasm: int64 out

# qhasm: int64 len

# qhasm: stack64 in_stack

# qhasm: enter aes128_amd64_2_expand
.text
.p2align 5
.globl _aes128_amd64_2_expand
.globl aes128_amd64_2_expand
_aes128_amd64_2_expand:
aes128_amd64_2_expand:
mov %rsp,%r11
and $31,%r11
add $96,%r11
sub %r11,%rsp

# qhasm: input c

# qhasm: input k

# qhasm: r11_stack = r11_caller
# asm 1: movq <r11_caller=int64#7,>r11_stack=stack64#1
# asm 2: movq <r11_caller=%r11,>r11_stack=0(%rsp)
movq %r11,0(%rsp)

# qhasm: r12_stack = r12_caller
# asm 1: movq <r12_caller=int64#8,>r12_stack=stack64#2
# asm 2: movq <r12_caller=%r12,>r12_stack=8(%rsp)
movq %r12,8(%rsp)

# qhasm: r13_stack = r13_caller
# asm 1: movq <r13_caller=int64#9,>r13_stack=stack64#3
# asm 2: movq <r13_caller=%r13,>r13_stack=16(%rsp)
movq %r13,16(%rsp)

# qhasm: r14_stack = r14_caller
# asm 1: movq <r14_caller=int64#10,>r14_stack=stack64#4
# asm 2: movq <r14_caller=%r14,>r14_stack=24(%rsp)
movq %r14,24(%rsp)

# qhasm: r15_stack = r15_caller
# asm 1: movq <r15_caller=int64#11,>r15_stack=stack64#5
# asm 2: movq <r15_caller=%r15,>r15_stack=32(%rsp)
movq %r15,32(%rsp)

# qhasm: rdi_stack = rdi_caller
# asm 1: movq <rdi_caller=int64#12,>rdi_stack=stack64#6
# asm 2: movq <rdi_caller=%rdi,>rdi_stack=40(%rsp)
movq %rdi,40(%rsp)

# qhasm: rsi_stack = rsi_caller
# asm 1: movq <rsi_caller=int64#13,>rsi_stack=stack64#7
# asm 2: movq <rsi_caller=%rsi,>rsi_stack=48(%rsp)
movq %rsi,48(%rsp)

# qhasm: rbp_stack = rbp_caller
# asm 1: movq <rbp_caller=int64#14,>rbp_stack=stack64#8
# asm 2: movq <rbp_caller=%rbp,>rbp_stack=56(%rsp)
movq %rbp,56(%rsp)

# qhasm: rbx_stack = rbx_caller
# asm 1: movq <rbx_caller=int64#15,>rbx_stack=stack64#9
# asm 2: movq <rbx_caller=%rbx,>rbx_stack=64(%rsp)
movq %rbx,64(%rsp)

# qhasm: x0 = *(uint32 *) (k + 0)
# asm 1: movl   0(<k=int64#2),>x0=int64#3d
# asm 2: movl   0(<k=%rdx),>x0=%r8d
movl   0(%rdx),%r8d

# qhasm: x1 = *(uint32 *) (k + 4)
# asm 1: movl   4(<k=int64#2),>x1=int64#4d
# asm 2: movl   4(<k=%rdx),>x1=%r9d
movl   4(%rdx),%r9d

# qhasm: x2 = *(uint32 *) (k + 8)
# asm 1: movl   8(<k=int64#2),>x2=int64#5d
# asm 2: movl   8(<k=%rdx),>x2=%eax
movl   8(%rdx),%eax

# qhasm: x3 = *(uint32 *) (k + 12)
# asm 1: movl   12(<k=int64#2),>x3=int64#15d
# asm 2: movl   12(<k=%rdx),>x3=%ebx
movl   12(%rdx),%ebx

# qhasm: *(uint32 *) (c + 0) = x0
# asm 1: movl   <x0=int64#3d,0(<c=int64#1)
# asm 2: movl   <x0=%r8d,0(<c=%rcx)
movl   %r8d,0(%rcx)

# qhasm: *(uint32 *) (c + 4) = x1
# asm 1: movl   <x1=int64#4d,4(<c=int64#1)
# asm 2: movl   <x1=%r9d,4(<c=%rcx)
movl   %r9d,4(%rcx)

# qhasm: *(uint32 *) (c + 8) = x2
# asm 1: movl   <x2=int64#5d,8(<c=int64#1)
# asm 2: movl   <x2=%eax,8(<c=%rcx)
movl   %eax,8(%rcx)

# qhasm: *(uint32 *) (c + 12) = x3
# asm 1: movl   <x3=int64#15d,12(<c=int64#1)
# asm 2: movl   <x3=%ebx,12(<c=%rcx)
movl   %ebx,12(%rcx)

# qhasm: table = &aes128_amd64_2_tablex
# asm 1: lea  aes128_amd64_2_tablex(%rip),>table=int64#2
# asm 2: lea  aes128_amd64_2_tablex(%rip),>table=%rdx
lea  aes128_amd64_2_tablex(%rip),%rdx

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>e=int64#12d
# asm 2: movzbl  <x3=%bh,>e=%edi
movzbl  %bh,%edi

# qhasm: e = *(uint8 *) (table + 1 + e * 8)
# asm 1: movzbq 1(<table=int64#2,<e=int64#12,8),>e=int64#6
# asm 2: movzbq 1(<table=%rdx,<e=%rdi,8),>e=%r10
movzbq 1(%rdx,%rdi,8),%r10

# qhasm: (uint32) e ^= 0x01
# asm 1: xor  $0x01,<e=int64#6d
# asm 2: xor  $0x01,<e=%r10d
xor  $0x01,%r10d

# qhasm: q3 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q3=int64#7d
# asm 2: movzbl  <x3=%bl,>q3=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q3 = *(uint32 *) (table + 2 + q3 * 8)
# asm 1: movl   2(<table=int64#2,<q3=int64#7,8),>q3=int64#7d
# asm 2: movl   2(<table=%rdx,<q3=%r11,8),>q3=%r11d
movl   2(%rdx,%r11,8),%r11d

# qhasm: (uint32) q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int64#7d
# asm 2: and  $0xff000000,<q3=%r11d
and  $0xff000000,%r11d

# qhasm: e ^= q3
# asm 1: xor  <q3=int64#7,<e=int64#6
# asm 2: xor  <q3=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>q2=int64#12d
# asm 2: movzbl  <x3=%bh,>q2=%edi
movzbl  %bh,%edi

# qhasm: q2 = *(uint32 *) (table + 3 + q2 * 8)
# asm 1: movl   3(<table=int64#2,<q2=int64#12,8),>q2=int64#7d
# asm 2: movl   3(<table=%rdx,<q2=%rdi,8),>q2=%r11d
movl   3(%rdx,%rdi,8),%r11d

# qhasm: (uint32) q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int64#7d
# asm 2: and  $0x00ff0000,<q2=%r11d
and  $0x00ff0000,%r11d

# qhasm: e ^= q2
# asm 1: xor  <q2=int64#7,<e=int64#6
# asm 2: xor  <q2=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q1 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q1=int64#7d
# asm 2: movzbl  <x3=%bl,>q1=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q1 = *(uint16 *) (table + q1 * 8)
# asm 1: movzwq (<table=int64#2,<q1=int64#7,8),>q1=int64#7
# asm 2: movzwq (<table=%rdx,<q1=%r11,8),>q1=%r11
movzwq (%rdx,%r11,8),%r11

# qhasm: e ^= q1
# asm 1: xor  <q1=int64#7,<e=int64#6
# asm 2: xor  <q1=%r11,<e=%r10
xor  %r11,%r10

# qhasm: x0 ^= e
# asm 1: xor  <e=int64#6,<x0=int64#3
# asm 2: xor  <e=%r10,<x0=%r8
xor  %r10,%r8

# qhasm: *(uint32 *) (c + 16) = x0
# asm 1: movl   <x0=int64#3d,16(<c=int64#1)
# asm 2: movl   <x0=%r8d,16(<c=%rcx)
movl   %r8d,16(%rcx)

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#3,<x1=int64#4
# asm 2: xor  <x0=%r8,<x1=%r9
xor  %r8,%r9

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#4,<x2=int64#5
# asm 2: xor  <x1=%r9,<x2=%rax
xor  %r9,%rax

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#5,<x3=int64#15
# asm 2: xor  <x2=%rax,<x3=%rbx
xor  %rax,%rbx

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>e=int64#12d
# asm 2: movzbl  <x3=%bh,>e=%edi
movzbl  %bh,%edi

# qhasm: e = *(uint8 *) (table + 1 + e * 8)
# asm 1: movzbq 1(<table=int64#2,<e=int64#12,8),>e=int64#6
# asm 2: movzbq 1(<table=%rdx,<e=%rdi,8),>e=%r10
movzbq 1(%rdx,%rdi,8),%r10

# qhasm: (uint32) e ^= 0x02
# asm 1: xor  $0x02,<e=int64#6d
# asm 2: xor  $0x02,<e=%r10d
xor  $0x02,%r10d

# qhasm: q3 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q3=int64#7d
# asm 2: movzbl  <x3=%bl,>q3=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q3 = *(uint32 *) (table + 2 + q3 * 8)
# asm 1: movl   2(<table=int64#2,<q3=int64#7,8),>q3=int64#7d
# asm 2: movl   2(<table=%rdx,<q3=%r11,8),>q3=%r11d
movl   2(%rdx,%r11,8),%r11d

# qhasm: (uint32) q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int64#7d
# asm 2: and  $0xff000000,<q3=%r11d
and  $0xff000000,%r11d

# qhasm: e ^= q3
# asm 1: xor  <q3=int64#7,<e=int64#6
# asm 2: xor  <q3=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>q2=int64#12d
# asm 2: movzbl  <x3=%bh,>q2=%edi
movzbl  %bh,%edi

# qhasm: q2 = *(uint32 *) (table + 3 + q2 * 8)
# asm 1: movl   3(<table=int64#2,<q2=int64#12,8),>q2=int64#7d
# asm 2: movl   3(<table=%rdx,<q2=%rdi,8),>q2=%r11d
movl   3(%rdx,%rdi,8),%r11d

# qhasm: (uint32) q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int64#7d
# asm 2: and  $0x00ff0000,<q2=%r11d
and  $0x00ff0000,%r11d

# qhasm: e ^= q2
# asm 1: xor  <q2=int64#7,<e=int64#6
# asm 2: xor  <q2=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q1 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q1=int64#7d
# asm 2: movzbl  <x3=%bl,>q1=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q1 = *(uint16 *) (table + q1 * 8)
# asm 1: movzwq (<table=int64#2,<q1=int64#7,8),>q1=int64#7
# asm 2: movzwq (<table=%rdx,<q1=%r11,8),>q1=%r11
movzwq (%rdx,%r11,8),%r11

# qhasm: e ^= q1
# asm 1: xor  <q1=int64#7,<e=int64#6
# asm 2: xor  <q1=%r11,<e=%r10
xor  %r11,%r10

# qhasm: x0 ^= e
# asm 1: xor  <e=int64#6,<x0=int64#3
# asm 2: xor  <e=%r10,<x0=%r8
xor  %r10,%r8

# qhasm: *(uint32 *) (c + 20) = x0
# asm 1: movl   <x0=int64#3d,20(<c=int64#1)
# asm 2: movl   <x0=%r8d,20(<c=%rcx)
movl   %r8d,20(%rcx)

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#3,<x1=int64#4
# asm 2: xor  <x0=%r8,<x1=%r9
xor  %r8,%r9

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#4,<x2=int64#5
# asm 2: xor  <x1=%r9,<x2=%rax
xor  %r9,%rax

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#5,<x3=int64#15
# asm 2: xor  <x2=%rax,<x3=%rbx
xor  %rax,%rbx

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>e=int64#12d
# asm 2: movzbl  <x3=%bh,>e=%edi
movzbl  %bh,%edi

# qhasm: e = *(uint8 *) (table + 1 + e * 8)
# asm 1: movzbq 1(<table=int64#2,<e=int64#12,8),>e=int64#6
# asm 2: movzbq 1(<table=%rdx,<e=%rdi,8),>e=%r10
movzbq 1(%rdx,%rdi,8),%r10

# qhasm: (uint32) e ^= 0x04
# asm 1: xor  $0x04,<e=int64#6d
# asm 2: xor  $0x04,<e=%r10d
xor  $0x04,%r10d

# qhasm: q3 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q3=int64#7d
# asm 2: movzbl  <x3=%bl,>q3=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q3 = *(uint32 *) (table + 2 + q3 * 8)
# asm 1: movl   2(<table=int64#2,<q3=int64#7,8),>q3=int64#7d
# asm 2: movl   2(<table=%rdx,<q3=%r11,8),>q3=%r11d
movl   2(%rdx,%r11,8),%r11d

# qhasm: (uint32) q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int64#7d
# asm 2: and  $0xff000000,<q3=%r11d
and  $0xff000000,%r11d

# qhasm: e ^= q3
# asm 1: xor  <q3=int64#7,<e=int64#6
# asm 2: xor  <q3=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>q2=int64#12d
# asm 2: movzbl  <x3=%bh,>q2=%edi
movzbl  %bh,%edi

# qhasm: q2 = *(uint32 *) (table + 3 + q2 * 8)
# asm 1: movl   3(<table=int64#2,<q2=int64#12,8),>q2=int64#7d
# asm 2: movl   3(<table=%rdx,<q2=%rdi,8),>q2=%r11d
movl   3(%rdx,%rdi,8),%r11d

# qhasm: (uint32) q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int64#7d
# asm 2: and  $0x00ff0000,<q2=%r11d
and  $0x00ff0000,%r11d

# qhasm: e ^= q2
# asm 1: xor  <q2=int64#7,<e=int64#6
# asm 2: xor  <q2=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q1 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q1=int64#7d
# asm 2: movzbl  <x3=%bl,>q1=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q1 = *(uint16 *) (table + q1 * 8)
# asm 1: movzwq (<table=int64#2,<q1=int64#7,8),>q1=int64#7
# asm 2: movzwq (<table=%rdx,<q1=%r11,8),>q1=%r11
movzwq (%rdx,%r11,8),%r11

# qhasm: e ^= q1
# asm 1: xor  <q1=int64#7,<e=int64#6
# asm 2: xor  <q1=%r11,<e=%r10
xor  %r11,%r10

# qhasm: x0 ^= e
# asm 1: xor  <e=int64#6,<x0=int64#3
# asm 2: xor  <e=%r10,<x0=%r8
xor  %r10,%r8

# qhasm: *(uint32 *) (c + 24) = x0
# asm 1: movl   <x0=int64#3d,24(<c=int64#1)
# asm 2: movl   <x0=%r8d,24(<c=%rcx)
movl   %r8d,24(%rcx)

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#3,<x1=int64#4
# asm 2: xor  <x0=%r8,<x1=%r9
xor  %r8,%r9

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#4,<x2=int64#5
# asm 2: xor  <x1=%r9,<x2=%rax
xor  %r9,%rax

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#5,<x3=int64#15
# asm 2: xor  <x2=%rax,<x3=%rbx
xor  %rax,%rbx

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>e=int64#12d
# asm 2: movzbl  <x3=%bh,>e=%edi
movzbl  %bh,%edi

# qhasm: e = *(uint8 *) (table + 1 + e * 8)
# asm 1: movzbq 1(<table=int64#2,<e=int64#12,8),>e=int64#6
# asm 2: movzbq 1(<table=%rdx,<e=%rdi,8),>e=%r10
movzbq 1(%rdx,%rdi,8),%r10

# qhasm: (uint32) e ^= 0x08
# asm 1: xor  $0x08,<e=int64#6d
# asm 2: xor  $0x08,<e=%r10d
xor  $0x08,%r10d

# qhasm: q3 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q3=int64#7d
# asm 2: movzbl  <x3=%bl,>q3=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q3 = *(uint32 *) (table + 2 + q3 * 8)
# asm 1: movl   2(<table=int64#2,<q3=int64#7,8),>q3=int64#7d
# asm 2: movl   2(<table=%rdx,<q3=%r11,8),>q3=%r11d
movl   2(%rdx,%r11,8),%r11d

# qhasm: (uint32) q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int64#7d
# asm 2: and  $0xff000000,<q3=%r11d
and  $0xff000000,%r11d

# qhasm: e ^= q3
# asm 1: xor  <q3=int64#7,<e=int64#6
# asm 2: xor  <q3=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>q2=int64#12d
# asm 2: movzbl  <x3=%bh,>q2=%edi
movzbl  %bh,%edi

# qhasm: q2 = *(uint32 *) (table + 3 + q2 * 8)
# asm 1: movl   3(<table=int64#2,<q2=int64#12,8),>q2=int64#7d
# asm 2: movl   3(<table=%rdx,<q2=%rdi,8),>q2=%r11d
movl   3(%rdx,%rdi,8),%r11d

# qhasm: (uint32) q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int64#7d
# asm 2: and  $0x00ff0000,<q2=%r11d
and  $0x00ff0000,%r11d

# qhasm: e ^= q2
# asm 1: xor  <q2=int64#7,<e=int64#6
# asm 2: xor  <q2=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q1 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q1=int64#7d
# asm 2: movzbl  <x3=%bl,>q1=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q1 = *(uint16 *) (table + q1 * 8)
# asm 1: movzwq (<table=int64#2,<q1=int64#7,8),>q1=int64#7
# asm 2: movzwq (<table=%rdx,<q1=%r11,8),>q1=%r11
movzwq (%rdx,%r11,8),%r11

# qhasm: e ^= q1
# asm 1: xor  <q1=int64#7,<e=int64#6
# asm 2: xor  <q1=%r11,<e=%r10
xor  %r11,%r10

# qhasm: x0 ^= e
# asm 1: xor  <e=int64#6,<x0=int64#3
# asm 2: xor  <e=%r10,<x0=%r8
xor  %r10,%r8

# qhasm: *(uint32 *) (c + 28) = x0
# asm 1: movl   <x0=int64#3d,28(<c=int64#1)
# asm 2: movl   <x0=%r8d,28(<c=%rcx)
movl   %r8d,28(%rcx)

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#3,<x1=int64#4
# asm 2: xor  <x0=%r8,<x1=%r9
xor  %r8,%r9

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#4,<x2=int64#5
# asm 2: xor  <x1=%r9,<x2=%rax
xor  %r9,%rax

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#5,<x3=int64#15
# asm 2: xor  <x2=%rax,<x3=%rbx
xor  %rax,%rbx

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>e=int64#12d
# asm 2: movzbl  <x3=%bh,>e=%edi
movzbl  %bh,%edi

# qhasm: e = *(uint8 *) (table + 1 + e * 8)
# asm 1: movzbq 1(<table=int64#2,<e=int64#12,8),>e=int64#6
# asm 2: movzbq 1(<table=%rdx,<e=%rdi,8),>e=%r10
movzbq 1(%rdx,%rdi,8),%r10

# qhasm: (uint32) e ^= 0x10
# asm 1: xor  $0x10,<e=int64#6d
# asm 2: xor  $0x10,<e=%r10d
xor  $0x10,%r10d

# qhasm: q3 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q3=int64#7d
# asm 2: movzbl  <x3=%bl,>q3=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q3 = *(uint32 *) (table + 2 + q3 * 8)
# asm 1: movl   2(<table=int64#2,<q3=int64#7,8),>q3=int64#7d
# asm 2: movl   2(<table=%rdx,<q3=%r11,8),>q3=%r11d
movl   2(%rdx,%r11,8),%r11d

# qhasm: (uint32) q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int64#7d
# asm 2: and  $0xff000000,<q3=%r11d
and  $0xff000000,%r11d

# qhasm: e ^= q3
# asm 1: xor  <q3=int64#7,<e=int64#6
# asm 2: xor  <q3=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>q2=int64#12d
# asm 2: movzbl  <x3=%bh,>q2=%edi
movzbl  %bh,%edi

# qhasm: q2 = *(uint32 *) (table + 3 + q2 * 8)
# asm 1: movl   3(<table=int64#2,<q2=int64#12,8),>q2=int64#7d
# asm 2: movl   3(<table=%rdx,<q2=%rdi,8),>q2=%r11d
movl   3(%rdx,%rdi,8),%r11d

# qhasm: (uint32) q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int64#7d
# asm 2: and  $0x00ff0000,<q2=%r11d
and  $0x00ff0000,%r11d

# qhasm: e ^= q2
# asm 1: xor  <q2=int64#7,<e=int64#6
# asm 2: xor  <q2=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q1 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q1=int64#7d
# asm 2: movzbl  <x3=%bl,>q1=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q1 = *(uint16 *) (table + q1 * 8)
# asm 1: movzwq (<table=int64#2,<q1=int64#7,8),>q1=int64#7
# asm 2: movzwq (<table=%rdx,<q1=%r11,8),>q1=%r11
movzwq (%rdx,%r11,8),%r11

# qhasm: e ^= q1
# asm 1: xor  <q1=int64#7,<e=int64#6
# asm 2: xor  <q1=%r11,<e=%r10
xor  %r11,%r10

# qhasm: x0 ^= e
# asm 1: xor  <e=int64#6,<x0=int64#3
# asm 2: xor  <e=%r10,<x0=%r8
xor  %r10,%r8

# qhasm: *(uint32 *) (c + 32) = x0
# asm 1: movl   <x0=int64#3d,32(<c=int64#1)
# asm 2: movl   <x0=%r8d,32(<c=%rcx)
movl   %r8d,32(%rcx)

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#3,<x1=int64#4
# asm 2: xor  <x0=%r8,<x1=%r9
xor  %r8,%r9

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#4,<x2=int64#5
# asm 2: xor  <x1=%r9,<x2=%rax
xor  %r9,%rax

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#5,<x3=int64#15
# asm 2: xor  <x2=%rax,<x3=%rbx
xor  %rax,%rbx

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>e=int64#12d
# asm 2: movzbl  <x3=%bh,>e=%edi
movzbl  %bh,%edi

# qhasm: e = *(uint8 *) (table + 1 + e * 8)
# asm 1: movzbq 1(<table=int64#2,<e=int64#12,8),>e=int64#6
# asm 2: movzbq 1(<table=%rdx,<e=%rdi,8),>e=%r10
movzbq 1(%rdx,%rdi,8),%r10

# qhasm: (uint32) e ^= 0x20
# asm 1: xor  $0x20,<e=int64#6d
# asm 2: xor  $0x20,<e=%r10d
xor  $0x20,%r10d

# qhasm: q3 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q3=int64#7d
# asm 2: movzbl  <x3=%bl,>q3=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q3 = *(uint32 *) (table + 2 + q3 * 8)
# asm 1: movl   2(<table=int64#2,<q3=int64#7,8),>q3=int64#7d
# asm 2: movl   2(<table=%rdx,<q3=%r11,8),>q3=%r11d
movl   2(%rdx,%r11,8),%r11d

# qhasm: (uint32) q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int64#7d
# asm 2: and  $0xff000000,<q3=%r11d
and  $0xff000000,%r11d

# qhasm: e ^= q3
# asm 1: xor  <q3=int64#7,<e=int64#6
# asm 2: xor  <q3=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>q2=int64#12d
# asm 2: movzbl  <x3=%bh,>q2=%edi
movzbl  %bh,%edi

# qhasm: q2 = *(uint32 *) (table + 3 + q2 * 8)
# asm 1: movl   3(<table=int64#2,<q2=int64#12,8),>q2=int64#7d
# asm 2: movl   3(<table=%rdx,<q2=%rdi,8),>q2=%r11d
movl   3(%rdx,%rdi,8),%r11d

# qhasm: (uint32) q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int64#7d
# asm 2: and  $0x00ff0000,<q2=%r11d
and  $0x00ff0000,%r11d

# qhasm: e ^= q2
# asm 1: xor  <q2=int64#7,<e=int64#6
# asm 2: xor  <q2=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q1 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q1=int64#7d
# asm 2: movzbl  <x3=%bl,>q1=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q1 = *(uint16 *) (table + q1 * 8)
# asm 1: movzwq (<table=int64#2,<q1=int64#7,8),>q1=int64#7
# asm 2: movzwq (<table=%rdx,<q1=%r11,8),>q1=%r11
movzwq (%rdx,%r11,8),%r11

# qhasm: e ^= q1
# asm 1: xor  <q1=int64#7,<e=int64#6
# asm 2: xor  <q1=%r11,<e=%r10
xor  %r11,%r10

# qhasm: x0 ^= e
# asm 1: xor  <e=int64#6,<x0=int64#3
# asm 2: xor  <e=%r10,<x0=%r8
xor  %r10,%r8

# qhasm: *(uint32 *) (c + 36) = x0
# asm 1: movl   <x0=int64#3d,36(<c=int64#1)
# asm 2: movl   <x0=%r8d,36(<c=%rcx)
movl   %r8d,36(%rcx)

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#3,<x1=int64#4
# asm 2: xor  <x0=%r8,<x1=%r9
xor  %r8,%r9

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#4,<x2=int64#5
# asm 2: xor  <x1=%r9,<x2=%rax
xor  %r9,%rax

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#5,<x3=int64#15
# asm 2: xor  <x2=%rax,<x3=%rbx
xor  %rax,%rbx

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>e=int64#12d
# asm 2: movzbl  <x3=%bh,>e=%edi
movzbl  %bh,%edi

# qhasm: e = *(uint8 *) (table + 1 + e * 8)
# asm 1: movzbq 1(<table=int64#2,<e=int64#12,8),>e=int64#6
# asm 2: movzbq 1(<table=%rdx,<e=%rdi,8),>e=%r10
movzbq 1(%rdx,%rdi,8),%r10

# qhasm: (uint32) e ^= 0x40
# asm 1: xor  $0x40,<e=int64#6d
# asm 2: xor  $0x40,<e=%r10d
xor  $0x40,%r10d

# qhasm: q3 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q3=int64#7d
# asm 2: movzbl  <x3=%bl,>q3=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q3 = *(uint32 *) (table + 2 + q3 * 8)
# asm 1: movl   2(<table=int64#2,<q3=int64#7,8),>q3=int64#7d
# asm 2: movl   2(<table=%rdx,<q3=%r11,8),>q3=%r11d
movl   2(%rdx,%r11,8),%r11d

# qhasm: (uint32) q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int64#7d
# asm 2: and  $0xff000000,<q3=%r11d
and  $0xff000000,%r11d

# qhasm: e ^= q3
# asm 1: xor  <q3=int64#7,<e=int64#6
# asm 2: xor  <q3=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>q2=int64#12d
# asm 2: movzbl  <x3=%bh,>q2=%edi
movzbl  %bh,%edi

# qhasm: q2 = *(uint32 *) (table + 3 + q2 * 8)
# asm 1: movl   3(<table=int64#2,<q2=int64#12,8),>q2=int64#7d
# asm 2: movl   3(<table=%rdx,<q2=%rdi,8),>q2=%r11d
movl   3(%rdx,%rdi,8),%r11d

# qhasm: (uint32) q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int64#7d
# asm 2: and  $0x00ff0000,<q2=%r11d
and  $0x00ff0000,%r11d

# qhasm: e ^= q2
# asm 1: xor  <q2=int64#7,<e=int64#6
# asm 2: xor  <q2=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q1 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q1=int64#7d
# asm 2: movzbl  <x3=%bl,>q1=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q1 = *(uint16 *) (table + q1 * 8)
# asm 1: movzwq (<table=int64#2,<q1=int64#7,8),>q1=int64#7
# asm 2: movzwq (<table=%rdx,<q1=%r11,8),>q1=%r11
movzwq (%rdx,%r11,8),%r11

# qhasm: e ^= q1
# asm 1: xor  <q1=int64#7,<e=int64#6
# asm 2: xor  <q1=%r11,<e=%r10
xor  %r11,%r10

# qhasm: x0 ^= e
# asm 1: xor  <e=int64#6,<x0=int64#3
# asm 2: xor  <e=%r10,<x0=%r8
xor  %r10,%r8

# qhasm: *(uint32 *) (c + 40) = x0
# asm 1: movl   <x0=int64#3d,40(<c=int64#1)
# asm 2: movl   <x0=%r8d,40(<c=%rcx)
movl   %r8d,40(%rcx)

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#3,<x1=int64#4
# asm 2: xor  <x0=%r8,<x1=%r9
xor  %r8,%r9

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#4,<x2=int64#5
# asm 2: xor  <x1=%r9,<x2=%rax
xor  %r9,%rax

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#5,<x3=int64#15
# asm 2: xor  <x2=%rax,<x3=%rbx
xor  %rax,%rbx

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>e=int64#12d
# asm 2: movzbl  <x3=%bh,>e=%edi
movzbl  %bh,%edi

# qhasm: e = *(uint8 *) (table + 1 + e * 8)
# asm 1: movzbq 1(<table=int64#2,<e=int64#12,8),>e=int64#6
# asm 2: movzbq 1(<table=%rdx,<e=%rdi,8),>e=%r10
movzbq 1(%rdx,%rdi,8),%r10

# qhasm: (uint32) e ^= 0x80
# asm 1: xor  $0x80,<e=int64#6d
# asm 2: xor  $0x80,<e=%r10d
xor  $0x80,%r10d

# qhasm: q3 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q3=int64#7d
# asm 2: movzbl  <x3=%bl,>q3=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q3 = *(uint32 *) (table + 2 + q3 * 8)
# asm 1: movl   2(<table=int64#2,<q3=int64#7,8),>q3=int64#7d
# asm 2: movl   2(<table=%rdx,<q3=%r11,8),>q3=%r11d
movl   2(%rdx,%r11,8),%r11d

# qhasm: (uint32) q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int64#7d
# asm 2: and  $0xff000000,<q3=%r11d
and  $0xff000000,%r11d

# qhasm: e ^= q3
# asm 1: xor  <q3=int64#7,<e=int64#6
# asm 2: xor  <q3=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>q2=int64#12d
# asm 2: movzbl  <x3=%bh,>q2=%edi
movzbl  %bh,%edi

# qhasm: q2 = *(uint32 *) (table + 3 + q2 * 8)
# asm 1: movl   3(<table=int64#2,<q2=int64#12,8),>q2=int64#7d
# asm 2: movl   3(<table=%rdx,<q2=%rdi,8),>q2=%r11d
movl   3(%rdx,%rdi,8),%r11d

# qhasm: (uint32) q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int64#7d
# asm 2: and  $0x00ff0000,<q2=%r11d
and  $0x00ff0000,%r11d

# qhasm: e ^= q2
# asm 1: xor  <q2=int64#7,<e=int64#6
# asm 2: xor  <q2=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q1 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q1=int64#7d
# asm 2: movzbl  <x3=%bl,>q1=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q1 = *(uint16 *) (table + q1 * 8)
# asm 1: movzwq (<table=int64#2,<q1=int64#7,8),>q1=int64#7
# asm 2: movzwq (<table=%rdx,<q1=%r11,8),>q1=%r11
movzwq (%rdx,%r11,8),%r11

# qhasm: e ^= q1
# asm 1: xor  <q1=int64#7,<e=int64#6
# asm 2: xor  <q1=%r11,<e=%r10
xor  %r11,%r10

# qhasm: x0 ^= e
# asm 1: xor  <e=int64#6,<x0=int64#3
# asm 2: xor  <e=%r10,<x0=%r8
xor  %r10,%r8

# qhasm: *(uint32 *) (c + 44) = x0
# asm 1: movl   <x0=int64#3d,44(<c=int64#1)
# asm 2: movl   <x0=%r8d,44(<c=%rcx)
movl   %r8d,44(%rcx)

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#3,<x1=int64#4
# asm 2: xor  <x0=%r8,<x1=%r9
xor  %r8,%r9

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#4,<x2=int64#5
# asm 2: xor  <x1=%r9,<x2=%rax
xor  %r9,%rax

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#5,<x3=int64#15
# asm 2: xor  <x2=%rax,<x3=%rbx
xor  %rax,%rbx

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>e=int64#12d
# asm 2: movzbl  <x3=%bh,>e=%edi
movzbl  %bh,%edi

# qhasm: e = *(uint8 *) (table + 1 + e * 8)
# asm 1: movzbq 1(<table=int64#2,<e=int64#12,8),>e=int64#6
# asm 2: movzbq 1(<table=%rdx,<e=%rdi,8),>e=%r10
movzbq 1(%rdx,%rdi,8),%r10

# qhasm: (uint32) e ^= 0x1b
# asm 1: xor  $0x1b,<e=int64#6d
# asm 2: xor  $0x1b,<e=%r10d
xor  $0x1b,%r10d

# qhasm: q3 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q3=int64#7d
# asm 2: movzbl  <x3=%bl,>q3=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q3 = *(uint32 *) (table + 2 + q3 * 8)
# asm 1: movl   2(<table=int64#2,<q3=int64#7,8),>q3=int64#7d
# asm 2: movl   2(<table=%rdx,<q3=%r11,8),>q3=%r11d
movl   2(%rdx,%r11,8),%r11d

# qhasm: (uint32) q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int64#7d
# asm 2: and  $0xff000000,<q3=%r11d
and  $0xff000000,%r11d

# qhasm: e ^= q3
# asm 1: xor  <q3=int64#7,<e=int64#6
# asm 2: xor  <q3=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>q2=int64#12d
# asm 2: movzbl  <x3=%bh,>q2=%edi
movzbl  %bh,%edi

# qhasm: q2 = *(uint32 *) (table + 3 + q2 * 8)
# asm 1: movl   3(<table=int64#2,<q2=int64#12,8),>q2=int64#7d
# asm 2: movl   3(<table=%rdx,<q2=%rdi,8),>q2=%r11d
movl   3(%rdx,%rdi,8),%r11d

# qhasm: (uint32) q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int64#7d
# asm 2: and  $0x00ff0000,<q2=%r11d
and  $0x00ff0000,%r11d

# qhasm: e ^= q2
# asm 1: xor  <q2=int64#7,<e=int64#6
# asm 2: xor  <q2=%r11,<e=%r10
xor  %r11,%r10

# qhasm: q1 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q1=int64#7d
# asm 2: movzbl  <x3=%bl,>q1=%r11d
movzbl  %bl,%r11d

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q1 = *(uint16 *) (table + q1 * 8)
# asm 1: movzwq (<table=int64#2,<q1=int64#7,8),>q1=int64#7
# asm 2: movzwq (<table=%rdx,<q1=%r11,8),>q1=%r11
movzwq (%rdx,%r11,8),%r11

# qhasm: e ^= q1
# asm 1: xor  <q1=int64#7,<e=int64#6
# asm 2: xor  <q1=%r11,<e=%r10
xor  %r11,%r10

# qhasm: x0 ^= e
# asm 1: xor  <e=int64#6,<x0=int64#3
# asm 2: xor  <e=%r10,<x0=%r8
xor  %r10,%r8

# qhasm: *(uint32 *) (c + 48) = x0
# asm 1: movl   <x0=int64#3d,48(<c=int64#1)
# asm 2: movl   <x0=%r8d,48(<c=%rcx)
movl   %r8d,48(%rcx)

# qhasm: x1 ^= x0
# asm 1: xor  <x0=int64#3,<x1=int64#4
# asm 2: xor  <x0=%r8,<x1=%r9
xor  %r8,%r9

# qhasm: x2 ^= x1
# asm 1: xor  <x1=int64#4,<x2=int64#5
# asm 2: xor  <x1=%r9,<x2=%rax
xor  %r9,%rax

# qhasm: x3 ^= x2
# asm 1: xor  <x2=int64#5,<x3=int64#15
# asm 2: xor  <x2=%rax,<x3=%rbx
xor  %rax,%rbx

# qhasm: e = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>e=int64#12d
# asm 2: movzbl  <x3=%bh,>e=%edi
movzbl  %bh,%edi

# qhasm: e = *(uint8 *) (table + 1 + e * 8)
# asm 1: movzbq 1(<table=int64#2,<e=int64#12,8),>e=int64#4
# asm 2: movzbq 1(<table=%rdx,<e=%rdi,8),>e=%r9
movzbq 1(%rdx,%rdi,8),%r9

# qhasm: (uint32) e ^= 0x36
# asm 1: xor  $0x36,<e=int64#4d
# asm 2: xor  $0x36,<e=%r9d
xor  $0x36,%r9d

# qhasm: q3 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q3=int64#5d
# asm 2: movzbl  <x3=%bl,>q3=%eax
movzbl  %bl,%eax

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q3 = *(uint32 *) (table + 2 + q3 * 8)
# asm 1: movl   2(<table=int64#2,<q3=int64#5,8),>q3=int64#5d
# asm 2: movl   2(<table=%rdx,<q3=%rax,8),>q3=%eax
movl   2(%rdx,%rax,8),%eax

# qhasm: (uint32) q3 &= 0xff000000
# asm 1: and  $0xff000000,<q3=int64#5d
# asm 2: and  $0xff000000,<q3=%eax
and  $0xff000000,%eax

# qhasm: e ^= q3
# asm 1: xor  <q3=int64#5,<e=int64#4
# asm 2: xor  <q3=%rax,<e=%r9
xor  %rax,%r9

# qhasm: q2 = (x3 >> 8) & 255
# asm 1: movzbl  <x3=int64#15%next8,>q2=int64#12d
# asm 2: movzbl  <x3=%bh,>q2=%edi
movzbl  %bh,%edi

# qhasm: q2 = *(uint32 *) (table + 3 + q2 * 8)
# asm 1: movl   3(<table=int64#2,<q2=int64#12,8),>q2=int64#5d
# asm 2: movl   3(<table=%rdx,<q2=%rdi,8),>q2=%eax
movl   3(%rdx,%rdi,8),%eax

# qhasm: (uint32) q2 &= 0x00ff0000
# asm 1: and  $0x00ff0000,<q2=int64#5d
# asm 2: and  $0x00ff0000,<q2=%eax
and  $0x00ff0000,%eax

# qhasm: e ^= q2
# asm 1: xor  <q2=int64#5,<e=int64#4
# asm 2: xor  <q2=%rax,<e=%r9
xor  %rax,%r9

# qhasm: q1 = x3 & 255
# asm 1: movzbl  <x3=int64#15b,>q1=int64#5d
# asm 2: movzbl  <x3=%bl,>q1=%eax
movzbl  %bl,%eax

# qhasm: (uint32) x3 <<<= 16
# asm 1: rol  $16,<x3=int64#15d
# asm 2: rol  $16,<x3=%ebx
rol  $16,%ebx

# qhasm: q1 = *(uint16 *) (table + q1 * 8)
# asm 1: movzwq (<table=int64#2,<q1=int64#5,8),>q1=int64#2
# asm 2: movzwq (<table=%rdx,<q1=%rax,8),>q1=%rdx
movzwq (%rdx,%rax,8),%rdx

# qhasm: e ^= q1
# asm 1: xor  <q1=int64#2,<e=int64#4
# asm 2: xor  <q1=%rdx,<e=%r9
xor  %rdx,%r9

# qhasm: x0 ^= e
# asm 1: xor  <e=int64#4,<x0=int64#3
# asm 2: xor  <e=%r9,<x0=%r8
xor  %r9,%r8

# qhasm: *(uint32 *) (c + 52) = x0
# asm 1: movl   <x0=int64#3d,52(<c=int64#1)
# asm 2: movl   <x0=%r8d,52(<c=%rcx)
movl   %r8d,52(%rcx)

# qhasm: r11_caller = r11_stack
# asm 1: movq <r11_stack=stack64#1,>r11_caller=int64#7
# asm 2: movq <r11_stack=0(%rsp),>r11_caller=%r11
movq 0(%rsp),%r11

# qhasm: r12_caller = r12_stack
# asm 1: movq <r12_stack=stack64#2,>r12_caller=int64#8
# asm 2: movq <r12_stack=8(%rsp),>r12_caller=%r12
movq 8(%rsp),%r12

# qhasm: r13_caller = r13_stack
# asm 1: movq <r13_stack=stack64#3,>r13_caller=int64#9
# asm 2: movq <r13_stack=16(%rsp),>r13_caller=%r13
movq 16(%rsp),%r13

# qhasm: r14_caller = r14_stack
# asm 1: movq <r14_stack=stack64#4,>r14_caller=int64#10
# asm 2: movq <r14_stack=24(%rsp),>r14_caller=%r14
movq 24(%rsp),%r14

# qhasm: r15_caller = r15_stack
# asm 1: movq <r15_stack=stack64#5,>r15_caller=int64#11
# asm 2: movq <r15_stack=32(%rsp),>r15_caller=%r15
movq 32(%rsp),%r15

# qhasm: rdi_caller = rdi_stack
# asm 1: movq <rdi_stack=stack64#6,>rdi_caller=int64#12
# asm 2: movq <rdi_stack=40(%rsp),>rdi_caller=%rdi
movq 40(%rsp),%rdi

# qhasm: rsi_caller = rsi_stack
# asm 1: movq <rsi_stack=stack64#7,>rsi_caller=int64#13
# asm 2: movq <rsi_stack=48(%rsp),>rsi_caller=%rsi
movq 48(%rsp),%rsi

# qhasm: rbp_caller = rbp_stack
# asm 1: movq <rbp_stack=stack64#8,>rbp_caller=int64#14
# asm 2: movq <rbp_stack=56(%rsp),>rbp_caller=%rbp
movq 56(%rsp),%rbp

# qhasm: rbx_caller = rbx_stack
# asm 1: movq <rbx_stack=stack64#9,>rbx_caller=int64#15
# asm 2: movq <rbx_stack=64(%rsp),>rbx_caller=%rbx
movq 64(%rsp),%rbx

# qhasm: leave
add %r11,%rsp
ret
