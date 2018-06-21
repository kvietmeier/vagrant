## Intel Clear Linux testing platform

You will need the Clear Linux Vagrant plugin:
````shell
vagrant plugin install vagrant-guests-clearlinux
````

NOTE:  It is very important to check for plugin updates after you update the box version.

Config the Clear Linux box and set hostname
````ruby
Vagrant.configure(2) do |config|
  config.vm.box = "AntonioMeireles/ClearLinux"
  config.vm.hostname = "clearlinux"
````

./setup has bootstrap and application setup scripts use with these lines in Vagrantfile:
````ruby
  config.vm.provision :shell, :path => "setup/bootstrap.sh"
  config.vm.provision :shell, :path => "setup/apache.sh"
````