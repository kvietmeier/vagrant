## Intel Clear Linux testing platform

./setup has bootstrap and application setup scripts use with these lines in Vagrantfile:

````ruby
  config.vm.provision :shell, :path => "setup/bootstrap.sh"
  config.vm.provision :shell, :path => "setup/apache.sh"
````