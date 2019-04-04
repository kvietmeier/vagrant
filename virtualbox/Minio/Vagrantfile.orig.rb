# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile to create a bootstrapped Storage cluster configuration
# Requires "servers.yml" to be in local directory
#
# Will create multiple nodes with several disks per node
# Created By: Karl Vietmeier
 
# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"
 
# Require YAML module
require 'yaml'
 
# Read YAML file with multi-machine node configurations
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
  config.vm.synced_folder '.', '/vagrant', disabled: true

  # Iterate through entries in YAML file - "servers" is a hash to iterate over using Ruby syntax.
  servers.each do |servers|
    config.vm.define servers["name"] do |srv|
      srv.vm.box = servers["box"]
      srv.vm.hostname = servers["name"]

      # Network setup
      srv.vm.network "forwarded_port", guest: 22, host: servers["ssh_port"]
      srv.vm.network "forwarded_port", guest: 9000, host: servers["minio_port"]
      srv.vm.network "private_network", ip: servers["ip1"]
      srv.vm.network "private_network", ip: servers["ip2"]

      # VM parameters
      srv.vm.provider :virtualbox do |vb|
        # Create a group in Virtualbox
        vb.customize ["modifyvm", :id, "--groups", "/StorageNodes" ]
        
        # Basic VM config - modify in servers.yml
        vb.name = servers["name"]
        vb.memory = servers["ram"]
        vb.cpus = servers["cpus"]
        
      
        vb.customize ["modifyvm", :id, "--ioapic", "on" ]
        vb.customize ["modifyvm", :id, "--chipset", "ich9" ]

        # Configure system parameters - get rid of extra stuff
        vb.customize ["modifyvm", :id, "--audio", "none" ]
        vb.customize ["modifyvm", :id, "--usb", "off" ]

        #-- SATA Add controller - you can only have one
        #vb.customize ['storagectl', :id, '--name', 'SATA Controller', '--add', 'sata', '--controller', 'IntelAhci', '--portcount', 6]

        #-- NVME -- Add controller - bootable has to be off
        #vb.customize ['storagectl', :id, '--name', 'NVME Controller', '--add', 'pcie', '--controller', 'NVMe', '--portcount', 6, '--bootable', 'off']

        vb.customize [
          'storagectl', :id,
          '--name', 'NVMe Controller',
          '--add', 'pcie',
          '--controller', 'NVMe',
          '--portcount', '4',
          '--bootable', 'off'
        ] unless File.exist?("#{servers['name']}-data01.vdi")


        ###-------- Disk setup ---------###
        ## Check the hostmame - only add extra drives to the OSD nodes, not admin or clients.
        if ("#{servers['name']}").include? "minio"
        
           # Loop and create/attach the OSD disks
           (1..3).each do |num|
             # Create Data drive/s 
             unless File.exist?("#{servers["name"]}-data0#{num}.vdi")
               vb.customize [
                   'createmedium', '--filename',
                   "#{servers["name"]}-data0#{num}.vdi",
                   "--variant", "Fixed", 
                   '--size', 512]
             end  # End create OSD drive

             # Attach the disks to the Disk controller
             #vb.customize [ 'storageattach', :id, '--storagectl', 'SATA Controller', '--port', "#{num}", '--device', 0, '--type', 'hdd', '--medium', "./#{servers["name"]}-data0#{num}.vdi"]
             vb.customize [ 'storageattach', :id, '--storagectl', 'NVMe Controller', '--port', "#{num}", '--device', 0, '--type', 'hdd', '--medium', "./#{servers["name"]}-data0#{num}.vdi"]
             #vb.customize [ 'storageattach', :id, '--storagectl', 'NVMe Controller', '--port', "#{num}", '--type', 'hdd', '--medium', "./#{servers["name"]}-data0#{num}.vdi"]

             # Add 1 to get port for Cache disk
             $port = num += 1
           end # Create/attach OSD disks  

           # Create Cache Drive
           #unless File.exist?("#{servers["name"]}-cache.vdi")
           #  vb.customize ['createmedium', '--filename', "#{servers["name"]}-cache.vdi", '--variant', 'Fixed', '--size', 256]
           #end  # End journal create disk

          # Attach journal disk to $port on SATA controller
          # vb.customize [ 'storageattach', :id, '--storagectl', 'SATA Controller', '--port', $port, '--device', 0, '--type', 'hdd', '--medium', "./#{servers["name"]}-cache.vdi"]
          # Attach journal disk to $port on NVMe controller
          #vb.customize [ 'storageattach', :id, '--storagectl', 'NVME Controller', '--port', $port, '--type', 'hdd', '--medium', "./#{servers["name"]}-cache.vdi"]

        end  # End if - check for osd nodes
        ###-------- End Disk Setup Section ---------###

      end # vm.provider

      ###-----------------------------------------------------------------------------------###
      ###-------------------           Provisioner Section               -------------------###
      ###-----------------------------------------------------------------------------------###
      ### Uses a combination of inline shell, file, and external shell scripts
      ### NOTE - You need to explicitely name each provisioner or it will run once for every
      ###        loop iteration
      
      # INLINE
      # Add the host system user's public key to .ssh/authorized_keys for root and vagrant users
      # - should move this to a script file but it is here as an example of an inline script
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
      
      # Copy in the hosts file
      config.vm.provision "Copy /etc/hosts", type: "file" do |file|
         file.source = "../../scripts/env/hosts" 
         file.destination =  "~/hosts"
      end  
      
      ### External shell scripts for configuration
      # - Run on every node - basic pre-flight
      #config.vm.provision "bootstrap", type: "shell" do |script|
      #   script.path = "../../scripts/bash/config/bootstrap.sh"
      #end

      # - Run on every node - Ceph common stuff
      #config.vm.provision "Install Ceph Common Stuff", type: "shell" do |script|
      #   script.path = "../../scripts/bash/ceph/ceph-common.sh"
      #end

      # Role based setup is in the servers.yml file - pull it out as a key:value
      #config.vm.provision "Role", type: "shell" do |script|
      #   script.path = "../../scripts/bash/ceph/#{servers["script"]}"
      #end
      
      ###--------------------- End Provisioning

    end  # config.vm.define
  end  # servers.each
end  # Vagrant.configure



