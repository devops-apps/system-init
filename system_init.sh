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


[ `id -u` -ne 0  ] && echo "The user no permission exec the scripts, Please use root is exec it..." && exit 0


read -p "Do you want Initialize the system of your system, please make sure the operation? please input [y/n]:" INPUT

#./start
if [ "$INPUT" = "y" ]; then


######### Install basic tools of system #########
yum install \
net-tools bind-utils vim \
lvm2 gcc gcc-c++ wget make automake \
pcre pcre-devel openssl openssl-devel zlib zlib-devel bios-devel -y >>/dev/null 2>&1
echo ".........................................................................."
echo "INFO: Install basic tools successd of system ..."

######### Change yum mirros images for system #########
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo >>/dev/null 2>&1
yum clean all  >>/dev/null 2>&1
yum makecache  >>/dev/null 2>&1
echo ".........................................................................."
echo "INFO: Changed the mirros success of yum ..."


######### Change interface name for network #########
sed -e "s:centos/swap rhgb:& net.ifnames=0 biosdevname=0:" /etc/sysconfig/grub 
grub2-mkconfig -o /boot/grub2/grub.cfg >>/dev/null 2>&1
cd /etc/sysconfig/network-scripts/
mv $ETH0 ifcfg-eth0
mv $ETH1 ifcfg-eth1

# Configure ip info of eth0
cat >/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
OTPROTO=static
DEFROUTE=yes
NAME=eth0
DEVICE=eth0
ONBOOT=yes
PREFIX=24
EOF
echo -e "IPADDR=$ETH0_IP"   >>/etc/sysconfig/network-scripts/ifcfg-eth0
echo -e "GATEWAY=$GATEWAY"   >>/etc/sysconfig/network-scripts/ifcfg-eth0

# Configure ip info of eth1
cat >/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
OTPROTO=static
DEFROUTE=yes
NAME=eth1
DEVICE=eth1
ONBOOT=yes
PREFIX=24
EOF
echo -e "IPADDR=$ETH1_IP"   >>/etc/sysconfig/network-scripts/ifcfg-eth001
echo ".........................................................................."
echo "INFO: Successful named network interface of system ..."


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
