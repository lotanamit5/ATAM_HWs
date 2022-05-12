.global hamming_weight, negate_first_k, bring_balance_to_the_word, read_input

.section .bss
.lcomm path, 1024

.section .text
read_input:
  ret
.global hamming_weight, negate_first_k, bring_balance_to_the_word, read_input

.section .bss
.lcomm path, 1024
#.lcomm num_in_ascii, 8

.section .text
read_input:
  pushq %rbp
  movq %rsp, %rbp
  
  pushq %rdi
  lea path(%rip), %rdi
  call get_path
  popq %rdi
  
  # Now path is the file's path 
  
  movq $2, %rax     #sys_open
  movq $path, %rdi
  movq $0x002, %rsi #r&w
  syscall
  mov %rax, %r10
  # Now %r10 is the file's descriptor 
  
  xor %rdx, %rdx
   
read_num:
  movq $2, %rax     #sys_read
  movq %r10, %rdi   #file descriptor
  movq $path, %rsi  #We re-use 'path'. This time the we store one char at a time.
  movq $1, %rdx     #We read 1 char 
  syscall
  
  cmpb $0xa, (path)
  jz finish_num
  jmp read_num
finish_num:
  movq $0x0, (path)
  movq $1, %rax     #sys_write
  movq %r10, %rdi   #file descriptor
  movq $path, %rsi  #We re-use 'path' again
  movq $1, %rdx     #We read 1 char 
  syscall
  
/*  lea num_in_ascii(%rip), %r11
loop_num:
  mov (%r10), %cl
  cmp $0xa, %cl
  jz finish_num
  movb %cl, (%r11)
  inc %r10
  inc %r11
  jmp loop_num
finish_num:
  movq $0x0, (%r11)
  */

  
  pushq %rdi
  pushq %r10
  lea path(%rip), %rdi
    # we are not using rax, rdi, rsi, rdx, rcx, r8-r11- so no need to backup
  call atam_atol # (%rax) = n
  popq %r10
  inc %r10 # restoring and updating the counter
  popq %rdi
  
  mov %rax, %r9  
  xor %rcx, %rcx
loop_code:
  cmp $0x0, %r9
  jz finish_code
  mov (%r10), %cl
  movb %cl, (%rdi)
  inc %r10
  inc %rdi
  dec %r9
  jmp loop_code
finish_code:
  shr $3, %rax
  
  leave
  ret

hamming_weight:
  ret

negate_first_k:
  ret

bring_balance_to_the_word:
  ret

hamming_weight:
  ret

negate_first_k:
  ret

bring_balance_to_the_word:
  ret
