#!/bin/bash
# Created by:  Karl Vietmeier
### Install and configure Docker

# Install latest docker-ce from the Docker repo (versions in the standard repos are old)
#yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#yum-config-manager --enable docker-ce-edge
#yum install -y docker-ce
#yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo > /dev/null 2>&1
#yum-config-manager --enable docker-ce-edge > /dev/null 2>&1
#yum install -y docker-ce > /dev/null 2>&1

# Install Docker from the epel repo
yum install docker -y


# Enable the vagrant user to run Docker commands
usermod -aG docker vagrant
usermod -aG docker labuser1

# To fix proxxy issue
#mkdir /etc/systemd/system/docker.service.d

#vi /etc/systemd/system/docker.service.d/http-proxy.conf

#[Service]
#Environment="HTTP_PROXY=http://proxy-chain.intel.com:911"

#vi /etc/systemd/system/docker.service.d/https-proxy.conf
#[Service]
#Environment="HTTPS_PROXY=https://proxy-chain.intel.com:912"

# Start and enable Docker services
systemctl enable docker
systemctl start docker