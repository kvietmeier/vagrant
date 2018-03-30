
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Example for using multi-disks to create nodes for Ceph install

Vagrant.configure("2") do |config|

  osd_data_size = 6
  osd_journal_size = 6
  osd_path = '/d02/vagrant/virtualbox-ceph-disks'


  hosts = {
    'mon-1' => {
       'ip' => '10.253.60.151',
       'cpus' => 1, 
       'memory' => 1024, 
       'autostart' => true,
       'data_disk_size' => osd_data_size * 1024, 
       'journal_disk_size' => osd_journal_size * 1024 },
  }

  hosts.each do |host, params|
    config.vm.define host, autostart: params['autostart'] do |host_config|
      host_config.vm.box = "centos/7"
      host_config.vm.hostname = "#{host}"
      host_config.vm.network :private_network, ip: params['ip'], hostupdater: "skip"
      #host_config.vm.synced_folder '.', '/home/vagrant/sync', disabled: true
      host_config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".git/", :nfs => false
      

      host_config.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--ioapic", "on" ]
        v.name = host
        v.memory = params['memory']
        v.cpus = params['cpus']

        v.customize ['storagectl', :id, '--name',  'SATA Controller', '--add', 'sata',  '--controller', 'IntelAhci', '--portcount', 4]

        unless File.exist?("#{osd_path}/#{host}-data-disk.vdi")
          v.customize ['createhd', '--filename', "#{osd_path}/#{host}-data-disk.vdi", '--size', params['data_disk_size']]
        end
        unless File.exist?("#{osd_path}/#{host}-journal-disk.vdi")
          v.customize ['createhd', '--filename', "#{osd_path}/#{host}-journal-disk.vdi", '--size', params['journal_disk_size']]
        end

        v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 0, '--device', 0, '--type', 'hdd', '--medium', "#{osd_path}/#{host}-data-disk.vdi"]
        v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', "#{osd_path}/#{host}-journal-disk.vdi"]
        v.customize ['modifyvm',      :id, '--nic3', 'intnet']

      #
      end

      host_config.vm.network :private_network, ip: params['ip']
      
      host_config.vm.provision :shell, inline: <<-SHELL
        sudo echo #{host} > /etc/hostname
        sudo hostname #{host}
        sudo chkconfig iptables off
        sudo service iptables stop
        sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
        sudo yum -y install puppet vim-enhanced strace dstat telnet
      SHELL

      host_config.vm.provision :puppet do |puppet|
        puppet.module_path    = "modules"
        puppet.manifests_path = "manifests"
        puppet.manifest_file  = "default.pp"
      end
    end
  end
end


ubuntu.vm.provider "virtualbox" do |virtualbox|
    virtualbox.name = "Ubuntu_1510_#{Time.now.getutc.to_i}"
    virtualbox.customize [
        "storagectl", :id, 
        "--name", "SATAController", 
        "--controller", "IntelAHCI", 
        "--portcount", "1", 
        "--hostiocache", "on"
    ]
    virtualbox.customize [
        "clonehd", "#{ENV["HOME"]}/VirtualBox VMs/Vagrant Test Boxes/#{virtualbox.name}/box-disk1.vmdk", 
                   "#{ENV["HOME"]}/VirtualBox VMs/Vagrant Test Boxes/#{virtualbox.name}/ubuntu.vdi", 
        "--format", "VDI"
    ]
    virtualbox.customize [
        "modifyhd", "#{ENV["HOME"]}/VirtualBox VMs/Vagrant Test Boxes/#{virtualbox.name}/ubuntu.vdi",
        "--resize", 100 * 1024
    ]
    virtualbox.customize [
        "storageattach", :id, 
        "--storagectl", "SATAController", 
        "--port", "0", 
        "--device", "0", 
        "--type", "hdd",
        "--nonrotational", "on",
        "--medium", "#{ENV["HOME"]}/VirtualBox VMs/Vagrant Test Boxes/#{virtualbox.name}/ubuntu.vdi" 
    ]
  end


  