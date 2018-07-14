#!/bin/bash
# Created by: Karl Vietmeier
# Install Docker/Clear Containers
# https://github.com/clearcontainers/runtime/blob/master/docs/clearlinux-installation-guide.md
# This needs lots of work a basic skeleton only

echo ""
echo "Running Clear Linux bootstrap.sh"
echo ""

# Proxies were giving me grief
tee unsetproxy.sh  << EOF > /dev/null 2>&1 
http_proxy=""
https_proxy=""
no_proxy=""
HTTP_PROXY=""
HTTPS_PROXY=""
NO_PROXY=""
export http_proxy https_proxy no_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY
EOF

# A fix for my local mirrors - you won't find these in the git repo
dos2unix installcerts.sh > /dev/null 2>&1
sudo bash installcerts.sh > /dev/null 2>&1

# Install container bundle and things the Vagrant box might be missing
swupd bundle-add containers-virt > /dev/null 2>&1
swupd bundle-add git > /dev/null 2>&1

# Start and enable Docker and Clear Container services
systemctl enable docker
systemctl start docker
systemctl enable cc3-proxy
systemctl start cc3-proxy