
# qhasm: int64 r

# qhasm: int64 a

# qhasm: int64 b

# qhasm: int64 r0

# qhasm: int64 r51

# qhasm: int64 r102

# qhasm: int64 r153

# qhasm: int64 r204

# qhasm: enter field25519_wes_add nostack
.text
.p2align 5
.globl _field25519_wes_add
.globl field25519_wes_add
_field25519_wes_add:
field25519_wes_add:

# qhasm:   input r

# qhasm:   input a

# qhasm:   input b

# qhasm:   r0   = *(uint64 *) (a +  0)
# asm 1: movq   0(<a=int64#2),>r0=int64#4
# asm 2: movq   0(<a=%rdx),>r0=%r9
movq   0(%rdx),%r9

# qhasm:   r51  = *(uint64 *) (a +  8)
# asm 1: movq   8(<a=int64#2),>r51=int64#5
# asm 2: movq   8(<a=%rdx),>r51=%rax
movq   8(%rdx),%rax

# qhasm:   r102 = *(uint64 *) (a + 16)
# asm 1: movq   16(<a=int64#2),>r102=int64#6
# asm 2: movq   16(<a=%rdx),>r102=%r10
movq   16(%rdx),%r10

# qhasm:   r153 = *(uint64 *) (a + 24)
# asm 1: movq   24(<a=int64#2),>r153=int64#7
# asm 2: movq   24(<a=%rdx),>r153=%r11
movq   24(%rdx),%r11

# qhasm:   r204 = *(uint64 *) (a + 32)
# asm 1: movq   32(<a=int64#2),>r204=int64#2
# asm 2: movq   32(<a=%rdx),>r204=%rdx
movq   32(%rdx),%rdx

# qhasm:   r0   += *(uint64 *) (b +  0)
# asm 1: addq 0(<b=int64#3),<r0=int64#4
# asm 2: addq 0(<b=%r8),<r0=%r9
addq 0(%r8),%r9

# qhasm:   r51  += *(uint64 *) (b +  8)
# asm 1: addq 8(<b=int64#3),<r51=int64#5
# asm 2: addq 8(<b=%r8),<r51=%rax
addq 8(%r8),%rax

# qhasm:   r102 += *(uint64 *) (b + 16)
# asm 1: addq 16(<b=int64#3),<r102=int64#6
# asm 2: addq 16(<b=%r8),<r102=%r10
addq 16(%r8),%r10

# qhasm:   r153 += *(uint64 *) (b + 24)
# asm 1: addq 24(<b=int64#3),<r153=int64#7
# asm 2: addq 24(<b=%r8),<r153=%r11
addq 24(%r8),%r11

# qhasm:   r204 += *(uint64 *) (b + 32)
# asm 1: addq 32(<b=int64#3),<r204=int64#2
# asm 2: addq 32(<b=%r8),<r204=%rdx
addq 32(%r8),%rdx

# qhasm:   *(uint64 *) (r +  0) = r0
# asm 1: movq   <r0=int64#4,0(<r=int64#1)
# asm 2: movq   <r0=%r9,0(<r=%rcx)
movq   %r9,0(%rcx)

# qhasm:   *(uint64 *) (r +  8) = r51
# asm 1: movq   <r51=int64#5,8(<r=int64#1)
# asm 2: movq   <r51=%rax,8(<r=%rcx)
movq   %rax,8(%rcx)

# qhasm:   *(uint64 *) (r + 16) = r102
# asm 1: movq   <r102=int64#6,16(<r=int64#1)
# asm 2: movq   <r102=%r10,16(<r=%rcx)
movq   %r10,16(%rcx)

# qhasm:   *(uint64 *) (r + 24) = r153
# asm 1: movq   <r153=int64#7,24(<r=int64#1)
# asm 2: movq   <r153=%r11,24(<r=%rcx)
movq   %r11,24(%rcx)

# qhasm:   *(uint64 *) (r + 32) = r204
# asm 1: movq   <r204=int64#2,32(<r=int64#1)
# asm 2: movq   <r204=%rdx,32(<r=%rcx)
movq   %rdx,32(%rcx)

# qhasm: leave nostack
ret
