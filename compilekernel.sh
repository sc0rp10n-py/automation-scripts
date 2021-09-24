#!/bin/sh
sudo pacman -S pahole bc cpio
wget  https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.14.3.tar.xz
tar -xvf linux-5.14.3.tar.xz
cd linux-5.14.3.tar.xz
wget https://bit.ly/3kBUZhR
mv 3kBUZhR .config
echo "MAKE COMMAND"
make
echo "AGAIN MAKE TO CONFIRM"
make
echo "MAKE MODULES NOW"
sudo make modules_install
sudo cp arch/x86_64/boot/bzImage /boot/vmlinuz-linux-5.14.3
sudo cp System.map System.map-5.14.3
sudo mkinitcpio -k 5.14.3 -g /boot/initramfs-linux-5.14.3.img
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
