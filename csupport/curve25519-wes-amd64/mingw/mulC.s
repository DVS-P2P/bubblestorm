
# qhasm: int64 r

# qhasm: int64 a

# qhasm: int64 b

# qhasm: int64 x

# qhasm: int64 y

# qhasm: int64 r0

# qhasm: int64 mask

# qhasm: int6464 tmp

# qhasm: int64 rax

# qhasm: int64 rdx

# qhasm: int64 carry51

# qhasm: int64 carry102

# qhasm: int64 carry153

# qhasm: int64 carry204

# qhasm: int64 carry255

# qhasm: enter field25519_wes_mulC nostack
.text
.p2align 5
.globl _field25519_wes_mulC
.globl field25519_wes_mulC
_field25519_wes_mulC:
field25519_wes_mulC:

# qhasm:   input r

# qhasm:   input b

# qhasm:   input y

# qhasm:   x = y 
# asm 1: mov  <y=int64#3,>x=int64#3
# asm 2: mov  <y=%r8,>x=%r8
mov  %r8,%r8

# qhasm:   a = b 
# asm 1: mov  <b=int64#2,>a=int64#4
# asm 2: mov  <b=%rdx,>a=%r9
mov  %rdx,%r9

# qhasm:   mask = 0x7ffffffffffff
# asm 1: mov  $0x7ffffffffffff,>mask=int64#6
# asm 2: mov  $0x7ffffffffffff,>mask=%r10
mov  $0x7ffffffffffff,%r10

# qhasm:   rax  = *(uint64 *) (a +  0)
# asm 1: movq   0(<a=int64#4),>rax=int64#5
# asm 2: movq   0(<a=%r9),>rax=%rax
movq   0(%r9),%rax

# qhasm:   (int128) rdx rax = rax * x
# asm 1: imul <x=int64#3
# asm 2: imul <x=%r8
imul %r8

# qhasm:   rdx = (rdx.rax) << 13
# asm 1: shld $13,<rax=int64#5,<rdx=int64#2
# asm 2: shld $13,<rax=%rax,<rdx=%rdx
shld $13,%rax,%rdx

# qhasm:   rax &= mask
# asm 1: and  <mask=int64#6,<rax=int64#5
# asm 2: and  <mask=%r10,<rax=%rax
and  %r10,%rax

# qhasm:   carry51 = rdx
# asm 1: mov  <rdx=int64#2,>carry51=int64#7
# asm 2: mov  <rdx=%rdx,>carry51=%r11
mov  %rdx,%r11

# qhasm:   tmp = rax
# asm 1: movd   <rax=int64#5,>tmp=int6464#1
# asm 2: movd   <rax=%rax,>tmp=%xmm0
movd   %rax,%xmm0

# qhasm:   rax = *(uint64 *) (a +  8)
# asm 1: movq   8(<a=int64#4),>rax=int64#5
# asm 2: movq   8(<a=%r9),>rax=%rax
movq   8(%r9),%rax

# qhasm:   (int128) rdx rax = rax * x
# asm 1: imul <x=int64#3
# asm 2: imul <x=%r8
imul %r8

# qhasm:   rdx = (rdx.rax) << 13
# asm 1: shld $13,<rax=int64#5,<rdx=int64#2
# asm 2: shld $13,<rax=%rax,<rdx=%rdx
shld $13,%rax,%rdx

# qhasm:   rax &= mask
# asm 1: and  <mask=int64#6,<rax=int64#5
# asm 2: and  <mask=%r10,<rax=%rax
and  %r10,%rax

# qhasm:   rax += carry51
# asm 1: add  <carry51=int64#7,<rax=int64#5
# asm 2: add  <carry51=%r11,<rax=%rax
add  %r11,%rax

# qhasm:   carry102 = rdx
# asm 1: mov  <rdx=int64#2,>carry102=int64#7
# asm 2: mov  <rdx=%rdx,>carry102=%r11
mov  %rdx,%r11

# qhasm:   *(uint64 *) (r + 8) = rax
# asm 1: movq   <rax=int64#5,8(<r=int64#1)
# asm 2: movq   <rax=%rax,8(<r=%rcx)
movq   %rax,8(%rcx)

# qhasm:   rax = *(uint64 *) (a + 16)
# asm 1: movq   16(<a=int64#4),>rax=int64#5
# asm 2: movq   16(<a=%r9),>rax=%rax
movq   16(%r9),%rax

# qhasm:   (int128) rdx rax = rax * x
# asm 1: imul <x=int64#3
# asm 2: imul <x=%r8
imul %r8

# qhasm:   rdx = (rdx.rax) << 13
# asm 1: shld $13,<rax=int64#5,<rdx=int64#2
# asm 2: shld $13,<rax=%rax,<rdx=%rdx
shld $13,%rax,%rdx

