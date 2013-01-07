
# qhasm: int64 r

# qhasm: int64 a

# qhasm: int64 b

# qhasm: int64 r0

# qhasm: int64 r51

# qhasm: int64 r102

# qhasm: int64 r153

# qhasm: int64 r204

# qhasm: enter field25519_wes_sub nostack
.text
.p2align 5
.globl _field25519_wes_sub
.globl field25519_wes_sub
_field25519_wes_sub:
field25519_wes_sub:

# qhasm:   input r

# qhasm:   input a

# qhasm:   input b

# qhasm:   r0   = *(uint64 *) (a +  0)
# asm 1: movq   0(<a=int64#2),>r0=int64#4
# asm 2: movq   0(<a=%rsi),>r0=%rcx
movq   0(%rsi),%rcx

# qhasm:   r51  = *(uint64 *) (a +  8)
# asm 1: movq   8(<a=int64#2),>r51=int64#5
# asm 2: movq   8(<a=%rsi),>r51=%r8
movq   8(%rsi),%r8

# qhasm:   r102 = *(uint64 *) (a + 16)
# asm 1: movq   16(<a=int64#2),>r102=int64#6
# asm 2: movq   16(<a=%rsi),>r102=%r9
movq   16(%rsi),%r9

# qhasm:   r153 = *(uint64 *) (a + 24)
# asm 1: movq   24(<a=int64#2),>r153=int64#7
# asm 2: movq   24(<a=%rsi),>r153=%rax
movq   24(%rsi),%rax

# qhasm:   r204 = *(uint64 *) (a + 32)
# asm 1: movq   32(<a=int64#2),>r204=int64#2
# asm 2: movq   32(<a=%rsi),>r204=%rsi
movq   32(%rsi),%rsi

# qhasm:   r0   -= *(uint64 *) (b +  0)
# asm 1: subq 0(<b=int64#3),<r0=int64#4
# asm 2: subq 0(<b=%rdx),<r0=%rcx
subq 0(%rdx),%rcx

# qhasm:   r51  -= *(uint64 *) (b +  8)
# asm 1: subq 8(<b=int64#3),<r51=int64#5
# asm 2: subq 8(<b=%rdx),<r51=%r8
subq 8(%rdx),%r8

# qhasm:   r102 -= *(uint64 *) (b + 16)
# asm 1: subq 16(<b=int64#3),<r102=int64#6
# asm 2: subq 16(<b=%rdx),<r102=%r9
subq 16(%rdx),%r9

# qhasm:   r153 -= *(uint64 *) (b + 24)
# asm 1: subq 24(<b=int64#3),<r153=int64#7
# asm 2: subq 24(<b=%rdx),<r153=%rax
subq 24(%rdx),%rax

# qhasm:   r204 -= *(uint64 *) (b + 32)
# asm 1: subq 32(<b=int64#3),<r204=int64#2
# asm 2: subq 32(<b=%rdx),<r204=%rsi
subq 32(%rdx),%rsi

# qhasm:   *(uint64 *) (r +  0) = r0
# asm 1: movq   <r0=int64#4,0(<r=int64#1)
# asm 2: movq   <r0=%rcx,0(<r=%rdi)
movq   %rcx,0(%rdi)

# qhasm:   *(uint64 *) (r +  8) = r51
# asm 1: movq   <r51=int64#5,8(<r=int64#1)
# asm 2: movq   <r51=%r8,8(<r=%rdi)
movq   %r8,8(%rdi)

# qhasm:   *(uint64 *) (r + 16) = r102
# asm 1: movq   <r102=int64#6,16(<r=int64#1)
# asm 2: movq   <r102=%r9,16(<r=%rdi)
movq   %r9,16(%rdi)

# qhasm:   *(uint64 *) (r + 24) = r153
# asm 1: movq   <r153=int64#7,24(<r=int64#1)
# asm 2: movq   <r153=%rax,24(<r=%rdi)
movq   %rax,24(%rdi)

# qhasm:   *(uint64 *) (r + 32) = r204
# asm 1: movq   <r204=int64#2,32(<r=int64#1)
# asm 2: movq   <r204=%rsi,32(<r=%rdi)
movq   %rsi,32(%rdi)

# qhasm: leave nostack
ret
