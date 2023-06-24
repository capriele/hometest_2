# Home Test

## Exercise 1
Bootable Linux image via QEMU
In this exercise you are expected to create a shell script that will run in a Linux environment (will be
tested on Ubuntu 20.04 LTS or 22.04 LTS). This shell script should create and run an AMD64 Linux
filesystem image using QEMU that will print “hello world” after successful startup. Bonus points for
creating a fully bootable filesystem image (but not mandatory). The system shouldn’t contain any
user/session management or prompt for login information to access the filesystem.
You can use any version/flavor of the Linux kernel. The script can either download and build the kernel
from source on the host environment or download a publicly available pre-built kernel.
The script shouldn’t ask for any user input unless superuser privileges are necessary for some
functionality, therefore any additional information that you require for the script should be available in
your repository.
The script should run within the working directory and not consume any other locations on the host file
system.

### Step 1: Installing qemu (if needed)

I'm supposing that in the system there are already installed the following tool:
- qemu
- qemu-system-x86
- util-linux
- build-essential
- bison
- flex
- libssl-dev
- libelf-dev
- bc
- initramfs-tools-core
in any case the script check if all the packages are installed otherwise ask for the root password in order to install them.

All the work has been divided into three main scripts:
 1. `run.sh`
 2. `create_qemu_image.sh`
 3. `boot_qemu.sh`

The first one (`run.sh`) executes the following tasks:
- checks/installs all the dependencies
- downloads the latest stable linux kernel
- configures the kernel with the default configuration
- compiles the kernel
- after that it will simply runs the second script and after its completition the third one

The second script (`create_qemu_image.sh`) creates a new disk hda image (ext4 formatted) in which:
- installs grub
- copies the compiled kernel (the bzImage) and the custom user application which will be executed after the kernel boot

The third script (`boot_qemu.sh`) simply boots the qemu image just created.

## Exercise 2
Shred tool in Go
Implement a Shred(path) function that will overwrite the given file (e.g. “randomfile”) 3 times with
random data and delete the file afterwards. Note that the file may contain any type of data.
You are expected to give information about the possible test cases for your Shred function, including
the ones that you don’t implement, and implementing the full test coverage is a bonus :)
In a few lines briefly discuss the possible use cases for such a helper function as well as advantages and
drawbacks of addressing them with this approach.

### Install go (if needed)
```bash
sudo apt install golang-go 
```
I've implemented the requested function in the file `main.go`. This file can be tested executing the following command

```bash
go test
```

that will run all the tests implemented into `main_test.go`.

I tested the software in the following cases:
- passing as argument a real file
- passing no argument
- passing as argument a fake file

I think that in this way I fully covered all the cases.

A function like this could be used in order to improve data privacy because for some hardware constraints it could happen that the file (or a portion of it) still remains inside some part of the mass storage. 
If you write the file more times before deleting it you are securing its real content.