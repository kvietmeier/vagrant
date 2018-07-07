#!/bin/bash
# Created by:  Karl Vietmeier
# Configure Ceph Admin Node
#

echo ""
echo "Configuring Admin Node"
echo ""
echo "Admin" >> /home/vagrant/file.txt

echo "Install ceph-deploy"
yum install ceph-deploy -y  > /dev/null 2>&1


echo ""
echo "Done Configuring Admin Node"
echo ""