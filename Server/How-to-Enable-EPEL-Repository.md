# How to Enable EPEL Repository for RHEL/CentOS 7.x/6.x/5.x

## What is EPEL
EPEL (Extra Packages for Enterprise Linux) is open source and free community based repository project from Fedora team which provides 100% high quality add-on software packages for Linux distribution including RHEL (Red Hat Enterprise Linux), CentOS, and Scientific Linux. Epel project is not a part of RHEL/Cent OS but it is designed for major Linux distributions by providing lots of open source packages like networking, sys admin, programming, monitoring and so on. Most of the epel packages are maintained by Fedora repo.

## How To Enable EPEL Repository in RHEL/CentOS 7/6/5?

First, you need to download the file using Wget and then install it using RPM on your system to enable the EPEL repository. Use below links based on your Linux OS versions. (Make sure you must be root user).

### RHEL/CentOS 7 64 Bit
```bash
## RHEL/CentOS 7 64-Bit ##
# wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# rpm -ivh epel-release-latest-7.noarch.rpm
```

### RHEL/CentOS 6 32-64 Bit
```bash
## RHEL/CentOS 6 32-Bit ##
# wget http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
# rpm -ivh epel-release-6-8.noarch.rpm
## RHEL/CentOS 6 64-Bit ##
# wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
# rpm -ivh epel-release-6-8.noarch.rpm
```

### How Do I Verify EPEL Repo?

You need to run the following command to verify that the EPEL repository is enabled. Once you ran the command you will see epel repository.

```bash
# yum repolist
```

### How Do I Use EPEL Repo?

You need to use YUM command for searching and installing packages. For example we search for Zabbix package using epel repo, lets see it is available or not under epel.

```bash
# yum --enablerepo=epel info zabbix
```

Let’s install Zabbix package using epel repo option –enablerepo=epel switch.

```bash
# yum --enablerepo=epel install zabbix
```

Note: The epel configuration file is located under /etc/yum.repos.d/epel.repo.

Link: [How to Enable EPEL Repository for RHEL/CentOS 7.x/6.x/5.x](https://www.tecmint.com/how-to-enable-epel-repository-for-rhel-centos-6-5/)