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

### Doing bad things 
# Disable SElinux - generally not a good idea but needed for nginx for now
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
setenforce 0

# Enable password authentication
sed -i "s/^PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
systemctl restart sshd 

# Disable strict hostkey checking for root and vagrant
tee ~/.ssh/config << EOF > /dev/null 2>&1
# Set some SSH defaults 

Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null

EOF
chmod 600 ~/.ssh/config

tee /home/vagrant/.ssh/config << EOF > /dev/null 2>&1
# Set some SSH defaults 

Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null

EOF
chown vagrant:vagrant /home/vagrant/.ssh/config
chmod 600 /home/vagrant/.ssh/config


###--- System file setup 
# Copy /etc/hosts
echo "###--- Copy /etc/hosts"
if [ -e /home/vagrant/hosts ]
  then 
    sed -i -e 's/\r//g' /home/vagrant/hosts
    cat /home/vagrant/hosts | sudo tee -a /etc/hosts > /dev/null 2>&1
    rm -f /home/vagrant/hosts
fi     


###--- Install any extra packages
# Install some useful tools and update the system
echo "###--- Install some useful utilities"
yum install -y epel-release > /dev/null 2>&1
yum install -y net-tools pciutils wget screen tree traceroute git gcc make python policycoreutils-python nvme-cli > /dev/null 2>&1 
echo "###--- Install some additional extra packages" 
yum install -y openssh-server sshpass yum-plugin-priorities > /dev/null 2>&1

# Update everything
#yum update -y 2>&1

# Update the man pages
catman > /dev/null 2>&1


###--- Create/modify an additional user account
# NOTE - may want to customize the users shell
echo "###--- Adding a User"
useradd -d /home/labuser1 -m labuser1 
chown labuser1:labuser1 /home/labuser1/
passwd -d labuser1
echo "labuser1" | passwd labuser1 --stdin

# Set some sudoers parameters in /etc/sudoers.d/labuser1
echo "Adding  Defaults:labuser1 !requiretty to /etc/sudoers.d/labuser1"
echo "labuser1 ALL = (root) NOPASSWD:ALL" > /etc/sudoers.d/labuser1
echo "Defaults:labuser1 !requiretty" >> /etc/sudoers
sudo chmod 0440 /etc/sudoers.d/labuser1

# - Configure SSH
mkdir /home/labuser1/.ssh
chown labuser1:labuser1 /home/labuser1/.ssh
chmod 700 /home/labuser1/.ssh

touch /home/labuser1/.ssh/authorized_keys
chown labuser1:labuser1 /home/labuser1/.ssh/authorized_keys
chmod 700 /home/labuser1/.ssh/authorized_keys

tee /home/labuser1/.ssh/config << EOF > /dev/null 2>&1
# Set some SSH defaults 

Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null

EOF
chown labuser1:labuser1 /home/labuser1/.ssh/config
chmod 600 /home/labuser1/.ssh/config

# Generate a key for the user
su - labuser1 --command "ssh-keygen -t rsa -N \"\" -f ~/.ssh/id_rsa" > /dev/null 2>&1

# For vagrant user too 
su - vagrant --command "ssh-keygen -t rsa -N \"\" -f ~/.ssh/id_rsa" > /dev/null 2>&1

###---- End User create section

###--- Firewall check to see if it is running if it is - configure it for NTP
echo "###--- Configure the firewall"
if $(systemctl is-active --quiet firewalld)
   then
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