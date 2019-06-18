#!/bin/bash
#
# Description: This is sysytem optimization scripts about centos !
################################################################
# Author：Kevin li
# Blog: https://blog.51cto.com/blief
# QQ: 2658757934
# Date: 2019.5.28
################################################################

# Variable settings
PATH=/bin:/sbin:/usr/bin:/usr/sbin && export PATH
ETH0=ifcfg-ens192
ETH1=ifcfg-ens224
ETH0_IP=192.168.20.100
ETH1_IP=10.10.10.100
GATEWAY=192.168.20.1
HOSTNAME=example.template.com
NAMESERVER1=10.10.10.30
NAMESERVER2=10.10.10.31 
INTERFACE_NUM=$(ls /etc/sysconfig/network-scripts/ifcfg-e* | wc -l)


[ `id -u` -ne 0  ] && echo "The user no permission exec the scripts, Please use root is exec it..." && exit 0

read -p "Do you want Initialize the system of your system, please make sure the operation? please input [y/n]:" INPUT

#./start
if [ "$INPUT" = "y" ]; then

######### Install basic tools of system #########
sudo yum install \
net-tools bind-utils vim telnet rsync \
lvm2 gcc gcc-c++ wget make automake \
pcre pcre-devel openssl openssl-devel zlib zlib-devel bios-devel -y >>/dev/null 2>&1
echo ".........................................................................."
echo "INFO: Install basic tools successd of system ..."


######### basic configure of system #########

sudo sed -i "/nameserver $NAMESERVER1/d"  /etc/resolv.conf
sudo sed -i "/nameserver $NAMESERVER2/d"  /etc/resolv.conf
echo -e "nameserver $NAMESERVER1" >> /etc/resolv.conf
echo -e "nameserver $NAMESERVER2" >> /etc/resolv.conf
sudo true > /etc/hostname
echo -e "$HOSTNAME" > /etc/hostname
sudo sed -i "/$HOSTNAME/d"  /etc/hosts 
echo -e "$ETH1_IP $HOSTNAME" >> /etc/hosts
echo ".........................................................................."
echo "INFO: Basic configure of system is success ..."


######### Change yum mirros images for system #########
sudo mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo >>/dev/null 2>&1
yum install -y epel-release  >>/dev/null 2>&1
sudo yum clean all  >>/dev/null 2>&1
sudo yum makecache  >>/dev/null 2>&1
echo ".........................................................................."
echo "INFO: Changed the mirros success of yum ..."

if [ $INTERFACE_NUM == 1 ]; then
######### Change interface name for network #########
sudo cp /etc/default/grub{,.bak}
sudo sed -i "s:net.ifnames=0 biosdevname=0::" /etc/sysconfig/grub 
sudo sed -i "s:centos/swap  rhgb:& net.ifnames=0 biosdevname=0:" /etc/sysconfig/grub 
sudo grub2-mkconfig -o /boot/grub2/grub.cfg >>/dev/null 2>&1
cd /etc/sysconfig/network-scripts/
sudo mv $ETH0 ifcfg-eth0  >>/tmp/init.log 2>&1

# Configure ip info of eth0
cat >/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
OTPROTO=static
DEFROUTE=yes
NAME=eth0
DEVICE=eth0
ONBOOT=yes
PREFIX=24
IPADDR=${ETH0_IP}
GATEWAY=${GATEWAY}
EOF
fi

if [ $INTERFACE_NUM == 2 ]; then
######### Change interface name for network #########
sudo cp /etc/default/grub{,.bak}
sudo sed -i "s:net.ifnames=0 biosdevname=0::" /etc/sysconfig/grub 
sudo sed -i "s:centos/swap  rhgb:& net.ifnames=0 biosdevname=0:" /etc/sysconfig/grub  
sudo grub2-mkconfig -o /boot/grub2/grub.cfg >>/dev/null 2>&1
cd /etc/sysconfig/network-scripts/
sudo mv $ETH0 ifcfg-eth0  >>/tmp/init.log 2>&1
sudo mv $ETH1 ifcfg-eth1  >>/tmp/init.log 2>&1

# Configure ip info of eth0
cat >/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
OTPROTO=static
DEFROUTE=yes
NAME=eth0
DEVICE=eth0
ONBOOT=yes
PREFIX=24
IPADDR=${ETH0_IP}
GATEWAY=${GATEWAY}
EOF

# Configure ip info of eth1
cat >/etc/sysconfig/network-scripts/ifcfg-eth1 <<EOF
OTPROTO=static
DEFROUTE=yes
NAME=eth1
DEVICE=eth1
ONBOOT=yes
PREFIX=24
IPADDR=${ETH1_IP}
EOF
echo ".........................................................................."
echo "INFO: Successful named network interface of system ..."
fi

######### Reboot server system #########
read -p "Initializes system success!, But it is need reboot now, please input [y/n]:" ID
if [ "$ID" = "y" ]; then
     reboot now
fi
if [ "$ID" = "n" ]; then
     exit 0
fi

fi
#./End

if [ "$INPUT" = "n" ]; then
     exit 0
fi
