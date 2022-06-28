.global _start, get_password_function

.section .rodata
success_message: .ascii "You have been hacked!\n"
.data
get_password_function: .zero 8

.text
_start:
    callq get_function
    callq hack
    callq print_success
	
    movq $60, %rax
    movq (secret_password), %rdi
    syscall

my_strlen:  
    push %rbp
    mov %rsp, %rbp
    
    mov $success_message, %rbx
    xor %rcx, %rcx
    check:
        mov (%rbx), %cl
        cmp $0, %cl
        je end

        inc %rbx
        jmp check

    end:
        sub $success_message, %rbx
        mov %rbx, %rax
        pop %rbp
        ret

print_success:
    push %rbp
    mov %rsp, %rbp

    call my_strlen
    mov %rax, %rdx
    mov $1, %rax
    mov $1, %rdi
    mov $success_message, %rsi
    syscall

    pop %rbp
    ret
