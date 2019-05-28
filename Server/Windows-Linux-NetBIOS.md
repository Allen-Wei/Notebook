# LAN主机通过主机名互相访问

Ref [Why can Windows machines resolve local names when Linux can't?](https://serverfault.com/questions/352305/why-can-windows-machines-resolve-local-names-when-linux-cant)

## 简述

Linux发行版一般使用**Avahi**包, 广播发现LAN其他主机. 假设LAN有一台Linux机器, 主机名为`ubuntu-desktop`, 和一台Windows机器, 主机名为`Windows-PC`. 从Linux机器中可以使用`ping Windows-PC.local`访问Windows主机, 从Windows机器使用`ping ubuntu-desktop`访问Linux主机.

## 原回答

I'm not a network expert, and I'm also researching a LOT for answers in this topic. My current findings are:

* Windows uses NetBIOS names, and such protocol, being a broadcast one, allows them to find each other without any central server.
* Linux machines in modern distros uses natively a protocol called Avahi, which is also a server-independent, broadcast protocol. Local network machines have a suffix `.local`, **so you can ping from Linux to Linux using ping `hostname.local`**, or see them with avahi-discover package. some apps in Gnome use avahi to list machines in the network (for example, the Remote Desktop Viewer)
* Installing SAMBA on a Linux machine will assign it a NetBIOS name (or, more technically, will make a Linux machine advertise itself in broadcast requests with their NetBIOS name, which is by default their hostname), and that allows Windows machines to find the Linux ones.
* Gotcha: Although Linux machines with Samba will reply to NetBIOS protocol requests, with default settings in distros like Ubuntu it won't use NetBIOS as a method to resolve names, and that's why Linux machines can't "see" each other or the Windows machines. For that, you need to edit `/etc/nsswitch.conf` file and add `wins` to the list in this line:

```
hosts:          files mdns4_minimal [NOTFOUND=return] dns wins mdns4
```

You may need to install `winbind` (and, if not installed automatically, `libnss-winbind`) package for the above to work.

So, for the visibility issue, you either install Samba on all Linux machines (and also edit /etc/nsswitch.conf to enable NetBIOS name resolution), or you install Avahi support in Windows machines.

As for file sharing, Samba provides Linux machines file-sharing capabilities with Windows. Theres no need to edit /etc/nsswitch.conf for Linux machines to see shared folders of each other and Windows (and vice-versa) in the "Network" section of Nautilus