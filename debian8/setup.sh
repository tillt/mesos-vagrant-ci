cat << EOF > Vagrantfile
# -*- mode: ruby -*-" >
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  # Disable shared folder to prevent certain kernel module dependencies.
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.box = "bento/debian-8.2"

  config.vm.hostname = ENV['PLATFORM_NAME']

  config.vm.provider "virtualbox" do |vb|
    vb.memory = ENV['VAGRANT_MEM']
    vb.cpus = ENV['VAGRANT_CPUS']
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.provider "vmware_fusion" do |vb|
    vb.memory = ENV['VAGRANT_MEM']
    vb.cpus = ENV['VAGRANT_CPUS']
  end

  config.vm.provision "file", source: "../test.sh", destination: "~/test.sh"

  config.vm.provision "shell", inline: <<-SHELL
    # Update the entire system.
    sudo apt-get update

    # Install Mesos dependecies.
    sudo apt-get install -y openjdk-7-jdk autoconf libtool
    sudo apt-get install -y build-essential python-dev python-boto 	      \
    			    libcurl4-nss-dev libsasl2-dev maven libapr1-dev   \
    			    libsvn-dev libssl-dev libevent-dev

    # Install latest Docker.
    sudo wget -qO- https://get.docker.com/ | sh

    sudo docker info

    # Enable memory and swap cgroups.
    sudo echo "GRUB_CMDLINE_LINUX_DEFAULT=\"cgroup_enable=memory swapaccount=1\"" >>/etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg "$@"
  SHELL
end
EOF
