## LocalDB 使用介绍

默认情况下, 安装Visual Studio的时候就会包含SQL Server LocalDB的组件, 默认是安装的. 如果没有, 你可以到微软官网[下载安装](http://www.microsoft.com/en-us/download/details.aspx?id=42299). 

## 使用
切换到 C:\Program Files\Microsoft SQL Server 目录, 然后打开最后一个目录, 我的是`120`, 然后找到 `Tools\Binn\SqlLocalDB.exe`, 打开DOS, 调用这个文件.
创建实例:

	SqlLocalDB.exe create MyInstanceName

运行实例:

	SqlLocalDB.exe start MyInstanceName

查看实例运行状态:

	SqlLocalDB.exe info MyInstanceName

连接实例: 使用VS的SQL Server工具连接时, 实例的全称是`(localdb)\MyInstanceName`, [相关资料](http://stackoverflow.com/questions/26977106/visual-studio-2013-does-not-create-sql-server-2014-localdb-database), 而编码时, 数据库连接字符串就类似于 `Data Source=(localdb)\MyInstanceName;Initial Catalog=Temporary;Integrated Security=True;`, [相关资料](https://connectionstrings.com/sql-server/).

LocalDB用于测试开发还是很方便的.
