
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
# asm 1: mov  <y=int64#3,>x=int64#4
# asm 2: mov  <y=%rdx,>x=%rcx
mov  %rdx,%rcx

# qhasm:   a = b 
# asm 1: mov  <b=int64#2,>a=int64#2
# asm 2: mov  <b=%rsi,>a=%rsi
mov  %rsi,%rsi

# qhasm:   mask = 0x7ffffffffffff
# asm 1: mov  $0x7ffffffffffff,>mask=int64#5
# asm 2: mov  $0x7ffffffffffff,>mask=%r8
mov  $0x7ffffffffffff,%r8

# qhasm:   rax  = *(uint64 *) (a +  0)
# asm 1: movq   0(<a=int64#2),>rax=int64#7
# asm 2: movq   0(<a=%rsi),>rax=%rax
movq   0(%rsi),%rax

# qhasm:   (int128) rdx rax = rax * x
# asm 1: imul <x=int64#4
# asm 2: imul <x=%rcx
imul %rcx

# qhasm:   rdx = (rdx.rax) << 13
# asm 1: shld $13,<rax=int64#7,<rdx=int64#3
# asm 2: shld $13,<rax=%rax,<rdx=%rdx
shld $13,%rax,%rdx

# qhasm:   rax &= mask
# asm 1: and  <mask=int64#5,<rax=int64#7
# asm 2: and  <mask=%r8,<rax=%rax
and  %r8,%rax

# qhasm:   carry51 = rdx
# asm 1: mov  <rdx=int64#3,>carry51=int64#6
# asm 2: mov  <rdx=%rdx,>carry51=%r9
mov  %rdx,%r9

# qhasm:   tmp = rax
# asm 1: movd   <rax=int64#7,>tmp=int6464#1
# asm 2: movd   <rax=%rax,>tmp=%xmm0
movd   %rax,%xmm0

# qhasm:   rax = *(uint64 *) (a +  8)
# asm 1: movq   8(<a=int64#2),>rax=int64#7
# asm 2: movq   8(<a=%rsi),>rax=%rax
movq   8(%rsi),%rax

# qhasm:   (int128) rdx rax = rax * x
# asm 1: imul <x=int64#4
# asm 2: imul <x=%rcx
imul %rcx

# qhasm:   rdx = (rdx.rax) << 13
# asm 1: shld $13,<rax=int64#7,<rdx=int64#3
# asm 2: shld $13,<rax=%rax,<rdx=%rdx
shld $13,%rax,%rdx

# qhasm:   rax &= mask
# asm 1: and  <mask=int64#5,<rax=int64#7
# asm 2: and  <mask=%r8,<rax=%rax
and  %r8,%rax

# qhasm:   rax += carry51
# asm 1: add  <carry51=int64#6,<rax=int64#7
# asm 2: add  <carry51=%r9,<rax=%rax
add  %r9,%rax

# qhasm:   carry102 = rdx
# asm 1: mov  <rdx=int64#3,>carry102=int64#6
# asm 2: mov  <rdx=%rdx,>carry102=%r9
mov  %rdx,%r9

# qhasm:   *(uint64 *) (r + 8) = rax
# asm 1: movq   <rax=int64#7,8(<r=int64#1)
# asm 2: movq   <rax=%rax,8(<r=%rdi)
movq   %rax,8(%rdi)

# qhasm:   rax = *(uint64 *) (a + 16)
# asm 1: movq   16(<a=int64#2),>rax=int64#7
# asm 2: movq   16(<a=%rsi),>rax=%rax
movq   16(%rsi),%rax

# qhasm:   (int128) rdx rax = rax * x
# asm 1: imul <x=int64#4
# asm 2: imul <x=%rcx
imul %rcx

# qhasm:   rdx = (rdx.rax) << 13
# asm 1: shld $13,<rax=int64#7,<rdx=int64#3
# asm 2: shld $13,<rax=%rax,<rdx=%rdx
shld $13,%rax,%rdx

# qhasm:   rax &= mask
# asm 1: and  <mask=int64#5,<rax=int64#7
# asm 2: and  <mask=%r8,<rax=%rax
and  %r8,%rax

# qhasm:   rax += carry102
# asm 1: add  <carry102=int64#6,<rax=int64#7
# asm 2: add  <carry102=%r9,<rax=%rax
add  %r9,%rax

