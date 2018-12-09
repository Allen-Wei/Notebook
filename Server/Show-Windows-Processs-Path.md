# 显示 Windows 进程的执行程序路径

via: [Show EXE file path of running processes on the command-line in Windows](https://superuser.com/questions/768984/show-exe-file-path-of-running-processes-on-the-command-line-in-windows)

```dos
PS C:\> gwmi win32_process | select Handle, CommandLine | format-list
PS C:\> gwmi win32_process | select name
PS C:\> gwmi win32_process | select CommandLine
C:\>wmic process get ProcessID,ExecutablePath
C:\>wmic process where "name='mysqld.exe'" get ProcessID, ExecutablePath
C:\>wmic process where "name='mysqld.exe'" get ProcessID, ExecutablePath /FORMAT:LIST
```