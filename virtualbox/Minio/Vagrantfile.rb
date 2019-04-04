# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile to create a bootstrapped Ceph cluster configuration
# Requires "servers.yml" to be in local directory
#
# Will create multiple nodes with several disks per node
# Created By: Karl Vietmeier

Vagrant.require_version '>= 1.6.0'

require 'yaml'

cluster = YAML.load_file(File.join(File.dirname(__FILE__), 'servers.yml'))

Vagrant.configure(2) do |config|
  config.vm.usable_port_range = 2800..2900
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.ssh.insert_key = false
  cluster.each do |servers|
    config.vm.define servers['name'] do |srv|
      srv.vm.box = servers['box']
      srv.vm.hostname = servers['name']

      srv.vm.provider :virtualbox do |vb|
        vb.name = servers['name']
        vb.memory = servers['ram']
        vb.cpus = servers['cpus']

        

        # support for the SSE4.x instruction is required in some versions of VB.
        {
          'VBoxInternal/CPUM/SSE4.1' => '1',
          'VBoxInternal/CPUM/SSE4.2' => '1'
        }.each { |k, v| vb.customize ['setextradata', :id, k.to_s, v.to_s] }

        {
          '--groups' => '/StorageNodes',
          '--ioapic' => 'on',
          '--audio' => 'none',
          '--usb' => 'off',
          '--chipset' => 'ich9'
        }.each { |k, v| vb.customize ['modifyvm', :id, k.to_s, v.to_s] }

        vb.customize [
          'storagectl', :id,
          '--name', 'NVMe',
          '--add', 'pcie',
          '--controller', 'NVMe',
          '--portcount', '4',
          '--bootable', 'off'
        ] unless File.exist?("#{servers['name']}-Data01.vdi")

        if servers['name'].to_s.include? 'minio'
          (1..3).each do |num|
            vb.customize [
              'createmedium',
              '--filename', "#{servers['name']}-Data0#{num}.vdi",
              '--variant', 'Fixed',
              '--size', '512'
            ] unless File.exist?("#{servers['name']}-Data0#{num}.vdi")
            vb.customize [
              'storageattach', :id,
              '--storagectl', 'NVMe',
              '--port', num.to_s,
              '--type', 'hdd',
              '--medium', "./#{servers['name']}-Data0#{num}.vdi"
            ] unless File.exist?("#{servers['name']}-Data0#{num}.vdi")
          end
        end
      end
    end
  end
end