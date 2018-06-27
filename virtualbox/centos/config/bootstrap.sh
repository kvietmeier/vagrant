#!/bin/bash
# 
# Install Docker

echo ""
echo "Running bootstrap.sh"
echo ""

###  - 
# Copy /etc/hosts
if [ -e /vagrant/config/hosts ]
  then sudo cat /vagrant/config/hosts >> /etc/hosts
elif [ -e /home/vagrant/sync/files/hosts ]
  then sudo cat /home/vagrant/sync/files/hosts >> /etc/hosts
fi     

# Install container bundle
yum install docker -y

# Start and enable Docker and CC3 services
systemctl enable docker
systemctl start docker