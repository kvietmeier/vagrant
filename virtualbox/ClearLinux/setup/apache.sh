#!/bin/bash
# Setup apache on Clear Linux

# Installing Apache
echo "Running apache.sh to install Apache"
echo "swupd bundle-add web-server-basic"
swupd bundle-add web-server-basic > /dev/null 2>&1
systemctl enable httpd.service
systemctl start httpd.service
systemctl restart pacrunner.service
