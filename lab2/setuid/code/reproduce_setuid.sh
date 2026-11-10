#!/bin/bash
set -e

echo "[1/3] Desactivation de l'ASLR (configuration de reference E3)"
sudo sysctl -w kernel.randomize_va_space=0

echo "[2/3] Contournement de la protection de dash (lien /bin/sh -> /bin/zsh)"
sudo ln -sf /bin/zsh /bin/sh
ls -l /bin/sh

echo "[3/3] Compilation des binaires Set-UID root (stack-L1 a stack-L4)"
make

echo
echo "Verification des binaires :"
ls -l stack-L1 stack-L2 stack-L3 stack-L4

echo
echo "Environnement pret. ASLR = $(sysctl -n kernel.randomize_va_space)"
