.extern _start, buff

.global hook, hijack

.section .data
msg: .ascii "This code was hacked by Ella Lee's gang\n"
endmsg:

.section .text
hook:
  push %r8
  lea _start(%rip), %r8
  add $0x1e, %r8            # r8 = &start of NOPs in a.o
  # c3 <-> return 
  movb $0xc3, (%r8)         # "return" was injected to a.o's text section
  pop %r8
  
  call _start               # Will return after first print
  
hijack:  
  push %rax                 # Saving all caller-saved regs 
  push %rdi
  push %rsi
  push %rdx
  push %rcx
  push %r8
  push %r9
  push %r10
  push %r11

  mov $0x1, %rax            # Printing our msg
  mov $0x1, %rdi
  lea msg(%rip), %rsi
  mov $endmsg - msg, %rdx
  syscall
  
  lea _start(%rip), %r8
  add $0x26, %r8            
  mov %r8, buff             # (buff) = &end of NOPs in a.o

  pop %r11                  # Restoring state
  pop %r10
  pop %r9
  pop %r8
  pop %rcx
  pop %rdx
  pop %rsi
  pop %rdi
  pop %rax

  jmp *buff                 # Use a.o data to jump back to code
