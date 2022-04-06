# 1<-9<-5<-9<-6<-4<-5<-9<-10<-6<-5
# src: 11
# dst: 6
.global _start
.section .data
src: .quad 11
dst: .quad 6
head:
.quad node1
node1:
.quad 5
.quad node2
node2:
.quad 6
.quad node3
node3:
.quad 10
.quad node4
node4:
.quad 9
.quad node5
node5:
.quad 5
.quad node6
node6:
.quad 4
.quad node7
node7:
.quad 6
.quad node8
node8:
.quad 9
.quad node9
node9:
.quad 5
.quad node10
node10:
.quad 9
.quad node11
node11:
.quad 1
.quad 0
.section .text
mov $node1, %rdx
cmpq $5, (%rdx)
jne bad_exit
cmpq $node2, 8(%rdx)
jne bad_exit
mov $node2, %rdx
cmpq $6, (%rdx)
jne bad_exit
cmpq $node3, 8(%rdx)
jne bad_exit
mov $node3, %rdx
cmpq $10, (%rdx)
jne bad_exit
cmpq $node4, 8(%rdx)
jne bad_exit
mov $node4, %rdx
cmpq $9, (%rdx)
jne bad_exit
cmpq $node5, 8(%rdx)
jne bad_exit
mov $node5, %rdx
cmpq $5, (%rdx)
jne bad_exit
cmpq $node6, 8(%rdx)
jne bad_exit
mov $node6, %rdx
cmpq $4, (%rdx)
jne bad_exit
cmpq $node7, 8(%rdx)
jne bad_exit
mov $node7, %rdx
cmpq $6, (%rdx)
jne bad_exit
cmpq $node8, 8(%rdx)
jne bad_exit
mov $node8, %rdx
cmpq $9, (%rdx)
jne bad_exit
cmpq $node9, 8(%rdx)
jne bad_exit
mov $node9, %rdx
cmpq $5, (%rdx)
jne bad_exit
cmpq $node10, 8(%rdx)
jne bad_exit
mov $node10, %rdx
cmpq $9, (%rdx)
jne bad_exit
cmpq $node11, 8(%rdx)
jne bad_exit
mov $node11, %rdx
cmpq $1, (%rdx)
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
