#!/bin/bash
# This does it old schoola and adds users to the sudoers list
# Probably better to use - "newusers /vagrant/userlist.txt"

#

echo "Configuring Admin Node"
echo "Admin" >> /home/vagrant/file.txt

yum install ceph-deploy -y 