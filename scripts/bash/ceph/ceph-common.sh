#!/bin/bash
# All of the Ceph nodes will need these settings/packages
# http://docs.ceph.com/docs/mimic/install/get-packages/
# Release info - 
# http://docs.ceph.com/docs/mimic/releases/#id1
#
# EPEL is already installed in bootstrap.sh

### ----  For Ceph bootstrap  ---- ###
#awk '/^# Defaults/ && !f {$0=$0 RS "Defaults:labuser1 !requiretty";f=1}1' /etc/sudoers
#sed '/^# Defaults/{s/.*/&\Defaults:labuser1 !requiretty/;:a;n;ba}' /etc/sudoers
#sed '/^# Defaults/{s/.*/$/\'$'\n''Defaults:labuser1 !requiretty/;}' /etc/sudoers


# Modify these as required for later commands
ceph_release="mimic"
distro="el7"
basearch=$(uname -i)

echo "Setting up Ceph Nodes"
echo "Common" >> /home/vagrant/file.txt

# Create a Ceph repos file for yum
tee << EOF > /etc/yum.repos.d/ceph.repo
[ceph]
name=Ceph packages for $basearch
baseurl=https://download.ceph.com/rpm-${ceph_release}/${distro}/${basearch}
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=https://download.ceph.com/rpm-${ceph_release}/${distro}/noarch
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=https://download.ceph.com/rpm-${ceph_release}/${distro}/SRPMS
enabled=0
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc
EOF

# Add a Ceph trusted key
rpm --import 'https://download.ceph.com/keys/release.asc'

# Install Required Packages
yum install snappy leveldb gdisk python-argparse gperftools-libs -y

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

# - Configure SSH
mkdir /home/cephuser/.ssh
chown cephuser:cephuser /home/cephuser/.ssh
chmod 700 /home/cephuser/.ssh

touch /home/cephuser/.ssh/authorized_keys
chown cephuser:cephuser /home/cephuser/.ssh/authorized_keys
chmod 700 /home/cephuser/.ssh/authorized_keys

tee /home/cephuser/.ssh/config << EOF
# Set some SSH defaults 

Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null

EOF
chown cephuser:cephuser /home/cephuser/.ssh/config
chmod 600 /home/cephuser/.ssh/config

# Generate a key
su - cephuser --command "ssh-keygen -t rsa -N \"\" -f ~/.ssh/id_rsa"

###---- End User create section

###--- Firewall check to see if it is running if it is - configure it for Ceph
echo "###--- Configure the firewall"
if $(systemctl is-active --quiet firewalld)
   then
    # Ceph
    firewall-cmd --zone=public --add-service=ceph-mon --permanent
    firewall-cmd --zone=public --add-service=ceph --permanent
    firewall-cmd --reload
fi
