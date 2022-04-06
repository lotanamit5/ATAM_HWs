.global _start
#.global main
.section .text
_start:
#main:
    lea array1, %eax
    lea array2, %ebx
    lea mergedArray, %ecx
    mov $0, %edx
loop_HW1:
    mov (%eax), %r8d
    test %r8d, %r8d
    jz mov_B_HW1
    
    mov (%ebx), %r9d
    test %r9d, %r9d
    jz mov_A_HW1
    
    cmp %r8d, %r9d
    ja mov_B_HW1
    
mov_A_HW1:
    cmp %r8d, %edx #C[i+j]-A[i]
    jz nextA_HW1
    mov %r8d, (%ecx) 
    add $4, %ecx
    mov %r8d, %edx
nextA_HW1:          
    add $4, %eax
    jmp loop_HW1

mov_B_HW1:
    mov (%ebx), %r9d
    test %r9d, %r9d
    jz finish_HW1
    
    cmp %r9d, %edx #C[i+j]-B[j]
    jz nextB_HW1
    mov %r9d, (%ecx) 
    add $4, %ecx
    mov %r9d, %edx
nextB_HW1:          
    add $4, %ebx
    jmp loop_HW1
    
finish_HW1:
    movl $0, (%ecx)

