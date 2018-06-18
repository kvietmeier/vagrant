#!/bin/bash
# 
# Install Docker

echo ""
echo "Running bootstrap.sh"
echo ""

# Install container bundle
yum install docker -y

# Start and enable Dockre and CC3 services
systemctl enable docker
systemctl start docker