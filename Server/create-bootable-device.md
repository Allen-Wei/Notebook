制作Windows启动盘, 来源[Dell](http://zh.community.dell.com/techcenter/b/weblog/archive/2011/09/05/usb-key-windows-7-installation)

```bat
C:\>diskpart

DISKPART> list disk

REM 如果你的机器只有一块硬盘, 那么U盘应该显示为Disk 1
REM 选择U盘为当前磁盘, 请确定一定要选对U盘所对应的磁盘编号. 如果选错了磁盘来清除, 下面的命令可是HOLD不住的哦.
DISKPART> select disk 1

REM 清空磁盘
DISKPART> clean

REM 创建主分区
DISKPART> create partition primary

REM 选择分区
DISKPART> select partition 1

REM 激活分区(一定要做, 不然不能启动)
DISKPART> active

REM 快速格式化为NTFS文件系统, 当然选择成FAT32也是可以的.
DISKPART> format fs=ntfs quick

REM 指定卷,，这个命令是可选的.［］里面包含盘符，不能与现存盘符重复，也可不加参数使用默认。
DISKPART> assign letter=[ ]

REM 退出Diskpart命令模式。
DISKPART> exit
```