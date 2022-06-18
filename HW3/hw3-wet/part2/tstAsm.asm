.section .text
hook:
# Edit a.o .text at .data + 0x0
  # we want to insert- buff= call hijack
  movq $hijack,(buff)

# Edit a.o .text at _start + 0xe1
# 48 83 ee 08             sub    rsi,0x8
# ff d6                   call   rsi <-> call *buff
  movq $_start, %r8
  add $0x1e, %r8
  movb $0x48, (%r8)
  inc %r8
  movb $0x83, (%r8)
  inc %r8
  movb $0xee, (%r8)
  inc %r8
  movb $0x08, (%r8)
  inc %r8
  movb $0xff, (%r8)
  inc %r8
  movb $0xd6, (%r8)

# Jump to _start
  jmp _start  
  
hijack:
  pushq %rbp
  movq %rsp, %rbp
  mov $0x1,%rax
  mov $0x1,%rdi
  mov msg,%rsi
  
