#!/usr/bin/bash
# prometheus.sh
# Installation of Prometheus  - REFERENCE ONLY - not for production 
# Created By:  Josh Hilliker
# 

###--- Vars
file_loc=/home/vagrant
user=prometheus
group=prometheus
pmths_git="https://github.com/prometheus/prometheus/releases/download/"
RELEASE=2.7.0

###--- Start the script
echo ""
echo "#####------------------------------------------#####"
echo "#####--------  Installing Prometheus  ---------#####"
echo "#####------------------------------------------#####"
echo ""

###--- Add/create the Prometheus system user/group
echo "###--- Add/create the Prometheus system user/group"
useradd --system -s /sbin/nologin $user


###--- Create some directories we will need
echo "###--- Create some directories we will need"
mkdir /var/lib/prometheus
chown -R ${user}:${group} /var/lib/prometheus/

for dir in rules rules.d files_sd
  do 
    mkdir -p /etc/prometheus/${dir}
    chown -R ${user}:${group} /etc/prometheus/${dir}
    chmod -R 775 /etc/prometheus/${dir}
done

###--- Install some utilities if they aren't there
echo ""
echo "###--- Install some utilities if they aren't there"
echo "yum install wget vim-enhanced screen tree -y > /dev/null 2>&1"
yum install wget mlocate vim-enhanced screen tree dos2unix -y > /dev/null 2>&1


###--- Download the packages from github and install Prometheus ---###
echo ""
echo "###--- Download the packages from github and install Prometheus ---###"
echo "wget -P /tmp ${pmths_git}/v${RELEASE}/prometheus-${RELEASE}.linux-amd64.tar.gz > /dev/null 2>&1"
wget -P /tmp ${pmths_git}/v${RELEASE}/prometheus-${RELEASE}.linux-amd64.tar.gz > /dev/null 2>&1

cd /tmp
tar xf prometheus-${RELEASE}.linux-amd64.tar.gz
cd prometheus-${RELEASE}.linux-amd64/
cp prometheus promtool /usr/local/bin/
cp -r consoles/ console_libraries/ /etc/prometheus/

# Be nice and cleanup after ourselves
rm -rf prometheus-${RELEASE}.linux-amd64.tar.gz
rm -rf prometheus-${RELEASE}.linux-amd64/

# Grab configuration files
#wget -P /etc/prometheus https://raw.githubusercontent.com/JoshHilliker/Telemetry-Infra/master/prometheus.yml
#wget -P /etc/systemd/system https://raw.githubusercontent.com/JoshHilliker/Telemetry-Infra/master/prometheus.service

###----  For Vagrant provisioning - remove if not using in a shell provisioner
### {file_loc} is set for Vagrant - you will need to modify for yourself
cp ${file_loc}/prometheus.yml /etc/prometheus
chown root:root /etc/prometheus/prometheus.yml
cp ${file_loc}/prometheus.service /etc/systemd/system
chown root:root /etc/systemd/system/prometheus.service
###---  End Vagrant

###--- Restart/Reload services
echo ""
echo "###--- Restart/Reload services"
systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus
systemctl status prometheus
