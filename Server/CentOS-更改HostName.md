## CentOS 更改 hostname

> [How to change hostname in CentOS/RHEL 7](https://www.thegeekdiary.com/centos-rhel-7-how-to-change-set-hostname/)

Unlike CentOS/RHEL 6, manually appending “HOSTNAME=xxxxx” into file /etc/sysconfig/network and restarting system will not work on CentOS/RHEL 7, in order to change/set the hostname. There 4 ways to change the hostname in CentOS/RHEL 7 :

You can use either of following methods to change the hostname: 

1. use hostname control utility: `hostnamectl`
2. use NetworkManager command line tool: `nmcli`
3. use NetworkManager text user interface tool : `nmtui`
4. edit `/etc/hostname` file directly (a reboot afterwards is required)

We can configure 3 hostname types is CentOS/RHEL 7 :
<table>
      <thead>
      <tr>
            <th>Hostname Type</th>
            <th>Description</th>
      </tr>
      </thead>
      <tbody>
<tr><td>Static</td><td>Assigned by the system admin</td></tr>
<tr><td>Dynamic</td><td>Assigned by DHCP or mDNS server at runtime</td></tr>
<tr><td>Pretty</td><td>Assigned by the system admin. Its can be used as Description like “Oracle DB server”</td></tr>
      </tbody>
</table>
 	

Out of these 3, only static hostname is mandatory. Other 2 are optional.

### Method 1 : hostnamectl

To get the current hostname of the system :

```bash
> hostnamectl status
   Static hostname: localhost.localdomain
         Icon name: computer
           Chassis: n/a
        Machine ID: 55cc1c57c7f24ed0b0d352648024cea6
           Boot ID: a12ec8e04e6b4534841d14dc8425e38c
    Virtualization: vmware
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-123.el7.x86_64
      Architecture: x86_64
```

To set new hostname (geeklab) for the machine :

```bash
> hostnamectl set-hostname geeklab    ## static
> hostnamectl set-hostname "Geeks LAB"   ## pretty
```

Re-login and verify the new hostname :

```bash
> hostnamectl
   Static hostname: geekslab
   Pretty hostname: Geeks LAB
         Icon name: computer
           Chassis: n/a
        Machine ID: 55cc1c57c7f24ed0b0d352648024cea6
           Boot ID: a12ec8e04e6b4534841d14dc8425e38c
    Virtualization: vmware
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-123.el7.x86_64
      Architecture: x86_64
```

### Method 2 : nmcli

To view the current hostname :

```bash
> nmcli general hostname
localhost.localdomain
```

To change the hostname to geeklab :

```bash
> nmcli general hostname geeklab
```

We need to restart the systemd-hostnamed service for the changes to take effect :

```bash
> service systemd-hostnamed restart
```

Re-login and erify the hostname change :

```bash
> hostname
geeklab
```

### Method 3 : nmtui

We can also change the hostname using the nmtui tool : `nmtui`

Select the option to `set the hostname`”` and hit enter

```
change hostname nmtui

Set the hostname

set hostname nmtui

Confirm the hostname change

confirm hostname nmtui
```

Restart the systemd-hostnamed service for the changes to take effect.

```bash
> service systemd-hostnamed restart
```

Re-login and verify the hostname change.

```
> hostnamectl
   Static hostname: geeklab
         Icon name: computer
           Chassis: n/a
        Machine ID: 55cc1c57c7f24ed0b0d352648024cea6
           Boot ID: a12ec8e04e6b4534841d14dc8425e38c
    Virtualization: vmware
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-123.el7.x86_64
      Architecture: x86_64
```

### Method 4 : Edit /etc/hostname

This method requires a reboot of the system. View the current content of the file `/etc/hostname`.

```bash
> cat /etc/hostname
localhost.localdomain
```

To change the hostname to `geeklab`, replace the content of the `/etc/hostname` file with `geeklab`

```bash
> echo "geeklab" > /etc/hostname
> cat /etc/hostname
geeklab
```

Restart the system and verify.

```bash
> shutdown -r now
> hostname
geeklab
```