.globl my_ili_handler

.text
.align 4, 0x90
my_ili_handler:
  pushq %rbp
  movq %rsp, %rbp
  
  pushq %r9
  pushq %rax
  pushq %r8
  pushq %rdi
  
  movq 0x8(%rbp), %r8    # should set %r8 = the original %rip from the stack
  movb (%r8), %dil       # dil <- first byte of %rip
  movq $1, %r9           # r9 <- num of bytes in op                                       
  cmp $0x0f, %dil 
  je two_byte_op_HW2
  jmp call_wtd_HW2
  
two_byte_op_HW2:
  movb 1(%r8), %dil
  movq $2, %r9
  
call_wtd_HW2:
  pushq %r9
  call what_to_do
  popq %r9
  
  popq %rdi
  popq %r8
  
  cmp $0, %rax
  jne end_HW2
  
  popq %rax 
  popq %r9
  popq %rbp
  jmp *old_ili_handler                
  
end_HW2: 
  add %r9, 8(%rbp)  #move offset of %rip
  mov %rax, %rdi
  
  popq %rax 
  popq %r9
  popq %rbp
  iretq
    /*
    iret instruction:
    return to the code we executed before the interrupt occurred by restoring CS,RIP from the kernel stack.
    restoring CS is the action that updates CPL from 0 to 3, as CPL is stored in two bits of CS.
    restore RFLAGS from kernel stack.
    return to the stack before handling the interrupt by restoring SS, RSP.
    if we return to user-mode, the stack will be switched to userland stack.
    */
