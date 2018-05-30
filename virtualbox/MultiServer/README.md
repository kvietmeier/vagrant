### Multinode project with attached disks for Kubernetes/Docker or any distributed platform

**Goal:**
Provide a working platform for testing Kubernetes installation, configuration, and basic cluster functionality

**Notes**
Currently setup as 1 Centos 7 node and 5 Centos Atomic nodes.
Server/node configuration is in "servers.yml"

Configuration Tasks:
* Create private networks and interfaces
* Set Port forwarding
* Set the VM names:
    * hostname
    * Name in Virtualbox
* Configfure VM
    * Memory/CPU
    * HW devices (audio/USB)
* Add additional disks
* Basic Shell provisioner
