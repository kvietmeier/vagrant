## Vagrant Projects

I use Vagrant for Windows 10 and have experimented with Virtualbox, HyperV, and VMware Workstation.  I have tested and discarded HyperV for now, there are just too many bugs and challenges with networking and mounting shared folders.  I really wanted to use HyperV since it is required if you want to install and use Docker4Windows, and I wanted to use a completely Microsoft/Windows toolset.  But - both D4W and HyperV are still WIP for now.

VMware Workstation is TBD

**NOTE - All of these examples are built/run using Windows 10 and PowerShell.**

## Getting Started

You will need at least these 2 utilities:

* [Vagrant](https://www.vagrantup.com/ - Grab the Windows 64bit version
* [VirtualBox] (https://www.virtualbox.org/wiki/Downloads) - No explanation needed

## Customize your workspace to make things easier and get a good IDE/text editor

There are many tutorials out there on getting Virtualbox and Vagrant installed so I won't try to replicate them here but there are some things I highly recommend you setup and configure on your laptop.

* [ConEmu](https://conemu.github.io/) - Windows terminal replacement can be configured to give "iterm like" functionality
* [Visual Studio Code](https://code.visualstudio.com/) - Free and lightweight version of Visual Studio

Powershell wrapper function/alias for git4win:

~~~powershell
function gpush {
    Param($message)
    git add -A; git commit -m $message; git push origin master
}
~~~

### Author

* **Karl Vietmeier - Intel Cloud Solutions Architect**

### Acknowledgments

* All of my colleagues at Intel who have been willing test subjects