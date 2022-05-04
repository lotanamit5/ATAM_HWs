.global _start

.section .text
_start:
    lea source, %r9d
    lea destination, %r10d
    
    mov num, %r8d
    test %r8d, %r8d
    jz end_HW1
    jns loop_dir_HW1
    xor $-1, %r8d 
    inc %r8d
    lea destination, %r9d
    lea source, %r10d
    
loop_dir_HW1:
    mov  %r10d, %eax
    sub  %r9d, %eax             # dst-src distance in bytes
    cmp  %r8d, %eax
    jb   backwards_HW1          # if (dst-src < copy_size) goto backwards

forward_HW1:
    mov  $0, %eax
forward_loop_HW1:
    lea (%r9d, %eax), %edx
    movb (%edx), %cl
    lea (%r10d, %eax), %edx
    movb %cl,(%edx)
    inc %eax
    cmp %r8d, %eax
    jne forward_loop_HW1
    jmp end_HW1

backwards_HW1:
    movl %r8d, %eax        # start from i=length
    dec %r9d
    dec %r10d
backwards_loop_HW1:
    movb  (%r9d, %eax), %cl
    movb  %cl, (%r10d, %eax)
    dec   %eax
    jnz   backwards_loop_HW1
end_HW1:

