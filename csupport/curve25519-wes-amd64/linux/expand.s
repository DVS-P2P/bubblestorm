
# qhasm: int64 r

# qhasm: int64 a

# qhasm: int64 mask

# qhasm: int64 r0

# qhasm: int64 r48

# qhasm: int64 r96

# qhasm: int64 r152

# qhasm: int64 r200

# qhasm: enter field25519_wes_expand nostack
.text
.p2align 5
.globl _field25519_wes_expand
.globl field25519_wes_expand
_field25519_wes_expand:
field25519_wes_expand:

# qhasm:   input r

# qhasm:   input a

# qhasm:   mask = 0x7ffffffffffff
# asm 1: mov  $0x7ffffffffffff,>mask=int64#3
# asm 2: mov  $0x7ffffffffffff,>mask=%rdx
mov  $0x7ffffffffffff,%rdx

# qhasm:   r0   = *(uint64 *) (a +  0)
# asm 1: movq   0(<a=int64#2),>r0=int64#4
# asm 2: movq   0(<a=%rsi),>r0=%rcx
movq   0(%rsi),%rcx

# qhasm:   r48  = *(uint64 *) (a +  6)
# asm 1: movq   6(<a=int64#2),>r48=int64#5
# asm 2: movq   6(<a=%rsi),>r48=%r8
movq   6(%rsi),%r8

# qhasm:   r96  = *(uint64 *) (a + 12)
# asm 1: movq   12(<a=int64#2),>r96=int64#6
# asm 2: movq   12(<a=%rsi),>r96=%r9
movq   12(%rsi),%r9

# qhasm:   r152 = *(uint64 *) (a + 19)
# asm 1: movq   19(<a=int64#2),>r152=int64#7
# asm 2: movq   19(<a=%rsi),>r152=%rax
movq   19(%rsi),%rax

# qhasm:   r200 = *(uint64 *) (a + 25)
# asm 1: movq   25(<a=int64#2),>r200=int64#2
# asm 2: movq   25(<a=%rsi),>r200=%rsi
movq   25(%rsi),%rsi

# qhasm:   (uint64) r48  >>= 3
# asm 1: shr  $3,<r48=int64#5
# asm 2: shr  $3,<r48=%r8
shr  $3,%r8

# qhasm:   (uint64) r96  >>= 6
# asm 1: shr  $6,<r96=int64#6
# asm 2: shr  $6,<r96=%r9
shr  $6,%r9

# qhasm:   (uint64) r152 >>= 1
# asm 1: shr  $1,<r152=int64#7
# asm 2: shr  $1,<r152=%rax
shr  $1,%rax

# qhasm:   (uint64) r200 >>= 4
# asm 1: shr  $4,<r200=int64#2
# asm 2: shr  $4,<r200=%rsi
shr  $4,%rsi

# qhasm:   r0   &= mask
# asm 1: and  <mask=int64#3,<r0=int64#4
# asm 2: and  <mask=%rdx,<r0=%rcx
and  %rdx,%rcx

# qhasm:   r48  &= mask
# asm 1: and  <mask=int64#3,<r48=int64#5
# asm 2: and  <mask=%rdx,<r48=%r8
and  %rdx,%r8

# qhasm:   r96  &= mask
# asm 1: and  <mask=int64#3,<r96=int64#6
# asm 2: and  <mask=%rdx,<r96=%r9
and  %rdx,%r9

# qhasm:   r152 &= mask
# asm 1: and  <mask=int64#3,<r152=int64#7
# asm 2: and  <mask=%rdx,<r152=%rax
and  %rdx,%rax

# qhasm:   r200 &= mask
# asm 1: and  <mask=int64#3,<r200=int64#2
# asm 2: and  <mask=%rdx,<r200=%rsi
and  %rdx,%rsi

# qhasm:   *(uint64 *) (r +  0) = r0
# asm 1: movq   <r0=int64#4,0(<r=int64#1)
# asm 2: movq   <r0=%rcx,0(<r=%rdi)
movq   %rcx,0(%rdi)

# qhasm:   *(uint64 *) (r +  8) = r48
# asm 1: movq   <r48=int64#5,8(<r=int64#1)
# asm 2: movq   <r48=%r8,8(<r=%rdi)
movq   %r8,8(%rdi)

# qhasm:   *(uint64 *) (r + 16) = r96
# asm 1: movq   <r96=int64#6,16(<r=int64#1)
# asm 2: movq   <r96=%r9,16(<r=%rdi)
movq   %r9,16(%rdi)

# qhasm:   *(uint64 *) (r + 24) = r152
# asm 1: movq   <r152=int64#7,24(<r=int64#1)
# asm 2: movq   <r152=%rax,24(<r=%rdi)
movq   %rax,24(%rdi)

# qhasm:   *(uint64 *) (r + 32) = r200
# asm 1: movq   <r200=int64#2,32(<r=int64#1)
# asm 2: movq   <r200=%rsi,32(<r=%rdi)
movq   %rsi,32(%rdi)

# qhasm: leave nostack
ret
