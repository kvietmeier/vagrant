### Vagrantfile snipets



# -*- mode: ruby -*-
# vi: set ft=ruby :
# http://cobbaut.blogspot.com/2014/04/vagrant-creating-10-vms-with-6-disks.html
# Example for using multi-disks to create nodes for Ceph install


hosts = [ { name: 'server1', disk1: './server1disk1.vdi', disk2: 'server1disk2.vdi' },
          { name: 'server2', disk1: './server2disk1.vdi', disk2: 'server2disk2.vdi' },
          { name: 'server3', disk1: './server3disk1.vdi', disk2: 'server3disk2.vdi' }]

Vagrant.configure("2") do |config|

  config.vm.provider :virtualbox do |vb|
   vb.customize ["storagectl", :id, "--add", "sata", "--name", "SATA" , "--portcount", 2, "--hostiocache", "on"]
  end

  hosts.each do |host|

    config.vm.define host[:name] do |node|
      node.vm.hostname = host[:name]
      node.vm.box = "chef/centos-6.5"
      node.vm.network :public_network
      node.vm.synced_folder "/srv/data", "/data"
      node.vm.provider :virtualbox do |vb|
        vb.name = host[:name]
        vb.customize ['createhd', '--filename', host[:disk1], '--size', 2 * 1024]
        vb.customize ['createhd', '--filename', host[:disk2], '--size', 2 * 1024]
        vb.customize ['storageattach', :id, '--storagectl', "SATA", '--port', 1, '--device', 0, '--type', 'hdd', '--medium', host[:disk1] ]
        vb.customize ['storageattach', :id, '--storagectl', "SATA", '--port', 2, '--device', 0, '--type', 'hdd', '--medium', host[:disk2] ]
      end
    end

  end

end


(1..3).each do |i|
  config.vm.define "ceph#{i}" do |node|
  node.vm.hostname = "ceph#{i}"
  node.vm.network "private_network", ip: "172.24.0.#{i}", intnet: true
  config.vm.provider "virtualbox" do |v|
  v.memory = 512
  v.cpus = 1
  v.customize ['createhd', '--filename', "ceph_disk_#{i}a.vdi", '--size', 8192 ]
  v.customize ['createhd', '--filename', "ceph_disk_#{i}b.vdi", '--size', 8192 ]
  v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', "./ceph_disk_#{i}a.vdi"]
  v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', "./ceph_disk_#{i}b.vdi"]
  end
  end
  
  end


#   For any number
  VAGRANTFILE_API_VERSION = "2"

  Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.provider :virtualbox do |vb|
    vb.customize ["storagectl", :id, "--add", "sata", "--name", "SATA" , "--portcount", 2, "--hostiocache", "on"]
    end

    (1..3).each do |i|
      config.vm.define "server#{i}" do |node|
      node.vm.hostname = "server#{i}"
      node.vm.box = "hfm4/centos7"
      config.vm.box_check_update = true
      node.vm.network :public_network, ip: "10.1.1.#{i}", netmask: '255.255.255.0'
      node.vm.network :public_network, ip: "10.1.2.#{i}", netmask: '255.255.255.0'
      node.vm.network :public_network, ip: "10.1.3.#{i}", netmask: '255.255.255.0'
  
  config.vm.provider "virtualbox" do |v|
    v.name = "server#{i}"
    v.memory = 512
    v.cpus = 1
    v.customize ['createhd', '--filename', "server_#{i}a.vdi", '--size', 8192 ]
    v.customize ['createhd', '--filename', "server_#{i}b.vdi", '--size', 8192 ]
    v.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', "./server_#{i}a.vdi"]
    v.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', "./server_#{i}b.vdi"]
    end
  end
  end
  end

  # multi - multi
  (1..3).each do |i|
    config.vm.define "node-#{i}" do |node|
        node.vm.network "private_network", ip: "192.168.200.#{i}"
        file_for_disk = "./large_disk#{i}.vdi"
        node.vm.provider "virtualbox" do |v|
           unless File.exist?(file_for_disk)
               v.customize ['createhd', 
                            '--filename', file_for_disk, 
                            '--size', 80 * 1024]
               v.customize ['storageattach', :id, 
                            '--storagectl', 'SATAController', 
                            '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_for_disk]
           end
       end
   end
end


Vagrant.configure("2") do |config|
  file_to_disk = '../second_disk.vdi'
  # create CrushFTP nodes
     (1..2).each do |i|
       config.vm.define "cftpnode#{i}" do |node|
           node.vm.customize ['createhd', '--filename', file_to_disk, '--size', 500 * 1024]
           node.vm.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk] 
           node.vm.box = "bento/centos-7.2"
           node.vm.hostname = "cftpnode#{i}"
           node.vm.network :private_network, ip: "192.168.0.1#{i}"
           node.vm.provider "virtualbox" do |vb|
               vb.memory = "1024"
                       end
         node.vm.provision :shell, path: "bootstrap-node.sh"
     end
    end
  end

  Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/xenial64"
  
    config.vm.host_name = "foo-dev"

    config.vm.provision "shell", path: "provision/bootstrap.sh"
    config.vm.provision "shell", inline: "sudo echo \"export ASPNETCORE_ENVIRONMENT=Development\" | tee -a /etc/profile.d/vars.sh", run: "always"
  
    # Nginx
    config.vm.network "forwarded_port", guest: 80, host: 8080
    # Postgres
    config.vm.network "forwarded_port", guest: 5432, host: 5432
    # Mongodb
    config.vm.network "forwarded_port", guest: 27017, host: 27017
    # Kestrel
    config.vm.network "forwarded_port", guest: 5050, host: 5050

    # Sync folders
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.synced_folder "..", "/foo"
  
     config.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
     end
  
  end