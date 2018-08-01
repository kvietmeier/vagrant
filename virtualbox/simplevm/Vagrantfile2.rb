# -*- mode: ruby -*-
# # vi: set ft=ruby :
# Simple Vangrantfile
# Created By: Karl Vietmeier

### Add networking and VM configuration - making it more usable

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"

  # Set the Vagrant vm name for stdout while starting VM
  config.vm.define "simple"
  
  # Set the VM OS level Hostname
  config.vm.hostname = "simple"
 
  ### Start creating networks and mapping ports
  # Define a range of usable ports for automatic port mapping
  config.vm.usable_port_range= 2800..2900

  # Create a Private Network - if it doesn't exist, it will be created by vboxmanage
  config.vm.network "private_network", ip: "172.16.0.50"

  config.vm.provider "virtualbox" do |vb|
    # Set the name in Virtualbox (GUI and CLI)
    vb.name = "simple"

    # Configure the amount of memory and number of CPUs for the VM:
    vb.memory = "512"
    vb.cpus = "1"
  end ###--- End Provider

end