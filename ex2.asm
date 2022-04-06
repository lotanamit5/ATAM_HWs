#.global main
.global _start

#.section .data
#num: .long 23
#source: .byte 28, 131, 59, 236, 130, 123, 11, 89, 164, 179, 66, 57, 105, 52, 149, 127, 238, 116, 239, 107, 42, 73
#destination: .byte 9, 172, 210, 96, 118, 134, 73, 228, 107, 95, 147, 250, 111, 68, 129, 240, 47, 31, 129, 19, 76, 140, 71, 161, 231, 13, 249

.section .text
_start:
    xor %rcx, %rcx #rcx = 0
    xor %rdx, %rdx #rdx = 0
    mov (num), %ecx #ecx = num
    test %ecx, %ecx
    jns pos_HW1
neg_HW1:
    lea destination, %rax
    lea source, %rbx
    
    xor $-1, %ecx 
    inc %ecx #ecx = |num|
    
    jmp init_HW1
pos_HW1:
    lea source, %rax
    lea destination, %rbx
init_HW1:
    add %rcx, %rax
    dec %rax
    add %rcx, %rbx
    dec %rbx
loop_HW1:  
    movb (%rax), %dl
    movb %dl, (%rbx)
    
    dec %rax
    dec %rbx
    
    dec %ecx
    jnz loop_HW1
    