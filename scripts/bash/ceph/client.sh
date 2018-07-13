#!/bin/bash
# This does it old schoola and adds users to the sudoers list
# Probably better to use - "newusers /vagrant/userlist.txt"

#

echo ""
echo "Configuring Client Node"
echo "Client" >> /home/vagrant/file.txt

yum install ceph-common -y  > /dev/null 2>&1

### We want Docker running on the clients.
# Install container bundle
yum install docker -y > /dev/null 2>&1

# Start and enable Docker services
systemctl enable docker
systemctl start docker

### Done with Docker

echo ""
echo "Done Configuring Client Node"
echo ""