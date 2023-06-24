#!/bin/bash

# Checking dependencies
echo -n "Checking dependencies... "
for name in qemu qemu-system-x86 util-linux build-essential bison flex libssl-dev libelf-dev bc initramfs-tools-core git
do
  [[ $(which $name 2>/dev/null) ]] || { deps=1; }
done

# Installing dependencies
[[ $deps -ne 1 ]] && echo "All dependencies installed" || { 
  echo -n "Installing dependencies... "
  sudo apt install -y qemu qemu-system-x86 util-linux build-essential bison flex libssl-dev libelf-dev bc initramfs-tools-core
}

# Downloading linux kernel
echo "Prepare the workspace"
if [ -d linux-stable ]; then rm -rf linux-stable; fi
if [ -d bin ]; then rm -rf bin; fi
if [ -f hda.img ] ; then rm hda.img; fi

echo "Clone latest linux stable kernel"
git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
cd linux-stable

echo "Just use a default config for now, and slim it down later"
make defconfig

echo "Compile the kernel image"
make -j$(nproc)
cd ..

echo "Adding custom start-up program that prints \"hello world\""
mkdir -p bin && cd bin && touch hello_world.c
cat <<EOT > hello_world.c
#include <stdio.h>
#include <unistd.h>

int main(int argc, char** argv) {
  printf("hello world\r\n");
  while (1) sleep(10);
  return 0;
}
EOT
gcc -Wall -static hello_world.c -o hello_world
cd ..

# Create the qemu image
bash create_qemu_image.sh

# Booting the image
bash boot_qemu.sh