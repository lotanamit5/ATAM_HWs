.global _start
#.global main

#.section .data
#src: .quad 5
#dst: .quad 4
#head: .quad ANode
#ANode:  .quad 5
#        .quad BNode
#BNode:  .quad 4
#        .quad NULL
#.set NULL, 0

.section .text
_start:
#main:
    xor %rax, %rax      # %rax = 0
    movl head, %eax     # %eax = first node ptr
    
    test %eax, %eax     # if(!head)
    jz end_HW1          #   return
    
    xor %rbx, %rbx      # %rbx = 0
    movl src, %ebx      # %ebx = src
    xor %rcx, %rcx      # %rcx = 0
    movl dst, %ecx      # %ecx = dst
    
    cmp %ebx, %ecx
    jz end_HW1          # if (dst == src) return
    
    xor %r8, %r8        # %r8 = 0 -> counter for src
    xor %r9, %r9        # %r8 = 0 -> counter for dst
    xor %r10, %r10      # %r10 = 0 -> pointer for src
    xor %r11, %r11      # %r11 = 0 -> pointer for dst
    
    mov head, %r12d     # %r12d = current ptr
    
while_HW1:
    cmp %ebx, (%r12d)   # compare src to *curr
    jnz dst_check_HW1   # if (src == *curr)
    inc %r8             # src_count++
    mov %r12, %r10      # src_ptr = curr
dst_check_HW1:
    cmp %ecx, (%r12d)   # compare dst to *curr
    jnz while_cont_HW1  # if (dst == *curr)
    inc %r9             # dst_count++
    mov %r12, %r11      # dst_ptr = curr
while_cont_HW1:
    mov 8(%r12d), %r12d # curr = curr->next
    test %r12d, %r12d
    jne while_HW1       # while(next != null)
    
    cmp $1, %r8         
    jnz end_HW1         # if (src_count != 1) return
    cmp $1, %r9         
    jnz end_HW1         # if (dst_count != 1) return
    
    movl %ebx, (%r11)    # *dst_ptr = src
    movl %ecx, (%r10)    # *src_ptr = dst
    
end_HW1:
    nop
    