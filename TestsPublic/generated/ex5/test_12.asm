# 6<-7<-2<-6<-7<-8<-2<-8
# src: 1
# dst: 4
.global _start
.section .data
src: .quad 1
dst: .quad 4
head:
.quad node1
node1:
.quad 8
.quad node2
node2:
.quad 2
.quad node3
node3:
.quad 8
.quad node4
node4:
.quad 7
.quad node5
node5:
.quad 6
.quad node6
node6:
.quad 2
.quad node7
node7:
.quad 7
.quad node8
node8:
.quad 6
.quad 0
.section .text
mov $node1, %rdx
cmpq $8, (%rdx)
jne bad_exit
cmpq $node2, 8(%rdx)
jne bad_exit
mov $node2, %rdx
cmpq $2, (%rdx)
jne bad_exit
cmpq $node3, 8(%rdx)
jne bad_exit
mov $node3, %rdx
cmpq $8, (%rdx)
jne bad_exit
cmpq $node4, 8(%rdx)
jne bad_exit
mov $node4, %rdx
cmpq $7, (%rdx)
jne bad_exit
cmpq $node5, 8(%rdx)
jne bad_exit
mov $node5, %rdx
cmpq $6, (%rdx)
jne bad_exit
cmpq $node6, 8(%rdx)
jne bad_exit
mov $node6, %rdx
cmpq $2, (%rdx)
jne bad_exit
cmpq $node7, 8(%rdx)
jne bad_exit
mov $node7, %rdx
cmpq $7, (%rdx)
jne bad_exit
cmpq $node8, 8(%rdx)
jne bad_exit
mov $node8, %rdx
cmpq $6, (%rdx)
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
