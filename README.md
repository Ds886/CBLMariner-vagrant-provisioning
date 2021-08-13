# CBLMariner-vagrant-provisioning
This is an autodeployment using shell script for provisioning configuration and vagrant for allocating VM

The script is designed for ubuntu 18.04 as per Microsoft reccomendation but can be accomedated to RHEL based easily by changing the installation of qemu-utils to qemu-img(never tested but seems to be the equivelent)

Originally the skelaton was designed as a docker image but I've changed it to VM since Microsft added docker as a dependency it requires that the docker image which have added depdnedcies

Vagrant image is set to libvirt but can easily accomdated to any other virtualisation platform

Opted to a thin shell script to reduce dependencies.

Logs of the deployment will be found on the machine under /opt/logs

# Prerequiremets
Host with
1. git
1. vagrant
1. libvirtd(can be opted out by changing the Vagrantfile)


# Usage

1. Clone the repository to a system with libvirt and vagrant installed
1. run the command
```
vagrant up
```
1. SSH to the machine using vagrant ssh.
1. A git repositry will be up and ready under /opt/CBL-Mariner(stable). In addition there will be a build script under /opt/build that take a configuration image based on the environment variable *image* in case the desired result is appending to an autodeployment of an image
1. For manual instructions see [Microsoft documentation](https://github.com/microsoft/CBL-Mariner/blob/1.0/toolkit/docs/building/building.md#toolchain-stage)

# Known issues and particularites
* Due to the existing logging method error is not being pushed to the stderr can probably be fixed but wasn't within the scope of the initial release
