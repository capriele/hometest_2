#!/bin/bash
clean () {
  rm .hda.img || true
  sudo umount tmpmnt || true
  rm -rf tmpmnt || true
  sudo losetup -d ${HDA_LOOP_DEV} || true
}
trap clean ERR

# Start off with a clean env.
clean

# Create an empty 1G disk image.
truncate -s1G .hda.img

# Format the image with an MBR (aka msdos) partition table
# on the first sector of the HDD, which by convention the
# bios will load and execute.
/sbin/parted -s .hda.img mktable msdos

# Use the rest of the image (starting at the first MiB) as
# the primary bootable partition.
/sbin/parted -s .hda.img mkpart primary ext4 1 "100%"
/sbin/parted -s .hda.img set 1 boot on

# Attach the image to a loopback device. This will end up
# being something like /dev/loop0.  losetup will create
# another loopback device corresponding to just the ext4
# partition if `-P` is passed. The device's name will
# match the whole-disk loopback device's name, but with
# 'p1' suffixed.
HDA_LOOP_DEV=$(sudo losetup -Pf --show .hda.img)
FS_LOOP_DEV="${HDA_LOOP_DEV?}p1"

# Initialize the ext4 filesystem in the primary partition.
sudo mkfs -t ext4 -v "${FS_LOOP_DEV?}"

# Mount the ext4 FS and copy critical initial
# binaries, config files, kernel image, etc.
mkdir tmpmnt
sudo mount "${FS_LOOP_DEV?}" tmpmnt
sudo chown -R ${USER?} tmpmnt

# Install grub2.

# Grub will write some initial executable code to the boot
# sector (initial 512 bytes) of the image while preserving
# the MBR. That inital code will load some other code that
# will eventually be capable of reading an ext4 file
# system (the primary partition on the disk image).
# Configure the grub installation so that the relevant grub
# files on the ext4 partition are kept in a /boot/grub
# directory. (hd0) is grub terminology for /dev/sda (the
# entire disk), and (hd0,1) is grub terminology for
# /dev/sda1 (the primary ext4 partition).

# `grub-install` looks for device.map inside of
# --boot-directory, i.e. on the mounted image itself. There
# does not appear to be any flag option to override this.
# So write a `device.map` into the mounted fs where
# `grub-install` will find it and map the main loop device
# to the '(hd0)' grub device.
mkdir -p tmpmnt/boot/grub
echo "(hd0) ${HDA_LOOP_DEV?}" >tmpmnt/boot/grub/device.map
sudo grub-install \
  -v \
  --directory=/usr/lib/grub/i386-pc \
  --boot-directory=tmpmnt/boot \
  ${HDA_LOOP_DEV?} \
  2>&1

# Drop a minimal grub.cfg into the ext4 FS for grub to
# consult during boot. We do not want anything fancy. Just
# tell grub to use the serial port for IO and then
# immediately load and run the compiled kernel image.
cat >tmpmnt/boot/grub/grub.cfg <<EOF
serial
terminal_input serial
terminal_output serial
set root=(hd0,1)
linux /boot/bzImage \
  root=/dev/sda1 \
  console=ttyS0 \
  init=/bin/hello_world
boot
EOF

# Install the compiled kernel image into the ext4 FS.
# Grub will load the kernel from here and run it.
cp ./linux-stable/arch/x86/boot/bzImage tmpmnt/boot/bzImage

# Copy over userland binaries to run after boot.
# Arbitrarily stick them in /bin for now.
mkdir ./tmpmnt/bin/
cp -r bin tmpmnt

# Done! Wait until now to rename .hda.img -> hda.img
# so that there is a (ideally) a working image to boot from
# in the working directory.
mv .hda.img hda.img
clean