# qhasm:   rax &= mask
# asm 1: and  <mask=int64#6,<rax=int64#5
# asm 2: and  <mask=%r10,<rax=%rax
and  %r10,%rax

# qhasm:   rax += carry102
# asm 1: add  <carry102=int64#7,<rax=int64#5
# asm 2: add  <carry102=%r11,<rax=%rax
add  %r11,%rax

# qhasm:   carry153 = rdx
# asm 1: mov  <rdx=int64#2,>carry153=int64#7
# asm 2: mov  <rdx=%rdx,>carry153=%r11
mov  %rdx,%r11

# qhasm:   *(uint64 *) (r + 16) = rax
# asm 1: movq   <rax=int64#5,16(<r=int64#1)
# asm 2: movq   <rax=%rax,16(<r=%rcx)
movq   %rax,16(%rcx)

# qhasm:   rax = *(uint64 *) (a + 24)
# asm 1: movq   24(<a=int64#4),>rax=int64#5
# asm 2: movq   24(<a=%r9),>rax=%rax
movq   24(%r9),%rax

# qhasm:   (int128) rdx rax = rax * x
# asm 1: imul <x=int64#3
# asm 2: imul <x=%r8
imul %r8

# qhasm:   rdx = (rdx.rax) << 13
# asm 1: shld $13,<rax=int64#5,<rdx=int64#2
# asm 2: shld $13,<rax=%rax,<rdx=%rdx
shld $13,%rax,%rdx

# qhasm:   rax &= mask
# asm 1: and  <mask=int64#6,<rax=int64#5
# asm 2: and  <mask=%r10,<rax=%rax
and  %r10,%rax

# qhasm:   rax += carry153
# asm 1: add  <carry153=int64#7,<rax=int64#5
# asm 2: add  <carry153=%r11,<rax=%rax
add  %r11,%rax

# qhasm:   carry204 = rdx
# asm 1: mov  <rdx=int64#2,>carry204=int64#7
# asm 2: mov  <rdx=%rdx,>carry204=%r11
mov  %rdx,%r11

# qhasm:   *(uint64 *) (r + 24) = rax
# asm 1: movq   <rax=int64#5,24(<r=int64#1)
# asm 2: movq   <rax=%rax,24(<r=%rcx)
movq   %rax,24(%rcx)

# qhasm:   rax = *(uint64 *) (a + 32)
# asm 1: movq   32(<a=int64#4),>rax=int64#5
# asm 2: movq   32(<a=%r9),>rax=%rax
movq   32(%r9),%rax

# qhasm:   (int128) rdx rax = rax * x
# asm 1: imul <x=int64#3
# asm 2: imul <x=%r8
imul %r8

# qhasm:   rdx = (rdx.rax) << 13
# asm 1: shld $13,<rax=int64#5,<rdx=int64#2
# asm 2: shld $13,<rax=%rax,<rdx=%rdx
shld $13,%rax,%rdx

# qhasm:   rax &= mask
# asm 1: and  <mask=int64#6,<rax=int64#5
# asm 2: and  <mask=%r10,<rax=%rax
and  %r10,%rax

# qhasm:   rax += carry204
# asm 1: add  <carry204=int64#7,<rax=int64#5
# asm 2: add  <carry204=%r11,<rax=%rax
add  %r11,%rax

# qhasm:   carry255 = rdx
# asm 1: mov  <rdx=int64#2,>carry255=int64#2
# asm 2: mov  <rdx=%rdx,>carry255=%rdx
mov  %rdx,%rdx

# qhasm:   *(uint64 *) (r + 32) = rax
# asm 1: movq   <rax=int64#5,32(<r=int64#1)
# asm 2: movq   <rax=%rax,32(<r=%rcx)
movq   %rax,32(%rcx)

# qhasm:   r0 = tmp
# asm 1: movd   <tmp=int6464#1,>r0=int64#3
# asm 2: movd   <tmp=%xmm0,>r0=%r8
movd   %xmm0,%r8

# qhasm:   carry255 *= 19
# asm 1: imul  $19,<carry255=int64#2
# asm 2: imul  $19,<carry255=%rdx
imul  $19,%rdx

# qhasm:   r0 += carry255
# asm 1: add  <carry255=int64#2,<r0=int64#3
# asm 2: add  <carry255=%rdx,<r0=%r8
add  %rdx,%r8

# qhasm:   *(uint64 *) (r + 0) = r0
# asm 1: movq   <r0=int64#3,0(<r=int64#1)
# asm 2: movq   <r0=%r8,0(<r=%rcx)
movq   %r8,0(%rcx)

# qhasm: leave nostack
ret
