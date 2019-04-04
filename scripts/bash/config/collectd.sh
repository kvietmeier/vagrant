#!/bin/bash
###
###--- Install and configure collectd and node_exporter
###    Created by:  Karl Vietmeier
###

# Package list
yum install collectd mcelog numactl smartmontools collectd-rrdtool collectd-ipmi collectd-mcelog collectd-smart -y > /dev/null 2>&1

# Update the man pages
catman > /dev/null 2>&1

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
