#!/bin/bash
# Created by:  Karl Vietmeier
# Basic system setup
#  Could move most of the inline shell provisioner in here but leaving it in the main Vagrantfile
#  as an example.
# NOTE - using redirect to /dev/null with yum to limit output so you won't see any errors
# Script runs as root in the guest


echo ""
echo "###--- Running bootstrap.sh ---###"
echo ""

# Disable SElinux - generally not a good idea but needed for nginx for now
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
setenforce 0

###  - 
# Copy /etc/hosts
echo "###--- Copy /etc/hosts"
if [ -e /home/vagrant/hosts ]
  then 
    sed -i -e 's/\r//g' /home/vagrant/hosts
    cat /home/vagrant/hosts | sudo tee -a /etc/hosts > /dev/null 2>&1
fi     

### ----  For Ceph bootstrap  ---- ###
#awk '/^# Defaults/ && !f {$0=$0 RS "Defaults:cephuser !requiretty";f=1}1' /etc/sudoers
#sed '/^# Defaults/{s/.*/&\Defaults:cephuser !requiretty/;:a;n;ba}' /etc/sudoers
#sed '/^# Defaults/{s/.*/$/\'$'\n''Defaults:cephuser !requiretty/;}' /etc/sudoers

###--- Install any extra packages
# Install some useful tools and update the system
echo "###--- Install some useful utilities"
yum install -y epel-release > /dev/null 2>&1
yum install -y net-tools pciutils wget screen tree traceroute git gcc make python policycoreutils-python nvme-cli > /dev/null 2>&1 
echo "###--- Install isome additional extra packages" 
yum install -y openssh-server > /dev/null 2>&1
yum install -y yum-plugin-priorities > /dev/null 2>&1

###--- Create/modify ceph-deploy user - we could use the vagrant user that already exists
# NOTE - may want to customize the users shell
echo "###--- Adding a User"
useradd -d /home/cephuser -m cephuser 
chown cephuser:cephuser /home/cephuser/
passwd -d cephuser
echo "ceph123" | passwd cephuser --stdin

# Set some sudoers parameters in /etc/sudoers.d/cephuser
echo "Adding  Defaults:cephuser !requiretty to /etc/sudoers.d/cephuser"
echo "cephuser ALL = (root) NOPASSWD:ALL" > /etc/sudoers.d/cephuser
echo "Defaults:cephuser !requiretty" >> /etc/sudoers
sudo chmod 0440 /etc/sudoers.d/cephuser

# - add section to copy in SSH keys
mkdir /home/cephuser/.ssh
chown cephuser:cephuser /home/cephuser/.ssh
chmod 700 /home/cephuser/.ssh
touch /home/cephuser/.ssh/authorized_keys


###--- Firewall check to see if it is running if it is - configure it for Ceph
echo "###--- Configure the firewall"
if $(systemctl is-active --quiet firewalld)
   then
    # Ceph
    firewall-cmd --zone=public --add-service=ceph-mon --permanent
    firewall-cmd --zone=public --add-service=ceph --permanent
    firewall-cmd --reload

    # NTP
    firewall-cmd --add-service=ntp --permanent
    firewall-cmd --reload
fi

###--- Configure NTP - Admin VM is the NTP server
echo "###--- Configure NTP"

yum install -y ntp ntpdate ntp-doc > /dev/null 2>&1

# Set timezone
unlink /etc/localtime
ln -s /usr/share/zoneinfo/US/Pacific /etc/localtime

# Hacks for blocked NTP packets when you can't use ntpdate 
#date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
#date -s "$(curl http://s3.amazonaws.com -v 2>&1 | grep "Date: " | awk '{ print $3 " " $5 " " $4 " " $7 " " $6 " GMT"}')"
# Use a local NTP server
ntpdate -u 172.10.0.10

# Replace time servers with the admin VM
sed -i '0,/^server/s/\(^s.*\)/server 172.10.0.10 prefer iburst/' /etc/ntp.conf

# Remove the extras we don't need
sed -i '/pool.*/s/\(^s.*\)/'$'/' /etc/ntp.conf

# Start ntpd services
systemctl start ntpd
systemctl enable ntpd
if $(systemctl is-active --quiet ntpd)
   then
    echo "NTP is running"
fi

###--- End NTP