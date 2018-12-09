via [Asynchronous Programming in C# 5.0 using async and await](http://www.codeproject.com/Tips/591586/Asynchronous-Programming-in-Csharp-using-async)

###Ϊʲô������Ҫ��
Ȼ��, ��ô������Ա����дͬ���ķ���, Ȼ��ͨ��������ʽ(Thread, ThreadStart, ThreadPool, BackgroudWorker�ȵ�)���첽�ķ�ʽ��������, �����ú���Ȼ�ķ�ʽ����д�첽�����Ǻ����ѵ�.
�ҽ�Ҫ���۵������ܹ������Ǻ����״���һ������, ���ܰ������ǰѴ�ͳ��ͬ����������첽����.
###The Task Class
������������ܽ����������(Task), ���Ǽ򵥵ظı�һ�·����ķ������;ͱ����һ���첽����.
�����Ǽ�����һ����ʱ�����еķ���:

	public static IEnumerable<int> getPrimes(int min, int count)
	{
	    return Enumerable.Range(min, count).Where
	      (n => Enumerable.Range(2, (int)Math.Sqrt(n) - 1).All(i => n % i > 0));
	}

������������������min��count�������кܳ�ʱ��.
��������첽��һ���򵥵ķ�ʽ�Ǹı䷵������, ����:

	public static Task<IEnumerable<int>> getPrimesAsync(int min, int count)
	{
	     return Task.Run (()=> Enumerable.Range(min, count).Where
	      (n => Enumerable.Range(2, (int)Math.Sqrt(n) - 1).All(i =>
	        n % i > 0)));
	}

������������У���ע�����Ǹı��˷�����, ����һ��Async, ����һ��Լ��.
���ͬ�������ķ���������void, �첽�ķ������;���Task, ���ͬ�������ķ���������T, ���첽�����ķ������;���Task<T>.

### Task��ʲô

