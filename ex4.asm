.global _Start

.section .text
_start:
    mov $root, %rbx     # addr = root
    mov (%rbx), %rax    # val = *addr
    mov new_node, %rdx
recursive_search_HW1:
    # if (val == 0 )
    cmp $0, %rax
    jnz cmp_HW1
    #       *addr = &new_node
    movq $new_node, (%rbx)
    #       return
    jmp end_HW1
cmp_HW1:
    # if (*new_node == val) return
    cmp %rdx, (%rax)
    jz end_HW1
    
    # else if (*new_node > val)
    #       addr = *addr.right
    ja left_son_HW1 
    # else 
    #       addr = *addr.left
    lea 16(%rax), %rbx
    jmp loop_footer_HW1
left_son_HW1:
    lea 8(%rax) , %rbx
    
loop_footer_HW1:
    mov (%rbx), %rax # *addr = val
    jmp recursive_search_HW1
end_HW1:
