#!/usr/bin/env bash

cat << EOF > Vagrantfile
# -*- mode: ruby -*-" >
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  # Disable shared folder to prevent certain kernel module dependencies.
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.box = "bento/ubuntu-14.04"

  config.vm.hostname = "${PLATFORM_NAME}"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = ${VAGRANT_MEM}
    vb.cpus = ${VAGRANT_CPUS}
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.provider "vmware_fusion" do |vb|
    vb.memory = ${VAGRANT_MEM}
    vb.cpus = ${VAGRANT_CPUS}
  end

  config.vm.provision "file", source: "../test.sh", destination: "~/test.sh"

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get -y install openjdk-7-jdk autoconf libtool
    apt-get -y install build-essential python-dev python-boto          \
                       libcurl4-nss-dev libsasl2-dev maven             \
                       libapr1-dev libsvn-dev libssl-dev libevent-dev
    apt-get -y install git
    wget -qO- https://get.docker.com/ | sh
  SHELL
end
EOF
