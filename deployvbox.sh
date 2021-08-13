#!/bin/bash

## Variables
# Setup logging
mkdir -p /opt/logs
strDeploymentLogs='/opt/logs/deployment.log'
touch $strDeploymentLogs
exec &> >(tee  -a /opt/logs/deployment.log)


# Autodetect system information
strInternalIP=$(ip addr show dev eth1 |egrep '.*inet\b.*'|head -n1|awk '{print $2}'|cut -d'/' -f1)
strHostnameSingle=$(hostname|cut -d'.' -f1)

echo "================= Starting deployment of CBL Mariner server ================= "

echo "Deployment logs release = $strDeploymentLogs"
echo "Internal IP = $strInternalIP"
echo "Hostname = $strHostnameSingle"

echo "******************** Set hosts file ********************"

# Set the host file with the internal IP in case it is not addded
if ! grep -q $strInternalIP /etc/hosts; then
sudo tee -a /etc/hosts > /dev/null << EOT
$strInternalIP $(hostname) $strHostnameSingle
EOT
	echo "Hosts file set"
else
	echo "Hosts file already set"
fi

echo "******************** Installing prerequirements ********************"

# Setting up dependencies for the script

echo "Adding cusotm golang"
if [ ! -e /etc/apt/sources.list.d/longsleep-ubuntu-golang-backports-focal.list ];then
	echo "Adding golang repository"
	sudo apt-get update
	sudo apt-get install -y software-properties-common
	sudo add-apt-repository ppa:longsleep/golang-backports
else
	echo "Skipping adding golang repository"
fi


echo "******************** Installing packages ********************"

echo "Updating and upgrading the system"
sudo apt-get update
sudo apt-get upgrade -y

function InstallPackage()
{
	packageFile=$1
	packageName=$2
	echo "Checing package: $packageFile"
	echo "**********************************"
	packageCurrent=$(which $packageFile)
	if [ -z $packageCurrent ];then
		echo "Installing package: $packageName"
		sudo apt-get -y install $packageName

		packageCurrent=$(which $packageFile)
		if [ -z $packageCurrent ];then
			echo "Error in installing $packageName"  1>&2
		fi
	else
		echo "Skipping installing package: packageName - No need to install the package: $packageName"
	fi
}

# Basic dependencies taken from https://github.com/microsoft/CBL-Mariner/blob/1.0/toolkit/docs/building/prerequisites.md
commands=( tar make wget curl rpm genisoimage python2.7 bison gawk parted pigz )
echo "Installing pacakges $commands"

for package in ${commands[@]}; do
	InstallPackage $package $package
done

# Installing go
if [ ! -e '/usr/bin/go' ];then
	InstallPackage "go" "golang-1.15-go"
	sudo ln -vsf /usr/lib/go-1.15/bin/go /usr/bin/go
fi

InstallPackage "qemu-img" "qemu-utils"

# Installing docker
currentPackage=$(which docker)
if [ -z $currentPackage ];then
	echo "Installing docker"
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
	sudo usermod -aG docker vagrant
else
	echo "No need to install docker"
fi

# Export folder needed for the building.
export CHROOT_DIR=/opt/chroot


echo "******************** Cloning repository ********************"
# Cloning repo
mkdir -p /opt
cd /opt
if [ ! -e /opt/CBL-Mariner ];then
	git clone https://github.com/microsoft/CBL-Mariner.git
	cd /opt/CBL-Mariner
	git checkout 1.0-stable
fi

#setting chroot folder
mkdir -p /opt/chroot

#setting buildscript
tee -a /opt/build.sh << END
#!/bin/sh

cd /opt/CBL-Mariner
git fetch

export CHROOT_DIR='/opt/chroot/'

cd toolkit

if [ -z "$image" ]; then
	make iso REBUILD_TOOLS=y REBUILD_PACKAGES=n CONFIG_FILE=./imageconfigs/core-legacy.json
else
	make iso REBUILD_TOOLS=y REBUILD_PACKAGES=n CONFIG_FILE=$image
fi
END

chmod +x /opt/build.sh
