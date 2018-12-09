
## 获取当前程序执行的目录

	var dir = AppDomain.CurrentDomain.BaseDirectory;

## 获取当前DLL所在的目录

	var dir = new Uri(Path.GetDirectoryName(Assembly.GetExecutingAssembly().CodeBase)).AbsolutePath

[How do I get the path of the assembly the code is in?](http://stackoverflow.com/questions/52797/how-do-i-get-the-path-of-the-assembly-the-code-is-in)

[Get the Assembly path C#](http://stackoverflow.com/questions/917053/get-the-assembly-path-c-sharp)