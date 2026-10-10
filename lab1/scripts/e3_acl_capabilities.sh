#!/bin/bash
sudo setfacl -m u:lab1_user3:rx /home/lab1_shared
cd ~/lab1/Labsetup
gcc cap_leak.c -o cap_leak
sudo chown root:root cap_leak
sudo chmod u-s cap_leak
sudo setcap cap_dac_override+ep cap_leak
