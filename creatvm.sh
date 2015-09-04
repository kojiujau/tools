#!/bin/bash

export VMname=$1
# Make sure script with parameters
if [ ! $# -eq 1 ] ; then
	echo -e "This script will builds guest vm host.\n"
	echo -e "usage: bash $0 [VM_image_name] \n"
	exit 1
fi


if [ -f "$1.vdi" -o -d "$1" ] ; then
	echo -e "${VMname} already exist in here!!"
	exit 1
fi

vboxmanage createvm --name ${VMname} --ostype Ubuntu_64 --register
vboxmanage createhd --filename ${VMname}.vdi --size 10000 
vboxmanage storagectl ${VMname} --name "IDE Controller" --add ide --controller PIIX4 
vboxmanage storageattach ${VMname} --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium ${VMname}.vdi
vboxmanage modifyvm ${VMname} --nic1 bridged --bridgeadapter1 eth1
vboxmanage list vms
