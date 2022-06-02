.extern _start ,buff

.global hook, hijack

.section .data
msg: .ascii "This code was hacked by Ella Lee's gang\n"
endmsg:

.section .text
hook:
  movq $60, %rax
  movq $0, %rdi
  syscall

#Edit a.o .text at .data + 0x0
  #movq hijack,(buff)

#Edit a.o .text at _start + 0xe1

  movq _start, %r8
  add 0xe1, %r8
  call (msg)

#Jump to _start
  jmp _start  
  
hijack:
  pushq %rbp
  movq %rsp, %rbp
  mov $0x1,%rax
  mov $0x1,%rdi
  mov msg,%rsi
  mov endmsg - msg,%rdx
  leave
  ret
