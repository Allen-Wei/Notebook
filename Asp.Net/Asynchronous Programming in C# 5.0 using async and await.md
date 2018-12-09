via [Asynchronous Programming in C# 5.0 using async and await](http://www.codeproject.com/Tips/591586/Asynchronous-Programming-in-Csharp-using-async)

###为什么这是重要的
然后, 我么开发人员常常写同步的方法, 然后通过其他方式(Thread, ThreadStart, ThreadPool, BackgroudWorker等等)以异步的方式调用他们, 但是用很自然的方式持续写异步方法是很困难的.
我将要讨论的特性能够让我们很容易创建一步方法, 它能帮助我们把传统的同步方法变成异步方法.
###The Task Class
下面这个例子总结了这个特性(Task), 我们简单地改变一下方法的返回类型就变成了一个异步方法.
让我们假设有一个长时间运行的方法:

	public static IEnumerable<int> getPrimes(int min, int count)
	{
	    return Enumerable.Range(min, count).Where
	      (n => Enumerable.Range(2, (int)Math.Sqrt(n) - 1).All(i => n % i > 0));
	}

上面这个方法将会根据min和count参数运行很长时间.
把它变成异步的一个简单的方式是改变返回类型, 如下:

	public static Task<IEnumerable<int>> getPrimesAsync(int min, int count)
	{
	     return Task.Run (()=> Enumerable.Range(min, count).Where
	      (n => Enumerable.Range(2, (int)Math.Sqrt(n) - 1).All(i =>
	        n % i > 0)));
	}

在上面的例子中，请注意我们改变了方法名, 加了一个Async, 这是一个约定.
如果同步方法的返回类型是void, 异步的返回类型就是Task, 如果同步方法的返回类型是T, 那异步方法的返回类型就是Task<T>.

### Task是什么

