#!/bin/bash
# Created by: Karl Vietmeier
# Install Docker/Clear Containers
# https://github.com/clearcontainers/runtime/blob/master/docs/clearlinux-installation-guide.md

echo ""
echo "Running bootstrap.sh"
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

dos2unix installcerts.sh > /dev/null 2>&1
sudo bash installcerts.sh > /dev/null 2>&1

# Install container bundle
swupd bundle-add containers-virt

# Start and enable Docker and Clear Container services
systemctl enable docker
systemctl start docker
systemctl enable cc3-proxy
systemctl start cc3-proxy