#!/bin/bash
# Created by:  Karl Vietmeier
# Configure Ceph Admin Node
#

#NUM_NODES=3


echo ""
echo "Configuring Admin Node"
echo ""
echo "Admin" >> /home/vagrant/file.txt

# Some basic setup stuff
# Create a directory for files
mkdir /home/cephuser/1-cluster
chown cephuser:cephuser /home/cephuser/1-cluster


echo "Install ceph-deploy"
yum install ceph-deploy -y  > /dev/null 2>&1

###---  Configure Ceph

#if [ $NUM_NODES -ge 3 ]; then
#	ceph-deploy new ceph-server-1 ceph-server-2 ceph-server-3
#else
#	ceph-deploy new ceph-server-1
#fi
#
#if [ $NUM_NODES == 1 ]; then
#	tee -a ceph.conf << EOF
#osd pool default size = 1
#osd pool default min size = 1
#osd crush chooseleaf type = 0
#EOF

#elif [ $NUM_NODES == 2 ]; then
#	tee -a ceph.conf << EOF
#osd pool default size = 2
#osd pool default min size = 1
#EOF

#fi

#ceph-deploy mon create-initial
#for x in $(seq 1 $NUM_NODES); do
#	ssh ceph-server-$x sudo ceph-disk list /dev/sda | grep unknown
#	if [ $? -eq 0 ]; then
#		ceph-deploy osd create --zap-disk ceph-server-$x:/dev/sda
#	else
#		ceph-deploy osd create --zap-disk ceph-server-$x:/dev/sdb
#	fi
#done
#ceph-deploy admin localhost


echo ""
echo "Done Configuring Admin Node"
echo ""