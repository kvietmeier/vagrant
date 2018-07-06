#!/bin/bash
# This does it old schoola and adds users to the sudoers list
# Probably better to use - "newusers /vagrant/userlist.txt"

#

echo "Configuring OSD Node"
echo "OSD" >> /home/vagrant/file.txt

#Configure Ceph

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
