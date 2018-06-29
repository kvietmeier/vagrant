#!/bin/bash
# 
# Ceph preflight
# http://docs.ceph.com/docs/mimic/start/quick-start-preflight/#ceph-node-setup

echo ""
echo "Running preflight.sh"
echo ""

# Install any extra packsages
yum install -y ntp ntpdate ntp-doc
yum install -y openssh-server
yum install -y yum-plugin-priorities

# Create ceph-deploy user - we will could the vagrant user that already exists

# Firewall
firewall-cmd --zone=public --add-service=ceph-mon --permanent
firewall-cmd --zone=public --add-service=ceph --permanent
firewall-cmd --reload

# Setup NTP
# Admin VM is the NTP server
