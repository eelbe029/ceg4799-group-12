#!/bin/bash
set -e

echo "[E2] Assemblage des shellcodes 64 bits (nasm + ld)"
make
ls -l hello mysh64 another_sh64

echo
echo "[E2] Desassemblage de mysh64 (code machine)"
objdump -Mintel -d mysh64

echo
echo "[E2] Verification de l'absence d'octets nuls"
objdump -d mysh64 | grep -i " 00 " || echo "Aucun octet nul dans le code machine"

echo
echo "Test manuel : ./mysh64 doit ouvrir un shell (tapez id puis exit)."