# qhasm:   carry153 = rdx
# asm 1: mov  <rdx=int64#3,>carry153=int64#6
# asm 2: mov  <rdx=%rdx,>carry153=%r9
mov  %rdx,%r9

# qhasm:   *(uint64 *) (r + 16) = rax
# asm 1: movq   <rax=int64#7,16(<r=int64#1)
# asm 2: movq   <rax=%rax,16(<r=%rdi)
movq   %rax,16(%rdi)

# qhasm:   rax = *(uint64 *) (a + 24)
# asm 1: movq   24(<a=int64#2),>rax=int64#7
# asm 2: movq   24(<a=%rsi),>rax=%rax
movq   24(%rsi),%rax

# qhasm:   (int128) rdx rax = rax * x
# asm 1: imul <x=int64#4
# asm 2: imul <x=%rcx
imul %rcx

# qhasm:   rdx = (rdx.rax) << 13
# asm 1: shld $13,<rax=int64#7,<rdx=int64#3
# asm 2: shld $13,<rax=%rax,<rdx=%rdx
shld $13,%rax,%rdx

# qhasm:   rax &= mask
# asm 1: and  <mask=int64#5,<rax=int64#7
# asm 2: and  <mask=%r8,<rax=%rax
and  %r8,%rax

# qhasm:   rax += carry153
# asm 1: add  <carry153=int64#6,<rax=int64#7
# asm 2: add  <carry153=%r9,<rax=%rax
add  %r9,%rax

# qhasm:   carry204 = rdx
# asm 1: mov  <rdx=int64#3,>carry204=int64#6
# asm 2: mov  <rdx=%rdx,>carry204=%r9
mov  %rdx,%r9

# qhasm:   *(uint64 *) (r + 24) = rax
# asm 1: movq   <rax=int64#7,24(<r=int64#1)
# asm 2: movq   <rax=%rax,24(<r=%rdi)
movq   %rax,24(%rdi)

# qhasm:   rax = *(uint64 *) (a + 32)
# asm 1: movq   32(<a=int64#2),>rax=int64#7
# asm 2: movq   32(<a=%rsi),>rax=%rax
movq   32(%rsi),%rax

# qhasm:   (int128) rdx rax = rax * x
# asm 1: imul <x=int64#4
# asm 2: imul <x=%rcx
imul %rcx

# qhasm:   rdx = (rdx.rax) << 13
# asm 1: shld $13,<rax=int64#7,<rdx=int64#3
# asm 2: shld $13,<rax=%rax,<rdx=%rdx
shld $13,%rax,%rdx

# qhasm:   rax &= mask
# asm 1: and  <mask=int64#5,<rax=int64#7
# asm 2: and  <mask=%r8,<rax=%rax
and  %r8,%rax

# qhasm:   rax += carry204
# asm 1: add  <carry204=int64#6,<rax=int64#7
# asm 2: add  <carry204=%r9,<rax=%rax
add  %r9,%rax

# qhasm:   carry255 = rdx
# asm 1: mov  <rdx=int64#3,>carry255=int64#2
# asm 2: mov  <rdx=%rdx,>carry255=%rsi
mov  %rdx,%rsi

# qhasm:   *(uint64 *) (r + 32) = rax
# asm 1: movq   <rax=int64#7,32(<r=int64#1)
# asm 2: movq   <rax=%rax,32(<r=%rdi)
movq   %rax,32(%rdi)

# qhasm:   r0 = tmp
# asm 1: movd   <tmp=int6464#1,>r0=int64#3
# asm 2: movd   <tmp=%xmm0,>r0=%rdx
movd   %xmm0,%rdx

# qhasm:   carry255 *= 19
# asm 1: imul  $19,<carry255=int64#2
# asm 2: imul  $19,<carry255=%rsi
imul  $19,%rsi

# qhasm:   r0 += carry255
# asm 1: add  <carry255=int64#2,<r0=int64#3
# asm 2: add  <carry255=%rsi,<r0=%rdx
add  %rsi,%rdx

# qhasm:   *(uint64 *) (r + 0) = r0
# asm 1: movq   <r0=int64#3,0(<r=int64#1)
# asm 2: movq   <r0=%rdx,0(<r=%rdi)
movq   %rdx,0(%rdi)

# qhasm: leave nostack
ret
