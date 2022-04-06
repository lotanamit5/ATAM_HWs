
.global _start

.section .text

# tree layout: (new_node value will be surrounded by | | if inserted)
#                  _______299_________               
#                 /                   \              
#            ____155_               _406_______      
#           /        \             /           \     
#       ___135_     273_        __375     ____445_   
#      /       \        \      /         /        \  
#     45_     151      290   |340|      414_     462 
#    /   \                                  \        
#   15  117                                442       
#  /                                                 
#  3                                                

test_start:
    
    cmpq $299, (node_0)
    jne bad_exit
    cmpq $node_1, (node_0+8)
    jne bad_exit
    cmpq $node_3, (node_0+16)
    jne bad_exit

    cmpq $155, (node_1)
    jne bad_exit
    cmpq $node_5, (node_1+8)
    jne bad_exit
    cmpq $node_2, (node_1+16)
    jne bad_exit

    cmpq $273, (node_2)
    jne bad_exit
    cmpq $0, (node_2+8)
    jne bad_exit
    cmpq $node_8, (node_2+16)
    jne bad_exit

    cmpq $406, (node_3)
    jne bad_exit
    cmpq $node_6, (node_3+8)
    jne bad_exit
    cmpq $node_4, (node_3+16)
    jne bad_exit

    cmpq $445, (node_4)
    jne bad_exit
    cmpq $node_13, (node_4+8)
    jne bad_exit
    cmpq $node_10, (node_4+16)
    jne bad_exit

    cmpq $135, (node_5)
    jne bad_exit
    cmpq $node_7, (node_5+8)
    jne bad_exit
    cmpq $node_11, (node_5+16)
    jne bad_exit

    cmpq $375, (node_6)
    jne bad_exit
    cmpq $new_node, (node_6+8)
    jne bad_exit
    cmpq $0, (node_6+16)
    jne bad_exit

    cmpq $45, (node_7)
    jne bad_exit
    cmpq $node_9, (node_7+8)
    jne bad_exit
    cmpq $node_14, (node_7+16)
    jne bad_exit

    cmpq $290, (node_8)
    jne bad_exit
    cmpq $0, (node_8+8)
    jne bad_exit
    cmpq $0, (node_8+16)
    jne bad_exit

    cmpq $15, (node_9)
    jne bad_exit
    cmpq $node_12, (node_9+8)
    jne bad_exit
    cmpq $0, (node_9+16)
    jne bad_exit

    cmpq $462, (node_10)
    jne bad_exit
    cmpq $0, (node_10+8)
    jne bad_exit
    cmpq $0, (node_10+16)
    jne bad_exit

    cmpq $151, (node_11)
    jne bad_exit
    cmpq $0, (node_11+8)
    jne bad_exit
    cmpq $0, (node_11+16)
    jne bad_exit

    cmpq $3, (node_12)
    jne bad_exit
    cmpq $0, (node_12+8)
    jne bad_exit
    cmpq $0, (node_12+16)
    jne bad_exit

    cmpq $414, (node_13)
    jne bad_exit
    cmpq $0, (node_13+8)
    jne bad_exit
    cmpq $node_15, (node_13+16)
    jne bad_exit

    cmpq $117, (node_14)
    jne bad_exit
    cmpq $0, (node_14+8)
    jne bad_exit
    cmpq $0, (node_14+16)
    jne bad_exit

    cmpq $442, (node_15)
    jne bad_exit
    cmpq $0, (node_15+8)
    jne bad_exit
    cmpq $0, (node_15+16)
    jne bad_exit

    cmpq $442, (new_node)
    jne bad_exit
    cmpq $0, (new_node+8)
    jne bad_exit
    cmpq $0, (new_node+16)
    jne bad_exit


    movq $60, %rax
    movq $0, %rdi
    syscall

bad_exit:
    movq $60, %rax
    movq $1, %rdi
    syscall

.section .data
root:
 .quad node_0
node_0:
 .quad 299
 .quad node_1
 .quad node_3
node_1:
 .quad 155
 .quad node_5
 .quad node_2
node_2:
 .quad 273
 .quad 0
 .quad node_8
node_3:
 .quad 406
 .quad node_6
 .quad node_4
node_4:
 .quad 445
 .quad node_13
 .quad node_10
node_5:
 .quad 135
 .quad node_7
 .quad node_11
node_6:
 .quad 375
 .quad new_node
 .quad 0
node_7:
 .quad 45
 .quad node_9
 .quad node_14
node_8:
 .quad 290
 .quad 0
 .quad 0
node_9:
 .quad 15
 .quad node_12
 .quad 0
node_10:
 .quad 462
 .quad 0
 .quad 0
node_11:
 .quad 151
 .quad 0
 .quad 0
node_12:
 .quad 3
 .quad 0
 .quad 0
node_13:
 .quad 414
 .quad 0
 .quad node_15
node_14:
 .quad 117
 .quad 0
 .quad 0
node_15:
 .quad 442
 .quad 0
 .quad 0
new_node:
 .quad 442
 .quad 0
 .quad 0

