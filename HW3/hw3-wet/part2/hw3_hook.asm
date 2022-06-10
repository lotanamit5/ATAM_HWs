.extern _start ,buff

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
  movb $0xd1, (%r8)

/*
  movq $_start, %r8
  add $0x1e, %r8
  mov $hijack, %r9
  sub %r8, %r9
  sub $0x2, %r9
  movb $0xeb, (%r8)
  inc %r8

  movl %r9d, (%r8)
*/
/*
# Edit a.o .text at .data + 0x0
  # we want to insert- buff= call hijack
  # movq $hijack,(buff)
  movq $buff, %r8

  movb $0xff, (%r8)
  inc %r8
  # movb $0x24, (%r8)
  # inc %r8
  movb $0x25, (%r8) 
  inc %r8

  movq $_start, %r9
  sub $hijack, %r9

  movl %r9d, (%r8)

# Edit a.o .text at _start + 0xe1
# 48 83 ee 08             sub    rsi,0x8
# ff d6                   call   *rsi <-> call buff
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
*/

# Jump to _start
  jmp _start  
  
hijack:
/*
  mov $0x1,%rax
  mov $0x1,%rdi
  mov msg,%rsi
  mov endmsg - msg,%rdx

  movq $_start, %r9
  addq $0x26, %r9
  jmpq *%r9
*/

  pushq %rbp
  movq %rsp, %rbp
  mov $0x1,%rax
  mov $0x1,%rdi
  mov $msg,%rsi
  mov $endmsg - msg,%rdx
  syscall
  leave
  ret
