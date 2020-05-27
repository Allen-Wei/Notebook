# 命令行设置 Windows 7 LAN 代理

ref: [How do I change the Windows7 LAN proxy config from the command line?](https://superuser.com/questions/337685/how-do-i-change-the-windows7-lan-proxy-config-from-the-command-line)


In Windows 7 proxycfg.exe has been replaced with the netsh command. Netsh.exe is a command-line scripting utility that allows you to, either locally or remotely, display or modify the network configuration of a computer that is currently running. To setup a local machine proxy you would use the following syntax:

* open a command prompt in administrative mode (hit start globe, type cmd, then hit Ctrl+Shift + Enter)

To set a proxy:

```powershell
netsh winhttp set proxy  [proxy server address:port number] [bypass list]
```

Example:

```powershell
netsh winhttp set proxy "myproxy.proxyaddress.com:8484" "<local>;*.proxyaddress.com"
```

To check your proxy server setting:

```powershell
netsh winhttp show proxy
```

To remove the proxy server setting:

```powershell
netsh winhttp reset proxy
```

The `netsh` command is interactive so you can always just type netsh and then the subsequent commands you need to save some key stroaks.

Important note: If you're running on a 64-bit OS, and want the proxy to be applied for 32-bit processes as well, you'll need to also modify your settings by running `C:\Windows\SysWow64\netsh.exe`. This is caused by a bug in Windows 7's version of netsh.exe, which doesn't write the registry values to the `Wow6432Node` key. This bug seems to be fixed for Windows 10 (and probably Windows 8 as well)
