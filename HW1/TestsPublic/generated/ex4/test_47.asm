
#        ________13
#       /          \
#    __5__          14
#   /     \
#  1       11
# / \     /  \
#0   2   7    12
#
.global _start
.section .data
node0:
.quad 0
.quad 0
.quad 0
node1:
.quad 2
.quad 0
.quad 0
node2:
.quad 1
.quad node0
.quad node1
node3:
.quad 7
.quad 0
.quad 0
node4:
.quad 12
.quad 0
.quad 0
node5:
.quad 11
.quad node3
.quad node4
node6:
.quad 5
.quad node2
.quad node5
node7:
.quad 14
.quad 0
.quad 0
node8:
.quad 13
.quad node6
.quad node7
root:
.quad node8
new_node: .quad 26,0,0
.section .text
mov $node0, %rdx
cmpq $0, (%rdx)
jne bad_exit
cmpq $0, 8(%rdx)
jne bad_exit
cmpq $0, 16(%rdx)
jne bad_exit
mov $node1, %rdx
cmpq $2, (%rdx)
jne bad_exit
cmpq $0, 8(%rdx)
jne bad_exit
cmpq $0, 16(%rdx)
jne bad_exit
mov $node2, %rdx
cmpq $1, (%rdx)
jne bad_exit
cmpq $node0, 8(%rdx)
jne bad_exit
cmpq $node1, 16(%rdx)
jne bad_exit
mov $node3, %rdx
cmpq $7, (%rdx)
jne bad_exit
cmpq $0, 8(%rdx)
jne bad_exit
cmpq $0, 16(%rdx)
jne bad_exit
mov $node4, %rdx
cmpq $12, (%rdx)
jne bad_exit
cmpq $0, 8(%rdx)
jne bad_exit
cmpq $0, 16(%rdx)
jne bad_exit
mov $node5, %rdx
cmpq $11, (%rdx)
jne bad_exit
cmpq $node3, 8(%rdx)
jne bad_exit
cmpq $node4, 16(%rdx)
jne bad_exit
mov $node6, %rdx
cmpq $5, (%rdx)
jne bad_exit
cmpq $node2, 8(%rdx)
jne bad_exit
cmpq $node5, 16(%rdx)
jne bad_exit
mov $node7, %rdx
cmpq $14, (%rdx)
jne bad_exit
cmpq $0, 8(%rdx)
jne bad_exit
cmpq $new_node, 16(%rdx)
jne bad_exit
mov $node8, %rdx
cmpq $13, (%rdx)
jne bad_exit
cmpq $node6, 8(%rdx)
jne bad_exit
cmpq $node7, 16(%rdx)
jne bad_exit
mov $root, %rdx
cmpq $node8, (%rdx)
jne bad_exit
exit:
 movq $60, %rax
movq $0, %rdi
syscall
bad_exit:
movq $60, %rax
movq $1, %rdi
syscall
