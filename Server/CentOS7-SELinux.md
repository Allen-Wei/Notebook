## How to Disable SELinux on CentOS 7

SELinux (Security Enhanced Linux) is a Linux kernel security module that allows administrators and users more control over access controls. It allows access based on SELinux policy rules.

SELinux policy rules specify how processes and users interact with each other as well as how processes and users interact with files.

When no SELinux policy rule explicitly allows access, such as for a process opening a file, access is denied.

SELinux has three modes:

* Enforcing: SELinux allows access based on SELinux policy rules.
* Permissive: SELinux only logs actions that would have been denied if running in enforcing mode.
* Disabled: No SELinux policy is loaded.

By default, in CentOS 7, SELinux is enabled and in enforcing mode.

It is recommended to keep SELinux in enforcing mode, but in some cases, you may need to set it to a permissive mode or disable it completely.

In this tutorial, we will show you how to disable SELinux on CentOS 7 systems.

### Prerequisites

Before starting with the tutorial, make sure you are logged in as a user with sudo privileges.

### Check the SELinux Status

To view the current SELinux status and the SELinux policy that is being used on your system, use the sestatus command:

```bash
sestatus

SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      31
```

You can see from the output above that SELinux is enabled and set to enforcing mode.

### Disable SELinux

You can temporarily change the SELinux mode from targeted to permissive with the following command:

```bash
sudo setenforce 0
```

However, this change is valid for the current runtime session only.

To permanently disable SELinux on your CentOS 7 system, follow the steps below:

Open the `/etc/selinux/config` file and set the `SELINUX` mod to disabled:

```
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#       enforcing - SELinux security policy is enforced.
#       permissive - SELinux prints warnings instead of enforcing.
#       disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of these two values:
#       targeted - Targeted processes are protected,
#       mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

Save the file and reboot your CentOS system with:

```bash
sudo shutdown -r now
```

Once the system boots up, verify the change with the sestatus command:

```bash
sestatus
```

The output should look like this:

```
SELinux status:                 disabled
```