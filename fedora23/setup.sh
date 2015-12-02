cat << EOF > Vagrantfile
# -*- mode: ruby -*- >
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  # Disable shared folder to prevent certain kernel module dependencies.
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.box = "box-cutter/fedora23"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = $VAGRANT_MEM
    vb.cpus = $VAGRANT_CPUS
    v.customize [
      "modifyvm", :id,
      "--nictype", "virtio"
      "--natdnshostresolver1", "on"
      "--natdnsproxy1", "on"
      "--paravirtprovider", "kvm"
    ]
  end

  config.vm.provider "vmware_fusion" do |vb|
    vb.memory = $VAGRANT_MEM
    vb.cpus = $VAGRANT_CPUS
  end

  config.vm.provision "file", source: "../test.sh", destination: "~/test.sh"

  config.vm.provision "shell", inline: <<-SHELL
    dnf -y upgrade
    dnf -y install @development-tools
    dnf -y install @c-development
    dnf -y install patch python-boto python-devel libcurl-devel openssl-devel \
                   cyrus-sasl-devel cyrus-sasl-md5 apr-devel subversion-devel \
                   apr-util-devel libevent-devel redhat-rpm-config
    dnf -y install perf nmap-ncat
    dnf -y install docker
    dnf -y install java-1.8.0-openjdk-devel maven
    systemctl start docker
    systemctl enable docker
    docker info
  SHELL
end
