
# DOS延迟执行

Ref: [How to wait in a batch script?](https://stackoverflow.com/questions/735285/how-to-wait-in-a-batch-script)

## 方式1

支持 Windows 7+

```batch
:top
cls  REM 清空屏幕
type G:\empty.txt REM 创建空文件
timeout /T 50 REM 等待50s 
goto top REM 回到 top 位置继续执行
```

## 方式2

支持 Windows XP+

```batch
REM  假设延迟 10s 
ping -n 11 127.0.0.1 > nul
```

## 示例

下面是使用 frp 工具示例, 每隔30s重试frpc连接, 直到连接成功:

```batch
taskkill /F /IM frpc.exe REM 删除正在运行的 frpc.exe 程序
:retry
"C:\frp_0.29.1_windows_amd64\frpc.exe" -c "C:\frp_0.29.1_windows_amd64\frpc.ini"
timeout /T 30
goto retry
```

可以把上面的脚本保存成批处理文件(比如 __frpc-run.bat__ )放到 `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup` 目录就可以登陆自动启动了. 

运行里输入 `Control Userpasswords2` 可以设置开机自动登陆.

下面是 frpc.ini 配置示例: 

```ini
[common]
server_addr = sub.domain.com # 服务器地址(可以是域名/IP)
server_port = 8000 # 服务器 frps 设置的端口号

# 下面配置的是开放远程桌面
[range:tcp_port]
type = tcp
local_ip = 127.0.0.1 
local_port = 3389 # 本地机器的远程桌面端口号一般是 3389
remote_port = 8019 # 远程可以指定任意一个未使用的端口号
use_encryption = false
```

执行上面的脚本 __frpc-run.bat__ 就可以通过访问 `sub.domain.com:8019` 远程访问这个机器了.