## VirtualBox Provider based Vagrant Projects

Working on building multi-server and multi-disk environments as baselines for installing things like Ceph and Kubernetes clusters.<br/>
The projects build from the most basic, "simplevm", to more complex setups.<br/>

1. **simplvm:** Most basic Vagrantfile with more complex but still simple examples.
2. **centos:** Fully commented single-machine example that utilizes as many Vagrantfile methods as possible, including adding a disk.
3. **MultiDisk:** A single-machine example attaching multple drives to the guest.
4. **MultiServer:** A multi-machine example using a sourced yaml definition filea - could be used for a Kubernetes cluster.
5. **Ceph:** A multi-machine, multi-disk example with shell provisioners to do the Ceph "pre-flight".

**Projects:**

    Current Set of Projects:
      ├───AtomicCentos
      |     |
      |     Basic Vagrantfile to startup a Centos Atomic guest
      |
      ├───centos
      |     |
      |     Single VM - Test platform for a fully configured Centos Guest with lots of comments
      |     in the Vagrantfile and a walk-through 
      |
      |───Ceph
      |     |
      |     6 VMs - Admin, osd01-3, mon01-2
      |
      |───ClearLinux
      |     |
      |     Intel Clearlinux with scripts to install Apache, Docker, and Clear Containers
      |
      |───devops
      |     |
      |     Vagrantfile that creates multiple VMs using only the Vagrantfile
      |
      |───devstack
      |     |
      |     Not active
      |
      |───MultiDisk
      |     |
      |     Example of creating multiple additional disks in a guest
      |
      |───MultiServer
      |     |
      |     Create 6 VMs using a seperate YAML dictionary file (Ceph is built on this)
      |
      |───OpenShift
      |     | 
      |     Not active
      |
      |───Photon
      |     |
      |     Basic Vagrantfile to startup a VMware Photon guest
      |
      |───scratch
      |     |
      |     Code snippets, misc text blocks
      |
      └───ubuntu
            |
            Ubuntu, not active
            