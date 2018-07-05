# -*- mode: ruby -*-
# # vi: set ft=ruby :
# Vagrantfile to create a bootstrapped Ceph cluster configuration
# Requires "servers.yml" to be in local directory
#
# Will create multiple nodes with several disks per node
# Created By: Karl Vietmeier
 
# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"
 
# Require YAML module
require 'yaml'
 
# Read YAML file with box details
servers = YAML.load_file(File.join(File.dirname(__FILE__), 'servers.yml'))

# Define some variables
ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
adminvm_karlvkey = File.readlines("#{Dir.home}/Documents/Projects/vagrant/certs/adminvm_karlv_id_rsa.pub").first.strip
adminvm_rootkey = File.readlines("#{Dir.home}/Documents/Projects/vagrant/certs/adminvm_root_id_rsa.pub").first.strip

# Not used right now
ssh_user = "vagrant"
ssh_pass = "vagrant"

# Create Virtual Machines
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Default is 2200..something, but port 2200 is used by some tools
  config.vm.usable_port_range = 2800..2900
 
  # Iterate through entries in YAML file - "servers" is a hash to iterate over using Ruby syntax.
  servers.each do |servers|
    config.vm.define servers["name"] do |srv|
      srv.vm.box = servers["box"]
      srv.vm.hostname = servers["name"]

      # Network setup
      srv.vm.network "private_network", ip: servers["ip1"]
      srv.vm.network "private_network", ip: servers["ip2"]
      srv.vm.network "forwarded_port", guest: 22, host: servers["port"]

      #????
      #srv.ssh.username = servers["ssh_user"]
      #srv.ssh.password = servers["ssh_pass"]

      # VM parameters
      srv.vm.provider :virtualbox do |vb|
        vb.name = servers["name"]
        vb.memory = servers["ram"]
        vb.cpus = servers["cpus"]
        
        # Configure system parameters - get rid of extra stuff
        vb.customize ["modifyvm", :id, "--ioapic", "on" ]
        vb.customize ["modifyvm", :id, "--audio", "none" ]
        vb.customize ["modifyvm", :id, "--usb", "off" ]

        # Add SATA controller - you can only have one
        vb.customize ['storagectl', :id, '--name',  'SATA Controller', '--add', 'sata',  '--controller', 'IntelAhci', '--portcount', 6]

        ###-------- Disk setup ---------###
        ## Check the hostmame - only add extra drives to the OSD nodes, not admin or mons.
        if ("#{servers["name"]}").include? "osd"
        
          # Loop and create/attach the OSD disks
         (1..3).each do |num|
           # Create OSD drive/s 
           unless File.exist?("#{servers["name"]}-OSD-0#{num}.vdi")
             vb.customize ['createhd', '--filename', "#{servers["name"]}-OSD-0#{num}.vdi", '--size', 512]
           end  # End create OSD drive

            # Attach the disks to the SATA controller
            vb.customize [ 'storageattach', :id, '--storagectl', 'SATA Controller', '--port', "#{num}", '--device', 0, '--type', 'hdd', '--medium', "./#{servers["name"]}-OSD-0#{num}.vdi"]

            # Add 1 to get port for Journal disk
            $port = num += 1
          end # Create/attach OSD disks  

          # Create Journal Drive
          unless File.exist?("#{servers["name"]}-Journal.vdi")
            vb.customize ['createhd', '--filename', "#{servers["name"]}-Journal.vdi", '--size', 256]
          end  # End journal create disk

          # Attach journal disk to $port on SATA controller
          vb.customize [ 'storageattach', :id, '--storagectl', 'SATA Controller', '--port', $port, '--device', 0, '--type', 'hdd', '--medium', "./#{servers["name"]}-Journal.vdi"]

        end  # End if - check for osd nodes
        ###-------- End Disk Setup Section ---------###

      end # vm.provider

      ###-------- Provisioner Section ---------###
      ### We want to add the local user's public key to .ssh/authorized_keys 
      ### and get a working /etc/hosts
      put servers["name"]
      put "Provision inline script - - -- - -- - - - -- - - - -- "
      config.vm.provision "Setup shell environment", type: "shell" do |s|
        s.inline = <<-SHELL
          # Install some tools
          #yum install -y net-tools traceroute git ansible gcc make python > /dev/null 2>&1 
          # Add the public key
          mkdir /root/.ssh
          chmod 700 /root/.ssh
          touch /root/.ssh/authorized_keys
          echo "Appending user@Laptop keys to root and vagrant authorized_keys"
          echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
          echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
          echo "Appending AdminVM keys to root and vagrant authorized_keys"
          echo #{adminvm_karlvkey} >> /home/vagrant/.ssh/authorized_keys
          echo #{adminvm_karlvkey} >> /root/.ssh/authorized_keys
          echo #{adminvm_rootkey} >> /home/vagrant/.ssh/authorized_keys
          echo #{adminvm_rootkey} >> /root/.ssh/authorized_keys
        SHELL
      end # inline shell provisioner config.provision
      
      ### External shell scripts for configuration
      puts servers["name"]
      puts "Provision external script - - -- - -"
      config.vm.provision :shell, :path => "../../scripts/bash/config/bootstrap.sh"
      
      # Basic bootstrap - NTP, sudoers, etc
      config.vm.provision "shell", inline: <<-SHELL
        echo "Provision Every Node"
      SHELL
      #config.vm.provision :shell, :path => "../../scripts/bash/config/bootstrap.sh"

      # Provision based on Role
      if ("#{servers["name"]}").include? "osd"
        config.vm.provision "shell", inline: <<-SHELL
          echo "Provision OSD"
        SHELL
      end

      if ("#{servers["name"]}").include? "admin"
        config.vm.provision "shell", inline: <<-SHELL
          echo "Provision Admin"
        SHELL
      end

      if ("#{servers["name"]}").include? "mon"
        config.vm.provision "shell", inline: <<-SHELL
          echo "Provision Mon"
        SHELL
      end

    end  # config.vm.define
  end  #servers.each
end  # Vagrant.configure



