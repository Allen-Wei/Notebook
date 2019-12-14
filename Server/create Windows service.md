
创建Windows服务

> 参考 [Create your own user-defined services Windows NT/2000/XP/2003](http://www.tacktech.com/display.cfm?ttid=197), 和 [Run a Windows Application as a Service with srvany](https://www.iceflatline.com/2015/12/run-a-windows-application-as-a-service-with-srvany/)

## 下载工具

[srvany.zip](http://www.tacktech.com/display.cfm?ttid=197), 或者从[本仓库下载](../files/srvany.zip)

## 创建服务

使用管理员权限打开控制台, 假设服务名称为 `frpc`: 

```dos
c:\srvany\instsrv.exe "frpc" c:\srvany\srvany.exe
```

`instsrv.exe` 和 `srvany.exe` 一定要用绝对路径, 也就是 `c:\srvany\instsrv.exe`, 不能使用相对路径(比如`.\instsrv.exe`是不行的).

## 更改注册表

打开注册表, 定位到 `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\frpc`, 然后新建一个名为 `Parameters` 的 Key( _Edit > New > Key_), 然后右击这个Key, 新建一个名为`Application`的 __String Value__, 双击这个Key, 值输入要执行的程序(比如: `"C:\frp_0.29.1_windows_amd64\frpc.exe" -c "C:\frp_0.29.1_windows_amd64\frpc.ini"`)

## 启动

```bash
sc start "frpc" #启动服务
sc delete "frcp" #删除服务
```

## 设置Windows启动自动登陆:

运行输入 `Control Userpasswords2`, 在打开的窗口里选中要自动登陆的账号, 取消勾选用户登陆必须输入用户名和密码使用电脑, 然后点击保存输入账号的密码即可.