
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
:retry
"C:\frp_0.29.1_windows_amd64\frpc.exe" -c "C:\frp_0.29.1_windows_amd64\frpc.ini"
timeout /T 30
goto retry
```

可以把上面的脚本放到 `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup` 就可以登陆自动启动了. 

运行里输入 `Control Userpasswords2` 可以设置开机自动登陆.