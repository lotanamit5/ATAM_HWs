.globl my_ili_handler

.text
.align 4, 0x90
my_ili_handler:
  movq -4(%rsp), %r8    # should set %r8 = the original %rip from the stack
  movq (%r8), %r9       # should set %r9 = original instruction (opcode only in this exrecise)
  
  /*
    Q: Are we supposed to save rsp, rbp and add 'leavel before iretq? (I think not...)
    
    TODO:
        > Get the opcode last byte (if the first byte is not 0x0F- it's the last one.
        Otherwise- it's the third one.
        > call (according to calling conventions) to what_to_do
        > Check return value and decide how to finish handeling.
  */                  
  
  
 
  iretq
/*
iret instruction:
return to the code we executed before the interrupt occurred by restoring CS,RIP from the kernel stack.
restoring CS is the action that updates CPL from 0 to 3, as CPL is stored in two bits of CS.
restore RFLAGS from kernel stack.
return to the stack before handling the interrupt by restoring SS, RSP.
if we return to user-mode, the stack will be switched to userland stack.
*/
