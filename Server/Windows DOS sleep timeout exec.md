
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