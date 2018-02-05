#!/bin/bash
apt-get install --yes --force-yes debootstrap syslinux isolinux squashfs-tools genisoimage 
mkdir -p chroot
debootstrap --arch=i386 --variant=minbase stretch chroot http://ftp.us.debian.org/debian/
chroot chroot /spectre/install.sh

mkdir -p image/
mkdir -p image/{live,isolinux}
cp chroot/boot/isolinux.cfg image/isolinux/isolinux.cfg
(  cp chroot/boot/vmlinuz* image/live/vmlinuz1 && \
    cp chroot/boot/initrd* image/live/initrd1
)
git clone https://github.com/Neohapsis/creddump7.git chroot/spectre/creddump7
git clone https://github.com/SpiderLabs/Responder.git chroot/spectre/Responder
(cd image/ && \
	cp /usr/lib/ISOLINUX/isolinux.bin isolinux/ && \
	cp /usr/lib/syslinux/modules/bios/menu.c32 isolinux/ && \
	cp /usr/lib/syslinux/modules/bios/hdt.c32 isolinux/ && \
	cp /usr/lib/syslinux/modules/bios/ldlinux.c32 isolinux/ && \
	cp /usr/lib/syslinux/modules/bios/libutil.c32 isolinux/ && \
	cp /usr/lib/syslinux/modules/bios/libmenu.c32 isolinux/ && \
	cp /usr/lib/syslinux/modules/bios/libcom32.c32 isolinux/ && \
	cp /usr/lib/syslinux/modules/bios/libgpl.c32 isolinux/ && \
	cp /usr/share/misc/pci.ids isolinux/ \
)
rm -f image/live/filesystem.squashfs scarlet-spectre.iso
mksquashfs chroot image/live/filesystem.squashfs -e boot
genisoimage -rational-rock \
	    -volid "Scarlet Spectre"\
       	    -cache-inodes\
       	    -joliet\
       	    -hfs\
       	    -full-iso9660-filenames\
       	    -b isolinux/isolinux.bin\
       	    -c isolinux/boot.cat\
       	    -no-emul-boot\
       	    -boot-load-size 4\
       	    -boot-info-table\
       	    -output scarlet-spectre.iso\
	     image;
