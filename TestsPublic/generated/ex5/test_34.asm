# 2<-2
# src: 1
# dst: 2
.global _start
.section .data
src: .quad 1
dst: .quad 2
head:
.quad node1
node1:
.quad 2
.quad node2
node2:
.quad 2
.quad 0
.section .text
mov $node1, %rdx
cmpq $2, (%rdx)
jne bad_exit
cmpq $node2, 8(%rdx)
jne bad_exit
mov $node2, %rdx
cmpq $2, (%rdx)
jne bad_exit
cmpq $0, 8(%rdx)
jne bad_exit
mov $head, %rdx
cmpq $node1, (%rdx)
jne bad_exit
exit:
 movq $60, %rax
movq $0, %rdi
syscall
bad_exit:
movq $60, %rax
movq $1, %rdi
syscall
