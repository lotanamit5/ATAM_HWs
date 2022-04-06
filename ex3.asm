#.global _start
.global main
# A = 1,2,3,4,5    B = 4,5,6,7,8  ==> C = 1,2,3,4,5,6,7,8
.section .text
#_start:
main:
#i,j,

#Init:
lea array1, %rax
lea array2, %rbx
lea mergedArray, %rcx

#double-loop 
#check if A[i]==o
#check if B[j]==o
#add smaller if diff
loop_HW1:
    mov (%rax), %r8d
    test %r8d, %r8d
    jz mov_B_HW1
    
    mov (%rbx), %r9d
    test %r9d, %r9d
    jz mov_A_HW1
    
    
mov_A_HW1:
    mov (%rcx), %r10d
    cmp %r8d, %r10d
    jz nextA_HW1
    add $4, %rcx
    mov %r8d, (%rcx) 
nextA_HW1:          
    add $4, %rax
    jmp loop_HW1

#A[i]==0
#if B[j]==0 jump to finish
#else add from B if diff

mov_B_HW1:
    mov (%rbx), %r9d
    test %r9d, %r9d
    jz finish_HW1
    
    mov (%rcx), %r10d
    cmp %r9d, %r10d
    jz nextB_HW1
    add $4, %rcx
    mov %r9d, (%rcx) 
nextB_HW1:          
    add $4, %rbx
    jmp loop_HW1
    
finish_HW1:
