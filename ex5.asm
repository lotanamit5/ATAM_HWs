.global _start
#.global main

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
    xor %r10, %r10      # %r10 = 0 -> src_prev
    xor %r11, %r11      # %r11 = 0 -> dst_prev
    
    mov $head, %r12d     # %r12d = current ptr
    mov (%r12d), %r13d # %r13d = next ptr
    
while_HW1:
   # cmp %ebx, 8(%r12d)   # compare src to *(curr->next)
    cmp %ebx, (%r13d)   # compare src to *(curr->next)
    jnz dst_check_HW1   # if (src == *curr)
    inc %r8             # src_count++
    mov %r12, %r10      # src_ptr = curr
dst_check_HW1:
    cmp %ecx, (%r13d)   # compare dst to *curr
    jnz while_cont_HW1  # if (dst == *curr)
    inc %r9             # dst_count++
    mov %r12, %r11      # dst_ptr = curr
while_cont_HW1:
    mov %r13d, %r12d    # curr = curr->next
    mov 8(%r12d), %r13d # %r13d = next ptr
    test %r13d, %r13d
    # SHOULD WE TEST R12?
    jne while_HW1       # while(next != null)
    
    cmp $1, %r8         
    jnz end_HW1         # if (src_count != 1) return
    cmp $1, %r9         
    jnz end_HW1         # if (dst_count != 1) return
    
    # swapping nodes
    movl $head, %eax
    
    xor %r13, %r13
    cmp %r11d, %eax
    cmovne 8(%r11), %r13    # %r13 = dst_prev->next=dst
    cmove (%r11), %r13
    
    xor %r14, %r14
    cmp %r10d, %eax
    cmovne 8(%r10), %r14    # %r14 = src_prev->next=src
    cmove (%r10), %r14
    
    cmp %r11d, %eax # if (dst_prev == head)
    je src_head_HW1
    mov %r14d, 8(%r11d)
    jmp dst_HW1
src_head_HW1:  
    mov %r14d, (%r11d)
  #  mov %r14, 8(%r11)
dst_HW1:    
    cmp %r10d, %eax
    je dst_head_HW1
    mov %r13d, 8(%r10d)
    jmp next_swap_HW1
dst_head_HW1:
    mov %r13d, (%r10d)
   # mov %r13, 8(%r10)
next_swap_HW1: 
    xor %r15, %r15
    mov 8(%r13), %r15    # %r15 = src->next
    xor %r8, %r8
    mov 8(%r14), %r8    # %r8 = dst->next
    
    #swapping next pointers
    
    mov %r8, 8(%r13)    # dst_ptr->next->next = src_ptr->next->next
    mov %r15, 8(%r14)       # src_ptr->next->next = dst_ptr->next->next


end_HW1:
    nop
