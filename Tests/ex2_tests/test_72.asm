
.global _start

.section .text

test_start:
    lea source, %rbx
    lea destination, %rcx

    
    movb 0(%rbx), %al
    cmp $133, %al
    jne bad_exit

    movb 1(%rbx), %al
    cmp $90, %al
    jne bad_exit

    movb 2(%rbx), %al
    cmp $25, %al
    jne bad_exit

    movb 3(%rbx), %al
    cmp $105, %al
    jne bad_exit

    movb 4(%rbx), %al
    cmp $28, %al
    jne bad_exit

    movb 5(%rbx), %al
    cmp $204, %al
    jne bad_exit

    movb 6(%rbx), %al
    cmp $163, %al
    jne bad_exit

    movb 7(%rbx), %al
    cmp $59, %al
    jne bad_exit

    movb 8(%rbx), %al
    cmp $156, %al
    jne bad_exit

    movb 9(%rbx), %al
    cmp $244, %al
    jne bad_exit

    movb 10(%rbx), %al
    cmp $88, %al
    jne bad_exit

    movb 11(%rbx), %al
    cmp $125, %al
    jne bad_exit

    movb 12(%rbx), %al
    cmp $92, %al
    jne bad_exit

    movb 13(%rbx), %al
    cmp $170, %al
    jne bad_exit

    movb 14(%rbx), %al
    cmp $70, %al
    jne bad_exit

    movb 15(%rbx), %al
    cmp $126, %al
    jne bad_exit

    movb 16(%rbx), %al
    cmp $20, %al
    jne bad_exit

    movb 17(%rbx), %al
    cmp $120, %al
    jne bad_exit

    movb 18(%rbx), %al
    cmp $2, %al
    jne bad_exit

    movb 19(%rbx), %al
    cmp $72, %al
    jne bad_exit

    movb 20(%rbx), %al
    cmp $233, %al
    jne bad_exit

    movb 0(%rcx), %al
    cmp $133, %al
    jne bad_exit

    movb 1(%rcx), %al
    cmp $90, %al
    jne bad_exit

    movb 2(%rcx), %al
    cmp $25, %al
    jne bad_exit

    movb 3(%rcx), %al
    cmp $105, %al
    jne bad_exit

    movb 4(%rcx), %al
    cmp $28, %al
    jne bad_exit

    movb 5(%rcx), %al
    cmp $204, %al
    jne bad_exit

    movb 6(%rcx), %al
    cmp $163, %al
    jne bad_exit

    movb 7(%rcx), %al
    cmp $59, %al
    jne bad_exit

    movb 8(%rcx), %al
    cmp $156, %al
    jne bad_exit

    movb 9(%rcx), %al
    cmp $244, %al
    jne bad_exit

    movb 10(%rcx), %al
    cmp $88, %al
    jne bad_exit

    movb 11(%rcx), %al
    cmp $125, %al
    jne bad_exit

    movb 12(%rcx), %al
    cmp $92, %al
    jne bad_exit

    movb 13(%rcx), %al
    cmp $170, %al
    jne bad_exit

    movb 14(%rcx), %al
    cmp $70, %al
    jne bad_exit

    movb 15(%rcx), %al
    cmp $126, %al
    jne bad_exit

    movb 16(%rcx), %al
    cmp $19, %al
    jne bad_exit

    movb 17(%rcx), %al
    cmp $86, %al
    jne bad_exit

    movb 18(%rcx), %al
    cmp $239, %al
    jne bad_exit

    movb 19(%rcx), %al
    cmp $90, %al
    jne bad_exit

    movb 20(%rcx), %al
    cmp $250, %al
    jne bad_exit


    movq $60, %rax
    movq $0, %rdi
    syscall

bad_exit:
    movq $60, %rax
    movq $1, %rdi
    syscall

.section .data
num: .long -16
source: .byte 253, 128, 75, 141, 217, 33, 239, 179, 102, 212, 101, 243, 150, 129, 79, 201, 20, 120, 2, 72, 233
destination: .byte 133, 90, 25, 105, 28, 204, 163, 59, 156, 244, 88, 125, 92, 170, 70, 126, 19, 86, 239, 90, 250
