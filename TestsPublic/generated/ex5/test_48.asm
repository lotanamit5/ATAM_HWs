# 9<-9<-7<-18<-7<-7<-8<-8<-1<-3<-16<-16<-15<-21<-6<-10<-14<-23<-10<-12<-3<-10<-12<-16
# src: 7
# dst: 4
.global _start
.section .data
src: .quad 7
dst: .quad 4
head:
.quad node1
node1:
.quad 16
.quad node2
node2:
.quad 12
.quad node3
node3:
.quad 10
.quad node4
node4:
.quad 3
.quad node5
node5:
.quad 12
.quad node6
node6:
.quad 10
.quad node7
node7:
.quad 23
.quad node8
node8:
.quad 14
.quad node9
node9:
.quad 10
.quad node10
node10:
.quad 6
.quad node11
node11:
.quad 21
.quad node12
node12:
.quad 15
.quad node13
node13:
.quad 16
.quad node14
node14:
.quad 16
.quad node15
node15:
.quad 3
.quad node16
node16:
.quad 1
.quad node17
node17:
.quad 8
.quad node18
node18:
.quad 8
.quad node19
node19:
.quad 7
.quad node20
node20:
.quad 7
.quad node21
node21:
.quad 18
.quad node22
node22:
.quad 7
.quad node23
node23:
.quad 9
.quad node24
node24:
.quad 9
.quad 0
.section .text
mov $node1, %rdx
cmpq $16, (%rdx)
jne bad_exit
cmpq $node2, 8(%rdx)
jne bad_exit
mov $node2, %rdx
cmpq $12, (%rdx)
jne bad_exit
cmpq $node3, 8(%rdx)
jne bad_exit
mov $node3, %rdx
cmpq $10, (%rdx)
jne bad_exit
cmpq $node4, 8(%rdx)
jne bad_exit
mov $node4, %rdx
cmpq $3, (%rdx)
jne bad_exit
cmpq $node5, 8(%rdx)
jne bad_exit
mov $node5, %rdx
cmpq $12, (%rdx)
jne bad_exit
cmpq $node6, 8(%rdx)
jne bad_exit
mov $node6, %rdx
cmpq $10, (%rdx)
jne bad_exit
cmpq $node7, 8(%rdx)
jne bad_exit
mov $node7, %rdx
cmpq $23, (%rdx)
jne bad_exit
cmpq $node8, 8(%rdx)
jne bad_exit
mov $node8, %rdx
cmpq $14, (%rdx)
jne bad_exit
cmpq $node9, 8(%rdx)
jne bad_exit
mov $node9, %rdx
cmpq $10, (%rdx)
jne bad_exit
cmpq $node10, 8(%rdx)
jne bad_exit
mov $node10, %rdx
cmpq $6, (%rdx)
jne bad_exit
cmpq $node11, 8(%rdx)
jne bad_exit
mov $node11, %rdx
cmpq $21, (%rdx)
jne bad_exit
cmpq $node12, 8(%rdx)
jne bad_exit
mov $node12, %rdx
cmpq $15, (%rdx)
jne bad_exit
cmpq $node13, 8(%rdx)
jne bad_exit
mov $node13, %rdx
cmpq $16, (%rdx)
jne bad_exit
cmpq $node14, 8(%rdx)
jne bad_exit
mov $node14, %rdx
cmpq $16, (%rdx)
jne bad_exit
cmpq $node15, 8(%rdx)
jne bad_exit
mov $node15, %rdx
cmpq $3, (%rdx)
jne bad_exit
cmpq $node16, 8(%rdx)
jne bad_exit
mov $node16, %rdx
cmpq $1, (%rdx)
jne bad_exit
cmpq $node17, 8(%rdx)
jne bad_exit
mov $node17, %rdx
cmpq $8, (%rdx)
jne bad_exit
cmpq $node18, 8(%rdx)
jne bad_exit
mov $node18, %rdx
cmpq $8, (%rdx)
jne bad_exit
cmpq $node19, 8(%rdx)
jne bad_exit
mov $node19, %rdx
cmpq $7, (%rdx)
jne bad_exit
cmpq $node20, 8(%rdx)
jne bad_exit
mov $node20, %rdx
cmpq $7, (%rdx)
jne bad_exit
cmpq $node21, 8(%rdx)
jne bad_exit
mov $node21, %rdx
cmpq $18, (%rdx)
jne bad_exit
cmpq $node22, 8(%rdx)
jne bad_exit
mov $node22, %rdx
cmpq $7, (%rdx)
jne bad_exit
cmpq $node23, 8(%rdx)
jne bad_exit
mov $node23, %rdx
cmpq $9, (%rdx)
jne bad_exit
cmpq $node24, 8(%rdx)
jne bad_exit
mov $node24, %rdx
cmpq $9, (%rdx)
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
