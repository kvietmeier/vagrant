## Intel Clear Linux Environment
I have created a basic Vagrantfile and shell provisioning scripts to spin up a Clear Linux instance with Docker and Clear Containers installed and enabled.

Add the box -

````shell
PS C:\Users\user\Documents\Projects>vagrant box add AntonioMeireles/ClearLinux
````

You will need the Clear Linux Vagrant plugin:

````shell
vagrant plugin install vagrant-guests-clearlinux
````

**NOTE:** It is very important to check for plugin updates after you update the box version.

**Vagrant.configure**<br/>
Use the Clear Linux box and set a hostname

````ruby
Vagrant.configure(2) do |config|
  config.vm.box = "AntonioMeireles/ClearLinux"
  config.vm.define "clearlinux"
  config.vm.hostname = "clearlinux"
````

**config.vm.provision**<br/>
./setup has bootstrap and application setup scripts you can use with these lines in Vagrantfile:<br/>
I also need to copy in a script to install certificates for internal mirrors - you should comment out or remove those lines.

````ruby
### External shell scripts for configuration
# Copy in a script to install certs
config.vm.provision :file do |file|
  file.source = "../../certs/certificates.sh" 
  file.destination =  "/home/clear/installcerts.sh"
end  

# - Basic bootstrap - install Docker and Clear Containers
config.vm.provision "bootstrap", type: "shell" do |script|
  script.path = "setup/bootstrap.sh"
end
````
