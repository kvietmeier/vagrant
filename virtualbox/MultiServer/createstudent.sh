#!/bin/bash

newusers /vagrant/userlist.txt

for i in $(cat /vagrant/userlist.txt | awk -F ":" '{print $1}')
  do  
    cp .bashrc .bash_profile /home/$i
    chown $i:wheel /home/${i}/.bashrc
    chown $i:wheel /home/${i}/.bash_profile
  done
