.global hamming_weight, negate_first_k, bring_balance_to_the_word, read_input

.section .bss
.lcomm path, 1024

.section .text
read_input:
  pushq %rbp
  movq %rsp, %rbp
  
  pushq %rdi
  lea path(%rip), %rdi
  call get_path
  
  # Now path is the file's path 
  movq $2, %rax     #sys_open
  lea path(%rip), %rdi
  movq $0x002, %rsi #r&w
  syscall
  mov %rax, %r10
  # Now %r10 is the file's descriptor 
  
  lea path(%rip), %r9
  
   
read_num:
  movq $0, %rax     #sys_read
  movq %r10, %rdi   #file descriptor
  movq %r9, %rsi    #We re-use 'path'
  movq $1, %rdx     #We read 1 char 
  syscall

  cmpb $0xa, (%r9)
  jz finish_num
  inc %r9
  jmp read_num
finish_num:
  movq $0x0, (%r9)
  
  pushq %r10
  lea path(%rip), %rdi
  # we are not using rax, rdi, rsi, rdx, rcx, r8-r11- so no need to backup
  call atam_atol # (%rax) = n
  
  popq %r10      # %r10 - fd
  popq %rdi
  
  movq %rdi, %r9    # %r9 - codeword
  movq %rax, %r8    # %r8 - n
  
  movq $0, %rax     #sys_read
  movq %r10, %rdi   #file descriptor
  movq %r9, %rsi    #We are reading to *codeword
  movq %r8, %rdx     #We read n chars
  syscall
  
  shr $3, %r8
  movq %r8, %rax    # %rax = n / 8
  
  leave
  ret

hamming_weight:
  pushq %rbp
  movq %rsp, %rbp
  
  xor %rax, %rax
len_loop:
  movq (%rdi), %rcx
  #internal loop
  xor %rdx, %rdx
rotate_loop:
  cmp $64, %rdx
  jz next_word
  rol %rcx
  inc %rdx
  jnc rotate_loop
  inc %rax
  jmp rotate_loop
  #
next_word:
  addq $8, %rdi
  dec %rsi
  cmp $0, %rsi
  jnz len_loop
  
end_loop:
  leave
  ret


negate_first_k:
  pushq %rbp
  movq %rsp, %rbp
  
  # %rdi - codeword
  # %rsi - k
  cmp $0, %rsi
  jz finish_negate
  movq %rsi, %rcx
  movq $64, %rdx
  sub %rsi, %rdx
  movq %rdi, %r8
  shr %cl, %rdi
  shl %cl, %rdi
  not %r8
  movq %rdx, %rcx
  shl %cl, %r8
  shr %cl, %r8
  or %r8, %rdi  
  
  finish_negate:
  movq %rdi, %rax
  leave
  ret

bring_balance_to_the_word:
  pushq %rbp
  movq %rsp, %rbp
  
  pushq %rdi
  pushq %rsi
  
  movq %rdi, %r11
  movq %rdi, %r12   # %rdi - codeword_ptr
  movq %rsi, %r13   # %rsi - len
  xor %r9, %r9      # %r9 = k
  
k_loop:
  movq %r11, %rdi
  movq %r13, %rsi
  call hamming_weight
  
  movq %r13, %rcx
  shl $5, %rcx
  cmpq %rax, %rcx
  jz finish

  movq (%r12), %rdi
  movq %r9, %rsi
  call negate_first_k
  movq %rax, (%r12)
   
  inc %r9
  cmpq $64, %r9
  jnz next_k
  movq $0, %r9
  movq (%r12),%rcx
  not %rcx
  movq %rcx,(%r12)
  add $8, %r12
  
next_k: 
  movq (%r12), %rdi
  movq %r9, %rsi
  call negate_first_k
  movq %rax, (%r12)
  
  jmp k_loop

finish:
  sub %r11, %r12
  mov %r12, %rax
  shl $3, %rax
  add %r9, %rax
  
  leave
  ret
  
  
  
  
  
  
  
  
  
  
  
  
  
  