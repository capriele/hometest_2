#!/bin/bash
qemu-system-x86_64 `
  # Just configure with a single disk which maps hda.img.
  # mkimg.sh did the following in preparation:
  #
  # - formatted hda.img with an MBR and a single
  #   bootable primary ext4 partition.
  #
  # - copied compiled kernel bzImage onto primary
  #   partition's /boot/bzImage.
  #
  # - installed grub2 onto hda.img's boot sector and the
  #   boot partition's /boot/grub tree.
  #
  # - wrote a /minimal/ grub.cfg to /boot/grub/grub.cfg
  #   which will immediately boot into linux.
 `-hda hda.img \
  `
  # Do not emulate any graphics. We only want serial IO so
  # we can work over ssh.
 `-display none \
  `
  # Create a character device named 'terminal', and tell
  # qemu to hook it into the qemu processes's stdin and
  # stdout. This doesn't do anything on its own.
 `-chardev stdio,id=terminal,mux=on \
  `
  # Emulate a special device in qemu. Seabios will
  # automatically write debug logs to this device. Plug it
  # into our 'terminal' chardev so that we see bios logs
  # after invoking qemu.
 `-device isa-debugcon,iobase=0x402,chardev=terminal \
  `
  # Connect the emulated serial port into our 'terminal'
  # chardev, which is connected to stdin and stdout of
  # qemu, so that we can directly interact with the
  # machine.
 `-serial chardev:terminal