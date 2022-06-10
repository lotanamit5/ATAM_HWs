.extern _start

.global hook, hijack

.section .data
msg: .ascii "This code was hacked by Ella Lee's gang\n"
endmsg:

.section .text
hook:
  lea _start(%rip), %r8
  add $0x1e, %r8            # r8 = &start of NOPs in a.o
  lea hijack(%rip), %r9     # r9 = &hijack
  # 41 ff d1 <-> call *r9 
  movb $0x41, (%r8)
  inc %r8
  movb $0xff, (%r8)
  inc %r8
  movb $0xd1, (%r8)         # "call *r9" = "call hijack" was injected to a.o's text section

# Jump to _start
  jmp _start  
  
hijack:
  pushq %rbp
  movq %rsp, %rbp
  mov $0x1, %rax
  mov $0x1, %rdi
  mov $msg, %rsi
  mov $endmsg - msg, %rdx
  syscall
  leave
  ret
