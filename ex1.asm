.global _start

#.section .data
#num: .quad 3325516014163340454
#CountBits: .zero 4

.section .text
_start:
    xor %eax, %eax      # eax (counter) = 0
    mov (num), %rbx     # rbx = num
    mov $64, %ecx       # size = 64
    
loop_HW1:
    shr %rbx
    jnc cmp_HW1
    inc %eax
cmp_HW1:    
    dec %ecx
    jnz loop_HW1
    
    mov %eax, (CountBits)
    
    