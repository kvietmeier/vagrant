#!/bin/bash
# 
# Install Docker/CContatiners
# https://github.com/clearcontainers/runtime/blob/master/docs/clearlinux-installation-guide.md

echo ""
echo "Running bootstrap.sh"
echo ""

# Install container bundle
swupd bundle-add containers-virt

# Start and enable Dockre and CC3 services
systemctl enable docker
systemctl start docker
systemctl enable cc3-proxy
systemctl start cc3-proxy