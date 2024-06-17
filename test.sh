#!/bin/bash
#config.sh
PROGRAMS=(
	#terminal
	zoxide zsh
	alacritty
	ripgrep fzf
	btop fastfetch
	#neovim
	neovim
	unzip fd
	#browser
	firefox
	#version control
	chezmoi git gh
	#man
	man-db
	man-pages
	tldr
	texinfo
	#hyprland
	hyprland
	sddm
	#misc
	plocate
)
SHELL=/usr/bin/zsh
USERNAME=nub
HOSTNAME=nubdesk
ROOT=""
BOOT=""
SWAP=""
#EOconfig.sh
read -p "init? (y/N): " init
if [[ "$init" = "y" || "$init" = "Y" ]]; then 
	timedatectl set-timezone America/Chicago

	fdisk -l
	read -p "part?" part
	if [[ "$part" = "y" || "$part" = "Y" ]]; then 
		read -p "disk: " disk
		fdisk $disk
	fi

	while true; do
		read -p "boot: " BOOT
		read -p "root: " ROOT
		read -p "swap: " SWAP
		read -p "jawohl? (y/N): " ja
		if [[ "$ja" = "y" || "$ja" = "Y" ]]; then 
			break
		fi
	done

	echo "formatting..."
	mkfs.fat -F 32 $BOOT
	mkfs.ext4 $ROOT
	mkswap $SWAP

	mount $BOOT /mnt
	mount --mkdir $BOOT /mnt/boot
	swapon $SWAP

	pacstrap -K /mnt base linux linux-firmware intel-ucode nvidia networkmanager neovim #duplicate

	read -p "fstab? (y/N): " fstab
	if [[ "$fstab" = "y" || "$fstab" = "Y" ]]; then 
		genfstab -U /mnt >> /mnt/etc/fstab
	fi

	arch-chroot /mnt

	echo "setting time and locale..."
	ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
	hwclock --systohc

	sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
	localectl set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"

	echo $HOSTNAME > /etc/hostname

	sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

	mkinitcpio -P

	passwd

	exit

	umount -R /mnt
	
	read -p "done. reboot? (y/N): " reboot
	if [[ "$reboot" = "y" || "$reboot" = "Y" ]]; then 
		reboot now
	fi
fi
