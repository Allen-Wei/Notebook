## LocalDB ʹ�ý���

Ĭ�������, ��װVisual Studio��ʱ��ͻ����SQL Server LocalDB�����, Ĭ���ǰ�װ��. ���û��, ����Ե�΢�����[���ذ�װ](http://www.microsoft.com/en-us/download/details.aspx?id=42299). 

## ʹ��
�л��� C:\Program Files\Microsoft SQL Server Ŀ¼, Ȼ������һ��Ŀ¼, �ҵ���`120`, Ȼ���ҵ� `Tools\Binn\SqlLocalDB.exe`, ��DOS, ��������ļ�.
����ʵ��:

	SqlLocalDB.exe create MyInstanceName

����ʵ��:

	SqlLocalDB.exe start MyInstanceName

�鿴ʵ������״̬:

	SqlLocalDB.exe info MyInstanceName

����ʵ��: ʹ��VS��SQL Server��������ʱ, ʵ����ȫ����`(localdb)\MyInstanceName`, [�������](http://stackoverflow.com/questions/26977106/visual-studio-2013-does-not-create-sql-server-2014-localdb-database), ������ʱ, ���ݿ������ַ����������� `Data Source=(localdb)\MyInstanceName;Initial Catalog=Temporary;Integrated Security=True;`, [�������](https://connectionstrings.com/sql-server/).

LocalDB���ڲ��Կ������Ǻܷ����.
