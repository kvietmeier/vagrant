## VirtualBox Provider based Vagrant Projects

Working on building multi-server and multi-disk environments as baselines for installing things like Ceph and Kubernetes clusters.

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
      |     Intel Cklearlinux with scripts to install Apache, Docker, and Clear Containers
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
      |     Create 6 VMs using a seperate yaml distionarty file (Ceph is built on this)
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