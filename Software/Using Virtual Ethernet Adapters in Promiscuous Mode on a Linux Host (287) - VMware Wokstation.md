# Using Virtual Ethernet Adapters in Promiscuous Mode on a Linux Host (287) 

Ref: [Using Virtual Ethernet Adapters in Promiscuous Mode on a Linux Host (287)](https://kb.vmware.com/s/article/287)

## Detail

How do I set my Virtual Ethernet Adapter on my Linux host to run in promiscuous mode?

## Solution

VMware software does not allow the virtual Ethernet adapter to go into promiscuous mode unless the user running the VMware software has permission to make that setting. This follows the standard Linux practice that only root can put a network interface into promiscuous mode.

When you install and configure your VMware software, you run the installation as root, and we create the **vmnet0-vmnet3** devices with root ownership and root group ownership. We also give those devices read/write access for the owner root only. For a user to be able to set the virtual machine's network adapter to promiscuous mode, the user who launches the VMware product needs to have read/write access to the vmnetx device (**/dev/vmnet0** if using basic bridged mode).

One way to do this is to create a new group, add the appropriate users to the group, and give that group read/write access to the appropriate device. These changes need to be made on the host operating system as root (su). For example:

```bash
chgrp newgroup /dev/vmnet0
chmod g+rw /dev/vmnet0
```

where newgroup is the group that should have the ability to set **vmnet0** to promiscuous mode.

If you want all users to be able to set the virtual network adapter (**/dev/vmnet0** in our example) to promiscuous mode, you can simply run the following command on the host operating system as root:

```bash
chmod a+rw /dev/vmnet0
```

For more information about issues with promiscuous mode, see [Host Crashes at Power on with Bridged Networking (514)](https://kb.vmware.com/s/article/514).
 
For Linux systems that use `udev`, you may see the error as device nodes are recreated at boot time:

```
The virtual machines operating system has attempted to enable promiscuous mode on adapter Ethernet0. This is not allowed for security reasons.
```

To resolve this error, create the `vmnet*` devices with the desired ownership and permissions under `/udev/devices/`, rather than creating it under `/dev/`, as above. .
 
Note: The location depends on the flavor of Linux.
