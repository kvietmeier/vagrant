#!/bin/bash
# Created by:  Karl Vietmeier
# Basic system setup
#  Could move most of the inline shell provisioner in here but leaving it in the main Vagrantfile
#  as an example.
# NOTE - using redirect to /dev/null with yum to limit output so you weon't see any errors


echo ""
echo "###--- Running bootstrap.sh ---###"
echo ""

###  - 
# Copy /etc/hosts
echo "###--- Copy /etc/hosts"
if [ -e /vagrant/config/hosts ]
  then sudo cat /vagrant/config/hosts >> /etc/hosts
elif [ -e /home/vagrant/sync/files/hosts ]
  then sudo cat /home/vagrant/sync/files/hosts >> /etc/hosts
fi     

### ----  For Ceph bootstrap  ---- ###
# Install any extra packages
echo "###--- Install any extra packages"
yum install -y openssh-server > /dev/null 2>&1
yum install -y yum-plugin-priorities > /dev/null 2>&1

###--- Create ceph-deploy user - we will could the vagrant user that already exists

###--- Firewall check to see if it is running if it is - configure it
echo "###--- Configure the firewall"
if $(systemctl is-active --quiet firewalld)
   then
    # Ceph
    firewall-cmd --zone=public --add-service=ceph-mon --permanent
    firewall-cmd --zone=public --add-service=ceph --permanent
    firewall-cmd --reload

    # Setup NTP
    # Admin VM is the NTP server
    firewall-cmd --add-service=ntp --permanent
    firewall-cmd --reload
fi

###--- Configure NTP
echo "###--- Configure NTP"

yum install -y ntp ntpdate ntp-doc > /dev/null 2>&1

# Set timezone
unlink /etc/localtime
ln -s /usr/share/zoneinfo/US/Pacific /etc/localtime

# Hacks for blocked NTP packets - can't use ntpdate 
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
systemctl status ntpd
###--- End NTP

