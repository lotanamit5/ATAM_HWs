
#  ____4__
# /       \
#0         8___
# \       /    \
#  1     6     _14
#   \         /
#    3       10
#
.global _start
.section .data
node0:
.quad 3
.quad 0
.quad 0
node1:
.quad 1
.quad 0
.quad node0
node2:
.quad 0
.quad 0
.quad node1
node3:
.quad 6
.quad 0
.quad 0
node4:
.quad 10
.quad 0
.quad 0
node5:
.quad 14
.quad node4
.quad 0
node6:
.quad 8
.quad node3
.quad node5
node7:
.quad 4
.quad node2
.quad node6
root:
.quad node7
new_node: .quad 1,0,0
.section .text
mov $node0, %rdx
cmpq $3, (%rdx)
jne bad_exit
cmpq $0, 8(%rdx)
jne bad_exit
cmpq $0, 16(%rdx)
jne bad_exit
mov $node1, %rdx
cmpq $1, (%rdx)
jne bad_exit
cmpq $0, 8(%rdx)
jne bad_exit
cmpq $node0, 16(%rdx)
jne bad_exit
mov $node2, %rdx
cmpq $0, (%rdx)
jne bad_exit
cmpq $0, 8(%rdx)
jne bad_exit
cmpq $node1, 16(%rdx)
jne bad_exit
mov $node3, %rdx
cmpq $6, (%rdx)
jne bad_exit
cmpq $0, 8(%rdx)
jne bad_exit
cmpq $0, 16(%rdx)
jne bad_exit
mov $node4, %rdx
cmpq $10, (%rdx)
jne bad_exit
cmpq $0, 8(%rdx)
jne bad_exit
cmpq $0, 16(%rdx)
jne bad_exit
mov $node5, %rdx
cmpq $14, (%rdx)
jne bad_exit
cmpq $node4, 8(%rdx)
jne bad_exit
cmpq $0, 16(%rdx)
jne bad_exit
mov $node6, %rdx
cmpq $8, (%rdx)
jne bad_exit
cmpq $node3, 8(%rdx)
jne bad_exit
cmpq $node5, 16(%rdx)
jne bad_exit
mov $node7, %rdx
cmpq $4, (%rdx)
jne bad_exit
cmpq $node2, 8(%rdx)
jne bad_exit
cmpq $node6, 16(%rdx)
jne bad_exit
mov $root, %rdx
cmpq $node7, (%rdx)
jne bad_exit
exit:
 movq $60, %rax
movq $0, %rdi
syscall
bad_exit:
movq $60, %rax
movq $1, %rdi
syscall
