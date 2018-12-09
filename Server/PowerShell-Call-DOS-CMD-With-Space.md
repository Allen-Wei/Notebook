# PowerShell调用带有空格的cmd命令

比如说执行以下cmd的sc命令查看所有服务的状态:

	'sc.exe query state= all' | Invoke-Expression
	#等同于如下方式
	&'sc.exe' query state= all

NOTE: 
1. 在PS中`sc`是`Set-Content`的alias, 如果想调用真实的DOS命令`sc`, 可以使用`sc.exe`, 参考[Using Windows PowerShell to run old command line tools](https://blogs.technet.microsoft.com/josebda/2012/03/03/using-windows-powershell-to-run-old-command-line-tools-and-their-weirdest-parameters/).
2. `&`和`Invoke-Expression`的区别可以参考[Invoke-expression vs &](http://www.techtalkz.com/microsoft-windows-powershell/205620-invoke-expression-vs.html).

但是如果你想调用的命令不在环境变量`Path`中, 必须用命令的绝对路径来调用的时候, 如果命令的绝对路径带有空格, 假设你需要使用`csi.exe`执行一个C#的脚本文件 `hello.csx`, 你可能会这么写:

	'"C:\Program Files (x86)\MSBuild\14.0\Bin\csi.exe" hello.csx' | Invoke-Expression

这么写是执行不成功的, 必须这么写:

	'&"C:\Program Files (x86)\MSBuild\14.0\Bin\csi.exe" hello.csx' | Invoke-Expression

在实际使用当中, 根据安装的VS版本不同, `csi.exe`可能位于不同的目录, 为了灵活可以这么写:

	#先找到csi.exe文件
	$csi =  Get-ChildItem "C:\Program Files (x86)\MSBuild" -Recurse -Filter csi.exe | Where-Object {$_.DirectoryName.IndexOf("amd64") -eq -1}
	#然后拼接需要的DOS命令
	'&"' +$csi.FullName + '"' + ' hello.csx' | Invoke-Expression

NOTE:
1. `csi.exe` 用法参考 [Essential .NET - C# Scripting](https://msdn.microsoft.com/magazine/mt614271).