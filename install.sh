#!/bin/bash -ex
red='\x1B[0;31m'
green='\x1B[0;32m'
blue='\x1B[0;34m'
white='\x1B[0;37m' 
reset='\x1B[0;m'
bold='\x1B[1;m'
fail=`printf " ${blue}${bold}[${red}${bold}!${blue}${bold}]${reset}"`
success=`printf " ${blue}${bold}[${green}${bold}*${blue}${bold}]${reset}"`
info=`printf " ${blue}${bold}[${white}${bold}i${blue}${bold}]${reset}"`

_process_handlers () {
	echo -e "${bold}Process handlers:${reset}"
	echo -e "${fail}: for error"
	echo -e "${success}: for success"
	echo -e "${info}: for info"
	printf "${bold}Apertis Setup needs 50GB free space for dotfiles to compile binaries and libraries, running ansible tasks, suckless' dwm and dmenu setup and more use.${reset}"
	sleep 5
	echo
}

_setup_disks () {
	# Wiping entire disk
	wipefs --all /dev/sda
	sgdisk /dev/sda -o
	sgdisk /dev/sda -n 1::+512MiB -c 1:"efi" -t 1:ef00
	mkfs.vfat -F32 -n "EFI"  /dev/sda1
	sgdisk /dev/sda -n 2::+1GiB   -c 2:"swap" -t 2:8200
	mkswap         -L "SWAP" /dev/sda2
	sgdisk /dev/sda -n 3          -c 3:"fs"
	pvcreate /dev/sda3
	vgcreate lvm_aptis /dev/sda3
	lvcreate -n fs lvm_aptis
	cryptsetup luksFormat /dev/lvm_aptis/fs
	cryptsetup open /dev/lvm_aptis/fs aptis-fs
	mkfs.ext4      -L "FS"   /dev/mapper/aptis-fs
	mount /dev/mapper/aptis-fs /mnt
}

_setup_container () {
	curl -sLo- https://images.apertis.org/release/v2022/v2022.3/amd64/isolation-sysroot/isolation_sysroot-v2022-amd64-v2022.3.tar.gz | tar -zxf- -C /mnt
	rm /mnt/etc/resolv.conf
	cat > /mnt/etc/resolv.conf < EOF
	nameserver 8.8.8.8
	nameserver 8.8.4.4
	nameserver 4.4.4.4
	EOF 
}

_setup_binds () {
	mount -B /dev /mnt/dev
	mount -B /dev/pts /mnt/dev/pts
	mount -B /proc /mnt/proc
	mount -B /sys /mnt/sys
	mount -B /run /mnt/run
	modprobe efivarfs
}

_setup () {
	_subscripts=(
		disks
		container
		binds
	)
	local _subscript
	for _subscript in ${_subscripts[@]}; do
		_setup_${_subscript}
	done
}

_chroot () {
	mkdir /mnt/{sources,scripts}
	cp chroot/stage1.sh /mnt/scripts/chroot-stage1.sh
	chroot /mnt /scripts/chroot-stage1.sh
}

_full_install () {
	_process_handlers
	_setup
	_chroot
}

_check_efi () {
	if [ ! -d "/sys/firmware/efi" ]; then
                echo -e "${fail}: EFI partitions are only can do that."
		exit 1
	fi
}

_question () {
	printf "${info}: Do you want to install Apertis? [yes/no]"
	read option
	if [ "$option" = "yes" ];then
		_setup
	elif [ "$option" = "no" ];then
		echo
		echo -e "${failed}: Installation aborted!"
		exit 1
	else
		echo -e "${failed}: Invalid option: $option"
		exit 1
	fi
}

if [ "$UID" != "0" ]; then
	echo -e "${fail}: You must have a root access to do that."
	exit 1
fi
ping -c 5 apertis.org || {
	echo -e "${fail}: Network error!"
        echo -e "${fail}: Check your internet connection and try again."
}
_check_efi
_question
