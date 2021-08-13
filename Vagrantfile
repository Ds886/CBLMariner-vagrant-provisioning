# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/ubuntu2004"
  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = 1
    libvirt.memory = 4096
  end

  config.vm.define :vboxhype do |vboxhype|
    vboxhype.vm.host_name = "virtbox"
    vboxhype.vm.network :public_network,
      :dev => "virbr0",
      :mode => "bridge",
      :type => "bridge"
    vboxhype.vm.provision "shell", path: "deployvbox.sh"
  end



end
