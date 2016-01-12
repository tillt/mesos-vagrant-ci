yum update -y

# Kernel 3.10 (required for process isolation and/or Docker)
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-6-6.el6.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install -y kernel-lt
sed -i "s/default=1/default=0/g" /boot/grub/grub.conf

# Add Subversion 1.8 repo
cat << EOF > wandisco-svn.repo
[WANdiscoSVN]
name=WANdisco SVN Repo 1.8
enabled=1
baseurl=http://opensource.wandisco.com/centos/6/svn-1.8/RPMS/\$basearch/
gpgcheck=1
gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
EOF
mv wandisco-svn.repo /etc/yum.repos.d/

# Add Docker repo
cat << EOF > docker.repo
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/\$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
mv docker.repo /etc/yum.repos.d/

# Add Apache maven repo
wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo

yum install -y tar wget git which nss libtool patch
yum install -y scl-utils centos-release-scl-rh
yum install -y devtoolset-3-toolchain

# Use devtoolset-3 by default
cat << EOF >"enabledevtoolset3.sh"
#!/bin/bash
source /opt/rh/devtoolset-3/enable
export X_SCLS="`scl enable devtoolset-3 'echo $X_SCLS'`"
EOF
mv enabledevtoolset3.sh /etc/profile.d/

# Mesos dependencies
yum install -y apache-maven python-devel java-1.8.0-openjdk-devel zlib-devel libcurl-devel openssl-devel cyrus-sasl-devel cyrus-sasl-md5 apr-devel subversion-devel apr-util-devel

# Mesos testing dependencies
yum install -y perf nc

# Enable cgroups
cat << EOF > cgconfig.conf
mount {
    cpuset  = /cgroup/cpuset;
    cpu = /cgroup/cpu;
    cpuacct = /cgroup/cpuacct;
    memory  = /cgroup/memory;
    devices = /cgroup/devices;
    freezer = /cgroup/freezer;
    net_cls = /cgroup/net_cls;
    blkio   = /cgroup/blkio;
    perf_event = /cgroup/perf_event;
}
EOF
mv cgconfig.conf /etc/cgconfig.conf
chkconfig cgconfig on

# Enable Docker
yum install -y docker-engine
chkconfig docker on
