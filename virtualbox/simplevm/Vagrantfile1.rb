# -*- mode: ruby -*-
# # vi: set ft=ruby :
# Simple Vangrantfile
# Created By: Karl Vietmeier

###- Give the VM a useful name.
 
# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"

  # Set the Vagrant vm name for stdout while starting VM
  config.vm.define "simple"
  
  # Set the VM OS level Hostname
  config.vm.hostname = "simple"
  
  config.vm.provider "virtualbox" do |vb|
    # Set the name in Virtualbox (GUI and CLI)
    vb.name = "simple"
  end ###--- End Provider

end