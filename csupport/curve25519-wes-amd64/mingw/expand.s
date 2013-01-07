
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
# asm 2: mov  $0x7ffffffffffff,>mask=%r8
mov  $0x7ffffffffffff,%r8

# qhasm:   r0   = *(uint64 *) (a +  0)
# asm 1: movq   0(<a=int64#2),>r0=int64#4
# asm 2: movq   0(<a=%rdx),>r0=%r9
movq   0(%rdx),%r9

# qhasm:   r48  = *(uint64 *) (a +  6)
# asm 1: movq   6(<a=int64#2),>r48=int64#5
# asm 2: movq   6(<a=%rdx),>r48=%rax
movq   6(%rdx),%rax

# qhasm:   r96  = *(uint64 *) (a + 12)
# asm 1: movq   12(<a=int64#2),>r96=int64#6
# asm 2: movq   12(<a=%rdx),>r96=%r10
movq   12(%rdx),%r10

# qhasm:   r152 = *(uint64 *) (a + 19)
# asm 1: movq   19(<a=int64#2),>r152=int64#7
# asm 2: movq   19(<a=%rdx),>r152=%r11
movq   19(%rdx),%r11

# qhasm:   r200 = *(uint64 *) (a + 25)
# asm 1: movq   25(<a=int64#2),>r200=int64#2
# asm 2: movq   25(<a=%rdx),>r200=%rdx
movq   25(%rdx),%rdx

# qhasm:   (uint64) r48  >>= 3
# asm 1: shr  $3,<r48=int64#5
# asm 2: shr  $3,<r48=%rax
shr  $3,%rax

# qhasm:   (uint64) r96  >>= 6
# asm 1: shr  $6,<r96=int64#6
# asm 2: shr  $6,<r96=%r10
shr  $6,%r10

# qhasm:   (uint64) r152 >>= 1
# asm 1: shr  $1,<r152=int64#7
# asm 2: shr  $1,<r152=%r11
shr  $1,%r11

# qhasm:   (uint64) r200 >>= 4
# asm 1: shr  $4,<r200=int64#2
# asm 2: shr  $4,<r200=%rdx
shr  $4,%rdx

# qhasm:   r0   &= mask
# asm 1: and  <mask=int64#3,<r0=int64#4
# asm 2: and  <mask=%r8,<r0=%r9
and  %r8,%r9

# qhasm:   r48  &= mask
# asm 1: and  <mask=int64#3,<r48=int64#5
# asm 2: and  <mask=%r8,<r48=%rax
and  %r8,%rax

# qhasm:   r96  &= mask
# asm 1: and  <mask=int64#3,<r96=int64#6
# asm 2: and  <mask=%r8,<r96=%r10
and  %r8,%r10

# qhasm:   r152 &= mask
# asm 1: and  <mask=int64#3,<r152=int64#7
# asm 2: and  <mask=%r8,<r152=%r11
and  %r8,%r11

# qhasm:   r200 &= mask
# asm 1: and  <mask=int64#3,<r200=int64#2
# asm 2: and  <mask=%r8,<r200=%rdx
and  %r8,%rdx

# qhasm:   *(uint64 *) (r +  0) = r0
# asm 1: movq   <r0=int64#4,0(<r=int64#1)
# asm 2: movq   <r0=%r9,0(<r=%rcx)
movq   %r9,0(%rcx)

# qhasm:   *(uint64 *) (r +  8) = r48
# asm 1: movq   <r48=int64#5,8(<r=int64#1)
# asm 2: movq   <r48=%rax,8(<r=%rcx)
movq   %rax,8(%rcx)

# qhasm:   *(uint64 *) (r + 16) = r96
# asm 1: movq   <r96=int64#6,16(<r=int64#1)
# asm 2: movq   <r96=%r10,16(<r=%rcx)
movq   %r10,16(%rcx)

# qhasm:   *(uint64 *) (r + 24) = r152
# asm 1: movq   <r152=int64#7,24(<r=int64#1)
# asm 2: movq   <r152=%r11,24(<r=%rcx)
movq   %r11,24(%rcx)

# qhasm:   *(uint64 *) (r + 32) = r200
# asm 1: movq   <r200=int64#2,32(<r=int64#1)
# asm 2: movq   <r200=%rdx,32(<r=%rcx)
movq   %rdx,32(%rcx)

# qhasm: leave nostack
ret
