#!/bin/bash
###--------------------------------------------------------------------------------------------------###
# bootstrap.sh
# Created by:  Karl Vietmeier
# Basic system setup for most applications
#  Could move most of the inline shell provisioner in here but leaving it in the main Vagrantfile
#  as an example.
#
# NOTE - using redirect to /dev/null with yum to limit output so you won't see any errors
# Script runs as root in the guest
# It does some bad stuff like disable selinux and firewalld.
###--------------------------------------------------------------------------------------------------###

echo ""
echo "###---------------------- Running bootstrap.sh ------------------------###"
echo ""

###---
###--- Basic system and SSH configuration
###---

# Disable SElinux - generally not a good idea but needed for nginx for now
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
setenforce 0

# Enable password authentication in /etyc/sshd_config
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


###---
###--- System file setup 
###---
# Copy /etc/hosts
echo "###--- Copy /etc/hosts"
if [ -e /home/vagrant/hosts ]
  then 
    sed -i -e 's/\r//g' /home/vagrant/hosts
    cat /home/vagrant/hosts | sudo tee -a /etc/hosts > /dev/null 2>&1
    rm -f /home/vagrant/hosts
fi     


###---
###--- Install any extra packages
###---

# Install some useful tools and update the system
echo "###--- Install some useful utilities"
yum install -y epel-release dos2unix net-tools pciutils wget screen tree traceroute git gcc make python policycoreutils-python nvme-cli > /dev/null 2>&1 
echo "###--- Install some additional extra packages" 
yum install -y openssh-server dos2unix sshpass yum-plugin-priorities vim-enhanced > /dev/null 2>&1

### Use this if you want to only install missing packages
### NOTE - you need the exact name of the package - not the short name.
#pkgs=(epel-release net-tools pciutils wget screen tree traceroute git gcc make python policycoreutils-python nvme-cli openssh-server sshpass yum-plugin-priorities vim-enhanced)
#for pkg in  ${pkgs[*]}
# do
#  echo "Checking $pkg"
#  #isinstalled=$(yum -q list installed $pkg)
#  yum -q list installed $pkg > /dev/null 2>&1
#  INSTALLED=$?
#  if [ $INSTALLED -eq 1 ];
#   then
#    echo "Need to install $pkg"
#    yum install $pkg -y  > /dev/null 2>&1
#  else
#    echo "Package $pkg already installed"
#    yum remove $pkg -y > /dev/null 2>&1
#  fi
#done

# Update everything
#yum update -y 2>&1

# Update the man pages
catman > /dev/null 2>&1
###--- End packages


###
###--- Install and configure collectd and node_exporter
###

# Package list
yum install collectd mcelog numactl smartmontools collectd-rrdtool collectd-ipmi collectd-mcelog collectd-smart -y > /dev/null 2>&1

# Grab Josh's collectd.conf
wget -P /etc/collectd.d/ https://raw.githubusercontent.com/JoshHilliker/Telemetry-Infra/master/collectd.conf > /dev/null 2>&1

# Need this to strip out the Windows linefeeds "^M"
dos2unix /etc/collectd.d/collectd.conf > /dev/null 2>&1

# Tweak collectd.conf
sed -i "s/^#Hostname.*/Hostname     $(hostname)/g" /etc/collectd.d/collectd.conf
sed -i "s/^Hostname.*/Hostname     $(hostname)/g" /etc/collectd.d/collectd.conf
sed -i "s/^#FQDNLookup.*/FQDNLookup   true/g" /etc/collectd.d/collectd.conf
#sed -i "s/^LoadPlugin smart/#LoadPlugin smart/g" /etc/collectd.conf

# Hack to stop spamming with default install
#sed -i "s/^#LoadPlugin network/LoadPlugin network/g" /etc/collectd.conf
#tee -a /etc/collectd.conf << EOF > /dev/null 2>&1
#<Plugin network>
#        # client setup:
#        <Server "127.0.0.1" "65534">
#        </Server>
#        # server setup:
#        <Listen "127.0.0.1" "65534">
#        </Listen>
#</Plugin>
#EOF

#LoadPlugin write_prometheus
#<Plugin write_prometheus>
#        Port "9103"
#</Plugin>

systemctl start collectd
systemctl enable collectd > /dev/null 2>&1

if $(systemctl is-active --quiet collectd)
   then
    echo "collectd is running"
fi

###--- End collectd

###---
###--- Create/modify an additional user account
# NOTE - may want to customize the users shell

###---
echo "###--- Adding labuser1"
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

tee -a /home/labuser1/.ssh/config << EOF > /dev/null 2>&1
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

###---
###--- Configure NTP - Admin VM is the NTP server
###---
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
systemctl enable ntpd > /dev/null 2>&1

if $(systemctl is-active --quiet ntpd)
   then
    echo "NTP is running"
fi
###--- End NTP

###---
###--- Firewall check to see if it is running if it is - configure it for NTP
###---
echo "###--- Configure the firewall"
if $(systemctl is-active --quiet firewalld)
   then
    # NTP
    firewall-cmd --add-service=ntp --permanent
    firewall-cmd --reload
fi

###=================================================  End bootstrap.sh  =================================================###