.global main
#hi
.section .data
destination: .short 0xCAFE
source: .quad 0xAABBCCDD
num: .long 0x3

.section .text
main:
    xor %rcx, %rcx      #rcx = 0
    xor %rdx, %rdx      #rdx = 0
    mov (num), %ecx     #ecx = num
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
    test %ecx, %ecx
    jz finish
    #move 1 byte from src to dst:  
    movb (%rax), %dl
    movb %dl, (%rbx)
    dec %rax
    dec %rbx
    dec %ecx
    jmp loop_HW1
finish:

