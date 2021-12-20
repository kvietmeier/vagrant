## Vagrant Projects

**NOTE: This is no longer an active repo.**

I use Vagrant for Windows 10 and have experimented with Virtualbox, HyperV, and VMware Workstation.  I have tested and discarded HyperV, there are just too many bugs and challenges with networking and mounting shared folders. I really wanted to use HyperV since it is required if you want to install and use Docker4Windows, and I wanted to use a completely Microsoft/Windows toolset but both D4W and HyperV are still WIP for now. 

**Update** - Hyper-V, Virtualbox, and VMware all play nicely together and Docker4Windows is used alongside WSL for things like Minikube and Kind so working with a 100% MSFT toolset ends up being very doable and efficient.

VMware Workstation is TBD

**All of these examples are built/run using Windows 10 and PowerShell.**

## Getting Started

You will need at least these 2 utilities:

* [Vagrant](https://www.vagrantup.com/) - Grab the Windows 64bit version
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) - No explanation needed

## Customize your workspace to make things easier and get a good IDE/text editor

There are many tutorials out there on getting Virtualbox and Vagrant installed so I won't try to replicate them here but there are some things I highly recommend you setup and configure on your laptop.

* [Windows Terminal](https://github.com/microsoft/terminal) - Modern, integrated terminal application
* [Visual Studio Code](https://code.visualstudio.com/) - Free and lightweight version of Visual Studio


### Author

* **Karl Vietmeier - Intel Cloud Solutions Architect**

### Acknowledgments

* All of my colleagues at Intel who have been willing test subjects