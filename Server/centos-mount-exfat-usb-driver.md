# CentOS 系统挂载USB驱动(磁盘)


[Howto mount USB drive in Linux](https://linuxconfig.org/howto-mount-usb-drive-in-linux)
## 查看USB驱动

使用 `fdisk -l` 列出当前所有的块设备文件, 然后根据设备文件的空间大小来找到插入的U盘设备标示.

假设插入的U盘标示是`/dev/sdb1`

```bash
mkdir /media/usb-drive # 创建挂载点
mount /dev/sdb1 /media/usb-drive/ # 执行挂载
```
如果USB设备类型(格式)是exFAT, 需要执行以下命令进行挂载: 

```bash
mount -t exfat /dev/sdb1 /media/usb-drive/
```
如果执行成功, 上述命令会输出`FUSE exfat 1.2.7`.

如果执行失败可能是因为系统不支持`exFAT`格式的设备, 需要额外安装软件包支持此格式, 对于CentOS系统需要执行以下命令安装 nux-dextop repo, 否则找不到需要安装的安装包(参考[CentOS Yum Not Finding Packages](https://superuser.com/questions/960321/centos-yum-not-finding-packages)):

```bash
yum install -y http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
```

然后安装需要的安装包: 

```bash
# CentOS
yum install exfat-utils fuse-exfat
# Ubuntu
apt-get install exfat-fuse exfat-utils
```

安装完之后就可以继续执行之前的挂载命令了:

```bash
mount -t exfat /dev/sdb1 /media/usb-drive/
```

[How to Mount and Use an exFAT Drive on Linux](https://www.howtogeek.com/235655/how-to-mount-and-use-an-exfat-drive-on-linux/)
