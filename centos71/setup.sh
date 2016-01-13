cat << EOF > Vagrantfile
# -*- mode: ruby -*-" >
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  # Disable shared folder to prevent certain kernel module dependencies.
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.box = "bento/centos-7.1"

  config.vm.hostname = "$PLATFORM_NAME"

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

  config.vm.provision "shell", inline: <<-SHELL
     yum -y update systemd
     yum -y install tar wget
     yum groupinstall -y "Development Tools"
     yum install -y maven python-devel java-1.7.0-openjdk-devel    \
                    zlib-devel libcurl-devel openssl-devel         \
                    cyrus-sasl-devel cyrus-sasl-md5 apr-devel      \
                    subversion-devel apr-util-devel libevent-devel

     yum install -y git

     yum install -y docker
     chkconfig docker on
     service docker start
     docker info
  SHELL
end
EOF
