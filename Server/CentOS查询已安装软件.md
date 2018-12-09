# CentOS 查询已安装软件

## Using RPM Package Manager

```bash
> rpm -qa
```

## Using YUM Package Manager

```bash
> yum list installed
```

### Using YUM-Utils

Yum-utils is an assortment of tools and programs for managing yum repositories, installing debug packages, source packages, extended information from repositories and administration.

To install it, run the command below as root, otherwise, use sudo command:

```bash
> yum update && yum install yum-utils
```

Once you have it installed, type the repoquery command below to list all installed packages on your system:

```bash
> repoquery -a --installed 
```

To list installed packages from a particular repository, use the yumdb program in the form below:

```bash
> yumdb search from_repo base
```

Via: [3 Ways to List All Installed Packages in RHEL, CentOS and Fedora](https://www.tecmint.com/list-installed-packages-in-rhel-centos-fedora/)