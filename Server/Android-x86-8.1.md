# Release Note 8.1-r5

The Android-x86 project is glad to announce the 8.1-r5 release to public. This is the fifth stable release for Android-x86 8.1 (oreo-x86). The prebuilt images are available in the following site as usual:

    https://www.fosshub.com/Android-x86-old.html
    https://osdn.net/rel/android-x86/Release%208.1


## Key Features

The 8.1-r5 is mainly a security updates of [8.1-r4](https://www.android-x86.org/releases/releasenote-8-1-r4.html) with some bugfixes. We encourage users of 8.1-r4 or older releases upgrade to this one.

* Update to latest Android 8.1.0 Oreo MR1 release (8.1.0_r76).
* Update to LTS kernel 4.19.122.
* Fix sdcardfs permissions issue.
* Enable serial gps.
* Add more devices specific quirks.
* Fix read-write mode support in auto-update.


## Released Files

This release contains these files. You can choose one of them depends on your devices. Most modern devices should be able to run the 64-bit ISO. For older devices with legacy BIOS, you may try the 32-bit ISO.

> 64-bit ISO:  android-x86_64-8.1-r5.iso
> 
> sha1sum: 130a8a712ee0753eb3475465647efd61296a8afb
> 32-bit ISO:  android-x86-8.1-r5.iso
> 
> sha1sum: eedc18b3d362d1f0805339c2617b882c02bb340d
> 64-bit rpm:  android-x86-8.1-r5.x86_64.rpm
> 
> sha1sum: 7e22066aaf74a9e3ac68a1278016c17b43b96718
> 32-bit rpm:  android-x86-8.1-r5.i686.rpm
> 
> sha1sum: 27be9535d7e7258111ed485b8bb39414a27e8127
> 64-bit ISO with kernel 4.9:  android-x86_64-8.1-r5-k49.iso
> 
> sha1sum: a002e414e20b846d7f1fa4a640e5b75bbe508db7
> Recommended for VMware users

To use an ISO file, Linux users can dump it into a usb drive by dd command like:

```bash
dd if=android-x86_64-8.1-r5.iso of=/dev/sdX
```

where `/dev/sdX` is the device name of your usb drive.

Windows's users can use the tool [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/) to create a bootable usb stick.

Please read this page about how to install it to the device.

Except the traditional ISO files, we also package android-x86 files into a Linux package rpm. It allows Linux users to easily install the release into an existing Linux device with a standalone ext4 root partition. On an rpm based device (Fedora/Red Hat/CentOS/SUSE...), just install it like a normal rpm package:
```bash
sudo rpm -Uvh android-x86-8.1-r5.x86_64.rpm
```

This will update your older installation like 7.1-r3 or 8.1-r4 if you have.

On a deb based device (Debian/Ubuntu/LinuxMint/...), please use the alien tool to install it:
```bash
sudo apt install alien
sudo alien -ci android-x86-8.1-r5.x86_64.rpm
```

All files will be installed to the /android-8.1-r5/ subdirectory and boot entries will be added to grub2 menu. Reboot and choose android-x86 item from the menu to boot Android-x86. Alternatively, you can launch Android-x86 in a QEMU virtual machine by the installed qemu-android script:
sudo qemu-android

Note Android-x86 running in QEMU and the real machine (after rebooting) share the same data sub-folder.
To uninstall it :
```bash
sudo rpm -e android-x86
```
or (on Debian/Ubuntu/LinuxMint/...)
```bash
sudo apt-get remove android-x86
```

Source code
The source code is available in the main git server.
```bash
repo init -u git://git.osdn.net/gitroot/android-x86/manifest -b oreo-x86 -m android-x86-8.1-r5.xml
repo sync --no-tags --no-clone-bundle
```

Read this page for how to compile source code.

To build 8.1-r5 with kernel 4.9, sync the source tree as above commands, then

```bash
cd kernel
git fetch x86 kernel-4.9
git checkout -t x86/kernel-4.9
cd ..
```
Then build the source as usual.