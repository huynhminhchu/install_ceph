###This script automates set up hostname, ip for one ceph node 
### REMEMBER TO CHANGE THE PARAMETER because i dont have time to set up dynamic variable

yum update -y
yum install epel-release -y
yum update -y
yum install wget byobu curl git byobu python-setuptools python-virtualenv -y


###Remember to change hostname , for ex : ceph2 ceph3
hostnamectl set-hostname ceph1

###Remember to change IP,interface 
echo "Setup IP  ens32"
nmcli con modify ens32 ipv4.addresses 192.168.98.85/24
nmcli con modify ens32 ipv4.gateway 192.168.98.1
nmcli con modify ens32 ipv4.dns 8.8.8.8
nmcli con modify ens32 ipv4.method manual
nmcli con modify ens32 connection.autoconnect yes

echo "Setup IP  ens33"
nmcli con modify ens33 ipv4.addresses 192.168.62.85/24
nmcli con modify ens33 ipv4.method manual
nmcli con modify ens33 connection.autoconnect yes

echo "Setup IP  ens34"
nmcli con modify ens34 ipv4.addresses 192.168.63.85/24
nmcli con modify ens34 ipv4.method manual
nmcli con modify ens34 connection.autoconnect yes

# Disable firewall, networkmanager
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo systemctl disable NetworkManager
sudo systemctl stop NetworkManager
sudo systemctl enable network
sudo systemctl start network

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf

# Declare hostname
cat << EOF > /etc/hosts
127.0.0.1 `hostname` localhost
192.168.10.9 client1
192.168.10.10 ceph1
192.168.10.11 ceph2
192.168.10.12 ceph3

192.168.20.9 client1
192.168.20.10 ceph1
192.168.20.11 ceph2
192.168.20.12 ceph3
EOF

# Install ntpd to synchronize time
yum install -y chrony

systemctl enable chronyd.service
systemctl start chronyd.service
systemctl restart chronyd.service
chronyc sources


# Add user cephuser
useradd cephuser; echo 'chudeptrai123' | passwd cephuser --stdin
echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
chmod 0440 /etc/sudoers.d/cephuser

cat << EOF > /etc/yum.repos.d/ceph.repo
[ceph]
name=Ceph packages for $basearch
baseurl=https://download.ceph.com/rpm-nautilus/el7/x86_64/
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=https://download.ceph.com/rpm-nautilus/el7/noarch
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=https://download.ceph.com/rpm-nautilus/el7/SRPMS
enabled=0
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc
EOF

yum update -y
