# How To Install Development Tools In Linux

In this brief tutorial, we will be discussing how to install development tools in popular Linux distributions like Arch Linux, CentOS, RHEL, Fedora, Debian, Ubuntu, and openSUSE etc. These development tools includes all necessary applications, such as GNU GCC C/C++ compilers, make, debuggers, man pages and others which are needed to compile and build new softwares, packages.
 
## Install Development Tools In Linux

The developer tools can be installed either individually one by one or all at once. We are going to install all at once to make things much easier.

### Install Development Tools In Arch Linux and derivatives

To install development tools in Arch Linux and its derivatives like Antergos, Manjaro Linux, just run:

```sh
sudo pacman -Syyu
sudo pacman -S base-devel
```

There are 25 members in the Arch Linux development tools group, such as,

    autoconf
    automake
    binutils
    bison
    fakeroot
    file
    findutils
    flex
    gawk
    gcc
    gettext
    grep
    groff
    gzip
    libtool
    m4
    make
    pacman
    patch
    pkg-config
    sed
    sudo
    texinfo
    util-linux
    which

Just hit `ENTER` to install all of them.

### Install Development Tools In RHEL, CentOS, Scientific Linux, Fedora

To install development tools in Fedora, RHEL and its clones such as CentOS, Scientific Linux, run the following commands as root user.

```sh
yum update
yum groupinstall "Development Tools"
```

The above command is going to install all necessary developer tools, such as:

    autoconf
    automake
    bison
    byacc
    cscope
    ctags
    diffstat
    doxygen
    elfutils
    flex
    gcc/gcc-c++/gcc-gfortran
    git
    indent
    intltool
    libtool
    patch
    patchutils
    rcs
    subversion
    swig

### Install Development Tools In Debian, Ubuntu and derivatives

To install required developer tools in DEB based systems, run:

```sh
sudo apt-get update
sudo apt-get install build-essential
```

This command will all necessary packages to setup the development environment in Debian, Ubuntu and its derivatives.

    binutils
    cpp
    gcc-5-locales
    g++-multilib
    g++-5-multilib
    gcc-5-doc
    gcc-multilib
    autoconf
    automake
    libtool
    flex
    bison
    gdb
    gcc-doc
    gcc-5-multilib
    and many.

You now have the necessary development tools to develop a software in your Linux box.

### Install Development Tools In openSUSE/SUSE

To setup development environment in openSUSE and SUSE enterprise, run the following commands as root user:

```sh
zypper refresh
zypper update
zypper install -t pattern devel_C_C++
```

Verifying Installation

Now, Let us verify the develop tools have been installed or not. To do so, run:

```sh
gcc -v
make -v
```

As you see in the above output, the development tools have been successfully installed. Start developing your applications!

That’s all for today! On behalf of OSTechNix, I wish you a very Happy New Year 2017. May the new year bring new hopes and opportunities for you!

Cheers!!
