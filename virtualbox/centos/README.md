### Commented example of creating a single VM

**Goal:**
Demonstrate the core sections of a Vagrantfile and common VM configuration tasks to provide a basis for more advanced configurations and Vagrantfiles.  

Configuration Tasks:
* Create private networks and interfaces
* Port forwarding
* Set the VM names:
    * Hostname in guest OS
    * Name in Virtualbox
    * Name for Vagrant
* Configfure VM
    * Memory/CPU
    * HW devices (audio/USB)
* Add additional disks (TBD)
* Shell provisioner

---
**Vagrantfile Walkthrough**
---


**Header with comments - Vagrantfile is using Ruby:**
```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
# Created By: Karl Vietmeier
# Basic Vagrantfile for a single VM with comments
```


**Setting variables local to Vagrantfile**
Using standard scripting best praqxtices it is a good idea to define varibles up front.
```ruby
### Set some variables
# Path to the local users public key file in $HOME/.ssh
# We use it later in the shell provisioner to populate authorized_keys

ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
adminvm_karlvkey = File.readlines("#{Dir.home}/Documents/Projects/vagrant/certs/adminvm_karlv_id_rsa.pub").first.strip
adminvm_rootkey = File.readlines("#{Dir.home}/Documents/Projects/vagrant/certs/adminvm_root_id_rsa.pub").first.strip
```


**Start VM configuration**
Define the box to use and VM names for Vagrant stdout and the guest OS.
```ruby
Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"

  # Set the VM OS level Hostname
  config.vm.hostname = "centos"

  # Set the Vagrant vm name for stdout while starting VM also the entry under machines in the .vagrant directory
  config.vm.define "centos"
```


**Network: Interface Configuration**
In this section you define private networks and setup port forwarding.
```ruby
  ###------- Network setup section - not Provider specific
  # You can create additional private networks which are configured as host-only networks by the Provider
  # If you don't create a private network the default NAT network of the provider will be used.
  # The first interface will always be the default NAT network, private networks get added as additional
  # interfaces
  # If the network doesn't exist - based on Subnet - it will be created in the Provider (VBox, VMware) 

  # Define a range of usable ports for automatic port mapping
  config.vm.usable_port_range= 2800..2900

  # Create 2 interfaces on 2 host-only networks
  config.vm.network "private_network", ip: "172.16.0.200"
  config.vm.network "private_network", ip: "172.10.0.200"

  # Do some port mapping - Vagrant will try 2222 for SSH if it is in use it will grab the first 
  # unused port in the above range
  config.vm.network "forwarded_port", guest: 22, host: 2250
  config.vm.network "forwarded_port", guest: 80, host: 2899
  config.vm.network "forwarded_port", guest: 8080, host: 2900

```


**Provider:  Virtualbox specific configuration**
We define the Provider specific options - in this case VirtualBox.  This includes adding an additional disk.
```ruby
  ###------- Provider specific VM definition and creation begins here
  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |vb|
   
   # Confifgure the amount of memory and number of CPUs for the VM:
   vb.memory = "1024"
   vb.cpus = "1"

   # Set the name in Virtualbox (GUI and CLI)
   vb.name = "centos"

   ###-------  Configure low level system parameters
   # - get rid of extra stuff
   # - need "ioapic on" when adding extra drives
   # - use "vb.customize" when modifying parameters that don't have predefined aliases like "vb.cpu"
   vb.customize ["modifyvm", :id, "--ioapic", "on" ]
   vb.customize ["modifyvm", :id, "--audio", "none" ]
   vb.customize ["modifyvm", :id, "--usb", "off" ]
```

**Add an additional Disk**
```ruby

    ###------- Add an additional disk
    # Add SATA controller - you can only have one
    vb.customize ['storagectl', :id, '--name',  'SATA Controller', '--add', 'sata',  '--controller', 'IntelAhci', '--portcount', 6]

    # Create OSD drive/s 
    unless File.exist?("Disk-01.vdi")
      vb.customize ['createhd', '--filename', "Disk-01.vdi", '--size', 512]
    end  # End create disk

    # Attach the drive to the controller
    vb.customize [ 'storageattach', :id, '--storagectl', 'SATA Controller', '--port', "2", '--device', 0, '--type', 'hdd', '--medium', "./Disk-01.vdi"]

  end ###--- End Provider
```
**End Provider**


**Provisioner: Using shell provisioner**
A basic box isn't terribly useful.  Here we do things like copy in host keys for SSH and install some basic packages that most boxes are missing.
We also a bad thing - disable SElinux.
ToDo - you could put in a check for OS type and switch between yum and apt-get.
```ruby
  ###------- Provisioner section - this is where you customize the guest OS.
  ### This example is using the Shell provisioner
  config.vm.provision "Setup shell environment", type: "shell" do |s|
    s.inline = <<-SHELL
    ### Run standard bash commands using an "inline" script
    
    # Install some useful tools and update the system
    yum install -y net-tools traceroute git ansible gcc make python policycoreutils-python > /dev/null 2>&1 
    yum install -y docker > /dev/null 2>&1 
    #yum update -y > /dev/null 2>&1
    
    # Disable SElinux - generally not a good idea but needed foir nginx for now
    sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
    setenforce 0

    # Add the public keys "adminvm" is a VM I use for testing things like Ansible
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

    echo "Reboot to permenantly disable SElinux"

    ###  This is for later - 
    # Copy /etc/hosts
    #if [ -e /vagrant/files/hosts ]
    #  then sudo cat /vagrant/files/hosts >> /etc/hosts
    #elif [ -e /home/vagrant/sync/files/hosts ]
    #  then sudo cat /home/vagrant/sync/files/hosts >> /etc/hosts
    #fi     
    SHELL
  end ###--- End Provisioner
```


**Provisioner: Reboot during setup**
Sometimes you need to reboot after doing something but befiore you are completely done 
```ruby
  ### Example of a Reboot in the middle of provisioning
  # Requires vagrant-reload plugin
  # https://github.com/aidanns/vagrant-reload/blob/master/README.md

  config.vm.provision "shell", inline: <<-SHELL
    echo "Do something requiring reboot"  
    echo $(date) > ~/reboottime
  SHELL

  # Trigger reload using plugin
  config.vm.provision :reload

  # Do something after the reload
  config.vm.provision "shell", inline: <<-SHELL
    echo "I just rebooted - continuing"
    echo $(date) >> ~/reboottime
  SHELL
```

**Provisioner: Call seperate shell scripts**   
```ruby
  # Demonstrate using external shell scripts for post bringup configuration
  config.vm.provision :shell, :path => "config/bootstrap.sh"
  config.vm.provision :shell, :path => "docker/setupdocker.sh"
  config.vm.provision :shell, :path => "nginx/setupnginx.sh"
```


**Close out "configure(2)"**
```ruby
end ###--- End configure(2) - this wraps up the wholething - like main()
```