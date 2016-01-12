cat << EOF > Vagrantfile
# -*- mode: ruby -*-" >
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  config.vm.hostname = "$PLATFORM_NAME"

  config.vm.box = "bento/centos-6.7"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = $VAGRANT_MEM
    vb.cpus = $VAGRANT_CPUS
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.provider "vmware_fusion" do |vb|
    vb.memory = $VAGRANT_MEM
    vb.cpus = $VAGRANT_CPUS
  end

  config.vm.provision "file", source: "../test.sh", destination: "~/test.sh"

  config.vm.provision "shell", path: "provision.sh"

  config.vm.synced_folder ".", "/vagrant", disabled: true
end
EOF
