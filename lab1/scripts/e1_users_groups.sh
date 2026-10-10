#!/bin/bash
sudo groupadd lab1_groupA
sudo groupadd lab1_groupB
sudo useradd -m -s /bin/bash lab1_user1
sudo useradd -m -s /bin/bash lab1_user2
sudo useradd -m -s /bin/bash lab1_user3
sudo usermod -aG lab1_groupA lab1_user1
sudo usermod -aG lab1_groupA lab1_user2
sudo usermod -aG lab1_groupB lab1_user3
